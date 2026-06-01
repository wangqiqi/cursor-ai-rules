#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../core/path-config.sh"  # 统一路径配置

# 🎯 Cursor AI Rules - 提交前格式化Hook
# 在提交前自动格式化代码文件

source "$SCRIPT_DIR/../../../core/colors.sh"

# 统计
FILES_FORMATTED=0
FILES_CHECKED=0
FORMAT_ERRORS=0

# 日志函数
log_info() {
    echo -e "${BLUE}[PRE-COMMIT-FORMAT]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PRE-COMMIT-FORMAT]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[PRE-COMMIT-FORMAT]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[PRE-COMMIT-FORMAT]${NC} ❌ $1"
}

# 获取要检查的文件
get_staged_files() {
    git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx|json|css|scss|less|html|md|py|java|go|rs)$'
}

# 自动格式化文件
auto_format_files() {
    local files=("$@")

    if [ ${#files[@]} -eq 0 ]; then
        log_debug "没有需要格式化的文件"
        return 0
    fi

    log_info "发现 ${#files[@]} 个待格式化文件"

    # 按文件类型分组
    declare -A file_groups
    for file in "${files[@]}"; do
        local ext="${file##*.}"
        file_groups["$ext"]+="$file "
    done

    local total_formatted=0
    local has_errors=false

    # 格式化JavaScript/TypeScript文件
    if [ -n "${file_groups['js']}${file_groups['jsx']}${file_groups['ts']}${file_groups['tsx']}" ]; then
        local js_files=(${file_groups['js']} ${file_groups['jsx']} ${file_groups['ts']} ${file_groups['tsx']})

        if command -v prettier &> /dev/null; then
            log_info "使用Prettier格式化JavaScript/TypeScript文件..."
            if prettier --write "${js_files[@]}"; then
                log_success "Prettier格式化完成: ${#js_files[@]} 个文件"
                ((total_formatted += ${#js_files[@]}))
            else
                log_error "Prettier格式化失败"
                has_errors=true
            fi
        elif command -v eslint &> /dev/null && [ -f ".eslintrc.js" ]; then
            log_info "使用ESLint格式化JavaScript/TypeScript文件..."
            if npx eslint --fix "${js_files[@]}"; then
                log_success "ESLint格式化完成: ${#js_files[@]} 个文件"
                ((total_formatted += ${#js_files[@]}))
            else
                log_error "ESLint格式化失败"
                has_errors=true
            fi
        fi
    fi

    # 格式化Python文件
    if [ -n "${file_groups['py']}" ]; then
        local py_files=(${file_groups['py']})

        if command -v black &> /dev/null; then
            log_info "使用Black格式化Python文件..."
            if black "${py_files[@]}"; then
                log_success "Black格式化完成: ${#py_files[@]} 个文件"
                ((total_formatted += ${#py_files[@]}))
            else
                log_error "Black格式化失败"
                has_errors=true
            fi
        elif command -v autopep8 &> /dev/null; then
            log_info "使用autopep8格式化Python文件..."
            if autopep8 --in-place "${py_files[@]}"; then
                log_success "autopep8格式化完成: ${#py_files[@]} 个文件"
                ((total_formatted += ${#py_files[@]}))
            else
                log_error "autopep8格式化失败"
                has_errors=true
            fi
        fi
    fi

    # 格式化Go文件
    if [ -n "${file_groups['go']}" ]; then
        local go_files=(${file_groups['go']})

        if command -v gofmt &> /dev/null; then
            log_info "使用gofmt格式化Go文件..."
            if gofmt -w "${go_files[@]}"; then
                log_success "gofmt格式化完成: ${#go_files[@]} 个文件"
                ((total_formatted += ${#go_files[@]}))
            else
                log_error "gofmt格式化失败"
                has_errors=true
            fi
        fi
    fi

    # 格式化Rust文件
    if [ -n "${file_groups['rs']}" ]; then
        local rs_files=(${file_groups['rs']})

        if command -v rustfmt &> /dev/null; then
            log_info "使用rustfmt格式化Rust文件..."
            if rustfmt "${rs_files[@]}"; then
                log_success "rustfmt格式化完成: ${#rs_files[@]} 个文件"
                ((total_formatted += ${#rs_files[@]}))
            else
                log_error "rustfmt格式化失败"
                has_errors=true
            fi
        fi
    fi

    # 格式化Java文件
    if [ -n "${file_groups['java']}" ]; then
        local java_files=(${file_groups['java']})

        if command -v google-java-format &> /dev/null; then
            log_info "使用google-java-format格式化Java文件..."
            if google-java-format -i "${java_files[@]}"; then
                log_success "google-java-format格式化完成: ${#java_files[@]} 个文件"
                ((total_formatted += ${#java_files[@]}))
            else
                log_error "google-java-format格式化失败"
                has_errors=true
            fi
        fi
    fi

    FILES_FORMATTED=$total_formatted

    if $has_errors; then
        log_warning "部分文件格式化失败，但将继续提交"
        return 1
    else
        log_success "所有文件格式化完成，共处理 $total_formatted 个文件"
        return 0
    fi
}

# 检查格式化状态
check_format_status() {
    local files=("$@")

    if [ ${#files[@]} -eq 0 ]; then
        return 0
    fi

    log_info "检查文件格式状态..."

    local needs_formatting=false

    # 检查Prettier格式
    local js_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.(js|jsx|ts|tsx|json|css|scss|less|html|md)$ ]]; then
            js_files+=("$file")
        fi
    done

    if [ ${#js_files[@]} -gt 0 ] && command -v prettier &> /dev/null; then
        if ! prettier --check "${js_files[@]}" &>/dev/null; then
            log_warning "JavaScript/TypeScript文件需要格式化"
            needs_formatting=true
        fi
    fi

    # 检查Python格式
    local py_files=()
    for file in "${files[@]}"; do
        if [[ "$file" =~ \.py$ ]]; then
            py_files+=("$file")
        fi
    done

    if [ ${#py_files[@]} -gt 0 ] && command -v black &> /dev/null; then
        if ! black --check --diff "${py_files[@]}" &>/dev/null; then
            log_warning "Python文件需要格式化"
            needs_formatting=true
        fi
    fi

    if $needs_formatting; then
        log_info "检测到需要格式化的文件，正在自动格式化..."
        auto_format_files "${files[@]}"
        return 0
    else
        log_success "所有文件格式正确"
        return 0
    fi
}

# 主函数
main() {
    log_info "开始提交前格式化检查..."

    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "不在Git仓库中"
        exit 1
    fi

    # 获取暂存的文件
    local staged_files=($(get_staged_files))

    if [ ${#staged_files[@]} -eq 0 ]; then
        log_debug "没有需要格式化的暂存文件"
        exit 0
    fi

    FILES_CHECKED=${#staged_files[@]}
    log_info "检查 ${FILES_CHECKED} 个暂存文件"

    # 执行格式化检查和自动格式化
    if check_format_status "${staged_files[@]}"; then
        # 如果有文件被格式化，需要重新暂存
        if [ $FILES_FORMATTED -gt 0 ]; then
            log_info "重新暂存格式化后的文件..."
            git add "${staged_files[@]}"
            log_success "文件已重新暂存"
        fi

        log_success "格式化检查通过"
        exit 0
    else
        log_warning "格式化检查失败，但允许继续提交"
        exit 0  # 不阻止提交，只发出警告
    fi
}

# 只有在直接调用时才执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi