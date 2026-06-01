#!/bin/bash
# ========================================
# Cursor AI Rules - 任务状态持久化系统模块
# 管理任务状态的存储、恢复和版本控制
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/agent-orchestration-common.sh"
source "$SCRIPT_DIR/agent-orchestration-core.sh"

# =============================================================================
# 任务状态持久化系统模块 - 支撑层
# =============================================================================

# 🎯 任务状态持久化系统

# 创建扩展任务状态
create_extended_task_state() {
    local task_id="$1"
    local task_description="$2"
    local task_type="$3"
    local priority="${4:-normal}"

    # TODO: 迁移自原agent-orchestration-engine.sh的create_extended_task_state函数

    # 生成状态ID
    local state_id="state_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"

    # 分析任务复杂度
    local complexity_analysis=$(analyze_task_complexity "$task_description" "$task_type")

    # 评估资源需求
    local resource_assessment=$(assess_task_resource_requirements "$task_description" "$task_type" "$complexity_analysis")

    # 分析依赖关系
    local dependency_analysis=$(analyze_task_dependencies "$task_description" "$task_type")
    # 确保dependency_analysis不为null
    if [[ "$dependency_analysis" == "null" ]] || [[ -z "$dependency_analysis" ]]; then
        dependency_analysis='{"dependencies": []}'
    fi

    # 创建扩展状态结构
    local extended_state=$(cat <<EOF
{
  "state_id": "$state_id",
  "task_id": "$task_id",
  "version": "2.0",
  "created_at": "$(date -Iseconds)",
  "last_modified": "$(date -Iseconds)",
  "status": "created",
  "status_history": [
    {
      "status": "created",
      "timestamp": "$(date -Iseconds)",
      "reason": "initial_creation"
    }
  ],
  "task_metadata": {
    "description": "$task_description",
    "type": "$task_type",
    "priority": "$priority",
    "estimated_effort": $(estimate_task_effort "$task_description" "$task_type"),
    "required_capabilities": $(identify_required_capabilities "$task_description" "$task_type")
  },
  "complexity_analysis": $complexity_analysis,
  "resource_assessment": $resource_assessment,
  "dependency_analysis": $dependency_analysis,
  "execution_context": {
    "assigned_agent": null,
    "start_time": null,
    "end_time": null,
    "actual_duration": null,
    "progress_percentage": 0,
    "current_step": null,
    "execution_logs": []
  },
  "quality_metrics": {
    "success_probability": $(calculate_success_probability "$complexity_analysis" "$resource_assessment"),
    "risk_level": "$(get_risk_level "$complexity_analysis" "$dependency_analysis")",
    "quality_score": 0
  },
  "persistence_flags": {
    "allow_resume": true,
    "checkpoint_enabled": $(should_enable_checkpoint "$complexity_analysis"),
    "backup_required": $(should_require_backup "$task_type" "$priority")
  },
  "relationships": {
    "parent_task": null,
    "child_tasks": [],
    "related_tasks": [],
    "predecessor_tasks": $(get_predecessor_tasks "$dependency_analysis" || echo "[]"),
    "successor_tasks": []
  },
  "monitoring_data": {
    "performance_metrics": {},
    "error_logs": [],
    "warning_logs": [],
    "info_logs": []
  }
}
EOF
)

    echo "$extended_state"
}

# 保存扩展任务状态
save_extended_task_state() {
    local task_id="$1"
    local extended_state="$2"

    # TODO: 迁移自原agent-orchestration-engine.sh的save_extended_task_state函数

    local state_dir="$AI_TASKS_DIR"
    local state_file="$state_dir/${task_id}.json"

    mkdir -p "$state_dir"
    echo "$extended_state" > "$state_file"

    smart_echo "扩展任务状态已保存: $task_id" "success"
}

# 加载扩展任务状态
load_extended_task_state() {
    local task_id="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的load_extended_task_state函数

    local state_file="$AI_TASKS_DIR/${task_id}.json"

    if [[ -f "$state_file" ]]; then
        cat "$state_file"
    else
        echo "{}"
    fi
}

