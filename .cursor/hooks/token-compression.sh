#!/bin/bash
# 🎯 Token压缩钩子 - AI响应后自动进行Token压缩优化
# 基于 token-compression.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
response_text=$(echo "$input" | jq -r '.response // empty' 2>/dev/null || echo "")

# 只在AI响应后事件中执行
if [[ "$event_type" == "afterAgentResponse" ]] && [[ -n "$response_text" ]]; then
    echo "🎯 检测到AI响应事件，开始Token压缩..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../../core/token-compression.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  Token压缩脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 执行Token压缩（异步，不阻塞）
    (
        echo "🔧 执行Token压缩优化..." >&2
        if bash "$CORE_SCRIPT" > /dev/null 2>&1; then
            echo "✅ Token压缩完成" >&2
        else
            echo "⚠️  Token压缩失败，但不影响AI响应" >&2
        fi
    ) &

    # 立即返回，不等待压缩完成
    echo "🔄 Token压缩已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"