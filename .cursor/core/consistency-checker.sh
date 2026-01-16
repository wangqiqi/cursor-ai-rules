#!/bin/bash

# 🌟 Cursor AI Rules - 一致性检查器
# 自动化验证系统一致性、引用完整性和配置有效性

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查统计
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# 通用检查函数
check_file_exists() {
    local file="$1"
    local description="$2"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -f "$file" ]; then
        log_success "$description: 文件存在 ($file)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        log_error "$description: 文件不存在 ($file)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

check_command_exists() {
    local cmd="$1"
    local description="$2"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if command -v "$cmd" >/dev/null 2>&1; then
        log_success "$description: 命令可用 ($cmd)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        log_warning "$description: 命令不可用 ($cmd)"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

# 检查配置文件一致性
check_config_consistency() {
    log_header "📋 检查配置文件一致性"

    # 检查主要配置文件
    check_file_exists "$SCRIPT_DIR/../config/global.json" "全局配置文件"
    check_file_exists "$SCRIPT_DIR/../config/system-defaults.json" "系统默认配置"
    check_file_exists "$SCRIPT_DIR/../config/cursor-config.schema.json" "配置Schema文件"

    # 验证JSON格式
    if check_command_exists "jq" "JSON处理器"; then
        local config_files=(
            "$SCRIPT_DIR/../config/global.json"
            "$SCRIPT_DIR/../config/system-defaults.json"
            "$SCRIPT_DIR/../quality/lint/eslint-config.json"
            "$SCRIPT_DIR/../quality/format/prettier-config.json"
            "$SCRIPT_DIR/../commands/capability-map.json"
        )

        for config_file in "${config_files[@]}"; do
            if [ -f "$config_file" ]; then
                TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
                if jq empty "$config_file" 2>/dev/null; then
                    log_success "JSON格式有效: $(basename "$config_file")"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                else
                    log_error "JSON格式无效: $(basename "$config_file")"
                    FAILED_CHECKS=$((FAILED_CHECKS + 1))
                fi
            fi
        done
    fi

    # 检查配置Schema一致性
    if [ -f "$SCRIPT_DIR/../config/cursor-config.schema.json" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if jq -e '.properties.metadata' "$SCRIPT_DIR/../config/cursor-config.schema.json" >/dev/null 2>&1; then
            log_success "配置Schema包含metadata定义"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_error "配置Schema缺少metadata定义"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    fi
}

# 检查引用完整性
check_reference_integrity() {
    log_header "🔗 检查引用完整性"

    # 检查capability-map.json中的脚本引用
    if [ -f "$SCRIPT_DIR/../commands/capability-map.json" ] && check_command_exists "jq" "JSON处理器"; then
        # 提取所有脚本引用
        local script_refs=$(jq -r '.mappings | to_entries[] | .value.capabilities.scripts[]' "$SCRIPT_DIR/../commands/capability-map.json" 2>/dev/null | sort | uniq)

        for script_ref in $script_refs; do
            if [[ "$script_ref" == core/* ]]; then
                local script_path="$SCRIPT_DIR/../$script_ref"
                TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

                if [ -f "$script_path" ]; then
                    log_success "脚本引用有效: $script_ref"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                else
                    log_error "脚本引用无效: $script_ref"
                    FAILED_CHECKS=$((FAILED_CHECKS + 1))
                fi
            fi
        done

        # 检查规则引用
        local rule_refs=$(jq -r '.mappings | to_entries[] | .value.capabilities.rules[]' "$SCRIPT_DIR/../commands/capability-map.json" 2>/dev/null | sort | uniq)

        for rule_ref in $rule_refs; do
            local rule_path="$SCRIPT_DIR/../rules/**/$rule_ref.md"
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

            if compgen -G "$rule_path" >/dev/null; then
                log_success "规则引用有效: $rule_ref"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                log_error "规则引用无效: $rule_ref"
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        done

        # 检查技能引用
        local skill_refs=$(jq -r '.mappings | to_entries[] | .value.capabilities.skills[]' "$SCRIPT_DIR/../commands/capability-map.json" 2>/dev/null | sort | uniq)

        for skill_ref in $skill_refs; do
            local skill_path="$SCRIPT_DIR/../features/skills/$skill_ref.md"
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

            if [ -f "$skill_path" ]; then
                log_success "技能引用有效: $skill_ref"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                log_error "技能引用无效: $skill_ref"
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        done
    fi
}

# 检查文档一致性
check_documentation_consistency() {
    log_header "📚 检查文档一致性"

    # 检查文档结构
    local doc_files=(
        "$SCRIPT_DIR/../README.md"
        "$SCRIPT_DIR/../docs/quick-start.md"
        "$SCRIPT_DIR/../docs/usage-guide.md"
        "$SCRIPT_DIR/../docs/user-guide/basic-usage.md"
        "$SCRIPT_DIR/../docs/user-guide/core-features.md"
        "$SCRIPT_DIR/../docs/user-guide/advanced-config.md"
    )

    for doc_file in "${doc_files[@]}"; do
        check_file_exists "$doc_file" "文档文件: $(basename "$doc_file")"
    done

    # 检查文档中的链接
    if [ -f "$SCRIPT_DIR/../README.md" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        # 检查是否包含指向新文档的链接
        if grep -q "docs/quick-start.md" "$SCRIPT_DIR/../README.md" && \
           grep -q "docs/user-guide/" "$SCRIPT_DIR/../README.md"; then
            log_success "README.md包含指向新文档结构的链接"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_error "README.md缺少指向新文档结构的链接"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    fi

    # 检查文档冗余（简单的重复内容检测）
    if [ -f "$SCRIPT_DIR/../README.md" ] && [ -f "$SCRIPT_DIR/../docs/quick-start.md" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        local readme_content=$(grep -o "智能Master一键初始化" "$SCRIPT_DIR/../README.md" | wc -l)
        local quickstart_content=$(grep -o "智能Master一键初始化" "$SCRIPT_DIR/../docs/quick-start.md" | wc -l)

        if [ "$readme_content" -le 1 ] && [ "$quickstart_content" -ge 1 ]; then
            log_success "文档内容正确分布，避免了冗余"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_warning "可能存在文档内容冗余"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# 检查代码质量配置一致性
check_code_quality_consistency() {
    log_header "🔧 检查代码质量配置一致性"

    # 检查ESLint和Prettier配置
    if [ -f "$SCRIPT_DIR/../quality/lint/eslint-config.json" ] && [ -f "$SCRIPT_DIR/../quality/format/prettier-config.json" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        # 检查分号配置是否一致（ESLint的always等价于Prettier的true）
        local eslint_semi=$(jq -r '.rules."semi"[1]' "$SCRIPT_DIR/../quality/lint/eslint-config.json" 2>/dev/null)
        local prettier_semi=$(jq -r '.semi' "$SCRIPT_DIR/../quality/format/prettier-config.json" 2>/dev/null)

        if [ "$eslint_semi" = "always" ] && [ "$prettier_semi" = "true" ]; then
            log_success "ESLint和Prettier分号配置一致"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        elif [ "$eslint_semi" = "never" ] && [ "$prettier_semi" = "false" ]; then
            log_success "ESLint和Prettier分号配置一致"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_warning "ESLint和Prettier分号配置可能不一致 (ESLint: $eslint_semi, Prettier: $prettier_semi)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

    # 检查缩进配置
    local eslint_indent=$(jq -r '.rules."indent"[1]' "$SCRIPT_DIR/../quality/lint/eslint-config.json" 2>/dev/null)
    local prettier_tabwidth=$(jq -r '.tabWidth' "$SCRIPT_DIR/../quality/format/prettier-config.json" 2>/dev/null)

    if [ "$eslint_indent" = "$prettier_tabwidth" ]; then
        log_success "ESLint和Prettier缩进配置一致 ($eslint_indent)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        log_warning "ESLint和Prettier缩进配置不一致 (ESLint: $eslint_indent, Prettier: $prettier_tabwidth)"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# 检查系统依赖
check_system_dependencies() {
    log_header "🔍 检查系统依赖"

    local required_deps=("git" "bash")
    local optional_deps=("jq" "node" "npm" "python3")

    for dep in "${required_deps[@]}"; do
        check_command_exists "$dep" "必需依赖"
    done

    for dep in "${optional_deps[@]}"; do
        check_command_exists "$dep" "可选依赖"
    done
}

# 生成报告
generate_report() {
    log_header "📊 一致性检查报告"

    echo "总检查数: $TOTAL_CHECKS"
    echo "通过检查: $PASSED_CHECKS"
    echo "失败检查: $FAILED_CHECKS"
    echo "警告数: $WARNINGS"
    echo ""

    local success_rate=0
    if [ "$TOTAL_CHECKS" -gt 0 ]; then
        success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi

    if [ "$FAILED_CHECKS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        echo -e "${GREEN}🎉 所有检查通过！系统一致性良好。${NC}"
        return 0
    elif [ "$FAILED_CHECKS" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  检查完成，但存在 $WARNINGS 个警告。${NC}"
        return 1
    else
        echo -e "${RED}❌ 发现 $FAILED_CHECKS 个失败的检查。${NC}"
        return 1
    fi
}

# 主函数
main() {
    local check_type="${1:-all}"

    log_header "🚀 Cursor AI Rules 一致性检查器 v1.0.0"

    case "$check_type" in
        "config")
            check_config_consistency
            ;;
        "references")
            check_reference_integrity
            ;;
        "docs")
            check_documentation_consistency
            ;;
        "quality")
            check_code_quality_consistency
            ;;
        "deps")
            check_system_dependencies
            ;;
        "all")
            check_system_dependencies
            check_config_consistency
            check_reference_integrity
            check_documentation_consistency
            check_code_quality_consistency
            ;;
        *)
            echo "用法: $0 [check_type]"
            echo "check_type: all, config, references, docs, quality, deps"
            exit 1
            ;;
    esac

    generate_report
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi