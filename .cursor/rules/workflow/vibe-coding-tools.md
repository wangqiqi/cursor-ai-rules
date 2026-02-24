---
description: "VIBE Coding 工具与质量门禁 - 对齐检查、阶段管理、质量保障 (vibe-align, vibe-phase, 对齐检查, 质量门禁)"
globs: ["**/*"]
alwaysApply: false
priority: 11
---

# 🛠️ VIBE Coding 工具与质量门禁

> 由 @vibe-coding 引用

## 实施工具

### 对齐检查
```bash
./cursor-master.sh vibe-align frontend-backend
./cursor-master.sh vibe-align docs-code
./cursor-master.sh vibe-align tests-features
```

### 阶段管理
```bash
./cursor-master.sh vibe-phase frontend-dev
./cursor-master.sh vibe-phase backend-dev
./cursor-master.sh vibe-phase testing
./cursor-master.sh vibe-phase alignment
```

### 技能集成
- `@master skill:webapp-testing e2e` - Playwright E2E
- `@master generator vibe-coding --template bs-architecture` - 项目结构

## 质量门禁

| 阶段 | 门禁条件 |
|------|----------|
| 前端完成 | UI完成、交互实现、API集成、覆盖率≥80% |
| 后端完成 | API实现、DB设计、业务逻辑、集成测试通过 |
| 测试完成 | E2E完成、通过率≥95%、回归通过 |
| 对齐验证 | 文档代码对齐≥95%、接口一致、验收通过 |
