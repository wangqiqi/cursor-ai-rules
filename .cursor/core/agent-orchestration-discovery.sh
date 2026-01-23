#!/bin/bash
# ========================================
# Cursor AI Rules - Agent发现和查询服务模块
# 提供Agent发现、查询和匹配功能
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-lifecycle.sh"

# =============================================================================
# Agent发现和查询服务模块 - 基础层
# =============================================================================

# 🎯 Agent发现和查询服务

# 发现所有可用Agent
discover_agents() {
    local filter_status="${1:-}"
    local filter_capability="${2:-}"

    smart_echo "发现Agent (状态: ${filter_status:-全部}, 能力: ${filter_capability:-全部})" "processing"

    # TODO: 迁移自原agent-orchestration-engine.sh的discover_agents函数
    local agents=()

    # 扫描Agent配置文件目录
    if [[ -d "$AGENT_CONFIG_DIR" ]]; then
        for config_file in "$AGENT_CONFIG_DIR"/ai-agent-*.json; do
            if [[ -f "$config_file" ]]; then
                local agent_id=$(basename "$config_file" | sed 's/ai-agent-\(.*\)\.json/\1/')
                if agent_matches_filter "$agent_id" "$filter_status" "$filter_capability"; then
                    agents+=("$agent_id")
                fi
            fi
        done
    fi

    smart_echo "发现 ${#agents[@]} 个Agent" "success"
    echo "${agents[@]}"
}

# 根据能力发现Agent
discover_agents_by_capability() {
    local capability="$1"
    discover_agents "" "$capability"
}

# 根据专业化发现Agent
discover_agents_by_specialization() {
    local specialization="$1"
    # TODO: 实现专业化过滤逻辑
    discover_agents
}

# 根据状态发现Agent
discover_agents_by_status() {
    local status="$1"
    discover_agents "$status" ""
}

# 获取Agent详细信息
get_agent_details() {
    local agent_id="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的get_agent_details函数
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"

    if [[ ! -f "$agent_config" ]]; then
        smart_echo "Agent配置不存在: $agent_id" "error"
        return 1
    fi

    # 读取并返回Agent配置
    cat "$agent_config"
}

# 查找最佳匹配Agent
find_best_matching_agent() {
    local task_description="$1"
    local required_capabilities="${2:-}"

    smart_echo "查找最佳匹配Agent (任务: $task_description)" "processing"

    # TODO: 迁移自原agent-orchestration-engine.sh的find_best_matching_agent函数
    local available_agents=$(discover_agents "idle")

    if [[ -z "$available_agents" ]]; then
        smart_echo "没有可用的Agent" "warning"
        return 1
    fi

    # 计算匹配度并选择最佳Agent
    local best_agent=""
    local best_score=0

    for agent_id in $available_agents; do
        local score=$(calculate_agent_match_score "$agent_id" "$task_description" "$required_capabilities")
        if (( $(echo "$score > $best_score" | bc -l 2>/dev/null || echo "0") )); then
            best_score=$score
            best_agent="$agent_id"
        fi
    done

    if [[ -n "$best_agent" ]]; then
        smart_echo "找到最佳匹配Agent: $best_agent (匹配度: $best_score)" "success"
        echo "$best_agent"
    else
        smart_echo "未找到合适的Agent" "warning"
        return 1
    fi
}

# 获取Agent健康报告
get_agent_health_report() {
    local agent_id="${1:-}"

    smart_echo "生成Agent健康报告" "processing"

    # TODO: 迁移自原agent-orchestration-engine.sh的get_agent_health_report函数

    if [[ -n "$agent_id" ]]; then
        # 单个Agent健康报告
        generate_single_agent_health_report "$agent_id"
    else
        # 所有Agent健康报告
        generate_all_agents_health_report
    fi
}

# 显示Agent发现界面
show_agent_discovery() {
    smart_echo "=== 📊 Agent发现面板 ===" "info"

    local total_agents=$(discover_agents | wc -w)
    local idle_agents=$(discover_agents_by_status "idle" | wc -w)
    local busy_agents=$(discover_agents_by_status "busy" | wc -w)

    smart_echo "Agent统计:" "info"
    smart_echo "  总数: $total_agents" "info"
    smart_echo "  空闲: $idle_agents" "info"
    smart_echo "  忙碌: $busy_agents" "info"

    # 显示Agent列表
    smart_echo "可用Agent:" "info"
    local agents=$(discover_agents)
    if [[ -n "$agents" ]]; then
        for agent_id in $agents; do
            local status=$(get_agent_status "$agent_id")
            local capabilities=$(get_agent_capabilities_summary "$agent_id")
            smart_echo "  • $agent_id [$status] - $capabilities" "info"
        done
    else
        smart_echo "  无可用Agent" "warning"
    fi
}

# =============================================================================
# 内部辅助函数
# =============================================================================

# 检查Agent是否匹配过滤条件
agent_matches_filter() {
    local agent_id="$1"
    local filter_status="$2"
    local filter_capability="$3"

    # 检查状态过滤
    if [[ -n "$filter_status" ]]; then
        local status=$(get_agent_status "$agent_id")
        if [[ "$status" != "$filter_status" ]]; then
            return 1
        fi
    fi

    # 检查能力过滤
    if [[ -n "$filter_capability" ]]; then
        if ! agent_has_capability "$agent_id" "$filter_capability"; then
            return 1
        fi
    fi

    return 0
}

# 获取Agent状态
get_agent_status() {
    local agent_id="$1"
    # TODO: 实现状态获取逻辑
    echo "idle"
}

# 计算Agent匹配度分数
calculate_agent_match_score() {
    local agent_id="$1"
    local task_description="$2"
    local required_capabilities="$3"

    # TODO: 实现匹配度计算逻辑
    # 这里应该考虑Agent的能力、当前负载、历史性能等因素
    echo "0.8"
}

# 生成单个Agent健康报告
generate_single_agent_health_report() {
    local agent_id="$1"

    cat <<EOF
Agent: $agent_id
状态: $(get_agent_status "$agent_id")
健康度: $(check_agent_health "$agent_id")
最后活动: $(get_agent_last_activity "$agent_id")
EOF
}

# 生成所有Agent健康报告
generate_all_agents_health_report() {
    local agents=$(discover_agents)

    cat <<EOF
Agent健康总览报告
生成时间: $(date -Iseconds)
总Agent数: $(echo "$agents" | wc -w)

详细报告:
EOF

    for agent_id in $agents; do
        echo "---"
        generate_single_agent_health_report "$agent_id"
    done
}

# 检查Agent是否具有特定能力
agent_has_capability() {
    local agent_id="$1"
    local capability="$2"

    # TODO: 实现能力检查逻辑
    true
}

# 获取Agent能力摘要
get_agent_capabilities_summary() {
    local agent_id="$1"

    # TODO: 实现能力摘要获取逻辑
    echo "多功能Agent"
}

# 获取Agent最后活动时间
get_agent_last_activity() {
    local agent_id="$1"

    # TODO: 实现最后活动时间获取逻辑
    echo "$(date -Iseconds)"
}

# =============================================================================
# 函数导出
# =============================================================================

export -f discover_agents
export -f discover_agents_by_capability
export -f discover_agents_by_specialization
export -f discover_agents_by_status
export -f get_agent_details
export -f find_best_matching_agent
export -f get_agent_health_report
export -f show_agent_discovery