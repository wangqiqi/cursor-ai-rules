#!/bin/bash
# ========================================
# Cursor AI Rules - 统一CLI框架
# 为所有脚本提供标准化的命令行接口
# ========================================

# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"

# =============================================================================
# CLI框架配置
# =============================================================================

# CLI框架版本
CLI_FRAMEWORK_VERSION="1.0.0"

# 全局CLI变量
CLI_COMMAND=""
CLI_ARGS=()
CLI_FLAGS=()
CLI_VERBOSE=false
CLI_QUIET=false
CLI_DRY_RUN=false
CLI_JSON_OUTPUT=false
CLI_EXIT_CODE=0

source "$SCRIPT_DIR/colors.sh"

# =============================================================================
# CLI框架核心函数
# =============================================================================

# 解析命令行参数
# 用法: parse_cli_args "$@"
parse_cli_args() {
    CLI_COMMAND=""
    CLI_ARGS=()
    CLI_FLAGS=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                CLI_FLAGS+=("help")
                shift
                ;;
            -v|--verbose)
                CLI_VERBOSE=true
                CLI_FLAGS+=("verbose")
                shift
                ;;
            -q|--quiet)
                CLI_QUIET=true
                CLI_FLAGS+=("quiet")
                shift
                ;;
            --dry-run)
                CLI_DRY_RUN=true
                CLI_FLAGS+=("dry-run")
                shift
                ;;
            --json)
                CLI_JSON_OUTPUT=true
                CLI_FLAGS+=("json")
                shift
                ;;
            --version)
                CLI_FLAGS+=("version")
                shift
                ;;
            -*)
                cli_error "未知选项: $1"
                return 1
                ;;
            *)
                if [[ -z "$CLI_COMMAND" ]]; then
                    CLI_COMMAND="$1"
                else
                    CLI_ARGS+=("$1")
                fi
                shift
                ;;
        esac
    done

    # 如果没有命令但有help标志，显示帮助
    if [[ -z "$CLI_COMMAND" && " ${CLI_FLAGS[*]} " == *" help "* ]]; then
        CLI_COMMAND="help"
    fi
}

# CLI日志输出函数
cli_log() {
    local level="$1"
    local message="$2"
    local color="$NC"

    # 如果是quiet模式且不是错误消息，不输出
    if [[ "$CLI_QUIET" == true && "$level" != "error" && "$level" != "success" ]]; then
        return
    fi

    case "$level" in
        "info")
            [[ "$CLI_VERBOSE" == true ]] && color="$BLUE"
            ;;
        "success")
            color="$GREEN"
            ;;
        "warning")
            color="$YELLOW"
            ;;
        "error")
            color="$RED"
            ;;
        "debug")
            [[ "$CLI_VERBOSE" == true ]] && color="$PURPLE"
            ;;
        *)
            color="$NC"
            ;;
    esac

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        # JSON输出格式
        echo "{\"level\":\"$level\",\"message\":\"$message\",\"timestamp\":\"$(date -Iseconds)\"}"
    else
        # 彩色文本输出
        echo -e "${color}${message}${NC}"
    fi
}

# 便捷的日志函数
cli_info() { cli_log "info" "$1"; }
cli_success() { cli_log "success" "✅ $1"; }
cli_warning() { cli_log "warning" "⚠️  $1"; }
cli_error() { cli_log "error" "❌ $1"; }
cli_debug() { cli_log "debug" "🔍 $1"; }

# 统一的错误处理
cli_handle_error() {
    local error_msg="$1"
    local exit_code="${2:-1}"

    cli_error "$error_msg"
    CLI_EXIT_CODE=$exit_code
}

# 验证必需的命令
cli_validate_command() {
    local valid_commands=("$@")

    if [[ -z "$CLI_COMMAND" ]]; then
        cli_error "未指定命令。使用 --help 查看可用命令。"
        return 1
    fi

    for cmd in "${valid_commands[@]}"; do
        if [[ "$CLI_COMMAND" == "$cmd" ]]; then
            return 0
        fi
    done

    cli_error "未知命令: $CLI_COMMAND"
    cli_info "可用命令: ${valid_commands[*]}"
    return 1
}

# 标准化的帮助输出
# 用法: cli_show_help "脚本名称" "脚本描述" command_definitions...
cli_show_help() {
    local script_name="$1"
    local description="$2"
    shift 2

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        # JSON格式帮助
        local commands_json="[]"
        while [[ $# -gt 0 ]]; do
            local cmd_name="$1"
            local cmd_desc="$2"
            shift 2

            commands_json=$(echo "$commands_json" | jq ". += {\"name\":\"$cmd_name\",\"description\":\"$cmd_desc\"}")
        done

        cat << EOF
{
  "script": "$script_name",
  "description": "$description",
  "version": "$CLI_FRAMEWORK_VERSION",
  "commands": $commands_json,
  "global_options": [
    {"name": "-h, --help", "description": "显示此帮助信息"},
    {"name": "-v, --verbose", "description": "详细输出"},
    {"name": "-q, --quiet", "description": "静默模式"},
    {"name": "--dry-run", "description": "仅显示将要执行的操作"},
    {"name": "--json", "description": "JSON格式输出"},
    {"name": "--version", "description": "显示版本信息"}
  ]
}
EOF
    else
        # 文本格式帮助
        cat << EOF
${CYAN}${script_name}${NC} - ${description}

${YELLOW}用法:${NC}
  $0 <command> [options] [args...]

${YELLOW}全局选项:${NC}
  -h, --help       显示此帮助信息
  -v, --verbose    详细输出
  -q, --quiet      静默模式
  --dry-run        仅显示将要执行的操作
  --json           JSON格式输出
  --version        显示版本信息

${YELLOW}可用命令:${NC}
EOF

        while [[ $# -gt 0 ]]; do
            local cmd_name="$1"
            local cmd_desc="$2"
            printf "  %-15s %s\n" "$cmd_name" "$cmd_desc"
            shift 2
        done

        echo ""
        echo "${YELLOW}示例:${NC}"
        echo "  $0 --help          # 显示帮助"
        echo "  $0 --version       # 显示版本"
        echo "  $0 <command> -v    # 详细模式执行命令"
    fi
}

# 显示版本信息
cli_show_version() {
    local script_name="$1"

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        cat << EOF
{
  "script": "$script_name",
  "framework_version": "$CLI_FRAMEWORK_VERSION",
  "timestamp": "$(date -Iseconds)"
}
EOF
    else
        echo "$script_name CLI框架 v$CLI_FRAMEWORK_VERSION"
        echo "构建时间: $(date)"
    fi
}

# 确认操作 (用于危险操作)
cli_confirm() {
    local message="$1"
    local default="${2:-no}"

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] $message (跳过确认)"
        return 0
    fi

    local prompt
    if [[ "$default" == "yes" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi

    echo -n "$prompt"
    read -r response

    # 默认值处理
    if [[ -z "$response" ]]; then
        response="$default"
    fi

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            cli_warning "操作已取消"
            return 1
            ;;
    esac
}

# =============================================================================
# 标准化脚本模板函数
# =============================================================================

# 标准化的main函数模板
# 用法: 在脚本中使用此函数作为main函数的基础
cli_main_template() {
    local script_name="$1"
    local script_description="$2"
    local valid_commands=("${@:3}")

    # 解析命令行参数
    parse_cli_args "$@" || return 1

    # 处理全局标志
    for flag in "${CLI_FLAGS[@]}"; do
        case "$flag" in
            "help")
                cli_show_help "$script_name" "$script_description" "${valid_commands[@]}"
                return 0
                ;;
            "version")
                cli_show_version "$script_name"
                return 0
                ;;
        esac
    done

    # 验证命令
    cli_validate_command "${valid_commands[@]}" || return 1

    # 设置输出模式
    if [[ "$CLI_QUIET" == true ]]; then
        exec >/dev/null 2>&1
    fi

    cli_debug "CLI框架初始化完成"
    cli_debug "命令: $CLI_COMMAND"
    cli_debug "参数: ${CLI_ARGS[*]}"
    cli_debug "标志: ${CLI_FLAGS[*]}"

    return 0
}

# =============================================================================
# 兼容性函数 (向后兼容现有脚本)
# =============================================================================

# 兼容现有脚本的日志函数
log_info() { cli_info "$1"; }
log_success() { cli_success "$1"; }
log_warning() { cli_warning "$1"; }
log_error() { cli_error "$1"; }
log_debug() { cli_debug "$1"; }

# 兼容现有的smart_echo函数
smart_echo() {
    local message="$1"
    local type="${2:-info}"

    case "$type" in
        "success")
            cli_success "$message"
            ;;
        "warning")
            cli_warning "$message"
            ;;
        "error")
            cli_error "$message"
            ;;
        "debug")
            cli_debug "$message"
            ;;
        *)
            cli_info "$message"
            ;;
    esac
}

# =============================================================================
# 输出格式化函数
# =============================================================================

# 格式化列表输出
cli_format_list() {
    local title="$1"
    shift

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        local items_json="[]"
        for item in "$@"; do
            items_json=$(echo "$items_json" | jq ". += \"$item\"")
        done

        cat << EOF
{
  "type": "list",
  "title": "$title",
  "items": $items_json
}
EOF
    else
        echo ""
        echo "${CYAN}${title}${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for item in "$@"; do
            echo "  • $item"
        done
        echo ""
    fi
}

# 格式化表格输出
cli_format_table() {
    local headers=("$@")

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        # JSON格式暂时不支持复杂表格
        cli_warning "表格输出在JSON模式下不可用"
        return 1
    fi

    # 这里可以实现文本表格格式化
    # 暂时保持简单
    echo "表格功能待实现"
}

# =============================================================================
# 脚本生命周期管理
# =============================================================================

# 脚本初始化
cli_init() {
    local script_name="$1"

    # 验证项目上下文
    if ! validate_project_context; then
        cli_error "项目上下文验证失败"
        return 1
    fi

    # 设置脚本标识
    SCRIPT_NAME="$script_name"
    export SCRIPT_NAME

    cli_debug "脚本初始化完成: $script_name"
}

# 脚本清理
cli_cleanup() {
    local exit_code="$1"

    # 清理临时文件等
    cli_debug "脚本清理完成"

    # 返回正确的退出码
    return "${exit_code:-$CLI_EXIT_CODE}"
}

# =============================================================================
# 如果直接运行此脚本，显示帮助
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 解析CLI参数
    parse_cli_args "$@" || exit 1

    # 处理全局标志
    for flag in "${CLI_FLAGS[@]}"; do
        case "$flag" in
            "help")
                cli_show_help "CLI Framework" "统一CLI框架" \
                    "test" "测试CLI功能" \
                    "version" "显示版本信息"
                exit 0
                ;;
            "version")
                cli_show_version "CLI Framework"
                exit 0
                ;;
        esac
    done

    # 验证命令
    cli_validate_command "test" "version" || exit 1

    # 执行命令
    case "$CLI_COMMAND" in
        "test")
            cli_info "CLI框架测试"
            cli_success "成功消息测试"
            cli_warning "警告消息测试"
            cli_error "错误消息测试"
            cli_debug "调试消息测试"

            cli_format_list "测试列表" "项目1" "项目2" "项目3"

            cli_confirm "这是一个测试确认" || cli_info "用户取消了"
            ;;
        "version"|*)
            cli_show_version "CLI Framework"
            ;;
    esac
fi