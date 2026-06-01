#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"

# 🌟 Cursor AI Rules - 安全审计器
# 代码安全漏洞扫描和安全最佳实践检查

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECURITY_DIR="$SCRIPT_DIR"

source "$SCRIPT_DIR/colors.sh"

# 安全统计
VULNERABILITIES_FOUND=0
SECURITY_ISSUES_CRITICAL=0
SECURITY_ISSUES_HIGH=0
SECURITY_ISSUES_MEDIUM=0
SECURITY_ISSUES_LOW=0
FILES_SCANNED=0

# 支持的安全工具
declare -A SECURITY_TOOLS=(
    ["snyk"]="Node.js依赖漏洞扫描"
    ["npm-audit"]="npm安全审计"
    ["bandit"]="Python安全扫描"
    ["safety"]="Python依赖安全检查"
    ["gosec"]="Go安全扫描"
    ["brakeman"]="Ruby安全扫描"
    ["spotbugs"]="Java字节码安全分析"
    ["semgrep"]="通用代码安全扫描"
    ["trivy"]="容器和文件系统安全扫描"
)

# 常见安全漏洞模式
declare -A VULNERABILITY_PATTERNS=(
    ["hardcoded_password"]="硬编码密码|密码.*=.*[\"'][^\"']*[\"']"
    ["sql_injection"]="SELECT.*\+|INSERT.*\+|UPDATE.*\+|DELETE.*\+"
    ["xss_vulnerable"]="innerHTML|outerHTML|document\.write"
    ["command_injection"]="exec\(|eval\(|system\("
    ["path_traversal"]="\.\./|\.\.\\"
    ["weak_crypto"]="md5\(|sha1\("
    ["exposed_secrets"]="API_KEY|SECRET_KEY|TOKEN"
)

# 日志函数
log_info() {
    echo -e "${BLUE}[SECURITY-AUDITOR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SECURITY-AUDITOR]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[SECURITY-AUDITOR]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[SECURITY-AUDITOR]${NC} ❌ $1"
}

log_critical() {
    echo -e "${RED}[SECURITY-AUDITOR]${NC} 🚨 $1"
}

log_debug() {
    echo -e "${CYAN}[SECURITY-AUDITOR]${NC} 🔍 $1"
}

# 检测可用的安全工具
detect_security_tools() {
    log_info "检测可用的安全工具..."

    for tool in "${!SECURITY_TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "未知版本")
            log_success "$tool 可用: $version"
            log_debug "功能: ${SECURITY_TOOLS[$tool]}"
        fi
    done

    # 检查npm工具
    if command -v npm &> /dev/null && [ -f "package.json" ]; then
        if npm list snyk &>/dev/null 2>&1; then
            log_success "Snyk (npm包) 可用"
        fi
    fi
}

# 运行npm审计
run_npm_audit() {
    log_info "运行npm安全审计..."

    if [ ! -f "package.json" ]; then
        log_debug "非npm项目，跳过npm审计"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        log_warning "npm未安装，跳过npm审计"
        return 0
    fi

    log_info "执行npm audit..."
    if npm audit --audit-level moderate; then
        log_success "npm审计通过"
        return 0
    else
        log_warning "发现npm依赖漏洞"
        ((SECURITY_ISSUES_HIGH++))
        return 1
    fi
}

# 运行Snyk测试
run_snyk_test() {
    log_info "运行Snyk安全测试..."

    local snyk_cmd="snyk"
    if ! command -v snyk &> /dev/null; then
        if npm list snyk &>/dev/null 2>&1; then
            snyk_cmd="npx snyk"
        else
            log_warning "Snyk未安装，跳过Snyk测试"
            return 0
        fi
    fi

    if $snyk_cmd test --severity-threshold=medium; then
        log_success "Snyk安全测试通过"
        return 0
    else
        log_warning "Snyk发现安全问题"
        ((SECURITY_ISSUES_HIGH++))
        return 1
    fi
}

# 运行Bandit (Python安全扫描)
run_bandit_scan() {
    log_info "运行Bandit Python安全扫描..."

    if ! command -v bandit &> /dev/null; then
        log_warning "Bandit未安装，跳过Python安全扫描"
        return 0
    fi

    # 检查是否有Python文件
    local python_files=$(find . -name "*.py" -not -path "*/__pycache__/*" -not -path "*/.*" | wc -l)
    if [ "$python_files" -eq 0 ]; then
        log_debug "未找到Python文件，跳过Bandit扫描"
        return 0
    fi

    if bandit -r . --severity-level medium; then
        log_success "Bandit安全扫描通过"
        return 0
    else
        log_warning "Bandit发现安全问题"
        ((SECURITY_ISSUES_MEDIUM++))
        return 1
    fi
}

# 运行Safety (Python依赖检查)
run_safety_check() {
    log_info "运行Safety Python依赖检查..."

    if ! command -v safety &> /dev/null; then
        log_warning "Safety未安装，跳过依赖检查"
        return 0
    fi

    if [ ! -f "requirements.txt" ] && [ ! -f "Pipfile.lock" ]; then
        log_debug "未找到Python依赖文件，跳过Safety检查"
        return 0
    fi

    if safety check; then
        log_success "Safety依赖检查通过"
        return 0
    else
        log_warning "Safety发现不安全的依赖"
        ((SECURITY_ISSUES_HIGH++))
        return 1
    fi
}

# 运行GoSec (Go安全扫描)
run_gosec_scan() {
    log_info "运行GoSec安全扫描..."

    if ! command -v gosec &> /dev/null; then
        log_warning "GoSec未安装，跳过Go安全扫描"
        return 0
    fi

    if [ ! -f "go.mod" ]; then
        log_debug "非Go项目，跳过GoSec扫描"
        return 0
    fi

    if gosec ./...; then
        log_success "GoSec安全扫描通过"
        return 0
    else
        log_warning "GoSec发现安全问题"
        ((SECURITY_ISSUES_MEDIUM++))
        return 1
    fi
}

# 模式匹配安全检查
pattern_based_security_check() {
    local target_dir="${1:-.}"

    log_info "执行模式匹配安全检查..."

    local total_issues=0

    for pattern_name in "${!VULNERABILITY_PATTERNS[@]}"; do
        local pattern="${VULNERABILITY_PATTERNS[$pattern_name]}"
        log_debug "检查模式: $pattern_name"

        # 查找匹配的文件
        local matching_files=$(find "$target_dir" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" \) \
                             -exec grep -l "$pattern" {} \; 2>/dev/null)

        if [ -n "$matching_files" ]; then
            local file_count=$(echo "$matching_files" | wc -l)
            log_warning "发现潜在安全问题 '$pattern_name' 在 $file_count 个文件中"

            # 根据问题类型设置严重程度
            case "$pattern_name" in
                "hardcoded_password"|"exposed_secrets")
                    ((SECURITY_ISSUES_CRITICAL++))
                    log_critical "严重: 硬编码敏感信息"
                    ;;
                "sql_injection"|"command_injection")
                    ((SECURITY_ISSUES_HIGH++))
                    log_error "高危: 注入漏洞风险"
                    ;;
                "xss_vulnerable")
                    ((SECURITY_ISSUES_HIGH++))
                    log_error "高危: XSS漏洞风险"
                    ;;
                *)
                    ((SECURITY_ISSUES_MEDIUM++))
                    log_warning "中等: 一般安全问题"
                    ;;
            esac

            ((total_issues += file_count))
        fi
    done

    VULNERABILITIES_FOUND=$total_issues

    if [ $total_issues -gt 0 ]; then
        log_warning "模式匹配发现 $total_issues 个潜在安全问题"
        return 1
    else
        log_success "模式匹配安全检查通过"
        return 0
    fi
}

# 检查配置文件安全
check_config_security() {
    log_info "检查配置文件安全..."

    local config_files=("package.json" "requirements.txt" "Pipfile" "Cargo.toml" "go.mod" ".env" ".env.local" ".env.production")
    local issues_found=0

    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            log_debug "检查配置文件: $config_file"

            # 检查是否包含敏感信息
            if grep -q "password\|secret\|key\|token" "$config_file" 2>/dev/null; then
                log_warning "配置文件可能包含敏感信息: $config_file"
                ((issues_found++))
                ((SECURITY_ISSUES_MEDIUM++))
            fi

            # 检查权限
            local permissions=$(stat -c %a "$config_file" 2>/dev/null || echo "")
            if [ -n "$permissions" ] && [ "${permissions: -1}" -gt "6" ]; then
                log_warning "配置文件权限过宽: $config_file ($permissions)"
                ((issues_found++))
                ((SECURITY_ISSUES_LOW++))
            fi
        fi
    done

    if [ $issues_found -gt 0 ]; then
        log_warning "配置文件安全检查发现 $issues_found 个问题"
        return 1
    else
        log_success "配置文件安全检查通过"
        return 0
    fi
}

