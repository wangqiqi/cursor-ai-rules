#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 🔍 一致性检查钩子 - 文件保存后自动检查代码一致性
# 基于 consistency-checker.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
file_path=$(echo "$input" | jq -r '.file // empty' 2>/dev/null || echo "")

# 只在文件保存事件中执行
if [[ "$event_type" == "afterFileSave" ]] && [[ -n "$file_path" ]]; then
    echo "🔍 检测到文件保存事件，开始一致性检查..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../core/consistency-checker.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  一致性检查脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 执行一致性检查（异步，不阻塞）
    (
        echo "📋 执行一致性检查..." >&2
        if bash "$CORE_SCRIPT" > /dev/null 2>&1; then
            echo "✅ 一致性检查完成" >&2
        else
            echo "⚠️  一致性检查失败，但不影响文件保存" >&2
        fi
    ) &

    # 立即返回，不等待检查完成
    echo "🔄 一致性检查已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"