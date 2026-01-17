# 🎯 组件选用指南

*版本: v1.0.0 | 最后更新: 2026-01-16 | 作者: wangqiqi*

## 📋 概述

Cursor AI Rules系统包含多种组件类型，选择合适的组件对于系统性能、可维护性和功能完整性至关重要。本指南帮助开发者理解不同组件的职责边界和选用标准。

## 🏗️ 组件类型总览

| 组件类型            | 位置               | 职责         | 文件格式            | 选用场景           |
| ------------------- | ------------------ | ------------ | ------------------- | ------------------ |
| **Rules**           | `rules/`           | 定义行为规范 | `.md` (Frontmatter) | 通用规范、质量标准 |
| **Skills**          | `features/skills/` | 提供具体能力 | `.md` (Frontmatter) | 专项功能、工具集成 |
| **Hooks**           | `features/hooks/`  | 自动化触发   | `.sh`               | 事件驱动自动化     |
| **Core Scripts**    | `core/`            | 核心业务逻辑 | `.sh`               | 系统核心功能       |
| **Capability Maps** | `commands/`        | 意图映射     | `.json`             | 用户意图处理       |

## 🎯 Rules vs Skills 选用标准

### 使用Rules的情况 ✅

**定义**: Rules是Cursor规则系统的基础组件，用于定义通用的行为规范和质量标准。

**选用条件**:
- 需要定义"应该做什么"的规范
- 功能具有通用性，适用于多种项目
- 需要与Cursor规则系统深度集成
- 功能相对稳定，不经常变更

**适用场景**:
```yaml
# ✅ 适合用Rules
---
command: eslint
description: "ESLint代码质量检查"
globs: ["*.js", "*.ts", "*.jsx", "*.tsx"]
alwaysApply: true
---

# 定义JavaScript代码质量规范
```

**文件位置**: `rules/workflow/eslint.md`

### 使用Skills的情况 ✅

**定义**: Skills是扩展功能组件，用于提供具体的工具能力和专项功能。

**选用条件**:
- 需要提供"能做什么"的具体能力
- 功能相对独立，可以作为独立工具使用
- 可能需要外部依赖或配置
- 功能较为复杂或专业化

**适用场景**:
```yaml
# ✅ 适合用Skills
---
command: skill:webapp-testing
description: "Web应用测试工具集成"
alwaysApply: false
---

# 提供Playwright测试能力
```

**文件位置**: `features/skills/webap-testing.md`

## 📊 选用决策流程

### 决策树
```
需要添加新功能？
├── 是
│   ├── 是通用规范或质量标准？
│   │   ├── 是 → 使用Rules (rules/)
│   │   └── 否
│   │       ├── 是具体工具能力？
│   │       │   ├── 是 → 使用Skills (features/skills/)
│   │       │   └── 否 → 继续判断
│   └── 否
│       ├── 是事件驱动自动化？
│       │   ├── 是 → 使用Hooks (features/hooks/)
│       │   └── 否
│       │       ├── 是核心业务逻辑？
│       │       │   ├── 是 → 核心脚本 (core/)
│       │       │   └── 否 → 继续判断
│       │       └── 其他情况
└── 否 → 不需要添加
```

## 🔧 具体选用指南

### 1. 代码质量相关

#### ✅ 使用Rules的情况
```yaml
# rules/workflow/eslint.md
---
command: eslint
description: "ESLint代码质量规范"
globs: ["*.js", "*.ts"]
alwaysApply: true
---

# 定义代码质量标准和规则
```

#### ✅ 使用Skills的情况
```yaml
# features/skills/code-formatter.md
---
command: skill:code-formatter
description: "代码格式化工具"
alwaysApply: false
---

# 提供具体的格式化功能
```

### 2. 测试相关

#### ✅ 使用Rules的情况
```yaml
# rules/workflow/testing-workflow.md
---
command: testing-workflow
description: "测试工作流规范"
alwaysApply: false
---

# 定义测试的最佳实践和流程
```

#### ✅ 使用Skills的情况
```yaml
# features/skills/webap-testing.md
---
command: skill:webapp-testing
description: "Web应用测试工具"
alwaysApply: false
---

# 提供具体的测试执行能力
```

### 3. 调试相关

#### ✅ 使用Rules的情况
```yaml
# rules/workflow/debug-workflow.md
---
command: debug-workflow
description: "调试工作流规范"
alwaysApply: false
---

# 定义调试的最佳实践
```

#### ✅ 使用Skills的情况
```yaml
# features/skills/debug-assistant.md
---
command: skill:debug-assistant
description: "智能调试助手"
alwaysApply: false
---

# 提供具体的调试工具和功能
```

### 4. 部署相关

