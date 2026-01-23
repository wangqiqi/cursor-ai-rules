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
    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"

    if [[ ! -f "$registry_file" ]]; then
        echo "[]"
        return
    fi

    # 返回所有活跃的Agent
    jq '.agents | map(select(.status == "active"))' "$registry_file"
}

# 根据能力发现Agent
discover_agents_by_capability() {
    local capability="$1"
    local agents=$(discover_agents)

    echo "$agents" | jq --arg cap "$capability" '
        map(select(.capabilities | index($cap)))
    '
}

# 根据专业领域发现Agent
discover_agents_by_specialization() {
    local specialization="$1"
    local agents=$(discover_agents)

    echo "$agents" | jq --arg spec "$specialization" '
        map(select(.specializations | index($spec)))
    '
}

# 根据状态发现Agent
discover_agents_by_status() {
    local status="$1"
    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"

    if [[ ! -f "$registry_file" ]]; then
        echo "[]"
        return
    fi

    jq --arg status "$status" '.agents | map(select(.status == $status))' "$registry_file"
}

# 获取Agent详细信息
get_agent_details() {
    local agent_id="$1"
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"

    if [[ ! -f "$agent_config" ]]; then
        echo "{}"
        return
    fi

    cat "$agent_config"
}

# 查找最佳匹配Agent
find_best_matching_agent() {
    local capability="$1"
    local specialization="${2:-}"
    local min_performance="${3:-50}"

    local candidates=$(discover_agents_by_capability "$capability")

    if [[ -n "$specialization" ]]; then
        candidates=$(echo "$candidates" | jq --arg spec "$specialization" '
            map(select(.specializations | index($spec)))
        ')
    fi

    # 根据性能排序并返回最佳匹配
    echo "$candidates" | jq --arg min_perf "$min_performance" '
        map(select(.performance_metrics.success_rate >= ($min_perf | tonumber)))
        | sort_by(.performance_metrics.success_rate)
        | reverse
        | first // empty
    '
}

# 获取Agent健康状态报告
get_agent_health_report() {
    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"

    if [[ ! -f "$registry_file" ]]; then
        echo '{"total_agents": 0, "healthy_agents": 0, "unhealthy_agents": 0, "health_score": 0}'
        return
    fi

    local total_agents=$(jq '.agents | length' "$registry_file")
    local healthy_count=0
    local unhealthy_count=0

    # 检查每个Agent的健康状态
    local agents=$(jq -r '.agents[].id' "$registry_file")
    for agent_id in $agents; do
        if [[ "$(check_agent_health "$agent_id")" == "healthy" ]]; then
            ((healthy_count++))
        else
            ((unhealthy_count++))
        fi
    done

    local health_score=$(( total_agents > 0 ? healthy_count * 100 / total_agents : 0 ))

    cat <<EOF
{
  "total_agents": $total_agents,
  "healthy_agents": $healthy_count,
  "unhealthy_agents": $unhealthy_count,
  "health_score": $health_score,
  "timestamp": "$(date -Iseconds)"
}
EOF
}

# 显示Agent发现结果
show_agent_discovery() {
    smart_echo "=== 🔍 Agent发现服务 ===" "info"

    local agents=$(discover_agents)
    local agent_count=$(echo "$agents" | jq 'length' 2>/dev/null || echo "0")

    smart_echo "发现 $agent_count 个活跃Agent:" "info"

    if (( agent_count > 0 )); then
        echo "$agents" | jq -r '.[] | "  👤 \(.id): \(.name) - \(.description)"' 2>/dev/null || smart_echo "  解析Agent信息失败" "error"
    else
        smart_echo "  无活跃Agent" "warning"
    fi

    # 显示健康状态
    smart_echo "🏥 Agent健康状态:" "info"
    local health_report=$(get_agent_health_report)
    local total_agents=$(echo "$health_report" | jq -r '.total_agents // 0' 2>/dev/null || echo "0")
    local healthy_agents=$(echo "$health_report" | jq -r '.healthy_agents // 0' 2>/dev/null || echo "0")
    local health_score=$(echo "$health_report" | jq -r '.health_score // 0' 2>/dev/null || echo "0")
    smart_echo "  总计: $total_agents 个, 健康: $healthy_agents 个, 健康评分: $health_score%" "info"
}

# =============================================================================
# 内部辅助函数
# =============================================================================


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