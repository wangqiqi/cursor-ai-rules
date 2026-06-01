#!/bin/bash
# 🔄 Cursor同步钩子 - 会话结束时自动同步对话记录
# 基于 cursor-sync.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")

# 只在会话结束事件中执行
if [[ "$event_type" == "onSessionEnd" ]]; then
    echo "🔄 检测到会话结束事件，开始Cursor同步..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../../core/cursor-sync.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  Cursor同步脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 执行Cursor同步（异步，不阻塞会话结束）
    (
        echo "📤 执行对话记录同步..." >&2
        if bash "$CORE_SCRIPT" sync > /dev/null 2>&1; then
            echo "✅ Cursor同步完成" >&2
        else
            echo "⚠️  Cursor同步失败，但不影响会话结束" >&2
        fi
    ) &

    # 立即返回，不等待同步完成
    echo "🔄 Cursor同步已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"