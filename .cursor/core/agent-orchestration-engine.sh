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

# 代理编排配置 (使用AI目录)
AGENT_CONFIG_DIR="$AI_DIR"
AGENT_COMMUNICATION_LOG="$AGENT_CONFIG_DIR/ai-agent-communication.log"
AGENT_PERFORMANCE_METRICS="$AGENT_CONFIG_DIR/ai-agent-performance.json"

# 确保Agent配置目录存在
if [[ ! -d "$AGENT_CONFIG_DIR" ]]; then
    mkdir -p "$AGENT_CONFIG_DIR"
fi

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
    ["initializing"]="初始化中 - 系统正在启动"
    ["terminating"]="终止中 - 系统正在关闭"
    ["suspended"]="暂停 - 暂时不可用"
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

# 🎯 Agent生命周期管理

# 初始化Agent实例
initialize_agent() {
    local agent_id="$1"
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"

    smart_echo "初始化Agent: $agent_id" "processing"

    # 设置Agent状态为初始化中
    update_agent_status "$agent_id" "initializing"

    # 验证Agent配置
    if [[ ! -f "$agent_config" ]]; then
        smart_echo "Agent配置不存在: $agent_config" "error"
        update_agent_status "$agent_id" "error"
        return 1
    fi

    # 加载Agent配置
    local agent_data=$(cat "$agent_config")

    # 执行Agent特定的初始化逻辑
    if ! initialize_agent_specific "$agent_id" "$agent_data"; then
        smart_echo "Agent特定初始化失败: $agent_id" "error"
        update_agent_status "$agent_id" "error"
        return 1
    fi

    # 注册Agent到编排引擎
    register_agent "$agent_id"

    # 设置Agent为就绪状态
    update_agent_status "$agent_id" "idle"

    smart_echo "Agent初始化完成: $agent_id" "success"
    return 0
}

# Agent特定的初始化逻辑
initialize_agent_specific() {
    local agent_id="$1"
    local agent_data="$2"

    case "$agent_id" in
        "planner")
            # 规划师初始化：加载规划模板和策略
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/planner"
            echo '{"templates": [], "strategies": []}' > "$AGENT_CONFIG_DIR/agent-data/planner/config.json"
            ;;
        "generator")
            # 生成器初始化：设置代码模板和生成器
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/generator"
            echo '{"templates": {}, "generators": []}' > "$AGENT_CONFIG_DIR/agent-data/generator/config.json"
            ;;
        "tester")
            # 测试师初始化：配置测试框架和工具
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/tester"
            echo '{"frameworks": [], "tools": []}' > "$AGENT_CONFIG_DIR/agent-data/tester/config.json"
            ;;
        "deployer")
            # 部署师初始化：设置部署环境和工具
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/deployer"
            echo '{"environments": [], "tools": []}' > "$AGENT_CONFIG_DIR/agent-data/deployer/config.json"
            ;;
        "reviewer")
            # 审查者初始化：加载审查规则和检查清单
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/reviewer"
            echo '{"rules": [], "checklists": []}' > "$AGENT_CONFIG_DIR/agent-data/reviewer/config.json"
            ;;
        "coordinator")
            # 协调者初始化：设置协调策略和通信协议
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/coordinator"
            echo '{"strategies": [], "protocols": []}' > "$AGENT_CONFIG_DIR/agent-data/coordinator/config.json"
            ;;
        "learner")
            # 学习者初始化：设置学习模型和数据存储
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/learner"
            echo '{"models": [], "datasets": []}' > "$AGENT_CONFIG_DIR/agent-data/learner/config.json"
            ;;
        "monitor")
            # 监控者初始化：配置监控指标和告警规则
            mkdir -p "$AGENT_CONFIG_DIR/agent-data/monitor"
            echo '{"metrics": [], "alerts": []}' > "$AGENT_CONFIG_DIR/agent-data/monitor/config.json"
            ;;
        *)
            smart_echo "未知的Agent类型: $agent_id" "warning"
            return 1
            ;;
    esac

    return 0
}

# 销毁Agent实例
terminate_agent() {
    local agent_id="$1"

    smart_echo "终止Agent: $agent_id" "processing"

    # 设置Agent状态为终止中
    update_agent_status "$agent_id" "terminating"

    # 执行Agent特定的清理逻辑
    terminate_agent_specific "$agent_id"

    # 从编排引擎注销Agent
    unregister_agent "$agent_id"

    # 设置Agent为已终止状态
    update_agent_status "$agent_id" "terminated"

    smart_echo "Agent终止完成: $agent_id" "success"
}

# Agent特定的终止逻辑
terminate_agent_specific() {
    local agent_id="$1"

    case "$agent_id" in
        "planner"|"generator"|"tester"|"deployer"|"reviewer"|"coordinator"|"learner"|"monitor")
            # 清理Agent数据目录
            local agent_data_dir="$AGENT_CONFIG_DIR/agent-data/$agent_id"
            if [[ -d "$agent_data_dir" ]]; then
                rm -rf "$agent_data_dir"
            fi
            ;;
        *)
            smart_echo "未知的Agent类型: $agent_id" "warning"
            ;;
    esac
}

# 暂停Agent
suspend_agent() {
    local agent_id="$1"

    smart_echo "暂停Agent: $agent_id" "info"
    update_agent_status "$agent_id" "suspended"
}

# 恢复Agent
resume_agent() {
    local agent_id="$1"

    smart_echo "恢复Agent: $agent_id" "info"
    update_agent_status "$agent_id" "idle"
}

# 检查Agent健康状态
check_agent_health() {
    local agent_id="$1"

    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    if [[ ! -f "$agent_config" ]]; then
        echo "unhealthy"
        return 1
    fi

    local status=$(jq -r '.status' "$agent_config")
    local last_active=$(jq -r '.last_active // "never"' "$agent_config")

    # 检查是否长时间未活动
    if [[ "$status" == "busy" && -n "$last_active" ]]; then
        local current_time=$(date +%s)
        local last_active_time=$(date -d "$last_active" +%s 2>/dev/null || echo "0")
        local time_diff=$((current_time - last_active_time))

        # 如果忙碌状态超过1小时，认为不健康
        if (( time_diff > 3600 )); then
            echo "stuck"
            return 1
        fi
    fi

    echo "healthy"
    return 0
}

# 注册Agent到编排引擎
register_agent() {
    local agent_id="$1"

    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"
    if [[ ! -f "$registry_file" ]]; then
        echo '{"agents": [], "registry_time": "'$(date -Iseconds)'"}' > "$registry_file"
    fi

    # 检查是否已注册
    if jq -e ".agents[] | select(.id == \"$agent_id\")" "$registry_file" >/dev/null 2>&1; then
        return 0
    fi

    # 添加到注册表
    local temp_file=$(mktemp)
    jq --arg agent_id "$agent_id" --arg timestamp "$(date -Iseconds)" '
        .agents += [{
            "id": $agent_id,
            "registered_at": $timestamp,
            "status": "active"
        }]
    ' "$registry_file" > "$temp_file"

    mv "$temp_file" "$registry_file"
    smart_echo "Agent已注册: $agent_id" "success"
}

# 从编排引擎注销Agent
unregister_agent() {
    local agent_id="$1"

    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"
    if [[ ! -f "$registry_file" ]]; then
        return 0
    fi

    # 从注册表移除
    local temp_file=$(mktemp)
    jq --arg agent_id "$agent_id" --arg timestamp "$(date -Iseconds)" '
        .agents = (.agents | map(if .id == $agent_id then .status = "inactive" | .unregistered_at = $timestamp else . end))
    ' "$registry_file" > "$temp_file"

    mv "$temp_file" "$registry_file"
    smart_echo "Agent已注销: $agent_id" "info"
}

# 🎯 Agent发现和查询服务

# 发现所有活跃的Agent
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

# 查找最佳匹配的Agent
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

# 注册Agent到编排引擎
register_agent() {
    local agent_id="$1"

    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"
    if [[ ! -f "$registry_file" ]]; then
        echo '{"agents": [], "registry_time": "'$(date -Iseconds)'", "version": "1.0"}' > "$registry_file"
    fi

    # 获取Agent配置信息
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    if [[ ! -f "$agent_config" ]]; then
        smart_echo "Agent配置不存在: $agent_config" "error"
        return 1
    fi

    local agent_info=$(cat "$agent_config")

    # 检查是否已注册
    if jq -e ".agents[] | select(.id == \"$agent_id\")" "$registry_file" >/dev/null 2>&1; then
        # 已注册，只需要更新状态为active
        local temp_file=$(mktemp)
        jq --arg agent_id "$agent_id" --arg timestamp "$(date -Iseconds)" '
            .agents = (.agents | map(if .id == $agent_id then .status = "active" | .last_registered = $timestamp else . end))
        ' "$registry_file" > "$temp_file"
        mv "$temp_file" "$registry_file"
        return 0
    fi

    # 添加新Agent到注册表
    local temp_file=$(mktemp)
    local agent_name=$(echo "$agent_info" | jq -r '.name // "Unknown"')
    local agent_description=$(echo "$agent_info" | jq -r '.description // "No description"')
    local agent_capabilities=$(echo "$agent_info" | jq -r '.capabilities // []')
    local agent_specializations=$(echo "$agent_info" | jq -r '.specializations // []')

    jq --arg agent_id "$agent_id" --arg name "$agent_name" --arg desc "$agent_description" --arg timestamp "$(date -Iseconds)" --argjson caps "$agent_capabilities" --argjson specs "$agent_specializations" '
        .agents += [{
            "id": $agent_id,
            "name": $name,
            "description": $desc,
            "capabilities": $caps,
            "specializations": $specs,
            "status": "active",
            "registered_at": $timestamp,
            "last_registered": $timestamp
        }]
    ' "$registry_file" > "$temp_file"

    mv "$temp_file" "$registry_file"
    smart_echo "Agent已注册: $agent_id" "success"
}

# 初始化代理编排引擎
init_agent_orchestration_engine() {
    smart_echo "初始化代理编排引擎..." "processing"

    # 创建代理目录结构 (只创建一级目录)
    mkdir -p "$AGENT_CONFIG_DIR"
    mkdir -p "$AGENT_CONFIG_DIR/agent-data"

    # 初始化Agent注册表
    init_agent_registry

    # 初始化代理配置文件
    init_agent_configs

    # 初始化所有Agent
    init_all_agents

    # 初始化任务队列
    init_task_queue

    # 初始化通信系统
    init_agent_communication

    # 初始化性能监控
    init_agent_performance_monitoring

    smart_echo "代理编排引擎初始化完成" "success"
}

# 初始化Agent注册表
init_agent_registry() {
    smart_echo "初始化Agent注册表..." "info"

    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"

    # 确保目录存在
    mkdir -p "$AGENT_CONFIG_DIR"

    # 创建或重置注册表
    cat > "$registry_file" <<EOF
{
  "agents": [],
  "registry_time": "$(date -Iseconds)",
  "version": "1.0"
}
EOF

    smart_echo "Agent注册表已初始化" "success"
}

# 初始化所有Agent
init_all_agents() {
    smart_echo "初始化所有Agent..." "processing"

    for agent_id in "${!AGENT_ARCHITECTURE[@]}"; do
        if ! initialize_agent "$agent_id"; then
            smart_echo "Agent初始化失败: $agent_id" "error"
        fi
    done
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

# 🎯 动态负载调度器

# 选择最优代理 (动态负载调度器)
select_optimal_agent() {
    local task_description="$1"
    local task_type="$2"
    local required_capabilities="$3"

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
    local agent_count=$(ls "$AGENT_CONFIG_DIR"/*.json 2>/dev/null | grep -c "ai-agent-" || echo "0")
    local busy_agents=0
    local total_load=0

    # 计算当前系统负载
    for agent_config in "$AGENT_CONFIG_DIR"/*.json; do
        if [[ -f "$agent_config" && $(basename "$agent_config") =~ ^ai-agent- ]]; then
            local status=$(jq -r '.status' "$agent_config" 2>/dev/null || echo "unknown")
            if [[ "$status" == "busy" ]]; then
                ((busy_agents++))
            fi
        fi
    done

    local load_percentage=0
    if (( agent_count > 0 )); then
        load_percentage=$(( busy_agents * 100 / agent_count ))
    fi

    cat <<EOF
{
  "total_agents": $agent_count,
  "busy_agents": $busy_agents,
  "idle_agents": $((agent_count - busy_agents)),
  "load_percentage": $load_percentage,
  "load_level": "$(get_load_level "$load_percentage")",
  "timestamp": "$(date -Iseconds)"
}
EOF
}

# 获取负载等级
get_load_level() {
    local load_percentage="$1"

    if (( load_percentage >= 80 )); then
        echo "critical"
    elif (( load_percentage >= 60 )); then
        echo "high"
    elif (( load_percentage >= 40 )); then
        echo "medium"
    else
        echo "low"
    fi
}

# 获取可用代理列表
get_available_agents() {
    local available_agents="[]"

    for agent_config in "$AGENT_CONFIG_DIR"/*.json; do
        if [[ -f "$agent_config" && $(basename "$agent_config") =~ ^ai-agent- ]]; then
            local agent_id=$(basename "$agent_config" .json | sed 's/ai-agent-//')
            local status=$(jq -r '.status' "$agent_config" 2>/dev/null || echo "unknown")

            # 只包含活跃的代理 (idle, initializing, terminating)
            if [[ "$status" == "idle" || "$status" == "initializing" ]]; then
                local agent_info=$(cat "$agent_config")
                available_agents=$(jq -n --argjson agents "$available_agents" --argjson agent "$agent_info" '$agents + [$agent]')
            fi
        fi
    done

    echo "$available_agents"
}

# 应用智能调度策略
apply_scheduling_strategy() {
    local task_description="$1"
    local task_type="$2"
    local required_capabilities="$3"
    local available_agents="$4"
    local system_load="$5"

    local load_level=$(echo "$system_load" | jq -r '.load_level')

    # 根据系统负载选择调度策略
    case "$load_level" in
        "critical")
            # 紧急负载: 只选择最佳匹配的代理
            apply_critical_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        "high")
            # 高负载: 优先考虑负载均衡
            apply_high_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        "medium")
            # 中等负载: 平衡性能和负载
            apply_medium_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
        "low"|*)
            # 低负载: 优化性能
            apply_low_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
            ;;
    esac
}

# 紧急负载调度策略
apply_critical_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用紧急负载调度策略" "warning"

    local best_agent=""
    local best_score=0

    # 只选择负载最低的代理中的最佳匹配
    echo "$available_agents" | jq -c '.[]' | while read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local current_load=$(get_agent_current_load "$agent_id")

        # 只考虑负载低于50%的代理
        if (( $(echo "$current_load < 50" | bc -l 2>/dev/null || echo "0") )); then
            local match_score=$(calculate_agent_task_match "$agent_id" "$task_description" "$task_type" "$required_capabilities")

            if (( $(echo "$match_score > $best_score" | bc -l 2>/dev/null || echo "0") )); then
                best_agent="$agent_id"
                best_score="$match_score"
            fi
        fi
    done

    echo "$best_agent"
}

# 高负载调度策略
apply_high_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用高负载调度策略" "info"

    # 优先考虑负载均衡，选择负载最低的代理
    local lowest_load_agent=""
    local lowest_load=100

    echo "$available_agents" | jq -c '.[]' | while read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local current_load=$(get_agent_current_load "$agent_id")

        if (( $(echo "$current_load < $lowest_load" | bc -l 2>/dev/null || echo "0") )); then
            lowest_load="$current_load"
            lowest_load_agent="$agent_id"
        fi
    done

    # 检查最低负载代理是否满足基本要求
    if [[ -n "$lowest_load_agent" ]]; then
        local match_score=$(calculate_agent_task_match "$lowest_load_agent" "$task_description" "$task_type" "$required_capabilities")
        if (( $(echo "$match_score >= 50" | bc -l 2>/dev/null || echo "0") )); then
            echo "$lowest_load_agent"
            return
        fi
    fi

    # 如果没有合适的低负载代理，回退到标准策略
    apply_medium_load_strategy "$available_agents" "$task_description" "$task_type" "$required_capabilities"
}

# 中等负载调度策略
apply_medium_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用中等负载调度策略" "info"

    local best_agent=""
    local best_score=0

    # 平衡考虑匹配度和负载
    echo "$available_agents" | jq -c '.[]' | while read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local match_score=$(calculate_agent_task_match "$agent_id" "$task_description" "$task_type" "$required_capabilities")
        local load_factor=$(get_agent_load_factor "$agent_id")

        # 计算平衡分数 (匹配度70% + 负载平衡30%)
        local balanced_score=$(echo "scale=2; $match_score * 0.7 + (100 - $load_factor) * 0.3" | bc 2>/dev/null || echo "0")

        if (( $(echo "$balanced_score > $best_score" | bc -l 2>/dev/null || echo "0") )); then
            best_agent="$agent_id"
            best_score="$balanced_score"
        fi
    done

    echo "$best_agent"
}

# 低负载调度策略
apply_low_load_strategy() {
    local available_agents="$1"
    local task_description="$2"
    local task_type="$3"
    local required_capabilities="$4"

    smart_echo "应用低负载调度策略" "info"

    local best_agent=""
    local best_score=0

    # 优化性能，选择最佳匹配的代理
    echo "$available_agents" | jq -c '.[]' | while read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local match_score=$(calculate_agent_task_match "$agent_id" "$task_description" "$task_type" "$required_capabilities")

        if (( $(echo "$match_score > $best_score" | bc -l 2>/dev/null || echo "0") )); then
            best_agent="$agent_id"
            best_score="$match_score"
        fi
    done

    echo "$best_agent"
}

# 获取代理当前负载
get_agent_current_load() {
    local agent_id="$1"

    # 检查代理当前是否有活跃任务
    local active_tasks=$(jq '.active_tasks | keys | length' "$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json" 2>/dev/null || echo "0")

    if (( active_tasks > 0 )); then
        echo "100"
    else
        echo "0"
    fi
}

# 获取代理负载因子
get_agent_load_factor() {
    local agent_id="$1"

    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    local status=$(jq -r '.status' "$agent_config" 2>/dev/null || echo "idle")

    case "$status" in
        "busy")
            echo "100"
            ;;
        "idle")
            echo "0"
            ;;
        "initializing")
            echo "20"
            ;;
        "terminating")
            echo "80"
            ;;
        *)
            echo "50"
            ;;
    esac
}

# 更新调度统计
update_scheduling_stats() {
    local agent_id="$1"
    local action="$2"

    local stats_file="$AGENT_CONFIG_DIR/scheduling-stats.json"

    if [[ ! -f "$stats_file" ]]; then
        cat > "$stats_file" <<EOF
{
  "total_scheduled": 0,
  "agent_stats": {},
  "last_updated": "$(date -Iseconds)"
}
EOF
    fi

    # 更新统计信息
    local temp_file=$(mktemp)
    jq --arg agent_id "$agent_id" --arg action "$action" '
        .total_scheduled += 1 |
        .agent_stats[$agent_id] = (.agent_stats[$agent_id] // {"scheduled": 0, "selected": 0, "failed": 0}) |
        .agent_stats[$agent_id][$action] += 1 |
        .last_updated = "'$(date -Iseconds)'"
    ' "$stats_file" > "$temp_file"

    mv "$temp_file" "$stats_file"
}

# 显示调度器状态
show_scheduler_status() {
    smart_echo "=== ⚖️ 动态负载调度器状态 ===" "info"

    local system_load=$(get_system_load_status)
    local load_percentage=$(echo "$system_load" | jq -r '.load_percentage')
    local load_level=$(echo "$system_load" | jq -r '.load_level')

    smart_echo "系统负载: $load_percentage% ($load_level)" "info"

    local available_agents=$(get_available_agents)
    local agent_count=$(echo "$available_agents" | jq 'length')

    smart_echo "可用代理: $agent_count 个" "info"

    # 显示调度统计
    local stats_file="$AGENT_CONFIG_DIR/scheduling-stats.json"
    if [[ -f "$stats_file" ]]; then
        local total_scheduled=$(jq -r '.total_scheduled' "$stats_file")
        smart_echo "总调度次数: $total_scheduled" "info"
    fi

    smart_echo "当前调度策略: $(get_current_scheduling_strategy "$load_level")" "info"
}

# 获取当前调度策略
get_current_scheduling_strategy() {
    local load_level="$1"

    case "$load_level" in
        "critical") echo "紧急负载优化 - 只选择最佳匹配" ;;
        "high") echo "高负载均衡 - 优先负载均衡" ;;
        "medium") echo "中等负载平衡 - 性能与负载兼顾" ;;
        "low") echo "低负载优化 - 性能优先" ;;
        *) echo "标准调度策略" ;;
    esac
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

# 执行代理任务 (带容错机制)
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
    local retry_count=$(echo "$task_details" | jq -r '.retry_count // 0')

    # 执行任务（带重试机制）
    local max_retries=3
    local attempt=1
    local execution_result=""

    while (( attempt <= max_retries )); do
        smart_echo "执行尝试 $attempt/$max_retries" "info"

        # 检查Agent健康状态
        if ! check_agent_health_status "$agent_id"; then
            smart_echo "Agent $agent_id 健康检查失败，尝试恢复" "warning"
            if ! attempt_agent_recovery "$agent_id"; then
                execution_result="agent_unhealthy"
                break
            fi
        fi

        # 执行具体任务
        execution_result=$(execute_agent_specific_task "$agent_id" "$task_description" "$task_type")

        if [[ "$execution_result" == "success" ]]; then
            break
        fi

        smart_echo "任务执行失败 (尝试 $attempt): $execution_result" "warning"

        # 如果不是最后一次尝试，等待后重试
        if (( attempt < max_retries )); then
            local retry_delay=$(( attempt * 5 ))  # 递增延迟
            smart_echo "等待 ${retry_delay}秒后重试..." "info"
            sleep "$retry_delay"
        fi

        ((attempt++))
    done

    # 处理执行结果
    if [[ "$execution_result" == "success" ]]; then
        complete_task "$task_id" "$agent_id"
        smart_echo "任务 $task_id 执行成功" "success"
    else
        # 执行失败，触发容错机制
        handle_task_execution_failure "$task_id" "$agent_id" "$execution_result" "$retry_count"
    fi

    # 释放代理
    update_agent_status "$agent_id" "idle"
}

# 处理任务执行失败
handle_task_execution_failure() {
    local task_id="$1"
    local agent_id="$2"
    local failure_reason="$3"
    local retry_count="$4"

    smart_echo "任务 $task_id 执行失败，启动容错处理" "error"

    # 记录失败信息
    log_task_failure "$task_id" "$agent_id" "$failure_reason"

    # 检查是否超过最大重试次数
    local max_total_retries=5
    if (( retry_count >= max_total_retries )); then
        # 最终失败
        fail_task "$task_id" "$agent_id" "max_retries_exceeded: $failure_reason"
        smart_echo "任务 $task_id 已达到最大重试次数，标记为失败" "error"
        return
    fi

    # 尝试重新分配任务
    smart_echo "尝试重新分配任务 $task_id" "info"

    # 标记原Agent为可疑状态
    update_agent_status "$agent_id" "suspicious"

    # 清除任务分配
    update_task_status "$task_id" "pending" ""

    # 等待一小段时间，让系统冷却
    sleep 2

    # 重新触发任务分配（会选择其他Agent）
    trigger_task_assignment

    smart_echo "任务 $task_id 已重新分配给其他Agent" "info"
}

# 记录任务失败
log_task_failure() {
    local task_id="$1"
    local agent_id="$2"
    local failure_reason="$3"

    local failure_log="$AGENT_CONFIG_DIR/task-failures.log"

    echo "[$(date -Iseconds)] TASK_FAILURE: $task_id - Agent: $agent_id - Reason: $failure_reason" >> "$failure_log"
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

# 🎯 智能复杂度分析和任务分解

# 分析任务复杂度并决定是否需要分解
analyze_task_complexity() {
    local task_description="$1"
    local task_type="$2"

    local complexity_score=$(calculate_complexity_score "$task_description" "$task_type")
    local decomposition_needed=$(should_decompose_task "$complexity_score" "$task_description")

    cat <<EOF
{
  "complexity_score": $complexity_score,
  "decomposition_needed": $decomposition_needed,
  "estimated_subtasks": $(estimate_subtask_count "$complexity_score"),
  "complexity_level": "$(get_complexity_level "$complexity_score")",
  "analysis_timestamp": "$(date -Iseconds)"
}
EOF
}

# 计算复杂度评分 (1-100分)
calculate_complexity_score() {
    local task_description="$1"
    local task_type="$2"

    local base_score=50

    # 1. 基于描述长度 (权重: 20%)
    # 使用wc -m来正确计算字符数（包括中文字符）
    local description_length=$(echo -n "$task_description" | wc -m)
    local length_score
    if (( description_length < 10 )); then
        length_score=10
    elif (( description_length < 20 )); then
        length_score=20
    elif (( description_length < 50 )); then
        length_score=40
    elif (( description_length < 100 )); then
        length_score=60
    elif (( description_length < 200 )); then
        length_score=80
    else
        length_score=100
    fi

    # 2. 基于关键词复杂度 (权重: 30%)
    local keyword_score=$(analyze_keywords_complexity "$task_description")

    # 3. 基于任务类型复杂度 (权重: 25%)
    local type_score
    case "$task_type" in
        "planning") type_score=70 ;;
        "coding") type_score=85 ;;
        "testing") type_score=75 ;;
        "deployment") type_score=65 ;;
        "review") type_score=60 ;;
        "coordination") type_score=90 ;;
        "learning") type_score=80 ;;
        "monitoring") type_score=55 ;;
        *) type_score=50 ;;
    esac

    # 4. 基于依赖复杂度 (权重: 15%)
    local dependency_score=$(analyze_dependency_complexity "$task_description")

    # 5. 基于技术栈复杂度 (权重: 10%)
    local tech_score=$(analyze_technology_complexity "$task_description")

    # 计算综合复杂度评分
    local total_score=$(
        echo "scale=2;
        ($length_score * 0.2) +
        ($keyword_score * 0.3) +
        ($type_score * 0.25) +
        ($dependency_score * 0.15) +
        ($tech_score * 0.1)
        " | bc 2>/dev/null || echo "50.0"
    )

    # 确保分数在1-100范围内
    if (( $(echo "$total_score < 1" | bc -l 2>/dev/null) )); then
        total_score=1
    elif (( $(echo "$total_score > 100" | bc -l 2>/dev/null) )); then
        total_score=100
    fi

    echo "$total_score"
}

# 分析关键词复杂度
analyze_keywords_complexity() {
    local task_description="$1"

    # 定义不同权重的关键词组
    local high_complexity_keywords=(
        "架构" "architecture" "design.*system" "infrastructure"
        "微服务" "microservice" "分布式" "distributed"
        "高并发" "high.concurrency" "可扩展" "scalability"
        "容错" "fault.tolerant" "负载均衡" "load.balancing"
        "云计算" "cloud" "容器化" "containerization"
    )

    local medium_complexity_keywords=(
        "优化" "optimization" "性能" "performance" "安全" "security"
        "集成" "integration" "api" "算法" "algorithm"
        "机器学习" "ai" "数据分析" "analytics"
        "并发" "concurrent" "异步" "async" "并行" "parallel"
        "数据库" "database" "查询优化" "query" "schema"
        "前端" "frontend" "后端" "backend" "服务端" "server"
    )

    local low_complexity_keywords=(
        "创建" "create" "添加" "add" "修改" "update" "删除" "delete"
        "配置" "config" "设置" "setup" "安装" "install"
        "测试" "test" "检查" "check" "验证" "validate"
    )

    # 计算各权重关键词的数量
    local high_count=0
    local medium_count=0
    local low_count=0

    for keyword in "${high_complexity_keywords[@]}"; do
        if echo "$task_description" | grep -qi "$keyword"; then
            ((high_count++))
        fi
    done

    for keyword in "${medium_complexity_keywords[@]}"; do
        if echo "$task_description" | grep -qi "$keyword"; then
            ((medium_count++))
        fi
    done

    for keyword in "${low_complexity_keywords[@]}"; do
        if echo "$task_description" | grep -qi "$keyword"; then
            ((low_count++))
        fi
    done

    # 计算加权复杂度分数
    local complexity_score=$(( high_count * 20 + medium_count * 10 + low_count * 5 ))
    echo "$complexity_score"
}

# 分析依赖复杂度
analyze_dependency_complexity() {
    local task_description="$1"

    local dependency_indicators=(
        "依赖" "depends" "requires" "needs" "after"
        "必须" "should" "prerequisite" "前提" "先决"
        "顺序" "sequence" "order" "先后" "串行"
        "并行" "parallel" "同时" "concurrent"
    )

    local dependency_count=0
    for indicator in "${dependency_indicators[@]}"; do
        if echo "$task_description" | grep -qi "$indicator"; then
            ((dependency_count++))
        fi
    done

    # 根据依赖指示器数量计算复杂度
    local dependency_score=$(( dependency_count * 25 ))
    if (( dependency_score > 100 )); then
        dependency_score=100
    fi

    echo "$dependency_score"
}

# 分析技术栈复杂度
analyze_technology_complexity() {
    local task_description="$1"

    local tech_stacks=(
        "kubernetes\|docker\|container" "cloud\|aws\|azure\|gcp"
        "react\|vue\|angular\|typescript" "python\|java\|golang\|rust"
        "database\|mysql\|postgres\|mongodb" "microservice\|distributed"
        "ai\|ml\|machine.learning" "blockchain\|crypto"
    )

    local tech_count=0
    for tech in "${tech_stacks[@]}"; do
        if echo "$task_description" | grep -qi "$tech"; then
            ((tech_count++))
        fi
    done

    # 计算技术栈复杂度
    local tech_score=$(( tech_count * 20 ))
    if (( tech_score > 100 )); then
        tech_score=100
    fi

    echo "$tech_score"
}

# 判断是否需要分解任务
should_decompose_task() {
    local complexity_score="$1"
    local task_description="$2"

    # 降低复杂度阈值：50分以上需要分解
    if (( $(echo "$complexity_score >= 50" | bc -l 2>/dev/null) )); then
        echo "true"
        return
    fi

    # 检查是否包含架构/系统/设计关键词
    if echo "$task_description" | grep -qi "架构\|系统\|设计\|微服务\|分布式"; then
        echo "true"
        return
    fi

    # 检查特殊情况
    if echo "$task_description" | grep -qi "并且\|同时\|包括\|以及\|和\|与\|and\|or"; then
        echo "true"
        return
    fi

    # 检查是否包含多个步骤指示器
    local step_indicators=$(echo "$task_description" | grep -o -i "第一步\|第二步\|首先\|然后\|接着\|最后\|step\|phase" | wc -l)
    if (( step_indicators >= 2 )); then
        echo "true"
        return
    fi

    echo "false"
}

# 估算子任务数量
estimate_subtask_count() {
    local complexity_score="$1"

    if (( $(echo "$complexity_score < 50" | bc -l 2>/dev/null) )); then
        echo "1"
    elif (( $(echo "$complexity_score < 70" | bc -l 2>/dev/null) )); then
        echo "2"
    elif (( $(echo "$complexity_score < 85" | bc -l 2>/dev/null) )); then
        echo "3"
    else
        echo "4"
    fi
}

# 获取复杂度等级
get_complexity_level() {
    local complexity_score="$1"

    if (( $(echo "$complexity_score < 30" | bc -l 2>/dev/null) )); then
        echo "简单"
    elif (( $(echo "$complexity_score < 50" | bc -l 2>/dev/null) )); then
        echo "中等"
    elif (( $(echo "$complexity_score < 70" | bc -l 2>/dev/null) )); then
        echo "复杂"
    elif (( $(echo "$complexity_score < 85" | bc -l 2>/dev/null) )); then
        echo "很高"
    else
        echo "极高"
    fi
}

# 智能任务分解
decompose_task() {
    local task_description="$1"
    local task_type="$2"
    local parent_task_id="${3:-}"

    local analysis=$(analyze_task_complexity "$task_description" "$task_type")
    local decomposition_needed=$(echo "$analysis" | jq -r '.decomposition_needed')
    local subtask_count=$(echo "$analysis" | jq -r '.estimated_subtasks')

    if [[ "$decomposition_needed" != "true" ]]; then
        echo "[]"
        return
    fi

    # 生成子任务
    local subtasks=$(generate_subtasks "$task_description" "$task_type" "$subtask_count" "$parent_task_id")

    echo "$subtasks"
}

# 生成子任务
generate_subtasks() {
    local task_description="$1"
    local task_type="$2"
    local subtask_count="$3"
    local parent_task_id="$4"

    local subtasks="[]"

    case "$task_type" in
        "planning")
            subtasks=$(generate_planning_subtasks "$task_description" "$subtask_count" "$parent_task_id")
            ;;
        "coding")
            subtasks=$(generate_coding_subtasks "$task_description" "$subtask_count" "$parent_task_id")
            ;;
        "testing")
            subtasks=$(generate_testing_subtasks "$task_description" "$subtask_count" "$parent_task_id")
            ;;
        "deployment")
            subtasks=$(generate_deployment_subtasks "$task_description" "$subtask_count" "$parent_task_id")
            ;;
        *)
            subtasks=$(generate_generic_subtasks "$task_description" "$subtask_count" "$parent_task_id")
            ;;
    esac

    echo "$subtasks"
}

# 生成规划类子任务
generate_planning_subtasks() {
    local task_description="$1"
    local count="$2"
    local parent_id="$3"

    cat <<EOF
[
  {
    "description": "需求分析和理解",
    "type": "planning",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 4
  },
  {
    "description": "制定详细计划和时间表",
    "type": "planning",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 3
  },
  {
    "description": "识别风险和依赖关系",
    "type": "planning",
    "priority": "medium",
    "parent_task_id": "$parent_id",
    "estimated_effort": 3
  }
]
EOF
}

# 生成编码类子任务
generate_coding_subtasks() {
    local task_description="$1"
    local count="$2"
    local parent_id="$3"

    cat <<EOF
[
  {
    "description": "设计代码结构和接口",
    "type": "coding",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 5
  },
  {
    "description": "实现核心功能逻辑",
    "type": "coding",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 7
  },
  {
    "description": "添加错误处理和边界检查",
    "type": "coding",
    "priority": "medium",
    "parent_task_id": "$parent_id",
    "estimated_effort": 4
  },
  {
    "description": "编写单元测试",
    "type": "testing",
    "priority": "medium",
    "parent_task_id": "$parent_id",
    "estimated_effort": 4
  }
]
EOF
}

# 生成测试类子任务
generate_testing_subtasks() {
    local task_description="$1"
    local count="$2"
    local parent_id="$3"

    cat <<EOF
[
  {
    "description": "设计测试用例和场景",
    "type": "testing",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 4
  },
  {
    "description": "编写自动化测试脚本",
    "type": "testing",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 6
  },
  {
    "description": "执行测试并分析结果",
    "type": "testing",
    "priority": "medium",
    "parent_task_id": "$parent_id",
    "estimated_effort": 3
  }
]
EOF
}

# 生成部署类子任务
generate_deployment_subtasks() {
    local task_description="$1"
    local count="$2"
    local parent_id="$3"

    cat <<EOF
[
  {
    "description": "准备部署环境和配置",
    "type": "deployment",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 4
  },
  {
    "description": "执行代码部署",
    "type": "deployment",
    "priority": "high",
    "parent_task_id": "$parent_id",
    "estimated_effort": 3
  },
  {
    "description": "验证部署结果和监控",
    "type": "deployment",
    "priority": "medium",
    "parent_task_id": "$parent_id",
    "estimated_effort": 3
  }
]
EOF
}

# 生成通用子任务
generate_generic_subtasks() {
    local task_description="$1"
    local count="$2"
    local parent_id="$3"

    # 基于任务描述智能分割
    local words=$(echo "$task_description" | wc -w)
    local words_per_subtask=$(( (words + count - 1) / count ))

    # 创建子任务数组
    local subtasks="["

    for (( i=1; i<=count; i++ )); do
        if (( i > 1 )); then
            subtasks="${subtasks},"
        fi

        subtasks="${subtasks}{
            \"description\": \"执行第${i}阶段任务\",
            \"type\": \"general\",
            \"priority\": \"medium\",
            \"parent_task_id\": \"$parent_id\",
            \"estimated_effort\": 3
        }"
    done

    subtasks="${subtasks}]"
    echo "$subtasks"
}

# 估算任务工作量 (保持向后兼容)
estimate_task_effort() {
    local task_description="$1"
    local task_type="$2"

    local analysis=$(analyze_task_complexity "$task_description" "$task_type")
    local complexity_score=$(echo "$analysis" | jq -r '.complexity_score')

    # 将复杂度评分转换为工作量估算 (1-10分)
    local effort
    if (( $(echo "$complexity_score < 20" | bc -l 2>/dev/null) )); then
        effort=1
    elif (( $(echo "$complexity_score < 40" | bc -l 2>/dev/null) )); then
        effort=3
    elif (( $(echo "$complexity_score < 60" | bc -l 2>/dev/null) )); then
        effort=5
    elif (( $(echo "$complexity_score < 80" | bc -l 2>/dev/null) )); then
        effort=7
    else
        effort=10
    fi

    echo "$effort"
}

# 🎯 依赖关系识别和管理系统

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

# 分析任务依赖关系
analyze_task_dependencies() {
    local task_description="$1"
    local task_type="$2"
    local existing_tasks="${3:-[]}"

    local dependencies=$(identify_dependencies "$task_description" "$task_type" "$existing_tasks")
    local dependency_graph=$(build_dependency_graph "$dependencies")
    local has_cycles=$(detect_circular_dependencies "$dependency_graph")

    cat <<EOF
{
  "dependencies": $dependencies,
  "dependency_graph": $dependency_graph,
  "has_circular_dependencies": $has_cycles,
  "analysis_timestamp": "$(date -Iseconds)"
}
EOF
}

# 识别任务依赖关系
identify_dependencies() {
    local task_description="$1"
    local task_type="$2"
    local existing_tasks="$3"

    local dependencies="[]"

    # 1. 基于任务类型的隐含依赖
    local type_dependencies=$(get_type_based_dependencies "$task_type")
    if [[ "$type_dependencies" != "[]" ]]; then
        dependencies=$(jq -n --argjson deps1 "$dependencies" --argjson deps2 "$type_dependencies" '$deps1 + $deps2')
    fi

    # 2. 基于描述的显式依赖
    local explicit_dependencies=$(parse_explicit_dependencies "$task_description")
    if [[ "$explicit_dependencies" != "[]" ]]; then
        dependencies=$(jq -n --argjson deps1 "$dependencies" --argjson deps2 "$explicit_dependencies" '$deps1 + $deps2')
    fi

    # 3. 基于现有任务的上下文依赖
    local context_dependencies=$(identify_context_dependencies "$task_description" "$existing_tasks")
    if [[ "$context_dependencies" != "[]" ]]; then
        dependencies=$(jq -n --argjson deps1 "$dependencies" --argjson deps2 "$context_dependencies" '$deps1 + $deps2')
    fi

    # 4. 基于资源依赖
    local resource_dependencies=$(identify_resource_dependencies "$task_description")
    if [[ "$resource_dependencies" != "[]" ]]; then
        dependencies=$(jq -n --argjson deps1 "$dependencies" --argjson deps2 "$resource_dependencies" '$deps1 + $deps2')
    fi

    echo "$dependencies"
}

# 获取基于任务类型的依赖关系
get_type_based_dependencies() {
    local task_type="$1"

    case "$task_type" in
        "testing")
            # 测试任务通常依赖于代码实现任务
            echo '[{"type": "task_type", "value": "coding", "reason": "测试需要先有可测试的代码"}]'
            ;;
        "deployment")
            # 部署任务依赖于测试任务
            echo '[{"type": "task_type", "value": "testing", "reason": "部署前需要通过测试"}, {"type": "task_type", "value": "coding", "reason": "部署需要先有代码"}]'
            ;;
        "review")
            # 审查任务依赖于代码实现
            echo '[{"type": "task_type", "value": "coding", "reason": "审查需要先有代码"}]'
            ;;
        "monitoring")
            # 监控任务依赖于部署
            echo '[{"type": "task_type", "value": "deployment", "reason": "监控需要先部署系统"}]'
            ;;
        *)
            echo "[]"
            ;;
    esac
}

# 解析显式依赖关系
parse_explicit_dependencies() {
    local task_description="$1"

    local dependencies="[]"

    # 解析"依赖"、"需要"、"必须"等关键词
    if echo "$task_description" | grep -qi "依赖\|depends.*on\|requires\|needs\|prerequisite"; then
        # 这里可以实现更复杂的解析逻辑
        dependencies='[{"type": "explicit", "value": "parsed_from_description", "reason": "任务描述中明确提及的依赖"}]'
    fi

    # 解析顺序指示器
    local step_indicators=("首先\|先\|第一步\|after\|before\|then\|接下来\|接着\|最后\|finally")
    for indicator in "${step_indicators[@]}"; do
        if echo "$task_description" | grep -qi "$indicator"; then
            dependencies=$(jq -n --argjson deps "$dependencies" '$deps + [{"type": "sequence", "value": "step_based", "reason": "任务描述中包含顺序指示"}]')
            break
        fi
    done

    echo "$dependencies"
}

# 识别上下文依赖关系
identify_context_dependencies() {
    local task_description="$1"
    local existing_tasks="$2"

    local dependencies="[]"

    # 检查现有任务中是否有相关的任务
    if [[ "$existing_tasks" != "[]" ]]; then
        # 查找相关的现有任务作为依赖
        local related_tasks=$(echo "$existing_tasks" | jq --arg desc "$task_description" '
            map(select(.description | test($desc; "i")) | select(.status == "completed"))
        ')

        if [[ "$related_tasks" != "[]" ]]; then
            dependencies=$(jq -n --argjson tasks "$related_tasks" '
                $tasks | map({
                    "type": "context",
                    "value": .task_id,
                    "reason": "基于现有完成任务的上下文依赖"
                })
            ')
        fi
    fi

    echo "$dependencies"
}

# 识别资源依赖关系
identify_resource_dependencies() {
    local task_description="$1"

    local dependencies="[]"

    # 检查是否需要特定资源
    local resource_indicators=(
        "数据库\|database" "服务器\|server" "网络\|network"
        "存储\|storage" "权限\|permission" "证书\|certificate"
        "配置\|config" "环境\|environment" "工具\|tool"
    )

    for indicator in "${resource_indicators[@]}"; do
        if echo "$task_description" | grep -qi "$indicator"; then
            dependencies=$(jq -n --argjson deps "$dependencies" --arg res "$indicator" '
                $deps + [{"type": "resource", "value": $res, "reason": "任务需要特定资源"}]
            ')
        fi
    done

    echo "$dependencies"
}

# 构建依赖关系图
build_dependency_graph() {
    local dependencies="$1"

    # 创建依赖关系图结构
    cat <<EOF
{
  "nodes": [],
  "edges": $(echo "$dependencies" | jq 'map({
    "from": (.value // "unknown"),
    "to": "current_task",
    "type": .type,
    "reason": .reason
  })')
}
EOF
}

# 检测循环依赖
detect_circular_dependencies() {
    local dependency_graph="$1"

    # 简化的循环依赖检测
    # 在实际实现中，这里应该使用图算法检测循环
    local edges=$(echo "$dependency_graph" | jq '.edges | length')

    # 如果依赖关系过于复杂，认为可能有循环依赖
    if (( edges > 10 )); then
        echo "true"
    else
        echo "false"
    fi
}

# 解析任务依赖关系
resolve_task_dependencies() {
    local task_id="$1"

    local task_details=$(get_task_details "$task_id")
    local dependencies=$(echo "$task_details" | jq -r '.dependencies // []')

    local resolved_dependencies="[]"
    local unresolved_dependencies="[]"

    # 检查每个依赖是否已满足
    echo "$dependencies" | jq -c '.[]' | while read -r dep; do
        local dep_type=$(echo "$dep" | jq -r '.type')
        local dep_value=$(echo "$dep" | jq -r '.value')

        if check_dependency_satisfied "$dep_type" "$dep_value"; then
            resolved_dependencies=$(jq -n --argjson deps "$resolved_dependencies" --argjson dep "$dep" '$deps + [$dep]')
        else
            unresolved_dependencies=$(jq -n --argjson deps "$unresolved_dependencies" --argjson dep "$dep" '$deps + [$dep]')
        fi
    done

    cat <<EOF
{
  "task_id": "$task_id",
  "resolved_dependencies": $resolved_dependencies,
  "unresolved_dependencies": $unresolved_dependencies,
  "can_proceed": $([[ "$unresolved_dependencies" == "[]" ]] && echo "true" || echo "false")
}
EOF
}

# 检查依赖是否满足
check_dependency_satisfied() {
    local dep_type="$1"
    local dep_value="$2"

    case "$dep_type" in
        "task_type")
            # 检查是否有相应类型的已完成任务
            local completed_tasks=$(jq '.completed_tasks[]?.type' "$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json" 2>/dev/null || echo "")
            if echo "$completed_tasks" | grep -q "$dep_value"; then
                return 0
            fi
            ;;
        "resource")
            # 检查资源是否可用（简化检查）
            return 0  # 假设资源总是可用的
            ;;
        "context")
            # 检查特定任务是否已完成
            local task_status=$(get_task_status "$dep_value")
            if [[ "$task_status" == "completed" ]]; then
                return 0
            fi
            ;;
        *)
            return 0  # 默认认为依赖已满足
            ;;
    esac

    return 1
}

# 获取任务状态
get_task_status() {
    local task_id="$1"

    local task_details=$(get_task_details "$task_id")
    echo "$task_details" | jq -r '.status // "unknown"'
}

# 拓扑排序任务（处理依赖顺序）
topological_sort_tasks() {
    local tasks="$1"

    # 简化的拓扑排序实现
    # 在实际应用中，这里应该使用标准的拓扑排序算法
    echo "$tasks" | jq 'sort_by(.dependencies | length)'
}

# 显示依赖关系分析结果
show_dependency_analysis() {
    local task_description="$1"
    local task_type="$2"

    smart_echo "=== 🔗 依赖关系分析 ===" "info"

    local analysis=$(analyze_task_dependencies "$task_description" "$task_type")

    local dependencies=$(echo "$analysis" | jq '.dependencies')
    local dep_count=$(echo "$dependencies" | jq 'length')
    local has_cycles=$(echo "$analysis" | jq -r '.has_circular_dependencies')

    smart_echo "发现 $dep_count 个依赖关系" "info"

    if (( dep_count > 0 )); then
        echo "$dependencies" | jq -r '.[] | "  📋 \(.type): \(.value) - \(.reason)"'
    fi

    if [[ "$has_cycles" == "true" ]]; then
        smart_echo "⚠️  检测到可能的循环依赖" "warning"
    else
        smart_echo "✅ 无循环依赖" "success"
    fi
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

# Agent生命周期管理函数
export -f initialize_agent
export -f terminate_agent
export -f suspend_agent
export -f resume_agent
export -f check_agent_health

# Agent注册和发现函数
export -f register_agent
export -f unregister_agent
export -f discover_agents
export -f discover_agents_by_capability
export -f discover_agents_by_specialization
export -f discover_agents_by_status
export -f get_agent_details
export -f find_best_matching_agent
export -f get_agent_health_report
export -f show_agent_discovery

# 智能复杂度分析和任务分解函数
export -f analyze_task_complexity
export -f calculate_complexity_score
export -f should_decompose_task
export -f decompose_task
export -f estimate_subtask_count
export -f get_complexity_level

# 🎯 资源需求评估模块

# 评估任务资源需求
assess_task_resource_requirements() {
    local task_description="$1"
    local task_type="$2"
    local complexity_analysis="$3"

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score // 50')
    local estimated_effort=$(estimate_task_effort "$task_description" "$task_type")

    # 基于复杂度评分和任务类型计算资源需求
    local resource_profile=$(calculate_resource_profile "$task_type" "$complexity_score" "$estimated_effort")

    # 基于任务描述分析特殊资源需求
    local special_requirements=$(analyze_special_resource_requirements "$task_description")

    # 合并基础资源需求和特殊需求
    local final_requirements=$(merge_resource_requirements "$resource_profile" "$special_requirements")

    cat <<EOF
{
  "resource_profile": $resource_profile,
  "special_requirements": $special_requirements,
  "final_requirements": $final_requirements,
  "estimated_cost": $(calculate_resource_cost "$final_requirements"),
  "recommended_agent_types": $(recommend_agent_types "$task_type" "$final_requirements"),
  "scalability_notes": "$(generate_scalability_notes "$final_requirements")",
  "assessment_timestamp": "$(date -Iseconds)"
}
EOF
}

# 计算资源配置档
calculate_resource_profile() {
    local task_type="$1"
    local complexity_score="$2"
    local effort="$3"

    # 基础资源配置
    local base_cpu="low"
    local base_memory="low"
    local base_io="low"
    local base_network="low"
    local base_storage="low"

    # 根据任务类型调整基础配置
    case "$task_type" in
        "coding")
            base_cpu="high"
            base_memory="high"
            base_io="medium"
            base_network="medium"
            ;;
        "testing")
            base_cpu="medium"
            base_memory="medium"
            base_io="high"
            base_network="low"
            ;;
        "deployment")
            base_cpu="medium"
            base_memory="medium"
            base_io="medium"
            base_network="high"
            ;;
        "review")
            base_cpu="medium"
            base_memory="high"
            base_io="medium"
            base_network="low"
            ;;
        "planning")
            base_cpu="low"
            base_memory="medium"
            base_io="low"
            base_network="medium"
            ;;
        "learning")
            base_cpu="high"
            base_memory="high"
            base_io="high"
            base_network="medium"
            ;;
        "coordination")
            base_cpu="low"
            base_memory="low"
            base_io="low"
            base_network="high"
            ;;
        "monitoring")
            base_cpu="low"
            base_memory="low"
            base_io="low"
            base_network="low"
            ;;
    esac

    # 根据复杂度评分调整配置
    if (( $(echo "$complexity_score >= 70" | bc -l 2>/dev/null) )); then
        # 高复杂度任务需要更多资源
        base_cpu=$(scale_resource_level "$base_cpu" 2)
        base_memory=$(scale_resource_level "$base_memory" 2)
        base_io=$(scale_resource_level "$base_io" 1)
        base_network=$(scale_resource_level "$base_network" 1)
    elif (( $(echo "$complexity_score >= 40" | bc -l 2>/dev/null) )); then
        # 中等复杂度任务轻微增加资源
        base_cpu=$(scale_resource_level "$base_cpu" 1)
        base_memory=$(scale_resource_level "$base_memory" 1)
    fi

    # 根据工作量调整配置
    if (( effort >= 7 )); then
        base_cpu=$(scale_resource_level "$base_cpu" 1)
        base_memory=$(scale_resource_level "$base_memory" 1)
    fi

    cat <<EOF
{
  "cpu": "$base_cpu",
  "memory": "$base_memory",
  "io": "$base_io",
  "network": "$base_network",
  "storage": "$base_storage",
  "parallelization": "$(calculate_parallelization_potential "$task_type" "$complexity_score")",
  "estimated_duration": "$(estimate_task_duration "$effort" "$complexity_score")"
}
EOF
}

# 调整资源等级
scale_resource_level() {
    local current_level="$1"
    local scale_factor="$2"

    case "$current_level" in
        "low")
            if (( scale_factor >= 2 )); then echo "medium"
            else echo "low"
            fi
            ;;
        "medium")
            if (( scale_factor >= 2 )); then echo "high"
            else echo "medium"
            fi
            ;;
        "high")
            echo "high"
            ;;
        *)
            echo "medium"
            ;;
    esac
}

# 计算并行化潜力
calculate_parallelization_potential() {
    local task_type="$1"
    local complexity_score="$2"

    # 某些任务类型更适合并行处理
    case "$task_type" in
        "testing")
            echo "high"
            ;;
        "coding")
            if (( $(echo "$complexity_score >= 60" | bc -l 2>/dev/null) )); then
                echo "medium"
            else
                echo "low"
            fi
            ;;
        "learning")
            echo "high"
            ;;
        *)
            echo "low"
            ;;
    esac
}

# 估算任务持续时间
estimate_task_duration() {
    local effort="$1"
    local complexity_score="$2"

    # 基础时间估算（分钟）
    local base_duration=$(( effort * 30 ))  # 每工作量单位30分钟

    # 根据复杂度调整
    local complexity_multiplier
    if (( $(echo "$complexity_score >= 80" | bc -l 2>/dev/null) )); then
        complexity_multiplier="2.0"
    elif (( $(echo "$complexity_score >= 60" | bc -l 2>/dev/null) )); then
        complexity_multiplier="1.5"
    elif (( $(echo "$complexity_score >= 40" | bc -l 2>/dev/null) )); then
        complexity_multiplier="1.2"
    else
        complexity_multiplier="1.0"
    fi

    local estimated_duration=$(echo "scale=1; $base_duration * $complexity_multiplier" | bc 2>/dev/null || echo "$base_duration")

    echo "${estimated_duration}m"
}

# 分析特殊资源需求
analyze_special_resource_requirements() {
    local task_description="$1"

    local special_reqs="[]"

    # 检查是否需要特殊工具或环境
    if echo "$task_description" | grep -qi "数据库\|database"; then
        special_reqs=$(jq -n --argjson reqs "$special_reqs" '$reqs + [{"type": "database", "requirement": "数据库访问权限", "priority": "high"}]')
    fi

    if echo "$task_description" | grep -qi "docker\|container\|kubernetes"; then
        special_reqs=$(jq -n --argjson reqs "$special_reqs" '$reqs + [{"type": "containerization", "requirement": "容器运行环境", "priority": "high"}]')
    fi

    if echo "$task_description" | grep -qi "云服务\|aws\|azure\|gcp"; then
        special_reqs=$(jq -n --argjson reqs "$special_reqs" '$reqs + [{"type": "cloud_access", "requirement": "云服务API访问", "priority": "medium"}]')
    fi

    if echo "$task_description" | grep -qi "安全\|security\|加密\|encryption"; then
        special_reqs=$(jq -n --argjson reqs "$special_reqs" '$reqs + [{"type": "security_clearance", "requirement": "安全审查权限", "priority": "high"}]')
    fi

    if echo "$task_description" | grep -qi "性能\|performance\|优化\|optimization"; then
        special_reqs=$(jq -n --argjson reqs "$special_reqs" '$reqs + [{"type": "profiling_tools", "requirement": "性能分析工具", "priority": "medium"}]')
    fi

    if echo "$task_description" | grep -qi "机器学习\|ai\|ml\|neural\|model"; then
        special_reqs=$(jq -n --argjson reqs "$special_reqs" '$reqs + [{"type": "gpu_access", "requirement": "GPU计算资源", "priority": "high"}]')
    fi

    echo "$special_reqs"
}

# 合并资源需求
merge_resource_requirements() {
    local base_profile="$1"
    local special_reqs="$2"

    # 从基础配置开始
    local merged="$base_profile"

    # 根据特殊需求调整配置
    if echo "$special_reqs" | jq -e '.[] | select(.type == "database")' >/dev/null 2>&1; then
        merged=$(echo "$merged" | jq '.network = "high"')
    fi

    if echo "$special_reqs" | jq -e '.[] | select(.type == "gpu_access")' >/dev/null 2>&1; then
        merged=$(echo "$merged" | jq '.cpu = "high" | .memory = "high"')
    fi

    if echo "$special_reqs" | jq -e '.[] | select(.type == "containerization")' >/dev/null 2>&1; then
        merged=$(echo "$merged" | jq '.io = "high"')
    fi

    echo "$merged"
}

# 计算资源成本
calculate_resource_cost() {
    local resource_reqs="$1"

    local cpu_level=$(echo "$resource_reqs" | jq -r '.cpu')
    local memory_level=$(echo "$resource_reqs" | jq -r '.memory')
    local io_level=$(echo "$resource_reqs" | jq -r '.io')
    local network_level=$(echo "$resource_reqs" | jq -r '.network')

    # 定义资源成本权重
    local cpu_cost
    case "$cpu_level" in
        "low") cpu_cost=1 ;;
        "medium") cpu_cost=2 ;;
        "high") cpu_cost=4 ;;
        *) cpu_cost=1 ;;
    esac

    local memory_cost
    case "$memory_level" in
        "low") memory_cost=1 ;;
        "medium") memory_cost=2 ;;
        "high") memory_cost=4 ;;
        *) memory_cost=1 ;;
    esac

    local io_cost
    case "$io_level" in
        "low") io_cost=1 ;;
        "medium") io_cost=2 ;;
        "high") io_cost=3 ;;
        *) io_cost=1 ;;
    esac

    local network_cost
    case "$network_level" in
        "low") network_cost=1 ;;
        "medium") network_cost=2 ;;
        "high") network_cost=3 ;;
        *) network_cost=1 ;;
    esac

    local total_cost=$(( cpu_cost + memory_cost + io_cost + network_cost ))

    echo "$total_cost"
}

# 推荐合适的Agent类型
recommend_agent_types() {
    local task_type="$1"
    local resource_reqs="$2"

    local cpu_level=$(echo "$resource_reqs" | jq -r '.cpu')
    local memory_level=$(echo "$resource_reqs" | jq -r '.memory')

    local recommendations="[]"

    # 基于任务类型推荐Agent
    case "$task_type" in
        "coding")
            if [[ "$cpu_level" == "high" && "$memory_level" == "high" ]]; then
                recommendations='["generator", "learner"]'
            else
                recommendations='["generator"]'
            fi
            ;;
        "testing")
            recommendations='["tester"]'
            ;;
        "deployment")
            recommendations='["deployer"]'
            ;;
        "review")
            recommendations='["reviewer"]'
            ;;
        "planning")
            recommendations='["planner", "coordinator"]'
            ;;
        "learning")
            recommendations='["learner"]'
            ;;
        "coordination")
            recommendations='["coordinator"]'
            ;;
        "monitoring")
            recommendations='["monitor"]'
            ;;
        *)
            recommendations='["coordinator"]'
            ;;
    esac

    echo "$recommendations"
}

# 生成扩展性说明
generate_scalability_notes() {
    local resource_reqs="$1"

    local parallelization=$(echo "$resource_reqs" | jq -r '.parallelization')
    local duration=$(echo "$resource_reqs" | jq -r '.estimated_duration')

    local notes=""

    case "$parallelization" in
        "high")
            notes="任务高度并行化，适合分解为多个子任务同时执行"
            ;;
        "medium")
            notes="任务中等并行化，可以考虑部分并行处理"
            ;;
        "low")
            notes="任务串行性强，不适合过度并行化"
            ;;
    esac

    local duration_minutes=$(echo "$duration" | sed 's/m//' | bc 2>/dev/null || echo "0")
    if [[ "$duration" == *h* ]] || (( $(echo "$duration_minutes > 120" | bc -l 2>/dev/null || echo "0") )); then
        notes="$notes。预计执行时间较长，建议设置检查点以支持中断恢复"
    fi

    echo "$notes"
}

# 显示资源需求评估结果
show_resource_assessment() {
    local task_description="$1"
    local task_type="$2"

    smart_echo "=== 💰 资源需求评估 ===" "info"

    local complexity_analysis=$(analyze_task_complexity "$task_description" "$task_type")
    local assessment=$(assess_task_resource_requirements "$task_description" "$task_type" "$complexity_analysis")

    smart_echo "任务类型: $task_type" "info"
    smart_echo "复杂度评分: $(echo "$assessment" | jq -r '.final_requirements | .cpu') CPU / $(echo "$assessment" | jq -r '.final_requirements | .memory') 内存" "info"
    smart_echo "并行化潜力: $(echo "$assessment" | jq -r '.final_requirements | .parallelization')" "info"
    smart_echo "预计时长: $(echo "$assessment" | jq -r '.final_requirements | .estimated_duration')" "info"
    smart_echo "资源成本: $(echo "$assessment" | jq -r '.estimated_cost') 单位" "info"

    local special_reqs=$(echo "$assessment" | jq -r '.special_requirements | length')
    if (( special_reqs > 0 )); then
        smart_echo "特殊需求:" "warning"
        echo "$assessment" | jq -r '.special_requirements[] | "  • \(.requirement) (\(.priority) 优先级)"'
    fi

    local recommendations=$(echo "$assessment" | jq -r '.recommended_agent_types | join(", ")')
    smart_echo "推荐Agent: $recommendations" "success"

    local notes=$(echo "$assessment" | jq -r '.scalability_notes')
    if [[ -n "$notes" ]]; then
        smart_echo "扩展性说明: $notes" "info"
    fi
}

# 依赖关系识别和管理函数
export -f analyze_task_dependencies
export -f identify_dependencies
export -f resolve_task_dependencies
export -f check_dependency_satisfied
export -f topological_sort_tasks
export -f show_dependency_analysis

# 资源需求评估函数
export -f assess_task_resource_requirements
export -f calculate_resource_profile
export -f analyze_special_resource_requirements
export -f merge_resource_requirements
export -f calculate_resource_cost
export -f recommend_agent_types
export -f generate_scalability_notes
export -f show_resource_assessment

# 🎯 多层级Agent调度系统

# 创建Agent树结构
create_agent_tree() {
    local root_task_id="$1"
    local max_depth="${2:-3}"

    smart_echo "创建Agent树结构: $root_task_id (最大深度: $max_depth)" "processing"

    # 获取根任务信息
    local root_task=$(get_task_details "$root_task_id")
    local task_type=$(echo "$root_task" | jq -r '.type')
    local complexity_analysis=$(echo "$root_task" | jq -r '.complexity_analysis')

    # 创建根节点
    local root_agent=$(select_root_agent "$task_type" "$complexity_analysis")
    local agent_tree=$(cat <<EOF
{
  "tree_id": "tree_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4)",
  "root_task_id": "$root_task_id",
  "root_agent": "$root_agent",
  "max_depth": $max_depth,
  "nodes": {
    "root": {
      "agent_id": "$root_agent",
      "task_id": "$root_task_id",
      "level": 0,
      "children": [],
      "siblings": [],
      "status": "active",
      "load_factor": 1.0
    }
  },
  "execution_plan": $(generate_execution_plan "$root_task_id" "$root_agent" "$max_depth"),
  "created_at": "$(date -Iseconds)",
  "status": "created"
}
EOF
)

    # 保存Agent树到存储
    save_agent_tree "$agent_tree"

    echo "$agent_tree"
}

# 选择根Agent
select_root_agent() {
    local task_type="$1"
    local complexity_analysis="$2"

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score // 50')
    local needs_decomposition=$(echo "$complexity_analysis" | jq -r '.decomposition_needed // false')

    # 对于复杂任务，使用coordinator作为根Agent
    if [[ "$needs_decomposition" == "true" ]] || (( $(echo "$complexity_score >= 70" | bc -l 2>/dev/null) )); then
        echo "coordinator"
    else
        # 对于简单任务，根据类型选择合适的Agent
        case "$task_type" in
            "coding") echo "generator" ;;
            "testing") echo "tester" ;;
            "deployment") echo "deployer" ;;
            "review") echo "reviewer" ;;
            "learning") echo "learner" ;;
            "monitoring") echo "monitor" ;;
            *) echo "coordinator" ;;
        esac
    fi
}

# 生成执行计划
generate_execution_plan() {
    local root_task_id="$1"
    local root_agent="$2"
    local max_depth="$3"

    cat <<EOF
{
  "phases": [
    {
      "phase": 1,
      "description": "任务分析和分解",
      "agent": "$root_agent",
      "estimated_duration": "15m",
      "parallel_execution": false
    },
    {
      "phase": 2,
      "description": "子任务分配和调度",
      "agent": "$root_agent",
      "estimated_duration": "10m",
      "parallel_execution": false
    },
    {
      "phase": 3,
      "description": "并行执行子任务",
      "agent": "multiple",
      "estimated_duration": "variable",
      "parallel_execution": true
    },
    {
      "phase": 4,
      "description": "结果整合和验证",
      "agent": "$root_agent",
      "estimated_duration": "20m",
      "parallel_execution": false
    }
  ],
  "total_estimated_duration": "variable",
  "risk_assessment": $(assess_execution_risks "$root_task_id")
}
EOF
}

# 评估执行风险
assess_execution_risks() {
    local task_id="$1"

    local task_details=$(get_task_details "$task_id")
    local complexity_score=$(echo "$task_details" | jq -r '.complexity_analysis.complexity_score // 50')
    local dependency_count=$(echo "$task_details" | jq -r '.dependencies | length')

    local risk_level="low"
    local risk_factors="[]"

    # 复杂度风险
    if (( $(echo "$complexity_score >= 80" | bc -l 2>/dev/null) )); then
        risk_level="high"
        risk_factors=$(jq -n --argjson factors "$risk_factors" '$factors + ["高复杂度可能导致执行失败"]')
    elif (( $(echo "$complexity_score >= 60" | bc -l 2>/dev/null) )); then
        risk_level="medium"
        risk_factors=$(jq -n --argjson factors "$risk_factors" '$factors + ["中等复杂度需要仔细监控"]')
    fi

    # 依赖风险
    if (( dependency_count > 3 )); then
        risk_level="high"
        risk_factors=$(jq -n --argjson factors "$risk_factors" '$factors + ["复杂依赖关系可能导致死锁"]')
    elif (( dependency_count > 1 )); then
        risk_level="medium"
        risk_factors=$(jq -n --argjson factors "$risk_factors" '$factors + ["多个依赖需要协调执行"]')
    fi

    cat <<EOF
{
  "risk_level": "$risk_level",
  "risk_factors": $risk_factors,
  "mitigation_strategies": $(generate_mitigation_strategies "$risk_level")
}
EOF
}

# 生成缓解策略
generate_mitigation_strategies() {
    local risk_level="$1"

    case "$risk_level" in
        "high")
            echo '["实施详细监控", "准备回滚计划", "设置执行超时", "启用故障转移机制"]'
            ;;
        "medium")
            echo '["增加状态检查", "实施进度跟踪", "准备备用方案"]'
            ;;
        "low")
            echo '["保持标准监控", "记录执行日志"]'
            ;;
        *)
            echo '["标准风险管理"]'
            ;;
    esac
}

# 扩展Agent树节点
expand_agent_tree_node() {
    local tree_id="$1"
    local parent_node_id="$2"
    local sub_tasks="$3"

    smart_echo "扩展Agent树节点: $parent_node_id" "processing"

    # 加载现有Agent树
    local agent_tree=$(load_agent_tree "$tree_id")

    # 为每个子任务创建子节点
    local child_nodes="[]"
    local sibling_nodes="[]"

    echo "$sub_tasks" | jq -c '.[]' | while read -r sub_task; do
        local sub_task_id=$(echo "$sub_task" | jq -r '.task_id')
        local sub_task_type=$(echo "$sub_task" | jq -r '.type')
        local sub_task_description=$(echo "$sub_task" | jq -r '.description')

        # 为子任务选择合适的Agent
        local child_agent=$(select_child_agent "$sub_task_type" "$sub_task_description")

        # 创建子节点
        local child_node=$(cat <<EOF
{
  "agent_id": "$child_agent",
  "task_id": "$sub_task_id",
  "level": $(($(echo "$agent_tree" | jq ".nodes.\"$parent_node_id\".level") + 1)),
  "children": [],
  "siblings": [],
  "status": "pending",
  "load_factor": 1.0,
  "parent_node": "$parent_node_id"
}
EOF
)

        # 添加到子节点列表
        child_nodes=$(jq -n --argjson nodes "$child_nodes" --argjson node "$child_node" '$nodes + [$node]')
    done

    # 如果有多个子节点，设置兄弟节点关系
    if (( $(echo "$child_nodes" | jq 'length') > 1 )); then
        local node_ids=$(echo "$child_nodes" | jq -r '.[].task_id' | tr '\n' ' ')
        for node_id in $node_ids; do
            local siblings=$(echo "$node_ids" | sed "s/\b$node_id\b//g" | jq -R -s 'split(" ") | map(select(. != ""))')
            agent_tree=$(echo "$agent_tree" | jq --arg node_id "$node_id" --argjson siblings "$siblings" ".nodes.\"$node_id\".siblings = \$siblings")
        done
    fi

    # 更新父节点的子节点列表
    local child_task_ids=$(echo "$child_nodes" | jq -r '.[].task_id')
    agent_tree=$(echo "$agent_tree" | jq --arg parent_id "$parent_node_id" --argjson children "$child_task_ids" ".nodes.\"$parent_id\".children = \$children")

    # 添加新节点到树中
    for child_node in $(echo "$child_nodes" | jq -c '.[]'); do
        local node_id=$(echo "$child_node" | jq -r '.task_id')
        agent_tree=$(echo "$agent_tree" | jq --arg node_id "$node_id" --argjson node "$child_node" ".nodes.\"$node_id\" = \$node")
    done

    # 保存更新后的Agent树
    save_agent_tree "$agent_tree"

    echo "$agent_tree"
}

# 选择子Agent
select_child_agent() {
    local task_type="$1"
    local task_description="$2"

    # 基于任务类型和描述选择最合适的Agent
    case "$task_type" in
        "coding")
            if echo "$task_description" | grep -qi "前端\|ui\|界面"; then
                echo "generator"
            elif echo "$task_description" | grep -qi "后端\|api\|server"; then
                echo "generator"
            else
                echo "generator"
            fi
            ;;
        "testing")
            echo "tester"
            ;;
        "deployment")
            echo "deployer"
            ;;
        "review")
            echo "reviewer"
            ;;
        "learning")
            echo "learner"
            ;;
        "monitoring")
            echo "monitor"
            ;;
        "planning")
            echo "planner"
            ;;
        *)
            echo "coordinator"
            ;;
    esac
}

# 保存Agent树
save_agent_tree() {
    local agent_tree="$1"

    local tree_id=$(echo "$agent_tree" | jq -r '.tree_id')
    local tree_file="$AGENT_CONFIG_DIR/agent-trees/${tree_id}.json"

    mkdir -p "$AGENT_CONFIG_DIR/agent-trees"
    echo "$agent_tree" > "$tree_file"

    smart_echo "Agent树已保存: $tree_id" "success"
}

# 加载Agent树
load_agent_tree() {
    local tree_id="$1"

    local tree_file="$AGENT_CONFIG_DIR/agent-trees/${tree_id}.json"

    if [[ -f "$tree_file" ]]; then
        cat "$tree_file"
    else
        echo "{}"
    fi
}

# 执行Agent树
execute_agent_tree() {
    local tree_id="$1"

    smart_echo "开始执行Agent树: $tree_id" "processing"

    local agent_tree=$(load_agent_tree "$tree_id")

    if [[ "$agent_tree" == "{}" ]]; then
        smart_echo "Agent树不存在: $tree_id" "error"
        return 1
    fi

    # 更新树状态为执行中
    agent_tree=$(echo "$agent_tree" | jq '.status = "executing"')
    save_agent_tree "$agent_tree"

    # 执行根节点任务
    local root_task_id=$(echo "$agent_tree" | jq -r '.root_task_id')
    local root_agent=$(echo "$agent_tree" | jq -r '.root_agent')

    # 分配根任务给根Agent
    assign_task_to_agent "$root_task_id" "$root_agent"

    # 监控执行进度
    monitor_agent_tree_execution "$tree_id"

    smart_echo "Agent树执行完成: $tree_id" "success"
}

# 监控Agent树执行
monitor_agent_tree_execution() {
    local tree_id="$1"

    local max_wait_time=3600  # 最大等待时间1小时
    local check_interval=30   # 检查间隔30秒
    local elapsed=0

    while (( elapsed < max_wait_time )); do
        local agent_tree=$(load_agent_tree "$tree_id")
        local status=$(echo "$agent_tree" | jq -r '.status')

        case "$status" in
            "completed")
                smart_echo "Agent树执行成功完成" "success"
                return 0
                ;;
            "failed")
                smart_echo "Agent树执行失败" "error"
                return 1
                ;;
            "executing")
                # 检查是否有新的子任务需要处理
                local new_subtasks=$(check_for_new_subtasks "$tree_id")
                if [[ "$new_subtasks" != "[]" ]]; then
                    process_new_subtasks "$tree_id" "$new_subtasks"
                fi
                ;;
        esac

        sleep "$check_interval"
        ((elapsed += check_interval))
    done

    smart_echo "Agent树执行超时" "warning"
    return 1
}

# 检查新子任务
check_for_new_subtasks() {
    local tree_id="$1"

    # 这里应该检查是否有新分解的子任务
    # 暂时返回空数组
    echo "[]"
}

# 处理新子任务
process_new_subtasks() {
    local tree_id="$1"
    local subtasks="$2"

    # 为新子任务扩展Agent树
    local agent_tree=$(load_agent_tree "$tree_id")
    local root_node="root"

    expand_agent_tree_node "$tree_id" "$root_node" "$subtasks"
}

# 显示Agent树状态
show_agent_tree() {
    local tree_id="$1"

    smart_echo "=== 🌳 Agent树状态 ===" "info"

    local agent_tree=$(load_agent_tree "$tree_id")

    if [[ "$agent_tree" == "{}" ]]; then
        smart_echo "Agent树不存在: $tree_id" "error"
        return 1
    fi

    local status=$(echo "$agent_tree" | jq -r '.status')
    local root_agent=$(echo "$agent_tree" | jq -r '.root_agent')
    local node_count=$(echo "$agent_tree" | jq '.nodes | length')

    smart_echo "树ID: $tree_id" "info"
    smart_echo "状态: $status" "info"
    smart_echo "根Agent: $root_agent" "info"
    smart_echo "节点数量: $node_count" "info"

    # 显示节点层次结构
    smart_echo "节点层次:" "info"
    echo "$agent_tree" | jq -r '.nodes | to_entries[] | "  \(.key): Agent \(.value.agent_id) (Level \(.value.level))"'

    # 显示执行计划
    smart_echo "执行计划:" "info"
    echo "$agent_tree" | jq -r '.execution_plan.phases[] | "  Phase \(.phase): \(.description) - \(.agent) (\(.estimated_duration))"'
}

# 多层级调度系统函数
export -f create_agent_tree
export -f select_root_agent
export -f generate_execution_plan
export -f assess_execution_risks
export -f generate_mitigation_strategies
export -f expand_agent_tree_node
export -f select_child_agent
export -f save_agent_tree
export -f load_agent_tree
export -f execute_agent_tree
export -f monitor_agent_tree_execution
export -f show_agent_tree

# 动态负载调度器函数
export -f select_optimal_agent
export -f get_system_load_status
export -f get_load_level
export -f get_available_agents
export -f apply_scheduling_strategy
export -f apply_critical_load_strategy
export -f apply_high_load_strategy
export -f apply_medium_load_strategy
export -f apply_low_load_strategy
export -f get_agent_current_load
export -f get_agent_load_factor
export -f update_scheduling_stats
export -f show_scheduler_status
export -f get_current_scheduling_strategy

# 🎯 高可用容错机制

# Agent健康监控和自动恢复
start_agent_health_monitor() {
    smart_echo "启动Agent健康监控服务..." "processing"

    # 创建健康监控配置
    local health_config="$AGENT_CONFIG_DIR/health-monitor.json"
    if [[ ! -f "$health_config" ]]; then
        cat > "$health_config" <<EOF
{
  "monitor_interval": 30,
  "max_retry_attempts": 3,
  "health_check_timeout": 10,
  "auto_recovery_enabled": true,
  "alert_threshold": 80,
  "last_health_check": null,
  "health_history": []
}
EOF
    fi

    # 启动后台监控进程
    (
        while true; do
            perform_health_checks
            sleep 30  # 30秒检查一次
        done
    ) &

    local monitor_pid=$!
    echo "$monitor_pid" > "$AGENT_CONFIG_DIR/health-monitor.pid"

    smart_echo "Agent健康监控服务已启动 (PID: $monitor_pid)" "success"
}

# 执行健康检查
perform_health_checks() {
    local health_config="$AGENT_CONFIG_DIR/health-monitor.json"
    local unhealthy_agents=()

    # 检查所有已注册的Agent
    local registry_file="$AGENT_CONFIG_DIR/agent-registry.json"
    if [[ -f "$registry_file" ]]; then
        local agents=$(jq -r '.agents[]?.id' "$registry_file" 2>/dev/null || echo "")

        for agent_id in $agents; do
            if ! check_agent_health_status "$agent_id"; then
                unhealthy_agents+=("$agent_id")
            fi
        done
    fi

    # 处理不健康的Agent
    if [[ ${#unhealthy_agents[@]} -gt 0 ]]; then
        smart_echo "发现 ${#unhealthy_agents[@]} 个不健康Agent: ${unhealthy_agents[*]}" "warning"
        handle_unhealthy_agents "${unhealthy_agents[@]}"
    fi

    # 更新健康检查时间戳
    local temp_file=$(mktemp)
    jq '.last_health_check = "'$(date -Iseconds)'"' "$health_config" > "$temp_file"
    mv "$temp_file" "$health_config"
}

# 检查Agent健康状态
check_agent_health_status() {
    local agent_id="$1"

    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    if [[ ! -f "$agent_config" ]]; then
        return 1
    fi

    local status=$(jq -r '.status' "$agent_config" 2>/dev/null || echo "unknown")
    local last_active=$(jq -r '.last_active // "never"' "$agent_config")

    # 检查状态
    case "$status" in
        "error"|"maintenance")
            return 1
            ;;
        "busy")
            # 检查是否超时 (超过5分钟)
            if [[ "$last_active" != "never" ]]; then
                local current_time=$(date +%s)
                local last_active_time=$(date -d "$last_active" +%s 2>/dev/null || echo "0")
                local time_diff=$((current_time - last_active_time))

                if (( time_diff > 300 )); then  # 5分钟超时
                    smart_echo "Agent $agent_id 任务执行超时" "warning"
                    return 1
                fi
            fi
            ;;
    esac

    # 检查性能指标
    local success_rate=$(jq -r '.performance_metrics.success_rate // 100' "$agent_config")
    if (( $(echo "$success_rate < 50" | bc -l 2>/dev/null || echo "0") )); then
        smart_echo "Agent $agent_id 成功率过低: $success_rate%" "warning"
        return 1
    fi

    return 0
}

# 处理不健康的Agent
handle_unhealthy_agents() {
    local unhealthy_agents=("$@")

    for agent_id in "${unhealthy_agents[@]}"; do
        smart_echo "处理不健康Agent: $agent_id" "warning"

        # 记录故障事件
        log_agent_failure "$agent_id" "health_check_failed"

        # 尝试自动恢复
        if attempt_agent_recovery "$agent_id"; then
            smart_echo "Agent $agent_id 自动恢复成功" "success"
        else
            # 自动恢复失败，标记为维护状态
            update_agent_status "$agent_id" "maintenance"

            # 触发备用切换
            trigger_failover "$agent_id"
        fi
    done
}

# 尝试Agent自动恢复
attempt_agent_recovery() {
    local agent_id="$1"

    smart_echo "尝试恢复Agent: $agent_id" "info"

    # 重新初始化Agent
    if initialize_agent "$agent_id"; then
        # 验证恢复是否成功
        sleep 2
        if check_agent_health_status "$agent_id"; then
            return 0
        fi
    fi

    smart_echo "Agent $agent_id 自动恢复失败" "error"
    return 1
}

# 触发故障转移
trigger_failover() {
    local failed_agent_id="$1"

    smart_echo "触发故障转移: $failed_agent_id" "warning"

    # 查找失败Agent的活跃任务
    local active_tasks=$(find_agent_active_tasks "$failed_agent_id")

    if [[ "$active_tasks" != "[]" ]]; then
        smart_echo "重新分配 $failed_agent_id 的活跃任务" "info"

        echo "$active_tasks" | jq -c '.[]' | while read -r task; do
            local task_id=$(echo "$task" | jq -r '.task_id')
            local task_description=$(echo "$task" | jq -r '.description')
            local task_type=$(echo "$task" | jq -r '.type')

            # 重新分配任务
            reassign_failed_task "$task_id" "$task_description" "$task_type" "$failed_agent_id"
        done
    fi

    # 发送告警通知
    send_failure_alert "$failed_agent_id" "${#active_tasks}"
}

# 查找Agent的活跃任务
find_agent_active_tasks() {
    local agent_id="$1"

    # 从任务队列中查找分配给该Agent的任务
    local task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    jq --arg agent_id "$agent_id" '.queue[] | select(.assigned_agent == $agent_id and (.status == "assigned" or .status == "executing"))' "$task_queue_file" 2>/dev/null || echo "[]"
}

# 重新分配失败的任务
reassign_failed_task() {
    local task_id="$1"
    local task_description="$2"
    local task_type="$3"
    local failed_agent_id="$4"

    smart_echo "重新分配失败任务: $task_id (原Agent: $failed_agent_id)" "warning"

    # 记录重试信息
    log_task_retry "$task_id" "$failed_agent_id"

    # 清除原分配
    update_task_status "$task_id" "pending" ""

    # 重新触发任务分配
    trigger_task_assignment

    smart_echo "任务 $task_id 已重新分配" "info"
}

# 记录Agent故障
log_agent_failure() {
    local agent_id="$1"
    local failure_reason="$2"

    local failure_log="$AGENT_CONFIG_DIR/agent-failures.log"

    echo "[$(date -Iseconds)] AGENT_FAILURE: $agent_id - $failure_reason" >> "$failure_log"

    # 更新Agent配置中的故障统计
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    if [[ -f "$agent_config" ]]; then
        local temp_file=$(mktemp)
        jq '.performance_metrics.failures = (.performance_metrics.failures // 0) + 1 | .last_failure = "'$(date -Iseconds)'"' "$agent_config" > "$temp_file"
        mv "$temp_file" "$agent_config"
    fi
}

# 记录任务重试
log_task_retry() {
    local task_id="$1"
    local failed_agent_id="$2"

    local retry_log="$AGENT_CONFIG_DIR/task-retries.log"

    echo "[$(date -Iseconds)] TASK_RETRY: $task_id - 原Agent: $failed_agent_id" >> "$retry_log"

    # 更新任务的重试计数
    local task_details=$(get_task_details "$task_id")
    local retry_count=$(echo "$task_details" | jq -r '.retry_count // 0')
    local new_retry_count=$((retry_count + 1))

    # 更新任务状态
    local task_queue_file="$AGENT_CONFIG_DIR/ai-agent-tasks-queue.json"
    local temp_file=$(mktemp)
    jq --arg task_id "$task_id" --argjson retry_count "$new_retry_count" '
        .queue = (.queue | map(if .task_id == $task_id then .retry_count = $retry_count else . end))
    ' "$task_queue_file" > "$temp_file"
    mv "$temp_file" "$task_queue_file"
}

# 发送故障告警
send_failure_alert() {
    local failed_agent_id="$1"
    local affected_tasks="$2"

    local alert_message="Agent $failed_agent_id 发生故障，影响 $affected_tasks 个任务"

    smart_echo "🔔 故障告警: $alert_message" "error"

    # 记录到系统日志
    local system_log="$AGENT_CONFIG_DIR/system-alerts.log"
    echo "[$(date -Iseconds)] ALERT: $alert_message" >> "$system_log"

    # 在实际系统中，这里可以集成邮件、Slack等通知服务
}

# 停止Agent健康监控
stop_agent_health_monitor() {
    local pid_file="$AGENT_CONFIG_DIR/health-monitor.pid"

    if [[ -f "$pid_file" ]]; then
        local monitor_pid=$(cat "$pid_file")
        if kill -0 "$monitor_pid" 2>/dev/null; then
            kill "$monitor_pid"
            smart_echo "Agent健康监控服务已停止" "info"
        fi
        rm -f "$pid_file"
    fi
}

# 获取系统健康状态
get_system_health_status() {
    local total_agents=$(ls "$AGENT_CONFIG_DIR"/*.json 2>/dev/null | grep -c "ai-agent-" || echo "0")
    local healthy_agents=0
    local unhealthy_agents=0

    for agent_config in "$AGENT_CONFIG_DIR"/*.json; do
        if [[ -f "$agent_config" && $(basename "$agent_config") =~ ^ai-agent- ]]; then
            local agent_id=$(basename "$agent_config" .json | sed 's/ai-agent-//')
            if check_agent_health_status "$agent_id"; then
                ((healthy_agents++))
            else
                ((unhealthy_agents++))
            fi
        fi
    done

    local health_score=0
    if (( total_agents > 0 )); then
        health_score=$(( healthy_agents * 100 / total_agents ))
    fi

    cat <<EOF
{
  "total_agents": $total_agents,
  "healthy_agents": $healthy_agents,
  "unhealthy_agents": $unhealthy_agents,
  "health_score": $health_score,
  "status": "$(if (( health_score >= 80 )); then echo "healthy"; elif (( health_score >= 60 )); then echo "warning"; else echo "critical"; fi)",
  "last_check": "$(date -Iseconds)"
}
EOF
}

# 显示容错系统状态
show_fault_tolerance_status() {
    smart_echo "=== 🛡️ 高可用容错系统状态 ===" "info"

    # 显示系统健康状态
    local health_status=$(get_system_health_status)
    local health_score=$(echo "$health_status" | jq -r '.health_score')
    local status=$(echo "$health_status" | jq -r '.status')

    smart_echo "系统健康评分: $health_score/100 ($status)" "info"

    # 显示健康监控状态
    local pid_file="$AGENT_CONFIG_DIR/health-monitor.pid"
    if [[ -f "$pid_file" ]]; then
        local monitor_pid=$(cat "$pid_file")
        if kill -0 "$monitor_pid" 2>/dev/null; then
            smart_echo "健康监控服务: 运行中 (PID: $monitor_pid)" "success"
        else
            smart_echo "健康监控服务: 已停止" "warning"
        fi
    else
        smart_echo "健康监控服务: 未启动" "warning"
    fi

    # 显示最近故障统计
    local failure_log="$AGENT_CONFIG_DIR/agent-failures.log"
    if [[ -f "$failure_log" ]]; then
        local recent_failures=$(tail -10 "$failure_log" | wc -l)
        smart_echo "最近故障记录: $recent_failures 条" "info"
    fi

    # 显示任务重试统计
    local retry_log="$AGENT_CONFIG_DIR/task-retries.log"
    if [[ -f "$retry_log" ]]; then
        local recent_retries=$(tail -10 "$retry_log" | wc -l)
        smart_echo "最近任务重试: $recent_retries 次" "info"
    fi
}

# 手动触发Agent恢复
manually_recover_agent() {
    local agent_id="$1"

    smart_echo "手动恢复Agent: $agent_id" "info"

    if attempt_agent_recovery "$agent_id"; then
        smart_echo "Agent $agent_id 手动恢复成功" "success"
        return 0
    else
        smart_echo "Agent $agent_id 手动恢复失败" "error"
        return 1
    fi
}

# 获取故障恢复建议
get_recovery_recommendations() {
    local agent_id="$1"

    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    local failure_log="$AGENT_CONFIG_DIR/agent-failures.log"

    # 分析故障模式
    local recent_failures=$(grep "$agent_id" "$failure_log" | tail -5 | wc -l)
    local failure_reasons=$(grep "$agent_id" "$failure_log" | tail -5 | cut -d'-' -f2 | sort | uniq -c | sort -nr)

    cat <<EOF
Agent $agent_id 故障分析报告:

最近5次故障: $recent_failures 次

主要故障原因:
$failure_reasons

建议恢复措施:
1. 检查Agent配置文件完整性
2. 重启Agent进程
3. 验证网络连接
4. 检查系统资源使用情况
5. 如问题持续，考虑更换到备用Agent
EOF
}

# 高可用容错机制函数
export -f start_agent_health_monitor
export -f perform_health_checks
export -f check_agent_health_status
export -f handle_unhealthy_agents
export -f attempt_agent_recovery
export -f trigger_failover
export -f find_agent_active_tasks
export -f reassign_failed_task
export -f log_agent_failure
export -f log_task_retry
export -f send_failure_alert
export -f stop_agent_health_monitor
export -f get_system_health_status
export -f show_fault_tolerance_status
export -f manually_recover_agent
export -f get_recovery_recommendations

# 🎯 任务状态持久化系统

# 扩展任务状态存储结构
create_extended_task_state() {
    local task_id="$1"
    local task_description="$2"
    local task_type="$3"
    local priority="${4:-normal}"

    # 生成扩展状态ID
    local state_id="state_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4)"

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

# 计算成功概率
calculate_success_probability() {
    local complexity_analysis="$1"
    local resource_assessment="$2"

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score // 50')
    local resource_cost=$(echo "$resource_assessment" | jq -r '.estimated_cost // 5')

    # 基于复杂度得分和资源成本计算成功概率
    # 复杂度越高、资源成本越高，成功概率越低
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

# 获取风险等级
get_risk_level() {
    local complexity_analysis="$1"
    local dependency_analysis="$2"

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score // 50')
    local dependency_count=$(echo "$dependency_analysis" | jq -r '.dependencies | length')

    if (( $(echo "$complexity_score >= 80" | bc -l 2>/dev/null || echo "0") )) && (( dependency_count >= 3 )); then
        echo "high"
    elif (( $(echo "$complexity_score >= 60" | bc -l 2>/dev/null || echo "0") )) || (( dependency_count >= 2 )); then
        echo "medium"
    else
        echo "low"
    fi
}

# 判断是否启用检查点
should_enable_checkpoint() {
    local complexity_analysis="$1"

    local complexity_score=$(echo "$complexity_analysis" | jq -r '.complexity_score // 50')
    local decomposition_needed=$(echo "$complexity_analysis" | jq -r '.decomposition_needed // false')

    # 复杂度高或需要分解的任务启用检查点
    if (( $(echo "$complexity_score >= 70" | bc -l 2>/dev/null || echo "0") )) || [[ "$decomposition_needed" == "true" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# 判断是否需要备份
should_require_backup() {
    local task_type="$1"
    local priority="$2"

    # 高优先级任务或关键任务类型需要备份
    if [[ "$priority" == "high" ]] || [[ "$priority" == "critical" ]]; then
        echo "true"
    elif [[ "$task_type" == "deployment" ]] || [[ "$task_type" == "coordination" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# 获取前置任务
get_predecessor_tasks() {
    local dependency_analysis="$1"

    # 从依赖分析中提取前置任务
    echo "$dependency_analysis" | jq -r '.dependencies[]? | select(.type == "task_type" or .type == "context") | .value' 2>/dev/null || echo "[]"
}

# 更新任务状态 (扩展版本)
update_task_state() {
    local task_id="$1"
    local new_status="$2"
    local reason="${3:-status_change}"
    local additional_data="${4:-{}}"

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"

    if [[ ! -f "$state_file" ]]; then
        smart_echo "任务状态文件不存在: $state_file" "error"
        return 1
    fi

    # 创建状态更新记录
    local status_update=$(cat <<EOF
{
  "status": "$new_status",
  "timestamp": "$(date -Iseconds)",
  "reason": "$reason",
  "additional_data": $additional_data
}
EOF
)

    # 原子性更新状态文件
    local temp_file=$(mktemp)
    jq --argjson update "$status_update" '
        .status = $update.status |
        .last_modified = $update.timestamp |
        .status_history += [$update] |
        .execution_context.progress_percentage = ($update.additional_data.progress_percentage // .execution_context.progress_percentage) |
        .execution_context.current_step = ($update.additional_data.current_step // .execution_context.current_step) |
        .execution_context.assigned_agent = ($update.additional_data.assigned_agent // .execution_context.assigned_agent) |
        .execution_context.start_time = ($update.additional_data.start_time // .execution_context.start_time) |
        .execution_context.end_time = ($update.additional_data.end_time // .execution_context.end_time) |
        .execution_context.actual_duration = ($update.additional_data.actual_duration // .execution_context.actual_duration)
    ' "$state_file" > "$temp_file"

    if [[ $? -eq 0 ]]; then
        mv "$temp_file" "$state_file"
        smart_echo "任务状态已更新: $task_id -> $new_status" "success"

        # 记录状态变更日志
        log_state_change "$task_id" "$new_status" "$reason"
    else
        smart_echo "任务状态更新失败: $task_id" "error"
        rm -f "$temp_file"
        return 1
    fi
}

# 记录状态变更
log_state_change() {
    local task_id="$1"
    local new_status="$2"
    local reason="$3"

    local log_file="$AGENT_CONFIG_DIR/state-changes.log"
    echo "[$(date -Iseconds)] STATE_CHANGE: $task_id -> $new_status ($reason)" >> "$log_file"
}

# 创建任务检查点
create_task_checkpoint() {
    local task_id="$1"
    local checkpoint_name="${2:-auto}"

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"
    local checkpoint_dir="$AGENT_CONFIG_DIR/task-checkpoints/${task_id}"
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

    if [[ ! -f "$checkpoint_file" ]]; then
        smart_echo "检查点文件不存在: $checkpoint_file" "error"
        return 1
    fi

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"
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

    local temp_file=$(mktemp)
    jq --argjson recovery "$recovery_record" '.status_history += [$recovery]' "$state_file" > "$temp_file"
    mv "$temp_file" "$state_file"

    smart_echo "任务已从检查点恢复: $task_id" "success"
}

# 获取任务状态历史
get_task_state_history() {
    local task_id="$1"

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"

    if [[ -f "$state_file" ]]; then
        jq '.status_history[]?' "$state_file" 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

# 验证任务状态完整性
validate_task_state() {
    local task_id="$1"

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"

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

    # 检查状态转换的合理性
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
        # 显示特定任务的状态
        show_single_task_state "$task_id"
    else
        # 显示所有任务的状态概览
        show_all_tasks_state_overview
    fi
}

# 显示单个任务状态
show_single_task_state() {
    local task_id="$1"

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"

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

    # 显示最近的状态历史
    smart_echo "最近状态变更:" "info"
    jq -r '.status_history[-3:][]? | "  \(.timestamp): \(.status) (\(.reason))"' "$state_file" 2>/dev/null || echo "  无状态历史"

    # 显示质量指标
    local success_prob=$(jq -r '.quality_metrics.success_probability' "$state_file")
    local risk_level=$(jq -r '.quality_metrics.risk_level' "$state_file")
    smart_echo "成功概率: ${success_prob}% | 风险等级: $risk_level" "info"
}

# 显示所有任务状态概览
show_all_tasks_state_overview() {
    local state_dir="$AGENT_CONFIG_DIR/task-states"
    local total_tasks=0
    local status_counts=$(cat <<EOF
{
  "created": 0,
  "pending": 0,
  "assigned": 0,
  "executing": 0,
  "completed": 0,
  "failed": 0
}
EOF
)

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

# 保存扩展任务状态
save_extended_task_state() {
    local task_id="$1"
    local extended_state="$2"

    local state_dir="$AGENT_CONFIG_DIR/task-states"
    local state_file="$state_dir/${task_id}.json"

    mkdir -p "$state_dir"
    echo "$extended_state" > "$state_file"

    smart_echo "扩展任务状态已保存: $task_id" "success"
}

# 加载扩展任务状态
load_extended_task_state() {
    local task_id="$1"

    local state_file="$AGENT_CONFIG_DIR/task-states/${task_id}.json"

    if [[ -f "$state_file" ]]; then
        cat "$state_file"
    else
        echo "{}"
    fi
}

# 任务状态持久化系统函数
export -f create_extended_task_state
export -f calculate_success_probability
export -f get_risk_level
export -f should_enable_checkpoint
export -f should_require_backup
export -f get_predecessor_tasks
export -f update_task_state
export -f log_state_change
export -f create_task_checkpoint
export -f restore_task_from_checkpoint
export -f get_task_state_history
export -f validate_task_state
export -f validate_state_transitions
export -f show_task_state_dashboard
export -f show_single_task_state
export -f show_all_tasks_state_overview
export -f save_extended_task_state
export -f load_extended_task_state

# 初始化
init_agent_orchestration_engine