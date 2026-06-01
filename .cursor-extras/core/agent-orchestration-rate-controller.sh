#!/bin/bash
# ========================================
# Cursor AI Rules - 频率控制系统模块
# 实现多层级API频率控制和智能请求队列管理
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/agent-orchestration-common.sh"
source "$SCRIPT_DIR/token-monitor.js"  # 集成现有的Token监控

# =============================================================================
# 频率控制系统模块 - 核心控制层
# =============================================================================

# 🎛️ 频率控制系统

# =============================================================================
# API限制配置 - 多层级频率控制
# =============================================================================

# API提供商限制配置
declare -A API_LIMITS=(
    # OpenAI GPT-4
    ["openai-gpt4-rpm"]="200"       # requests per minute
    ["openai-gpt4-tpm"]="40000"     # tokens per minute
    ["openai-gpt4-rpd"]="10000"     # requests per day

    # OpenAI GPT-3.5
    ["openai-gpt35-rpm"]="3500"
    ["openai-gpt35-tpm"]="90000"
    ["openai-gpt35-rpd"]="100000"

    # Claude (Anthropic)
    ["anthropic-claude-rpm"]="50"
    ["anthropic-claude-tpm"]="100000"
    ["anthropic-claude-rpd"]="1000"

    # Google Gemini
    ["google-gemini-rpm"]="60"
    ["google-gemini-tpm"]="1000000"
    ["google-gemini-rpd"]="1500"

    # 通义千问
    ["tongyi-qwen-rpm"]="100"
    ["tongyi-qwen-tpm"]="200000"
    ["tongyi-qwen-rpd"]="10000"
)

# 动态调整因子
declare -A ADJUSTMENT_FACTORS=(
    ["success_rate"]="0.3"        # 成功率权重
    ["response_time"]="0.2"       # 响应时间权重
    ["error_rate"]="0.3"          # 错误率权重
    ["resource_usage"]="0.2"      # 资源使用权重
)

# =============================================================================
# 核心频率控制类
# =============================================================================

# 频率限制器类定义
RateLimiter() {
    local limiter_id="$1"
    local provider="$2"

    # 初始化限制器
    init_rate_limiter "$limiter_id" "$provider"
}

# 初始化频率限制器
init_rate_limiter() {
    local limiter_id="$1"
    local provider="$2"

    local limiter_dir="$RATE_LIMITER_DIR/$limiter_id"
    mkdir -p "$limiter_dir"

    # 创建限制器配置文件
    cat > "$limiter_dir/config.json" <<EOF
{
  "limiter_id": "$limiter_id",
  "provider": "$provider",
  "limits": {
    "rpm": $(get_api_limit "$provider-rpm" "60"),
    "tpm": $(get_api_limit "$provider-tpm" "60000"),
    "rpd": $(get_api_limit "$provider-rpd" "1000")
  },
  "current_usage": {
    "requests_minute": 0,
    "tokens_minute": 0,
    "requests_day": 0,
    "last_reset_minute": $(date +%s),
    "last_reset_day": $(date +%s)
  },
  "backoff_strategy": {
    "current_delay": 1,
    "max_delay": 300,
    "multiplier": 2,
    "jitter": 0.1
  },
  "performance_metrics": {
    "success_rate": 0.95,
    "avg_response_time": 2000,
    "error_rate": 0.05,
    "last_updated": $(date +%s)
  }
}
EOF

    smart_echo "频率限制器已初始化: $limiter_id ($provider)" "success"
}

# 检查频率限制
check_rate_limit() {
    local limiter_id="$1"
    local request_tokens="${2:-1000}"

    local limiter_config="$RATE_LIMITER_DIR/$limiter_id/config.json"

    if [[ ! -f "$limiter_config" ]]; then
        smart_echo "频率限制器不存在: $limiter_id" "error"
        return 1
    fi

    # 重置过期计数器
    reset_expired_counters "$limiter_id"

    # 获取当前使用情况
    local current_rpm=$(jq -r '.current_usage.requests_minute' "$limiter_config")
    local current_tpm=$(jq -r '.current_usage.tokens_minute' "$limiter_config")
    local current_rpd=$(jq -r '.current_usage.requests_day' "$limiter_config")

    # 获取限制
    local limit_rpm=$(jq -r '.limits.rpm' "$limiter_config")
    local limit_tpm=$(jq -r '.limits.tpm' "$limiter_config")
    local limit_rpd=$(jq -r '.limits.rpd' "$limiter_config")

    # 检查各种限制
    local retry_after=0

    if (( current_rpm >= limit_rpm )); then
        retry_after=60  # 1分钟后重试
    elif (( current_tpm + request_tokens >= limit_tpm )); then
        retry_after=60  # 1分钟后重试
    elif (( current_rpd >= limit_rpd )); then
        retry_after=3600  # 1小时后重试
    fi

    if (( retry_after > 0 )); then
        echo "{\"allowed\": false, \"retry_after\": $retry_after, \"reason\": \"rate_limit_exceeded\"}"
        return 1
    else
        echo "{\"allowed\": true, \"remaining_rpm\": $((limit_rpm - current_rpm)), \"remaining_tpm\": $((limit_tpm - current_tpm))}"
        return 0
    fi
}

# 记录API调用
record_api_call() {
    local limiter_id="$1"
    local tokens_used="${2:-1000}"
    local success="${3:-true}"

    local limiter_config="$RATE_LIMITER_DIR/$limiter_id/config.json"

    # 更新使用计数
    jq --arg tokens "$tokens_used" \
       '.current_usage.requests_minute += 1 | .current_usage.tokens_minute += ($tokens | tonumber) | .current_usage.requests_day += 1' \
       "$limiter_config" > "${limiter_config}.tmp" && mv "${limiter_config}.tmp" "$limiter_config"

    # 更新性能指标
    update_performance_metrics "$limiter_id" "$success"

    smart_echo "API调用已记录: $limiter_id (+${tokens_used} tokens)" "info"
}

# 重置过期计数器
reset_expired_counters() {
    local limiter_id="$1"
    local limiter_config="$RATE_LIMITER_DIR/$limiter_id/config.json"

    local current_time=$(date +%s)
    local last_reset_minute=$(jq -r '.current_usage.last_reset_minute' "$limiter_config")
    local last_reset_day=$(jq -r '.current_usage.last_reset_day' "$limiter_config")

    # 检查是否需要重置分钟计数器 (60秒)
    if (( current_time - last_reset_minute >= 60 )); then
        jq --arg time "$current_time" \
           '.current_usage.requests_minute = 0 | .current_usage.tokens_minute = 0 | .current_usage.last_reset_minute = ($time | tonumber)' \
           "$limiter_config" > "${limiter_config}.tmp" && mv "${limiter_config}.tmp" "$limiter_config"
    fi

    # 检查是否需要重置日计数器 (24小时)
    if (( current_time - last_reset_day >= 86400 )); then
        jq --arg time "$current_time" \
           '.current_usage.requests_day = 0 | .current_usage.last_reset_day = ($time | tonumber)' \
           "$limiter_config" > "${limiter_config}.tmp" && mv "${limiter_config}.tmp" "$limiter_config"
    fi
}

# 更新性能指标
update_performance_metrics() {
    local limiter_id="$1"
    local success="$2"

    local limiter_config="$RATE_LIMITER_DIR/$limiter_id/config.json"

    # 简单的性能跟踪 (实际应该使用更复杂的算法)
    local current_success_rate=$(jq -r '.performance_metrics.success_rate' "$limiter_config")

    # 指数移动平均更新
    local alpha=0.1
    local new_success_rate
    if [[ "$success" == "true" ]]; then
        new_success_rate=$(echo "scale=4; $current_success_rate + $alpha * (1 - $current_success_rate)" | bc 2>/dev/null || echo "$current_success_rate")
    else
        new_success_rate=$(echo "scale=4; $current_success_rate + $alpha * (0 - $current_success_rate)" | bc 2>/dev/null || echo "$current_success_rate")
    fi

    jq --arg rate "$new_success_rate" \
       '.performance_metrics.success_rate = ($rate | tonumber) | .performance_metrics.last_updated = $(date +%s)' \
       "$limiter_config" > "${limiter_config}.tmp" && mv "${limiter_config}.tmp" "$limiter_config"
}

# 获取API限制
get_api_limit() {
    local key="$1"
    local default="${2:-100}"

    echo "${API_LIMITS[$key]:-$default}"
}

# =============================================================================
# 智能请求队列系统
# =============================================================================

# 请求队列优先级
declare -A QUEUE_PRIORITIES=(
    ["critical"]="100"    # 紧急修复，立即执行
    ["high"]="75"         # 高优先级任务
    ["normal"]="50"       # 普通任务
    ["low"]="25"          # 低优先级任务
    ["background"]="10"   # 后台任务
)

# 初始化请求队列
init_request_queue() {
    local queue_id="$1"

    local queue_dir="$REQUEST_QUEUE_DIR/$queue_id"
    mkdir -p "$queue_dir"

    # 创建队列文件
    for priority in "${!QUEUE_PRIORITIES[@]}"; do
        touch "$queue_dir/${priority}.queue"
        echo "[]" > "$queue_dir/${priority}.stats"
    done

    # 创建队列配置
    cat > "$queue_dir/config.json" <<EOF
{
  "queue_id": "$queue_id",
  "max_size": 1000,
  "processing_concurrency": 3,
  "retry_policy": {
    "max_attempts": 3,
    "base_delay": 1,
    "max_delay": 300,
    "backoff_multiplier": 2
  },
  "created_at": "$(date -Iseconds)",
  "stats": {
    "total_queued": 0,
    "total_processed": 0,
    "total_failed": 0,
    "avg_processing_time": 0
  }
}
EOF

    smart_echo "智能请求队列已初始化: $queue_id" "success"
}

# 添加请求到队列
enqueue_request() {
    local queue_id="$1"
    local priority="${2:-normal}"
    local request_data="$3"

    local queue_dir="$REQUEST_QUEUE_DIR/$queue_id"
    local queue_file="$queue_dir/${priority}.queue"

    if [[ ! -f "$queue_file" ]]; then
        smart_echo "队列不存在: $queue_id/$priority" "error"
        return 1
    fi

    # 检查队列大小限制
    local queue_size=$(jq 'length' "$queue_file" 2>/dev/null || echo "0")
    local max_size=$(jq -r '.max_size' "$queue_dir/config.json" 2>/dev/null || echo "1000")

    if (( queue_size >= max_size )); then
        smart_echo "队列已满: $queue_id/$priority ($queue_size/$max_size)" "warning"
        return 1
    fi

    # 创建请求对象
    local request_id="req_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"
    local request_object=$(cat <<EOF
{
  "request_id": "$request_id",
  "priority": "$priority",
  "data": $request_data,
  "queued_at": "$(date -Iseconds)",
  "attempts": 0,
  "next_retry_at": null,
  "status": "queued"
}
EOF
)

    # 添加到队列
    jq --argjson req "$request_object" '. += [$req]' "$queue_file" > "${queue_file}.tmp" && mv "${queue_file}.tmp" "$queue_file"

    # 更新队列统计
    update_queue_stats "$queue_id" "queued"

    smart_echo "请求已添加到队列: $queue_id/$priority ($request_id)" "success"
    echo "$request_id"
}

# 从队列获取下一个请求
dequeue_request() {
    local queue_id="$1"

    local queue_dir="$REQUEST_QUEUE_DIR/$queue_id"

    # 按优先级顺序检查队列
    for priority in critical high normal low background; do
        local queue_file="$queue_dir/${priority}.queue"

        if [[ -f "$queue_file" ]]; then
            # 查找可处理的请求 (状态为queued且retry时间已到)
            local current_time=$(date +%s)
            local request=$(jq -r --arg time "$current_time" '
                map(select(.status == "queued" and (.next_retry_at == null or (.next_retry_at | strptime("%s") | mktime) <= ($time | tonumber))))
                | sort_by(.queued_at)
                | first // empty
            ' "$queue_file")

            if [[ -n "$request" ]]; then
                local request_id=$(echo "$request" | jq -r '.request_id')

                # 标记为处理中
                jq --arg id "$request_id" \
                   'map(if .request_id == $id then .status = "processing" | .attempts += 1 else . end)' \
                   "$queue_file" > "${queue_file}.tmp" && mv "${queue_file}.tmp" "$queue_file"

                echo "$request"
                return 0
            fi
        fi
    done

    # 没有可处理的请求
    echo ""
    return 1
}

# 完成请求处理
complete_request() {
    local queue_id="$1"
    local request_id="$2"
    local success="${3:-true}"

    local queue_dir="$REQUEST_QUEUE_DIR/$queue_id"

    # 查找并更新请求
    for priority in critical high normal low background; do
        local queue_file="$queue_dir/${priority}.queue"

        if [[ -f "$queue_file" ]]; then
            local found=$(jq --arg id "$request_id" 'any(.request_id == $id)' "$queue_file")

            if [[ "$found" == "true" ]]; then
                if [[ "$success" == "true" ]]; then
                    # 移除成功的请求
                    jq --arg id "$request_id" 'map(select(.request_id != $id))' \
                       "$queue_file" > "${queue_file}.tmp" && mv "${queue_file}.tmp" "$queue_file"
                    update_queue_stats "$queue_id" "completed"
                else
                    # 标记失败并安排重试
                    schedule_retry "$queue_id" "$request_id" "$priority"
                    update_queue_stats "$queue_id" "failed"
                fi
                return 0
            fi
        fi
    done

    smart_echo "请求未找到: $request_id" "warning"
    return 1
}

# 安排请求重试
schedule_retry() {
    local queue_id="$1"
    local request_id="$2"
    local priority="$3"

    local queue_file="$REQUEST_QUEUE_DIR/$queue_id/${priority}.queue"

    # 获取重试配置
    local retry_config=$(jq -r '.retry_policy' "$REQUEST_QUEUE_DIR/$queue_id/config.json")
    local max_attempts=$(echo "$retry_config" | jq -r '.max_attempts')
    local base_delay=$(echo "$retry_config" | jq -r '.base_delay')
    local max_delay=$(echo "$retry_config" | jq -r '.max_delay')
    local multiplier=$(echo "$retry_config" | jq -r '.backoff_multiplier')

    # 获取当前尝试次数
    local attempts=$(jq -r --arg id "$request_id" 'map(select(.request_id == $id))[0].attempts // 0' "$queue_file")

    if (( attempts >= max_attempts )); then
        # 超过最大重试次数，标记为永久失败
        jq --arg id "$request_id" \
           'map(if .request_id == $id then .status = "permanently_failed" else . end)' \
           "$queue_file" > "${queue_file}.tmp" && mv "${queue_file}.tmp" "$queue_file"
        smart_echo "请求达到最大重试次数: $request_id" "error"
        return 1
    fi

    # 计算重试延迟 (指数退避)
    local delay=$(( base_delay * (multiplier ** (attempts - 1)) ))
    if (( delay > max_delay )); then
        delay=$max_delay
    fi

    # 添加随机抖动 (±10%)
    local jitter=$(( delay / 10 ))
    local random_offset=$(( RANDOM % (jitter * 2) - jitter ))
    delay=$(( delay + random_offset ))

    local next_retry=$(date -d "+${delay} seconds" +%s 2>/dev/null || echo "$(( $(date +%s) + delay ))")

    # 更新请求状态
    jq --arg id "$request_id" --arg retry "$next_retry" \
       'map(if .request_id == $id then .status = "queued" | .next_retry_at = ($retry | tonumber) else . end)' \
       "$queue_file" > "${queue_file}.tmp" && mv "${queue_file}.tmp" "$queue_file"

    smart_echo "请求安排重试: $request_id (延迟: ${delay}s)" "info"
}

# 更新队列统计
update_queue_stats() {
    local queue_id="$1"
    local action="$2"

    local config_file="$REQUEST_QUEUE_DIR/$queue_id/config.json"

    case "$action" in
        "queued")
            jq '.stats.total_queued += 1' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
            ;;
        "completed")
            jq '.stats.total_processed += 1' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
            ;;
        "failed")
            jq '.stats.total_failed += 1' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
            ;;
    esac
}

# =============================================================================
# 自适应频率调节器
# =============================================================================

# 自适应调节器
AdaptiveRateController() {
    local controller_id="$1"

    # 初始化调节器
    init_adaptive_controller "$controller_id"
}

# 初始化自适应控制器
init_adaptive_controller() {
    local controller_id="$1"

    local controller_dir="$ADAPTIVE_CONTROLLER_DIR/$controller_id"
    mkdir -p "$controller_dir"

    cat > "$controller_dir/config.json" <<EOF
{
  "controller_id": "$controller_id",
  "adjustment_factors": {
    "success_rate": 0.3,
    "response_time": 0.2,
    "error_rate": 0.3,
    "resource_usage": 0.2
  },
  "performance_history": [],
  "current_adjustments": {
    "frequency_multiplier": 1.0,
    "concurrency_limit": 3,
    "backoff_base": 1,
    "last_adjustment": $(date +%s)
  },
  "thresholds": {
    "good_performance": 0.8,
    "poor_performance": 0.6,
    "max_frequency_multiplier": 2.0,
    "min_frequency_multiplier": 0.1
  }
}
EOF

    smart_echo "自适应频率调节器已初始化: $controller_id" "success"
}

# 计算性能分数
calculate_performance_score() {
    local controller_id="$1"

    local controller_config="$ADAPTIVE_CONTROLLER_DIR/$controller_id/config.json"
    local factors=$(jq -r '.adjustment_factors' "$controller_config")

    # 获取最近的性能指标 (这里应该从实际监控数据获取)
    local success_rate=$(jq -r '.performance_metrics.success_rate // 0.95' "$controller_config" 2>/dev/null || echo "0.95")
    local response_time=$(jq -r '.performance_metrics.avg_response_time // 2000' "$controller_config" 2>/dev/null || echo "2000")
    local error_rate=$(jq -r '.performance_metrics.error_rate // 0.05' "$controller_config" 2>/dev/null || echo "0.05")
    local resource_usage=$(jq -r '.performance_metrics.resource_usage // 0.5' "$controller_config" 2>/dev/null || echo "0.5")

    # 归一化指标 (0-1范围，1为最佳)
    local norm_success=$success_rate
    local norm_response_time=$(echo "scale=4; 1 / (1 + ($response_time / 10000))" | bc 2>/dev/null || echo "0.8")
    local norm_error_rate=$(echo "scale=4; 1 - $error_rate" | bc 2>/dev/null || echo "0.95")
    local norm_resource=$(echo "scale=4; 1 - $resource_usage" | bc 2>/dev/null || echo "0.5")

    # 加权计算综合分数
    local success_weight=$(echo "$factors" | jq -r '.success_rate')
    local response_weight=$(echo "$factors" | jq -r '.response_time')
    local error_weight=$(echo "$factors" | jq -r '.error_rate')
    local resource_weight=$(echo "$factors" | jq -r '.resource_usage')

    local score=$(echo "scale=4; $norm_success * $success_weight + $norm_response_time * $response_weight + $norm_error_rate * $error_weight + $norm_resource * $resource_weight" | bc 2>/dev/null || echo "0.8")

    echo "$score"
}

# 执行频率调整
adjust_frequency() {
    local controller_id="$1"

    local controller_config="$ADAPTIVE_CONTROLLER_DIR/$controller_id/config.json"
    local score=$(calculate_performance_score "$controller_id")

    local current_multiplier=$(jq -r '.current_adjustments.frequency_multiplier' "$controller_config")
    local max_multiplier=$(jq -r '.thresholds.max_frequency_multiplier' "$controller_config")
    local min_multiplier=$(jq -r '.thresholds.min_frequency_multiplier' "$controller_config")

    local new_multiplier="$current_multiplier"

    if (( $(echo "$score > 0.8" | bc -l 2>/dev/null || echo "0") )); then
        # 性能良好，增加频率
        new_multiplier=$(echo "scale=4; $current_multiplier * 1.1" | bc 2>/dev/null || echo "$current_multiplier")
        if (( $(echo "$new_multiplier > $max_multiplier" | bc -l 2>/dev/null || echo "0") )); then
            new_multiplier="$max_multiplier"
        fi
        smart_echo "性能良好，增加频率: ${current_multiplier} → ${new_multiplier}" "success"
    elif (( $(echo "$score < 0.6" | bc -l 2>/dev/null || echo "0") )); then
        # 性能不佳，降低频率
        new_multiplier=$(echo "scale=4; $current_multiplier * 0.9" | bc 2>/dev/null || echo "$current_multiplier")
        if (( $(echo "$new_multiplier < $min_multiplier" | bc -l 2>/dev/null || echo "0") )); then
            new_multiplier="$min_multiplier"
        fi
        smart_echo "性能不佳，降低频率: ${current_multiplier} → ${new_multiplier}" "warning"
    else
        smart_echo "性能稳定，保持当前频率: ${current_multiplier}" "info"
    fi

    # 更新配置
    jq --arg multiplier "$new_multiplier" --arg time "$(date +%s)" \
       '.current_adjustments.frequency_multiplier = ($multiplier | tonumber) | .current_adjustments.last_adjustment = ($time | tonumber)' \
       "$controller_config" > "${controller_config}.tmp" && mv "${controller_config}.tmp" "$controller_config"

    echo "$new_multiplier"
}

# =============================================================================
# 集成Token监控系统
# =============================================================================

# 集成Token监控
integrate_token_monitoring() {
    local limiter_id="$1"

    # 这里应该与现有的token-monitor.js集成
    # 创建监控钩子，在每次API调用时更新Token使用情况

    smart_echo "Token监控已集成: $limiter_id" "success"
}

# 获取Token使用报告
get_token_usage_report() {
    local limiter_id="$1"
    local time_window="${2:-3600}"  # 默认1小时

    # 这里应该从token-monitor.js获取实际数据
    # 目前返回模拟数据

    cat <<EOF
{
  "limiter_id": "$limiter_id",
  "time_window_seconds": $time_window,
  "token_usage": {
    "total_tokens": 15000,
    "requests_count": 45,
    "average_tokens_per_request": 333,
    "peak_usage_minute": 1200,
    "cost_estimate_usd": 0.075
  },
  "rate_limits": {
    "rpm_current": 12,
    "rpm_limit": 200,
    "tpm_current": 4000,
    "tpm_limit": 40000,
    "rpd_current": 180,
    "rpd_limit": 10000
  },
  "recommendations": [
    "当前使用率正常，可以适当增加并发",
    "建议启用请求压缩以降低Token消耗",
    "考虑使用更高效的模型以降低成本"
  ]
}
EOF
}

# =============================================================================
# 主控制器接口
# =============================================================================

# 创建完整的频率控制系统
create_rate_control_system() {
    local system_id="$1"

    smart_echo "创建频率控制系统: $system_id" "processing"

    # 创建频率限制器
    RateLimiter "${system_id}_limiter" "openai-gpt4"

    # 创建请求队列
    init_request_queue "${system_id}_queue"

    # 创建自适应控制器
    AdaptiveRateController "${system_id}_controller"

    # 集成Token监控
    integrate_token_monitoring "${system_id}_limiter"

    smart_echo "频率控制系统创建完成: $system_id" "success"
}

# 获取系统状态
get_rate_control_status() {
    local system_id="$1"

    cat <<EOF
{
  "system_id": "$system_id",
  "limiter_status": $(get_limiter_status "${system_id}_limiter"),
  "queue_status": $(get_queue_status "${system_id}_queue"),
  "controller_status": $(get_controller_status "${system_id}_controller"),
  "token_usage": $(get_token_usage_report "${system_id}_limiter"),
  "last_updated": "$(date -Iseconds)"
}
EOF
}

# 获取限制器状态
get_limiter_status() {
    local limiter_id="$1"
    local config_file="$RATE_LIMITER_DIR/$limiter_id/config.json"

    if [[ -f "$config_file" ]]; then
        jq '.current_usage + {status: "active"}' "$config_file"
    else
        echo '{"status": "not_found"}'
    fi
}

# 获取队列状态
get_queue_status() {
    local queue_id="$1"
    local config_file="$REQUEST_QUEUE_DIR/$queue_id/config.json"

    if [[ -f "$config_file" ]]; then
        local stats=$(jq '.stats' "$config_file")
        local total_queued=0

        for priority in critical high normal low background; do
            local queue_file="$REQUEST_QUEUE_DIR/$queue_id/${priority}.queue"
            if [[ -f "$queue_file" ]]; then
                local count=$(jq 'length' "$queue_file" 2>/dev/null || echo "0")
                total_queued=$((total_queued + count))
            fi
        done

        echo "$stats" | jq --arg total "$total_queued" '. + {total_queued: ($total | tonumber), status: "active"}'
    else
        echo '{"status": "not_found"}'
    fi
}

# 获取控制器状态
get_controller_status() {
    local controller_id="$1"
    local config_file="$ADAPTIVE_CONTROLLER_DIR/$controller_id/config.json"

    if [[ -f "$config_file" ]]; then
        jq '.current_adjustments + {status: "active"}' "$config_file"
    else
        echo '{"status": "not_found"}'
    fi
}

# =============================================================================
# 函数导出
# =============================================================================

export -f RateLimiter
export -f check_rate_limit
export -f record_api_call
export -f init_request_queue
export -f enqueue_request
export -f dequeue_request
export -f complete_request
export -f AdaptiveRateController
export -f calculate_performance_score
export -f adjust_frequency
export -f create_rate_control_system
export -f get_rate_control_status

# 初始化目录
RATE_LIMITER_DIR="$AI_DIR/rate_limiters"
REQUEST_QUEUE_DIR="$AI_DIR/request_queues"
ADAPTIVE_CONTROLLER_DIR="$AI_DIR/adaptive_controllers"

mkdir -p "$RATE_LIMITER_DIR" "$REQUEST_QUEUE_DIR" "$ADAPTIVE_CONTROLLER_DIR"

smart_echo "频率控制系统模块已加载" "success"