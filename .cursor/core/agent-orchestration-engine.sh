#!/bin/bash

# 🎯 Cursor AI Rules - 代理编排引擎
# 实现动态多代理协作系统，支持8个核心代理的智能化任务分配和执行

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/context-pool-manager.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 代理编排配置 (合并到ai目录)
AGENT_CONFIG_DIR="$AI_DIR"
AGENT_COMMUNICATION_LOG="$AGENT_CONFIG_DIR/ai-agent-communication.log"
AGENT_PERFORMANCE_METRICS="$AGENT_CONFIG_DIR/ai-agent-performance.json"

# 8个核心代理定义
declare -A AGENT_ARCHITECTURE=(
    ["planner"]="规划师 - 需求分析、任务规划、优先级排序"
    ["generator"]="生成器 - 代码生成、文档创建、模板填充"
    ["tester"]="测试师 - 测试编写、测试执行、覆盖率分析"
    ["deployer"]="部署师 - 环境配置、部署执行、监控设置"
    ["reviewer"]="审查者 - 代码审查、质量检查、安全审计"
    ["coordinator"]="协调者 - 任务分配、冲突解决、进度跟踪"
    ["learner"]="学习者 - 模式学习、性能优化、改进建议"
    ["monitor"]="监控者 - 健康检查、性能监控、告警处理"
)

# 代理状态定义
declare -A AGENT_STATES=(
    ["idle"]="空闲 - 等待任务分配"
    ["busy"]="忙碌 - 正在执行任务"
    ["error"]="错误 - 任务执行失败"
    ["maintenance"]="维护 - 系统维护中"
)

# 任务状态定义
declare -A TASK_STATES=(
    ["pending"]="等待中 - 等待分配"
    ["assigned"]="已分配 - 分配给代理"
    ["executing"]="执行中 - 正在执行"
    ["completed"]="已完成 - 执行成功"
    ["failed"]="失败 - 执行失败"
    ["cancelled"]="取消 - 任务取消"
)

# 初始化代理编排引擎
init_agent_orchestration_engine() {
    smart_echo "初始化代理编排引擎..." "processing"

    # 创建代理目录结构 (只创建一级目录)
    mkdir -p "$AGENT_CONFIG_DIR"

    # 初始化代理配置文件
    init_agent_configs

    # 初始化任务队列
    init_task_queue

    # 初始化通信系统
    init_agent_communication

    # 初始化性能监控
    init_agent_performance_monitoring

    smart_echo "代理编排引擎初始化完成" "success"
}

# 初始化代理配置
init_agent_configs() {
    smart_echo "初始化代理配置..." "info"

    for agent_id in "${!AGENT_ARCHITECTURE[@]}"; do
        agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"

        if [[ ! -f "$agent_config" ]]; then
            cat > "$agent_config" <<EOF
{
  "agent_id": "$agent_id",
  "name": "${AGENT_ARCHITECTURE[$agent_id]%% - *}",
  "description": "${AGENT_ARCHITECTURE[$agent_id]#* - }",
  "status": "idle",
  "capabilities": $(get_agent_capabilities "$agent_id"),
  "performance_metrics": {
    "tasks_completed": 0,
    "tasks_failed": 0,
    "average_execution_time": 0,
    "success_rate": 100.0,
    "last_active": null
  },
  "specializations": $(get_agent_specializations "$agent_id"),
  "resource_requirements": $(get_agent_resource_requirements "$agent_id"),
  "communication_channels": $(get_agent_communication_channels "$agent_id")
}
EOF
        fi
    done
}

# 获取代理能力
get_agent_capabilities() {
    local agent_id="$1"

    case "$agent_id" in
        "planner")
            echo '["task_planning", "requirement_analysis", "priority_assessment", "dependency_mapping"]'
            ;;
        "generator")
            echo '["code_generation", "documentation_creation", "template_processing", "content_synthesis"]'
            ;;
        "tester")
            echo '["test_creation", "test_execution", "coverage_analysis", "quality_assessment"]'
            ;;
        "deployer")
            echo '["environment_setup", "deployment_execution", "monitoring_configuration", "rollback_management"]'
            ;;
        "reviewer")
            echo '["code_review", "security_audit", "performance_analysis", "quality_gates"]'
            ;;
        "coordinator")
            echo '["task_coordination", "conflict_resolution", "progress_tracking", "resource_allocation"]'
            ;;
        "learner")
            echo '["pattern_learning", "performance_optimization", "improvement_recommendations", "knowledge_accumulation"]'
            ;;
        "monitor")
            echo '["health_monitoring", "performance_tracking", "alert_generation", "system_diagnostics"]'
            ;;
        *)
            echo '[]'
            ;;
    esac
}

# 获取代理专业领域
get_agent_specializations() {
    local agent_id="$1"

    case "$agent_id" in
        "planner")
            echo '["project_management", "requirement_engineering", "agile_methodology"]'
            ;;
        "generator")
            echo '["code_generation", "documentation", "automation", "content_creation"]'
            ;;
        "tester")
            echo '["software_testing", "quality_assurance", "test_automation", "coverage_analysis"]'
            ;;
        "deployer")
            echo '["devops", "infrastructure", "deployment", "monitoring"]'
            ;;
        "reviewer")
            echo '["code_quality", "security", "performance", "maintainability"]'
            ;;
        "coordinator")
            echo '["project_coordination", "team_management", "conflict_resolution", "stakeholder_management"]'
            ;;
        "learner")
            echo '["machine_learning", "data_analysis", "pattern_recognition", "continuous_improvement"]'
            ;;
        "monitor")
            echo '["system_monitoring", "performance_analysis", "alert_management", "diagnostic_tools"]'
            ;;
        *)
            echo '[]'
            ;;
    esac
}

# 获取代理资源需求
get_agent_resource_requirements() {
    local agent_id="$1"

    case "$agent_id" in
        "planner")
            echo '{"cpu": "low", "memory": "medium", "io": "low", "network": "medium"}'
            ;;
        "generator")
            echo '{"cpu": "high", "memory": "high", "io": "medium", "network": "high"}'
            ;;
        "tester")
            echo '{"cpu": "medium", "memory": "medium", "io": "high", "network": "low"}'
            ;;
        "deployer")
            echo '{"cpu": "medium", "memory": "medium", "io": "medium", "network": "high"}'
            ;;
        "reviewer")
            echo '{"cpu": "medium", "memory": "high", "io": "medium", "network": "low"}'
            ;;
        "coordinator")
            echo '{"cpu": "low", "memory": "low", "io": "low", "network": "medium"}'
            ;;
        "learner")
            echo '{"cpu": "high", "memory": "high", "io": "high", "network": "medium"}'
            ;;
        "monitor")
            echo '{"cpu": "low", "memory": "low", "io": "low", "network": "low"}'
            ;;
        *)
            echo '{"cpu": "low", "memory": "low", "io": "low", "network": "low"}'
            ;;
    esac
}

# 获取代理通信渠道
get_agent_communication_channels() {
    local agent_id="$1"

    case "$agent_id" in
        "coordinator")
            echo '["broadcast", "direct", "task_queue", "status_updates"]'
            ;;
        *)
            echo '["direct", "task_results", "status_updates"]'
            ;;
    esac
}

# 初始化任务队列
init_task_queue() {
    smart_echo "初始化任务队列..." "info"

    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"

    if [[ ! -f "$task_queue_file" ]]; then
        cat > "$task_queue_file" <<EOF
{
  "version": "1.0",
  "created_at": "$(date -Iseconds)",
  "queue": [],
  "active_tasks": {},
  "completed_tasks": [],
  "failed_tasks": [],
  "statistics": {
    "total_tasks": 0,
    "completed_tasks": 0,
    "failed_tasks": 0,
    "average_completion_time": 0
  }
}
EOF
    fi
}

# 初始化代理通信系统
init_agent_communication() {
    smart_echo "初始化代理通信系统..." "info"

    # 初始化通信日志
    if [[ ! -f "$AGENT_COMMUNICATION_LOG" ]]; then
        echo "=== 代理通信日志 ===" > "$AGENT_COMMUNICATION_LOG"
        echo "初始化时间: $(date -Iseconds)" >> "$AGENT_COMMUNICATION_LOG"
        echo "===================" >> "$AGENT_COMMUNICATION_LOG"
    fi

    # 初始化通信频道
    communication_channels="$AGENT_CONFIG_DIR/communication_channels.json"
    if [[ ! -f "$communication_channels" ]]; then
        cat > "$communication_channels" <<EOF
{
  "channels": {
    "task_assignment": {"type": "queue", "subscribers": []},
    "status_updates": {"type": "broadcast", "subscribers": []},
    "conflict_resolution": {"type": "direct", "subscribers": []},
    "performance_alerts": {"type": "broadcast", "subscribers": []}
  },
  "message_history": [],
  "active_conversations": {}
}
EOF
    fi
}

# 初始化性能监控
init_agent_performance_monitoring() {
    smart_echo "初始化代理性能监控..." "info"

    if [[ ! -f "$AGENT_PERFORMANCE_METRICS" ]]; then
        cat > "$AGENT_PERFORMANCE_METRICS" <<EOF
{
  "monitoring_start": "$(date -Iseconds)",
  "agent_metrics": {},
  "system_metrics": {
    "total_tasks_processed": 0,
    "average_task_completion_time": 0,
    "system_efficiency": 100.0,
    "conflict_resolution_rate": 0
  },
  "performance_trends": [],
  "alerts": [],
  "recommendations": []
}
EOF
    fi
}

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
  "dependencies": [],
  "estimated_effort": $(estimate_task_effort "$task_description" "$task_type"),
  "required_capabilities": $(identify_required_capabilities "$task_description" "$task_type")
}
EOF
)

    # 添加到任务队列
    add_task_to_queue "$task_object"

    # 触发任务分配
    trigger_task_assignment

    echo "$task_id"
}

# 添加任务到队列
add_task_to_queue() {
    local task_object="$1"

    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"

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
    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    jq '.queue | map(select(.status == "pending"))' "$task_queue_file"
}

# 选择最优代理
select_optimal_agent() {
    local task_description="$1"
    local task_type="$2"
    local required_capabilities="$3"

    smart_echo "选择最优代理执行任务..." "info"

    local best_agent=""
    local best_score=0

    # 遍历所有代理，计算匹配度
    for agent_config in "$AGENT_CONFIG_DIR/agents"/*.json; do
        if [[ -f "$agent_config" ]]; then
            local agent_id=$(basename "$agent_config" .json)
            local agent_status=$(jq -r '.status' "$agent_config")

            # 只考虑空闲的代理
            if [[ "$agent_status" == "idle" ]]; then
                local match_score=$(calculate_agent_task_match "$agent_id" "$task_description" "$task_type" "$required_capabilities")

                if (( $(echo "$match_score > $best_score" | bc -l 2>/dev/null || echo "0") )); then
                    best_agent="$agent_id"
                    best_score="$match_score"
                fi
            fi
        fi
    done

    echo "$best_agent"
}

# 计算代理与任务的匹配度
calculate_agent_task_match() {
    local agent_id="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"

    # 能力匹配度 (权重: 40%)
    local capability_match=$(calculate_capability_match "$agent_config" "$required_capabilities")

    # 专业领域匹配度 (权重: 30%)
    local specialization_match=$(calculate_specialization_match "$agent_config" "$task_type")

    # 性能历史匹配度 (权重: 20%)
    local performance_match=$(calculate_performance_match "$agent_config")

    # 当前负载匹配度 (权重: 10%)
    local load_match=$(calculate_load_match "$agent_id")

    # 计算综合匹配度
    local total_match=$(echo "scale=2; $capability_match * 0.4 + $specialization_match * 0.3 + $performance_match * 0.2 + $load_match * 0.1" | bc 2>/dev/null || echo "0")

    echo "$total_match"
}

# 计算能力匹配度
calculate_capability_match() {
    local agent_config="$1"
    local required_capabilities="$2"

    # 解析所需能力
    local required_list=$(echo "$required_capabilities" | jq -r '.[]' 2>/dev/null || echo "")

    # 获取代理能力
    local agent_capabilities=$(jq -r '.capabilities[]' "$agent_config" 2>/dev/null || echo "")

    local match_count=0
    local total_required=0

    # 计算匹配的百分比
    if [[ -n "$required_list" ]]; then
        total_required=$(echo "$required_list" | wc -l)
        for req_cap in $required_list; do
            if echo "$agent_capabilities" | grep -q "$req_cap"; then
                ((match_count++))
            fi
        done
    fi

    if (( total_required > 0 )); then
        echo "scale=2; $match_count * 100 / $total_required" | bc 2>/dev/null || echo "0"
    else
        echo "50"  # 如果没有明确的能力要求，给个中等分数
    fi
}

# 计算专业领域匹配度
calculate_specialization_match() {
    local agent_config="$1"
    local task_type="$2"

    # 定义任务类型到专业领域的映射
    local type_to_specialization=(
        ["planning"]="project_management"
        ["coding"]="code_generation"
        ["testing"]="software_testing"
        ["deployment"]="devops"
        ["review"]="code_quality"
        ["coordination"]="project_coordination"
        ["learning"]="machine_learning"
        ["monitoring"]="system_monitoring"
    )

    local target_specialization="${type_to_specialization[$task_type]}"

    if [[ -n "$target_specialization" ]]; then
        # 检查代理是否具有目标专业领域
        if jq -r ".specializations[]? // empty" "$agent_config" | grep -q "$target_specialization"; then
            echo "100"
        else
            echo "30"  # 基础匹配度
        fi
    else
        echo "50"  # 默认中等匹配度
    fi
}

# 计算性能匹配度
calculate_performance_match() {
    local agent_config="$1"

    # 获取代理的成功率
    local success_rate=$(jq -r '.performance_metrics.success_rate // 100' "$agent_config")

    echo "$success_rate"
}

# 计算负载匹配度
calculate_load_match() {
    local agent_id="$1"

    # 检查代理当前是否有任务在执行
    local active_tasks=$(jq '.active_tasks | keys | length' "$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json" 2>/dev/null || echo "0")

    # 如果代理当前有任务在执行，降低优先级
    if (( active_tasks > 0 )); then
        echo "70"
    else
        echo "100"
    fi
}

# 分配任务给代理
assign_task_to_agent() {
    local task_id="$1"
    local agent_id="$2"

    smart_echo "分配任务 $task_id 给代理 $agent_id" "info"

    # 更新任务状态
    update_task_status "$task_id" "assigned" "$agent_id"

    # 更新代理状态
    update_agent_status "$agent_id" "busy"

    # 记录分配信息
    log_agent_communication "TASK_ASSIGNMENT" "coordinator" "$agent_id" "任务 $task_id 已分配"

    # 异步执行任务
    execute_agent_task "$task_id" "$agent_id" &
}

# 更新任务状态
update_task_status() {
    local task_id="$1"
    local new_status="$2"
    local assigned_agent="${3:-}"

    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    temp_file=$(mktemp)

    jq --arg task_id "$task_id" --arg status "$new_status" --arg agent "$assigned_agent" '
        if $agent != "" then
            local current_time="$(date -Iseconds)"
            .queue = (.queue | map(if .task_id == $task_id then .status = $status | .assigned_agent = $agent | .assigned_at = $current_time else . end))
        else
            .queue = (.queue | map(if .task_id == $task_id then .status = $status else . end))
        end
    ' "$task_queue_file" > "$temp_file"

    mv "$temp_file" "$task_queue_file"
}

# 更新代理状态
update_agent_status() {
    local agent_id="$1"
    local new_status="$2"

    agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    temp_config=$(mktemp)

    jq --arg status "$new_status" --arg timestamp "$(date -Iseconds)" '.status = $status | .last_active = $timestamp' "$agent_config" > "$temp_config"
    mv "$temp_config" "$agent_config"
}

# 执行代理任务
execute_agent_task() {
    local task_id="$1"
    local agent_id="$2"

    smart_echo "代理 $agent_id 开始执行任务 $task_id" "processing"

    # 更新任务状态为执行中
    update_task_status "$task_id" "executing"

    # 获取任务详情
    local task_details=$(get_task_details "$task_id")
    local task_description=$(echo "$task_details" | jq -r '.description // ""')
    local task_type=$(echo "$task_details" | jq -r '.type // "general"')

    # 模拟任务执行（实际实现会调用具体的代理逻辑）
    local execution_result=$(execute_agent_specific_task "$agent_id" "$task_description" "$task_type")

    # 更新任务结果
    if [[ "$execution_result" == "success" ]]; then
        complete_task "$task_id" "$agent_id"
        smart_echo "任务 $task_id 执行成功" "success"
    else
        fail_task "$task_id" "$agent_id" "$execution_result"
        smart_echo "任务 $task_id 执行失败: $execution_result" "error"
    fi

    # 释放代理
    update_agent_status "$agent_id" "idle"
}

# 执行代理特定任务
execute_agent_specific_task() {
    local agent_id="$1"
    local task_description="$2"
    local task_type="$3"

    # 模拟执行时间
    sleep 1

    case "$agent_id" in
        "planner")
            # 规划师：分析需求，制定计划
            echo "success"
            ;;
        "generator")
            # 生成器：生成代码或文档
            echo "success"
            ;;
        "tester")
            # 测试师：执行测试
            echo "success"
            ;;
        "deployer")
            # 部署师：执行部署
            echo "success"
            ;;
        "reviewer")
            # 审查者：执行审查
            echo "success"
            ;;
        "coordinator")
            # 协调者：协调其他代理
            echo "success"
            ;;
        "learner")
            # 学习者：学习和改进
            echo "success"
            ;;
        "monitor")
            # 监控者：监控系统状态
            echo "success"
            ;;
        *)
            echo "unknown_agent"
            ;;
    esac
}

# 完成任务
complete_task() {
    local task_id="$1"
    local agent_id="$2"

    # 更新任务状态
    update_task_status "$task_id" "completed"

    # 更新代理性能指标
    update_agent_performance "$agent_id" "success"

    # 移动任务到完成列表
    move_task_to_completed "$task_id"

    # 记录通信
    log_agent_communication "TASK_COMPLETION" "$agent_id" "coordinator" "任务 $task_id 已完成"
}

# 失败任务
fail_task() {
    local task_id="$1"
    local agent_id="$2"
    local error_message="$3"

    # 更新任务状态
    update_task_status "$task_id" "failed"

    # 更新代理性能指标
    update_agent_performance "$agent_id" "failure"

    # 移动任务到失败列表
    move_task_to_failed "$task_id" "$error_message"

    # 记录通信
    log_agent_communication "TASK_FAILURE" "$agent_id" "coordinator" "任务 $task_id 失败: $error_message"
}

# 移动任务到完成列表
move_task_to_completed() {
    local task_id="$1"

    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    temp_file=$(mktemp)

    # 获取完成的任务
    local completed_task=$(jq --arg task_id "$task_id" '.queue[] | select(.task_id == $task_id)' "$task_queue_file")

    # 从队列中移除并添加到完成列表
    jq --arg task_id "$task_id" --argjson task "$completed_task" '
        .queue = (.queue | map(select(.task_id != $task_id))) |
        .completed_tasks += [$task] |
        .statistics.completed_tasks += 1
    ' "$task_queue_file" > "$temp_file"

    mv "$temp_file" "$task_queue_file"
}

# 移动任务到失败列表
move_task_to_failed() {
    local task_id="$1"
    local error_message="$2"

    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    temp_file=$(mktemp)

    # 获取失败的任务
    local failed_task=$(jq --arg task_id "$task_id" '.queue[] | select(.task_id == $task_id)' "$task_queue_file")

    # 添加错误信息
    failed_task=$(echo "$failed_task" | jq --arg error "$error_message" '.error_message = $error')

    # 从队列中移除并添加到失败列表
    jq --arg task_id "$task_id" --argjson task "$failed_task" '
        .queue = (.queue | map(select(.task_id != $task_id))) |
        .failed_tasks += [$task] |
        .statistics.failed_tasks += 1
    ' "$task_queue_file" > "$temp_file"

    mv "$temp_file" "$task_queue_file"
}

# 更新代理性能指标
update_agent_performance() {
    local agent_id="$1"
    local result="$2"

    agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    temp_config=$(mktemp)

    if [[ "$result" == "success" ]]; then
        jq '.performance_metrics.tasks_completed += 1' "$agent_config" > "$temp_config"
    else
        jq '.performance_metrics.tasks_failed += 1' "$agent_config" > "$temp_config"
    fi

    # 重新计算成功率
    jq '
        .performance_metrics.success_rate = (
            (.performance_metrics.tasks_completed * 100) /
            (.performance_metrics.tasks_completed + .performance_metrics.tasks_failed)
        ) // 100
    ' "$temp_config" > "${temp_config}.tmp"

    mv "${temp_config}.tmp" "$agent_config"
}

# 🎯 代理通信和协作

# 记录代理通信
log_agent_communication() {
    local message_type="$1"
    local from_agent="$2"
    local to_agent="$3"
    local message="$4"

    local timestamp=$(date -Iseconds)

    # 记录到通信日志
    echo "[$timestamp] $message_type: $from_agent -> $to_agent: $message" >> "$AGENT_COMMUNICATION_LOG"

    # 记录到通信频道
    communication_channels="$AGENT_CONFIG_DIR/communication_channels.json"
    temp_channels=$(mktemp)

    jq --arg timestamp "$timestamp" --arg type "$message_type" --arg from "$from_agent" --arg to "$to_agent" --arg msg "$message" '
        .message_history += [{
            "timestamp": $timestamp,
            "type": $type,
            "from": $from,
            "to": $to,
            "message": $msg
        }]
    ' "$communication_channels" > "$temp_channels"

    mv "$temp_channels" "$communication_channels"
}

# 获取任务详情
get_task_details() {
    local task_id="$1"

    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    jq --arg task_id "$task_id" '.queue[] | select(.task_id == $task_id) // (.completed_tasks[] | select(.task_id == $task_id)) // (.failed_tasks[] | select(.task_id == $task_id)) // {}' "$task_queue_file"
}

# 估算任务工作量
estimate_task_effort() {
    local task_description="$1"
    local task_type="$2"

    # 基于描述长度和类型估算工作量（1-10分）
    local description_length=${#task_description}
    local base_effort=5

    # 根据长度调整
    if (( description_length < 50 )); then
        base_effort=3
    elif (( description_length > 200 )); then
        base_effort=8
    fi

    # 根据类型调整
    case "$task_type" in
        "planning") base_effort=4 ;;
        "coding") base_effort=7 ;;
        "testing") base_effort=6 ;;
        "deployment") base_effort=5 ;;
        "review") base_effort=4 ;;
    esac

    echo "$base_effort"
}

# 识别所需能力
identify_required_capabilities() {
    local task_description="$1"
    local task_type="$2"

    # 基于任务类型和描述识别所需能力
    local capabilities="[]"

    case "$task_type" in
        "planning")
            capabilities='["task_planning", "requirement_analysis"]'
            ;;
        "coding")
            capabilities='["code_generation", "documentation_creation"]'
            ;;
        "testing")
            capabilities='["test_creation", "test_execution"]'
            ;;
        "deployment")
            capabilities='["deployment_execution", "monitoring_configuration"]'
            ;;
        "review")
            capabilities='["code_review", "quality_assessment"]'
            ;;
        *)
            # 基于描述关键词识别
            if echo "$task_description" | grep -qi "代码\|编程\|开发"; then
                capabilities='["code_generation"]'
            elif echo "$task_description" | grep -qi "测试"; then
                capabilities='["test_execution"]'
            elif echo "$task_description" | grep -qi "部署\|发布"; then
                capabilities='["deployment_execution"]'
            else
                capabilities='["general_assistance"]'
            fi
            ;;
    esac

    echo "$capabilities"
}

# 🎯 监控和报告

# 获取编排引擎状态
get_orchestration_status() {
    local status_report=$(cat <<EOF
{
  "engine_status": "active",
  "timestamp": "$(date -Iseconds)",
  "agent_status": $(get_agents_status),
  "task_queue_status": $(get_task_queue_status),
  "performance_metrics": $(get_orchestration_performance),
  "system_health": $(get_system_health)
}
EOF
)

    echo "$status_report"
}

# 获取代理状态
get_agents_status() {
    local agents_status="{"

    first=true
    for agent_config in "$AGENT_CONFIG_DIR/agents"/*.json; do
        if [[ -f "$agent_config" ]]; then
            local agent_id=$(basename "$agent_config" .json)
            local status=$(jq -r '.status' "$agent_config")

            if [[ "$first" == true ]]; then
                first=false
            else
                agents_status="${agents_status},"
            fi

            agents_status="${agents_status}\"${agent_id}\":\"${status}\""
        fi
    done

    agents_status="${agents_status}}"
    echo "$agents_status"
}

# 获取任务队列状态
get_task_queue_status() {
    task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"

    if [[ ! -f "$task_queue_file" ]]; then
        echo "{}"
        return
    fi

    jq '{
        pending_tasks: (.queue | map(select(.status == "pending")) | length),
        active_tasks: (.active_tasks | keys | length),
        completed_tasks: (.completed_tasks | length),
        failed_tasks: (.failed_tasks | length),
        total_tasks: .statistics.total_tasks
    }' "$task_queue_file"
}

# 获取编排性能指标
get_orchestration_performance() {
    if [[ ! -f "$AGENT_PERFORMANCE_METRICS" ]]; then
        echo "{}"
        return
    fi

    jq '.system_metrics' "$AGENT_PERFORMANCE_METRICS"
}

# 获取系统健康状态
get_system_health() {
    local agent_count=$(ls "$AGENT_CONFIG_DIR/agents"/*.json 2>/dev/null | wc -l)
    local idle_agents=0

    for agent_config in "$AGENT_CONFIG_DIR/agents"/*.json; do
        if [[ -f "$agent_config" ]]; then
            local status=$(jq -r '.status' "$agent_config")
            if [[ "$status" == "idle" ]]; then
                ((idle_agents++))
            fi
        fi
    done

    local health_score=$(( agent_count > 0 ? idle_agents * 100 / agent_count : 0 ))

    cat <<EOF
{
  "health_score": $health_score,
  "total_agents": $agent_count,
  "idle_agents": $idle_agents,
  "status": "$(if (( health_score >= 70 )); then echo "healthy"; elif (( health_score >= 40 )); then echo "warning"; else echo "critical"; fi)"
}
EOF
}

# 显示编排引擎状态
show_orchestration_status() {
    smart_echo "=== 🤖 代理编排引擎状态 ===" "info"

    local status=$(get_orchestration_status)

    # 显示代理状态
    smart_echo "👥 代理状态:" "info"
    echo "$status" | jq -r '.agent_status | to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || smart_echo "  无代理信息" "warning"

    # 显示任务队列状态
    smart_echo "📋 任务队列:" "info"
    local queue_status=$(echo "$status" | jq -r '.task_queue_status')
    echo "$queue_status" | jq -r 'to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || smart_echo "  无队列信息" "warning"

    # 显示系统健康
    smart_echo "🏥 系统健康:" "info"
    local health=$(echo "$status" | jq -r '.system_health')
    local health_score=$(echo "$health" | jq -r '.health_score // 0')
    local health_status=$(echo "$health" | jq -r '.status // "unknown"')
    smart_echo "  健康评分: $health_score/100 ($health_status)" "info"

    # 显示性能指标
    smart_echo "📊 性能指标:" "info"
    local metrics=$(echo "$status" | jq -r '.performance_metrics')
    echo "$metrics" | jq -r 'to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || smart_echo "  无性能数据" "warning"
}

# 导出函数
export -f init_agent_orchestration_engine
export -f submit_task
export -f get_orchestration_status
export -f show_orchestration_status

# 初始化
init_agent_orchestration_engine