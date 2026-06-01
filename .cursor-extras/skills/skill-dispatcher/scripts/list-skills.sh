#!/bin/bash
# Skill Dispatcher - 技能列表工具
# 用于发现和列出 .cursor/features/skills/ 目录中的所有技能

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FEATURES_SKILLS_DIR="$PROJECT_ROOT/features/skills"
REGISTRY_FILE="$FEATURES_SKILLS_DIR/registry.json"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印标题
print_header() {
    local title="$1"
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $title${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"
}

# 打印分类
print_category() {
    local category="$1"
    local icon="$2"
    echo -e "\n${BLUE}$icon $category${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────${NC}"
}

# 打印技能
print_skill() {
    local id="$1"
    local name="$2"
    local desc="$3"
    local auto_install="$4"
    local deps="$5"
    
    local status_icon=""
    if [ "$auto_install" = "true" ]; then
        status_icon="${GREEN}✓${NC} "
    else
        status_icon="${YELLOW}○${NC} "
    fi
    
    echo -e "  ${status_icon}${CYAN}$id${NC} - $name"
    echo -e "     ${desc}"
    if [ -n "$deps" ] && [ "$deps" != "[]" ]; then
        echo -e "     依赖: $deps"
    fi
    echo ""
}

# 解析 JSON 字段 (简单实现)
parse_json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | grep -o "\"$field\"\s*:\s*[^,}]*" | sed 's/.*: *//; s/"//g; s/\[//; s/\]//; s/, */, /g'
}

# 解析嵌套 JSON 字段
parse_nested_json() {
    local json="$1"
    local key1="$2"
    local key2="$3"
    echo "$json" | grep -o "\"$key1\"[^}]*" | head -1 | grep -o "\"$key2\"\s*:\s*[^,}]*" | sed 's/.*: *//; s/"//g'
}

# 检查依赖
check_dependencies() {
    local deps="$1"
    
    # 检测 JavaScript/Node.js
    if [ -f "$PROJECT_ROOT/../package.json" ] || [ -f "$PROJECT_ROOT/package.json" ]; then
        return 0
    fi
    
    # 检测 Python
    if [ -f "$PROJECT_ROOT/../requirements.txt" ] || [ -f "$PROJECT_ROOT/requirements.txt" ]; then
        return 0
    fi
    
    return 1
}

# 主函数
main() {
    print_header "🎯 Cursor Skills - 技能列表"
    
    # 检查注册表文件
    if [ ! -f "$REGISTRY_FILE" ]; then
        echo -e "${RED}❌ 错误: 注册表文件不存在${NC}"
        echo -e "${YELLOW}路径: $REGISTRY_FILE${NC}"
        exit 1
    fi
    
    # 读取注册表
    local registry_content
    registry_content=$(cat "$REGISTRY_FILE")
    
    echo -e "${CYAN}📍 技能目录:${NC} $FEATURES_SKILLS_DIR"
    echo -e "${CYAN}📄 注册表版本:${NC} $(parse_json_field "$registry_content" "version")"
    echo -e "${CYAN}📅 最后更新:${NC} $(parse_json_field "$registry_content" "last_updated")"
    
    # 按分类列出技能
    declare -A category_icons=(
        ["Development"]="🚀"
        ["Testing"]="🧪"
        ["Security"]="🔒"
        ["Analysis"]="📊"
        ["Optimization"]="⚡"
        ["Documentation"]="📚"
        ["Collaboration"]="🤝"
        ["Learning"]="🎓"
        ["AI Integration"]="🤖"
        ["Design"]="🎨"
        ["Creative"]="✨"
        ["Enterprise"]="🏢"
        ["Productivity"]="⚙️"
        ["Debugging"]="🐛"
    )
    
    declare -A category_translations=(
        ["Development"]="开发"
        ["Testing"]="测试"
        ["Security"]="安全"
        ["Analysis"]="分析"
        ["Optimization"]="优化"
        ["Documentation"]="文档"
        ["Collaboration"]="协作"
        ["Learning"]="学习"
        ["AI Integration"]="AI集成"
        ["Design"]="设计"
        ["Creative"]="创意"
        ["Enterprise"]="企业"
        ["Productivity"]="生产力"
        ["Debugging"]="调试"
    )
    
    # 提取所有技能 ID
    local skill_ids
    skill_ids=$(echo "$registry_content" | grep -o '"[a-z-]*":\s*{' | grep -B1 '"name"' | grep -o '"[^"]*:' | sed 's/"//g; s/://g' | sort -u)
    
    # 统计
    local total_skills=0
    local auto_install_skills=0
    
    # 按分类显示技能
    local previous_category=""
    
    while IFS= read -r skill_id; do
        if [ -z "$skill_id" ]; then
            continue
        fi
        
        # 提取技能信息
        local skill_block
        skill_block=$(echo "$registry_content" | grep -A20 "\"$skill_id\":\s*{" | head -21)
        
        local name
        local description
        local category
        local auto_install
        local dependencies
        
        name=$(echo "$skill_block" | grep '"name"' | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')
        description=$(echo "$skill_block" | grep '"description"' | head -1 | sed 's/.*"description": *"\([^"]*\)".*/\1/')
        category=$(echo "$skill_block" | grep '"category"' | head -1 | sed 's/.*"category": *"\([^"]*\)".*/\1/')
        auto_install=$(echo "$skill_block" | grep '"auto_install"' | head -1 | sed 's/.*"auto_install": *\([^,}]*\).*/\1/')
        dependencies=$(echo "$skill_block" | grep '"dependencies"' -A5 | head -6 | sed 's/.*"dependencies": *\[[^]]*\].*/\0/' | tr '\n' ' ')
        
        # 清理 dependencies
        dependencies=$(echo "$dependencies" | sed 's/.*\[\([^]]*\)\].*/\1/; s/"//g; s/, */, /g')
        
        # 如果是空依赖，显示为无
        if [ -z "$dependencies" ] || [ "$dependencies" = " " ]; then
            dependencies="无"
        fi
        
        # 统计
        ((total_skills++))
        if [ "$auto_install" = "true" ]; then
            ((auto_install_skills++))
        fi
        
        # 打印分类标题
        if [ "$category" != "$previous_category" ]; then
            local category_icon="${category_icons[$category]:-📦}"
            local category_name="${category_translations[$category]:-$category}"
            print_category "$category ($category_name)" "$category_icon"
            previous_category="$category"
        fi
        
        # 打印技能
        print_skill "$skill_id" "$name" "$description" "$auto_install" "$dependencies"
        
    done <<< "$skill_ids"
    
    # 打印统计
    print_header "📊 统计信息"
    echo -e "${CYAN}总技能数:${NC} $total_skills"
    echo -e "${GREEN}自动安装:${NC} $auto_install_skills"
    echo -e "${YELLOW}手动安装:${NC} $((total_skills - auto_install_skills))"
    
    # 打印说明
    echo -e "\n${BLUE}图例说明:${NC}"
    echo -e "  ${GREEN}✓${NC} = 自动安装 (auto_install: true)"
    echo -e "  ${YELLOW}○${NC} = 手动安装 (auto_install: false)"
    
    echo -e "\n${CYAN}💡 提示:${NC}"
    echo -e "  使用 ${YELLOW}@skill-dispatcher${NC} 来发现和调用这些技能"
    echo -e "  查看 ${YELLOW}reference.md${NC} 了解详细信息"
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}\n"
}

# 运行主函数
main "$@"
