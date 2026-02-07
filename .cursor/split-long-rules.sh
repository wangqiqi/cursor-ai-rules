#!/bin/bash

# 分割超长的规则文件以降低认知负担
# 版本: v1.0.0
# 作者: Cursor AI Rules

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 规则目录
RULES_DIR=".cursor/rules/tech"
BACKUP_DIR=".cursor/rules/.backup"

echo -e "${BLUE}=== 分割超长规则文件 ===${NC}\n"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 分割react.md
split_react() {
    echo -e "${YELLOW}分割 react.md (1552行)...${NC}"
    
    local source="$RULES_DIR/react.md"
    local backup="$BACKUP_DIR/react.md"
    
    # 备份原文件
    cp "$source" "$backup"
    
    # 提取frontmatter和基础部分（1-673行）
    sed -n '1,673p' "$source" > "$RULES_DIR/react-basics.md"
    
    # 提取依赖管理和测试部分（674-1003行）+ frontmatter
    cat > "$RULES_DIR/react-dependencies.md" << 'EOF'
---
description: "React依赖管理和测试 - 包管理、依赖优化和测试策略"
apply_when:
  - file_pattern: "**/package.json"
  - file_pattern: "**/jest.config.js"
  - file_pattern: "**/*.test.jsx"
  - file_pattern: "**/*.test.tsx"
  - keywords: ["npm", "yarn", "测试", "test", "依赖"]
priority: 9
---

EOF
    sed -n '674,1003p' "$backup" >> "$RULES_DIR/react-dependencies.md"
    
    # 提取高级主题部分（1004-1552行）+ frontmatter
    cat > "$RULES_DIR/react-advanced.md" << 'EOF'
---
description: "React高级实践 - 性能优化、安全实践和最佳实践"
apply_when:
  - keywords: ["性能优化", "security", "best practices", "优化", "安全"]
priority: 9
---

# ⚛️ React 高级实践

本文档是从 `react.md` 分割出来的高级主题部分，涵盖性能优化、安全实践和最佳实践。

EOF
    sed -n '1004,1552p' "$backup" >> "$RULES_DIR/react-advanced.md"
    
    # 删除原文件
    rm "$source"
    
    echo -e "${GREEN}✓ react.md 分割完成${NC}"
    echo -e "  - react-basics.md (673行)"
    echo -e "  - react-dependencies.md (330行)"
    echo -e "  - react-advanced.md (549行)"
}

# 主函数
main() {
    if [[ ! -f "$RULES_DIR/react.md" ]]; then
        echo -e "${RED}✗ react.md 不存在${NC}"
        exit 1
    fi
    
    split_react
    
    echo -e "\n${GREEN}=== 分割完成 ===${NC}"
    echo -e "备份位置: $BACKUP_DIR"
    echo -e "\n${YELLOW}提示: 使用以下命令恢复原文件${NC}"
    echo -e "  mv $BACKUP_DIR/react.md $RULES_DIR/react.md"
    echo -e "  rm $RULES_DIR/react-*.md"
}

main "$@"
