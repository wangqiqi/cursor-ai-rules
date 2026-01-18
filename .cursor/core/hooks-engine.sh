#!/bin/bash
# 🚀 Cursor AI Rules 钩子执行引擎
# 执行基于 hooks.json 配置的钩子系统
# 支持异步执行、超时控制、错误处理等高级特性

set -euo pipefail

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[HOOKS-ENGINE]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[HOOKS-ENGINE]${NC} ✅ $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[HOOKS-ENGINE]${NC} ⚠️  $1" >&2
}

log_error() {
    echo -e "${RED}[HOOKS-ENGINE]${NC} ❌ $1" >&2
}

# 全局变量
HOOKS_CONFIG="$PROJECT_ROOT/.cursor/features/hooks/hooks.json"
LOG_DIR="$PROJECT_ROOT/.cursorGrowth/monitoring/logs"
PID_DIR="$PROJECT_ROOT/.cursorGrowth/monitoring/pids"
MAX_CONCURRENT_HOOKS=5
HOOK_EXECUTION_TIMEOUT=30000

# 初始化目录
init_directories() {
    mkdir -p "$LOG_DIR" "$PID_DIR"
}

# 检查 jq 依赖
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log_error "jq 命令未找到，请安装 jq 以使用钩子系统"
        return 1
    fi
    return 0
}

# 读取钩子配置
load_hooks_config() {
    if [ ! -f "$HOOKS_CONFIG" ]; then
        log_error "钩子配置文件不存在: $HOOKS_CONFIG"
        return 1
    fi

    # 验证 JSON 格式
    if ! jq empty "$HOOKS_CONFIG" 2>/dev/null; then
        log_error "钩子配置文件 JSON 格式错误"
        return 1
    fi

    echo "$HOOKS_CONFIG"
}

# 获取指定触发器的钩子列表
get_hooks_for_trigger() {
    local trigger="$1"
    local config_file="$2"

    jq -r ".hooks.\"$trigger\"[]? | select(.enabled == true) | @base64" "$config_file" 2>/dev/null || true
}

# 解码钩子配置
decode_hook_config() {
    local encoded_hook="$1"
    echo "$encoded_hook" | base64 -d | jq -r '.'
}

# 执行单个钩子（异步）
execute_hook_async() {
    local hook_config="$1"
    local trigger="$2"
    local execution_id="$3"

    local hook_name=$(echo "$hook_config" | jq -r '.name')
    local command=$(echo "$hook_config" | jq -r '.command')
    local timeout=$(echo "$hook_config" | jq -r '.timeout // 10000')
    local async=$(echo "$hook_config" | jq -r '.async // true')

    local log_file="$LOG_DIR/${trigger}_${hook_name}_${execution_id}.log"
    local pid_file="$PID_DIR/${trigger}_${hook_name}_${execution_id}.pid"

    log_info "开始执行钩子: $hook_name (触发器: $trigger)"

    # 构建完整命令路径
    local full_command="$PROJECT_ROOT/.cursor/$command"
    if [ ! -f "$full_command" ]; then
        log_error "钩子脚本不存在: $full_command"
        echo "{\"status\": \"error\", \"hook\": \"$hook_name\", \"error\": \"script not found\"}" >> "$log_file"
        return 1
    fi

    # 检查脚本执行权限
    if [ ! -x "$full_command" ]; then
        log_error "钩子脚本没有执行权限: $full_command"
        echo "{\"status\": \"error\", \"hook\": \"$hook_name\", \"error\": \"no execute permission\"}" >> "$log_file"
        return 1
    fi

    # 异步执行钩子
    {
        local start_time=$(date +%s%3N)
        local exit_code=0
        local output=""
        local error_output=""

        # 设置超时
        timeout $((timeout / 1000)) bash "$full_command" > >(tee >(jq -R '{output: .}' >> "$log_file" 2>/dev/null || echo "{\"output\": \"$output\"}" >> "$log_file")) 2> >(tee >(jq -R '{error: .}' >> "$log_file" 2>/dev/null || echo "{\"error\": \"$error_output\"}" >> "$log_file")) || exit_code=$?

        local end_time=$(date +%s%3N)
        local duration=$((end_time - start_time))

        # 记录执行结果
        if [ $exit_code -eq 0 ]; then
            log_success "钩子执行成功: $hook_name (${duration}ms)"
            echo "{\"status\": \"success\", \"hook\": \"$hook_name\", \"duration\": $duration, \"exit_code\": $exit_code}" >> "$log_file"
        else
            log_error "钩子执行失败: $hook_name (${duration}ms, 退出码: $exit_code)"
            echo "{\"status\": \"error\", \"hook\": \"$hook_name\", \"duration\": $duration, \"exit_code\": $exit_code}" >> "$log_file"
        fi

        # 清理 PID 文件
        rm -f "$pid_file"

    } &
    local hook_pid=$!
    echo $hook_pid > "$pid_file"

    log_info "钩子 $hook_name 已启动 (PID: $hook_pid)"
}

# 等待钩子执行完成（带超时）
wait_for_hooks() {
    local execution_id="$1"
    local max_wait_time=$((HOOK_EXECUTION_TIMEOUT / 1000))

    log_info "等待钩子执行完成 (最多等待 ${max_wait_time}s)..."

    local start_time=$(date +%s)
    local completed=0
    local total=0

    # 统计钩子数量
    total=$(find "$PID_DIR" -name "*_${execution_id}.pid" 2>/dev/null | wc -l)

    while [ $(date +%s) -lt $((start_time + max_wait_time)) ]; do
        local running=$(find "$PID_DIR" -name "*_${execution_id}.pid" 2>/dev/null | wc -l)

        if [ $running -eq 0 ]; then
            completed=1
            break
        fi

        log_info "还有 $running 个钩子正在执行..."
        sleep 1
    done

    if [ $completed -eq 0 ]; then
        log_warning "钩子执行超时，强制终止剩余进程"

        # 终止所有相关进程
        for pid_file in "$PID_DIR"/*_"${execution_id}".pid; do
            if [ -f "$pid_file" ]; then
                local pid=$(cat "$pid_file")
                kill -TERM $pid 2>/dev/null || true
                rm -f "$pid_file"
            fi
        done
    fi

    log_success "所有钩子执行完成"
}

# 获取全局配置
get_global_config() {
    local config_file="$1"
    jq -r '.global_config // {}' "$config_file" 2>/dev/null || echo "{}"
}

# 主执行函数
execute_hooks_for_trigger() {
    local trigger="$1"
    local config_file="$2"

    log_info "触发钩子执行器: $trigger"

    # 初始化
    init_directories
    check_dependencies || return 1

    # 生成执行ID
    local execution_id=$(date +%s)_$$

    log_info "执行ID: $execution_id"

    # 获取要执行的钩子
    local hooks_data=$(get_hooks_for_trigger "$trigger" "$config_file")

    if [ -z "$hooks_data" ]; then
        log_info "没有为触发器 '$trigger' 配置启用的钩子"
        return 0
    fi

    local hook_count=0
    local running_hooks=0

    # 执行每个钩子
    echo "$hooks_data" | while read -r encoded_hook; do
        if [ -z "$encoded_hook" ]; then
            continue
        fi

        # 控制并发数量
        while [ $running_hooks -ge $MAX_CONCURRENT_HOOKS ]; do
            sleep 0.5
            running_hooks=$(find "$PID_DIR" -name "*_${execution_id}.pid" 2>/dev/null | wc -l)
        done

        local hook_config=$(decode_hook_config "$encoded_hook")
        local async=$(echo "$hook_config" | jq -r '.async // true')

        if [ "$async" = "true" ]; then
            execute_hook_async "$hook_config" "$trigger" "$execution_id"
            ((running_hooks++))
        else
            # 同步执行
            local hook_name=$(echo "$hook_config" | jq -r '.name')
            log_info "同步执行钩子: $hook_name"

            local full_command="$PROJECT_ROOT/.cursor/$(echo "$hook_config" | jq -r '.command')"
            if [ -x "$full_command" ]; then
                bash "$full_command"
                log_success "同步钩子执行完成: $hook_name"
            else
                log_error "同步钩子脚本无法执行: $full_command"
            fi
        fi

        ((hook_count++))
    done

    log_info "已启动 $hook_count 个钩子"

    # 等待异步钩子完成
    if [ $running_hooks -gt 0 ]; then
        wait_for_hooks "$execution_id"
    fi

    log_success "触发器 '$trigger' 的钩子执行完成"
}

# 显示帮助信息
show_help() {
    cat << EOF
🚀 Cursor AI Rules 钩子执行引擎

用法:
    $0 <trigger> [config_file]

参数:
    trigger      触发器名称 (如: onSessionStart, afterFileSave 等)
    config_file  钩子配置文件路径 (可选，默认为 $HOOKS_CONFIG)

示例:
    $0 onSessionStart
    $0 afterFileSave /path/to/custom/hooks.json

支持的触发器:
    - onSessionStart: 会话开始时
    - afterFileSave: 文件保存后
    - afterShellExecution: Shell执行后
    - afterAgentResponse: AI响应后
    - beforeSubmitPrompt: 提交提示前
    - preCommitAnalysis: 预提交分析
    - commitMessageValidation: 提交消息验证
    - preCommitOptimization: 预提交优化
    - postCommitLogging: 后提交日志
    - onSessionEnd: 会话结束时
    - onEnvironmentChange: 环境变化时
    - performanceReportGeneration: 性能报告生成
    - onDebugSessionStart: 调试会话开始时
    - onErrorDetected: 错误检测时
    - tokenOptimization: Token优化
    - qualityReportGeneration: 质量报告生成
    - onComplexConversation: 复杂对话时

EOF
}

# 主函数
main() {
    local trigger="${1:-}"
    local config_file="${2:-$HOOKS_CONFIG}"

    if [ -z "$trigger" ] || [ "$trigger" = "--help" ] || [ "$trigger" = "-h" ]; then
        show_help
        exit 0
    fi

    # 验证触发器名称
    case "$trigger" in
        onSessionStart|afterFileSave|afterShellExecution|afterAgentResponse|beforeSubmitPrompt|preCommitAnalysis|commitMessageValidation|preCommitOptimization|postCommitLogging|onSessionEnd|onEnvironmentChange|performanceReportGeneration|onDebugSessionStart|onErrorDetected|tokenOptimization|qualityReportGeneration|onComplexConversation)
            ;;
        *)
            log_error "无效的触发器名称: $trigger"
            log_info "运行 '$0 --help' 查看支持的触发器列表"
            exit 1
            ;;
    esac

    # 执行钩子
    execute_hooks_for_trigger "$trigger" "$config_file"
}

# 如果脚本被直接调用，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi