#!/bin/bash

# AI共生项目规则自动适配脚本
# 用于将下载的规则自动适配到当前用户的环境

set -e

echo "🚀 AI共生项目规则自动适配工具"
echo "================================="

# 获取当前用户信息
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
CURRENT_TIME_ISO=$(date '+%Y-%m-%dT%H:%M:%S+08:00')
AUTHOR_NAME=$(git config --get user.name 2>/dev/null || echo "Unknown")
AUTHOR_EMAIL=$(git config --get user.email 2>/dev/null || echo "unknown@example.com")

echo "📋 当前环境信息："
echo "   时间: $CURRENT_TIME"
echo "   用户: $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo ""

# 设置环境变量
# 确保在项目根目录运行
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查脚本是否在 .cursor 目录中运行
if [[ "$(basename "$SCRIPT_DIR")" != ".cursor" ]]; then
    echo "❌ 错误: 请从项目根目录运行此脚本: ./cursor/cursor-adaptation-setup.sh"
    exit 1
fi

# 切换到项目根目录（.cursor 的父目录）
cd "$(dirname "$SCRIPT_DIR")"

BASE_DIR=".cursor"
if [ ! -d "$BASE_DIR" ]; then
    echo "❌ 错误: 未找到 .cursor 目录"
    exit 1
fi

# 设置备份目录
BACKUP_DIR="${BASE_DIR}/backup/$(date +%Y%m%d_%H%M%S)"

# 备份原文件
echo "💾 创建备份..."
mkdir -p "$BACKUP_DIR"
# exit 1

# 生成需要处理的文件列表
FILES_TO_UPDATE=(
    "${BASE_DIR}/README.md"
    "${BASE_DIR}/rules/constitution/RULE.md"
    "${BASE_DIR}/rules/philosophy/RULE.md"
    "${BASE_DIR}/rules/evolution/RULE.md"
    "${BASE_DIR}/rules/generator/RULE.md"
    "${BASE_DIR}/rules/templates/templates.json"
)

for file in "${FILES_TO_UPDATE[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/"
        echo "   备份: $file → $BACKUP_DIR/"
    fi
done

echo ""
echo "🔄 开始适配..."

# 替换规则文件中的硬编码信息和模板变量
for file in "${FILES_TO_UPDATE[@]}"; do
    if [ -f "$file" ]; then
        echo "   处理: $file"

        # 替换时间戳 (保持原有时区格式，但更新时间)
        sed -i "s/2025-12-21 11:41:30 CST/$CURRENT_TIME/g" "$file"

        # 替换模板变量
        sed -i "s/{{GENERATION_TIME}}/$CURRENT_TIME/g" "$file"
        sed -i "s/{{GENERATION_TIME_ISO}}/$CURRENT_TIME_ISO/g" "$file"
        sed -i "s/{{AUTHOR_NAME}}/$AUTHOR_NAME/g" "$file"
        sed -i "s/{{AUTHOR_EMAIL}}/$AUTHOR_EMAIL/g" "$file"

        # 替换硬编码的作者信息 (向后兼容)
        sed -i "s/jwzhou <zhou24388@163.com>/$AUTHOR_NAME <$AUTHOR_EMAIL>/g" "$file"
        sed -i "s/jwzhou/$AUTHOR_NAME/g" "$file"
        sed -i "s/zhou24388@163.com/$AUTHOR_EMAIL/g" "$file"
    fi
done

echo ""
echo "✅ 适配完成！"
echo ""
echo "📁 备份文件保存在: $BACKUP_DIR"
echo ""
echo "🎯 规则已适配到您的环境："
echo "   - 时间戳: $CURRENT_TIME"
echo "   - 作者信息: $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo ""
echo "💡 现在您可以开始使用这些个性化的AI协作规则了！"
