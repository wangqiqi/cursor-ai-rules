#!/bin/bash

# 🚀 Cursor AI Rules - 智能Git提交助手
# 自动分析变更、生成提交信息、执行安全提交

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 显示Logo
show_logo() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║              🚀 智能Git提交助手 v2.0                        ║"
    echo "║                                                              ║"
    echo "║        自动分析 · 智能提交 · 安全推送 · 质量保证            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查Git状态
check_git_status() {
    echo -e "${BLUE}🔍 检查Git状态...${NC}"

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ 错误: 当前目录不是Git仓库${NC}"
        exit 1
    fi

    # 检查是否有未暂存的更改
    if [ -z "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}⚠️  没有发现未暂存的更改${NC}"
        echo -e "${YELLOW}💡 可能所有更改都已提交，或需要先添加文件${NC}"
        exit 0
    fi

    echo -e "${GREEN}✅ Git仓库状态正常${NC}"
}

# 分析变更内容
analyze_changes() {
    echo -e "${BLUE}📊 分析变更内容...${NC}"

    # 获取变更统计
    local stats=$(git diff --cached --stat 2>/dev/null || git diff --stat)

    if [ -n "$stats" ]; then
        echo -e "${CYAN}📈 变更统计:${NC}"
        echo "$stats"
        echo ""
    fi

    # 分析变更类型
    local change_types=""
    local has_code_changes=false
    local has_config_changes=false
    local has_docs_changes=false

    # 检查暂存区变更
    if git diff --cached --name-only | grep -q '\.js\|\.ts\|\.py\|\.java\|\.cpp\|\.c\|\.go\|\.rs\|\.php\|\.rb\|\.swift\|\.kt\|\.scala\|\.clj\|\.hs\|\.ml\|\.fs\|\.vb\|\.cs'; then
        change_types="${change_types}代码修改 "
        has_code_changes=true
    fi

    if git diff --cached --name-only | grep -q '\.json\|\.yaml\|\.yml\|\.toml\|\.ini\|\.cfg\|\.conf\|\.properties\|\.env'; then
        change_types="${change_types}配置更新 "
        has_config_changes=true
    fi

    if git diff --cached --name-only | grep -q '\.md\|\.txt\|\.rst\|\.adoc\|\.pdf\|\.doc\|\.docx'; then
        change_types="${change_types}文档更新 "
        has_docs_changes=true
    fi

    # 检查是否有新增/删除文件
    if git diff --cached --name-status | grep -q '^A\|^D\|^R'; then
        change_types="${change_types}文件变更 "
    fi

    if [ -z "$change_types" ]; then
        change_types="其他修改"
    fi

    echo -e "${CYAN}🔧 变更类型: ${NC}$change_types"

    # 返回变更信息
    echo "{\"change_types\":\"$change_types\",\"has_code\":$has_code_changes,\"has_config\":$has_config_changes,\"has_docs\":$has_docs_changes}"
}

# 生成智能提交信息
generate_commit_message() {
    local change_info="$1"

    echo -e "${BLUE}🤖 生成智能提交信息...${NC}"

    # 解析变更信息
    local change_types=$(echo "$change_info" | jq -r '.change_types')
    local has_code=$(echo "$change_info" | jq -r '.has_code')
    local has_config=$(echo "$change_info" | jq -r '.has_config')
    local has_docs=$(echo "$change_info" | jq -r '.has_docs')

    # 基于变更类型生成提交信息
    local commit_prefix=""
    local commit_body=""

    if [ "$has_code" = "true" ] && [ "$has_config" = "false" ] && [ "$has_docs" = "false" ]; then
        commit_prefix="feat"
        commit_body="实现新功能或修复代码问题"
    elif [ "$has_config" = "true" ]; then
        commit_prefix="config"
        commit_body="更新配置文件和项目设置"
    elif [ "$has_docs" = "true" ]; then
        commit_prefix="docs"
        commit_body="更新文档和说明文件"
    elif echo "$change_types" | grep -q "文件变更"; then
        commit_prefix="refactor"
        commit_body="重构代码结构或重组文件"
    else
        commit_prefix="chore"
        commit_body="其他类型代码维护和优化"
    fi

    # 生成最终提交信息
    local commit_message="$commit_prefix: $commit_body"

    # 检查是否有未暂存的文件
    local unstaged_files=$(git ls-files --others --exclude-standard)
    if [ -n "$unstaged_files" ]; then
        commit_message="$commit_message (包含新增文件)"
    fi

    echo -e "${GREEN}✅ 生成提交信息: ${NC}$commit_message"
    echo "$commit_message"
}

# 执行安全提交
execute_safe_commit() {
    local commit_message="$1"

    echo -e "${BLUE}🔒 执行安全提交流程...${NC}"

    # 1. 运行代码质量检查（如果有钩子）
    if [ -f "$SCRIPT_DIR/../features/hooks/code-quality.sh" ]; then
        echo -e "${YELLOW}🔍 运行代码质量检查...${NC}"
        bash "$SCRIPT_DIR/../features/hooks/code-quality.sh" pre-commit || {
            echo -e "${RED}❌ 代码质量检查失败，提交已取消${NC}"
            echo -e "${YELLOW}💡 请修复质量问题后重试${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ 代码质量检查通过${NC}"
    fi

    # 2. 自动暂存所有更改
    echo -e "${YELLOW}📦 暂存所有更改...${NC}"
    git add .

    # 3. 检查是否有实际变更
    if [ -z "$(git diff --cached --name-only)" ]; then
        echo -e "${YELLOW}⚠️  没有发现需要提交的更改${NC}"
        exit 0
    fi

    # 4. 执行提交
    echo -e "${YELLOW}💾 执行Git提交...${NC}"
    if git commit -m "$commit_message"; then
        echo -e "${GREEN}✅ 代码提交成功！${NC}"

        # 显示提交信息
        local commit_hash=$(git rev-parse HEAD)
        local short_hash=$(git rev-parse --short HEAD)
        echo -e "${CYAN}📋 提交详情:${NC}"
        echo -e "   提交哈希: $commit_hash"
        echo -e "   短哈希: $short_hash"
        echo -e "   提交信息: $commit_message"

        # 5. 询问是否推送
        echo ""
        echo -e "${YELLOW}❓ 是否推送到远程仓库？(y/n): ${NC}"
        read -r -n 1 -t 10 should_push || should_push="n"

        if [[ $should_push =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${BLUE}🚀 推送到远程仓库...${NC}"
            if git push origin "$(git branch --show-current)"; then
                echo -e "${GREEN}✅ 推送成功！${NC}"
            else
                echo -e "${YELLOW}⚠️  推送失败，请手动推送${NC}"
                echo -e "${YELLOW}💡 命令: git push origin $(git branch --show-current)${NC}"
            fi
        else
            echo ""
            echo -e "${YELLOW}💡 如需推送，请执行: git push origin $(git branch --show-current)${NC}"
        fi

    else
        echo -e "${RED}❌ 提交失败${NC}"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🚀 智能Git提交助手${NC}"
    echo ""
    echo -e "${YELLOW}功能特性:${NC}"
    echo "  • 自动分析变更内容和类型"
    echo "  • 智能生成符合规范的提交信息"
    echo "  • 执行代码质量检查（如果配置了钩子）"
    echo "  • 安全提交并可选推送"
    echo ""
    echo -e "${YELLOW}使用方法:${NC}"
    echo "  ./git-commit.sh              # 自动分析并提交"
    echo "  ./git-commit.sh --message \"自定义提交信息\"  # 指定提交信息"
    echo "  ./git-commit.sh --help       # 显示此帮助"
    echo ""
    echo -e "${YELLOW}集成方式:${NC}"
    echo "  @master 提交代码            # 通过Master控制器调用"
    echo "  @master commit_code         # 直接调用能力映射"
}

# 主函数
main() {
    local custom_message=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --message|-m)
                custom_message="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 未知参数: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done

    show_logo

    # 检查Git状态
    check_git_status

    # 分析变更内容
    local change_info=$(analyze_changes)

    # 生成提交信息
    local commit_message=""
    if [ -n "$custom_message" ]; then
        commit_message="$custom_message"
        echo -e "${GREEN}✅ 使用自定义提交信息: ${NC}$commit_message"
    else
        commit_message=$(generate_commit_message "$change_info")
    fi

    # 执行安全提交
    execute_safe_commit "$commit_message"

    echo ""
    echo -e "${GREEN}🎉 智能Git提交完成！${NC}"

    # 记录到生长系统
    if [ -f "$SCRIPT_DIR/growth-recorder.sh" ]; then
        bash "$SCRIPT_DIR/growth-recorder.sh" record "git-commit" "$commit_message" "success" 2>/dev/null || true
    fi
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi