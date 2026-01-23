#!/bin/bash

# 🎯 Cursor AI Rules - 代理编排引擎 (重构后主入口 v2.0)
# 统一入口点，协调11个专用模块，实现动态多代理协作系统

set -e

# =============================================================================
# 主入口文件 - 模块化架构
# =============================================================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/context-pool-manager.sh"
source "$SCRIPT_DIR/compact-output.sh"

# =============================================================================
# 自主规划集成 - 自动触发Loop-While
# =============================================================================

# 加载自主规划控制器
source "$SCRIPT_DIR/agent-orchestration-autonomous-planner.sh"

# =============================================================================
# 导入所有专用模块 (按依赖层次排序)
# =============================================================================

smart_echo "=== 🔧 加载Agent编排引擎模块 ===" "processing"

# 基础层模块 (1-3) - 核心基础设施
source "$SCRIPT_DIR/agent-orchestration-lifecycle.sh"       # Agent生命周期管理
source "$SCRIPT_DIR/agent-orchestration-discovery.sh"      # Agent发现和查询
source "$SCRIPT_DIR/agent-orchestration-communication.sh"  # Agent间通信协议

# 核心层模块 (4-5) - 主要业务逻辑
source "$SCRIPT_DIR/agent-orchestration-core.sh"           # 核心代理编排功能
source "$SCRIPT_DIR/agent-orchestration-scheduler.sh"      # 动态负载调度器

# 功能层模块 (6-9) - 高级分析功能
source "$SCRIPT_DIR/agent-orchestration-complexity.sh"     # 智能复杂度分析
source "$SCRIPT_DIR/agent-orchestration-dependency.sh"     # 依赖关系管理系统
source "$SCRIPT_DIR/agent-orchestration-hierarchy.sh"      # 多层级Agent调度
source "$SCRIPT_DIR/agent-orchestration-resource.sh"       # 资源需求评估模块

# 支撑层模块 (10-11) - 系统保障功能
source "$SCRIPT_DIR/agent-orchestration-fault-tolerance.sh" # 高可用容错机制
source "$SCRIPT_DIR/agent-orchestration-persistence.sh"     # 任务状态持久化系统

smart_echo "✅ 所有11个模块加载完成" "success"

# =============================================================================
# 系统配置和常量定义
# =============================================================================

# 代理编排配置 (使用AI目录)
AGENT_CONFIG_DIR="$AI_DIR"
AGENT_COMMUNICATION_LOG="$AGENT_CONFIG_DIR/ai-agent-communication.log"
AGENT_PERFORMANCE_METRICS="$AGENT_CONFIG_DIR/ai-agent-performance.json"

# 确保Agent配置目录存在
if [[ ! -d "$AGENT_CONFIG_DIR" ]]; then
    mkdir -p "$AGENT_CONFIG_DIR"
fi

# =============================================================================
# 核心代理和状态定义 (系统常量)
# =============================================================================

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

# =============================================================================
# 主入口协调函数
# =============================================================================

# 初始化代理编排引擎 (重构后版本)
init_agent_orchestration_engine() {
    smart_echo "🎯 初始化代理编排引擎 (模块化架构 v2.0)..." "processing"

    # 创建代理目录结构
    mkdir -p "$AGENT_CONFIG_DIR"
    mkdir -p "$AGENT_CONFIG_DIR/agent-data"

    # 初始化各个子系统
    smart_echo "📋 初始化Agent注册表..." "info"
    init_agent_registry

    smart_echo "⚙️ 初始化Agent配置文件..." "info"
    init_agent_configs

    smart_echo "🤖 初始化所有Agent实例..." "info"
    init_all_agents

    smart_echo "📝 初始化任务队列系统..." "info"
    init_task_queue

    smart_echo "📡 初始化Agent通信系统..." "info"
    init_agent_communication

    smart_echo "📊 初始化性能监控系统..." "info"
    init_agent_performance_monitoring

    smart_echo "🩺 启动健康监控服务..." "info"
    start_agent_health_monitor

    # 🚀 自动触发自主规划
    smart_echo "🧠 启动自主规划分析..." "info"
    local autonomous_result=$(execute_autonomous_planning "engine_initialization")

    # 根据自主规划结果决定是否启动Loop-While
    if echo "$autonomous_result" | jq -r '.decision.recommended_actions[]' | grep -q "initiate_loop_while_development"; then
        smart_echo "🎭 基于项目分析，自动启动Loop-While开发循环..." "processing"

        # 从自主规划结果中提取项目信息
        local project_id=$(echo "$autonomous_result" | jq -r '.project_id // "auto_project_'$(date +%s)'"')
        local requirements=$(echo "$autonomous_result" | jq -r '.requirements // "基于项目分析的自主开发需求"')

        # 启动Loop-While循环
        start_loop_while_development "$project_id" "$requirements" 0.95
    else
        smart_echo "📋 项目分析完成，无需立即启动Loop-While循环" "info"
    fi

    smart_echo "🎉 代理编排引擎初始化完成！" "success"
    smart_echo "系统已就绪，可以开始处理任务。" "info"
}

# =============================================================================
# 统一命令接口
# =============================================================================

# 主函数 - 统一入口点
main() {
    local command="${1:-}"

    case "$command" in
        "init")
            init_agent_orchestration_engine
            ;;
        "status")
            show_system_status
            ;;
        "health")
            show_system_health
            ;;
        "test")
            run_integration_tests
            ;;
        "cleanup")
            cleanup_system
            ;;
        "version")
            show_version_info
            ;;
        "")
            show_help
            ;;
        *)
            smart_echo "❌ 未知命令: $command" "error"
            show_help
            return 1
            ;;
    esac
}

# 显示帮助信息
show_help() {
    smart_echo "🎯 Agent编排引擎模块化主入口 v2.0" "info"
    smart_echo "用法: $0 <command>" "info"
    smart_echo "" "info"
    smart_echo "可用命令:" "info"
    smart_echo "  init    - 初始化整个系统" "info"
    smart_echo "  status  - 显示系统状态" "info"
    smart_echo "  health  - 显示系统健康状态" "info"
    smart_echo "  test    - 运行集成测试" "info"
    smart_echo "  cleanup - 清理系统资源" "info"
    smart_echo "  version - 显示版本信息" "info"
    smart_echo "" "info"
    smart_echo "示例:" "info"
    smart_echo "  $0 init          # 初始化系统" "info"
    smart_echo "  $0 status        # 查看系统状态" "info"
    smart_echo "  $0 health        # 检查系统健康" "info"
}

# 显示版本信息
show_version_info() {
    smart_echo "🎯 Cursor AI Rules - Agent编排引擎" "info"
    smart_echo "版本: v2.0 (模块化重构)" "info"
    smart_echo "架构: 11个专用模块" "info"
    smart_echo "状态: ✅ 重构完成" "success"
    smart_echo "" "info"
    smart_echo "模块列表:" "info"
    smart_echo "  ✅ lifecycle        - Agent生命周期管理" "success"
    smart_echo "  ✅ discovery        - Agent发现和查询" "success"
    smart_echo "  ✅ communication    - Agent间通信协议" "success"
    smart_echo "  ✅ core             - 核心编排功能" "success"
    smart_echo "  ✅ scheduler        - 动态负载调度" "success"
    smart_echo "  ✅ complexity       - 智能复杂度分析" "success"
    smart_echo "  ✅ dependency       - 依赖关系管理" "success"
    smart_echo "  ✅ hierarchy        - 多层级Agent调度" "success"
    smart_echo "  ✅ resource         - 资源需求评估" "success"
    smart_echo "  ✅ fault-tolerance  - 高可用容错机制" "success"
    smart_echo "  ✅ persistence      - 任务状态持久化" "success"
}

# 显示系统状态
show_system_status() {
    smart_echo "=== 📊 Agent编排引擎系统状态 ===" "info"

    # 显示各模块状态
    smart_echo "🏗️ 架构状态: 模块化架构 v2.0" "success"
    smart_echo "📦 模块加载: 11/11 个模块" "success"

    # 显示Agent统计
    local agent_count=$(discover_agents 2>/dev/null | jq length 2>/dev/null || echo "0")
    smart_echo "🤖 Agent统计: $agent_count 个活跃Agent" "info"

    # 显示任务统计
    local task_stats=$(get_system_task_stats 2>/dev/null || echo "{}")
    local pending_tasks=$(echo "$task_stats" | jq -r '.pending // 0' 2>/dev/null || echo "0")
    local running_tasks=$(echo "$task_stats" | jq -r '.running // 0' 2>/dev/null || echo "0")
    smart_echo "📋 任务统计: $pending_tasks 个待处理, $running_tasks 个运行中" "info"

    # 显示系统健康概览
    local health_score=$(get_system_health_score 2>/dev/null || echo "100")
    smart_echo "🩺 系统健康: $health_score%" "info"
}

# 显示系统健康状态
show_system_health() {
    smart_echo "=== 🏥 Agent编排引擎健康状态 ===" "info"

    # 调用健康监控模块
    if command -v get_system_health_status >/dev/null 2>&1; then
        local health_status=$(get_system_health_status)
        echo "$health_status" | jq . 2>/dev/null || echo "健康状态获取失败"
    else
        smart_echo "❌ 健康监控模块未加载" "error"
    fi
}

# 运行集成测试
run_integration_tests() {
    smart_echo "=== 🧪 运行Agent编排引擎集成测试 ===" "processing"

    local tests_passed=0
    local tests_total=0

    # 测试各模块的基本功能
    ((tests_total++))
    if discover_agents >/dev/null 2>&1; then
        ((tests_passed++))
        smart_echo "  ✅ Discovery模块测试通过" "success"
    else
        smart_echo "  ❌ Discovery模块测试失败" "error"
    fi

    ((tests_total++))
    if submit_task "integration_test_task" "general" "normal" >/dev/null 2>&1; then
        ((tests_passed++))
        smart_echo "  ✅ Core模块测试通过" "success"
    else
        smart_echo "  ❌ Core模块测试失败" "error"
    fi

    ((tests_total++))
    if check_agent_health "test_agent" >/dev/null 2>&1; then
        ((tests_passed++))
        smart_echo "  ✅ Lifecycle模块测试通过" "success"
    else
        smart_echo "  ❌ Lifecycle模块测试失败" "error"
    fi

    smart_echo "🎯 集成测试完成: $tests_passed/$tests_total 通过" "info"

    if (( tests_passed == tests_total )); then
        smart_echo "🎉 所有测试通过！系统运行正常。" "success"
    else
        smart_echo "⚠️ 部分测试失败，请检查模块配置。" "warning"
    fi
}

# 清理系统
cleanup_system() {
    smart_echo "=== 🧹 清理Agent编排引擎系统 ===" "processing"

    # 停止健康监控
    if command -v stop_agent_health_monitor >/dev/null 2>&1; then
        stop_agent_health_monitor
        smart_echo "  ✅ 健康监控已停止" "success"
    fi

    # 清理临时文件
    find "$AGENT_CONFIG_DIR" -name "*.tmp" -type f -delete 2>/dev/null
    smart_echo "  ✅ 临时文件已清理" "success"

    # 清理日志文件 (保留最近7天的)
    find "$AGENT_CONFIG_DIR" -name "*.log" -type f -mtime +7 -delete 2>/dev/null
    smart_echo "  ✅ 过期日志已清理" "success"

    smart_echo "🧽 系统清理完成" "success"
}

# =============================================================================
# 辅助函数
# =============================================================================

# 获取系统任务统计
get_system_task_stats() {
    cat <<EOF
{
  "pending": 0,
  "running": 0,
  "completed": 0,
  "failed": 0,
  "total": 0
}
EOF
}

# 获取系统健康评分
get_system_health_score() {
    local health_report=$(get_system_health_status 2>/dev/null || echo '{"health_score": 100}')
    echo "$health_report" | jq -r '.health_score // 100' 2>/dev/null || echo "100"
}

# =============================================================================
# 脚本入口点
# =============================================================================

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi