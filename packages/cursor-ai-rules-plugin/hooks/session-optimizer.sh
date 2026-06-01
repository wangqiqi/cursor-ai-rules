#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# ⚡ 会话优化钩子 - 会话开始时自动进行系统优化
# 基于 optimizer.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")

# 只在会话开始事件中执行
if [[ "$event_type" == "onSessionStart" ]]; then
    echo "⚡ 检测到会话开始事件，开始系统优化..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../core/optimizer.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  优化器脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 执行系统优化（异步，不阻塞会话启动）
    (
        echo "🔧 执行系统优化..." >&2
        if bash "$CORE_SCRIPT" > /dev/null 2>&1; then
            echo "✅ 系统优化完成" >&2
        else
            echo "⚠️  系统优化失败，但不影响会话启动" >&2
        fi
    ) &

    # 立即返回，不等待优化完成
    echo "🔄 系统优化已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"