# 创建任务检查点
create_task_checkpoint() {
    local task_id="$1"
    local checkpoint_name="${2:-auto}"

    # TODO: 迁移自原agent-orchestration-engine.sh的create_task_checkpoint函数

    local state_file="$AI_TASKS_DIR/${task_id}.json"
    local checkpoint_dir="$AI_TASKS_DIR/checkpoints/${task_id}"
    local checkpoint_file="$checkpoint_dir/${checkpoint_name}_$(date +%s).json"

    mkdir -p "$checkpoint_dir"

    if [[ -f "$state_file" ]]; then
        cp "$state_file" "$checkpoint_file"
        smart_echo "任务检查点已创建: $task_id ($checkpoint_name)" "success"
        echo "$checkpoint_file"
    else
        smart_echo "任务状态文件不存在，无法创建检查点: $task_id" "error"
        return 1
    fi
}

# 从检查点恢复任务
restore_task_from_checkpoint() {
    local task_id="$1"
    local checkpoint_file="$2"

    # TODO: 迁移自原agent-orchestration-engine.sh的restore_task_from_checkpoint函数

    if [[ ! -f "$checkpoint_file" ]]; then
        smart_echo "检查点文件不存在: $checkpoint_file" "error"
        return 1
    fi

    local state_file="$AI_TASKS_DIR/${task_id}.json"
    cp "$checkpoint_file" "$state_file"

    # 更新恢复记录
    local recovery_record=$(cat <<EOF
{
  "status": "restored",
  "timestamp": "$(date -Iseconds)",
  "reason": "checkpoint_restore",
  "additional_data": {
    "checkpoint_file": "$checkpoint_file"
  }
}
EOF
)

    update_task_state_with_record "$task_id" "$recovery_record"

    smart_echo "任务已从检查点恢复: $task_id" "success"
}

# 获取任务状态历史
get_task_state_history() {
    local task_id="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的get_task_state_history函数

    local state_file="$AI_TASKS_DIR/${task_id}.json"

    if [[ -f "$state_file" ]]; then
        jq '.status_history[]?' "$state_file" 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

# 验证任务状态完整性
validate_task_state() {
    local task_id="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的validate_task_state函数

    local state_file="$AI_TASKS_DIR/${task_id}.json"

    if [[ ! -f "$state_file" ]]; then
        echo "missing"
        return 1
    fi

    # 检查必需字段
    local required_fields=("state_id" "task_id" "version" "status" "task_metadata")
    for field in "${required_fields[@]}"; do
        if ! jq -e "has(\"$field\")" "$state_file" >/dev/null 2>&1; then
            echo "incomplete"
            return 1
        fi
    done

    # 检查状态转换合理性
    if ! validate_state_transitions "$state_file"; then
        echo "invalid_transitions"
        return 1
    fi

    echo "valid"
    return 0
}

# 验证状态转换
validate_state_transitions() {
    local state_file="$1"

    # TODO: 迁移自原agent-orchestration-engine.sh的validate_state_transitions函数

    # 定义有效的状态转换
    local valid_transitions=(
        "created->pending"
        "pending->assigned"
        "assigned->executing"
        "executing->completed"
        "executing->failed"
        "failed->pending"
        "completed->*"
    )

    local history=$(jq -r '.status_history[]?.status' "$state_file" 2>/dev/null)
    local prev_status=""

    while read -r current_status; do
        if [[ -n "$prev_status" ]]; then
            local transition="${prev_status}->${current_status}"
            local is_valid=false

            for valid_transition in "${valid_transitions[@]}"; do
                if [[ "$valid_transition" == "$transition" ]] || [[ "$valid_transition" == "${prev_status}->*" ]]; then
                    is_valid=true
                    break
                fi
            done

            if [[ "$is_valid" != "true" ]]; then
                smart_echo "无效的状态转换: $transition" "warning"
                return 1
            fi
        fi
        prev_status="$current_status"
    done <<< "$history"

    return 0
}

# 显示任务状态面板
show_task_state_dashboard() {
    local task_id="${1:-}"

    smart_echo "=== 📊 任务状态面板 ===" "info"

    if [[ -n "$task_id" ]]; then
        show_single_task_state "$task_id"
    else
        show_all_tasks_state_overview
    fi
}

# 显示单个任务状态
show_single_task_state() {
    local task_id="$1"

    local state_file="$AI_TASKS_DIR/${task_id}.json"

    if [[ ! -f "$state_file" ]]; then
        smart_echo "任务状态文件不存在: $task_id" "error"
        return 1
    fi

    smart_echo "任务ID: $task_id" "info"

    local status=$(jq -r '.status' "$state_file")
    local priority=$(jq -r '.task_metadata.priority' "$state_file")
    local progress=$(jq -r '.execution_context.progress_percentage' "$state_file")

    smart_echo "状态: $status | 优先级: $priority | 进度: ${progress}%" "info"

    local assigned_agent=$(jq -r '.execution_context.assigned_agent // "未分配"' "$state_file")
    smart_echo "分配Agent: $assigned_agent" "info"

    # 显示最近状态历史
    smart_echo "最近状态变更:" "info"
    jq -r '.status_history[-3:][]? | "  \(.timestamp): \(.status) (\(.reason))"' "$state_file" 2>/dev/null || echo "  无状态历史"

    # 显示质量指标
    local success_prob=$(jq -r '.quality_metrics.success_probability' "$state_file")
    smart_echo "成功概率: ${success_prob}% | 风险等级: 低" "info"
}

# 显示所有任务状态概览
show_all_tasks_state_overview() {
    local state_dir="$AI_TASKS_DIR"
    local total_tasks=0
    local status_counts='{"created": 0, "pending": 0, "assigned": 0, "executing": 0, "completed": 0, "failed": 0}'

    if [[ -d "$state_dir" ]]; then
        for state_file in "$state_dir"/*.json; do
            if [[ -f "$state_file" ]]; then
                ((total_tasks++))
                local status=$(jq -r '.status' "$state_file" 2>/dev/null || echo "unknown")
                status_counts=$(echo "$status_counts" | jq --arg status "$status" '.[$status] = (.[$status] // 0) + 1')
            fi
        done
    fi

    smart_echo "任务状态统计 (总数: $total_tasks):" "info"
    echo "$status_counts" | jq -r 'to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || echo "  无状态数据"

    # 显示活跃任务
    local active_tasks=$(find "$state_dir" -name "*.json" -exec jq -r 'select(.status == "executing" or .status == "assigned") | .task_id' {} \; 2>/dev/null)
    if [[ -n "$active_tasks" ]]; then
        smart_echo "活跃任务:" "info"
        echo "$active_tasks" | while read -r task_id; do
            echo "  • $task_id"
        done
    fi
}

# =============================================================================
# 内部辅助函数
# =============================================================================

# 计算成功概率
calculate_success_probability() {
    local complexity_analysis="$1"
    local resource_assessment="$2"

    # TODO: 迁移自原agent-orchestration-engine.sh的calculate_success_probability函数

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score // 50' 2>/dev/null || echo "50")
    local resource_cost=$(echo "$resource_assessment" | jq -r '.resource_cost // 5' 2>/dev/null || echo "5")

    # 基于复杂度得分和资源成本计算成功概率
    local base_probability=90

    # 复杂度影响 (-0.5% per complexity point above 50)
    local complexity_penalty=0
    if (( $(echo "$complexity_score > 50" | bc -l 2>/dev/null || echo "0") )); then
        complexity_penalty=$(echo "scale=2; ($complexity_score - 50) * 0.5" | bc 2>/dev/null || echo "0")
    fi

    # 资源成本影响 (-2% per cost unit above 5)
    local resource_penalty=0
    if (( resource_cost > 5 )); then
        resource_penalty=$(( (resource_cost - 5) * 2 ))
    fi

    local total_penalty=$(( complexity_penalty + resource_penalty ))
    local success_probability=$(( base_probability - total_penalty ))

    # 确保概率在0-100范围内
    if (( success_probability < 0 )); then
        success_probability=0
    elif (( success_probability > 100 )); then
        success_probability=100
    fi

    echo "$success_probability"
}

# 更新任务状态（带记录）
update_task_state_with_record() {
    local task_id="$1"
    local status_record="$2"

    # TODO: 实现带记录的任务状态更新逻辑
    smart_echo "更新任务状态记录: $task_id" "info"
}

# =============================================================================
# 函数导出
# =============================================================================

export -f create_extended_task_state
export -f save_extended_task_state
export -f load_extended_task_state
export -f create_task_checkpoint
export -f restore_task_from_checkpoint
export -f get_task_state_history
export -f validate_task_state
export -f validate_state_transitions
export -f show_task_state_dashboard
export -f show_single_task_state
export -f show_all_tasks_state_overview