# 检查依赖安全
check_dependency_security() {
    log_info "检查依赖安全..."

    local issues_found=0

    # Node.js项目
    if [ -f "package.json" ]; then
        run_npm_audit || ((issues_found++))
        run_snyk_test || ((issues_found++))
    fi

    # Python项目
    if [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        run_bandit_scan || ((issues_found++))
        run_safety_check || ((issues_found++))
    fi

    # Go项目
    if [ -f "go.mod" ]; then
        run_gosec_scan || ((issues_found++))
    fi

    if [ $issues_found -gt 0 ]; then
        log_warning "依赖安全检查发现问题"
        return 1
    else
        log_success "依赖安全检查通过"
        return 0
    fi
}

# 完整安全审计
run_full_security_audit() {
    local target_dir="${1:-.}"

    log_info "开始完整安全审计..."

    # 统计扫描的文件数
    FILES_SCANNED=$(find "$target_dir" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" \) \
                   -not -path "*/node_modules/*" -not -path "*/__pycache__/*" -not -path "*/.*" | wc -l)

    log_info "扫描文件数: $FILES_SCANNED"

    # 执行各项安全检查
    local audit_passed=true

    pattern_based_security_check "$target_dir" || audit_passed=false
    check_config_security || audit_passed=false
    check_dependency_security || audit_passed=false

    # 生成审计报告
    generate_security_report

    if $audit_passed; then
        log_success "安全审计通过"
        return 0
    else
        log_warning "安全审计发现问题，建议修复"
        return 1
    fi
}

# 生成安全审计报告
generate_security_report() {
    log_info "生成安全审计报告..."

    cat << EOF
🔒 安全审计报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 扫描文件数: $FILES_SCANNED
🔍 发现漏洞数: $VULNERABILITIES_FOUND

🚨 安全问题统计:
  🔴 严重: $SECURITY_ISSUES_CRITICAL
  ❌ 高危: $SECURITY_ISSUES_HIGH
  ⚠️  中等: $SECURITY_ISSUES_MEDIUM
  ℹ️  低危: $SECURITY_ISSUES_LOW

🔧 使用的安全工具:
$(for tool in "${!SECURITY_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "  ✅ $tool - ${SECURITY_TOOLS[$tool]}"
    fi
done)

📋 检查的项目:
  ✅ 模式匹配安全检查
  ✅ 配置文件安全检查
  ✅ 依赖安全检查

💡 安全建议:
  🔐 避免硬编码敏感信息
  🛡️  使用参数化查询防止SQL注入
  🔒  定期更新依赖包
  📝  使用环境变量管理配置
  🔍  定期进行安全审计

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

    # 风险等级评估
    local total_issues=$((SECURITY_ISSUES_CRITICAL + SECURITY_ISSUES_HIGH + SECURITY_ISSUES_MEDIUM + SECURITY_ISSUES_LOW))

    if [ $SECURITY_ISSUES_CRITICAL -gt 0 ]; then
        log_critical "🚨 严重风险: 发现严重安全问题，需立即修复！"
    elif [ $SECURITY_ISSUES_HIGH -gt 0 ]; then
        log_error "❌ 高风险: 发现高危安全问题，建议尽快修复"
    elif [ $total_issues -gt 0 ]; then
        log_warning "⚠️ 中等风险: 发现一般安全问题，建议改进"
    else
        log_success "✅ 安全状态良好"
    fi
}

# 主函数
main() {
    local command="$1"
    shift

    case "$command" in
        "audit")
            local target_dir="${1:-.}"
            if run_full_security_audit "$target_dir"; then
                log_success "安全审计完成"
            else
                log_warning "安全审计完成，发现问题"
            fi
            ;;
        "pattern")
            local target_dir="${1:-.}"
            pattern_based_security_check "$target_dir"
            ;;
        "config")
            check_config_security
            ;;
        "deps")
            check_dependency_security
            ;;
        "detect")
            detect_security_tools
            ;;
        "report")
            generate_security_report
            ;;
        *)
            echo "用法: $0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  audit [target_dir]    执行完整安全审计"
            echo "  pattern [target_dir]  模式匹配安全检查"
            echo "  config                检查配置文件安全"
            echo "  deps                  检查依赖安全"
            echo "  detect                检测可用的安全工具"
            echo "  report                生成安全审计报告"
            echo ""
            echo "示例:"
            echo "  $0 audit              # 完整安全审计"
            echo "  $0 pattern src        # 检查src目录"
            echo "  $0 config             # 检查配置文件"
            return 1
            ;;
    esac
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi