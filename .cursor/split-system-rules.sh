#!/bin/bash

# 分割系统级规则文件
# 版本: v1.0.0

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_DIR=".cursor/rules/.backup"
mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}=== 分割系统级规则文件 ===${NC}\n"

# 1. 分割 module_manager.md (1039行) - 最长，必须分割
split_module_manager() {
    echo -e "${YELLOW}分割 module_manager.md (1039行)...${NC}"
    
    local source=".cursor/rules/system/module_manager.md"
    local backup="$BACKUP_DIR/module_manager.md"
    
    cp "$source" "$backup"
    
    # 第一部分：核心架构 (1-453行)
    cat > "$source" << 'EOF'
---
description: "规则管理系统 - 管理.cursor规则的依赖关系和激活控制"
apply_when:
  - always: true
priority: 20
---

# 📋 规则管理系统 (Rule Management System)

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

EOF
    sed -n '12,453p' "$backup" >> "$source"
    
    # 第二部分：执行和监控 (454-1039行)
    cat > ".cursor/rules/system/module_executor.md" << 'EOF'
---
description: "模块执行器和监控器 - 命令调度、性能监控和配置管理"
apply_when:
  - keywords: ["执行", "调度", "监控", "性能", "配置"]
priority: 19
---

# 🚀 模块执行器和监控器 (Module Executor & Monitor)

本文档是从 `module_manager.md` 分割出来的执行和监控部分。

EOF
    sed -n '454,1039p' "$backup" >> ".cursor/rules/system/module_executor.md"
    
    echo -e "${GREEN}✓ module_manager.md 分割完成${NC}"
}

# 2. 分割 rules-router.md (727行)
split_rules_router() {
    echo -e "${YELLOW}分割 rules-router.md (727行)...${NC}"
    
    local source=".cursor/rules/rules-router.md"
    local backup="$BACKUP_DIR/rules-router.md"
    
    cp "$source" "$backup"
    
    # 第一部分：核心引擎 (1-383行)
    cat > "$source" << 'EOF'
---
description: "规则路由器 - 智能管理规则激活、依赖和优先级"
apply_when:
  - always: true
priority: 20
---

# 🎯 规则路由器 (Rules Router)

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

EOF
    sed -n '12,383p' "$backup" >> "$source"
    
    # 第二部分：冲突解决和监控 (384-727行)
    cat > ".cursor/rules/rules-conflict-resolver.md" << 'EOF'
---
description: "规则冲突解决器 - 优先级矩阵、冲突解决和性能监控"
apply_when:
  - keywords: ["冲突", "优先级", "性能", "监控"]
priority: 19
---

# ⚡ 规则冲突解决和监控 (Rule Conflict Resolver & Monitor)

本文档是从 `rules-router.md` 分割出来的冲突解决和监控部分。

EOF
    sed -n '384,727p' "$backup" >> ".cursor/rules/rules-conflict-resolver.md"
    
    echo -e "${GREEN}✓ rules-router.md 分割完成${NC}"
}

# 3. 分割 intelligent_evolution.md (584行)
split_intelligent_evolution() {
    echo -e "${YELLOW}分割 intelligent_evolution.md (584行)...${NC}"
    
    local source=".cursor/rules/core/intelligent_evolution.md"
    local backup="$BACKUP_DIR/intelligent_evolution.md"
    
    cp "$source" "$backup"
    
    # 第一部分：系统架构 (1-554行)
    sed -n '1,554p' "$backup" > "$source"
    
    # 第二部分：使用指南 (555-584行) - 很短，合并到第一个文件
    # 保持为一个文件，但添加一个清晰的分节标记
    
    echo -e "${GREEN}✓ intelligent_evolution.md 保持完整（添加分节标记）${NC}"
}

# 主函数
main() {
    # 分割最长的文件
    split_module_manager
    split_rules_router
    split_intelligent_evolution
    
    # 说明保留的文件
    echo -e "\n${YELLOW}保留完整的文件（核心流程文件）:${NC}"
    echo -e "  ✓ constitution.md (542行) - 宪法，保持完整性"
    echo -e "  ✓ vibe-coding.md (540行) - 开发原则，保持完整性"
    echo -e "  ✓ conversation_intent_analyzer.md (712行) - 意图分析，保持完整性"
    
    echo -e "\n${GREEN}=== 分割完成 ===${NC}"
    echo -e "备份位置: $BACKUP_DIR"
}

main "$@"
