#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"

# 🌟 Cursor AI Rules - Git管理器 (增强版)
# 智能Git操作管理，支持提交、分支、远程操作、深度分析等

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_DIR="$SCRIPT_DIR"

# 加载共享函数库
source "$SCRIPT_DIR/shared-functions.sh"  # 共享函数库

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Git操作统计
GIT_OPERATIONS_TOTAL=0
GIT_OPERATIONS_SUCCESS=0
COMMITS_CREATED=0
BRANCHES_CREATED=0

# Git结果存储
declare -A GIT_RESULTS

# 日志函数
log_info() {
    echo -e "${BLUE}[GIT-MANAGER]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[GIT-MANAGER]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[GIT-MANAGER]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[GIT-MANAGER]${NC} ❌ $1"
}

log_debug() {
    echo -e "${CYAN}[GIT-MANAGER]${NC} 🔍 $1"
}

# 项目上下文验证 (强制!)
validate_project_context() {
    log_info "验证项目上下文..."

    # 检查是否在项目目录中
    if [ ! -f ".cursorrules" ] && [ ! -f ".cursor-project.json" ] && [ ! -d ".cursor" ]; then
        log_error "enhanced-git-commit.sh: 项目上下文验证失败"
        log_info "请确保在正确的项目目录中运行脚本"
        return 1
    fi

    log_success "项目上下文验证通过"
    return 0
}

# 检查Git环境 (增强版)
check_git_environment_enhanced() {
    log_info "执行增强Git状态检查..."

    # 基础检查
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "错误: 当前目录不是Git仓库"
        return 1
    fi

    # 检查是否有未暂存的更改
    if [ -z "$(git status --porcelain)" ]; then
        log_warning "没有发现未暂存的更改"
        log_info "可能所有更改都已提交，或需要先添加文件"
        return 1
    fi

    # 检查是否有冲突
    if git status --porcelain | grep -q '^UU\|^AA\|^DD'; then
        log_error "检测到合并冲突，请先解决冲突"
        return 1
    fi

    # 显示当前分支信息
    local current_branch=$(git branch --show-current)
    log_success "Git仓库状态正常"
    log_info "当前分支: $current_branch"

    # 检查远程状态
    if git remote get-url origin >/dev/null 2>&1; then
        local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null || echo "0 0")
        local ahead=$(echo $ahead_behind | cut -d' ' -f1)
        local behind=$(echo $ahead_behind | cut -d' ' -f2)

        if [ "$ahead" -gt 0 ]; then
            log_info "领先远程 $ahead 个提交"
        fi
        if [ "$behind" -gt 0 ]; then
            log_info "落后远程 $behind 个提交"
        fi
    fi

    return 0
}

# 检查Git环境 (基础版)
check_git_environment() {
    log_info "检查Git环境..."

    if ! command -v git &> /dev/null; then
        log_error "Git未安装，请先安装Git"
        return 1
    fi

    if [ ! -d ".git" ]; then
        log_error "当前目录不是Git仓库"
        return 1
    fi

    local git_version=$(git --version | awk '{print $3}')
    log_success "Git版本: $git_version"

    # 检查Git配置
    local user_name=$(git config user.name)
    local user_email=$(git config user.email)

    if [ -z "$user_name" ] || [ -z "$user_email" ]; then
        log_warning "Git用户配置不完整"
        log_info "建议运行: git config --global user.name 'Your Name'"
        log_info "          git config --global user.email 'your.email@example.com'"
    else
        log_success "Git用户: $user_name <$user_email>"
    fi

    return 0
}

# 深度变更分析 (增强版)
analyze_changes_enhanced() {
    log_info "执行深度变更分析..."

    # 获取变更统计
    local stats=$(git diff --cached --stat 2>/dev/null || git diff --stat)

    if [ -n "$stats" ]; then
        log_info "变更统计:"
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

    # 确定复杂度级别
    local complexity="低"
    if [ $complexity_score -gt 10 ]; then
        complexity="高"
    elif [ $complexity_score -gt 5 ]; then
        complexity="中"
    fi

    # 返回分析结果
    echo "$change_types|$has_code_changes|$has_config_changes|$has_docs_changes|$has_test_changes|$has_build_changes|$complexity|$added_files|$deleted_files|$modified_files"
}

# 智能提交消息生成 (增强版)
generate_commit_message() {
    local changes=$(git status --porcelain)
    local message_parts=()

    # 分析变更类型
    local has_modified=false
    local has_added=false
    local has_deleted=false
    local has_renamed=false

    while IFS= read -r line; do
        case "${line:0:2}" in
            "M ") has_modified=true ;;
            "A ") has_added=true ;;
            "D ") has_deleted=true ;;
            "R ") has_renamed=true ;;
        esac
    done <<< "$changes"

    # 构建提交消息
    if $has_added && ! $has_modified && ! $has_deleted; then
        message_parts+=("feat: 添加新文件")
    elif $has_deleted && ! $has_modified && ! $has_added; then
        message_parts+=("refactor: 删除文件")
    elif $has_renamed; then
        message_parts+=("refactor: 重命名文件")
    else
        # 分析文件类型
        local file_types=$(git diff --cached --name-only | sed 's/.*\.//' | sort | uniq -c | sort -nr)
        local main_type=$(echo "$file_types" | head -1 | awk '{print $2}')

        case "$main_type" in
            "js"|"ts"|"jsx"|"tsx")
                message_parts+=("feat: 更新JavaScript/TypeScript代码") ;;
            "py")
                message_parts+=("feat: 更新Python代码") ;;
            "java")
                message_parts+=("feat: 更新Java代码") ;;
            "md")
                message_parts+=("docs: 更新文档") ;;
            "json")
                message_parts+=("feat: 更新配置") ;;
            "sh"|"bash")
                message_parts+=("feat: 更新脚本") ;;
            "css"|"scss"|"less")
                message_parts+=("feat: 更新样式") ;;
            *)
                message_parts+=("feat: 更新文件") ;;
        esac
    fi

    # 添加变更统计
    local file_count=$(git diff --cached --name-only | wc -l)
    message_parts+=("$file_count 个文件变更")

    # 添加时间戳
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    message_parts+=("($timestamp)")

    # 生成最终消息
    local final_message=$(IFS='; '; echo "${message_parts[*]}")

    echo "$final_message"
}

# 智能提交消息生成 (增强版)
generate_commit_message_enhanced() {
    log_debug "生成智能提交信息..."

    # 执行深度变更分析
    local analysis_result=$(analyze_changes_enhanced)
    IFS='|' read -r change_types has_code has_config has_docs has_test has_build complexity added deleted modified <<< "$analysis_result"

    # 确定提交类型和作用域
    local commit_type=""
    local commit_scope=""

    # 基于变更类型确定提交类型
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

    # 添加详细的变更描述
    local detailed_description="$commit_message\n\n"

    # 添加变更统计
    local total_files=$((added + deleted + modified))
    detailed_description="${detailed_description}- 变更文件数: $total_files 个\n"

    if [ "$added" -gt 0 ]; then
        detailed_description="${detailed_description}- 新增文件: $added 个\n"
    fi
    if [ "$deleted" -gt 0 ]; then
        detailed_description="${detailed_description}- 删除文件: $deleted 个\n"
    fi
    if [ "$modified" -gt 0 ]; then
        detailed_description="${detailed_description}- 修改文件: $modified 个\n"
    fi

    # 添加变更类型信息
    if [ -n "$change_types" ]; then
        detailed_description="${detailed_description}- 变更类型: $change_types\n"
    fi

    # 添加复杂度信息
    detailed_description="${detailed_description}- 复杂度: $complexity\n"

    # 添加智能分析信息
    if [ "$has_code" = "true" ]; then
        detailed_description="${detailed_description}- 包含代码变更\n"
    fi
    if [ "$has_test" = "true" ]; then
        detailed_description="${detailed_description}- 包含测试更新\n"
    fi
    if [ "$has_docs" = "true" ]; then
        detailed_description="${detailed_description}- 包含文档更新\n"
    fi
    if [ "$has_config" = "true" ]; then
        detailed_description="${detailed_description}- 包含配置更新\n"
    fi
    if [ "$has_build" = "true" ]; then
        detailed_description="${detailed_description}- 包含构建配置\n"
    fi

    # 添加时间戳
    detailed_description="${detailed_description}\nGenerated by Cursor AI Rules v4.3.0 at $(date '+%Y-%m-%d %H:%M:%S')"

    echo "$detailed_description"
}

# 执行智能提交 (增强版)
execute_smart_commit() {
    local use_enhanced="${1:-false}"

    log_info "执行智能Git提交..."

    # 项目上下文验证 (增强版)
    if ! validate_project_context; then
        return 1
    fi

    # 检查Git环境 (增强版)
    if ! check_git_environment_enhanced; then
        return 1
    fi

    # 检查暂存区状态
    local staged_changes=$(git diff --cached --name-only)
    if [ -z "$staged_changes" ]; then
        log_warning "暂存区为空，没有要提交的更改"
        return 1
    fi

    local file_count=$(echo "$staged_changes" | wc -l)
    log_info "发现 $file_count 个暂存文件"

    # 生成提交消息 (支持增强版)
    local commit_message=""
    if [ "${1:-}" = "enhanced" ]; then
        commit_message=$(generate_commit_message_enhanced)
        log_info "生成的增强版提交消息"
    else
        commit_message=$(generate_commit_message)
        log_info "生成的提交消息: $commit_message"
    fi

    # 显示变更详情
    log_info "变更详情:"
    git diff --cached --stat

    # 执行提交
    if git commit -m "$commit_message"; then
        log_success "提交成功: $commit_message"
        ((GIT_OPERATIONS_SUCCESS++))
        ((COMMITS_CREATED++))
        GIT_RESULTS["last_commit"]="$commit_message"
        return 0
    else
        log_error "提交失败"
        return 1
    fi
}

# 分支管理
manage_branches() {
    local action="$1"
    local branch_name="$2"

    case "$action" in
        "create")
            if [ -z "$branch_name" ]; then
                log_error "请指定分支名称"
                return 1
            fi

            if git show-ref --verify --quiet "refs/heads/$branch_name"; then
                log_warning "分支 '$branch_name' 已存在"
                return 1
            fi

            if git checkout -b "$branch_name"; then
                log_success "分支 '$branch_name' 创建成功"
                ((BRANCHES_CREATED++))
                return 0
            else
                log_error "分支创建失败"
                return 1
            fi
            ;;
        "list")
            log_info "当前分支列表:"
            git branch -a
            return 0
            ;;
        "switch")
            if [ -z "$branch_name" ]; then
                log_error "请指定分支名称"
                return 1
            fi

            if git checkout "$branch_name"; then
                log_success "切换到分支 '$branch_name'"
                return 0
            else
                log_error "分支切换失败"
                return 1
            fi
            ;;
        *)
            log_error "未知的分支操作: $action"
            return 1
            ;;
    esac
}

# 远程操作
manage_remote() {
    local action="$1"
    local remote_name="$2"
    local remote_url="$3"

    case "$action" in
        "add")
            if [ -z "$remote_name" ] || [ -z "$remote_url" ]; then
                log_error "请指定远程仓库名称和URL"
                return 1
            fi

            if git remote add "$remote_name" "$remote_url"; then
                log_success "远程仓库 '$remote_name' 添加成功"
                return 0
            else
                log_error "远程仓库添加失败"
                return 1
            fi
            ;;
        "push")
            local current_branch=$(git rev-parse --abbrev-ref HEAD)

            if git push -u origin "$current_branch"; then
                log_success "推送成功: $current_branch -> origin"
                return 0
            else
                log_error "推送失败"
                return 1
            fi
            ;;
        "pull")
            if git pull; then
                log_success "拉取成功"
                return 0
            else
                log_error "拉取失败"
                return 1
            fi
            ;;
        *)
            log_error "未知的远程操作: $action"
            return 1
            ;;
    esac
}

# 状态检查
check_repository_status() {
    log_info "检查仓库状态..."

    # 显示当前分支
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    log_info "当前分支: $current_branch"

    # 显示状态
    log_info "Git状态:"
    git status --short

    # 显示最近提交
    log_info "最近3次提交:"
    git log --oneline -3

    # 检查未推送的提交
    local unpushed=$(git log --oneline origin/"$current_branch"..HEAD 2>/dev/null | wc -l)
    if [ "$unpushed" -gt 0 ]; then
        log_warning "有 $unpushed 个未推送的提交"
    else
        log_success "所有提交都已推送"
    fi
}

# 清理操作
cleanup_repository() {
    log_info "执行仓库清理..."

    # 清理未跟踪文件 (询问用户)
    local untracked=$(git ls-files --others --exclude-standard | wc -l)
    if [ "$untracked" -gt 0 ]; then
        log_warning "发现 $untracked 个未跟踪文件"
        log_info "运行 'git clean -fd' 来清理 (谨慎使用)"
    fi

    # 优化仓库
    if git gc --quiet; then
        log_success "仓库优化完成"
    fi
}

# 主函数
main() {
    local command="$1"
    shift

    ((GIT_OPERATIONS_TOTAL++))

    case "$command" in
        "commit")
            # 检查是否使用增强版
            local use_enhanced=false
            for arg in "$@"; do
                if [ "$arg" = "enhanced" ] || [ "$arg" = "--enhanced" ]; then
                    use_enhanced=true
                    break
                fi
            done
            execute_smart_commit "$use_enhanced"
            ;;
        "branch")
            manage_branches "$@"
            ;;
        "remote")
            manage_remote "$@"
            ;;
        "status")
            check_repository_status "$@"
            ;;
        "cleanup")
            cleanup_repository "$@"
            ;;
        "check")
            check_git_environment "$@"
            ;;
        *)
            echo "用法: $0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  commit [enhanced]   智能提交当前更改 (enhanced=增强版)"
            echo "  branch <action>     分支管理 (create/list/switch)"
            echo "  remote <action>     远程仓库管理 (add/push/pull)"
            echo "  status              显示仓库状态"
            echo "  cleanup             清理仓库"
            echo "  check               检查Git环境"
            echo ""
            echo "示例:"
            echo "  $0 commit           # 智能提交"
            echo "  $0 branch create feature-branch  # 创建分支"
            echo "  $0 remote push      # 推送当前分支"
            return 1
            ;;
    esac

    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        ((GIT_OPERATIONS_SUCCESS++))
    fi

    return $exit_code
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi