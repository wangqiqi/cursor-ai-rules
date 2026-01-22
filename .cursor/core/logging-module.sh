#!/bin/bash
# ========================================
# Cursor AI Rules - 日志记录模块
# 统一的日志记录和输出格式化功能
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/cli-framework.sh"

# =============================================================================
# 日志模块配置
# =============================================================================

# 日志级别
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_ERROR=3
LOG_LEVEL_SUCCESS=4

# 当前日志级别 (默认INFO)
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO

# 日志文件配置
LOG_FILE=""
LOG_MAX_SIZE=10485760  # 10MB
LOG_BACKUP_COUNT=5

# =============================================================================
# 日志核心函数
# =============================================================================

# 设置日志级别
logging_set_level() {
    local level="$1"

    case "${level,,}" in
        "debug")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
            ;;
        "info")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
        "warning")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_WARNING
            ;;
        "error")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
            ;;
        "success")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_SUCCESS
            ;;
        *)
            cli_error "无效的日志级别: $level"
            return 1
            ;;
    esac

    cli_debug "日志级别设置为: $level"
}

# 设置日志文件
logging_set_file() {
    local log_file="$1"

    if [[ -z "$log_file" ]]; then
        LOG_FILE=""
        cli_debug "禁用文件日志"
        return 0
    fi

    # 创建日志目录
    local log_dir
    log_dir=$(dirname "$log_file")
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" || {
            cli_error "无法创建日志目录: $log_dir"
            return 1
        }
    fi

    LOG_FILE="$log_file"
    cli_debug "日志文件设置为: $log_file"
}

# 核心日志记录函数
logging_log() {
    local level="$1"
    local message="$2"
    local level_num

    # 获取级别数值
    case "${level,,}" in
        "debug")
            level_num=$LOG_LEVEL_DEBUG
            ;;
        "info")
            level_num=$LOG_LEVEL_INFO
            ;;
        "warning")
            level_num=$LOG_LEVEL_WARNING
            ;;
        "error")
            level_num=$LOG_LEVEL_ERROR
            ;;
        "success")
            level_num=$LOG_LEVEL_SUCCESS
            ;;
        *)
            level_num=$LOG_LEVEL_INFO
            ;;
    esac

    # 检查是否需要记录此级别的日志
    if [[ $level_num -lt $CURRENT_LOG_LEVEL ]]; then
        return 0
    fi

    # 格式化消息
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local formatted_message
    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        formatted_message="{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}"
    else
        formatted_message="[$timestamp] [$level] $message"
    fi

    # 输出到控制台
    cli_log "$level" "$message"

    # 输出到文件 (如果配置了)
    if [[ -n "$LOG_FILE" ]]; then
        echo "$formatted_message" >> "$LOG_FILE" 2>/dev/null || {
            cli_warning "无法写入日志文件: $LOG_FILE"
        }

        # 检查日志文件大小并轮转
        logging_rotate_if_needed
    fi
}

# 日志轮转
logging_rotate_if_needed() {
    if [[ ! -f "$LOG_FILE" ]]; then
        return 0
    fi

    local file_size
    file_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")

    if [[ $file_size -gt $LOG_MAX_SIZE ]]; then
        cli_debug "日志文件大小超过限制，开始轮转"

        # 删除最旧的备份
        if [[ -f "${LOG_FILE}.${LOG_BACKUP_COUNT}" ]]; then
            rm -f "${LOG_FILE}.${LOG_BACKUP_COUNT}" || cli_warning "无法删除旧日志备份"
        fi

        # 轮转现有备份
        for ((i=LOG_BACKUP_COUNT-1; i>=1; i--)); do
            if [[ -f "${LOG_FILE}.$i" ]]; then
                mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))" || cli_warning "无法轮转日志文件 $i"
            fi
        done

        # 创建新备份
        mv "$LOG_FILE" "${LOG_FILE}.1" || cli_warning "无法创建日志备份"

        # 创建新的日志文件
        touch "$LOG_FILE" || cli_warning "无法创建新的日志文件"
    fi
}

# 便捷的日志函数
logging_debug() { logging_log "debug" "$1"; }
logging_info() { logging_log "info" "$1"; }
logging_warning() { logging_log "warning" "$1"; }
logging_error() { logging_log "error" "$1"; }
logging_success() { logging_log "success" "$1"; }

# =============================================================================
# 高级日志功能
# =============================================================================

# 记录函数开始
logging_function_start() {
    local function_name="$1"
    logging_debug "开始执行函数: $function_name"
}

# 记录函数结束
logging_function_end() {
    local function_name="$1"
    local exit_code="${2:-0}"

    if [[ $exit_code -eq 0 ]]; then
        logging_debug "函数执行成功: $function_name"
    else
        logging_warning "函数执行失败: $function_name (退出码: $exit_code)"
    fi
}

# 记录性能信息
logging_performance() {
    local operation="$1"
    local duration="$2"
    local details="${3:-}"

    if [[ -n "$details" ]]; then
        logging_info "性能: $operation 耗时 ${duration}ms - $details"
    else
        logging_info "性能: $operation 耗时 ${duration}ms"
    fi
}

# 记录错误并提供建议
logging_error_with_suggestion() {
    local error_msg="$1"
    local suggestion="$2"

    logging_error "$error_msg"
    logging_info "建议解决方案: $suggestion"
}

# =============================================================================
# 日志分析和统计
# =============================================================================

# 分析日志文件
logging_analyze() {
    local log_file="${1:-$LOG_FILE}"

    if [[ ! -f "$log_file" ]]; then
        cli_error "日志文件不存在: $log_file"
        return 1
    fi

    cli_info "分析日志文件: $log_file"

    # 统计各个级别的日志数量
    local debug_count info_count warning_count error_count success_count
    debug_count=$(grep -c '"level":"debug"' "$log_file" 2>/dev/null || echo "0")
    info_count=$(grep -c '"level":"info"' "$log_file" 2>/dev/null || echo "0")
    warning_count=$(grep -c '"level":"warning"' "$log_file" 2>/dev/null || echo "0")
    error_count=$(grep -c '"level":"error"' "$log_file" 2>/dev/null || echo "0")
    success_count=$(grep -c '"level":"success"' "$log_file" 2>/dev/null || echo "0")

    # 显示统计信息
    cli_format_list "日志统计" \
        "调试消息: $debug_count" \
        "信息消息: $info_count" \
        "警告消息: $warning_count" \
        "错误消息: $error_count" \
        "成功消息: $success_count"

    # 显示最近的错误
    if [[ $error_count -gt 0 ]]; then
        cli_info "最近的错误消息:"
        grep '"level":"error"' "$log_file" | tail -3 | while read -r line; do
            # 简单的JSON解析 (生产环境中应该使用jq)
            local message
            message=$(echo "$line" | sed 's/.*"message":"\([^"]*\)".*/\1/')
            echo "  • $message"
        done
    fi
}

# =============================================================================
# 兼容性函数
# =============================================================================

# 向后兼容现有脚本
log_info() { logging_info "$1"; }
log_success() { logging_success "$1"; }
log_warning() { logging_warning "$1"; }
log_error() { logging_error "$1"; }
log_debug() { logging_debug "$1"; }

# =============================================================================
# 如果直接运行此脚本，显示测试功能
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cli_main_template "Logging Module" "日志记录模块" \
        "test" "测试日志功能" \
        "analyze" "分析当前日志文件" \
        "set-level" "设置日志级别" \
        "set-file" "设置日志文件"

    case "$CLI_COMMAND" in
        "test")
            cli_info "测试日志功能"

            logging_debug "这是一条调试消息"
            logging_info "这是一条信息消息"
            logging_warning "这是一条警告消息"
            logging_error "这是一条错误消息"
            logging_success "这是一条成功消息"

            # 测试函数日志
            logging_function_start "test_function"
            sleep 0.1
            logging_function_end "test_function"
            ;;
        "analyze")
            logging_analyze
            ;;
        "set-level")
            local level="${CLI_ARGS[0]:-info}"
            logging_set_level "$level"
            ;;
        "set-file")
            local file="${CLI_ARGS[0]}"
            logging_set_file "$file"
            ;;
        *)
            cli_show_help "Logging Module" "日志记录模块" \
                "test" "测试日志功能" \
                "analyze" "分析当前日志文件" \
                "set-level" "设置日志级别" \
                "set-file" "设置日志文件"
            ;;
    esac
fi