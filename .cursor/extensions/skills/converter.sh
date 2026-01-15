#!/bin/bash

# 🎯 Skills格式转换器
# 将Anthropic SKILL.md格式转换为Cursor AI Rules格式

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="/home/saida/workspace/skills/skills"

# 转换单个技能
convert_skill() {
    local skill_name="$1"
    local skill_md="$SKILLS_SOURCE/$skill_name/SKILL.md"
    local output_file="$SCRIPT_DIR/${skill_name}.md"

    echo "🔄 转换技能: $skill_name"

    if [ ! -f "$skill_md" ]; then
        echo "❌ 未找到: $skill_md"
        return 1
    fi

    # 读取并转换
    local content=$(cat "$skill_md")

    # 提取元数据
    local name=$(echo "$content" | grep "^name:" | head -1 | sed 's/name: //' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//")
    local description=$(echo "$content" | grep "^description:" | head -1 | sed 's/description: //' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//")

    # 获取主体内容
    local body=$(echo "$content" | sed -n '/^---$/,/^---$/p' | sed '1d;$d' | sed '1d')

    # 生成新格式
    cat > "$output_file" << EOF
---
command: skill:$name
description: "🎯 Skills扩展: $description"
alwaysApply: false
---

# 🎯 Skills扩展: $name

$description

## 🔧 使用方法

\`\`\`bash
@master skill:$name [参数]
\`\`\`

## 📚 原始文档

$body

---
*来源: Anthropic Skills库 | 集成时间: 2026-01-15*
EOF

    echo "✅ 完成: $output_file"
}

# 转换所有技能
convert_all() {
    echo "🚀 开始转换所有技能..."

    local skills=(
        "algorithmic-art"
        "brand-guidelines"
        "canvas-design"
        "doc-coauthoring"
        "docx"
        "frontend-design"
        "internal-comms"
        "mcp-builder"
        "pdf"
        "pptx"
        "skill-creator"
        "slack-gif-creator"
        "theme-factory"
        "webapp-testing"
        "web-artifacts-builder"
        "xlsx"
    )

    for skill in "${skills[@]}"; do
        convert_skill "$skill"
    done

    echo "✅ 转换完成!"
}

# 主函数
case "${1:-}" in
    "--all") convert_all ;;
    *) convert_skill "$1" ;;
esac