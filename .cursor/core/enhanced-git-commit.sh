#!/bin/bash
# 🚀 Cursor AI Rules - 增强版智能Git提交助手 v3.0
# 深度集成现有架构：项目验证 + MCP支持 + 钩子系统 + 生长记录
# 标准化提交流程，符合Conventional Commits规范

set -e

# 🔧 加载现有架构组件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"  # 共享函数库
source "$SCRIPT_DIR/path-config.sh"       # 统一路径配置

# 🛡️ 项目上下文验证 (强制!)
validate_project_context || {
    echo "❌ enhanced-git-commit.sh: 项目上下文验证失败"
    echo "   请确保在正确的项目目录中运行脚本"
    exit 1
}

# 🌱 生长目录配置
GROWTH_DIR="$CURSOR_GROWTH"

# 🎨 颜色定义 (与现有脚本保持一致)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 🚀 显示增强版Logo
show_enhanced_logo() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║               🚀 增强版智能Git提交助手 v3.0                   ║"
    echo "║                                                                ║"
    echo "║     深度架构集成 · MCP增强 · 标准化流程 · 质量保证           ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 🔍 检查Git状态 (增强版)
check_git_status_enhanced() {
    echo -e "${BLUE}🔍 执行增强Git状态检查...${NC}"

    # 基础检查
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

    # 检查是否有冲突
    if git status --porcelain | grep -q '^UU\|^AA\|^DD'; then
        echo -e "${RED}❌ 检测到合并冲突，请先解决冲突${NC}"
        exit 1
    fi

    # 显示当前分支信息
    local current_branch=$(git branch --show-current)
    echo -e "${GREEN}✅ Git仓库状态正常${NC}"
    echo -e "${CYAN}📍 当前分支: ${NC}$current_branch"

    # 检查远程状态
    if git remote get-url origin >/dev/null 2>&1; then
        local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null || echo "0 0")
        local ahead=$(echo $ahead_behind | cut -d' ' -f1)
        local behind=$(echo $ahead_behind | cut -d' ' -f2)

        if [ "$ahead" -gt 0 ]; then
            echo -e "${YELLOW}📤 领先远程 $ahead 个提交${NC}"
        fi
        if [ "$behind" -gt 0 ]; then
            echo -e "${YELLOW}📥 落后远程 $behind 个提交${NC}"
        fi
    fi
}

# 🧠 深度变更分析 (增强版)
analyze_changes_enhanced() {
    echo -e "${BLUE}🧠 执行深度变更分析...${NC}"

    # 获取变更统计
    local stats=$(git diff --cached --stat 2>/dev/null || git diff --stat)

    if [ -n "$stats" ]; then
        echo -e "${CYAN}📈 变更统计:${NC}"
        echo "$stats"
        echo ""
    fi

    # 深度分析变更类型
    local change_types=""
    local has_code_changes=false
    local has_config_changes=false
    local has_docs_changes=false
    local has_test_changes=false
    local has_build_changes=false
    local complexity_score=0

    # 代码文件分析
    local code_files=$(git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx|py|java|cpp|c|go|rs|php|rb|swift|kt|scala|clj|hs|ml|fs|vb|cs)$' | wc -l)
    if [ "$code_files" -gt 0 ]; then
        change_types="${change_types}代码修改 "
        has_code_changes=true
        complexity_score=$((complexity_score + code_files * 2))
    fi

    # 配置文件分析
    local config_files=$(git diff --cached --name-only | grep -E '\.(json|yaml|yml|toml|ini|cfg|conf|properties|env|xml)$' | wc -l)
    if [ "$config_files" -gt 0 ]; then
        change_types="${change_types}配置更新 "
        has_config_changes=true
        complexity_score=$((complexity_score + config_files))
    fi

    # 文档文件分析
    local doc_files=$(git diff --cached --name-only | grep -E '\.(md|txt|rst|adoc|pdf|doc|docx)$' | wc -l)
    if [ "$doc_files" -gt 0 ]; then
        change_types="${change_types}文档更新 "
        has_docs_changes=true
        complexity_score=$((complexity_score + doc_files / 2))
    fi

    # 测试文件分析
    local test_files=$(git diff --cached --name-only | grep -E '(test|spec)\.(js|ts|py|java|cpp|go|rs)$' | wc -l)
    if [ "$test_files" -gt 0 ]; then
        change_types="${change_types}测试更新 "
        has_test_changes=true
        complexity_score=$((complexity_score + test_files))
    fi

    # 构建文件分析
    local build_files=$(git diff --cached --name-only | grep -E '(package\.json|requirements\.txt|Cargo\.toml|go\.mod|pom\.xml|build\.gradle|\.gitignore|Makefile|Dockerfile)$' | wc -l)
    if [ "$build_files" -gt 0 ]; then
        change_types="${change_types}构建配置 "
        has_build_changes=true
        complexity_score=$((complexity_score + build_files))
    fi

    # 文件操作分析
    local added_files=$(git diff --cached --name-status | grep '^A' | wc -l)
    local deleted_files=$(git diff --cached --name-status | grep '^D' | wc -l)
    local modified_files=$(git diff --cached --name-status | grep '^M' | wc -l)
    local renamed_files=$(git diff --cached --name-status | grep '^R' | wc -l)

    if [ "$added_files" -gt 0 ] || [ "$deleted_files" -gt 0 ] || [ "$renamed_files" -gt 0 ]; then
        change_types="${change_types}文件结构变更 "
        complexity_score=$((complexity_score + added_files + deleted_files + renamed_files))
    fi

    # 变更复杂度评估
    local complexity_level="低"
    if [ $complexity_score -gt 20 ]; then
        complexity_level="高"
    elif [ $complexity_score -gt 10 ]; then
        complexity_level="中"
    fi

    if [ -z "$change_types" ]; then
        change_types="其他修改"
    fi

    echo -e "${CYAN}🔧 变更类型: ${NC}$change_types"
    echo -e "${CYAN}📊 复杂度: ${NC}$complexity_level (分数: $complexity_score)"
    echo -e "${CYAN}📁 文件变更: ${NC}+${added_files} -${deleted_files} ~${modified_files} ↻${renamed_files}"

    # 返回增强的变更信息
    echo "{\"change_types\":\"$change_types\",\"complexity\":\"$complexity_level\",\"score\":$complexity_score,\"has_code\":$has_code_changes,\"has_config\":$has_config_changes,\"has_docs\":$has_docs_changes,\"has_test\":$has_test_changes,\"has_build\":$has_build_changes,\"added\":$added_files,\"deleted\":$deleted_files,\"modified\":$modified_files,\"renamed\":$renamed_files}"
}

# 🎯 生成标准化提交信息 (符合Conventional Commits)
generate_standard_commit_message() {
    local change_info="$1"

    echo -e "${BLUE}🎯 生成标准化提交信息 (Conventional Commits)...${NC}"

    # 解析变更信息
    local change_types=$(echo "$change_info" | jq -r '.change_types')
    local complexity=$(echo "$change_info" | jq -r '.complexity')
    local has_code=$(echo "$change_info" | jq -r '.has_code')
    local has_config=$(echo "$change_info" | jq -r '.has_config')
    local has_docs=$(echo "$change_info" | jq -r '.has_docs')
    local has_test=$(echo "$change_info" | jq -r '.has_test')
    local has_build=$(echo "$change_info" | jq -r '.has_build')
    local added=$(echo "$change_info" | jq -r '.added')
    local deleted=$(echo "$change_info" | jq -r '.deleted')
    local modified=$(echo "$change_info" | jq -r '.modified')

    # Conventional Commits类型映射
    local commit_type=""
    local commit_scope=""

    # 确定提交类型
    if [ "$has_code" = "true" ] && [ "$has_config" = "false" ] && [ "$has_docs" = "false" ] && [ "$has_build" = "false" ]; then
        if [ "$has_test" = "true" ]; then
            commit_type="test"
        elif [ "$added" -gt "$deleted" ]; then
            commit_type="feat"
        else
            commit_type="fix"
        fi
    elif [ "$has_config" = "true" ]; then
        commit_type="config"
    elif [ "$has_docs" = "true" ]; then
        commit_type="docs"
    elif [ "$has_build" = "true" ]; then
        commit_type="build"
    elif [ "$added" -gt 0 ] && [ "$deleted" -eq 0 ]; then
        commit_type="feat"
    elif [ "$deleted" -gt 0 ] && [ "$added" -eq 0 ]; then
        commit_type="refactor"
    elif echo "$change_types" | grep -q "文件结构变更"; then
        commit_type="refactor"
    else
        commit_type="chore"
    fi

    # 确定作用域 (基于文件路径分析)
    local top_level_dirs=$(git diff --cached --name-only | cut -d'/' -f1 | sort | uniq | head -3)
    if [ $(echo "$top_level_dirs" | wc -l) -eq 1 ]; then
        commit_scope=$(echo "$top_level_dirs" | head -1)
    fi

    # 生成描述
    local descriptions=(
        "feat:添加新功能"
        "fix:修复bug"
        "docs:更新文档"
        "style:代码格式调整"
        "refactor:代码重构"
        "test:添加测试"
        "chore:维护任务"
        "config:配置更新"
        "build:构建相关"
        "ci:CI/CD相关"
        "perf:性能优化"
    )

    local description="${descriptions[$RANDOM % ${#descriptions[@]}]}"

    # 基于复杂度调整描述
    if [ "$complexity" = "高" ]; then
        description="$description (大规模变更)"
    elif [ "$complexity" = "中" ]; then
        description="$description (中等复杂度)"
    fi

    # 构建标准提交信息
    local commit_message="$commit_type"
    if [ -n "$commit_scope" ]; then
        commit_message="$commit_message($commit_scope)"
    fi
    commit_message="$commit_message: $description"

    echo -e "${GREEN}✅ 生成标准化提交信息: ${NC}$commit_message"
    echo -e "${CYAN}📋 符合规范: ${NC}Conventional Commits"
    echo "$commit_message"
}

# 🔗 MCP增强集成
check_mcp_availability() {
    # 检查MCP工具是否可用
    # 这里可以集成MCP检测逻辑
    return 1  # 暂时返回不可用，后续增强
}

# 🎣 钩子系统集成
trigger_commit_hooks() {
    local hook_type="$1"
    local hook_data="$2"

    echo -e "${BLUE}🎣 触发$hook_type钩子...${NC}"

    # 预提交分析钩子
    if [ -f "$SCRIPT_DIR/../features/hooks/pre-commit-analyzer.sh" ]; then
        echo -e "${CYAN}🔍 运行预提交分析...${NC}"
        bash "$SCRIPT_DIR/../features/hooks/pre-commit-analyzer.sh" "$hook_type" "$hook_data" || {
            echo -e "${YELLOW}⚠️  预提交分析失败，继续执行${NC}"
        }
    fi

    # 提交消息验证钩子
    if [ -f "$SCRIPT_DIR/../features/hooks/commit-message-validator.sh" ]; then
        echo -e "${CYAN}✅ 验证提交消息格式...${NC}"
        bash "$SCRIPT_DIR/../features/hooks/commit-message-validator.sh" "$hook_type" "$hook_data" || {
            echo -e "${RED}❌ 提交消息验证失败${NC}"
            exit 1
        }
    fi
}

# 🚀 执行增强安全提交流程
execute_enhanced_safe_commit() {
    local commit_message="$1"

    echo -e "${BLUE}🚀 执行增强安全提交流程...${NC}"

    # 1. 触发预提交钩子
    trigger_commit_hooks "pre-commit" "$commit_message"

    # 2. 运行代码质量检查 (集成现有钩子系统)
    if [ -f "$SCRIPT_DIR/../features/hooks/code-quality.sh" ]; then
        echo -e "${YELLOW}🔍 运行代码质量检查...${NC}"
        bash "$SCRIPT_DIR/../features/hooks/code-quality.sh" pre-commit || {
            echo -e "${RED}❌ 代码质量检查失败，提交已取消${NC}"
            echo -e "${YELLOW}💡 请修复质量问题后重试${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ 代码质量检查通过${NC}"
    fi

    # 3. 运行一致性检查
    if [ -f "$SCRIPT_DIR/../features/hooks/consistency-check.sh" ]; then
        echo -e "${YELLOW}🔍 运行一致性检查...${NC}"
        bash "$SCRIPT_DIR/../features/hooks/consistency-check.sh" pre-commit || {
            echo -e "${RED}❌ 一致性检查失败，提交已取消${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ 一致性检查通过${NC}"
    fi

    # 4. MCP增强 (如果可用)
    if check_mcp_availability; then
        echo -e "${BLUE}🤖 MCP增强处理...${NC}"
        # 这里可以添加MCP处理逻辑
    fi

    # 5. 自动暂存所有更改
    echo -e "${YELLOW}📦 暂存所有更改...${NC}"
    git add .

    # 6. 检查是否有实际变更
    if [ -z "$(git diff --cached --name-only)" ]; then
        echo -e "${YELLOW}⚠️  没有发现需要提交的更改${NC}"
        exit 0
    fi

    # 7. 执行提交
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

        # 8. 触发后提交钩子
        trigger_commit_hooks "post-commit" "$commit_message"

        # 9. 智能推送建议
        echo ""
        echo -e "${YELLOW}🚀 推送建议:${NC}"
        local current_branch=$(git branch --show-current)

        # 检查是否有远程分支
        if git ls-remote --heads origin "$current_branch" >/dev/null 2>&1; then
            echo -e "${CYAN}💡 建议推送命令: ${NC}git push origin $current_branch"
            echo -e "${YELLOW}❓ 是否现在推送？(y/N): ${NC}"

            read -r -n 1 -t 10 should_push || should_push="n"
            echo ""

            if [[ $should_push =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}🚀 推送到远程仓库...${NC}"
                if git push origin "$current_branch"; then
                    echo -e "${GREEN}✅ 推送成功！${NC}"
                else
                    echo -e "${YELLOW}⚠️  推送失败，请手动推送${NC}"
                    echo -e "${YELLOW}💡 命令: git push origin $current_branch${NC}"
                fi
            fi
        else
            echo -e "${CYAN}💡 远程分支不存在，首次推送请使用:${NC}"
            echo -e "${CYAN}   git push -u origin $current_branch${NC}"
        fi

    else
        echo -e "${RED}❌ 提交失败${NC}"
        exit 1
    fi
}

# 📖 显示增强帮助信息
show_enhanced_help() {
    echo -e "${BLUE}🚀 增强版智能Git提交助手 v3.0${NC}"
    echo ""
    echo -e "${YELLOW}🎯 核心特性:${NC}"
    echo "  • 深度变更分析和复杂度评估"
    echo "  • 标准化Conventional Commits格式"
    echo "  • 完整钩子系统集成"
    echo "  • MCP增强支持"
    echo "  • 项目上下文验证"
    echo "  • 生长系统记录"
    echo ""
    echo -e "${YELLOW}📋 使用方法:${NC}"
    echo "  ./enhanced-git-commit.sh                    # 自动分析并提交"
    echo "  ./enhanced-git-commit.sh --message \"自定义信息\"  # 指定提交信息"
    echo "  ./enhanced-git-commit.sh --help             # 显示此帮助"
    echo "  ./enhanced-git-commit.sh --dry-run          # 预览模式"
    echo ""
    echo -e "${YELLOW}🔗 集成方式:${NC}"
    echo "  @master 提交代码                           # 通过Master控制器调用"
    echo "  @master enhanced_commit                     # 直接调用增强能力"
    echo ""
    echo -e "${YELLOW}📊 标准化输出:${NC}"
    echo "  所有提交信息符合Conventional Commits规范"
    echo "  自动分析变更复杂度"
    echo "  集成质量检查和一致性验证"
}

# 🎭 主函数
main() {
    local custom_message=""
    local dry_run=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --message|-m)
                custom_message="$2"
                shift 2
                ;;
            --dry-run|-d)
                dry_run=true
                shift
                ;;
            --help|-h)
                show_enhanced_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 未知参数: $1${NC}"
                show_enhanced_help
                exit 1
                ;;
        esac
    done

    show_enhanced_logo

    # 检查Git状态
    check_git_status_enhanced

    # 深度分析变更
    local change_info=$(analyze_changes_enhanced)

    # 生成提交信息
    local commit_message=""
    if [ -n "$custom_message" ]; then
        commit_message="$custom_message"
        echo -e "${GREEN}✅ 使用自定义提交信息: ${NC}$commit_message"
    else
        commit_message=$(generate_standard_commit_message "$change_info")
    fi

    # 预览模式
    if [ "$dry_run" = true ]; then
        echo ""
        echo -e "${YELLOW}🔍 预览模式 - 不会实际执行提交${NC}"
        echo -e "${CYAN}📝 提交信息: ${NC}$commit_message"
        echo -e "${CYAN}📊 变更分析: ${NC}$change_info"
        exit 0
    fi

    # 执行增强安全提交
    execute_enhanced_safe_commit "$commit_message"

    echo ""
    echo -e "${GREEN}🎉 增强版智能Git提交完成！${NC}"

    # 记录到生长系统 (增强记录)
    if [ -f "$SCRIPT_DIR/growth-recorder.sh" ]; then
        bash "$SCRIPT_DIR/growth-recorder.sh" record "enhanced-git-commit" "$commit_message" "success" 2>/dev/null || true
    fi
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi