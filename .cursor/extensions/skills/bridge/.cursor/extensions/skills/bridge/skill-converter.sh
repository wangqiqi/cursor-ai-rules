#!/bin/bash

# 🎯 Skills格式转换器
# 将Anthropic SKILL.md格式转换为Cursor AI Rules格式
#
# 使用方法:
#   ./skill-converter.sh <skill_name>    # 转换单个技能
#   ./skill-converter.sh --all           # 转换所有技能

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_SOURCE="/home/saida/workspace/skills/skills"
BRIDGE_DIR="$SCRIPT_DIR"
REGISTRY_FILE="$EXTENSIONS_DIR/registry/skills-registry.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 显示帮助信息
show_help() {
    echo -e "${CYAN}🎯 Skills格式转换器${NC}"
    echo
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 <skill_name>     # 转换单个技能"
    echo "  $0 --all           # 转换所有技能"
    echo "  $0 --help          # 显示帮助信息"
    echo
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 docx            # 转换docx技能"
    echo "  $0 --all           # 转换所有16个技能"
}

# 转换单个SKILL.md到cursor规则格式
convert_skill() {
    local skill_name="$1"
    local skill_source="$SKILLS_SOURCE/$skill_name"
    local skill_md="$skill_source/SKILL.md"
    local output_file="$BRIDGE_DIR/${skill_name}.md"

    echo -e "${BLUE}🔄 转换技能: ${CYAN}$skill_name${NC}"

    # 检查源文件是否存在
    if [ ! -f "$skill_md" ]; then
        echo -e "${RED}❌ 错误: 未找到技能文件 '$skill_md'${NC}"
        return 1
    fi

    # 读取SKILL.md内容
    local content=$(cat "$skill_md")

    # 解析YAML frontmatter
    local name=$(echo "$content" | grep "^name:" | head -1 | sed 's/name: //' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//")
    local description=$(echo "$content" | grep "^description:" | head -1 | sed 's/description: //' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//")
    local license=$(echo "$content" | grep "^license:" | head -1 | sed 's/license: //' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//")

    # 获取markdown内容（去掉frontmatter）
    local body=$(echo "$content" | awk '
    /^---$/ { frontmatter_count++ }
    frontmatter_count >= 2 { print }
    ' | sed '1d')  # 移除第一个---后的空行

    # 生成Cursor规则格式
    cat > "$output_file" << EOF
---
command: skill:$name
description: "🎯 Skills扩展: $description | 来源: Anthropic Skills库"
alwaysApply: false
skill_metadata:
  original_name: "$name"
  source_path: "$skill_source"
  category: "$(get_skill_category "$name")"
  dependencies: $(get_skill_dependencies "$name" | jq -R . | jq -s .)
  license: "$license"
---

# 🎯 Skills扩展: $name

*版本: 1.0.0 | 最后更新: 2026-01-15 | 作者: wangqiqi (https://github.com/wangqiqi)*
*原技能来源: Anthropic Skills库 | 许可证: $license*

## 📋 技能概述

$description

## 🔧 使用方法

此技能已集成到Cursor AI Rules系统中，可以通过以下方式调用：

\`\`\`bash
@master skill:$name [参数]    # 直接调用此技能
\`\`\`

## 📚 原始技能文档

---

$body

---

*💡 此技能由Anthropic Skills库转换而来，已适配Cursor AI Rules系统架构。*
EOF

    echo -e "${GREEN}✅ 转换完成: $output_file${NC}"
}

# 获取技能分类
get_skill_category() {
    local skill_name="$1"
    case "$skill_name" in
        "algorithmic-art"|"canvas-design"|"slack-gif-creator"|"theme-factory")
            echo "creative" ;;
        "frontend-design")
            echo "design" ;;
        "docx"|"pdf"|"pptx"|"xlsx")
            echo "document_processing" ;;
        "brand-guidelines"|"internal-comms")
            echo "enterprise" ;;
        "mcp-builder")
            echo "ai_integration" ;;
        "skill-creator"|"web-artifacts-builder")
            echo "development" ;;
        "doc-coauthoring")
            echo "productivity" ;;
        "webapp-testing")
            echo "testing" ;;
        *)
            echo "general" ;;
    esac
}

# 获取技能依赖
get_skill_dependencies() {
    local skill_name="$1"
    case "$skill_name" in
        "docx"|"pdf"|"pptx"|"xlsx"|"webapp-testing"|"slack-gif-creator"|"skill-creator")
            echo "python" ;;
        "mcp-builder"|"web-artifacts-builder")
            echo "node" ;;
        "canvas-design")
            echo "fonts" ;;
        *)
            echo "" ;;
    esac
}

# 转换所有技能
convert_all_skills() {
    echo -e "${CYAN}🚀 开始转换所有16个技能...${NC}"

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

    local converted=0
    local failed=0

    for skill in "${skills[@]}"; do
        if convert_skill "$skill"; then
            ((converted++))
        else
            ((failed++))
        fi
    done

    echo
    echo -e "${GREEN}📊 转换完成统计:${NC}"
    echo -e "  ✅ 成功转换: $converted 个技能"
    echo -e "  ❌ 转换失败: $failed 个技能"
    echo -e "  📁 输出目录: $BRIDGE_DIR"
}

# 主函数
main() {
    case "${1:-}" in
        "--help"|"-h")
            show_help
            ;;
        "--all")
            convert_all_skills
            ;;
        "")
            echo -e "${RED}❌ 错误: 请指定技能名称或使用 --all 参数${NC}"
            echo
            show_help
            exit 1
            ;;
        *)
            convert_skill "$1"
            ;;
    esac
}

# 执行主函数
main "$@"