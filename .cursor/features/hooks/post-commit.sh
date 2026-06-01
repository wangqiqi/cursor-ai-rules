#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../.cursor/core/path-config.sh"  # 统一路径配置

# 🎯 Cursor AI Rules - 提交后处理Hook
# 在提交完成后执行清理和记录操作

source "$SCRIPT_DIR/../../../.cursor/core/colors.sh"

# 统计
COMMIT_HASH=""
COMMIT_MESSAGE=""
FILES_CHANGED=0

# 日志函数
log_info() {
    echo -e "${BLUE}[POST-COMMIT-HOOK]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[POST-COMMIT-HOOK]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[POST-COMMIT-HOOK]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[POST-COMMIT-HOOK]${NC} ❌ $1"
}

# 获取提交信息
get_commit_info() {
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_MESSAGE=$(git log -1 --pretty=%B)

    log_info "提交完成: $COMMIT_HASH"
    log_debug "提交信息: $COMMIT_MESSAGE"
}

# 分析提交内容
analyze_commit() {
    log_info "分析提交内容..."

    # 获取变更的文件数
    FILES_CHANGED=$(git show --name-only --pretty="" | wc -l)

    # 获取变更类型统计
    local added=$(git show --pretty="" --numstat | awk '{added+=$1} END {print added+0}')
    local deleted=$(git show --pretty="" --numstat | awk '{deleted+=$2} END {print deleted+0}')

    log_info "变更统计: +$added - $deleted 行，$FILES_CHANGED 个文件"

    # 检查是否包含重要文件
    local important_files=$(git show --name-only --pretty="" | grep -E "\.(md|txt|config|env)$" | wc -l)
    if [ "$important_files" -gt 0 ]; then
        log_info "包含 $important_files 个文档/配置文件"
    fi
}

# 清理临时文件
cleanup_temp_files() {
    log_info "清理临时文件..."

    local cleaned=0

    # 清理常见的临时文件
    local temp_patterns=(
        "*.tmp"
        "*.temp"
        "*.bak"
        "*.swp"
        "*.swo"
        "*~"
        ".DS_Store"
        "Thumbs.db"
    )

    for pattern in "${temp_patterns[@]}"; do
        local found=$(find . -name "$pattern" -not -path "./.git/*" | wc -l)
        if [ "$found" -gt 0 ]; then
            find . -name "$pattern" -not -path "./.git/*" -delete
            log_debug "清理了 $found 个 $pattern 文件"
            ((cleaned += found))
        fi
    done

    # 清理空目录 (谨慎操作，只清理特定目录)
    local empty_dirs=$(find . -type d -empty -not -path "./.git/*" -not -path "./node_modules/*" | wc -l)
    if [ "$empty_dirs" -gt 0 ]; then
        find . -type d -empty -not -path "./.git/*" -not -path "./node_modules/*" -delete 2>/dev/null
        log_debug "清理了 $empty_dirs 个空目录"
        ((cleaned += empty_dirs))
    fi

    if [ $cleaned -gt 0 ]; then
        log_success "清理完成，共处理 $cleaned 项"
    else
        log_debug "没有发现需要清理的文件"
    fi
}

# 更新项目状态记录
update_project_status() {
    log_info "更新项目状态记录..."

    # 创建项目状态目录
    local status_dir="$GROWTH_DIR/project-status"
    mkdir -p "$status_dir"

    # 记录提交信息
    local commit_file="$status_dir/last-commit.json"
    cat > "$commit_file" << EOF
{
  "commit_hash": "$COMMIT_HASH",
  "commit_message": "$COMMIT_MESSAGE",
  "files_changed": $FILES_CHANGED,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "branch": "$(git rev-parse --abbrev-ref HEAD)"
}
EOF

    log_debug "项目状态已更新: $commit_file"
}

# 检查是否需要推送
check_push_needed() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # 检查是否有远程分支
    if git ls-remote --heads origin "$current_branch" &>/dev/null; then
        local local_commits=$(git rev-list --count HEAD ^origin/"$current_branch" 2>/dev/null || echo "0")

        if [ "$local_commits" -gt 0 ]; then
            log_info "当前分支领先远程 $local_commits 个提交"
            log_info "建议推送: git push origin $current_branch"

            # 如果启用了自动推送，询问用户
            if [ "${AUTO_PUSH:-false}" = "true" ]; then
                echo ""
                read -p "是否现在推送？(y/N): " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if git push origin "$current_branch"; then
                        log_success "推送成功"
                    else
                        log_warning "推送失败，请手动推送"
                    fi
                fi
            fi
        else
            log_success "分支已同步到远程"
        fi
    else
        log_debug "当前分支没有对应的远程分支"
    fi
}

# 生成提交摘要
generate_commit_summary() {
    echo ""
    echo "📊 提交摘要"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔗 提交: $COMMIT_HASH"
    echo "📝 信息: $COMMIT_MESSAGE"
    echo "📁 文件: $FILES_CHANGED 个"
    echo "🌿 分支: $(git rev-parse --abbrev-ref HEAD)"
    echo "🕒 时间: $(date)"
    echo ""

    # 显示变更的文件列表
    echo "📋 变更文件:"
    git show --name-only --pretty="" | head -10 | while read -r file; do
        if [ -n "$file" ]; then
            if git show --name-status --pretty="" | grep "^A.*$file" > /dev/null; then
                echo "  🆕 $file"
            elif git show --name-status --pretty="" | grep "^M.*$file" > /dev/null; then
                echo "  ✏️  $file"
            elif git show --name-status --pretty="" | grep "^D.*$file" > /dev/null; then
                echo "  🗑️  $file"
            else
                echo "  📄 $file"
            fi
        fi
    done

    local total_files=$(git show --name-only --pretty="" | wc -l)
    if [ "$total_files" -gt 10 ]; then
        echo "  ... 还有 $((total_files - 10)) 个文件"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 检查是否需要触发后续操作
check_followup_actions() {
    log_info "检查后续操作..."

    # 检查是否包含版本标签
    if echo "$COMMIT_MESSAGE" | grep -qE "(release|version|tag)"; then
        log_info "检测到版本相关提交，建议创建标签"
        log_info "创建标签: git tag v1.0.0 && git push --tags"
    fi

    # 检查是否包含文档更新
    if git show --name-only --pretty="" | grep -qE "\.(md|txt|rst)$"; then
        log_info "检测到文档更新"
    fi

    # 检查是否包含配置更新
    if git show --name-only --pretty="" | grep -qE "(package\.json|requirements\.txt|Cargo\.toml)"; then
        log_info "检测到依赖配置更新"
    fi
}

# 主函数
main() {
    log_info "开始提交后处理..."

    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "不在Git仓库中"
        exit 1
    fi

    # 获取提交信息
    get_commit_info

    # 分析提交内容
    analyze_commit

    # 生成提交摘要
    generate_commit_summary

    # 清理临时文件
    cleanup_temp_files

    # 更新项目状态
    update_project_status

    # 检查推送状态
    check_push_needed

    # 检查后续操作
    check_followup_actions

    log_success "提交后处理完成"
}

# 只有在直接调用时才执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi