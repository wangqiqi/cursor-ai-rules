#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"

# 🌟 Cursor AI Rules - Git管理器
# 智能Git操作管理，支持提交、分支、远程操作等

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_DIR="$SCRIPT_DIR"

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

# 检查Git环境
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

# 智能提交消息生成
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

# 执行智能提交
execute_smart_commit() {
    log_info "执行智能Git提交..."

    # 检查Git环境
    if ! check_git_environment; then
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

    # 生成提交消息
    local commit_message=$(generate_commit_message)
    log_info "生成的提交消息: $commit_message"

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
            execute_smart_commit "$@"
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
            echo "  commit              智能提交当前更改"
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