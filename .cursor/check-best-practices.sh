#!/bin/bash

# 检查规则是否符合Cursor最佳实践
# 版本: v1.0.0
# 作者: Cursor AI Rules

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 统计变量
TOTAL_RULES=0
WITH_APPLY_WHEN=0
WITH_PRIORITY=0
WITH_EXAMPLES=0
TOO_LONG=0
COMMAND_STYLE=0

# 规则目录
RULES_DIR=".cursor/rules"

echo -e "${BLUE}=== Cursor Rules Best Practices Checker ===${NC}\n"

# 检查apply_when和priority
check_frontmatter() {
    local file=$1
    local has_apply_when=false
    local has_priority=false
    local has_examples=false
    local line_count=0
    
    # 读取frontmatter
    while IFS= read -r line; do
        line_count=$((line_count + 1))
        
        # 检查frontmatter结束
        if [[ "$line" == "---" ]] && [[ $line_count -gt 1 ]]; then
            break
        fi
        
        # 检查apply_when
        if [[ "$line" =~ apply_when: ]]; then
            has_apply_when=true
        fi
        
        # 检查priority
        if [[ "$line" =~ priority: ]]; then
            has_priority=true
        fi
    done < "$file"
    
    # 检查文件长度（超过500行）
    local total_lines=$(wc -l < "$file")
    if [[ $total_lines -gt 500 ]]; then
        echo -e "${YELLOW}⚠️  文件过长${NC}: $file (${total_lines}行)"
        TOO_LONG=$((TOO_LONG + 1))
    fi
    
    # 检查是否包含代码示例
    if grep -q '```' "$file"; then
        has_examples=true
    fi
    
    # 检查是否使用命令式语言（简单的启发式检查）
    if grep -qiE 'MUST|NEVER|ALWAYS|DO NOT|REQUIRED|禁止|必须' "$file"; then
        COMMAND_STYLE=$((COMMAND_STYLE + 1))
    fi
    
    # 更新统计
    TOTAL_RULES=$((TOTAL_RULES + 1))
    if [[ "$has_apply_when" == true ]]; then
        WITH_APPLY_WHEN=$((WITH_APPLY_WHEN + 1))
    else
        echo -e "${RED}✗ 缺少apply_when${NC}: $file"
    fi
    
    if [[ "$has_priority" == true ]]; then
        WITH_PRIORITY=$((WITH_PRIORITY + 1))
    else
        echo -e "${RED}✗ 缺少priority${NC}: $file"
    fi
    
    if [[ "$has_examples" == true ]]; then
        WITH_EXAMPLES=$((WITH_EXAMPLES + 1))
    fi
}

# 遍历所有规则文件
echo -e "${BLUE}检查规则文件...${NC}\n"
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        check_frontmatter "$file"
    fi
done < <(find "$RULES_DIR" -type f -name "*.md" -print0)

# 输出统计结果
echo -e "\n${BLUE}=== 统计结果 ===${NC}"
echo -e "总规则数: ${TOTAL_RULES}"
percent_apply_when=$((WITH_APPLY_WHEN * 100 / TOTAL_RULES))
percent_priority=$((WITH_PRIORITY * 100 / TOTAL_RULES))
percent_examples=$((WITH_EXAMPLES * 100 / TOTAL_RULES))
percent_command=$((COMMAND_STYLE * 100 / TOTAL_RULES))
echo -e "${GREEN}包含apply_when: ${WITH_APPLY_WHEN} (${percent_apply_when}%)${NC}"
echo -e "${GREEN}包含priority: ${WITH_PRIORITY} (${percent_priority}%)${NC}"
echo -e "${GREEN}包含代码示例: ${WITH_EXAMPLES} (${percent_examples}%)${NC}"
echo -e "${GREEN}使用命令式语言: ${COMMAND_STYLE} (${percent_command}%)${NC}"
echo -e "${YELLOW}文件过长(>500行): ${TOO_LONG}${NC}"

# 计算合规性分数
COMPLIANCE_SCORE=$(( (WITH_APPLY_WHEN + WITH_PRIORITY) * 100 / (TOTAL_RULES * 2) ))
echo -e "\n${BLUE}总体合规性: ${COMPLIANCE_SCORE}%${NC}"

if [[ $COMPLIANCE_SCORE -eq 100 ]]; then
    echo -e "${GREEN}✅ 所有规则都符合最佳实践！${NC}"
    exit 0
elif [[ $COMPLIANCE_SCORE -ge 80 ]]; then
    echo -e "${YELLOW}⚠️  大部分规则符合最佳实践，但仍有改进空间${NC}"
    exit 0
else
    echo -e "${RED}❌ 许多规则不符合最佳实践，需要改进${NC}"
    exit 1
fi
