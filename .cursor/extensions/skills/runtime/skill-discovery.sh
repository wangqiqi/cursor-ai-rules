#!/bin/bash

# 🎯 Skills发现和加载器

echo "🎯 Skills扩展状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查目录结构
echo "📁 扩展目录: .cursor/extensions/skills"
echo "🔧 桥接目录: .cursor/extensions/skills/bridge"
echo "📋 注册表: .cursor/extensions/skills/registry/skills-registry.json"

# 检查文件状态
BRIDGE_DIR=".cursor/extensions/skills/bridge"
if [ -d "$BRIDGE_DIR" ]; then
    skill_count=$(find "$BRIDGE_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    echo "📄 转换技能: ${skill_count} 个"
else
    echo "⚠️  桥接目录不存在"
fi

REGISTRY_FILE=".cursor/extensions/skills/registry/skills-registry.json"
if [ -f "$REGISTRY_FILE" ]; then
    echo "✅ 注册表: 存在"
else
    echo "⚠️  注册表: 不存在"
fi

echo ""
echo "🎯 Skills集成测试完成"