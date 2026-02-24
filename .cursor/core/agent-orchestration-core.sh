#!/bin/bash
# ========================================
# Cursor AI Rules - 核心代理编排功能模块
# 处理任务的提交、分发、队列管理和基本编排逻辑
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-lifecycle.sh"
source "$SCRIPT_DIR/agent-orchestration-discovery.sh"
source "$SCRIPT_DIR/agent-orchestration-communication.sh"

# =============================================================================
# 核心代理编排功能模块 - 核心层
# =============================================================================

# 🎯 核心代理编排功能

# 提交任务到编排引擎
submit_task() {
    local task_description="$1"
    local task_type="${2:-general}"
    local priority="${3:-normal}"
    local deadline="${4:-}"

    smart_echo "提交任务到编排引擎: $task_description" "info"

    # 生成任务ID
    local task_id="task_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4)"

    # 分析任务复杂度
    local complexity_analysis=$(analyze_task_complexity "$task_description" "$task_type")

    # 评估资源需求
    local resource_assessment=$(assess_task_resource_requirements "$task_description" "$task_type" "$complexity_analysis")

    # 创建任务对象
    local task_object=$(cat <<EOF
{
  "task_id": "$task_id",
  "description": "$task_description",
  "type": "$task_type",
  "priority": "$priority",
  "status": "pending",
  "created_at": "$(date -Iseconds)",
  "deadline": "$deadline",
  "assigned_agent": null,
  "progress": 0,
  "dependencies": $(analyze_task_dependencies "$task_description" "$task_type" | jq '.dependencies'),
  "complexity_analysis": $complexity_analysis,
  "resource_assessment": $resource_assessment,
  "estimated_effort": $(estimate_task_effort "$task_description" "$task_type"),
  "required_capabilities": $(identify_required_capabilities "$task_description" "$task_type")
}
EOF
)

    # 检查是否需要创建Agent树
    local needs_decomposition=$(echo "$complexity_analysis" | jq -r '.decomposition_needed')
    local agent_tree="null"

    if [[ "$needs_decomposition" == "true" ]]; then
        smart_echo "任务复杂度较高，创建Agent树进行调度" "info"
        agent_tree=$(create_agent_tree "$task_id")
        smart_echo "Agent树创建完成" "success"
    fi

    # 创建扩展任务状态
    smart_echo "正在创建扩展任务状态..." "info"
    local extended_state=$(create_extended_task_state "$task_id" "$task_description" "$task_type" "$priority")

    # 添加agent_tree信息到扩展状态
    if [[ "$agent_tree" != "null" ]] && [[ -n "$agent_tree" ]]; then
        # 提取tree_id并简化存储
        local tree_id=$(echo "$agent_tree" | jq -r '.tree_id // empty')
        if [[ -n "$tree_id" ]]; then
            extended_state=$(echo "$extended_state" | jq --arg tree_id "$tree_id" '.agent_tree = {"tree_id": $tree_id, "status": "created"}')
        fi
    fi

    # 保存扩展状态到持久化存储
    save_extended_task_state "$task_id" "$extended_state"

    # 同时添加到传统任务队列 (向后兼容)
    smart_echo "正在添加任务到队列..." "info"
    add_task_to_queue "$task_object"

    # 如果有Agent树，启动树执行；否则触发普通任务分配
    if [[ "$agent_tree" != "null" ]] && [[ -n "$agent_tree" ]]; then
        local tree_id=$(echo "$agent_tree" | jq -r '.tree_id')
        smart_echo "启动Agent树执行: $tree_id" "info"
        execute_agent_tree "$tree_id" &
    else
        smart_echo "触发普通任务分配" "info"
        trigger_task_assignment
    fi

    echo "$task_id"
}

# 添加任务到队列
add_task_to_queue() {
    local task_object="$1"

    task_queue_file="$AI_DIR/ai-agent-tasks-queue.json"

    # 更新队列
    local temp_queue=$(mktemp)
    jq --argjson task "$task_object" '.queue += [$task] | .statistics.total_tasks += 1' "$task_queue_file" > "$temp_queue"
    mv "$temp_queue" "$task_queue_file"

    smart_echo "任务已添加到队列" "success"
}

# 触发任务分配
trigger_task_assignment() {
    smart_echo "触发智能任务分配..." "processing"

    # 获取待分配的任务
    local pending_tasks=$(get_pending_tasks)

    if [[ "$pending_tasks" == "[]" ]]; then
        smart_echo "没有待分配的任务" "info"
        return
    fi

    # 为每个任务分配最适合的代理
    echo "$pending_tasks" | jq -c '.[]' | while read -r task; do
        local task_id=$(echo "$task" | jq -r '.task_id')
        local task_description=$(echo "$task" | jq -r '.description')
        local task_type=$(echo "$task" | jq -r '.type')
        local required_capabilities=$(echo "$task" | jq -r '.required_capabilities')

        # 智能代理选择
        local selected_agent=$(select_optimal_agent "$task_description" "$task_type" "$required_capabilities")

        if [[ -n "$selected_agent" ]]; then
            assign_task_to_agent "$task_id" "$selected_agent"
        else
            smart_echo "警告: 无法为任务 $task_id 找到合适的代理" "warning"
        fi
    done
}

# 获取待处理任务
get_pending_tasks() {
    task_queue_file="$AI_DIR/ai-agent-tasks-queue.json"
    jq '.queue | map(select(.status == "pending"))' "$task_queue_file"
}

# 处理任务队列
process_task_queue() {
    smart_echo "处理任务队列" "processing"

    local pending_tasks=$(get_pending_tasks)
    local processed_count=0

    while read -r task_file; do
        if [[ -f "$task_file" ]]; then
            process_single_task "$task_file"
            ((processed_count++))
        fi
    done <<< "$pending_tasks"

    smart_echo "任务队列处理完成: 处理了 $processed_count 个任务" "info"
}

# 取消任务
cancel_task() {
    local task_id="$1"
    local reason="${2:-user_cancelled}"

    smart_echo "取消任务: $task_id (原因: $reason)" "processing"

    # TODO: 实现任务取消逻辑
    local task_file="$AI_TASKS_DIR/${task_id}.json"

    if [[ -f "$task_file" ]]; then
        # 更新任务状态
        update_task_status "$task_id" "cancelled" "$reason"

        # 从队列中移除
        rm -f "$task_file"

        smart_echo "任务已取消: $task_id" "success"
        return 0
    else
        smart_echo "任务不存在: $task_id" "error"
        return 1
    fi
}

# 获取任务状态
get_task_status() {
    local task_id="$1"

    local task_details=$(get_task_details "$task_id")
    echo "$task_details" | jq -r '.status // "unknown"'
}

# =============================================================================
# 内部辅助函数
# =============================================================================

# 生成任务ID
generate_task_id() {
    echo "task_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"
}

# 创建任务对象
create_task_object() {
    local task_id="$1"
    local description="$2"
    local type="$3"
    local priority="$4"
    local metadata="$5"

    cat <<EOF
{
  "id": "$task_id",
  "description": "$description",
  "type": "$type",
  "priority": "$priority",
  "status": "pending",
  "created_at": "$(date -Iseconds)",
  "metadata": $metadata
}
EOF
}

# 为任务分配Agent (内部使用)
assign_task_to_agent() {
    local task_id="$1"
    local selected_agent="$2"

    # TODO: 实现任务分配逻辑
    smart_echo "分配任务 $task_id 给Agent $selected_agent" "info"
}


# =============================================================================
# 函数导出
# =============================================================================

export -f submit_task
export -f add_task_to_queue
export -f trigger_task_assignment
export -f get_pending_tasks
export -f process_task_queue
export -f cancel_task
export -f get_task_status