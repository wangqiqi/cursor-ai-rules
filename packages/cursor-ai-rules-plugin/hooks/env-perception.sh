#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 🌍 环境感知钩子 - 会话开始时自动感知项目环境
# 基于 env-perception.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")

# 只在会话开始事件中执行
if [[ "$event_type" == "onSessionStart" ]]; then
    echo "🌍 检测到会话开始事件，开始环境感知..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../core/env-perception.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  环境感知脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 执行环境感知（异步，不阻塞会话启动）
    (
        echo "🔍 执行环境感知分析..." >&2
        if bash "$CORE_SCRIPT" > /dev/null 2>&1; then
            echo "✅ 环境感知完成" >&2
        else
            echo "⚠️  环境感知失败，但不影响会话启动" >&2
        fi
    ) &

    # 立即返回，不等待感知完成
    echo "🔄 环境感知已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"