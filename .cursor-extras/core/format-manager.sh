#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"

# 🌟 Cursor AI Rules - 代码格式化管理器
# 统一代码格式化，支持多种语言和格式化工具

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORMAT_DIR="$SCRIPT_DIR"

source "$SCRIPT_DIR/colors.sh"

# 格式化统计
FILES_FORMATTED=0
FILES_CHECKED=0
FORMAT_ERRORS=0
FORMAT_WARNINGS=0

# 支持的格式化工具
declare -A FORMATTERS=(
    ["prettier"]="JavaScript/TypeScript/CSS/HTML/JSON/Markdown"
    ["black"]="Python"
    ["gofmt"]="Go"
    ["rustfmt"]="Rust"
    ["clang-format"]="C/C++/Java"
    ["shfmt"]="Shell"
    ["sql-formatter"]="SQL"
)

# 日志函数
log_info() {
    echo -e "${BLUE}[FORMAT-MANAGER]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[FORMAT-MANAGER]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[FORMAT-MANAGER]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[FORMAT-MANAGER]${NC} ❌ $1"
}

log_debug() {
    echo -e "${CYAN}[FORMAT-MANAGER]${NC} 🔍 $1"
}

# 检测可用的格式化工具
detect_formatters() {
    log_info "检测可用的格式化工具..."

    for formatter in "${!FORMATTERS[@]}"; do
        if command -v "$formatter" &> /dev/null; then
            local version=$($formatter --version 2>/dev/null | head -1 || echo "未知版本")
            log_success "$formatter 可用: $version"
            log_debug "支持: ${FORMATTERS[$formatter]}"
        else
            log_debug "$formatter 未安装: ${FORMATTERS[$formatter]}"
        fi
    done
}

# 根据文件扩展名选择格式化工具
select_formatter() {
    local file="$1"
    local extension="${file##*.}"

    case "$extension" in
        "js"|"jsx"|"ts"|"tsx"|"json"|"css"|"scss"|"less"|"html"|"md"|"yaml"|"yml")
            echo "prettier"
            ;;
        "py")
            echo "black"
            ;;
        "go")
            echo "gofmt"
            ;;
        "rs")
            echo "rustfmt"
            ;;
        "c"|"cpp"|"cc"|"cxx"|"h"|"hpp"|"java")
            echo "clang-format"
            ;;
        "sh"|"bash")
            echo "shfmt"
            ;;
        "sql")
            echo "sql-formatter"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 检查Prettier格式
check_prettier() {
    local files=("$@")

    if ! command -v prettier &> /dev/null; then
        log_warning "Prettier未安装，跳过检查"
        return 1
    fi

    log_info "使用Prettier检查格式..."

    local check_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.(js|jsx|ts|tsx|json|css|scss|less|html|md|yaml|yml)$ ]]; then
            check_files+=("$file")
        fi
    done

    if [ ${#check_files[@]} -eq 0 ]; then
        log_debug "没有需要Prettier检查的文件"
        return 0
    fi

    if prettier --check "${check_files[@]}" &>/dev/null; then
        log_success "Prettier检查通过"
        return 0
    else
        log_warning "发现格式问题"
        return 1
    fi
}

# 应用Prettier格式化
apply_prettier() {
    local files=("$@")
    local write_mode="${1:-false}"

    if ! command -v prettier &> /dev/null; then
        log_error "Prettier未安装"
        return 1
    fi

    log_info "使用Prettier格式化..."

    local check_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.(js|jsx|ts|tsx|json|css|scss|less|html|md|yaml|yml)$ ]]; then
            check_files+=("$file")
        fi
    done

    if [ ${#check_files[@]} -eq 0 ]; then
        log_debug "没有需要Prettier格式化的文件"
        return 0
    fi

    if [ "$write_mode" = "true" ]; then
        if prettier --write "${check_files[@]}"; then
            log_success "Prettier格式化完成"
            FILES_FORMATTED=$((FILES_FORMATTED + ${#check_files[@]}))
            return 0
        else
            log_error "Prettier格式化失败"
            return 1
        fi
    else
        if check_prettier "${check_files[@]}"; then
            return 0
        else
            return 1
        fi
    fi
}

# 检查Black格式
check_black() {
    local files=("$@")

    if ! command -v black &> /dev/null; then
        log_warning "Black未安装，跳过检查"
        return 1
    fi

    log_info "使用Black检查格式..."

    local check_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.py$ ]]; then
            check_files+=("$file")
        fi
    done

    if [ ${#check_files[@]} -eq 0 ]; then
        log_debug "没有需要Black检查的文件"
        return 0
    fi

    if black --check --diff "${check_files[@]}" &>/dev/null; then
        log_success "Black检查通过"
        return 0
    else
        log_warning "发现Python格式问题"
        return 1
    fi
}

# 应用Black格式化
apply_black() {
    local files=("$@")
    local write_mode="${1:-false}"

    if ! command -v black &> /dev/null; then
        log_error "Black未安装"
        return 1
    fi

    log_info "使用Black格式化Python代码..."

    local check_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.py$ ]]; then
            check_files+=("$file")
        fi
    done

    if [ ${#check_files[@]} -eq 0 ]; then
        log_debug "没有需要Black格式化的文件"
        return 0
    fi

    if [ "$write_mode" = "true" ]; then
        if black "${check_files[@]}"; then
            log_success "Black格式化完成"
            FILES_FORMATTED=$((FILES_FORMATTED + ${#check_files[@]}))
            return 0
        else
            log_error "Black格式化失败"
            return 1
        fi
    else
        if check_black "${check_files[@]}"; then
            return 0
        else
            return 1
        fi
    fi
}

# 检查Go格式
check_gofmt() {
    local files=("$@")

    if ! command -v gofmt &> /dev/null; then
        log_warning "gofmt未安装，跳过检查"
        return 1
    fi

    log_info "使用gofmt检查格式..."

    local check_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.go$ ]]; then
            check_files+=("$file")
        fi
    done

    if [ ${#check_files[@]} -eq 0 ]; then
        log_debug "没有需要gofmt检查的文件"
        return 0
    fi

    local has_issues=false
    for file in "${check_files[@]}"; do
        if ! gofmt -d "$file" | grep -q .; then
            continue
        else
            has_issues=true
            break
        fi
    done

    if $has_issues; then
        log_warning "发现Go格式问题"
        return 1
    else
        log_success "gofmt检查通过"
        return 0
    fi
}

# 应用Go格式化
apply_gofmt() {
    local files=("$@")
    local write_mode="${1:-false}"

    if ! command -v gofmt &> /dev/null; then
        log_error "gofmt未安装"
        return 1
    fi

    log_info "使用gofmt格式化Go代码..."

    local check_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.go$ ]]; then
            check_files+=("$file")
        fi
    done

    if [ ${#check_files[@]} -eq 0 ]; then
        log_debug "没有需要gofmt格式化的文件"
        return 0
    fi

    if [ "$write_mode" = "true" ]; then
        if gofmt -w "${check_files[@]}"; then
            log_success "gofmt格式化完成"
            FILES_FORMATTED=$((FILES_FORMATTED + ${#check_files[@]}))
            return 0
        else
            log_error "gofmt格式化失败"
            return 1
        fi
    else
        if check_gofmt "${check_files[@]}"; then
            return 0
        else
            return 1
        fi
    fi
}

# 通用格式化函数
format_files() {
    local write_mode="$1"
    shift
    local files=("$@")

    log_info "开始格式化 ${#files[@]} 个文件..."

    if [ ${#files[@]} -eq 0 ]; then
        log_warning "没有指定要格式化的文件"
        return 1
    fi

    # 按格式化工具分组文件
    declare -A formatter_files
    for file in "${files[@]}"; do
        local formatter=$(select_formatter "$file")
        if [ -n "$formatter" ]; then
            formatter_files["$formatter"]+="$file "
        fi
    done

    # 对每个格式化工具执行格式化
    local all_success=true
    for formatter in "${!formatter_files[@]}"; do
        log_info "处理 $formatter 文件..."
        local file_list=(${formatter_files["$formatter"]})

        case "$formatter" in
            "prettier")
                if ! apply_prettier "$write_mode" "${file_list[@]}"; then
                    all_success=false
                    ((FORMAT_ERRORS++))
                fi
                ;;
            "black")
                if ! apply_black "$write_mode" "${file_list[@]}"; then
                    all_success=false
                    ((FORMAT_ERRORS++))
                fi
                ;;
            "gofmt")
                if ! apply_gofmt "$write_mode" "${file_list[@]}"; then
                    all_success=false
                    ((FORMAT_ERRORS++))
                fi
                ;;
            *)
                log_warning "不支持的格式化工具: $formatter"
                ;;
        esac
    done

    if $all_success; then
        log_success "所有文件格式化完成"
        return 0
    else
        log_warning "部分文件格式化失败"
        return 1
    fi
}

# 检查格式化状态
check_format_status() {
    local files=("$@")

    log_info "检查格式化状态..."

    FILES_CHECKED=${#files[@]}

    if format_files "false" "${files[@]}"; then
        log_success "所有文件格式正确"
        return 0
    else
        log_warning "发现格式问题，建议运行格式化"
        return 1
    fi
}

# 执行格式化
execute_formatting() {
    local files=("$@")

    log_info "执行代码格式化..."

    if format_files "true" "${files[@]}"; then
        log_success "格式化完成，共处理 $FILES_FORMATTED 个文件"
        return 0
    else
        log_error "格式化失败"
        return 1
    fi
}

# 生成格式化报告
generate_format_report() {
    log_info "生成格式化报告..."

    cat << EOF
📊 代码格式化报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 处理文件数: $FILES_CHECKED
✅ 格式化文件数: $FILES_FORMATTED
⚠️  警告数: $FORMAT_WARNINGS
❌ 错误数: $FORMAT_ERRORS

🔧 支持的格式化工具:
$(for formatter in "${!FORMATTERS[@]}"; do
    if command -v "$formatter" &> /dev/null; then
        echo "  ✅ $formatter - ${FORMATTERS[$formatter]}"
    else
        echo "  ❌ $formatter - ${FORMATTERS[$formatter]}"
    fi
done)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# 主函数
main() {
    local command="$1"
    shift

    case "$command" in
        "check")
            detect_formatters
            if check_format_status "$@"; then
                log_success "格式检查通过"
            else
                log_warning "发现格式问题"
            fi
            ;;
        "format")
            if execute_formatting "$@"; then
                log_success "格式化完成"
            else
                log_error "格式化失败"
            fi
            ;;
        "report")
            generate_format_report
            ;;
        "detect")
            detect_formatters
            ;;
        *)
            echo "用法: $0 <command> [files...]"
            echo ""
            echo "命令:"
            echo "  check    检查文件格式"
            echo "  format   格式化文件 (会修改文件)"
            echo "  report   生成格式化报告"
            echo "  detect   检测可用的格式化工具"
            echo ""
            echo "示例:"
            echo "  $0 check *.js *.py        # 检查JS和Python文件格式"
            echo "  $0 format src/            # 格式化src目录下的所有文件"
            echo "  $0 report                 # 显示格式化统计报告"
            return 1
            ;;
    esac
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi