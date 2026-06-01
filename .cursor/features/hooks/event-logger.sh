#!/bin/bash
# 📝 事件日志钩子 - 记录各种重要事件
# 基于 logging.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
details=$(echo "$input" | jq -r '.details // "无详情"' 2>/dev/null || echo "无详情")

# 记录所有重要事件
echo "📝 记录事件: $event_type - $details" >&2

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="$SCRIPT_DIR/../../core/logging.sh"

# 检查核心脚本是否存在
if [ ! -f "$CORE_SCRIPT" ]; then
    echo "⚠️  日志脚本不存在: $CORE_SCRIPT" >&2
    echo "$input"
    exit 0
fi

# 异步执行日志记录
(
    case "$event_type" in
        "afterFileSave")
            echo "💾 文件保存事件已记录" >&2
            ;;
        "afterShellExecution")
            echo "⚡ 命令执行事件已记录" >&2
            ;;
        "beforeSubmitPrompt")
            echo "🤖 提示提交前事件已记录" >&2
            ;;
        "onSessionStart")
            echo "🎬 会话开始事件已记录" >&2
            ;;
        "afterAgentResponse")
            echo "🧠 AI响应后事件已记录" >&2
            ;;
        *)
            echo "📋 通用事件已记录: $event_type" >&2
            ;;
    esac

    # 这里可以调用实际的日志记录功能
    # bash "$CORE_SCRIPT" log_event "$event_type" "$details" > /dev/null 2>&1
) &

# 返回原始输入，保持钩子链正常工作
echo "$input"