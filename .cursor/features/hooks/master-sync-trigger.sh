#!/bin/bash
# 🎯 Master同步触发钩子 - 检测对话框首次使用/master命令并触发同步
# 只在新对话框第一次使用/master时触发，避免重复同步

# 读取输入参数（JSON格式）
input=$(cat)

# 获取项目路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

# 检查对话框标识符是否存在
CONVERSATION_ID_FILE="/tmp/cursor-master-sync-conversation-$USER.id"
if [[ ! -f "$CONVERSATION_ID_FILE" ]]; then
    # 没有对话框标识符，直接返回（可能是旧对话框或初始化失败）
    echo "$input"
    exit 0
fi

CONVERSATION_ID=$(cat "$CONVERSATION_ID_FILE")
SYNC_MARKER_FILE="/tmp/cursor-master-sync-$CONVERSATION_ID.marker"

# 检查同步标记是否存在且为ready状态
if [[ ! -f "$SYNC_MARKER_FILE" ]] || [[ "$(cat "$SYNC_MARKER_FILE")" != "ready" ]]; then
    # 不是ready状态，直接返回（已触发过或不存在）
    echo "$input"
    exit 0
fi

# 解析输入内容，检测是否包含/master命令
prompt_text=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null || echo "")
has_master_command=$(echo "$prompt_text" | grep -c "/master" || echo "0")

if [[ "$has_master_command" -gt 0 ]]; then
    echo "🎯 检测到对话框 $CONVERSATION_ID 首次使用/master命令，触发同步..." >&2

    # 确保同步脚本存在
    CURSOR_SYNC_SCRIPT="$CURSOR_DIR/core/cursor-sync.sh"
    if [[ ! -f "$CURSOR_SYNC_SCRIPT" ]]; then
        echo "⚠️  Cursor同步脚本不存在: $CURSOR_SYNC_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 标记为已触发同步，避免重复
    echo "triggered" > "$SYNC_MARKER_FILE"

    # 执行同步（后台进行）
    (
        echo "📤 执行Cursor对话记录同步..." >&2
        if bash "$CURSOR_SYNC_SCRIPT" sync > /dev/null 2>&1; then
            echo "✅ Cursor同步完成" >&2
            # 标记同步成功
            echo "completed" > "$SYNC_MARKER_FILE"
        else
            echo "⚠️  Cursor同步失败，但不影响命令执行" >&2
            # 重置标记，允许重试
            echo "ready" > "$SYNC_MARKER_FILE"
        fi
    ) &

    echo "🔄 对话框 $CONVERSATION_ID 同步已启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"