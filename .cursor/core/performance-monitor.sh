#!/bin/bash

# 📊 Cursor AI Rules - 性能监控和Token统计系统
# 实时监控系统性能，优化资源使用

set -e

# 配置
MONITOR_DIR=".cursor/monitoring"
METRICS_FILE="$MONITOR_DIR/metrics.json"
TOKEN_LOG="$MONITOR_DIR/token_usage.log"
PERFORMANCE_LOG="$MONITOR_DIR/performance.log"

# 初始化监控目录
init_monitoring() {
    mkdir -p "$MONITOR_DIR"

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
    "uptime_seconds": 0,
    "last_health_check": "$(date '+%Y-%m-%d %H:%M:%S')",
    "status": "healthy"
  }
}
EOF
    fi

    touch "$TOKEN_LOG" "$PERFORMANCE_LOG"
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

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp,$operation,$response_time_ms,$memory_usage_kb,$cpu_usage_percent,$status" >> "$PERFORMANCE_LOG"
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
        *)
            echo "50"  # 默认估算
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
    if [ ! -f "$METRICS_FILE" ] || [ ! -f "$TOKEN_LOG" ] || [ ! -f "$PERFORMANCE_LOG" ]; then
        return 1
    fi

    # 计算token统计
    local total_tokens=$(awk -F',' '{sum += $3} END {print sum}' "$TOKEN_LOG" 2>/dev/null || echo "0")
    local cached_tokens=$(awk -F',' '$5=="true" {sum += $3} END {print sum}' "$TOKEN_LOG" 2>/dev/null || echo "0")
    local cache_savings=$((total_tokens - cached_tokens))

    # 计算性能统计
    local total_requests=$(wc -l < "$PERFORMANCE_LOG" 2>/dev/null || echo "0")
    local avg_response_time=$(awk -F',' '{sum += $3; count++} END {print count > 0 ? int(sum/count) : 0}' "$PERFORMANCE_LOG" 2>/dev/null || echo "0")

    # 计算缓存命中率
    local cache_hits=$(awk -F',' '$6=="cache_hit" {count++} END {print count}' "$PERFORMANCE_LOG" 2>/dev/null || echo "0")
    local cache_hit_rate=0
    if [ "$total_requests" -gt 0 ]; then
        cache_hit_rate=$((cache_hits * 100 / total_requests))
    fi

    # 计算错误率
    local errors=$(awk -F',' '$6=="error" {count++} END {print count}' "$PERFORMANCE_LOG" 2>/dev/null || echo "0")
    local error_rate=0
    if [ "$total_requests" -gt 0 ]; then
        error_rate=$((errors * 100 / total_requests))
    fi

    # 更新指标文件
    jq --arg total_tokens "$total_tokens" \
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
        .system_health.last_health_check = $current_time' "$METRICS_FILE" > "${METRICS_FILE}.tmp" && mv "${METRICS_FILE}.tmp" "$METRICS_FILE"
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
    if [ ! -d ".cursor/cache" ]; then
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
    find "$MONITOR_DIR" -name "*.log" -mtime +$days_to_keep -delete 2>/dev/null || true

    echo "🧹 已清理 $days_to_keep 天前的监控数据"
}

# 导出函数
export -f log_token_usage
export -f log_performance_metric
export -f estimate_tokens
export -f get_memory_usage
export -f get_cpu_usage
export -f update_metrics
export -f show_performance_report
export -f health_check
export -f cleanup_old_data

# 初始化
init_monitoring