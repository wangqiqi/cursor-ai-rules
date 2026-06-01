#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# ⚙️ 配置验证钩子 - 文件保存后自动验证配置文件
# 基于 config-validator.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
file_path=$(echo "$input" | jq -r '.file // empty' 2>/dev/null || echo "")

# 只在文件保存事件中执行，且仅针对配置文件
if [[ "$event_type" == "afterFileSave" ]] && [[ -n "$file_path" ]]; then
    # 检查是否是配置文件
    if [[ "$file_path" =~ \.(json|yaml|yml|toml|ini|conf|config)$ ]] || [[ "$file_path" =~ (config|settings) ]]; then
        echo "⚙️ 检测到配置文件保存事件，开始配置验证..." >&2

        # 获取脚本目录
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        CORE_SCRIPT="$SCRIPT_DIR/../core/core/config/config-validator.sh"

        # 检查核心脚本是否存在
        if [ ! -f "$CORE_SCRIPT" ]; then
            echo "⚠️  配置验证脚本不存在: $CORE_SCRIPT" >&2
            echo "$input"
            exit 0
        fi

        # 执行配置验证（异步，不阻塞）
        (
            echo "🔍 执行配置验证..." >&2
            if bash "$CORE_SCRIPT" "$file_path" > /dev/null 2>&1; then
                echo "✅ 配置验证完成" >&2
            else
                echo "⚠️  配置验证失败，建议检查配置文件" >&2
            fi
        ) &

        # 立即返回，不等待验证完成
        echo "🔄 配置验证已在后台启动" >&2
    fi
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"