#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 📝 后提交日志记录器钩子
# 记录提交后的详细信息，用于分析和改进
# 集成到增强版Git提交流程中

set -e

# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../core" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
source "$SCRIPT_DIR/path-config.sh"

# 项目上下文验证
validate_project_context || exit 1

source "$SCRIPT_DIR/colors.sh"

# 记录钩子执行
log() {
    echo "[HOOK:post-commit-logger] $(date '+%H:%M:%S') $*" >&2
}

# 记录提交统计信息
log_commit_stats() {
    local commit_message="$1"

    log "记录提交统计信息"

    # 获取当前提交信息
    local commit_hash=$(git rev-parse HEAD)
    local commit_short=$(git rev-parse --short HEAD)
    local author_name=$(git log -1 --pretty=format:'%an')
    local author_email=$(git log -1 --pretty=format:'%ae')
    local commit_time=$(git log -1 --pretty=format:'%ad' --date=iso)
    local branch_name=$(git branch --show-current)

    # 分析提交内容
    local files_changed=$(git show --name-only --pretty="" | wc -l)
    local insertions=$(git show --stat | grep "insertions" | awk '{print $4}' | sed 's/,//g' | head -1)
    local deletions=$(git show --stat | grep "deletions" | awk '{print $6}' | sed 's/,//g' | head -1)

    # 默认为0如果没有数据
    insertions=${insertions:-0}
    deletions=${deletions:-0}

    # 提取提交类型和范围
    local commit_type=$(echo "$commit_message" | sed -n 's/^\([a-zA-Z]*\).*/\1/p')
    local commit_scope=$(echo "$commit_message" | sed -n 's/.*(\([^)]*\)).*/\1/p')

    # 创建统计记录
    local stats_record=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "commit_hash": "$commit_hash",
  "commit_short": "$commit_short",
  "branch": "$branch_name",
  "author": {
    "name": "$author_name",
    "email": "$author_email"
  },
  "message": "$commit_message",
  "type": "$commit_type",
  "scope": "$commit_scope",
  "stats": {
    "files_changed": $files_changed,
    "insertions": $insertions,
    "deletions": $deletions,
    "lines_changed": $((insertions + deletions))
  },
  "hook_version": "3.0",
  "enhanced_commit": true
}
EOF
)

    echo "$stats_record" >&2

    # 保存到生长系统
    if [ -f "$SCRIPT_DIR/growth-recorder.sh" ]; then
        bash "$SCRIPT_DIR/growth-recorder.sh" record "enhanced-git-commit-stats" "$stats_record" "completed" 2>/dev/null || true
    fi

    # 保存到本地日志文件
    local log_dir="$CURSOR_GROWTH/records/logs"
    safe_file_operation "mkdir" "$log_dir"

    local log_file="$log_dir/commit-stats-$(date +%Y%m%d).jsonl"
    echo "$stats_record" >> "$log_file"

    log "提交统计信息已记录到: $log_file"
}

# 分析提交模式和趋势
analyze_commit_patterns() {
    log "分析提交模式和趋势"

    # 获取最近10次提交
    local recent_commits=$(git log --oneline -10 --pretty=format:'{"hash":"%h","message":"%s","date":"%ad"}' --date=short | jq -s '.')

    if [ "$(echo "$recent_commits" | jq length)" -lt 2 ]; then
        log "提交历史不足，跳过模式分析"
        return
    fi

    # 分析提交频率
    local commit_frequency=$(echo "$recent_commits" | jq 'length / (((now - (.[0].date | strptime("%Y-%m-%d") | mktime)) / 86400) + 1)')

    # 分析提交类型分布
    local type_distribution=$(echo "$recent_commits" | jq '[.[] | .message | capture("^(?<type>[a-zA-Z]+).*")] | group_by(.type) | map({type: .[0].type, count: length})')

    # 分析提交消息质量
    local avg_message_length=$(echo "$recent_commits" | jq '[.[] | .message | length] | add / length')

    # 生成洞察
    local insights=""
    if [ "$(echo "$commit_frequency > 2" | bc -l)" -eq 1 ]; then
        insights="${insights}提交频率较高，建议定期review; "
    fi

    if echo "$type_distribution" | jq -e 'any(.type == "fix"; .count > 3)' >/dev/null; then
        insights="${insights}近期有较多bug修复，建议检查代码质量; "
    fi

    if [ "$(echo "$avg_message_length < 20" | bc -l)" -eq 1 ]; then
        insights="${insights}提交消息较短，建议提供更详细的描述; "
    fi

    # 保存分析结果
    local analysis_record=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "analysis_type": "commit_patterns",
  "commit_frequency": $commit_frequency,
  "type_distribution": $type_distribution,
  "avg_message_length": $avg_message_length,
  "insights": "$insights",
  "sample_size": $(echo "$recent_commits" | jq length)
}
EOF
)

    # 保存到生长系统
    if [ -f "$SCRIPT_DIR/growth-recorder.sh" ]; then
        bash "$SCRIPT_DIR/growth-recorder.sh" record "commit-pattern-analysis" "$analysis_record" "completed" 2>/dev/null || true
    fi

    if [ -n "$insights" ]; then
        echo -e "${BLUE}📊 提交模式分析:${NC}" >&2
        echo -e "${CYAN}  $insights${NC}" >&2
    fi

    log "提交模式分析完成"
}

# 检查推送状态和建议
check_push_status() {
    log "检查推送状态"

    local current_branch=$(git branch --show-current)

    # 检查是否有远程分支
    if git ls-remote --heads origin "$current_branch" >/dev/null 2>&1; then
        # 检查是否领先远程
        local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null || echo "0 0")
        local ahead=$(echo $ahead_behind | cut -d' ' -f1)
        local behind=$(echo $ahead_behind | cut -d' ' -f2)

        if [ "$ahead" -gt 0 ]; then
            echo -e "${YELLOW}📤 分支领先远程 $ahead 个提交${NC}" >&2
            echo -e "${CYAN}💡 建议执行: git push origin $current_branch${NC}" >&2
        fi

        if [ "$behind" -gt 0 ]; then
            echo -e "${YELLOW}📥 分支落后远程 $behind 个提交${NC}" >&2
            echo -e "${CYAN}💡 建议执行: git pull --rebase origin $current_branch${NC}" >&2
        fi

        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            echo -e "${GREEN}✅ 分支与远程同步${NC}" >&2
        fi
    else
        echo -e "${YELLOW}📝 远程分支不存在${NC}" >&2
        echo -e "${CYAN}💡 首次推送请执行: git push -u origin $current_branch${NC}" >&2
    fi
}

# 生成提交摘要报告
generate_commit_summary() {
    log "生成提交摘要报告"

    local commit_message="$1"

    echo "" >&2
    echo -e "${BLUE}📋 提交摘要报告${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${CYAN}📝 提交信息: ${NC}$commit_message" >&2
    echo -e "${CYAN}🕒 提交时间: ${NC}$(date)" >&2
    echo -e "${CYAN}👤 提交者: ${NC}$(git config user.name) <$(git config user.email)>" >&2
    echo -e "${CYAN}🌿 当前分支: ${NC}$(git branch --show-current)" >&2

    # 显示变更概览
    local changed_files=$(git show --name-only --pretty="" | head -10)
    echo -e "${CYAN}📁 变更文件 (${NC}$(echo "$changed_files" | wc -l) 个${CYAN}):${NC}" >&2
    echo "$changed_files" | head -5 | sed 's/^/    /' >&2
    if [ $(echo "$changed_files" | wc -l) -gt 5 ]; then
        echo -e "${CYAN}    ... 还有 $(($(echo "$changed_files" | wc -l) - 5)) 个文件${NC}" >&2
    fi

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
}

# 主处理函数
main() {
    local hook_event="$1"
    local commit_message="$2"

    log "执行后提交日志记录钩子: $hook_event"

    case "$hook_event" in
        "post-commit")
            # 标准Git post-commit钩子处理
            log "记录提交统计信息"
            log_commit_stats "$commit_message"

            # 分析提交模式（每5次提交执行一次）
            local commit_count=$(git rev-list --count HEAD)
            if [ $((commit_count % 5)) -eq 0 ]; then
                analyze_commit_patterns
            fi

            # 检查推送状态
            check_push_status

            # 生成摘要报告
            generate_commit_summary "$commit_message"

            log "后提交日志记录完成"
            ;;

        "log-stats")
            # 仅记录统计信息
            log_commit_stats "$commit_message"
            ;;

        "generate-report")
            # 仅生成报告
            generate_commit_summary "$commit_message"
            ;;

        *)
            log "未知钩子事件: $hook_event"
            exit 1
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi