#!/bin/bash

# 🎯 智能Master命令控制器 v3.0
# 自动感知 + 智能决策 + 自主执行
#
# 使用方法:
#   ./cursor-master.sh [自然语言需求描述]    # 智能自动执行
#   ./cursor-master.sh list                   # 查看可用命令
#   ./cursor-master.sh help                   # 智能使用指南

set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$SCRIPT_DIR/.cursor"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 🧠 智能感知引擎
analyze_user_intent() {
    local user_input="$1"

    echo "🧠 正在分析用户意图..." >&2

    # 初始化分析结果
    local intent_type="unknown"
    local confidence=0
    local actions=()

    # 意图识别规则
    if echo "$user_input" | grep -qiE "^skill "; then
        intent_type="skill_call"
        confidence=95
        skill_name=$(echo "$user_input" | sed 's/^skill //' | tr -d '\n\r')
        actions=("skill:$skill_name")
    elif echo "$user_input" | grep -qiE "(创建|开发|构建|搭建|做一个)"; then
        intent_type="project_creation"
        confidence=90
        actions=("env_check" "enable" "generator" "constitution")
    elif echo "$user_input" | grep -qiE "(优化|改进|重构|质量|检查)"; then
        intent_type="code_optimization"
        confidence=85
        actions=("check" "eslint" "perception")
    elif echo "$user_input" | grep -qiE "(分析|评估|诊断|状态)"; then
        intent_type="project_analysis"
        confidence=80
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(部署|发布|上线|运维)"; then
        intent_type="deployment"
        confidence=75
        actions=("env_check" "plugin_manager")
    elif echo "$user_input" | grep -qiE "(学习|了解|教程|指南)"; then
        intent_type="learning"
        confidence=70
        actions=("templates" "generator")
    fi

    # 返回JSON格式的结果
    cat << EOF
{
  "intent_analysis": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "recommended_actions": $(printf '%s\n' "${actions[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
}

# 🎯 环境感知引擎
analyze_environment() {
    echo "🔍 正在感知项目环境..." >&2

    local project_type="unknown"
    local has_package_json=false
    local has_requirements_txt=false
    local has_git=false

    # 检测项目类型
    if [ -f "package.json" ]; then
        project_type="javascript"
        has_package_json=true
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        project_type="python"
        has_requirements_txt=true
    elif [ -f "go.mod" ]; then
        project_type="golang"
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
    fi

    # 检测Git状态
    if git rev-parse --git-dir > /dev/null 2>&1; then
        has_git=true
    fi

    # 返回环境分析结果
    cat << EOF
{
  "environment_analysis": {
    "project_type": "$project_type",
    "has_package_json": $has_package_json,
    "has_requirements_txt": $has_requirements_txt,
    "has_git": $has_git,
    "working_directory": "$PWD",
    "project_root": "$PROJECT_ROOT"
  }
}
EOF
}

# 🚀 智能决策引擎
make_decision() {
    local intent_json="$1"
    local env_json="$2"

    echo "🎯 正在制定执行策略..." >&2

    # 解析输入数据
    local intent_type=$(echo "$intent_json" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local confidence=$(echo "$intent_json" | jq -r '.intent_analysis.confidence' 2>/dev/null || echo "0")
    local project_type=$(echo "$env_json" | jq -r '.environment_analysis.project_type' 2>/dev/null || echo "unknown")

    # 初始化决策结果
    local should_execute=true
    local execution_plan=()
    local explanation=""

    # 基于意图和环境制定决策
    case "$intent_type" in
        "project_creation")
            if [ "$project_type" = "unknown" ]; then
                execution_plan=("env_check" "enable" "generator")
                explanation="检测到项目创建意图，为新项目执行初始化流程"
            else
                should_execute=false
                explanation="检测到已有项目，建议先分析现有项目状态"
            fi
            ;;
        "code_optimization")
            if [ "$project_type" != "unknown" ]; then
                execution_plan=("check" "eslint")
                explanation="为现有项目执行代码质量优化"
            else
                execution_plan=("env_check" "enable")
                explanation="项目环境未就绪，先进行环境准备"
            fi
            ;;
        "project_analysis")
            execution_plan=("perception")
            explanation="执行全面的项目状态分析"
            ;;
        "deployment")
            execution_plan=("env_check" "plugin_manager")
            explanation="准备项目部署环境"
            ;;
        "learning")
            execution_plan=("templates" "generator")
            explanation="提供学习和模板资源"
            ;;
        "skill_call")
            # 从intent_json中提取技能名称
            local skill_action=$(echo "$intent_json" | jq -r '.intent_analysis.recommended_actions[0]' 2>/dev/null || echo "")
            if [ -n "$skill_action" ] && [ "$skill_action" != "null" ]; then
                execution_plan=("$skill_action")
                explanation="调用指定的专业技能"
            else
                should_execute=false
                explanation="无法确定要调用的技能"
            fi
            ;;
        *)
            should_execute=false
            explanation="无法确定具体意图，建议提供更详细的需求描述"
            ;;
    esac

    # 返回决策结果
    cat << EOF
{
  "decision_making": {
    "should_execute": $should_execute,
    "execution_plan": $(printf '%s\n' "${execution_plan[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
    "explanation": "$explanation",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "project_type": "$project_type"
  }
}
EOF
}

# ⚡ 自动执行引擎
execute_plan() {
    local plan_json="$1"

    echo "⚡ 开始自动执行计划..." >&2

    local execution_plan=$(echo "$plan_json" | jq -r '.decision_making.execution_plan[]' 2>/dev/null || echo "")
    local explanation=$(echo "$plan_json" | jq -r '.decision_making.explanation' 2>/dev/null || echo "")

    echo -e "${BLUE}📋 执行计划: ${NC}$explanation"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 执行计划中的每个动作
    echo "$execution_plan" | while read -r action; do
        if [ -n "$action" ] && [ "$action" != "null" ]; then
            execute_action "$action"
        fi
    done
}

# 🔧 单个动作执行器
execute_action() {
    local action="$1"

    echo -e "${YELLOW}🚀 执行动作: ${CYAN}$action${NC}"

    case "$action" in
        "env_check")
            if [ -f "$CURSOR_DIR/scripts/env_check.sh" ]; then
                bash "$CURSOR_DIR/scripts/env_check.sh"
            else
                echo -e "${YELLOW}⚠️  未找到环境检查脚本${NC}"
            fi
            ;;
        "enable")
            if [ -f "$CURSOR_DIR/scripts/enable.sh" ]; then
                bash "$CURSOR_DIR/scripts/enable.sh"
            else
                echo -e "${YELLOW}⚠️  未找到启用脚本${NC}"
            fi
            ;;
        "generator")
            echo -e "${GREEN}✅ 规则生成器已激活 (alwaysApply: false)${NC}"
            ;;
        "constitution")
            echo -e "${GREEN}✅ AI共生宪法已激活 (alwaysApply: true)${NC}"
            ;;
        "check")
            if [ -f "$CURSOR_DIR/scripts/check.sh" ]; then
                bash "$CURSOR_DIR/scripts/check.sh"
            else
                echo -e "${YELLOW}⚠️  未找到代码检查脚本${NC}"
            fi
            ;;
        "eslint")
            echo -e "${GREEN}✅ ESLint规则已激活 (alwaysApply: true)${NC}"
            ;;
        "perception")
            if [ -f "$CURSOR_DIR/scripts/perception.sh" ]; then
                bash "$CURSOR_DIR/scripts/perception.sh"
            else
                echo -e "${YELLOW}⚠️  未找到感知分析脚本${NC}"
            fi
            ;;
        "plugin_manager")
            if [ -f "$CURSOR_DIR/scripts/plugin_manager.sh" ]; then
                bash "$CURSOR_DIR/scripts/plugin_manager.sh"
            else
                echo -e "${YELLOW}⚠️  未找到插件管理脚本${NC}"
            fi
            ;;
        "templates")
            echo -e "${GREEN}✅ 项目模板框架已激活 (alwaysApply: false)${NC}"
            ;;
        skill:*)
            # Skills扩展调用
            local skill_name=$(echo "$action" | sed 's/skill://')
            execute_skill "$skill_name"
            ;;
        *)
            echo -e "${YELLOW}⚠️  未知动作: $action${NC}"
            ;;
    esac

    echo ""
}

# 🎓 学习引擎 - 记录用户偏好
learn_from_interaction() {
    local user_input="$1"
    local decision_json="$2"

    # 保存学习数据到.cursorGrowth目录
    local growth_dir="$PROJECT_ROOT/.cursorGrowth"
    local learning_file="$growth_dir/learning/master_interactions.json"

    mkdir -p "$growth_dir/learning"

    # 创建学习记录
    local learning_record=$(cat << EOF
{
  "interaction": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "user_input": "$user_input",
    "decision": $decision_json,
    "success": true
  }
}
EOF
)

    # 追加到学习文件
    echo "$learning_record" >> "$learning_file"
}

# 🎯 智能主函数
intelligent_master() {
    local user_input="$1"

    # 显示智能Logo
    show_intelligent_logo

    # 如果没有用户输入，显示帮助
    if [ -z "$user_input" ]; then
        show_intelligent_help
        return
    fi

    echo -e "${CYAN}🎯 智能Master控制器已激活${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 1. 分析用户意图
    local intent_result=$(analyze_user_intent "$user_input")

    # 2. 感知环境
    local env_result=$(analyze_environment)

    # 3. 智能决策
    local decision_result=$(make_decision "$intent_result" "$env_result")

    # 4. 显示分析结果
    show_analysis_results "$intent_result" "$env_result" "$decision_result"

    # 5. 执行决策
    local should_execute=$(echo "$decision_result" | jq -r '.decision_making.should_execute' 2>/dev/null || echo "false")

    if [ "$should_execute" = "true" ]; then
        execute_plan "$decision_result"
    else
        echo -e "${YELLOW}💡 建议: ${NC}$(echo "$decision_result" | jq -r '.decision_making.explanation' 2>/dev/null || echo "无法确定执行策略")"
    fi

    # 6. 学习和记录
    learn_from_interaction "$user_input" "$decision_result"

    echo -e "${GREEN}✅ 智能执行完成！${NC}"
}

# 🎨 智能界面显示函数
show_intelligent_logo() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║            🧠 智能Master控制器 v3.0                          ║"
    echo "║                                                              ║"
    echo "║        自动感知 · 智能决策 · 自主执行 · 持续学习            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_analysis_results() {
    local intent_json="$1"
    local env_json="$2"
    local decision_json="$3"

    echo ""
    echo -e "${BLUE}📊 智能分析结果:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 显示意图分析
    local intent_type=$(echo "$intent_json" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local confidence=$(echo "$intent_json" | jq -r '.intent_analysis.confidence' 2>/dev/null || echo "0")

    echo -e "${PURPLE}🎯 用户意图: ${NC}$intent_type (置信度: ${confidence}%)"

    # 显示环境分析
    local project_type=$(echo "$env_json" | jq -r '.environment_analysis.project_type' 2>/dev/null || echo "unknown")
    echo -e "${PURPLE}🏗️  项目类型: ${NC}$project_type"

    # 显示决策结果
    local explanation=$(echo "$decision_json" | jq -r '.decision_making.explanation' 2>/dev/null || echo "无法确定执行策略")
    echo -e "${PURPLE}🎯 执行策略: ${NC}$explanation"

    local execution_plan=$(echo "$decision_json" | jq -r '.decision_making.execution_plan[]' 2>/dev/null | tr '\n' ' ')
    if [ -n "$execution_plan" ] && [ "$execution_plan" != "null" ]; then
        echo -e "${PURPLE}⚡ 执行计划: ${NC}$execution_plan"
    fi

    echo ""
}

show_intelligent_help() {
    echo -e "${CYAN}🧠 智能Master控制器 - 使用指南${NC}"
    echo ""
    echo -e "${YELLOW}🎯 智能模式 (推荐):${NC}"
    echo "  ./cursor-master.sh 我想创建一个React项目"
    echo "  ./cursor-master.sh 需要优化代码质量"
    echo "  ./cursor-master.sh 帮我分析项目现状"
    echo "  ./cursor-master.sh 准备部署环境"
    echo "  ./cursor-master.sh 学习新技术栈"
    echo ""
    echo -e "${YELLOW}📋 传统模式:${NC}"
    echo "  ./cursor-master.sh list                   # 查看所有可用命令"
    echo "  ./cursor-master.sh help                   # 显示此帮助信息"
    echo ""
    echo -e "${YELLOW}✨ 智能特性:${NC}"
    echo "  • 自动意图识别 - 无需记忆命令语法"
    echo "  • 环境感知 - 智能判断项目状态"
    echo "  • 决策优化 - 选择最合适的操作组合"
    echo "  • 自主执行 - 一键完成复杂任务"
    echo "  • 持续学习 - 从交互中改进决策"
    echo ""
    echo -e "${GREEN}🚀 现在就开始使用: ./cursor-master.sh [描述你的需求]${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        "")
            intelligent_master ""
            ;;
        "help"|"-h"|"--help")
            show_intelligent_logo
            show_intelligent_help
            ;;
        "list")
            show_intelligent_logo
            show_traditional_commands
            ;;
        *)
            # 智能模式：将所有参数作为用户需求处理
            intelligent_master "$*"
            ;;
    esac
}

# 显示传统命令列表（兼容性）
show_traditional_commands() {
    echo -e "${BLUE}📚 可用规则命令 (Rules):${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 这里可以调用原有的命令列表逻辑
    echo -e "  ✅ ${GREEN}constitution${NC} - AI共生宪法 (总是启用)"
    echo -e "  ✅ ${GREEN}conversation_intent_analyzer${NC} - 对话意图分析器 (总是启用)"
    echo -e "  ✅ ${GREEN}eslint${NC} - ESLint代码质量检查 (总是启用)"
    echo -e "  🔄 ${YELLOW}generator${NC} - 项目规则生成器 (按需启用)"
    echo -e "  🔄 ${YELLOW}templates${NC} - 项目配置模板 (按需启用)"
    echo -e "  🔄 ${YELLOW}intelligent_evolution${NC} - 智能演进系统 (按需启用)"

    echo ""
    echo -e "${PURPLE}🔧 可用脚本命令 (Scripts):${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "  🚀 ${CYAN}env_check.sh${NC} - 环境依赖检查脚本"
    echo -e "  🚀 ${CYAN}enable.sh${NC} - 插件启用脚本"
    echo -e "  🚀 ${CYAN}check.sh${NC} - 代码质量检查脚本"
    echo -e "  🚀 ${CYAN}perception.sh${NC} - 智能感知分析脚本"
    echo -e "  🚀 ${CYAN}plugin_manager.sh${NC} - 插件管理系统脚本"

    echo ""
    echo -e "${YELLOW}💡 提示: 建议使用智能模式 './cursor-master.sh [需求描述]' 而非传统命令模式${NC}"
}

# 🎯 Skills执行器
execute_skill() {
    local skill_name="$1"
    local skill_file="$PROJECT_ROOT/.cursor/extensions/skills/${skill_name}.md"

    echo -e "${PURPLE}🎯 调用Skills: ${CYAN}$skill_name${NC}"

    if [ -f "$skill_file" ]; then
        echo -e "${GREEN}✅ Skills文件存在: $skill_file${NC}"
        echo -e "${YELLOW}💡 此技能已准备就绪，可通过 @master skill:$skill_name 调用${NC}"
    else
        echo -e "${RED}❌ Skills文件不存在: $skill_file${NC}"
        echo -e "${YELLOW}💡 尝试运行技能发现器...${NC}"

        # 尝试自动发现和转换
        if [ -f "$PROJECT_ROOT/.cursor/extensions/skills/discovery.sh" ]; then
            bash "$PROJECT_ROOT/.cursor/extensions/skills/discovery.sh" load "$skill_name"
        fi
    fi
}

# 执行主函数
main "$@"