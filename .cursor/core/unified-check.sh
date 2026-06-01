#!/bin/bash

###############################################################################
# .cursor 统一验证脚本
#
# 功能整合：
# - 系统完整性验证
# - 规则最佳实践检查
# - 系统健康检查
#
# 使用方法：
#   .cursor/check.sh              # 完整验证
#   .cursor/check.sh --quick      # 快速验证
#   .cursor/check.sh --rules      # 仅检查规则
#   .cursor/check.sh --system     # 仅检查系统
###############################################################################

set -e

# 项目路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CURSOR_DIR="$PROJECT_ROOT/.cursor"

# 参数解析
QUICK_MODE=false
CHECK_RULES=true
CHECK_SYSTEM=true

for arg in "$@"; do
    case $arg in
        --quick) QUICK_MODE=true ;;
        --rules) CHECK_SYSTEM=false ;;
        --system) CHECK_RULES=false ;;
        --help)
            echo "用法: .cursor/check.sh [选项]"
            echo "选项:"
            echo "  --quick    快速验证"
            echo "  --rules    仅检查规则最佳实践"
            echo "  --system   仅检查系统完整性"
            echo "  --help     显示帮助"
            exit 0
            ;;
    esac
done

###############################################################################
# 辅助函数
###############################################################################

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_section() {
    echo -e "\n${GREEN}▶ $1${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

###############################################################################
# 系统完整性验证
###############################################################################

verify_system() {
    print_header "系统完整性验证"
    
    local errors=0
    
    # 目录结构验证
    print_section "目录结构检查"
    
    DIRS=("agents" "commands" "config" "rules" "core" "features" "skills" "docs")
    for dir in "${DIRS[@]}"; do
        if [[ -d "$CURSOR_DIR/$dir" ]]; then
            print_success "$dir/ 目录存在"
        else
            print_error "$dir/ 目录缺失"
            errors=$((errors + 1))
        fi
    done
    
    # 系统统计
    print_section "系统统计"
    
    local agent_count=$(find "$CURSOR_DIR/agents" -name "*.md" 2>/dev/null | wc -l)
    local command_count=$(find "$CURSOR_DIR/commands" -name "*.md" 2>/dev/null | wc -l)
    local rule_count=$(find "$CURSOR_DIR/rules" -name "*.mdc" 2>/dev/null | wc -l)
    local skill_count=$(find "$CURSOR_DIR/skills" -mindepth 2 -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l)
    
    echo "  Agents: $agent_count 个"
    echo "  Commands: $command_count 个"
    echo "  Rules: $rule_count 个"
    echo "  Skills: $skill_count 个"
    
    # Hook 脚本：禁止将 \" 写入路径（会导致仓库根下畸形 " 目录）
    print_section "Hook 脚本路径引号检查"
    local hook_quote_errors=0
    while IFS= read -r -d '' hook_file; do
        if grep -qE 'log_to_file \\"|case \\"\$|local [a-z_]+=\\"|>> \\$' "$hook_file" 2>/dev/null; then
            print_error "Hook 含错误转义引号: ${hook_file#$PROJECT_ROOT/}"
            hook_quote_errors=$((hook_quote_errors + 1))
        fi
    done < <(find "$CURSOR_DIR/hooks" "$CURSOR_DIR/features/hooks" -name '*.sh' -print0 2>/dev/null)
    if [[ $hook_quote_errors -eq 0 ]]; then
        print_success "Hook 脚本路径引号检查通过"
    else
        errors=$((errors + hook_quote_errors))
    fi

    return $errors
}

###############################################################################
# 规则最佳实践检查
###############################################################################

verify_rules() {
    print_header "规则最佳实践检查"
    
    local RULES_DIR="$CURSOR_DIR/rules"
    local total=0
    local with_globs_or_always=0
    local with_priority=0
    local with_examples=0
    local command_style=0
    local too_long=0
    local rule_ref_errors=0
    
    # 遍历规则文件
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            total=$((total + 1))
            
            local has_globs_or_always=false
            local has_priority=false
            
            while IFS= read -r line; do
                if [[ "$line" == "---" ]] && [[ $has_globs_or_always == true || $has_priority == true ]]; then
                    break
                fi
                
                if [[ "$line" =~ ^globs: ]] || [[ "$line" =~ alwaysApply: ]]; then
                    has_globs_or_always=true
                fi
                
                if [[ "$line" =~ priority: ]]; then
                    has_priority=true
                fi
            done < "$file"
            
            [[ "$has_globs_or_always" == true ]] && with_globs_or_always=$((with_globs_or_always + 1))
            [[ "$has_priority" == true ]] && with_priority=$((with_priority + 1))
            grep -q '```' "$file" && with_examples=$((with_examples + 1))
            grep -qiE 'MUST|NEVER|ALWAYS|DO NOT|REQUIRED|禁止|必须' "$file" && command_style=$((command_style + 1))
            
            local lines=$(wc -l < "$file")
            [[ $lines -gt 500 ]] && too_long=$((too_long + 1))

            if grep -qE '@[a-zA-Z0-9_-]+\.mdc?\b' "$file" 2>/dev/null; then
                print_error "规则含非官方 @ 引用（应使用 @规则名 无后缀）: ${file#$PROJECT_ROOT/}"
                rule_ref_errors=$((rule_ref_errors + 1))
            fi
            if grep -q 'RULE\.md' "$file" 2>/dev/null; then
                print_error "规则仍引用已废弃 RULE.md 布局: ${file#$PROJECT_ROOT/}"
                rule_ref_errors=$((rule_ref_errors + 1))
            fi
        fi
    done < <(find "$RULES_DIR" -type f -name "*.mdc" -print0)
    
    # 输出统计
    print_section "合规性统计"
    
    if [[ $total -eq 0 ]]; then
        print_error "未找到 .mdc 规则文件"
        return 1
    fi
    
    local percent_globs=$((with_globs_or_always * 100 / total))
    local percent_priority=$((with_priority * 100 / total))
    local percent_examples=$((with_examples * 100 / total))
    local percent_command=$((command_style * 100 / total))
    
    echo "  总规则数: $total"
    echo -e "${GREEN}包含globs/alwaysApply: $with_globs_or_always (${percent_globs}%)${NC}"
    echo -e "${GREEN}包含priority: $with_priority (${percent_priority}%)${NC}"
    echo -e "${GREEN}包含代码示例: $with_examples (${percent_examples}%)${NC}"
    echo -e "${GREEN}使用命令式语言: $command_style (${percent_command}%)${NC}"
    echo -e "${YELLOW}文件过长(>500行): $too_long${NC}"
    
    local compliance_score=$(( (with_globs_or_always + with_priority) * 100 / (total * 2) ))
    echo -e "\n总体合规性: ${compliance_score}%"
    
    if [[ $rule_ref_errors -gt 0 ]]; then
        print_error "发现 $rule_ref_errors 处非官方规则引用或 RULE.md 残留"
        return 1
    fi

    if [[ $compliance_score -eq 100 ]]; then
        print_success "所有规则都符合最佳实践！"
        return 0
    else
        print_error "存在不符合最佳实践的规则"
        return 1
    fi
}

###############################################################################
# 主函数
###############################################################################

main() {
    local exit_code=0
    
    echo -e "${BLUE}"
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║        .cursor 系统统一验证                              ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "项目路径: $PROJECT_ROOT"
    echo "验证时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    [[ "$CHECK_SYSTEM" == true ]] && verify_system || exit_code=$?
    [[ "$CHECK_RULES" == true ]] && verify_rules || exit_code=$?
    
    print_header "验证完成"
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "系统状态: 良好 ✓"
    else
        print_error "系统状态: 发现问题，需要修复"
    fi
    
    exit $exit_code
}

main "$@"
