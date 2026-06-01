#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 📦 依赖检查钩子 - 文件保存后自动检查依赖关系
# 基于 dependency-checker.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
file_path=$(echo "$input" | jq -r '.file // empty' 2>/dev/null || echo "")

# 只在文件保存事件中执行，且仅针对相关文件
if [[ "$event_type" == "afterFileSave" ]] && [[ -n "$file_path" ]]; then
    # 检查是否是可能影响依赖关系的文件
    if [[ "$file_path" =~ (package\.json|requirements\.txt|pyproject\.toml|Cargo\.toml|go\.mod) ]] || [[ "$file_path" =~ (setup\.py|composer\.json) ]]; then
        echo "📦 检测到依赖文件保存事件，开始依赖检查..." >&2

        # 获取脚本目录
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        CORE_SCRIPT="$SCRIPT_DIR/../core/dependency-checker.sh"

        # 检查核心脚本是否存在
        if [ ! -f "$CORE_SCRIPT" ]; then
            echo "⚠️  依赖检查脚本不存在: $CORE_SCRIPT" >&2
            echo "$input"
            exit 0
        fi

        # 执行依赖检查（异步，不阻塞）
        (
            echo "🔗 执行依赖关系检查..." >&2
            if bash "$CORE_SCRIPT" > /dev/null 2>&1; then
                echo "✅ 依赖检查完成" >&2
            else
                echo "⚠️  依赖检查失败，建议检查依赖配置" >&2
            fi
        ) &

        # 立即返回，不等待检查完成
        echo "🔄 依赖检查已在后台启动" >&2
    fi
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"