#### ✅ 使用Rules的情况
```yaml
# rules/workflow/deployment-workflow.md
---
command: deployment-workflow
description: "部署工作流规范"
alwaysApply: false
---

# 定义部署的最佳实践
```

#### ✅ 使用Skills的情况
```yaml
# features/skills/docker-deploy.md
---
command: skill:docker-deploy
description: "Docker部署工具"
alwaysApply: false
---

# 提供具体的部署执行能力
```

## 🪝 Hooks选用指南

### Hook类型选择

| 事件类型              | 适用场景             | 示例                |
| --------------------- | -------------------- | ------------------- |
| `onSessionStart`      | 会话初始化、环境准备 | 环境感知、缓存预热  |
| `afterFileSave`       | 文件变更后处理       | 代码检查、格式化    |
| `afterShellExecution` | 命令执行后处理       | 性能监控、日志记录  |
| `afterAgentResponse`  | AI响应后处理         | 学习记录、Token优化 |
| `beforeSubmitPrompt`  | 提示提交前处理       | 安全检查、内容过滤  |

### Hook设计原则
- **单一职责**: 每个Hook只处理一个具体的任务
- **异步友好**: 耗时操作使用异步执行
- **错误容忍**: Hook失败不影响主要功能
- **配置灵活**: 支持启用/禁用配置

## ⚙️ 配置选用指南

### 全局配置 vs 项目配置

#### 全局配置 (config/global.json)
- 适用于所有项目
- 系统级默认设置
- 不包含敏感信息

#### 项目配置 (project.json)
- 特定于当前项目
- 可覆盖全局配置
- 可包含项目特定信息

#### 用户覆盖 (overrides.json)
- 用户个人偏好设置
- 最高优先级
- 不会提交到版本控制

## 📁 文件位置指南

### Rules文件位置
```
rules/
├── core/           # 核心原则 (constitution, philosophy)
├── evolution/      # 演进相关 (evolution-*)
├── system/         # 系统级 (i18n, platform_adapter)
├── team/           # 团队协作 (collaboration)
├── tech/           # 技术栈 (javascript, python)
└── workflow/       # 工作流 (eslint, generator, testing)
```

### Skills文件位置
```
features/skills/
├── 按功能分类命名
├── 直接放在根目录
└── 不使用子目录 (除reference/)
```

### Hooks文件位置
```
features/hooks/
├── 按事件和动作命名
├── {event}-{action}.sh格式
└── 例如: file-save-quality-check.sh
```

## 🔄 组件迁移指南

### 从Skill迁移到Rule
**适用情况**: 功能从专项工具转变为通用规范

```bash
# 步骤:
1. 创建新的Rule文件
2. 复制Skill的核心逻辑到Rule
3. 更新capability mappings
4. 验证功能正常
5. 逐步废弃旧Skill
```

### 从Rule迁移到Skill
**适用情况**: 规范过于具体，需要更灵活的实现

```bash
# 步骤:
1. 创建新的Skill文件
2. 提取Rule的具体实现逻辑
3. 更新配置和依赖
4. 测试Skill功能
5. 调整Rule为更通用的规范
```

## ✅ 质量检查清单

### 新增Rules检查
- [ ] 是否定义了清晰的行为规范？
- [ ] 是否适用于多种项目类型？
- [ ] 是否与现有Rules不冲突？
- [ ] 是否包含适当的配置选项？

### 新增Skills检查
- [ ] 是否提供了具体的工具能力？
- [ ] 是否有明确的适用场景？
- [ ] 是否处理了错误情况？
- [ ] 是否提供了配置选项？

### 新增Hooks检查
- [ ] 是否绑定到合适的生命周期事件？
- [ ] 是否有错误处理和日志记录？
- [ ] 是否支持异步执行？
- [ ] 是否可以安全禁用？

## 📈 性能考虑

### Rules性能优化
- **条件匹配**: 使用高效的文件匹配模式
- **缓存策略**: 合理使用规则缓存
- **优先级设置**: 避免过度优先级设置

### Skills性能优化
- **懒加载**: 按需加载大型依赖
- **资源管理**: 合理管理外部进程
- **超时控制**: 设置合理的执行超时

### Hooks性能优化
- **异步执行**: 耗时操作使用后台执行
- **条件检查**: 快速的执行条件判断
- **资源限制**: 避免过度消耗系统资源

## 🔧 维护指南

### 定期审查
- **每季度**: 审查组件职责是否清晰
- **每半年**: 检查配置规范遵守情况
- **每年**: 评估组件选用标准的有效性

### 文档更新
- 新增组件时必须更新选用指南
- 组件职责变更时更新相关文档
- 定期审查和更新示例

---

*🎯 组件选用指南 - 确保Cursor AI Rules系统的组件职责清晰和选用正确*