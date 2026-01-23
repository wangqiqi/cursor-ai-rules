#!/bin/bash
# ========================================
# Cursor AI Rules - 动态负载调度器模块
# 负责Agent的选择、负载均衡和调度策略
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-core.sh"
source "$SCRIPT_DIR/agent-orchestration-discovery.sh"

# =============================================================================
# 动态负载调度器模块 - 核心层
# =============================================================================

# 🎯 动态负载调度器

# 选择最优Agent
select_optimal_agent() {
    local task_description="$1"
    local task_type="${2:-general}"
    local required_capabilities="${3:-}"

    smart_echo "动态负载调度器: 选择最优代理执行任务..." "processing"

    # 获取系统负载状态
    local system_load=$(get_system_load_status)

    # 获取可用代理列表
    local available_agents=$(get_available_agents)

    if [[ "$available_agents" == "[]" ]]; then
        smart_echo "警告: 没有可用的代理" "warning"
        return 1
    fi

    # 应用智能调度策略
    local selected_agent=$(apply_scheduling_strategy "$task_description" "$task_type" "$required_capabilities" "$available_agents" "$system_load")

    if [[ -n "$selected_agent" ]]; then
        smart_echo "选中代理: $selected_agent" "success"

        # 更新调度统计
        update_scheduling_stats "$selected_agent" "selected"

        echo "$selected_agent"
    else
        smart_echo "无法找到合适的代理" "error"
        echo ""
    fi
}

# 获取系统负载状态
get_system_load_status() {
    # TODO: 迁移自原agent-orchestration-engine.sh的get_system_load_status函数

    cat <<EOF
{
  "current_load": $(get_current_system_load),
  "load_level": "$(get_load_level)",
  "available_resources": $(get_available_resources),
  "timestamp": "$(date -Iseconds)"
}
EOF
}

# 应用调度策略
apply_scheduling_strategy() {
    local available_agents="$1"
    local load_status="$2"
    local task_description="$3"
    local task_type="$4"
    local required_capabilities="$5"

    # TODO: 迁移自原agent-orchestration-engine.sh的apply_scheduling_strategy函数

    # 解析负载状态
    local load_level=$(echo "$load_status" | jq -r '.load_level' 2>/dev/null || echo "medium")

    # 根据负载水平应用不同策略
    case "$load_level" in
        "low")
            apply_low_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        "medium")
            apply_medium_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        "high")
            apply_high_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        "critical")
            apply_critical_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        *)
            apply_medium_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
    esac
}

# 更新调度统计
update_scheduling_stats() {
    local agent_id="$1"
    local task_type="$2"
    local success="${3:-true}"

    # TODO: 迁移自原agent-orchestration-engine.sh的update_scheduling_stats函数

    # 更新Agent的负载因子
    update_agent_load_factor "$agent_id"

    # 记录调度历史
    log_scheduling_decision "$agent_id" "$task_type" "$success"

    smart_echo "调度统计已更新: $agent_id" "info"
}

# 获取Agent当前负载
get_agent_current_load() {
    local agent_id="$1"

    # TODO: 实现Agent负载获取逻辑
    # 这里应该返回Agent当前正在处理的任务数量、CPU使用率、内存使用率等

    cat <<EOF
{
  "active_tasks": $(get_agent_active_tasks_count "$agent_id"),
  "cpu_usage": $(get_agent_cpu_usage "$agent_id"),
  "memory_usage": $(get_agent_memory_usage "$agent_id"),
  "last_updated": "$(date -Iseconds)"
}
EOF
}

# 计算Agent负载因子
get_agent_load_factor() {
    local agent_id="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的get_agent_load_factor函数

    # 基于多种因素计算负载因子 (0.0-1.0)
    local active_tasks=$(get_agent_active_tasks_count "$agent_id")
    local cpu_usage=$(get_agent_cpu_usage "$agent_id")
    local memory_usage=$(get_agent_memory_usage "$agent_id")

    # 简单加权计算
    local load_factor=$(
        echo "scale=3; ($active_tasks * 0.4) + ($cpu_usage * 0.001) + ($memory_usage * 0.001)" | bc 2>/dev/null || echo "0.5"
    )

    # 确保在0.0-1.0范围内
    if (( $(echo "$load_factor > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        load_factor="1.0"
    fi

    echo "$load_factor"
}

# =============================================================================
# 调度策略实现
# =============================================================================

# 应用临界负载策略
apply_critical_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用临界负载调度策略" "warning"

    # 在临界负载下，只选择负载最轻的Agent
    local lightest_agent=""
    local lightest_load="999"

    for agent_id in $available_agents; do
        local load_factor=$(get_agent_load_factor "$agent_id")
        if (( $(echo "$load_factor < $lightest_load" | bc -l 2>/dev/null || echo "0") )); then
            lightest_load="$load_factor"
            lightest_agent="$agent_id"
        fi
    done

    echo "$lightest_agent"
}

# 应用高负载策略
apply_high_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用高负载调度策略" "warning"

    # 高负载下，优先考虑专业能力和当前负载
    select_best_agent_by_score "$available_agents" "$task_description" "$task_type" "$required_capabilities" "high_load"
}

# 应用中等负载策略
apply_medium_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用中等负载调度策略" "info"

    # 中等负载下，平衡考虑能力和负载
    select_best_agent_by_score "$available_agents" "$task_description" "$task_type" "$required_capabilities" "medium_load"
}

# 应用低负载策略
apply_low_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用低负载调度策略" "info"

    # 低负载下，优先考虑能力匹配度
    select_best_agent_by_score "$available_agents" "$task_description" "$task_type" "$required_capabilities" "low_load"
}

# =============================================================================
# 内部辅助函数
# =============================================================================

# 获取可用Agent列表
get_available_agents() {
    # 获取空闲状态的Agent
    discover_agents_by_status "idle"
}

# 获取当前系统负载
get_current_system_load() {
    # 获取系统负载平均值
    uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs 2>/dev/null || echo "1.0"
}

# 获取负载水平
get_load_level() {
    local load=$(get_current_system_load)

    if (( $(echo "$load >= 4.0" | bc -l 2>/dev/null || echo "0") )); then
        echo "critical"
    elif (( $(echo "$load >= 2.0" | bc -l 2>/dev/null || echo "0") )); then
        echo "high"
    elif (( $(echo "$load >= 1.0" | bc -l 2>/dev/null || echo "0") )); then
        echo "medium"
    else
        echo "low"
    fi
}

# 获取可用资源
get_available_resources() {
    cat <<EOF
{
  "cpu_cores": $(nproc 2>/dev/null || echo "4"),
  "memory_gb": $(free -g 2>/dev/null | awk 'NR==2{printf "%.1f", $4}' || echo "8.0"),
  "disk_free_gb": $(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//' || echo "100")
}
EOF
}

# 根据评分选择最佳Agent
select_best_agent_by_score() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"
    local strategy_type="$5"

    local best_agent=""
    local best_score=0

    for agent_id in $available_agents; do
        local score=$(calculate_agent_task_match "$agent_id" "$task_description" "$task_type" "$required_capabilities" "$strategy_type")

        if (( $(echo "$score > $best_score" | bc -l 2>/dev/null || echo "0") )); then
            best_score="$score"
            best_agent="$agent_id"
        fi
    done

    echo "$best_agent"
}

# 计算Agent与任务的匹配度
calculate_agent_task_match() {
    local agent_id="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"
    local strategy_type="$5"

    # TODO: 迁移自原agent-orchestration-engine.sh的calculate_agent_task_match函数

    # 这里应该考虑Agent的能力、当前负载、历史性能等因素
    # 暂时返回一个模拟分数
    echo "85"
}

# 更新Agent负载因子
update_agent_load_factor() {
    local agent_id="$1"

    # TODO: 实现负载因子更新逻辑
    smart_echo "更新Agent负载因子: $agent_id" "info"
}

# 记录调度决策
log_scheduling_decision() {
    local agent_id="$1"
    local task_type="$2"
    local success="$3"

    # TODO: 实现调度决策记录逻辑
    local log_file="$AGENT_CONFIG_DIR/scheduling-history.log"
    echo "[$(date -Iseconds)] $agent_id processed $task_type task ($success)" >> "$log_file"
}

# 获取Agent活跃任务数
get_agent_active_tasks_count() {
    local agent_id="$1"

    # TODO: 实现活跃任务数获取逻辑
    echo "1"
}

# 获取Agent CPU使用率
get_agent_cpu_usage() {
    local agent_id="$1"

    # TODO: 实现CPU使用率获取逻辑
    echo "25"
}

# 获取Agent内存使用率
get_agent_memory_usage() {
    local agent_id="$1"

    # TODO: 实现内存使用率获取逻辑
    echo "40"
}

# =============================================================================
# 函数导出
# =============================================================================

export -f select_optimal_agent
export -f get_system_load_status
export -f apply_scheduling_strategy
export -f update_scheduling_stats
export -f get_agent_current_load
export -f get_agent_load_factor