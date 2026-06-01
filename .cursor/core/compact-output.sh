#!/bin/bash
# 加载统一路径配置（兼容核心层和扩展层）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/path-config.sh" ]; then
    source "$SCRIPT_DIR/path-config.sh"
elif [ -f "$SCRIPT_DIR/../../.cursor/core/path-config.sh" ]; then
    source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"
fi


# 🎯 Cursor AI Rules - 精简输出系统
# 减少token消耗，提升响应速度

# 颜色定义（精简模式下可选禁用）
USE_COLORS=true

# 设置颜色
if [ "$USE_COLORS" = true ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# 精简输出模式控制 - 启用以节省token
COMPACT_MODE="${COMPACT_MODE:-true}"

# 智能输出函数
smart_echo() {
    local message="$1"
    local level="${2:-info}"

    if [ "$COMPACT_MODE" = true ]; then
        # 精简模式：只输出关键信息
        case "$level" in
            "error")
                echo "❌ $message" >&2
                ;;
            "success")
                echo "✅ $message"
                ;;
            "warning")
                echo "⚠️  $message" >&2
                ;;
            "info")
                # 精简模式下跳过一般信息
                ;;
            *)
                echo "$message"
                ;;
        esac
    else
        # 完整模式：保持原有输出
        case "$level" in
            "error")
                echo -e "${RED}❌ $message${NC}" >&2
                ;;
            "success")
                echo -e "${GREEN}✅ $message${NC}"
                ;;
            "warning")
                echo -e "${YELLOW}⚠️  $message${NC}" >&2
                ;;
            "info")
                echo -e "${BLUE}ℹ️  $message${NC}"
                ;;
            "processing")
                echo -e "${BLUE}🔄 $message${NC}"
                ;;
            *)
                echo "$message"
                ;;
        esac
    fi
}

# 精简的分析结果显示
show_compact_analysis() {
    local intent_json="$1"
    local env_json="$2"
    local decision_json="$3"

    if [ "$COMPACT_MODE" = true ]; then
        # 精简模式：只显示关键决策信息
        local intent_type=$(echo "$intent_json" | jq -r '.quick_intent_analysis.intent_type // .intent_analysis.intent_type // "unknown"' 2>/dev/null || echo "unknown")
        local confidence=$(echo "$intent_json" | jq -r '.quick_intent_analysis.confidence // .intent_analysis.confidence // 0' 2>/dev/null || echo "0")
        local should_execute=$(echo "$decision_json" | jq -r '.decision_making.should_execute // false' 2>/dev/null || echo "false")

        echo "🎯 $intent_type (${confidence}%) → $([ "$should_execute" = "true" ] && echo "执行" || echo "跳过")"
    else
        # 完整模式：显示详细分析
        show_detailed_analysis "$intent_json" "$env_json" "$decision_json"
    fi
}

# 详细分析结果显示（原有逻辑）
show_detailed_analysis() {
    local intent_json="$1"
    local env_json="$2"
    local decision_json="$3"

    echo ""
    echo -e "${BLUE}📊 智能分析结果:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 显示意图分析
    local intent_type=$(echo "$intent_json" | jq -r '.intent_analysis.intent_type // .quick_intent_analysis.intent_type // "unknown"')
    local confidence=$(echo "$intent_json" | jq -r '.intent_analysis.confidence // .quick_intent_analysis.confidence // 0')

    echo -e "${PURPLE}🎯 用户意图: ${NC}$intent_type (置信度: ${confidence}%)"

    # 显示环境分析
    local project_type=$(echo "$env_json" | jq -r '.environment_analysis.project_type // .quick_env_scan.project_type // "unknown"')
    echo -e "${PURPLE}🏗️  项目类型: ${NC}$project_type"

    # 显示决策结果
    local explanation=$(echo "$decision_json" | jq -r '.decision_making.explanation // "无决策结果"')
    echo -e "${PURPLE}🎯 执行策略: ${NC}$explanation"

    local execution_plan=$(echo "$decision_json" | jq -r '.decision_making.execution_plan[]' 2>/dev/null | tr '\n' ' ')
    if [ -n "$execution_plan" ]; then
        echo -e "${PURPLE}⚡ 执行计划: ${NC}$execution_plan"
    fi

    echo ""
}

# 精简的执行状态显示
show_compact_execution() {
    local action="$1"

    if [ "$COMPACT_MODE" = true ]; then
        echo -n "→ $action "
    else
        echo -e "${YELLOW}🚀 执行动作: ${CYAN}$action${NC}"
    fi
}

# 精简的成功状态显示
show_compact_success() {
    local message="$1"

    if [ "$COMPACT_MODE" = true ]; then
        echo "✓"
    else
        smart_echo "$message" "success"
    fi
}

# 批量操作状态显示
show_batch_progress() {
    local current="$1"
    local total="$2"
    local operation="$3"

    if [ "$COMPACT_MODE" = true ]; then
        echo -n "[$current/$total] $operation "
    else
        echo -e "${BLUE}🔄 [$current/$total] $operation${NC}"
    fi
}

# 性能指标显示
show_performance_metrics() {
    local operation="$1"
    local duration_ms="$2"
    local tokens="$3"
    local cache_hit="$4"

    if [ "$COMPACT_MODE" = true ]; then
        # 精简模式：只在性能较差时显示
        if [ "$duration_ms" -gt 2000 ] || [ "$tokens" -gt 1000 ]; then
            echo "⚠️  慢操作: ${operation} (${duration_ms}ms, ${tokens}tokens)" >&2
        fi
    else
        # 完整模式：显示详细性能指标
        local cache_indicator=""
        [ "$cache_hit" = "true" ] && cache_indicator=" 💾"

        echo -e "${BLUE}⚡ 性能: ${NC}${operation} - ${duration_ms}ms, ${tokens}tokens${cache_indicator}"
    fi
}

# 切换输出模式
toggle_compact_mode() {
    if [ "$COMPACT_MODE" = true ]; then
        COMPACT_MODE=false
        smart_echo "已切换到完整输出模式" "info"
    else
        COMPACT_MODE=true
        smart_echo "已切换到精简输出模式" "info"
    fi
}

# 自动模式选择（基于用户偏好或系统负载）
auto_select_mode() {
    # 检查用户偏好
    local user_pref_file="$CURSOR_GROWTH/user_data/user_profile.json"
    if [ -f "$user_pref_file" ]; then
        local pref=$(jq -r '.preferences.output_mode // "detailed"' "$user_pref_file" 2>/dev/null || echo "detailed")
        case "$pref" in
            "compact")
                COMPACT_MODE=true
                ;;
            "detailed")
                COMPACT_MODE=false
                ;;
        esac
    fi

    # 检查系统负载（简单的CPU检查）
    local cpu_load=$(uptime | awk -F'load average:' '{ print $2 }' | awk -F',' '{ print $1 }' | tr -d ' ')
    if (( $(echo "$cpu_load > 2.0" | bc -l 2>/dev/null || echo "0") )); then
        COMPACT_MODE=true
        smart_echo "系统负载较高，自动启用精简模式" "warning"
    fi
}

# 导出函数供其他脚本使用
export -f smart_echo
export -f show_compact_analysis
export -f show_compact_execution
export -f show_compact_success
export -f show_batch_progress
export -f show_performance_metrics
export -f toggle_compact_mode
export -f auto_select_mode
export COMPACT_MODE
export USE_COLORS