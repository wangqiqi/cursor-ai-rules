#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🎯 Skills发现和加载器 - 扁平化版本

echo "🎯 Skills扩展状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 获取正确的路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查扁平化目录结构
echo "📁 技能目录: $SCRIPT_DIR"

# 检查文件状态
SKILLS_DIR="$SCRIPT_DIR"
if [ -d "$SKILLS_DIR" ]; then
    skill_count=$(find "$SKILLS_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    script_count=$(find "$SKILLS_DIR" -name "*.sh" -type f 2>/dev/null | wc -l)
    echo "📄 技能文件: ${skill_count} 个"
    echo "🔧 工具脚本: ${script_count} 个"
else
    echo "⚠️  技能目录不存在"
fi

REGISTRY_FILE="$SCRIPT_DIR/registry.json"
if [ -f "$REGISTRY_FILE" ]; then
    echo "✅ 注册表: 存在"
else
    echo "⚠️  注册表: 不存在"
fi

CONVERTER_FILE="$SCRIPT_DIR/converter.sh"
if [ -f "$CONVERTER_FILE" ]; then
    echo "✅ 转换器: 存在"
else
    echo "⚠️  转换器: 不存在"
fi

echo ""
echo "🎯 Skills扁平化结构检查完成"