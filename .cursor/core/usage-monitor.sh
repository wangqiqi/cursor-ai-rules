#!/bin/bash
# 📊 Cursor AI Rules - 系统使用监控脚本
# 监控脚本使用情况，生成统计报告

set -e

# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
# 保存SCRIPT_DIR，避免被path-config.sh覆盖
ORIGINAL_SCRIPT_DIR="$SCRIPT_DIR"
source "$SCRIPT_DIR/path-config.sh"
SCRIPT_DIR="$ORIGINAL_SCRIPT_DIR"

# 验证项目上下文
validate_project_context || handle_error 1 "项目上下文验证失败"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
REPORT_DIR="$CURSOR_GROWTH/analytics"
USAGE_STATS_FILE="$REPORT_DIR/usage-stats-$(date +%Y%m%d).json"

log() {
    echo "[USAGE-MONITOR] $(date '+%H:%M:%S') $*" >&2
}

# 收集脚本使用统计
collect_script_stats() {
    log "收集脚本使用统计..."

    local stats="{}"

    # 脚本文件大小统计 (Linux兼容)
    local total_scripts=$(find "$SCRIPT_DIR" -name "*.sh" 2>/dev/null | wc -l)
    local total_size=$(find "$SCRIPT_DIR" -name "*.sh" -exec stat -c%s {} \; 2>/dev/null | paste -sd+ - 2>/dev/null | bc 2>/dev/null || echo "0")

    stats=$(echo "$stats" | jq ".total_scripts = $total_scripts" 2>/dev/null || echo "$stats")
    stats=$(echo "$stats" | jq ".total_size_bytes = $total_size" 2>/dev/null || echo "$stats")

    # 按大小分类统计 (Linux兼容)
    local large_scripts=$(find "$SCRIPT_DIR" -name "*.sh" -exec stat -c%s {} \; 2>/dev/null | awk '$1 > 20000 {count++} END {print count+0}' 2>/dev/null || echo "0")
    local medium_scripts=$(find "$SCRIPT_DIR" -name "*.sh" -exec stat -c%s {} \; 2>/dev/null | awk '$1 > 10000 && $1 <= 20000 {count++} END {print count+0}' 2>/dev/null || echo "0")
    local small_scripts=$(find "$SCRIPT_DIR" -name "*.sh" -exec stat -c%s {} \; 2>/dev/null | awk '$1 <= 10000 {count++} END {print count+0}' 2>/dev/null || echo "0")

    stats=$(echo "$stats" | jq ".large_scripts = $large_scripts" 2>/dev/null || echo "$stats")
    stats=$(echo "$stats" | jq ".medium_scripts = $medium_scripts" 2>/dev/null || echo "$stats")
    stats=$(echo "$stats" | jq ".small_scripts = $small_scripts" 2>/dev/null || echo "$stats")

    echo "$stats"
}

# 分析hooks触发统计
analyze_hooks_usage() {
    log "分析hooks使用情况..."

    local hooks_stats="{}"

    # 检查hooks日志
    local hooks_log_dir="$CURSOR_GROWTH/logs"
    if [ -d "$hooks_log_dir" ]; then
        local total_hook_calls=$(find "$hooks_log_dir" -name "*hook*.log" -exec wc -l {} \; 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo "0")
        hooks_stats=$(echo "$hooks_stats" | jq ".total_hook_calls = $total_hook_calls" 2>/dev/null || echo "$hooks_stats")
    else
        hooks_stats=$(echo "$hooks_stats" | jq ".total_hook_calls = 0" 2>/dev/null || echo "$hooks_stats")
    fi

    # 分析不同类型hooks的使用情况
    local after_agent_response=$(grep -r "afterAgentResponse" "$hooks_log_dir" 2>/dev/null | wc -l || echo "0")
    local pre_commit=$(grep -r "pre-commit" "$hooks_log_dir" 2>/dev/null | wc -l || echo "0")
    local post_commit=$(grep -r "post-commit" "$hooks_log_dir" 2>/dev/null | wc -l || echo "0")

    hooks_stats=$(echo "$hooks_stats" | jq ".after_agent_response = $after_agent_response" 2>/dev/null || echo "$hooks_stats")
    hooks_stats=$(echo "$hooks_stats" | jq ".pre_commit = $pre_commit" 2>/dev/null || echo "$hooks_stats")
    hooks_stats=$(echo "$hooks_stats" | jq ".post_commit = $post_commit" 2>/dev/null || echo "$hooks_stats")

    echo "$hooks_stats"
}

# 分析命令使用统计
analyze_command_usage() {
    log "分析命令使用统计..."

    local command_stats="{}"

    # 从日志中提取命令使用情况
    local cursor_master_logs=$(find "$CURSOR_GROWTH/logs" -name "*cursor-master*" -exec grep -h "intent_type" {} \; 2>/dev/null | wc -l || echo "0")

    command_stats=$(echo "$command_stats" | jq ".cursor_master_calls = $cursor_master_logs" 2>/dev/null || echo "$command_stats")

    # 分析最常用的意图类型
    if [ -d "$CURSOR_GROWTH/analytics" ]; then
        local intent_types=$(find "$CURSOR_GROWTH/analytics" -name "*.json" -exec grep -h "intent_type" {} \; 2>/dev/null | sed 's/.*"intent_type": "\([^"]*\)".*/\1/' | sort | uniq -c | sort -nr | head -5 | jq -R -s 'split("\n") | map(select(. != ""))' 2>/dev/null || echo "[]")
        command_stats=$(echo "$command_stats" | jq ".popular_intents = $intent_types" 2>/dev/null || echo "$command_stats")
    fi

    echo "$command_stats"
}

# 分析性能统计
analyze_performance_stats() {
    log "分析性能统计..."

    local perf_stats="{}"

    # 分析响应时间
    if [ -f "$CURSOR_GROWTH/analytics/performance-metrics.jsonl" ]; then
        local avg_response_time=$(tail -100 "$CURSOR_GROWTH/analytics/performance-metrics.jsonl" 2>/dev/null | jq -r '.response_time // 0' 2>/dev/null | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
        perf_stats=$(echo "$perf_stats" | jq ".avg_response_time = $avg_response_time" 2>/dev/null || echo "$perf_stats")
    fi

    # 分析Token使用情况
    if [ -f "$CURSOR_GROWTH/analytics/token-usage.jsonl" ]; then
        local total_tokens=$(tail -100 "$CURSOR_GROWTH/analytics/token-usage.jsonl" 2>/dev/null | jq -r '.tokens_used // 0' 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo "0")
        perf_stats=$(echo "$perf_stats" | jq ".total_tokens_used = $total_tokens" 2>/dev/null || echo "$perf_stats")
    fi

    echo "$perf_stats"
}

# 生成综合报告
generate_comprehensive_report() {
    local script_stats="$1"
    local hooks_stats="$2"
    local command_stats="$3"
    local perf_stats="$4"

    log "生成综合报告..."

    mkdir -p "$(dirname "$USAGE_STATS_FILE")"

    local report=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "report_type": "usage_monitoring",
  "period": "daily",
  "script_statistics": $script_stats,
  "hooks_statistics": $hooks_stats,
  "command_statistics": $command_stats,
  "performance_statistics": $perf_stats,
  "system_health": {
    "cursor_dir_exists": $([ -d "$CURSOR_DIR" ] && echo true || echo false),
    "growth_dir_exists": $([ -d "$CURSOR_GROWTH" ] && echo true || echo false),
    "logs_dir_exists": $([ -d "$CURSOR_GROWTH/logs" ] && echo true || echo false),
    "analytics_dir_exists": $([ -d "$CURSOR_GROWTH/analytics" ] && echo true || echo false)
  },
  "recommendations": $(generate_recommendations "$script_stats" "$hooks_stats" "$command_stats" "$perf_stats")
}
EOF
)

    echo "$report" > "$USAGE_STATS_FILE"
    echo -e "${GREEN}✅ 使用统计报告已生成: $USAGE_STATS_FILE${NC}" >&2

    # 同时保存为人类可读格式
    generate_human_readable_report "$report"
}

# 生成人类可读报告
generate_human_readable_report() {
    local report="$1"

    local readable_file="${USAGE_STATS_FILE%.json}.txt"

    cat > "$readable_file" << EOF
📊 Cursor AI Rules - 系统使用统计报告
=====================================

生成时间: $(date)
报告周期: 每日统计

📈 脚本统计
----------
总脚本数量: $(echo "$report" | jq -r '.script_statistics.total_scripts')
总大小: $(echo "$report" | jq -r '.script_statistics.total_size_bytes') bytes
大文件脚本(>20KB): $(echo "$report" | jq -r '.script_statistics.large_scripts')
中型脚本(10-20KB): $(echo "$report" | jq -r '.script_statistics.medium_scripts')
小文件脚本(≤10KB): $(echo "$report" | jq -r '.script_statistics.small_scripts')

🎣 Hooks统计
-----------
总调用次数: $(echo "$report" | jq -r '.hooks_statistics.total_hook_calls')
AI响应后触发: $(echo "$report" | jq -r '.hooks_statistics.after_agent_response')
提交前触发: $(echo "$report" | jq -r '.hooks_statistics.pre_commit')
提交后触发: $(echo "$report" | jq -r '.hooks_statistics.post_commit')

💬 命令统计
----------
Master控制器调用: $(echo "$report" | jq -r '.command_statistics.cursor_master_calls')

⚡ 性能统计
----------
平均响应时间: $(echo "$report" | jq -r '.performance_statistics.avg_response_time') ms
总Token使用: $(echo "$report" | jq -r '.performance_statistics.total_tokens_used')

🏥 系统健康
----------
.cursor目录: $(echo "$report" | jq -r '.system_health.cursor_dir_exists' | sed 's/true/✅ 正常/;s/false/❌ 异常/')
生长目录: $(echo "$report" | jq -r '.system_health.growth_dir_exists' | sed 's/true/✅ 正常/;s/false/❌ 异常/')
日志目录: $(echo "$report" | jq -r '.system_health.logs_dir_exists' | sed 's/true/✅ 正常/;s/false/❌ 异常/')
分析目录: $(echo "$report" | jq -r '.system_health.analytics_dir_exists' | sed 's/true/✅ 正常/;s/false/❌ 异常/')

💡 优化建议
----------
$(echo "$report" | jq -r '.recommendations[]' 2>/dev/null | sed 's/^/- /' | paste -sd'\n' - || echo "暂无建议")

📁 报告文件
----------
JSON格式: $USAGE_STATS_FILE
文本格式: $readable_file

---
*此报告由 usage-monitor.sh 自动生成*
EOF

    echo -e "${GREEN}✅ 人类可读报告已生成: $readable_file${NC}" >&2
}

# 生成优化建议
generate_recommendations() {
    local script_stats="$1"
    local hooks_stats="$2"
    local command_stats="$3"
    local perf_stats="$4"

    local recommendations=()

    # 基于脚本使用情况的建议
    local unused_scripts=$(echo "$script_stats" | jq -r '.total_scripts - (.large_scripts + .medium_scripts + .small_scripts)')
    if [ "$unused_scripts" -gt 0 ]; then
        recommendations+=("发现 $unused_scripts 个未分类脚本，建议检查是否需要清理")
    fi

    # 基于hooks使用的建议
    local hook_calls=$(echo "$hooks_stats" | jq -r '.total_hook_calls')
    if [ "$hook_calls" -eq 0 ]; then
        recommendations+=("hooks系统未被触发，建议检查Git hooks安装状态")
    fi

    # 基于性能的建议
    local avg_response=$(echo "$perf_stats" | jq -r '.avg_response_time // 0' 2>/dev/null || echo "0")
    if [ "$avg_response" != "0" ] && [ "$avg_response" != "null" ] && [ "$(echo "$avg_response > 5000" | bc 2>/dev/null || echo "0")" = "1" ]; then
        recommendations+=("平均响应时间过长 ($avg_response ms)，建议优化性能")
    fi

    # 基于命令使用的建议
    local master_calls=$(echo "$command_stats" | jq -r '.cursor_master_calls')
    if [ "$master_calls" -eq 0 ]; then
        recommendations+=("今日无Master控制器调用，建议检查系统使用情况")
    fi

    # 转换为JSON数组
    printf '%s\n' "${recommendations[@]}" | jq -R . | jq -s .
}

# 主函数
main() {
    local generate_only=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --generate-only)
                generate_only=true
                shift
                ;;
            *)
                echo -e "${RED}❌ 未知参数: $1${NC}" >&2
                echo -e "${YELLOW}使用方法: $0 [--generate-only]${NC}" >&2
                exit 1
                ;;
        esac
    done

    log "开始系统使用监控..."

    # 收集各项统计
    local script_stats=$(collect_script_stats)
    local hooks_stats=$(analyze_hooks_usage)
    local command_stats=$(analyze_command_usage)
    local perf_stats=$(analyze_performance_stats)

    # 生成报告
    generate_comprehensive_report "$script_stats" "$hooks_stats" "$command_stats" "$perf_stats"

    if [ "$generate_only" = false ]; then
        echo "" >&2
        echo -e "${BLUE}🎯 系统使用监控完成${NC}" >&2
        echo -e "${CYAN}📊 报告已保存到: $USAGE_STATS_FILE${NC}" >&2
        echo -e "${CYAN}📄 文本报告: ${USAGE_STATS_FILE%.json}.txt${NC}" >&2
    fi

    log "系统使用监控完成"
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi