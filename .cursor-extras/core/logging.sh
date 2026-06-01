#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置


# 🌟 Cursor AI Rules - 标准日志和错误处理库
# 提供统一的日志记录和错误处理功能

# 🎨 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 📊 日志级别
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3
LOG_LEVEL_FATAL=4

# 当前日志级别 (默认为INFO)
CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}

# 日志文件路径
LOG_DIR="$ANALYTICS_DIR"
LOG_FILE="$LOG_DIR/cursor.log"

# 📁 确保日志目录存在
ensure_log_dir() {
    mkdir -p "$LOG_DIR" 2>/dev/null || true
}

# 🎯 设置日志级别
set_log_level() {
    local level="$1"

    case "$level" in
        "DEBUG"|"debug")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
            ;;
        "INFO"|"info")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
        "WARN"|"warn"|"WARNING"|"warning")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_WARN
            ;;
        "ERROR"|"error")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
            ;;
        "FATAL"|"fatal")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_FATAL
            ;;
        *)
            log_warn "未知的日志级别: $level，使用默认级别INFO"
            CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
    esac
}

# 📝 内部日志函数
write_log() {
    local level="$1"
    local level_num="$2"
    local message="$3"
    local component="${4:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    # 检查日志级别
    if [ $level_num -lt $CURRENT_LOG_LEVEL ]; then
        return
    fi

    ensure_log_dir

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local pid=$$
    local log_entry="$timestamp [$level] [$component] [PID:$pid] $message"

    # 写入日志文件
    echo "$log_entry" >> "$LOG_FILE" 2>/dev/null || true

    # 同时输出到控制台（带颜色）
    case "$level" in
        "DEBUG")
            echo -e "${CYAN}🐛 $message${NC}" >&2
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $message${NC}" >&2
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}" >&2
            ;;
        "FATAL")
            echo -e "${PURPLE}💀 $message${NC}" >&2
            ;;
    esac
}

# 🐛 调试日志
log_debug() {
    write_log "DEBUG" $LOG_LEVEL_DEBUG "$1" "$2"
}

# ℹ️ 信息日志
log_info() {
    write_log "INFO" $LOG_LEVEL_INFO "$1" "$2"
}

# ⚠️ 警告日志
log_warn() {
    write_log "WARN" $LOG_LEVEL_WARN "$1" "$2"
}

# ⚠️ 警告日志（别名，兼容 log_warning 命名风格）
log_warning() {
    log_warn "$1" "$2"
}

# ✅ 成功日志
log_success() {
    write_log "INFO" $LOG_LEVEL_INFO "✅ $1" "$2"
}

# ❌ 错误日志
log_error() {
    write_log "ERROR" $LOG_LEVEL_ERROR "$1" "$2"
}

# 💀 致命错误日志
log_fatal() {
    write_log "FATAL" $LOG_LEVEL_FATAL "$1" "$2"
}

# 🎯 标准错误处理函数
handle_error() {
    local error_code=$?
    local error_message="$1"
    local component="${2:-$(basename "${BASH_SOURCE[1]}" .sh)}"
    local exit_on_error="${3:-true}"

    if [ $error_code -ne 0 ]; then
        log_error "错误 ($error_code): $error_message" "$component"

        if [ "$exit_on_error" = "true" ]; then
            log_fatal "程序终止" "$component"
            exit $error_code
        fi
    fi
}

# ✅ 成功处理函数
handle_success() {
    local message="$1"
    local component="${2:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    log_info "成功: $message" "$component"
}

# 🔍 验证函数执行结果
validate_command() {
    local command="$1"
    local success_message="$2"
    local error_message="$3"
    local component="${4:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    if eval "$command" 2>/dev/null; then
        [ -n "$success_message" ] && log_info "$success_message" "$component"
        return 0
    else
        [ -n "$error_message" ] && log_error "$error_message" "$component"
        return 1
    fi
}

# 📊 性能监控函数
time_execution() {
    local start_time=$(date +%s%N)
    local command="$1"
    local operation_name="$2"
    local component="${3:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    log_debug "开始执行: $operation_name" "$component"

    eval "$command"
    local exit_code=$?

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # 转换为毫秒

    if [ $exit_code -eq 0 ]; then
        log_info "完成 ($duration ms): $operation_name" "$component"
    else
        log_error "失败 ($duration ms): $operation_name" "$component"
    fi

    return $exit_code
}

# 🔄 重试机制
retry_command() {
    local max_attempts="$1"
    local delay="$2"
    local command="$3"
    local operation_name="$4"
    local component="${5:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        log_debug "尝试 $attempt/$max_attempts: $operation_name" "$component"

        if eval "$command" 2>/dev/null; then
            log_info "重试成功 ($attempt/$max_attempts): $operation_name" "$component"
            return 0
        fi

        if [ $attempt -lt $max_attempts ]; then
            log_warn "尝试 $attempt 失败，$delay 秒后重试" "$component"
            sleep $delay
        fi

        ((attempt++))
    done

    log_error "重试失败 ($max_attempts 次): $operation_name" "$component"
    return 1
}

# 🧹 清理函数
cleanup_logs() {
    local max_age_days="${1:-30}"
    local component="${2:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    if [ -d "$LOG_DIR" ]; then
        # 删除旧日志文件
        find "$LOG_DIR" -name "*.log" -mtime +$max_age_days -delete 2>/dev/null || true

        # 压缩大日志文件
        find "$LOG_DIR" -name "*.log" -size +10M -exec gzip {} \; 2>/dev/null || true

        log_info "日志清理完成 (保留 ${max_age_days} 天)" "$component"
    fi
}

# 📋 获取日志统计
get_log_stats() {
    local component="${1:-$(basename "${BASH_SOURCE[1]}" .sh)}"

    if [ -f "$LOG_FILE" ]; then
        local total_lines=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
        local error_count=$(grep -c "\[ERROR\]" "$LOG_FILE" 2>/dev/null || echo "0")
        local warn_count=$(grep -c "\[WARN\]" "$LOG_FILE" 2>/dev/null || echo "0")
        local file_size=$(du -h "$LOG_FILE" 2>/dev/null | cut -f1 || echo "未知")

        cat << EOF
日志统计信息:
├── 总行数: $total_lines
├── 错误数: $error_count
├── 警告数: $warn_count
└── 文件大小: $file_size
EOF
    else
        echo "日志文件不存在"
    fi
}

# 🚀 初始化日志系统
init_logging() {
    local log_level="${1:-INFO}"
    local component="${2:-system}"

    # 设置日志级别
    set_log_level "$log_level"

    # 确保日志目录存在
    ensure_log_dir

    # 记录初始化
    log_info "日志系统初始化完成 (级别: $log_level)" "$component"
}

# 如果直接运行此脚本，显示帮助信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🌟 Cursor AI Rules - 标准日志和错误处理库"
    echo ""
    echo "此库提供统一的日志记录和错误处理功能"
    echo ""
    echo "使用方法:"
    echo "  source .cursor/core/logging.sh"
    echo ""
    echo "可用函数:"
    echo "  log_debug|info|warn|error|fatal <message> [component]"
    echo "  handle_error <message> [component] [exit_on_error]"
    echo "  handle_success <message> [component]"
    echo "  validate_command <command> [success_msg] [error_msg] [component]"
    echo "  time_execution <command> <operation_name> [component]"
    echo "  retry_command <max_attempts> <delay> <command> <operation_name> [component]"
    echo "  cleanup_logs [max_age_days] [component]"
    echo "  get_log_stats [component]"
    echo "  init_logging [log_level] [component]"
    echo ""
    echo "示例:"
    echo '  init_logging "INFO"'
    echo '  log_info "操作开始"'
    echo '  time_execution "sleep 1" "测试操作"'
    echo '  handle_success "操作完成"'
fi