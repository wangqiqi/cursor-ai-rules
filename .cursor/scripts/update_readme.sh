#!/bin/bash

# 独立的README更新脚本
# 用于手动更新README.md，集成最新的项目状态

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "🔄 更新README.md..."
cd "$PROJECT_ROOT"

if [ -f ".cursor/scripts/generate_readme.sh" ]; then
    bash ".cursor/scripts/generate_readme.sh"
    echo "✅ README.md 更新完成！"
    echo ""
    echo "📊 当前状态摘要："

    # 显示关键统计信息
    RULE_COUNT=$(find .cursor/rules -name "RULE.md" | wc -l)
    SCRIPT_COUNT=$(find .cursor/rules -name "*.sh" | wc -l)
    TEMPLATE_COUNT=$(find .cursor/rules -name "*.json" | wc -l)

    echo "   • 规则数量: $RULE_COUNT"
    echo "   • 脚本数量: $SCRIPT_COUNT"
    echo "   • 配置数量: $TEMPLATE_COUNT"

    # 显示最新感知数据
    if [ -d ".cursor/data" ]; then
        LATEST_DATA=$(find .cursor/data -name "perception_*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
        if [ -f "$LATEST_DATA" ]; then
            LAST_UPDATE=$(stat -c '%y' "$LATEST_DATA" 2>/dev/null | cut -d'.' -f1 || echo "未知")
            echo "   • 最后感知: $LAST_UPDATE"
        fi
    fi

else
    echo "❌ 错误: README生成器脚本不存在"
    exit 1
fi
