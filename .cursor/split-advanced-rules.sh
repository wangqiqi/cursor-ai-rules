#!/bin/bash

# 第二轮分割 - 处理仍然过长的文件
# 版本: v2.0.0

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== 第二轮分割优化 ===${NC}\n"

# 1. 分割 go-advanced.md (841行)
split_go_advanced() {
    echo -e "${YELLOW}分割 go-advanced.md...${NC}"
    local source=".cursor/rules/tech/go-advanced.md"
    
    # 第一部分：测试 (1-280行)
    sed -n '1,280p' "$source" > "${source}.tmp"
    
    # 第二部分：性能优化 (281-530行)
    cat > ".cursor/rules/tech/go-performance.md" << 'EOF'
---
description: "Go性能优化 - 并发、内存和CPU优化技巧"
apply_when:
  - keywords: ["go", "性能", "优化", "performance", "并发"]
priority: 9
---

# 🚀 Go 性能优化

EOF
    sed -n '281,530p' "$source" >> ".cursor/rules/tech/go-performance.md"
    
    # 第三部分：安全和最佳实践 (531-841行)
    cat > ".cursor/rules/tech/go-security.md" << 'EOF'
---
description: "Go安全实践和最佳实践 - 安全编码和生产环境指南"
apply_when:
  - keywords: ["go", "安全", "最佳实践", "security"]
priority: 9
---

# 🔒 Go 安全实践和最佳实践

EOF
    sed -n '531,841p' "$source" >> ".cursor/rules/tech/go-security.md"
    
    # 更新原文件为测试部分
    sed -n '1,280p' "$source" > "${source}.test"
    mv "${source}.test" "$source"
    
    rm -f "${source}.tmp"
    echo -e "${GREEN}✓ go-advanced.md 分割完成${NC}"
}

# 2. 分割 rust-advanced.md (763行)
split_rust_advanced() {
    echo -e "${YELLOW}分割 rust-advanced.md...${NC}"
    local source=".cursor/rules/tech/rust-advanced.md"
    
    # 性能和最佳实践 (400-763行)
    cat > ".cursor/rules/tech/rust-performance.md" << 'EOF'
---
description: "Rust性能优化和最佳实践 - 零成本抽象和unsafe指南"
apply_when:
  - keywords: ["rust", "性能", "优化", "unsafe", "最佳实践"]
priority: 9
---

# ⚡ Rust 性能优化和最佳实践

EOF
    sed -n '400,763p' "$source" >> ".cursor/rules/tech/rust-performance.md"
    
    # 保留测试部分在原文件
    sed -n '1,399p' "$source" > "${source}.tmp"
    mv "${source}.tmp" "$source"
    
    echo -e "${GREEN}✓ rust-advanced.md 分割完成${NC}"
}

# 3. 分割 typescript-basics.md (715行)
split_ts_basics() {
    echo -e "${YELLOW}分割 typescript-basics.md...${NC}"
    local source=".cursor/rules/tech/typescript-basics.md"
    
    # 分割点：类型系统 (400行)
    sed -n '1,400p' "$source" > "${source}.tmp"
    cat > ".cursor/rules/tech/typescript-types.md" << 'EOF'
---
description: "TypeScript高级类型系统 - 泛型、条件类型和类型推导"
apply_when:
  - keywords: ["typescript", "泛型", "类型", "泛型", "条件类型"]
priority: 9
---

# 🔷 TypeScript 高级类型系统

EOF
    sed -n '401,715p' "$source" >> ".cursor/rules/tech/typescript-types.md"
    mv "${source}.tmp" "$source"
    
    echo -e "${GREEN}✓ typescript-basics.md 分割完成${NC}"
}

# 4. 分割 module_executor.md (597行)
split_module_executor() {
    echo -e "${YELLOW}分割 module_executor.md...${NC}"
    local source=".cursor/rules/system/module_executor.md"
    
    # 分割为执行器和监控器
    sed -n '1,300p' "$source" > "${source}.tmp"
    cat > ".cursor/rules/system/module-monitor.md" << 'EOF'
---
description: "模块监控和配置管理 - 性能监控、配置管理和工具系统"
apply_when:
  - keywords: ["监控", "配置", "性能", "工具"]
priority: 19
---

# 📊 模块监控和配置管理

EOF
    sed -n '301,597p' "$source" >> ".cursor/rules/system/module-monitor.md"
    mv "${source}.tmp" "$source"
    
    echo -e "${GREEN}✓ module_executor.md 分割完成${NC}"
}

# 执行分割
split_go_advanced
split_rust_advanced
split_ts_basics
split_module_executor

echo -e "\n${GREEN}=== 第二轮分割完成 ===${NC}"
