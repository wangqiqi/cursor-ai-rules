#!/bin/bash

# Cursor AI Rules - Agent Skills转换脚本
# 用于将传统技能格式转换为Agent Skills标准格式

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PROJECT_ROOT/.cursor/skills"
EXTENSIONS_DIR="$PROJECT_ROOT/.cursor/extensions/skills"

echo "🚀 开始转换Cursor AI Rules技能到Agent Skills标准"
echo "📁 项目根目录: $PROJECT_ROOT"
echo "🎯 目标目录: $SKILLS_DIR"
echo ""

# 确保目标目录存在
mkdir -p "$SKILLS_DIR"

# 要转换的技能列表
SKILLS_TO_CONVERT=(
    "algorithmic-art"
    "brand-guidelines"
    "canvas-design"
    "doc-coauthoring"
    "internal-comms"
    "mcp-builder"
    "slack-gif-creator"
    "theme-factory"
    "web-artifacts-builder"
)

echo "📋 待转换技能列表:"
for skill in "${SKILLS_TO_CONVERT[@]}"; do
    echo "  - $skill"
done
echo ""

# 转换函数
convert_skill() {
    local skill_name="$1"
    local source_file="$EXTENSIONS_DIR/${skill_name}.md"
    local target_dir="$SKILLS_DIR/$skill_name"
    local target_file="$target_dir/SKILL.md"

    if [ ! -f "$source_file" ]; then
        echo "⚠️  跳过 $skill_name: 源文件不存在"
        return 1
    fi

    echo "🔄 转换 $skill_name..."

    # 创建目标目录
    mkdir -p "$target_dir"

    # 读取源文件
    local content=$(cat "$source_file")

    # 提取frontmatter信息
    local description=$(echo "$content" | grep 'description:' | head -1 | sed 's/description: "\(.*\)"/\1/' | sed "s/description: '\(.*\)'/\1/")

    # 如果没有提取到描述，使用默认值
    if [ -z "$description" ]; then
        description="Professional skill for $skill_name operations"
    fi

    # 生成新的SKILL.md内容
    cat > "$target_file" << EOF
---
name: $skill_name
description: $description
---

# 🎯 ${skill_name//-/ }

$content

## When to Use

- When you need to work with $skill_name related tasks
- For professional $skill_name operations and automation
- When requiring specialized tools for $skill_name processing

## Instructions

This skill provides comprehensive support for $skill_name operations.
Please refer to the documentation above for detailed usage instructions.

## Dependencies

- Check the original documentation for required dependencies
- Ensure all prerequisites are installed before use

---
*Converted from legacy format | Migration: 2026-01-15*
EOF

    echo "✅ 转换完成: $skill_name"
    return 0
}

# 转换所有技能
converted_count=0
total_count=${#SKILLS_TO_CONVERT[@]}

for skill in "${SKILLS_TO_CONVERT[@]}"; do
    if convert_skill "$skill"; then
        ((converted_count++))
    fi
done

echo ""
echo "🎉 转换完成!"
echo "📊 统计: $converted_count/$total_count 个技能转换成功"
echo ""
echo "📝 接下来:"
echo "1. 测试转换后的技能是否正常工作"
echo "2. 更新registry.json中的技能状态"
echo "3. 提交更改到版本控制"
echo ""

# 显示当前技能状态
echo "📁 当前Agent Skills目录状态:"
ls -la "$SKILLS_DIR" | grep -E "^d" | tail -n +2 | while read -r line; do
    dir_name=$(echo "$line" | awk '{print $9}')
    if [ -n "$dir_name" ] && [ "$dir_name" != "." ] && [ "$dir_name" != ".." ]; then
        skill_file="$SKILLS_DIR/$dir_name/SKILL.md"
        if [ -f "$skill_file" ]; then
            echo "  ✅ $dir_name (Agent Skills)"
        else
            echo "  ⚠️  $dir_name (目录存在但无SKILL.md)"
        fi
    fi
done