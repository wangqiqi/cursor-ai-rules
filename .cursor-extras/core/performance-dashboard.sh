#!/bin/bash

# 🎯 Cursor AI Rules - 性能监控仪表板
# 提供Token使用统计、性能指标监控、优化建议生成

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/performance-monitor.sh"
source "$SCRIPT_DIR/context-pool-manager.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 仪表板配置 (合并到analytics目录)
DASHBOARD_DIR="$ANALYTICS_DIR"
DASHBOARD_METRICS_FILE="$DASHBOARD_DIR/analytics-metrics.json"
DASHBOARD_ANALYSIS_FILE="$DASHBOARD_DIR/analytics-analysis.json"
DASHBOARD_REPORTS_FILE="$DASHBOARD_DIR/analytics-reports.json"

# 性能阈值配置
declare -A PERFORMANCE_THRESHOLDS=(
    ["response_time_max"]=3000      # 最大响应时间(ms)
    ["token_usage_max"]=1000        # 最大Token使用量
    ["memory_usage_max"]=80         # 最大内存使用率(%)
    ["cpu_usage_max"]=70            # 最大CPU使用率(%)
    ["cache_hit_rate_min"]=70       # 最小缓存命中率(%)
    ["compression_ratio_min"]=20    # 最小压缩比率(%)
)

# 初始化仪表板
init_performance_dashboard() {
    smart_echo "初始化性能监控仪表板..." "processing"

    # 创建必要的目录结构 (只创建一级目录)
    mkdir -p "$DASHBOARD_DIR"

    # 初始化指标数据文件
    [[ ! -f "$DASHBOARD_METRICS_FILE" ]] && cat > "$DASHBOARD_METRICS_FILE" << EOF
{
  "version": "1.0",
  "created_at": "$(date -Iseconds)",
  "metrics": {
    "response_times": [],
    "token_usage": [],
    "memory_usage": [],
    "cpu_usage": [],
    "cache_performance": [],
    "compression_stats": [],
    "error_rates": []
  },
  "aggregates": {
    "total_requests": 0,
    "total_tokens_used": 0,
    "avg_response_time": 0,
    "cache_hit_rate": 0,
    "compression_ratio": 0
  }
}
EOF

    # 初始化分析文件
    [[ ! -f "$DASHBOARD_ANALYSIS_FILE" ]] && cat > "$DASHBOARD_ANALYSIS_FILE" << EOF
{
  "last_analysis": "$(date -Iseconds)",
  "performance_trends": {},
  "optimization_opportunities": [],
  "system_health": {},
  "recommendations": []
}
EOF

    smart_echo "性能监控仪表板初始化完成" "success"
}

# 🎯 实时性能监控

# 记录性能指标
record_performance_metric() {
    local operation="$1"
    local response_time="$2"
    local token_usage="$3"
    local memory_usage="${4:-$(get_memory_usage)}"
    local cpu_usage="${5:-$(get_cpu_usage)}"
    local cache_hit="${6:-false}"
    local compression_ratio="${7:-0}"

    # 创建指标记录
    local metric_record=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "operation": "$operation",
  "response_time_ms": $response_time,
  "token_usage": $token_usage,
  "memory_usage_percent": $memory_usage,
  "cpu_usage_percent": $cpu_usage,
  "cache_hit": $cache_hit,
  "compression_ratio_percent": $compression_ratio
}
EOF
)

    # 添加到指标历史
    local temp_metrics=$(mktemp)
    jq --argjson record "$metric_record" '.metrics.response_times += [$record] | .metrics.token_usage += [$record] | .metrics.memory_usage += [$record] | .metrics.cpu_usage += [$record] | .metrics.cache_performance += [$record] | .metrics.compression_stats += [$record] | .aggregates.total_requests += 1 | .aggregates.total_tokens_used += '"$token_usage" "$DASHBOARD_METRICS_FILE" > "$temp_metrics"
    mv "$temp_metrics" "$DASHBOARD_METRICS_FILE"

    # 限制历史记录数量（最近1000条）
    local temp_clean=$(mktemp)
    jq 'if .metrics.response_times | length > 1000 then .metrics.response_times = .metrics.response_times[1000:] else . end' "$DASHBOARD_METRICS_FILE" > "$temp_clean"
    mv "$temp_clean" "$DASHBOARD_METRICS_FILE"
}

# 获取实时性能统计
get_realtime_performance_stats() {
    if [[ ! -f "$DASHBOARD_METRICS_FILE" ]]; then
        echo "{}"
        return
    fi

    # 计算实时统计
    local stats=$(jq '
        .aggregates.avg_response_time = (if (.metrics.response_times | length) > 0 then (.metrics.response_times | map(.response_time_ms) | add / length) else 0 end) |
        .aggregates.cache_hit_rate = (if (.metrics.cache_performance | length) > 0 then ((.metrics.cache_performance | map(select(.cache_hit == true) | 1) | add // 0) / (.metrics.cache_performance | length) * 100) else 0 end) |
        .aggregates.compression_ratio = (if (.metrics.compression_stats | length) > 0 then (.metrics.compression_stats | map(.compression_ratio_percent) | add / length) else 0 end) |
        .aggregates.avg_memory_usage = (if (.metrics.memory_usage | length) > 0 then (.metrics.memory_usage | map(.memory_usage_percent) | add / length) else 0 end) |
        .aggregates.avg_cpu_usage = (if (.metrics.cpu_usage | length) > 0 then (.metrics.cpu_usage | map(.cpu_usage_percent) | add / length) else 0 end)
    ' "$DASHBOARD_METRICS_FILE")

    echo "$stats"
}

# 🎯 性能分析和优化建议

# 生成性能分析报告
generate_performance_analysis() {
    smart_echo "生成性能分析报告..." "processing"

    local current_stats=$(get_realtime_performance_stats)
    local analysis_file="$DASHBOARD_ANALYSIS_FILE"
    local temp_analysis=$(mktemp)

    # 分析性能趋势
    local performance_trends=$(analyze_performance_trends "$current_stats")

    # 识别优化机会
    local optimization_opportunities=$(identify_optimization_opportunities "$current_stats")

    # 评估系统健康状况
    local system_health=$(assess_system_health "$current_stats")

    # 生成优化建议
    local recommendations=$(generate_optimization_recommendations "$optimization_opportunities" "$system_health")

    # 保存分析结果
    cat <<EOF > "$temp_analysis"
{
  "last_analysis": "$(date -Iseconds)",
  "performance_trends": $performance_trends,
  "optimization_opportunities": $optimization_opportunities,
  "system_health": $system_health,
  "recommendations": $recommendations
}
EOF

    mv "$temp_analysis" "$analysis_file"

    smart_echo "性能分析报告生成完成" "success"
    echo "$analysis_file"
}

# 分析性能趋势
analyze_performance_trends() {
    local current_stats="$1"

    # 分析响应时间趋势
    local response_time_trend=$(calculate_metric_trend ".metrics.response_times" "response_time_ms")

    # 分析Token使用趋势
    local token_usage_trend=$(calculate_metric_trend ".metrics.token_usage" "token_usage")

    # 分析缓存命中率趋势
    local cache_hit_trend=$(calculate_cache_hit_trend)

    # 分析压缩效果趋势
    local compression_trend=$(calculate_metric_trend ".metrics.compression_stats" "compression_ratio_percent")

    cat <<EOF
{
  "response_time_trend": $response_time_trend,
  "token_usage_trend": $token_usage_trend,
  "cache_hit_trend": $cache_hit_trend,
  "compression_trend": $compression_trend,
  "overall_performance_score": $(calculate_overall_performance_score "$response_time_trend" "$token_usage_trend" "$cache_hit_trend" "$compression_trend")
}
EOF
}

# 计算指标趋势
calculate_metric_trend() {
    local metric_path="$1"
    local field="$2"

    # 获取最近的数据点（最后10个）
    local recent_data=$(jq "$metric_path | .[-10:] | map(.$field)" "$DASHBOARD_METRICS_FILE" 2>/dev/null || echo "[]")

    # 计算趋势（简单线性回归斜率）
    local trend=$(calculate_trend_slope "$recent_data")

    # 判断趋势方向
    if (( $(echo "$trend > 0.1" | bc -l 2>/dev/null || echo "0") )); then
        echo '"increasing"'
    elif (( $(echo "$trend < -0.1" | bc -l 2>/dev/null || echo "0") )); then
        echo '"decreasing"'
    else
        echo '"stable"'
    fi
}

# 计算缓存命中率趋势
calculate_cache_hit_trend() {
    # 计算最近10次的缓存命中率
    local recent_cache_hits=$(jq '.metrics.cache_performance | .[-10:] | map(.cache_hit)' "$DASHBOARD_METRICS_FILE" 2>/dev/null || echo "[]")
    local hit_rate=$(echo "$recent_cache_hits" | jq 'map(select(. == true) | 1) | add / length * 100 // 0' 2>/dev/null || echo "0")

    if (( $(echo "$hit_rate > 80" | bc -l 2>/dev/null || echo "0") )); then
        echo '"excellent"'
    elif (( $(echo "$hit_rate > 60" | bc -l 2>/dev/null || echo "0") )); then
        echo '"good"'
    elif (( $(echo "$hit_rate > 40" | bc -l 2>/dev/null || echo "0") )); then
        echo '"fair"'
    else
        echo '"poor"'
    fi
}

# 计算趋势斜率（简化版）
calculate_trend_slope() {
    local data="$1"
    local length=$(echo "$data" | jq 'length' 2>/dev/null || echo "0")

    if (( length < 2 )); then
        echo "0"
        return
    fi

    # 计算简单斜率：(最后值 - 最前值) / 长度
    local first=$(echo "$data" | jq '.[0] // 0')
    local last=$(echo "$data" | jq '.[-1] // 0')

    echo "scale=3; ($last - $first) / $length" | bc 2>/dev/null || echo "0"
}

# 计算整体性能评分
calculate_overall_performance_score() {
    local response_trend="$1"
    local token_trend="$2"
    local cache_trend="$3"
    local compression_trend="$4"

    # 评分标准：excellent=4, good=3, stable=2, poor/fair=1, increasing(decreasing for bad metrics)=0
    local score=0

    # 响应时间：越稳定越好
    case "$response_trend" in
        '"stable"') ((score += 3)) ;;
        '"decreasing"') ((score += 4)) ;;
        '"increasing"') ((score += 1)) ;;
    esac

    # Token使用：越下降越好
    case "$token_trend" in
        '"decreasing"') ((score += 4)) ;;
        '"stable"') ((score += 3)) ;;
        '"increasing"') ((score += 1)) ;;
    esac

    # 缓存命中率：越高越好
    case "$cache_trend" in
        '"excellent"') ((score += 4)) ;;
        '"good"') ((score += 3)) ;;
        '"fair"') ((score += 2)) ;;
        '"poor"') ((score += 1)) ;;
    esac

    # 压缩效果：越高越好（这里用stable表示效果稳定）
    case "$compression_trend" in
        '"stable"') ((score += 3)) ;;
        '"increasing"') ((score += 4)) ;;
        '"decreasing"') ((score += 2)) ;;
    esac

    # 标准化到0-100分
    echo $(( score * 100 / 16 ))
}

# 识别优化机会
identify_optimization_opportunities() {
    local current_stats="$1"

    local opportunities="[]"

    # 检查响应时间
    local avg_response_time=$(echo "$current_stats" | jq '.aggregates.avg_response_time // 0')
    if (( $(echo "$avg_response_time > 2000" | bc -l 2>/dev/null || echo "0") )); then
        opportunities=$(echo "$opportunities" | jq '. + [{"type": "response_time", "severity": "high", "description": "平均响应时间过高，建议优化缓存策略"}]')
    fi

    # 检查Token使用量
    local avg_token_usage=$(echo "$current_stats" | jq '.aggregates.total_tokens_used / .aggregates.total_requests // 0' 2>/dev/null || echo "0")
    if (( $(echo "$avg_token_usage > 500" | bc -l 2>/dev/null || echo "0") )); then
        opportunities=$(echo "$opportunities" | jq '. + [{"type": "token_usage", "severity": "medium", "description": "平均Token使用量较高，建议启用压缩"}]')
    fi

    # 检查缓存命中率
    local cache_hit_rate=$(echo "$current_stats" | jq '.aggregates.cache_hit_rate // 0')
    if (( $(echo "$cache_hit_rate < 50" | bc -l 2>/dev/null || echo "0") )); then
        opportunities=$(echo "$opportunities" | jq '. + [{"type": "cache_performance", "severity": "medium", "description": "缓存命中率偏低，建议优化缓存键"}]')
    fi

    # 检查压缩效果
    local compression_ratio=$(echo "$current_stats" | jq '.aggregates.compression_ratio // 0')
    if (( $(echo "$compression_ratio < 15" | bc -l 2>/dev/null || echo "0") )); then
        opportunities=$(echo "$opportunities" | jq '. + [{"type": "compression", "severity": "low", "description": "压缩效果不佳，建议调整压缩策略"}]')
    fi

    echo "$opportunities"
}

# 评估系统健康状况
assess_system_health() {
    local current_stats="$1"

    local health_score=100
    local issues="[]"

    # 检查各项指标是否在阈值内
    local response_time=$(echo "$current_stats" | jq '.aggregates.avg_response_time // 0')
    if (( response_time > PERFORMANCE_THRESHOLDS[response_time_max] )); then
        ((health_score -= 20))
        issues=$(echo "$issues" | jq '. + ["响应时间过高"]')
    fi

    local memory_usage=$(echo "$current_stats" | jq '.aggregates.avg_memory_usage // 0')
    if (( $(echo "$memory_usage > ${PERFORMANCE_THRESHOLDS[memory_usage_max]}" | bc -l 2>/dev/null || echo "0") )); then
        ((health_score -= 15))
        issues=$(echo "$issues" | jq '. + ["内存使用率过高"]')
    fi

    local cpu_usage=$(echo "$current_stats" | jq '.aggregates.avg_cpu_usage // 0')
    if (( $(echo "$cpu_usage > ${PERFORMANCE_THRESHOLDS[cpu_usage_max]}" | bc -l 2>/dev/null || echo "0") )); then
        ((health_score -= 15))
        issues=$(echo "$issues" | jq '. + ["CPU使用率过高"]')
    fi

    cat <<EOF
{
  "health_score": $health_score,
  "status": "$(if (( health_score >= 80 )); then echo "healthy"; elif (( health_score >= 60 )); then echo "warning"; else echo "critical"; fi)",
  "issues": $issues,
  "last_checked": "$(date -Iseconds)"
}
EOF
}

# 生成优化建议
generate_optimization_recommendations() {
    local opportunities="$1"
    local health="$2"

    local recommendations="[]"
    local health_score=$(echo "$health" | jq -r '.health_score // 100')

    # 基于优化机会生成建议
    while IFS= read -r opportunity; do
        [[ -z "$opportunity" ]] && continue

        local opp_type=$(echo "$opportunity" | jq -r '.type // empty')
        local severity=$(echo "$opportunity" | jq -r '.severity // "low"')

        case "$opp_type" in
            "response_time")
                recommendations=$(echo "$recommendations" | jq '. + [{"priority": "'$severity'", "action": "优化缓存策略", "details": "增加缓存TTL，预加载常用上下文"}]')
                ;;
            "token_usage")
                recommendations=$(echo "$recommendations" | jq '. + [{"priority": "'$severity'", "action": "启用高级压缩", "details": "使用语义压缩和重复模式消除"}]')
                ;;
            "cache_performance")
                recommendations=$(echo "$recommendations" | jq '. + [{"priority": "'$severity'", "action": "改进缓存策略", "details": "优化缓存键算法，增加缓存容量"}]')
                ;;
            "compression")
                recommendations=$(echo "$recommendations" | jq '. + [{"priority": "'$severity'", "action": "调整压缩参数", "details": "启用更激进的压缩算法"}]')
                ;;
        esac
    done <<< "$(echo "$opportunities" | jq -c '.[] // empty' 2>/dev/null)"

    # 基于健康状况添加通用建议
    if (( health_score < 70 )); then
        recommendations=$(echo "$recommendations" | jq '. + [{"priority": "high", "action": "系统维护", "details": "立即执行系统维护，清理缓存，重启服务"}]')
    fi

    echo "$recommendations"
}

# 🎯 仪表板显示和报告

# 显示性能仪表板
show_performance_dashboard() {
    smart_echo "=== 🚀 性能监控仪表板 ===" "info"

    # 获取当前统计
    local stats=$(get_realtime_performance_stats)

    # 显示关键指标
    local total_requests=$(echo "$stats" | jq -r '.aggregates.total_requests // 0')
    local avg_response_time=$(echo "$stats" | jq -r '.aggregates.avg_response_time // 0' | xargs printf "%.1f")
    local total_tokens=$(echo "$stats" | jq -r '.aggregates.total_tokens_used // 0')
    local cache_hit_rate=$(echo "$stats" | jq -r '.aggregates.cache_hit_rate // 0' | xargs printf "%.1f")
    local compression_ratio=$(echo "$stats" | jq -r '.aggregates.compression_ratio // 0' | xargs printf "%.1f")

    smart_echo "📊 总体统计:" "info"
    smart_echo "  总请求数: $total_requests" "info"
    smart_echo "  平均响应时间: ${avg_response_time}ms" "info"
    smart_echo "  总Token使用: $total_tokens" "info"
    smart_echo "  缓存命中率: ${cache_hit_rate}%" "info"
    smart_echo "  平均压缩率: ${compression_ratio}%" "info"

    # 显示系统健康状况
    local health=$(assess_system_health "$stats")
    local health_score=$(echo "$health" | jq -r '.health_score // 100')
    local health_status=$(echo "$health" | jq -r '.status // "unknown"')

    smart_echo "🏥 系统健康: $health_status (分数: $health_score/100)" "info"

    # 显示优化建议
    local analysis_file="$DASHBOARD_ANALYSIS_FILE"
    if [[ -f "$analysis_file" ]]; then
        local recommendations=$(jq -r '.recommendations[]?.action // empty' "$analysis_file" 2>/dev/null | head -3)
        if [[ -n "$recommendations" ]]; then
            smart_echo "💡 优化建议:" "info"
            echo "$recommendations" | while read -r rec; do
                [[ -n "$rec" ]] && smart_echo "  • $rec" "info"
            done
        fi
    fi

    # 显示上下文池状态
    show_pool_status 2>/dev/null || smart_echo "上下文池状态: 未初始化" "warning"
}

# 生成性能报告
generate_performance_report() {
    local report_file="$DASHBOARD_REPORTS_DIR/performance_report_$(date +%Y%m%d_%H%M%S).json"
    local stats=$(get_realtime_performance_stats)
    local analysis=$(generate_performance_analysis)

    cat <<EOF > "$report_file"
{
  "report_generated_at": "$(date -Iseconds)",
  "period": {
    "start": "$(date -d '1 hour ago' -Iseconds 2>/dev/null || echo 'unknown')",
    "end": "$(date -Iseconds)"
  },
  "performance_stats": $stats,
  "detailed_analysis": $(cat "$analysis" 2>/dev/null || echo "{}"),
  "system_info": {
    "os": "$(uname -s)",
    "memory_total": "$(get_memory_total)",
    "cpu_cores": "$(nproc 2>/dev/null || echo 'unknown')"
  },
  "token_optimization_metrics": {
    "estimated_savings_percent": $(calculate_token_savings "$stats"),
    "compression_effectiveness": $(calculate_compression_effectiveness "$stats"),
    "cache_effectiveness": $(calculate_cache_effectiveness "$stats")
  }
}
EOF

    smart_echo "性能报告已生成: $report_file" "success"
    echo "$report_file"
}

# 计算Token节省百分比
calculate_token_savings() {
    local stats="$1"

    local total_tokens=$(echo "$stats" | jq -r '.aggregates.total_tokens_used // 0')
    local compression_ratio=$(echo "$stats" | jq -r '.aggregates.compression_ratio // 0')
    local cache_hit_rate=$(echo "$stats" | jq -r '.aggregates.cache_hit_rate // 0')

    # 估算节省：压缩节省 + 缓存节省
    local compression_savings=$(echo "scale=2; $compression_ratio * 0.01 * $total_tokens" | bc 2>/dev/null || echo "0")
    local cache_savings=$(echo "scale=2; $cache_hit_rate * 0.01 * $total_tokens * 0.8" | bc 2>/dev/null || echo "0")  # 缓存节省80%的重复请求

    local total_savings=$(echo "scale=2; $compression_savings + $cache_savings" | bc 2>/dev/null || echo "0")
    local savings_percent=$(echo "scale=2; $total_tokens > 0 && $total_savings / $total_tokens * 100 || 0" | bc 2>/dev/null || echo "0")

    echo "$savings_percent"
}

# 计算压缩效果
calculate_compression_effectiveness() {
    local stats="$1"

    local compression_ratio=$(echo "$stats" | jq -r '.aggregates.compression_ratio // 0')

    if (( $(echo "$compression_ratio > 25" | bc -l 2>/dev/null || echo "0") )); then
        echo '"excellent"'
    elif (( $(echo "$compression_ratio > 15" | bc -l 2>/dev/null || echo "0") )); then
        echo '"good"'
    elif (( $(echo "$compression_ratio > 10" | bc -l 2>/dev/null || echo "0") )); then
        echo '"fair"'
    else
        echo '"needs_improvement"'
    fi
}

# 计算缓存效果
calculate_cache_effectiveness() {
    local stats="$1"

    local cache_hit_rate=$(echo "$stats" | jq -r '.aggregates.cache_hit_rate // 0')

    if (( $(echo "$cache_hit_rate > 80" | bc -l 2>/dev/null || echo "0") )); then
        echo '"excellent"'
    elif (( $(echo "$cache_hit_rate > 60" | bc -l 2>/dev/null || echo "0") )); then
        echo '"good"'
    elif (( $(echo "$cache_hit_rate > 40" | bc -l 2>/dev/null || echo "0") )); then
        echo '"fair"'
    else
        echo '"needs_improvement"'
    fi
}

# 获取内存总量
get_memory_total() {
    if command -v free >/dev/null 2>&1; then
        free -h | grep Mem | awk '{print $2}'
    else
        echo "unknown"
    fi
}

# 🎯 自动监控和维护

# 启动自动监控
start_automatic_monitoring() {
    smart_echo "启动自动性能监控..." "processing"

    # 创建监控进程（后台运行）
    (
        while true; do
            # 每5分钟生成一次分析报告
            generate_performance_analysis >/dev/null 2>&1

            # 检查系统健康
            local stats=$(get_realtime_performance_stats)
            local health=$(assess_system_health "$stats")
            local health_score=$(echo "$health" | jq -r '.health_score // 100')

            # 如果健康分数低于60，发送警告
            if (( health_score < 60 )); then
                smart_echo "⚠️ 系统健康警告: 健康分数 $health_score/100" "warning"
            fi

            # 每小时执行一次维护
            if (( $(date +%M) == 0 )); then
                perform_pool_maintenance >/dev/null 2>&1
                smart_echo "自动维护执行完成" "info"
            fi

            sleep 300  # 5分钟间隔
        done
    ) &

    local monitor_pid=$!
    echo "$monitor_pid" > "$DASHBOARD_DIR/monitor.pid"

    smart_echo "自动监控已启动 (PID: $monitor_pid)" "success"
}

# 停止自动监控
stop_automatic_monitoring() {
    local pid_file="$DASHBOARD_DIR/monitor.pid"

    if [[ -f "$pid_file" ]]; then
        local monitor_pid=$(cat "$pid_file")
        if kill -0 "$monitor_pid" 2>/dev/null; then
            kill "$monitor_pid"
            smart_echo "自动监控已停止" "info"
        fi
        rm -f "$pid_file"
    else
        smart_echo "未找到运行中的监控进程" "warning"
    fi
}

# 导出函数
export -f init_performance_dashboard
export -f record_performance_metric
export -f get_realtime_performance_stats
export -f generate_performance_analysis
export -f show_performance_dashboard
export -f generate_performance_report
export -f start_automatic_monitoring
export -f stop_automatic_monitoring

# 初始化
init_performance_dashboard