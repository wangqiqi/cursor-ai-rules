#!/bin/bash
# 🎯 会话状态守护钩子
# 确保角色激活与 Master 初始化只在必要时触发（避免重复）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
STATE_DIR="$PROJECT_ROOT/.cursor/.state"
ROLE_MARKER="$STATE_DIR/role-activation.done"
MASTER_MARKER="$STATE_DIR/master-init.done"

HOOK_EVENT="${1:-unknown}"
HOOK_INPUT="$(cat)"

mkdir -p "$STATE_DIR"

reset_session_markers() {
    rm -f "$ROLE_MARKER" "$MASTER_MARKER"
    echo "🌀 会话启动，清理角色与初始化标记" >&2
}

ensure_role_activation() {
    if [[ -f "$ROLE_MARKER" ]]; then
        echo "🎭 角色标记已存在，跳过重复激活" >&2
        return
    fi

    bash "$SCRIPT_DIR/role-activation.sh" "$HOOK_EVENT" "$HOOK_INPUT" >/dev/null 2>&1 || true
    touch "$ROLE_MARKER"
}

ensure_master_init() {
    if [[ -f "$MASTER_MARKER" ]]; then
        echo "🚀 Master 初始化标记已存在，跳过重复初始化" >&2
        return
    fi

    bash "$SCRIPT_DIR/master-init.sh" <<< "$HOOK_INPUT" >/dev/null 2>&1 || true
    touch "$MASTER_MARKER"
}

case "$HOOK_EVENT" in
    onSessionStart)
        reset_session_markers
        ;;
    beforeSubmitPrompt)
        ensure_role_activation
        ensure_master_init
        ;;
    onConversationStart)
        ensure_role_activation
        ;;
    *)
        echo "ℹ️ 未知事件 $HOOK_EVENT，保持当前状态" >&2
        ;;
esac

echo "$HOOK_INPUT"
