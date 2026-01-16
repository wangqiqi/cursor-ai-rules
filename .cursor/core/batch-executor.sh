#!/bin/bash

# 🚀 Cursor AI Rules - 批量操作执行器
# 合并小操作，减少shell调用开销

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/performance-cache.sh"

# 批量操作队列
declare -a BATCH_QUEUE=()
declare -A BATCH_RESULTS=()

# 添加操作到批量队列
batch_add() {
    local operation="$1"
    local params="$2"

    BATCH_QUEUE+=("$operation:$params")
    smart_echo "已添加到批量队列: $operation" "info"
}

# 批量执行所有操作
batch_execute() {
    local queue_size=${#BATCH_QUEUE[@]}

    if [ $queue_size -eq 0 ]; then
        smart_echo "批量队列为空" "warning"
        return 0
    fi

    smart_echo "开始批量执行 $queue_size 个操作" "processing"

    local start_time=$(date +%s)
    local completed=0
    local failed=0

    for item in "${BATCH_QUEUE[@]}"; do
        local operation="${item%%:*}"
        local params="${item#*:}"

        completed=$((completed + 1))
        show_batch_progress "$completed" "$queue_size" "$operation"

        if execute_single_operation "$operation" "$params"; then
            show_compact_success
            BATCH_RESULTS["$operation"]="success"
        else
            echo "❌"
            failed=$((failed + 1))
            BATCH_RESULTS["$operation"]="failed"
        fi
    done

    # 清空队列
    BATCH_QUEUE=()

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    smart_echo "批量执行完成: $completed 成功, $failed 失败 (${duration}s)" "info"

    # 返回执行结果
    echo "{\"batch_result\": {\"total\": $queue_size, \"successful\": $((queue_size - failed)), \"failed\": $failed, \"duration_seconds\": $duration}}"
}

# 执行单个操作
execute_single_operation() {
    local operation="$1"
    local params="$2"

    case "$operation" in
        "env_check")
            # 环境检查（使用缓存）
            cached_env_perception >/dev/null 2>&1
            ;;
        "file_check")
            # 文件存在性检查
            [ -f "$params" ]
            ;;
        "dir_check")
            # 目录存在性检查
            [ -d "$params" ]
            ;;
        "git_status")
            # Git状态检查（精简版）
            git rev-parse --git-dir >/dev/null 2>&1 && echo "git_repo" || echo "no_git"
            ;;
        "package_check")
            # 包管理器检查
            case "$params" in
                "npm")
                    command -v npm >/dev/null 2>&1 && echo "installed" || echo "missing"
                    ;;
                "pip")
                    command -v pip >/dev/null 2>&1 && echo "installed" || echo "missing"
                    ;;
                "yarn")
                    command -v yarn >/dev/null 2>&1 && echo "installed" || echo "missing"
                    ;;
            esac
            ;;
        "lint_check")
            # 代码检查（异步执行）
            run_quick_lint "$params" &
            ;;
        *)
            smart_echo "未知操作: $operation" "warning"
            return 1
            ;;
    esac
}

# 快速代码检查
run_quick_lint() {
    local file_pattern="$1"

    # 只检查基本语法错误，不进行详细分析
    if [ -f "package.json" ] && command -v node >/dev/null 2>&1; then
        # JavaScript/TypeScript 快速检查
        find . -name "$file_pattern" -type f | head -10 | xargs -I {} node -c {} 2>/dev/null && echo "syntax_ok" || echo "syntax_error"
    else
        echo "no_js_checker"
    fi
}

# 智能批量分组
group_operations() {
    local operations="$1"

    # 将相似操作分组执行
    local file_checks=$(echo "$operations" | jq -r '.[] | select(.type == "file_check") | .params' 2>/dev/null | tr '\n' ' ')
    local dir_checks=$(echo "$operations" | jq -r '.[] | select(.type == "dir_check") | .params' 2>/dev/null | tr '\n' ' ')
    local env_checks=$(echo "$operations" | jq -r '.[] | select(.type == "env_check") | .params' 2>/dev/null | tr '\n' ' ')

    # 批量文件检查
    if [ -n "$file_checks" ]; then
        batch_add "batch_file_check" "$file_checks"
    fi

    # 批量目录检查
    if [ -n "$dir_checks" ]; then
        batch_add "batch_dir_check" "$dir_checks"
    fi

    # 环境检查（通常只有一个）
    if [ -n "$env_checks" ]; then
        batch_add "env_check" ""
    fi
}

# 批量文件检查
execute_batch_file_check() {
    local files="$1"
    local result="{"

    for file in $files; do
        if [ -f "$file" ]; then
            result="$result \"$file\": true,"
        else
            result="$result \"$file\": false,"
        fi
    done

    result="${result%,}}"
    echo "$result"
}

# 批量目录检查
execute_batch_dir_check() {
    local dirs="$1"
    local result="{"

    for dir in $dirs; do
        if [ -d "$dir" ]; then
            result="$result \"$dir\": true,"
        else
            result="$result \"$dir\": false,"
        fi
    done

    result="${result%,}}"
    echo "$result"
}

# 并行执行器（实验性）
parallel_execute() {
    local operations="$1"
    local max_parallel="${2:-4}"

    # 将操作分批并行执行
    echo "$operations" | jq -c '.[]' | xargs -n 1 -P "$max_parallel" -I {} bash -c '
        operation=$(echo "$1" | jq -r ".type")
        params=$(echo "$1" | jq -r ".params")
        execute_single_operation "$operation" "$params"
    ' -- {}
}

# 性能优化的决策执行
optimized_decision_execute() {
    local decision_json="$1"

    # 解析决策
    local should_execute=$(echo "$decision_json" | jq -r '.decision_making.should_execute')
    local execution_plan=$(echo "$decision_json" | jq -r '.decision_making.execution_plan[]' 2>/dev/null)

    if [ "$should_execute" != "true" ]; then
        smart_echo "决策结果: 不需要执行操作" "info"
        return 0
    fi

    # 分析操作依赖关系
    local independent_ops=""
    local sequential_ops=""

    while read -r action; do
        if [ -n "$action" ] && [ "$action" != "null" ]; then
            case "$action" in
                "env_check"|"file_check"|"dir_check")
                    # 独立操作，可以并行
                    independent_ops="$independent_ops{\"type\":\"$action\",\"params\":\"\"},"
                    ;;
                *)
                    # 顺序操作
                    sequential_ops="$sequential_ops$action "
                    ;;
            esac
        fi
    done <<< "$execution_plan"

    # 执行独立操作（批量）
    if [ -n "$independent_ops" ]; then
        independent_ops="[${independent_ops%,}]"
        group_operations "$independent_ops"
        batch_execute
    fi

    # 执行顺序操作
    for action in $sequential_ops; do
        smart_echo "执行顺序操作: $action" "processing"
        execute_single_operation "$action" ""
    done
}

# 清理函数
batch_cleanup() {
    BATCH_QUEUE=()
    BATCH_RESULTS=()
}

# 导出函数
export -f batch_add
export -f batch_execute
export -f execute_single_operation
export -f optimized_decision_execute
export -f batch_cleanup