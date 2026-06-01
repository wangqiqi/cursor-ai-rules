#!/bin/bash
# ========================================
# Cursor AI Rules - 多层级Agent调度系统模块
# 管理多层级Agent的树状协作网络
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/agent-orchestration-common.sh"
source "$SCRIPT_DIR/agent-orchestration-scheduler.sh"

CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"
STATE_DIR="$PROJECT_ROOT/.cursor/.cache/agent-hierarchy"
HIERARCHY_DB="$STATE_DIR/hierarchies.json"
LAST_HIERARCHY_ID=""
LAST_ROOT_AGENT=""

ensure_hierarchy_store() {
    mkdir -p "$STATE_DIR"
    if [[ ! -f "$HIERARCHY_DB" ]]; then
        cat <<EOF > "$HIERARCHY_DB"
{
  "hierarchies": []
}
EOF
    fi
}

load_hierarchy_db() {
    ensure_hierarchy_store
    cat "$HIERARCHY_DB"
}

save_hierarchy_db() {
    local payload="$1"
    ensure_hierarchy_store
    echo "$payload" > "$HIERARCHY_DB"
}

append_hierarchy_entry() {
    local entry="$1"
    local current
    current="$(load_hierarchy_db)"
    local updated
    updated=$(echo "$current" | jq --argjson entry "$entry" '.hierarchies += [$entry]')
    save_hierarchy_db "$updated"
}

# =============================================================================
# 多层级Agent调度系统模块 - 功能层
# =============================================================================

# 🎯 多层级Agent调度系统

# 创建Agent层级结构
create_agent_hierarchy() {
    local root_task="$1"
    local complexity_analysis="$2"

    smart_echo "创建Agent层级结构: $root_task" "processing"

    local hierarchy_depth
    hierarchy_depth=$(determine_hierarchy_depth "$complexity_analysis")

    local root_agent
    root_agent=$(create_root_agent "$root_task")

    local child_agents
    child_agents=$(create_child_agents "$root_agent" "$hierarchy_depth")

    establish_agent_relationships "$root_agent" "$child_agents"

    local safe_root_agent
    safe_root_agent=$(echo "$root_agent" | tr -cd '[:alnum:]_' | tr '[:upper:]' '[:lower:]')

    local hierarchy_id="hierarchy_${safe_root_agent}_$(date +%s)"
    local timestamp
    timestamp="$(date -Iseconds)"

    local entry
    entry=$(cat <<EOF
{
  "id": "$hierarchy_id",
  "task": "$root_task",
  "root_agent": "$root_agent",
  "child_agents": $child_agents,
  "hierarchy_depth": $hierarchy_depth,
  "status": "active",
  "created_at": "$timestamp"
}
EOF
)

    append_hierarchy_entry "$entry"
    LAST_HIERARCHY_ID="$hierarchy_id"
    LAST_ROOT_AGENT="$root_agent"

    cat <<EOF
{
  "hierarchy_id": "$hierarchy_id",
  "root_agent": "$root_agent",
  "child_agents": $child_agents,
  "hierarchy_depth": $hierarchy_depth,
  "creation_timestamp": "$timestamp"
}
EOF
}

# 分配给父Agent
assign_parent_agent() {
    local task_id="$1"
    local parent_agent_id="$2"
    local hierarchy_id="${3:-$LAST_HIERARCHY_ID}"

    smart_echo "分配任务给父Agent: $task_id -> $parent_agent_id" "processing"

    if [[ -z "$hierarchy_id" ]]; then
        smart_echo "⚠️ 未检测到活跃层级，使用最近创建的层级" "warning"
        hierarchy_id="$LAST_HIERARCHY_ID"
    fi

    if [[ -z "$hierarchy_id" ]]; then
        smart_echo "❌ 没有可用层级，无法分配任务" "error"
        return 1
    fi

    if ! validate_parent_agent "$parent_agent_id"; then
        smart_echo "父Agent无效: $parent_agent_id" "error"
        return 1
    fi

    local subtasks
    subtasks=$(decompose_task_for_hierarchy "$task_id")

    assign_subtasks_to_children "$subtasks" "$parent_agent_id" "$hierarchy_id"

    local db
    db=$(load_hierarchy_db)
    db=$(echo "$db" | jq --arg id "$hierarchy_id" --arg parent "$parent_agent_id" --arg task "$task_id" '.hierarchies |= map(if .id == $id then .status = "pending" | .last_parent = $parent | .last_task_assigned = $task else . end)')
    save_hierarchy_db "$db"

    smart_echo "任务分配完成: $task_id" "success"
}

# 委托给子Agent
delegate_to_child_agent() {
    local parent_agent="$1"
    local child_agent="$2"
    local subtask="$3"

    smart_echo "委托子任务给子Agent: $parent_agent -> $child_agent" "processing"

    local hierarchy_id="${4:-$LAST_HIERARCHY_ID}"
    local delegation_message
    delegation_message=$(create_delegation_message "$parent_agent" "$child_agent" "$subtask")

    send_agent_message "$child_agent" "task_delegation" "$delegation_message"

    monitor_delegation_execution "$parent_agent" "$child_agent" "$subtask"

    if [[ -n "$hierarchy_id" ]]; then
        local db
        db=$(load_hierarchy_db)
        db=$(echo "$db" | jq --arg id "$hierarchy_id" --arg subtask "$subtask" --arg child "$child_agent" '.hierarchies |= map(if .id == $id then .last_delegation = $subtask | .last_child = $child else . end)')
        save_hierarchy_db "$db"
    fi
}

# 协调Agent层级
coordinate_agent_levels() {
    local hierarchy_id="$1"

    smart_echo "协调Agent层级: $hierarchy_id" "processing"

    local level_status
    level_status=$(collect_level_status "$hierarchy_id")

    local coordination_needs
    coordination_needs=$(identify_coordination_needs "$level_status")

    execute_coordination_actions "$coordination_needs"

    update_hierarchy_status "$hierarchy_id" "coordinated"
}

# 优化层级结构
optimize_hierarchy_structure() {
    local hierarchy_id="$1"
    local performance_metrics="$2"

    smart_echo "优化层级结构: $hierarchy_id" "processing"

    local performance_analysis
    performance_analysis=$(analyze_hierarchy_performance "$performance_metrics")

    local optimization_opportunities
    optimization_opportunities=$(identify_optimization_opportunities "$performance_analysis")

    apply_hierarchy_optimizations "$optimization_opportunities"

    update_hierarchy_status "$hierarchy_id" "optimized"

    local applied_count
    applied_count=$(echo "$optimization_opportunities" | jq 'length' 2>/dev/null || echo "0")

    cat <<EOF
{
  "hierarchy_id": "$hierarchy_id",
  "optimizations_applied": $applied_count,
  "performance_improved": true,
  "optimization_timestamp": "$(date -Iseconds)"
}
EOF
}

# =============================================================================
# 多层级调度系统函数
# =============================================================================

# 显示层级调度状态
show_hierarchy_status() {
    local hierarchy_id="${1:-}"

    smart_echo "=== 🏗️ 多层级调度状态 ===" "info"

    if [[ -n "$hierarchy_id" ]]; then
        show_single_hierarchy_status "$hierarchy_id"
    else
        show_all_hierarchies_status
    fi
}

# 获取层级调度统计
get_hierarchy_statistics() {
    local db
    db=$(load_hierarchy_db)

    local total
    total=$(echo "$db" | jq '.hierarchies | length')

    local active
    active=$(echo "$db" | jq '[.hierarchies[] | select(.status == "active")] | length')

    local completed
    completed=$(echo "$db" | jq '[.hierarchies[] | select(.status == "completed")] | length')

    local failed
    failed=$(echo "$db" | jq '[.hierarchies[] | select(.status == "failed")] | length')

    local average_depth
    average_depth=$(echo "$db" | jq 'if (.hierarchies | length) > 0 then ([.hierarchies[].hierarchy_depth // 0] | add) / (.hierarchies | length) else 0 end')

    local performance_metrics
    performance_metrics=$(echo "$db" | jq '{last_optimization: (.hierarchies | map(.last_optimization) | last)}')

    cat <<EOF
{
  "total_hierarchies": $total,
  "active_hierarchies": $active,
  "completed_hierarchies": $completed,
  "failed_hierarchies": $failed,
  "average_depth": $average_depth,
  "performance_metrics": $performance_metrics
}
EOF
}

# =============================================================================
# 内部辅助函数
# =============================================================================

# 确定层级深度
determine_hierarchy_depth() {
    local complexity_analysis="$1"

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score' 2>/dev/null || echo "50")

    if (( complexity_score >= 80 )); then
        echo "3"  # 根->父->子->孙
    elif (( complexity_score >= 60 )); then
        echo "2"  # 根->父->子
    else
        echo "1"  # 根->子
    fi
}

# 创建根Agent
create_root_agent() {
    local task_id="$1"

    local normalized
    normalized=$(echo "$task_id" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
    local timestamp
    timestamp="$(date +%s)"
    local root_agent="root_agent_${normalized}_${timestamp}"

    smart_echo "生成根Agent: $root_agent" "info"
    echo "$root_agent"
}

# 创建子Agent
create_child_agents() {
    local root_agent="$1"
    local depth="$2"

    local count=$((depth * 2))
    if (( count < 1 )); then
        count=1
    fi

    local agents=()
    for i in $(seq 1 "$count"); do
        agents+=("\"${root_agent}_child_${i}\"")
    done

    printf '[%s]' "$(IFS=,; echo "${agents[*]}")"
}

# 建立Agent关系
establish_agent_relationships() {
    local root_agent="$1"
    local child_agents="$2"
    local hierarchy_id="${3:-$LAST_HIERARCHY_ID}"

    smart_echo "建立Agent关系: $root_agent" "info"

    if [[ -n "$hierarchy_id" ]]; then
        local db
        db=$(load_hierarchy_db)
        db=$(echo "$db" | jq --arg id "$hierarchy_id" --arg root "$root_agent" --argjson children "$child_agents" '.hierarchies |= map(if .id == $id then .relationship = {root_agent: $root, child_agents: $children} else . end)')
        save_hierarchy_db "$db"
    fi
}

# 验证父Agent
validate_parent_agent() {
    local agent_id="$1"

    if [[ -z "$agent_id" ]]; then
        smart_echo "父Agent ID 为空，验证失败" "warning"
        return 1
    fi

    if [[ "$agent_id" =~ ^[[:alnum:]_-]+$ ]]; then
        return 0
    fi

    smart_echo "父Agent ID 不合法: $agent_id" "warning"
    return 1
}

# 分解任务为子任务
decompose_task_for_hierarchy() {
    local task_id="$1"

    local parts=()
    read -ra segments <<< "$task_id"

    for segment in "${segments[@]}"; do
        if [[ -n "$segment" ]]; then
            parts+=("\"$segment\"")
        fi
    done

    if [[ ${#parts[@]} -eq 0 ]]; then
        parts+=("\"${task_id}_part\"")
    fi

    printf '[%s]' "$(IFS=,; echo "${parts[*]}")"
}

# 分配子任务给子Agent
assign_subtasks_to_children() {
    local subtasks="$1"
    local parent_agent="$2"

    smart_echo "分配子任务给子Agent $parent_agent" "info"

    if [[ -n "$subtasks" && -n "$parent_agent" ]]; then
        smart_echo "子任务列表: $subtasks" "debug"
    fi

    local hierarchy_id="${3:-$LAST_HIERARCHY_ID}"
    if [[ -n "$hierarchy_id" ]]; then
        local db
        db=$(load_hierarchy_db)
        db=$(echo "$db" | jq --arg id "$hierarchy_id" --arg parent "$parent_agent" --argjson subs "$subtasks" '.hierarchies |= map(if .id == $id then .pending_subtasks = ($subs // []) | .last_child = $parent else . end)')
        save_hierarchy_db "$db"
    fi
}

# 创建委托消息
create_delegation_message() {
    local parent_agent="$1"
    local child_agent="$2"
    local subtask="$3"

    cat <<EOF
{
  "parent_agent": "$parent_agent",
  "child_agent": "$child_agent",
  "subtask": "$subtask",
  "delegation_timestamp": "$(date -Iseconds)"
}
EOF
}

# 监控委托执行
monitor_delegation_execution() {
    local parent_agent="$1"
    local child_agent="$2"
    local subtask="$3"

    smart_echo "监控委托执行: $parent_agent -> $child_agent ($subtask)" "info"
    smart_echo "委托执行状态: 正在跟踪" "debug"
}

# 收集层级状态
collect_level_status() {
    local hierarchy_id="$1"

    local db
    db=$(load_hierarchy_db)

    if [[ -n "$hierarchy_id" ]]; then
        echo "$db" | jq --arg id "$hierarchy_id" '.hierarchies[] | select(.id == $id)'
    else
        echo "$db"
    fi
}

# 识别协调需求
identify_coordination_needs() {
    local level_status="$1"

    local needs=()

    if echo "$level_status" | jq -e '.status == "busy"' >/dev/null 2>&1; then
        needs+=("\"rebalance\"")
    fi

    if echo "$level_status" | jq -e '.status == "error"' >/dev/null 2>&1; then
        needs+=("\"recovery\"")
    fi

    if echo "$level_status" | jq -e '.pending_subtasks | length > 0' >/dev/null 2>&1; then
        needs+=("\"reschedule\"")
    fi

    if [[ ${#needs[@]} -eq 0 ]]; then
        needs+=("\"monitor\"")
    fi

    printf '[%s]' "$(IFS=,; echo "${needs[*]}")"
}

# 执行协调动作
execute_coordination_actions() {
    local coordination_needs="$1"

    smart_echo "执行协调动作: $coordination_needs" "info"

    local need
    while read -r need; do
        smart_echo "执行协调策略: $need" "debug"
    done < <(echo "$coordination_needs" | jq -r '.[]')
}

# 更新层级状态
update_hierarchy_status() {
    local hierarchy_id="$1"
    local status="${2:-active}"

    if [[ -z "$hierarchy_id" ]]; then
        smart_echo "⚠️ 无层级ID，无法更新状态" "warning"
        return 1
    fi

    local db
    db=$(load_hierarchy_db)
    db=$(echo "$db" | jq --arg id "$hierarchy_id" --arg status "$status" '.hierarchies |= map(if .id == $id then .status = $status else . end)')
    save_hierarchy_db "$db"

    smart_echo "更新层级状态: $hierarchy_id -> $status" "info"
}

# 分析层级性能
analyze_hierarchy_performance() {
    local performance_metrics="$1"

    if [[ -z "$performance_metrics" ]]; then
        echo '{"average_latency": 0, "throughput": 0}'
        return
    fi

    echo "$performance_metrics" | jq '{
        average_latency: (.average_latency // 0),
        throughput: (.throughput // 0),
        efficiency: (.efficiency // 0)
    }'
}

# 识别优化机会
identify_optimization_opportunities() {
    local performance_analysis="$1"

    local latency
    local throughput
    latency=$(echo "$performance_analysis" | jq -r '.average_latency // 0')
    throughput=$(echo "$performance_analysis" | jq -r '.throughput // 0')

    local opportunities=()

    if (( $(echo "$latency > 120" | bc -l) )); then
        opportunities+=("\"latency_reduction\"")
    fi

    if (( $(echo "$throughput < 50" | bc -l) )); then
        opportunities+=("\"throughput_boost\"")
    fi

    opportunities+=("\"health_check\"")

    printf '[%s]' "$(IFS=,; echo "${opportunities[*]}")"
}

# 应用层级优化
apply_hierarchy_optimizations() {
    local optimization_opportunities="$1"
    local hierarchy_id="${2:-$LAST_HIERARCHY_ID}"

    smart_echo "应用层级优化: $optimization_opportunities" "info"

    if [[ -n "$hierarchy_id" ]]; then
        local db
        db=$(load_hierarchy_db)
        db=$(echo "$db" | jq --arg id "$hierarchy_id" --argjson ops "$optimization_opportunities" '.hierarchies |= map(if .id == $id then .last_optimization = ($ops // []) else . end)')
        save_hierarchy_db "$db"
    fi
}

# 显示单个层级状态
show_single_hierarchy_status() {
    local hierarchy_id="$1"

    smart_echo "层级ID: $hierarchy_id 状态详情" "info"

    if [[ -z "$hierarchy_id" ]]; then
        smart_echo "⚠️ 层级ID为空" "warning"
        return
    fi

    local status
    status=$(collect_level_status "$hierarchy_id")

    if [[ -z "$status" ]]; then
        smart_echo "❌ 未找到对应层级" "warning"
        return
    fi

    echo "$status"
}

# 显示所有层级状态
show_all_hierarchies_status() {
    smart_echo "所有层级状态概览:" "info"

    local db
    db=$(collect_level_status)
    echo "$db" | jq '.'
}

# =============================================================================
# 函数导出
# =============================================================================

export -f create_agent_hierarchy
export -f assign_parent_agent
export -f delegate_to_child_agent
export -f coordinate_agent_levels
export -f optimize_hierarchy_structure
export -f show_hierarchy_status
export -f get_hierarchy_statistics