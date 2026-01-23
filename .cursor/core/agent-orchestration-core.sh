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
    local metadata="${4:-{}}"

    smart_echo "提交任务: $task_description (类型: $task_type, 优先级: $priority)" "processing"

    # TODO: 迁移自原agent-orchestration-engine.sh的submit_task函数

    # 生成任务ID
    local task_id=$(generate_task_id)

    # 创建任务对象
    local task_data=$(create_task_object "$task_id" "$task_description" "$task_type" "$priority" "$metadata")

    # 添加到任务队列
    if add_task_to_queue "$task_data"; then
        smart_echo "任务提交成功: $task_id" "success"

        # 触发任务分配
        trigger_task_assignment

        echo "$task_id"
        return 0
    else
        smart_echo "任务提交失败" "error"
        return 1
    fi
}

# 添加任务到队列
add_task_to_queue() {
    local task_data="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的add_task_to_queue函数

    # 确保任务队列目录存在
    local queue_dir="$AGENT_CONFIG_DIR/task-queue"
    mkdir -p "$queue_dir"

    # 提取任务ID
    local task_id=$(echo "$task_data" | jq -r '.id' 2>/dev/null)

    if [[ -z "$task_id" ]]; then
        smart_echo "无效的任务数据" "error"
        return 1
    fi

    # 保存任务到队列文件
    local queue_file="$queue_dir/${task_id}.json"
    echo "$task_data" > "$queue_file"

    smart_echo "任务已添加到队列: $task_id" "success"
    return 0
}

# 触发任务分配
trigger_task_assignment() {
    smart_echo "触发任务分配" "processing"

    # TODO: 迁移自原agent-orchestration-engine.sh的trigger_task_assignment函数

    # 获取待处理任务
    local pending_tasks=$(get_pending_tasks)

    if [[ -z "$pending_tasks" ]]; then
        smart_echo "没有待分配的任务" "info"
        return 0
    fi

    # 为每个任务分配Agent
    local assigned_count=0
    local failed_count=0

    while read -r task_file; do
        if assign_task_to_agent "$task_file"; then
            ((assigned_count++))
        else
            ((failed_count++))
        fi
    done <<< "$pending_tasks"

    smart_echo "任务分配完成: $assigned_count 成功, $failed_count 失败" "info"
}

# 获取待处理任务
get_pending_tasks() {
    # TODO: 迁移自原agent-orchestration-engine.sh的get_pending_tasks函数

    local queue_dir="$AGENT_CONFIG_DIR/task-queue"
    if [[ ! -d "$queue_dir" ]]; then
        echo ""
        return
    fi

    # 查找所有待处理任务文件
    find "$queue_dir" -name "*.json" -type f 2>/dev/null || echo ""
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
    local task_file="$AGENT_CONFIG_DIR/task-queue/${task_id}.json"

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

    # TODO: 实现任务状态获取逻辑
    local task_file="$AGENT_CONFIG_DIR/task-queue/${task_id}.json"

    if [[ -f "$task_file" ]]; then
        echo "queued"
    else
        # 检查是否在执行中或已完成
        local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"
        if [[ -f "$state_file" ]]; then
            jq -r '.status' "$state_file" 2>/dev/null || echo "unknown"
        else
            echo "not_found"
        fi
    fi
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

# 为任务分配Agent
assign_task_to_agent() {
    local task_file="$1"

    if [[ ! -f "$task_file" ]]; then
        return 1
    fi

    # 读取任务数据
    local task_data=$(cat "$task_file")
    local task_id=$(echo "$task_data" | jq -r '.id' 2>/dev/null)
    local task_description=$(echo "$task_data" | jq -r '.description' 2>/dev/null)

    # 查找最佳匹配Agent
    local best_agent=$(find_best_matching_agent "$task_description")

    if [[ -z "$best_agent" ]]; then
        smart_echo "未找到合适的Agent处理任务: $task_id" "warning"
        return 1
    fi

    # 发送任务分配消息
    local assignment_data=$(cat <<EOF
{
  "task_id": "$task_id",
  "task_data": $task_data,
  "assigned_at": "$(date -Iseconds)"
}
EOF
)

    if send_agent_message "$best_agent" "task_assignment" "$assignment_data"; then
        # 更新任务状态
        update_task_status "$task_id" "assigned" "assigned_to_$best_agent"

        # 从队列移除
        rm -f "$task_file"

        smart_echo "任务分配成功: $task_id -> $best_agent" "success"
        return 0
    else
        smart_echo "任务分配失败: $task_id" "error"
        return 1
    fi
}

# 处理单个任务
process_single_task() {
    local task_file="$1"

    # TODO: 实现单个任务处理逻辑
    local task_id=$(basename "$task_file" .json)
    smart_echo "处理任务: $task_id" "info"
}

# 更新任务状态
update_task_status() {
    local task_id="$1"
    local new_status="$2"
    local reason="${3:-status_change}"

    # TODO: 实现任务状态更新逻辑
    smart_echo "更新任务状态: $task_id -> $new_status" "info"
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