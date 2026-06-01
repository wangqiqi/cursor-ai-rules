#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../.cursor/core/path-config.sh"  # 统一路径配置

# 🎯 Cursor AI Rules - 安全预提交Hook
# 在提交前进行安全检查，防止安全问题被提交

source "$SCRIPT_DIR/../../../.cursor/core/colors.sh"

# 统计
SECURITY_ISSUES=0
FILES_CHECKED=0
BLOCK_COMMIT=false

# 日志函数
log_info() {
    echo -e "${BLUE}[SECURITY-PRE-COMMIT]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SECURITY-PRE-COMMIT]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[SECURITY-PRE-COMMIT]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[SECURITY-PRE-COMMIT]${NC} ❌ $1"
}

log_critical() {
    echo -e "${RED}[SECURITY-PRE-COMMIT]${NC} 🚨 $1"
}

# 获取暂存的文件
get_staged_files() {
    git diff --cached --name-only --diff-filter=ACM
}

# 安全模式匹配检查
check_security_patterns() {
    local files=("$@")

    log_info "执行安全模式匹配检查..."

    local issues_found=0

    # 定义安全检查模式
    declare -A SECURITY_PATTERNS=(
        ["hardcoded_secrets"]="password.*=.*[\"'][^\"']*[\"']|secret.*=.*[\"'][^\"']*[\"']|api_key.*=.*[\"'][^\"']*[\"']|token.*=.*[\"'][^\"']*[\"']"
        ["sql_injection"]="SELECT.*\\+.*WHERE|INSERT.*\\+.*VALUES|UPDATE.*\\+.*SET|DELETE.*\\+.*WHERE"
        ["xss_vulnerable"]="innerHTML.*=|outerHTML.*=|document\\.write|eval\\("
        ["command_injection"]="exec\\(|system\\(|shell_exec\\(|popen\\("
        ["path_traversal"]="\\.\\./|\\.\\\\"
        ["weak_crypto"]="md5\\(|sha1\\(|des\\("
        ["debug_code"]="console\\.log|print\\(|echo |var_dump|debugger"
    )

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            continue
        fi

        ((FILES_CHECKED++))

        for pattern_name in "${!SECURITY_PATTERNS[@]}"; do
            local pattern="${SECURITY_PATTERNS[$pattern_name]}"

            if grep -n "$pattern" "$file" > /dev/null 2>&1; then
                local line_numbers=$(grep -n "$pattern" "$file" | cut -d: -f1 | tr '\n' ', ' | sed 's/, $//')

                case "$pattern_name" in
                    "hardcoded_secrets")
                        log_critical "严重安全问题: $file (行 $line_numbers) - 硬编码敏感信息"
                        ((SECURITY_ISSUES++))
                        BLOCK_COMMIT=true
                        ;;
                    "sql_injection")
                        log_error "高危安全问题: $file (行 $line_numbers) - 可能的SQL注入"
                        ((SECURITY_ISSUES++))
                        BLOCK_COMMIT=true
                        ;;
                    "xss_vulnerable")
                        log_error "高危安全问题: $file (行 $line_numbers) - 可能的XSS漏洞"
                        ((SECURITY_ISSUES++))
                        BLOCK_COMMIT=true
                        ;;
                    "command_injection")
                        log_error "高危安全问题: $file (行 $line_numbers) - 可能的命令注入"
                        ((SECURITY_ISSUES++))
                        BLOCK_COMMIT=true
                        ;;
                    "path_traversal")
                        log_warning "中等安全问题: $file (行 $line_numbers) - 路径遍历风险"
                        ((SECURITY_ISSUES++))
                        ;;
                    "weak_crypto")
                        log_warning "中等安全问题: $file (行 $line_numbers) - 使用弱加密算法"
                        ((SECURITY_ISSUES++))
                        ;;
                    "debug_code")
                        log_warning "调试代码: $file (行 $line_numbers) - 发现调试代码"
                        ((SECURITY_ISSUES++))
                        ;;
                esac

                ((issues_found++))
            fi
        done
    done

    if [ $issues_found -gt 0 ]; then
        log_warning "在 $issues_found 个文件中发现安全问题"
        return 1
    else
        log_success "安全模式匹配检查通过"
        return 0
    fi
}

# 检查配置文件安全
check_config_files() {
    local files=("$@")

    log_info "检查配置文件安全..."

    local config_issues=0

    for file in "${files[@]}"; do
        # 检查是否是配置文件
        if [[ "$file" =~ \.(env|config|conf|ini|toml|yaml|yml|json)$ ]] || [[ "$file" =~ (config|settings|credentials) ]]; then
            if [ -f "$file" ]; then
                # 检查是否包含敏感信息
                if grep -q "password\|secret\|key\|token\|PASSWORD\|SECRET\|KEY\|TOKEN" "$file" 2>/dev/null; then
                    log_critical "配置文件安全问题: $file 包含敏感信息"
                    ((SECURITY_ISSUES++))
                    ((config_issues++))
                    BLOCK_COMMIT=true
                fi

                # 检查文件权限 (如果在Unix系统上)
                if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "win32" ]]; then
                    local permissions=$(stat -c %a "$file" 2>/dev/null)
                    if [ "${permissions: -1}" -gt "6" ]; then
                        log_warning "配置文件权限过宽: $file (权限: $permissions)"
                        ((SECURITY_ISSUES++))
                        ((config_issues++))
                    fi
                fi
            fi
        fi
    done

    if [ $config_issues -gt 0 ]; then
        log_warning "发现 $config_issues 个配置文件安全问题"
        return 1
    else
        log_success "配置文件安全检查通过"
        return 0
    fi
}

# 检查大文件
check_large_files() {
    local files=("$@")

    log_info "检查大文件..."

    local large_files=()
    local max_size=$((10*1024*1024))  # 10MB

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            if [ "$size" -gt "$max_size" ]; then
                local size_mb=$((size / 1024 / 1024))
                log_warning "大文件检测: $file (${size_mb}MB)"
                large_files+=("$file")
                ((SECURITY_ISSUES++))
            fi
        fi
    done

    if [ ${#large_files[@]} -gt 0 ]; then
        log_warning "发现 ${#large_files[@]} 个大文件，建议考虑其他存储方式"
        return 1
    else
        log_success "大文件检查通过"
        return 0
    fi
}

# 运行快速安全检查
run_quick_security_check() {
    local files=("$@")

    log_info "开始快速安全检查..."

    local checks_passed=true

    # 安全模式匹配检查
    if ! check_security_patterns "${files[@]}"; then
        checks_passed=false
    fi

    # 配置文件安全检查
    if ! check_config_files "${files[@]}"; then
        checks_passed=false
    fi

    # 大文件检查
    if ! check_large_files "${files[@]}"; then
        checks_passed=false
    fi

    return $checks_passed
}

# 生成安全检查报告
generate_security_report() {
    echo ""
    echo "🔒 安全预提交检查报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📁 检查文件数: $FILES_CHECKED"
    echo "🔍 发现问题数: $SECURITY_ISSUES"
    echo ""

    if [ $SECURITY_ISSUES -gt 0 ]; then
        echo "⚠️  安全建议:"
        echo "   • 移除硬编码的敏感信息"
        echo "   • 使用参数化查询防止SQL注入"
        echo "   • 验证用户输入防止XSS攻击"
        echo "   • 避免在代码中使用弱加密算法"
        echo "   • 删除调试代码和日志"
        echo "   • 使用环境变量管理配置"
        echo ""
        echo "🔧 修复问题后重新提交:"
        echo "   git add <files>"
        echo "   git commit"
        echo ""
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 主函数
main() {
    log_info "开始安全预提交检查..."

    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "不在Git仓库中"
        exit 1
    fi

    # 获取暂存的文件
    local staged_files=($(get_staged_files))

    if [ ${#staged_files[@]} -eq 0 ]; then
        log_debug "没有暂存文件，跳过安全检查"
        exit 0
    fi

    log_info "检查 ${#staged_files[@]} 个暂存文件"

    # 执行安全检查
    if run_quick_security_check "${staged_files[@]}"; then
        log_success "安全检查通过"
        exit 0
    else
        generate_security_report

        if $BLOCK_COMMIT; then
            log_critical "发现严重安全问题，提交已被阻止"
            log_info "请修复安全问题后重新提交"
            log_info "强制提交: git commit --no-verify"
            exit 1
        else
            log_warning "发现安全问题，但允许继续提交"
            exit 0
        fi
    fi
}

# 只有在直接调用时才执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi