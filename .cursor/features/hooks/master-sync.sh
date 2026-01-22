#!/bin/bash
# 🎯 Master命令同步钩子 - 首次使用/master时自动同步Cursor对话记录
# 实现实时同步，避免等到会话结束

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")

# 只在beforeSubmitPrompt事件中处理
if [[ "$event_type" == "beforeSubmitPrompt" ]]; then
    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

    # 解析输入内容，检测是否包含/master命令
    prompt_text=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null || echo "")
    has_master_command=$(echo "$prompt_text" | grep -c "/master" || echo "0")

    if [[ "$has_master_command" -gt 0 ]]; then
        echo "🎯 检测到/master命令，检查是否需要同步..." >&2

        # 检查同步状态文件
        SYNC_STATUS_FILE="$PROJECT_ROOT/.cursorGrowth/integrations/sync/cursor_sync_status.json"
        CURSOR_SYNC_SCRIPT="$CURSOR_DIR/core/cursor-sync.sh"

        # 确保同步脚本存在
        if [[ ! -f "$CURSOR_SYNC_SCRIPT" ]]; then
            echo "⚠️  Cursor同步脚本不存在: $CURSOR_SYNC_SCRIPT" >&2
            echo "$input"
            exit 0
        fi

        # 检查是否已经同步过今天的对话
        needs_sync=false
        if [[ ! -f "$SYNC_STATUS_FILE" ]]; then
            needs_sync=true
            echo "🔄 首次同步，准备同步Cursor对话记录..." >&2
        else
            # 检查今天是否已经同步过
            last_sync=$(jq -r '.sync_status.last_sync // empty' "$SYNC_STATUS_FILE" 2>/dev/null || echo "")
            today=$(date '+%Y-%m-%d')

            if [[ -z "$last_sync" ]] || [[ "$last_sync" != *"$today"* ]]; then
                needs_sync=true
                echo "🔄 今日首次使用/master，准备同步最新对话记录..." >&2
            else
                echo "⏭️  今日已同步，跳过重复同步" >&2
            fi
        fi

        # 执行同步（如果需要）
        if [[ "$needs_sync" == true ]]; then
            (
                echo "📤 执行Cursor对话记录同步..." >&2
                if bash "$CURSOR_SYNC_SCRIPT" sync > /dev/null 2>&1; then
                    echo "✅ Cursor同步完成" >&2
                else
                    echo "⚠️  Cursor同步失败，但不影响命令执行" >&2
                fi
            ) &
        fi
    fi
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"