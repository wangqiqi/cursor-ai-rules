#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"

# 🌟 Cursor AI Rules - 文档生成器
# 自动生成代码文档，支持多种格式和语言

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR"

source "$SCRIPT_DIR/colors.sh"

# 文档统计
FILES_PROCESSED=0
DOCS_GENERATED=0
DOCS_UPDATED=0
DOCS_ERRORS=0

# 支持的文档工具
declare -A DOC_TOOLS=(
    ["jsdoc"]="JavaScript/TypeScript"
    ["typedoc"]="TypeScript"
    ["pydoc"]="Python"
    ["sphinx"]="Python (高级)"
    ["javadoc"]="Java"
    ["godoc"]="Go"
    ["rustdoc"]="Rust"
)

# 日志函数
log_info() {
    echo -e "${BLUE}[DOCS-GENERATOR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[DOCS-GENERATOR]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[DOCS-GENERATOR]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[DOCS-GENERATOR]${NC} ❌ $1"
}

log_debug() {
    echo -e "${CYAN}[DOCS-GENERATOR]${NC} 🔍 $1"
}

# 检测可用的文档工具
detect_doc_tools() {
    log_info "检测可用的文档工具..."

    for tool in "${!DOC_TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "未知版本")
            log_success "$tool 可用: $version"
            log_debug "支持: ${DOC_TOOLS[$tool]}"
        fi
    done

    # 检查npm包
    if command -v npm &> /dev/null; then
        if [ -f "package.json" ]; then
            if npm list typedoc &>/dev/null 2>&1; then
                log_success "TypeDoc (npm包) 可用"
            fi
            if npm list jsdoc &>/dev/null 2>&1; then
                log_success "JSDoc (npm包) 可用"
            fi
        fi
    fi
}

# 根据文件扩展名选择文档工具
select_doc_tool() {
    local file="$1"
    local extension="${file##*.}"

    case "$extension" in
        "js"|"jsx")
            if command -v jsdoc &> /dev/null || npm list jsdoc &>/dev/null 2>&1; then
                echo "jsdoc"
            fi
            ;;
        "ts"|"tsx")
            if command -v typedoc &> /dev/null || npm list typedoc &>/dev/null 2>&1; then
                echo "typedoc"
            else
                echo "jsdoc"
            fi
            ;;
        "py")
            if command -v sphinx-build &> /dev/null; then
                echo "sphinx"
            else
                echo "pydoc"
            fi
            ;;
        "java")
            echo "javadoc"
            ;;
        "go")
            echo "godoc"
            ;;
        "rs")
            echo "rustdoc"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 生成JSDoc文档
generate_jsdoc() {
    local source_dir="${1:-src}"
    local output_dir="${2:-docs/jsdoc}"

    log_info "生成JSDoc文档..."

    if ! command -v jsdoc &> /dev/null && ! npm list jsdoc &>/dev/null 2>&1; then
        log_error "JSDoc未安装"
        return 1
    fi

    # 创建输出目录
    mkdir -p "$output_dir"

    local jsdoc_cmd="jsdoc"
    if npm list jsdoc &>/dev/null 2>&1; then
        jsdoc_cmd="npx jsdoc"
    fi

    # 生成配置文件
    cat > jsdoc.conf.json << EOF
{
  "source": {
    "include": ["$source_dir"],
    "includePattern": "\\.(js|jsx)$",
    "exclude": ["node_modules", "docs"]
  },
  "opts": {
    "destination": "$output_dir",
    "recurse": true
  }
}
EOF

    if $jsdoc_cmd -c jsdoc.conf.json; then
        log_success "JSDoc文档生成完成: $output_dir"
        ((DOCS_GENERATED++))
        rm -f jsdoc.conf.json
        return 0
    else
        log_error "JSDoc文档生成失败"
        rm -f jsdoc.conf.json
        return 1
    fi
}

# 生成TypeDoc文档
generate_typedoc() {
    local source_dir="${1:-src}"
    local output_dir="${2:-docs/typedoc}"

    log_info "生成TypeDoc文档..."

    if ! command -v typedoc &> /dev/null && ! npm list typedoc &>/dev/null 2>&1; then
        log_error "TypeDoc未安装"
        return 1
    fi

    # 创建输出目录
    mkdir -p "$output_dir"

    local typedoc_cmd="typedoc"
    if npm list typedoc &>/dev/null 2>&1; then
        typedoc_cmd="npx typedoc"
    fi

    if $typedoc_cmd --out "$output_dir" --mode file "$source_dir"; then
        log_success "TypeDoc文档生成完成: $output_dir"
        ((DOCS_GENERATED++))
        return 0
    else
        log_error "TypeDoc文档生成失败"
        return 1
    fi
}

# 生成Python文档
generate_pydoc() {
    local source_dir="${1:-.}"
    local output_dir="${2:-docs/pydoc}"

    log_info "生成Python文档..."

    # 创建输出目录
    mkdir -p "$output_dir"

    # 查找Python文件
    local python_files=$(find "$source_dir" -name "*.py" -not -path "*/__pycache__/*" -not -path "*/.*" | head -10)

    if [ -z "$python_files" ]; then
        log_warning "未找到Python文件"
        return 1
    fi

    local success_count=0
    for py_file in $python_files; do
        local module_name=$(basename "$py_file" .py)
        local output_file="$output_dir/${module_name}.html"

        if python -m pydoc -w "$module_name" 2>/dev/null; then
            if [ -f "${module_name}.html" ]; then
                mv "${module_name}.html" "$output_file"
                ((success_count++))
            fi
        fi
    done

    if [ $success_count -gt 0 ]; then
        log_success "Python文档生成完成: $output_dir ($success_count 个文件)"
        ((DOCS_GENERATED++))
        return 0
    else
        log_error "Python文档生成失败"
        return 1
    fi
}

# 生成Javadoc文档
generate_javadoc() {
    local source_dir="${1:-src}"
    local output_dir="${2:-docs/javadoc}"

    log_info "生成Javadoc文档..."

    if ! command -v javadoc &> /dev/null; then
        log_error "javadoc未安装"
        return 1
    fi

    # 创建输出目录
    mkdir -p "$output_dir"

    # 查找Java文件
    local java_files=$(find "$source_dir" -name "*.java" | head -20)

    if [ -z "$java_files" ]; then
        log_warning "未找到Java文件"
        return 1
    fi

    if javadoc -d "$output_dir" -sourcepath "$source_dir" -subpackages .; then
        log_success "Javadoc文档生成完成: $output_dir"
        ((DOCS_GENERATED++))
        return 0
    else
        log_error "Javadoc文档生成失败"
        return 1
    fi
}

# 生成Go文档
generate_godoc() {
    local source_dir="${1:-.}"
    local output_dir="${2:-docs/godoc}"

    log_info "生成Go文档..."

    if ! command -v godoc &> /dev/null; then
        log_error "godoc未安装"
        return 1
    fi

    # 创建输出目录
    mkdir -p "$output_dir"

    # 生成包文档
    if godoc -html -goroot "$(go env GOROOT)" . > "$output_dir/index.html" 2>/dev/null; then
        log_success "Go文档生成完成: $output_dir"
        ((DOCS_GENERATED++))
        return 0
    else
        log_error "Go文档生成失败"
        return 1
    fi
}

# 生成Rust文档
generate_rustdoc() {
    local source_dir="${1:-.}"
    local output_dir="${2:-docs/rustdoc}"

    log_info "生成Rust文档..."

    if ! command -v cargo &> /dev/null; then
        log_error "Cargo未安装"
        return 1
    fi

    if cargo doc --open --no-deps; then
        log_success "Rust文档生成完成: target/doc"
        ((DOCS_GENERATED++))
        return 0
    else
        log_error "Rust文档生成失败"
        return 1
    fi
}

# 自动检测项目类型并生成文档
auto_generate_docs() {
    local source_dir="${1:-.}"
    local output_dir="${2:-docs}"

    log_info "自动检测项目类型并生成文档..."

    # 检测项目类型并选择合适的文档工具
    if [ -f "package.json" ]; then
        log_debug "检测到JavaScript/Node.js项目"

        if [ -f "tsconfig.json" ] || find "$source_dir" -name "*.ts" -o -name "*.tsx" | grep -q .; then
            log_info "检测到TypeScript，使用TypeDoc"
            generate_typedoc "$source_dir" "$output_dir/typedoc"
        else
            log_info "检测到JavaScript，使用JSDoc"
            generate_jsdoc "$source_dir" "$output_dir/jsdoc"
        fi

    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        log_debug "检测到Python项目，使用pydoc"
        generate_pydoc "$source_dir" "$output_dir/pydoc"

    elif [ -f "Cargo.toml" ]; then
        log_debug "检测到Rust项目，使用rustdoc"
        generate_rustdoc "$source_dir" "$output_dir/rustdoc"

    elif [ -f "go.mod" ]; then
        log_debug "检测到Go项目，使用godoc"
        generate_godoc "$source_dir" "$output_dir/godoc"

    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        log_debug "检测到Java项目，使用Javadoc"
        generate_javadoc "$source_dir" "$output_dir/javadoc"

    else
        log_warning "无法自动检测项目类型，请手动指定文档工具"
        return 1
    fi
}

# 更新现有文档
update_existing_docs() {
    local docs_dir="${1:-docs}"

    log_info "检查并更新现有文档..."

    if [ ! -d "$docs_dir" ]; then
        log_warning "文档目录不存在: $docs_dir"
        return 1
    fi

    local updated_count=0

    # 检查README文件
    if [ -f "README.md" ]; then
        local readme_age=$(stat -c %Y README.md 2>/dev/null || stat -f %m README.md 2>/dev/null || echo "0")
        local now=$(date +%s)
        local age_days=$(( (now - readme_age) / 86400 ))

        if [ $age_days -gt 30 ]; then
            log_warning "README.md 已过期 ($age_days 天未更新)"
        else
            log_success "README.md 状态良好"
            ((updated_count++))
        fi
    fi

    # 检查API文档
    if [ -d "$docs_dir/api" ]; then
        local api_files=$(find "$docs_dir/api" -name "*.md" | wc -l)
        log_info "发现 $api_files 个API文档文件"
        ((updated_count += api_files))
    fi

    # 检查指南文档
    if [ -d "$docs_dir/guides" ]; then
        local guide_files=$(find "$docs_dir/guides" -name "*.md" | wc -l)
        log_info "发现 $guide_files 个指南文档文件"
        ((updated_count += guide_files))
    fi

    DOCS_UPDATED=$updated_count
    log_success "文档检查完成，共 $updated_count 个文档文件"
}

# 生成文档报告
generate_docs_report() {
    log_info "生成文档报告..."

    cat << EOF
📚 文档生成报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 处理文件数: $FILES_PROCESSED
📝 生成文档数: $DOCS_GENERATED
🔄 更新文档数: $DOCS_UPDATED
❌ 错误数: $DOCS_ERRORS

🔧 支持的文档工具:
$(for tool in "${!DOC_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "  ✅ $tool - ${DOC_TOOLS[$tool]}"
    else
        case "$tool" in
            "typedoc"|"jsdoc")
                if npm list "$tool" &>/dev/null 2>&1; then
                    echo "  ✅ $tool (npm) - ${DOC_TOOLS[$tool]}"
                fi
                ;;
        esac
    fi
done)

📖 推荐文档结构:
  docs/
  ├── README.md          # 项目说明
  ├── api/               # API文档
  ├── guides/            # 使用指南
  ├── architecture/      # 架构文档
  └── examples/          # 示例代码

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# 主函数
main() {
    local command="$1"
    shift

    case "$command" in
        "auto")
            local source_dir="${1:-.}"
            local output_dir="${2:-docs}"
            if auto_generate_docs "$source_dir" "$output_dir"; then
                log_success "自动文档生成完成"
            else
                log_error "自动文档生成失败"
            fi
            ;;
        "jsdoc")
            local source_dir="${1:-src}"
            local output_dir="${2:-docs/jsdoc}"
            generate_jsdoc "$source_dir" "$output_dir"
            ;;
        "typedoc")
            local source_dir="${1:-src}"
            local output_dir="${2:-docs/typedoc}"
            generate_typedoc "$source_dir" "$output_dir"
            ;;
        "pydoc")
            local source_dir="${1:-.}"
            local output_dir="${2:-docs/pydoc}"
            generate_pydoc "$source_dir" "$output_dir"
            ;;
        "javadoc")
            local source_dir="${1:-src}"
            local output_dir="${2:-docs/javadoc}"
            generate_javadoc "$source_dir" "$output_dir"
            ;;
        "godoc")
            local source_dir="${1:-.}"
            local output_dir="${2:-docs/godoc}"
            generate_godoc "$source_dir" "$output_dir"
            ;;
        "rustdoc")
            generate_rustdoc
            ;;
        "update")
            local docs_dir="${1:-docs}"
            update_existing_docs "$docs_dir"
            ;;
        "detect")
            detect_doc_tools
            ;;
        "report")
            generate_docs_report
            ;;
        *)
            echo "用法: $0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  auto [source_dir] [output_dir]    自动检测项目类型并生成文档"
            echo "  jsdoc [source_dir] [output_dir]    生成JSDoc文档"
            echo "  typedoc [source_dir] [output_dir]  生成TypeDoc文档"
            echo "  pydoc [source_dir] [output_dir]    生成Python文档"
            echo "  javadoc [source_dir] [output_dir]  生成Javadoc文档"
            echo "  godoc [source_dir] [output_dir]    生成Go文档"
            echo "  rustdoc                            生成Rust文档"
            echo "  update [docs_dir]                  更新现有文档"
            echo "  detect                             检测可用的文档工具"
            echo "  report                             生成文档报告"
            echo ""
            echo "示例:"
            echo "  $0 auto                           # 自动生成文档"
            echo "  $0 jsdoc src docs/jsdoc          # 生成JSDoc"
            echo "  $0 update docs                   # 更新文档"
            return 1
            ;;
    esac
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi