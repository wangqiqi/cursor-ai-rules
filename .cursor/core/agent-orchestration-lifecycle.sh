#!/bin/bash
# ========================================
# Cursor AI Rules - Agent生命周期管理模块
# 负责Agent的创建、初始化、终止和状态管理
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"

# =============================================================================
# Agent生命周期管理模块 - 基础层
# =============================================================================

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

# 终止Agent实例
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

# 挂起Agent
suspend_agent() {
    local agent_id="$1"
    local reason="${2:-maintenance}"

    smart_echo "挂起Agent: $agent_id (原因: $reason)" "processing"

    # 设置Agent状态为挂起
    update_agent_status "$agent_id" "suspended"

    # 执行挂起逻辑
    suspend_agent_operations "$agent_id" "$reason"

    smart_echo "Agent已挂起: $agent_id" "success"
    return 0
}

# 恢复Agent
resume_agent() {
    local agent_id="$1"

    smart_echo "恢复Agent: $agent_id" "processing"

    # 执行恢复逻辑
    if ! resume_agent_operations "$agent_id"; then
        smart_echo "Agent恢复失败: $agent_id" "error"
        return 1
    fi

    # 设置Agent状态为空闲
    update_agent_status "$agent_id" "idle"

    smart_echo "Agent恢复完成: $agent_id" "success"
    return 0
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

# 注册Agent
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

# =============================================================================
# 内部辅助函数
# =============================================================================

# 验证Agent配置
validate_agent_config() {
    local agent_id="$1"
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"

    [[ -f "$agent_config" ]] && jq empty "$agent_config" >/dev/null 2>&1
}

# 更新Agent状态
update_agent_status() {
    local agent_id="$1"
    local new_status="$2"
    # TODO: 实现状态更新逻辑，迁移自原agent-orchestration-engine.sh
    smart_echo "Agent状态更新: $agent_id -> $new_status" "info"
}

# 挂起Agent操作
suspend_agent_operations() {
    local agent_id="$1"
    local reason="$2"
    # TODO: 实现挂起逻辑
    smart_echo "挂起Agent操作: $agent_id" "info"
}

# 恢复Agent操作
resume_agent_operations() {
    local agent_id="$1"
    # TODO: 实现恢复逻辑
    smart_echo "恢复Agent操作: $agent_id" "info"
    return 0
}

# 检查Agent配置文件是否存在
agent_config_exists() {
    local agent_id="$1"
    local agent_config="$AGENT_CONFIG_DIR/ai-agent-${agent_id}.json"
    [[ -f "$agent_config" ]]
}

# 检查Agent进程是否运行
agent_process_running() {
    local agent_id="$1"
    # TODO: 实现进程检查逻辑
    true
}

# 检查Agent是否有错误
agent_has_errors() {
    local agent_id="$1"
    # TODO: 实现错误检查逻辑
    false
}

# =============================================================================
# 函数导出
# =============================================================================

export -f initialize_agent
export -f initialize_agent_specific
export -f terminate_agent
export -f terminate_agent_specific
export -f suspend_agent
export -f resume_agent
export -f check_agent_health
export -f register_agent
export -f unregister_agent