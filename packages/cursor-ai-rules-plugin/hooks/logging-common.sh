#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 🎯 钩子通用日志钩子
# 合并命令日志 + 事件日志逻辑，统一记录到 .cursor/monitoring/logs/hooks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
HOOK_LOG_DIR="$PROJECT_ROOT/.cursor/monitoring/logs/hooks"

mkdir -p "$HOOK_LOG_DIR"

HOOK_TYPE="${1:-command}"
INPUT="$(cat)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

log_to_file() {
    local file_path="$1"
    local entry="$2"
    mkdir -p "$(dirname "$file_path")"
    echo "$entry" >> "$file_path"
}

log_command() {
    local command
    local output
    local duration
    local cwd
    local conversation_id

    command="$(echo "$INPUT" | jq -r '.command // empty' 2>/dev/null || echo "")"
    output="$(echo "$INPUT" | jq -r '.output // empty' 2>/dev/null || echo "")"
    duration="$(echo "$INPUT" | jq -r '.duration // 0' 2>/dev/null || echo "0")"
    cwd="$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")"
    conversation_id="$(echo "$INPUT" | jq -r '.conversation_id // empty' 2>/dev/null || echo "")"

    local command_type="unknown"
    if [[ "$command" =~ ^(ls|pwd|cd|mkdir|touch) ]]; then
        command_type="file_system"
    elif [[ "$command" =~ ^(git|gh) ]]; then
        command_type="version_control"
    elif [[ "$command" =~ ^(npm|yarn|pnpm|pip|python|node) ]]; then
        command_type="package_management"
    elif [[ "$command" =~ ^(curl|wget|http) ]]; then
        command_type="network"
    elif [[ "$command" =~ ^(ps|top|kill|systemctl) ]]; then
        command_type="system"
    elif [[ "$command" =~ ^(\./|\.cursor/scripts/) ]]; then
        command_type="project_script"
    fi

    local output_length="${#output}"
    local log_entry="$TIMESTAMP|$conversation_id|$command_type|$command|$duration|$output_length|$cwd"
    log_to_file "$HOOK_LOG_DIR/command-execution.log" "$log_entry"

    if (( duration > 10000 )); then
        log_to_file "$HOOK_LOG_DIR/performance-warnings.log" "[$TIMESTAMP] SLOW_COMMAND: $command took ${duration}ms"
    fi

    if [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]] || [[ "$output" == *"ERROR"* ]]; then
        log_to_file "$HOOK_LOG_DIR/command-errors.log" "[$TIMESTAMP] COMMAND_ERROR: $command"
        log_to_file "$HOOK_LOG_DIR/command-errors.log" "Error output: $output"
    fi

    echo "📝 命令日志已记录: $command_type" >&2
}

log_event() {
    local event_type
    local details

    event_type="$(echo "$INPUT" | jq -r '.event // empty' 2>/dev/null || echo 'unknown_event')"
    details="$(echo "$INPUT" | jq -r '.details // "无详情"' 2>/dev/null || echo '无详情')"

    local log_entry="[$TIMESTAMP] event=$event_type details=$details"
    log_to_file "$HOOK_LOG_DIR/event.log" "$log_entry"
    echo "🗂️ 事件日志已记录: $event_type" >&2
}

case "$HOOK_TYPE" in
    command)
        log_command
        ;;
    event)
        log_event
        ;;
    *)
        echo "⚠️ 未知的日志类型: $HOOK_TYPE" >&2
        log_event
        ;;
esac

echo "$INPUT"
