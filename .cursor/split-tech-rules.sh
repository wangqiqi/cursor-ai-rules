#!/bin/bash

# 通用的技术规则文件分割脚本
# 将超长的技术规则文件分割为 basics 和 advanced 两部分
# 版本: v1.0.0

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RULES_DIR=".cursor/rules/tech"
BACKUP_DIR=".cursor/rules/.backup"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 分割单个文件
split_tech_file() {
    local tech_name=$1
    local source="$RULES_DIR/${tech_name}.md"
    local backup="$BACKUP_DIR/${tech_name}.md"
    
    if [[ ! -f "$source" ]]; then
        echo "⚠️  ${tech_name}.md 不存在，跳过"
        return
    fi
    
    echo -e "${YELLOW}分割 ${tech_name}.md...${NC}"
    
    # 备份原文件
    cp "$source" "$backup"
    
    # 获取总行数和依赖管理章节行号
    local total_lines=$(wc -l < "$source")
    local dep_line=$(grep -n "^## 🛠️ 依赖管理" "$source" | cut -d: -f1)
    
    if [[ -z "$dep_line" ]]; then
        echo "  ⚠️  未找到'依赖管理'章节，使用默认分割点: 600行"
        dep_line=600
    fi
    
    # 提取基础部分（1到依赖管理章节结束，约600-700行）
    local basics_end=$((dep_line + 70))
    sed -n "1,${basics_end}p" "$backup" > "$RULES_DIR/${tech_name}-basics.md"
    
    # 提取高级部分（从测试策略开始到文件结束）
    local advanced_start=$((dep_line + 71))
    sed -n "${advanced_start},\$p" "$backup" > "$RULES_DIR/${tech_name}-advanced.md"
    
    # 为advanced文件添加frontmatter
    local temp_file="$RULES_DIR/${tech_name}-advanced-temp.md"
    cat > "$temp_file" << EOF
---
description: "${tech_name^}高级实践 - 测试、性能优化、安全实践和最佳实践"
apply_when:
  - keywords: ["${tech_name}", "测试", "性能", "安全", "优化"]
priority: 9
---

# ${tech_name^} 高级实践

本文档是从 \`${tech_name}.md\` 分割出来的高级主题部分，涵盖测试策略、性能优化、安全实践和最佳实践。

EOF
    cat "$RULES_DIR/${tech_name}-advanced.md" >> "$temp_file"
    mv "$temp_file" "$RULES_DIR/${tech_name}-advanced.md"
    
    # 删除原文件
    rm "$source"
    
    local basics_lines=$(wc -l < "$RULES_DIR/${tech_name}-basics.md")
    local advanced_lines=$(wc -l < "$RULES_DIR/${tech_name}-advanced.md")
    
    echo -e "${GREEN}✓ ${tech_name}.md 分割完成${NC}"
    echo -e "  - ${tech_name}-basics.md (${basics_lines}行)"
    echo -e "  - ${tech_name}-advanced.md (${advanced_lines}行)"
}

# 主函数
main() {
    echo -e "${BLUE}=== 批量分割技术规则文件 ===${NC}\n"
    
    # 按优先级分割
    split_tech_file "typescript"  # 1368行
    split_tech_file "rust"        # 1259行
    split_tech_file "go"          # 1151行
    split_tech_file "c"           # 1096行
    split_tech_file "vue"         # 1079行
    split_tech_file "cpp"         # 844行
    
    echo -e "\n${GREEN}=== 分割完成 ===${NC}"
    echo -e "备份位置: $BACKUP_DIR"
    echo -e "\n${YELLOW}提示: 如需恢复，运行：${NC}"
    echo -e "  cd $RULES_DIR"
    echo -e "  for f in \$BACKUP_DIR/*.md; do mv \"\$f\" .; done"
    echo -e "  rm *-basics.md *-advanced.md"
}

main "$@"
