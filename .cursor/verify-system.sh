#!/bin/bash

###############################################################################
# .cursor 系统验证脚本
#
# 功能：
# - 验证系统组件完整性
# - 检查文件结构
# - 验证调用链
# - 生成验证报告
#
# 使用方法：
#   ./verify-system.sh              # 完整验证
#   ./verify-system.sh --quick      # 快速验证
#   ./verify-system.sh --json       # JSON格式输出
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_DIR="$PROJECT_ROOT/.cursor"

# 输出模式
OUTPUT_MODE="text"
QUICK_MODE=false

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

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "  $1"
}

###############################################################################
# 验证函数
###############################################################################

verify_directory() {
    local dir="$1"
    local name="$2"
    
    if [ -d "$dir" ]; then
        print_success "$name 目录存在: $dir"
        return 0
    else
        print_error "$name 目录不存在: $dir"
        return 1
    fi
}

verify_file() {
    local file="$1"
    local name="$2"
    
    if [ -f "$file" ]; then
        print_success "$name 文件存在: $file"
        return 0
    else
        print_error "$name 文件不存在: $file"
        return 1
    fi
}

verify_json() {
    local file="$1"
    local name="$2"
    
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
            print_success "$name JSON格式正确"
            return 0
        else
            print_error "$name JSON格式错误"
            return 1
        fi
    else
        print_warning "未安装python3，跳过JSON验证"
        return 0
    fi
}

count_files() {
    local dir="$1"
    local pattern="$2"
    
    find "$dir" -name "$pattern" -type f 2>/dev/null | wc -l
}

###############################################################################
# 组件验证
###############################################################################

verify_agents() {
    print_section "验证 Agents 系统"
    
    local agents_dir="$CURSOR_DIR/agents"
    verify_directory "$agents_dir" "Agents" || return 1
    
    # 检查command-center
    local command_center="$agents_dir/command-center.md"
    verify_file "$command_center" "command-center Agent"
    
    # 统计
    local agent_count=$(find "$agents_dir" -name "*.md" -type f | wc -l)
    print_info "Agent总数: $agent_count"
}

verify_commands() {
    print_section "验证 Commands 系统"
    
    local commands_dir="$CURSOR_DIR/commands"
    verify_directory "$commands_dir" "Commands" || return 1
    
    # 检查关键文件
    verify_file "$commands_dir/master.md" "Master命令"
    verify_file "$commands_dir/master-handler.js" "Master处理器"
    verify_file "$commands_dir/master-router.js" "Master路由器"
    verify_file "$commands_dir/vibe.md" "VIBE命令"
    
    # 统计
    local cmd_files=$(count_files "$commands_dir" "*.md")
    local js_files=$(count_files "$commands_dir" "*.js")
    local json_files=$(count_files "$commands_dir" "*.json")
    print_info "命令文件: $cmd_files 个"
    print_info "处理器脚本: $js_files 个"
    print_info "配置文件: $json_files 个"
}

verify_skills() {
    print_section "验证 Skills 系统"
    
    # 项目技能
    local skills_dir="$CURSOR_DIR/skills"
    verify_directory "$skills_dir" "项目Skills" || return 1
    
    local dispatcher="$skills_dir/skill-dispatcher/SKILL.md"
    verify_file "$dispatcher" "skill-dispatcher"
    
    # 技能库
    local features_dir="$CURSOR_DIR/features/skills"
    verify_directory "$features_dir" "技能库" || return 1
    
    # 检查注册表
    local registry="$features_dir/registry.json"
    verify_file "$registry" "技能注册表"
    verify_json "$registry" "技能注册表"
    
    # 统计
    local skill_count=$(find "$features_dir" -maxdepth 1 -name "*.md" -type f | wc -l)
    print_info "项目技能目录: $(find "$skills_dir" -maxdepth 1 -type d | tail -n +2 | wc -l) 个"
    print_info "技能库技能: $skill_count 个"
}

verify_core() {
    print_section "验证 Core 脚本系统"
    
    local core_dir="$CURSOR_DIR/core"
    verify_directory "$core_dir" "Core" || return 1
    
    # 检查关键脚本
    verify_file "$core_dir/init.sh" "初始化脚本"
    verify_file "$core_dir/env-perception.sh" "环境感知"
    verify_file "$core_dir/context-manager.sh" "上下文管理"
    verify_file "$core_dir/quality-manager.sh" "质量管理"
    verify_file "$core_dir/git-manager.sh" "Git管理"
    
    # 统计
    local script_count=$(count_files "$core_dir" "*.sh")
    local js_count=$(count_files "$core_dir" "*.js")
    print_info "Shell脚本: $script_count 个"
    print_info "JavaScript文件: $js_count 个"
}

verify_config() {
    print_section "验证 Config 配置系统"
    
    local config_dir="$CURSOR_DIR/config"
    verify_directory "$config_dir" "Config" || return 1
    
    # 统计
    local config_count=$(find "$config_dir" -type f | wc -l)
    print_info "配置文件: $config_count 个"
}

verify_rules() {
    print_section "验证 Rules 规则系统"
    
    local rules_dir="$CURSOR_DIR/rules"
    verify_directory "$rules_dir" "Rules" || return 1
    
    # 统计
    local rule_count=$(find "$rules_dir" -name "*.md" -type f | wc -l)
    print_info "规则文件: $rule_count 个"
}

verify_hooks() {
    print_section "验证 Hooks 钩子系统"
    
    local hooks_dir="$CURSOR_DIR/features/hooks"
    verify_directory "$hooks_dir" "Hooks" || return 1
    
    # 统计
    local hook_count=$(find "$hooks_dir" -name "*.sh" -type f | wc -l)
    print_info "钩子脚本: $hook_count 个"
}

verify_docs() {
    print_section "验证文档系统"
    
    # 检查新增文档
    verify_file "$CURSOR_DIR/ARCHITECTURE.md" "架构文档"
    verify_file "$CURSOR_DIR/CALL_CHAIN.md" "调用链文档"
    verify_file "$CURSOR_DIR/SKILL_GUIDE.md" "技能指南"
    
    local docs_dir="$CURSOR_DIR/docs"
    if [ -d "$docs_dir" ]; then
        local doc_count=$(find "$docs_dir" -name "*.md" -type f | wc -l)
        print_info "文档文件: $doc_count 个"
    fi
}

verify_call_chain() {
    print_section "验证调用链"
    
    # 检查关键组件
    local command_center="$CURSOR_DIR/agents/command-center.md"
    local skill_dispatcher="$CURSOR_DIR/skills/skill-dispatcher/SKILL.md"
    local registry="$CURSOR_DIR/features/skills/registry.json"
    
    if [ -f "$command_center" ] && [ -f "$skill_dispatcher" ] && [ -f "$registry" ]; then
        print_success "调用链组件完整"
        print_info "command-center → skill-dispatcher → features/skills/"
    else
        print_error "调用链组件不完整"
        return 1
    fi
}

verify_consistency() {
    print_section "验证系统一致性"
    
    # 检查路径引用
    if grep -r "\.cursor/skills/" "$CURSOR_DIR/agents/" 2>/dev/null | grep -q "features/skills"; then
        print_success "技能路径引用一致"
    else
        print_warning "建议统一技能路径引用"
    fi
    
    # 检查文档版本
    local version=$(grep "文档版本" "$CURSOR_DIR/ARCHITECTURE.md" 2>/dev/null | head -1)
    if [ -n "$version" ]; then
        print_success "文档版本信息: $version"
    fi
}

###############################################################################
# 统计与报告
###############################################################################

generate_statistics() {
    print_section "系统统计"
    
    local total_agents=$(find "$CURSOR_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l)
    local total_commands=$(find "$CURSOR_DIR/commands" -name "*.md" -type f 2>/dev/null | wc -l)
    local total_skills=$(find "$CURSOR_DIR/features/skills" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
    local total_core=$(find "$CURSOR_DIR/core" -name "*.sh" -type f 2>/dev/null | wc -l)
    local total_rules=$(find "$CURSOR_DIR/rules" -name "*.md" -type f 2>/dev/null | wc -l)
    local total_hooks=$(find "$CURSOR_DIR/features/hooks" -name "*.sh" -type f 2>/dev/null | wc -l)
    
    echo -e "${BLUE}系统组件统计：${NC}"
    echo "  Agents:        $total_agents 个"
    echo "  Commands:      $total_commands 个"
    echo "  Skills:        $total_skills 个"
    echo "  Core Scripts:  $total_core 个"
    echo "  Rules:         $total_rules 个"
    echo "  Hooks:         $total_hooks 个"
}

generate_report() {
    print_header "验证完成"
    
    # 计算总耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo -e "${GREEN}✓ 验证完成${NC}"
    echo -e "  耗时: ${duration}秒"
    echo -e "  模式: $OUTPUT_MODE"
    
    # 建议
    if [ "$ERRORS_FOUND" -eq 0 ]; then
        echo -e "\n${GREEN}系统状态: 良好 ✓${NC}"
    else
        echo -e "\n${YELLOW}发现 $ERRORS_FOUND 个问题，建议修复${NC}"
    fi
}

###############################################################################
# 主流程
###############################################################################

main() {
    local start_time=$(date +%s)
    local ERRORS_FOUND=0
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                QUICK_MODE=true
                shift
                ;;
            --json)
                OUTPUT_MODE="json"
                shift
                ;;
            *)
                echo "未知参数: $1"
                exit 1
                ;;
        esac
    done
    
    print_header ".cursor 系统验证"
    
    echo -e "项目路径: $PROJECT_ROOT"
    echo -e "配置目录: $CURSOR_DIR"
    echo -e "验证时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 执行验证
    verify_agents || ERRORS_FOUND=$((ERRORS_FOUND + 1))
    verify_commands || ERRORS_FOUND=$((ERRORS_FOUND + 1))
    verify_skills || ERRORS_FOUND=$((ERRORS_FOUND + 1))
    verify_core || ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if [ "$QUICK_MODE" = false ]; then
        verify_config || ERRORS_FOUND=$((ERRORS_FOUND + 1))
        verify_rules || ERRORS_FOUND=$((ERRORS_FOUND + 1))
        verify_hooks || ERRORS_FOUND=$((ERRORS_FOUND + 1))
        verify_docs || ERRORS_FOUND=$((ERRORS_FOUND + 1))
        verify_call_chain || ERRORS_FOUND=$((ERRORS_FOUND + 1))
        verify_consistency || ERRORS_FOUND=$((ERRORS_FOUND + 1))
        generate_statistics
    fi
    
    # 生成报告
    generate_report
    
    exit $ERRORS_FOUND
}

# 运行主流程
main "$@"
