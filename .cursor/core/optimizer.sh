#!/bin/bash

# 🎯 Cursor AI Rules - 统一优化控制器
# 整合所有性能优化功能，提供简单易用的接口

set -e

# 加载所有优化模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/batch-executor.sh"
source "$SCRIPT_DIR/token-compression.sh"

# 优化配置
OPTIMIZATION_LEVEL="${OPTIMIZATION_LEVEL:-balanced}"  # minimal, balanced, aggressive, maximum
AUTO_OPTIMIZE="${AUTO_OPTIMIZE:-true}"

# 优化策略配置
declare -A OPTIMIZATION_STRATEGIES=(
    ["minimal"]="COMPACT_MODE=false; CACHE_TTL=60; MAX_PARALLEL=1"
    ["balanced"]="COMPACT_MODE=true; CACHE_TTL=300; MAX_PARALLEL=2"
    ["aggressive"]="COMPACT_MODE=true; CACHE_TTL=600; MAX_PARALLEL=4"
    ["maximum"]="COMPACT_MODE=true; CACHE_TTL=1800; MAX_PARALLEL=8"
)

# 初始化优化系统
init_optimizer() {
    smart_echo "初始化统一优化系统..." "processing"

    # 初始化各个子系统
    init_cache
    init_monitoring
    init_compression
    init_streaming
    init_incremental_updates
    init_predictive_preload
    auto_select_mode

    # 应用优化策略
    apply_optimization_strategy "$OPTIMIZATION_LEVEL"

    smart_echo "优化系统初始化完成" "success"
}

# 应用优化策略
apply_optimization_strategy() {
    local strategy="$1"

    if [ -z "${OPTIMIZATION_STRATEGIES[$strategy]}" ]; then
        smart_echo "未知优化策略: $strategy" "warning"
        return 1
    fi

    # 解析策略配置
    local config="${OPTIMIZATION_STRATEGIES[$strategy]}"
    while IFS=';' read -ra PAIR; do
        for pair in "${PAIR[@]}"; do
            if [[ $pair =~ ^([^=]+)=(.*)$ ]]; then
                local var="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                export "$var"="$value"
            fi
        done
    done <<< "$config"

    smart_echo "已应用优化策略: $strategy" "info"
}

# 智能执行（整合所有优化）
optimized_execute() {
    local user_input="$1"
    local start_time=$(date +%s)

    # 1. 快速意图分析（使用缓存）
    local intent_result=$(cached_intent_analysis "$user_input")
    local intent_type=$(echo "$intent_result" | jq -r '.quick_intent_analysis.intent_type // .intent_analysis.intent_type // "unknown"' 2>/dev/null)

    # 2. 环境感知（使用缓存）
    local env_result=$(cached_env_perception)

    # 3. 智能决策制定
    local decision_result=$(make_quick_decision "$intent_result" "$env_result")

    # 4. 显示精简分析结果
    show_compact_analysis "$intent_result" "$env_result" "$decision_result"

    # 5. 优化执行策略
    local should_execute=$(echo "$decision_result" | jq -r '.decision_making.should_execute')
    if [ "$should_execute" = "true" ]; then
        optimized_decision_execute "$decision_result"
    fi

    # 6. 高级token压缩和流式输出
    local response_data="{
        \"intent_analysis\": $intent_result,
        \"environment_analysis\": $env_result,
        \"decision_making\": $decision_result,
        \"execution_time_ms\": $(($(date +%s) - start_time))
    }"

    # 应用token压缩
    local compressed_response=$(execute_optimized "response_generation" "$response_data" "technical")
    end_streaming

    # 7. 记录性能指标
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local original_tokens=$(estimate_tokens "response" "${#response_data}")
    local compressed_tokens=$(estimate_tokens "compressed_response" "${#compressed_response}")
    local tokens_saved=$((original_tokens - compressed_tokens))

    log_performance_metric "optimized_execute" "$duration" "$(get_memory_usage)" "$(get_cpu_usage)" "success"
    log_token_usage "optimized_execute" "$compressed_tokens" "$original_tokens" "false"

    # 8. 更新监控指标
    update_metrics

    smart_echo "优化执行完成 (${duration}ms, ${compressed_tokens}/${original_tokens} tokens, 节省: ${tokens_saved})" "success"
}

# 快速决策制定（简化版）
make_quick_decision() {
    local intent_json="$1"
    local env_json="$2"

    local intent_type=$(echo "$intent_json" | jq -r '.quick_intent_analysis.intent_type // .intent_analysis.intent_type // "unknown"')
    local confidence=$(echo "$intent_json" | jq -r '.quick_intent_analysis.confidence // .intent_analysis.confidence // 0')

    local should_execute=true
    local execution_plan="[]"
    local explanation=""

    case "$intent_type" in
        "project_creation")
            execution_plan="[\"env_check\"]"
            explanation="快速环境检查"
            ;;
        "code_optimization")
            execution_plan="[\"quick_lint\"]"
            explanation="快速代码检查"
            ;;
        "git_operation")
            execution_plan="[\"git_status\"]"
            explanation="Git状态检查"
            ;;
        "unknown")
            should_execute=false
            explanation="无法识别意图"
            ;;
        *)
            execution_plan="[\"env_check\"]"
            explanation="通用环境检查"
            ;;
    esac

    cat << EOF
{
  "decision_making": {
    "should_execute": $should_execute,
    "execution_plan": $execution_plan,
    "explanation": "$explanation",
    "intent_type": "$intent_type",
    "confidence": $confidence
  }
}
EOF
}

# 批量优化执行
batch_optimize() {
    local operations="$1"

    smart_echo "开始批量优化执行..." "processing"

    # 解析操作列表
    echo "$operations" | jq -c '.[]' | while read -r op; do
        local op_type=$(echo "$op" | jq -r '.type')
        local op_params=$(echo "$op" | jq -r '.params // ""')

        batch_add "$op_type" "$op_params"
    done

    # 执行批量操作
    batch_execute
}

# 性能分析和报告
performance_analysis() {
    echo "🔍 性能深度分析"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 显示性能报告
    show_performance_report

    echo ""
    echo "💾 缓存状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ls -la $CURSOR_GROWTH/analytics/cache/ 2>/dev/null | wc -l | xargs echo "分析缓存文件数量:"

    echo ""
    echo "🎯 优化建议"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 基于当前指标提供建议
    local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent // 0' "$METRICS_FILE" 2>/dev/null)
    local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms // 0' "$METRICS_FILE" 2>/dev/null)

    if [ "$cache_hit_rate" -lt 50 ]; then
        echo "• 考虑增加缓存有效期或启用更激进的缓存策略"
    fi

    if [ "$avg_response_time" -gt 1500 ]; then
        echo "• 建议启用精简输出模式或增加并行处理"
    fi

    if [ "$COMPACT_MODE" = false ]; then
        echo "• 考虑切换到精简输出模式以减少token消耗"
    fi
}

# 一键系统优化
system_optimize() {
    smart_echo "开始系统优化..." "processing"

    # 1. 清理过期缓存
    clean_expired_cache
    smart_echo "缓存清理完成" "success"

    # 2. 更新性能指标
    update_metrics
    smart_echo "性能指标更新完成" "success"

    # 3. 健康检查
    if health_check >/dev/null 2>&1; then
        smart_echo "系统健康检查通过" "success"
    else
        smart_echo "发现系统问题，请检查" "warning"
    fi

    # 4. 自动调整优化策略
    if [ "$AUTO_OPTIMIZE" = true ]; then
        auto_adjust_strategy
    fi

    smart_echo "系统优化完成" "success"
}

# 自动调整优化策略
auto_adjust_strategy() {
    local current_strategy="$OPTIMIZATION_LEVEL"
    local new_strategy="$current_strategy"

    # 基于性能指标调整策略
    local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms // 1000' "$METRICS_FILE" 2>/dev/null)
    local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent // 50' "$METRICS_FILE" 2>/dev/null)
    local error_rate=$(jq -r '.performance_metrics.error_rate_percent // 5' "$METRICS_FILE" 2>/dev/null)

    # 性能较差时升级策略
    if [ "$avg_response_time" -gt 2000 ] && [ "$current_strategy" != "maximum" ]; then
        case "$current_strategy" in
            "minimal") new_strategy="balanced" ;;
            "balanced") new_strategy="aggressive" ;;
            "aggressive") new_strategy="maximum" ;;
        esac
    fi

    # 性能良好时降级策略（节省资源）
    if [ "$avg_response_time" -lt 500 ] && [ "$cache_hit_rate" -gt 80 ] && [ "$current_strategy" != "minimal" ]; then
        case "$current_strategy" in
            "maximum") new_strategy="aggressive" ;;
            "aggressive") new_strategy="balanced" ;;
            "balanced") new_strategy="minimal" ;;
        esac
    fi

    if [ "$new_strategy" != "$current_strategy" ]; then
        apply_optimization_strategy "$new_strategy"
        OPTIMIZATION_LEVEL="$new_strategy"
        smart_echo "自动调整优化策略: $current_strategy → $new_strategy" "info"
    fi
}

# 显示优化状态
show_optimization_status() {
    echo "🎛️  优化系统状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "📊 当前配置:"
    echo "  • 优化等级: $OPTIMIZATION_LEVEL"
    echo "  • 精简模式: $COMPACT_MODE"
    echo "  • 缓存TTL: ${CACHE_TTL:-300}秒"
    echo "  • 最大并行: ${MAX_PARALLEL:-2}"
    echo "  • 自动优化: $AUTO_OPTIMIZE"

    echo ""
    echo "💾 缓存状态:"
    local cache_files=$(find $CURSOR_GROWTH/cache -name "*.cache" 2>/dev/null | wc -l)
    local cache_size=$(du -sh $CURSOR_GROWTH/cache 2>/dev/null | cut -f1)
    echo "  • 缓存文件: $cache_files 个"
    echo "  • 缓存大小: ${cache_size:-0B}"

    echo ""
    echo "📈 性能概览:"
    if [ -f "$METRICS_FILE" ]; then
        local total_interactions=$(jq -r '.total_interactions // 0' "$METRICS_FILE")
        local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms // 0' "$METRICS_FILE")
        local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent // 0' "$METRICS_FILE")

        echo "  • 总交互: $total_interactions 次"
        echo "  • 平均响应: ${avg_response_time}ms"
        echo "  • 缓存命中: ${cache_hit_rate}%"
    else
        echo "  • 性能数据暂不可用"
    fi
}

# 主函数
main() {
    case "${1:-}" in
        "init")
            init_optimizer
            ;;
        "execute")
            shift
            optimized_execute "$*"
            ;;
        "batch")
            shift
            batch_optimize "$*"
            ;;
        "analyze"|"report")
            performance_analysis
            ;;
        "optimize")
            system_optimize
            ;;
        "status")
            show_optimization_status
            ;;
        "strategy")
            shift
            apply_optimization_strategy "${1:-balanced}"
            ;;
        "cleanup")
            clean_expired_cache
            cleanup_old_data "${2:-30}"
            smart_echo "清理完成" "success"
            ;;
        "help"|"-h"|"--help")
            show_optimizer_help
            ;;
        *)
            smart_echo "使用方法: optimizer.sh [command] [args]" "info"
            echo "运行 'optimizer.sh help' 查看详细帮助"
            ;;
    esac
}

# 显示帮助信息
show_optimizer_help() {
    cat << EOF
🎯 Cursor AI Rules - 统一优化控制器

使用方法:
  optimizer.sh <command> [options]

可用命令:
  init                    初始化优化系统
  execute <input>         优化执行用户输入
  batch <operations>      批量执行操作
  analyze/report          性能分析报告
  optimize                一键系统优化
  status                  显示优化状态
  strategy <level>        设置优化策略 (minimal/balanced/aggressive/maximum)
  cleanup [days]          清理过期数据 (默认30天)

优化策略:
  minimal     最小优化 - 基础功能
  balanced    平衡优化 - 推荐使用 (默认)
  aggressive  激进优化 - 高性能
  maximum     最大优化 - 极致性能

示例:
  # 初始化系统
  optimizer.sh init

  # 优化执行
  optimizer.sh execute "帮我检查代码质量"

  # 批量操作
  optimizer.sh batch '[{"type":"file_check","params":"*.js"},{"type":"git_status"}]'

  # 性能分析
  optimizer.sh analyze

  # 设置激进优化
  optimizer.sh strategy aggressive

  # 系统优化
  optimizer.sh optimize

环境变量:
  OPTIMIZATION_LEVEL    优化等级 (minimal/balanced/aggressive/maximum)
  AUTO_OPTIMIZE         自动优化 (true/false)
  COMPACT_MODE          精简模式 (true/false)
  CACHE_TTL             缓存有效期(秒)
  MAX_PARALLEL          最大并行数

EOF
}

# =============================================================================
# 集成缓存功能 (从performance-cache.sh合并)
# =============================================================================

# 缓存配置
CACHE_DIR="$ANALYTICS_DIR"
CACHE_TTL=300  # 5分钟缓存有效期
PERFORMANCE_LOG="$CACHE_DIR/performance.log"

# 获取缓存键
get_cache_key() {
    local type="$1"
    local input="$2"
    echo "$type:$(echo "$input" | md5sum | cut -d' ' -f1)"
}

# 检查缓存是否有效
is_cache_valid() {
    local cache_file="$1"
    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    local cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local age=$((current_time - cache_time))

    [ $age -lt $CACHE_TTL ]
}

# 从缓存读取数据
read_cache() {
    local cache_key="$1"
    local cache_file="$CACHE_DIR/$cache_key.cache"

    if is_cache_valid "$cache_file"; then
        cat "$cache_file" 2>/dev/null
        return 0
    else
        return 1
    fi
}

# 写入缓存数据
write_cache() {
    local cache_key="$1"
    local data="$2"
    local cache_file="$CACHE_DIR/$cache_key.cache"

    echo "$data" > "$cache_file"
}

# 清除过期缓存
clean_expired_cache() {
    find "$CACHE_DIR" -name "*.cache" -type f -mmin +5 -delete 2>/dev/null || true
}

# 记录性能指标
log_performance() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    local token_estimate="$4"
    local cache_hit="${5:-false}"

    local duration=$((end_time - start_time))
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$operation,$duration,$token_estimate,$cache_hit" >> "$PERFORMANCE_LOG"
}

# 获取性能统计
get_performance_stats() {
    if [ ! -f "$PERFORMANCE_LOG" ]; then
        echo '{"error": "No performance data available"}'
        return
    fi

    # 分析最近的性能数据
    local recent_data=$(tail -n 100 "$PERFORMANCE_LOG" 2>/dev/null || cat "$PERFORMANCE_LOG")

    # 计算平均响应时间
    local avg_duration=$(echo "$recent_data" | awk -F',' '{sum += $3; count++} END {print count > 0 ? sum/count : 0}')

    # 计算缓存命中率
    local total_requests=$(echo "$recent_data" | wc -l)
    local cache_hits=$(echo "$recent_data" | grep ",true$" | wc -l)
    local cache_hit_rate=0
    if [ "$total_requests" -gt 0 ]; then
        cache_hit_rate=$((cache_hits * 100 / total_requests))
    fi

    # 计算平均token消耗
    local avg_tokens=$(echo "$recent_data" | awk -F',' '{sum += $4; count++} END {print count > 0 ? sum/count : 0}')

    cat << EOF
{
  "performance_stats": {
    "average_response_time_ms": ${avg_duration:-0},
    "cache_hit_rate_percent": $cache_hit_rate,
    "average_token_consumption": ${avg_tokens:-0},
    "total_requests_analyzed": $total_requests,
    "time_range": "last_100_requests"
  }
}
EOF
}

# 智能缓存的环境感知
cached_env_perception() {
    local cache_key=$(get_cache_key "env_perception" "full_scan")
    local start_time=$(date +%s)

    # 尝试从缓存读取
    if read_cache "$cache_key" >/dev/null 2>&1; then
        # 缓存命中：读取并输出缓存内容
        local cached_data=$(read_cache "$cache_key")
        local end_time=$(date +%s)
        log_performance "env_perception" "$start_time" "$end_time" "50" "true"
        echo "$cached_data"
        return 0
    fi

    # 缓存未命中，执行实际感知（精简版）
    local result=$(quick_env_scan)
    write_cache "$cache_key" "$result"

    local end_time=$(date +%s)
    log_performance "env_perception" "$start_time" "$end_time" "500" "false"

    echo "$result"
}

# 快速环境扫描（精简版）
quick_env_scan() {
    cat << EOF
{
  "quick_env_scan": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "project_type": "$(detect_project_type)",
    "has_git": $(git rev-parse --git-dir >/dev/null 2>&1 && echo "true" || echo "false"),
    "has_package_json": $([ -f "package.json" ] && echo "true" || echo "false"),
    "has_requirements_txt": $([ -f "requirements.txt" ] || [ -f "pyproject.toml" ] && echo "true" || echo "false"),
    "working_directory": "$PWD"
  }
}
EOF
}

# 快速项目类型检测
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "javascript"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "golang"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

# 智能缓存的意图分析
cached_intent_analysis() {
    local user_input="$1"
    local cache_key=$(get_cache_key "intent_analysis" "$user_input")
    local start_time=$(date +%s)

    # 尝试从缓存读取
    if read_cache "$cache_key" >/dev/null 2>&1; then
        # 缓存命中：读取并输出缓存内容
        local cached_data=$(read_cache "$cache_key")
        local end_time=$(date +%s)
        log_performance "intent_analysis" "$start_time" "$end_time" "30" "true"
        echo "$cached_data"
        return 0
    fi

    # 执行简化的意图分析
    local result=$(quick_intent_analysis "$user_input")
    write_cache "$cache_key" "$result"

    local end_time=$(date +%s)
    log_performance "intent_analysis" "$start_time" "$end_time" "150" "false"

    echo "$result"
}

# 快速意图分析（精简版）
quick_intent_analysis() {
    local user_input="$1"

    # 简单的意图识别规则
    local intent_type="unknown"
    local confidence=0

    if echo "$user_input" | grep -qiE "(创建|开发|构建|搭建|做一个)"; then
        intent_type="project_creation"
        confidence=90
    elif echo "$user_input" | grep -qiE "(优化|改进|重构|质量|检查)"; then
        intent_type="code_optimization"
        confidence=85
    elif echo "$user_input" | grep -qiE "(分析|评估|诊断|状态)"; then
        intent_type="project_analysis"
        confidence=80
    elif echo "$user_input" | grep -qiE "(提交|推送|push)"; then
        intent_type="git_operation"
        confidence=95
    fi

    cat << EOF
{
  "quick_intent_analysis": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
}

# =============================================================================
# 集成监控功能 (从performance-monitor.sh合并)
# =============================================================================

# 监控配置
METRICS_FILE="$ANALYTICS_DATA_DIR/analytics-monitoring-metrics.json"
TOKEN_LOG="$ANALYTICS_DATA_DIR/analytics-monitoring-token-usage.log"
PERFORMANCE_LOG_MONITOR="$ANALYTICS_DATA_DIR/analytics-monitoring-performance.log"

# 初始化监控系统
init_monitoring() {
    safe_file_operation "mkdir" "$ANALYTICS_DATA_DIR"
    safe_file_operation "mkdir" "$ANALYTICS_CACHE_DIR"

    # 初始化指标文件
    if [ ! -f "$METRICS_FILE" ]; then
        cat > "$METRICS_FILE" << EOF
{
  "monitoring_start": "$(date '+%Y-%m-%d %H:%M:%S')",
  "total_interactions": 0,
  "performance_metrics": {
    "average_response_time_ms": 0,
    "cache_hit_rate_percent": 0,
    "average_token_consumption": 0,
    "peak_memory_usage_mb": 0,
    "error_rate_percent": 0
  },
  "token_economics": {
    "total_tokens_consumed": 0,
    "tokens_saved_by_cache": 0,
    "cost_savings_usd": 0,
    "efficiency_rating": "unknown"
  },
  "system_health": {
    "uptime_percent": 100,
    "error_count": 0,
    "warning_count": 0,
    "last_health_check": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
    fi

    smart_echo "监控系统初始化完成" "info"
}

# 记录token使用情况
log_token_usage() {
    local operation="$1"
    local tokens_used="$2"
    local tokens_estimated="$3"
    local cache_hit="$4"

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp,$operation,$tokens_used,$tokens_estimated,$cache_hit" >> "$TOKEN_LOG"
}

# 记录性能指标
log_performance_metric() {
    local operation="$1"
    local response_time_ms="$2"
    local memory_usage_kb="$3"
    local cpu_usage_percent="$4"
    local status="${5:-success}"

    # 统一使用5列格式，与cache.sh保持一致
    # timestamp,operation,duration,token_estimate,cache_hit
    local token_estimate=$(estimate_tokens "$operation" "${#status}")
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp,$operation,$response_time_ms,$token_estimate,$cpu_usage_percent" >> "$PERFORMANCE_LOG_MONITOR"
}

# 估算token消耗（基于操作类型）
estimate_tokens() {
    local operation="$1"
    local data_size="${2:-0}"

    case "$operation" in
        "env_perception")
            echo $((50 + data_size / 100))  # 基础50 + 每100字符额外token
            ;;
        "intent_analysis")
            echo $((30 + data_size / 50))   # 基础30 + 每50字符额外token
            ;;
        "file_read")
            echo $((20 + data_size / 200))  # 基础20 + 每200字符额外token
            ;;
        "code_execution")
            echo $((100 + data_size / 20))  # 基础100 + 代码复杂度
            ;;
        "git_operation")
            echo "25"  # Git操作相对固定
            ;;
        "cache_hit")
            echo "5"   # 缓存命中消耗很少
            ;;
        "response"|"original"|"compressed"|"compressed_response"|"generic"|"optimized")
            echo $(( (data_size * 10 + 36) / 37 ))  # ~chars/3.7，近似 cl100k
            ;;
        *)
            echo $(( (data_size * 10 + 36) / 37 ))
            ;;
    esac
}

# 获取当前内存使用情况
get_memory_usage() {
    # 尝试多种方式获取内存使用
    if command -v free >/dev/null 2>&1; then
        free -k | awk 'NR==2{printf "%.0f", $3/1024}'  # MB
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS
        vm_stat | awk '/Pages active/ {print int($3 * 4096 / 1024 / 1024)}'
    else
        echo "0"
    fi
}

# 获取CPU使用率
get_cpu_usage() {
    if command -v top >/dev/null 2>&1; then
        top -bn1 | awk '/Cpu/ {print int($2)}' 2>/dev/null || echo "0"
    elif command -v iostat >/dev/null 2>&1; then
        iostat -c 1 1 | awk 'NR==4{print int(100 - $6)}' 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# 更新监控指标
update_metrics() {
    if [ ! -f "$METRICS_FILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: metrics.json file not found" >&2
        return 1
    fi

    # 计算token统计 (token_usage.log: timestamp,operation,tokens,cache_hit)
    local total_tokens=0
    local cached_tokens=0
    if [ -f "$TOKEN_LOG" ] && [ -s "$TOKEN_LOG" ]; then
        total_tokens=$(awk -F',' 'NF>=3 {sum += $3} END {print sum+0}' "$TOKEN_LOG" 2>/dev/null || echo "0")
        cached_tokens=$(awk -F',' 'NF>=4 && $4=="true" {sum += $3} END {print sum+0}' "$TOKEN_LOG" 2>/dev/null || echo "0")
    fi
    local cache_savings=$((total_tokens - cached_tokens))

    # 计算性能统计 (performance.log: timestamp,operation,duration,token_estimate,cache_hit)
    local total_requests=0
    local avg_response_time=0
    if [ -f "$PERFORMANCE_LOG_MONITOR" ] && [ -s "$PERFORMANCE_LOG_MONITOR" ]; then
        # 过滤掉注释行和空行
        total_requests=$(grep -v '^#' "$PERFORMANCE_LOG_MONITOR" | grep -v '^$' | wc -l)
        if [ "$total_requests" -gt 0 ]; then
            avg_response_time=$(grep -v '^#' "$PERFORMANCE_LOG_MONITOR" | grep -v '^$' | awk -F',' '{sum += $3} END {print int(sum/NR)}' 2>/dev/null || echo "0")
        fi
    fi

    # 计算缓存命中率 (基于token日志)
    local cache_hit_rate=0
    if [ "$total_tokens" -gt 0 ]; then
        cache_hit_rate=$((cached_tokens * 100 / total_tokens))
    fi

    # 计算错误率 (暂时设为0，未来可以扩展)
    local error_rate=0

    # 更新指标文件
    if jq --arg total_tokens "$total_tokens" \
          --arg cache_savings "$cache_savings" \
          --arg total_requests "$total_requests" \
          --arg avg_response_time "$avg_response_time" \
          --arg cache_hit_rate "$cache_hit_rate" \
          --arg error_rate "$error_rate" \
          --arg current_time "$(date '+%Y-%m-%d %H:%M:%S')" \
          '.total_interactions = ($total_requests | tonumber) |
           .performance_metrics.average_response_time_ms = ($avg_response_time | tonumber) |
           .performance_metrics.cache_hit_rate_percent = ($cache_hit_rate | tonumber) |
           .performance_metrics.error_rate_percent = ($error_rate | tonumber) |
           .token_economics.total_tokens_consumed = ($total_tokens | tonumber) |
           .token_economics.tokens_saved_by_cache = ($cache_savings | tonumber) |
           .system_health.last_health_check = $current_time' "$METRICS_FILE" > "${METRICS_FILE}.tmp" 2>/dev/null; then
        mv "${METRICS_FILE}.tmp" "$METRICS_FILE"
    else
        # jq失败，清理临时文件并记录错误
        rm -f "${METRICS_FILE}.tmp"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to update metrics.json" >&2
        return 1
    fi
}

# 显示性能报告
show_performance_report() {
    if [ ! -f "$METRICS_FILE" ]; then
        echo "⚠️  性能监控数据不可用"
        return 1
    fi

    echo "📊 性能监控报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 读取指标
    local total_interactions=$(jq -r '.total_interactions' "$METRICS_FILE")
    local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms' "$METRICS_FILE")
    local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent' "$METRICS_FILE")
    local error_rate=$(jq -r '.performance_metrics.error_rate_percent' "$METRICS_FILE")
    local total_tokens=$(jq -r '.token_economics.total_tokens_consumed' "$METRICS_FILE")
    local tokens_saved=$(jq -r '.token_economics.tokens_saved_by_cache' "$METRICS_FILE")

    echo "🎯 总交互次数: $total_interactions"
    echo "⚡ 平均响应时间: ${avg_response_time}ms"
    echo "💾 缓存命中率: ${cache_hit_rate}%"
    echo "❌ 错误率: ${error_rate}%"
    echo "🎫 Token消耗: $total_tokens (节省: $tokens_saved)"

    # 性能评分
    local performance_score=100
    [ "$avg_response_time" -gt 2000 ] && performance_score=$((performance_score - 20))
    [ "$cache_hit_rate" -lt 50 ] && performance_score=$((performance_score - 15))
    [ "$error_rate" -gt 10 ] && performance_score=$((performance_score - 25))

    echo "🏆 性能评分: $performance_score/100"

    # 优化建议
    echo ""
    echo "💡 优化建议:"
    if [ "$cache_hit_rate" -lt 50 ]; then
        echo "  • 启用更激进的缓存策略"
    fi
    if [ "$avg_response_time" -gt 2000 ]; then
        echo "  • 考虑使用精简输出模式"
    fi
    if [ "$error_rate" -gt 10 ]; then
        echo "  • 检查系统配置和依赖"
    fi
}

# 健康检查
health_check() {
    local issues=0
    local warnings=0

    echo "🔍 系统健康检查"

    # 检查缓存目录
    if [ ! -d "$ANALYTICS_DATA_DIR" ]; then
        echo "❌ 缓存目录不存在"
        issues=$((issues + 1))
    fi

    # 检查监控文件
    if [ ! -f "$METRICS_FILE" ]; then
        echo "❌ 指标文件不存在"
        issues=$((issues + 1))
    fi

    # 检查磁盘空间
    local disk_usage=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        echo "⚠️  磁盘空间不足: ${disk_usage}%"
        warnings=$((warnings + 1))
    fi

    # 检查内存使用
    local mem_usage=$(get_memory_usage)
    if [ "$mem_usage" -gt 80 ]; then
        echo "⚠️  内存使用过高: ${mem_usage}%"
        warnings=$((warnings + 1))
    fi

    # 总结
    if [ $issues -eq 0 ] && [ $warnings -eq 0 ]; then
        echo "✅ 系统健康"
        return 0
    elif [ $issues -eq 0 ]; then
        echo "⚠️  系统有 $warnings 个警告"
        return 1
    else
        echo "❌ 系统有 $issues 个问题和 $warnings 个警告"
        return 2
    fi
}

# 清理旧数据
cleanup_old_data() {
    local days_to_keep="${1:-30}"

    # 清理旧的日志文件
    find "$ANALYTICS_DATA_DIR" -name "*.log" -mtime +$days_to_keep -delete 2>/dev/null || true

    echo "🧹 已清理 $days_to_keep 天前的监控数据"
}

# 运行主函数
main "$@"