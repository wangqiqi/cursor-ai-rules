# .cursor 系统架构文档

## 📊 系统概览

本系统是项目的 `.cursor` 配置，提供智能AI编程助手能力。可复制到任意项目使用（项目无关、用户无关、设备无关）。

### 项目信息
- **项目路径**: {{PROJECT_ROOT}} （运行时替换为当前项目根目录）
- **配置路径**: `.cursor/`（复制安装）或 `packages/cursor-ai-rules-plugin/`（Cursor 插件，由 sync 生成）
- **版本**: 2.0.0
- **最后更新**: 2026-06-01

### 双轨分发（Phase 6）

| 轨道 | 路径 | 用途 |
|------|------|------|
| 复制轨 | `.cursor/` + 根 `AGENTS.md` | 完整运行时；权威源 |
| 插件轨 | `packages/cursor-ai-rules-plugin/` | Cursor 本地/市场插件；`scripts/sync-plugin-package.sh` 同步 |

CI：`verify-plugin-package.sh` + `check-plugin-package-drift.sh`（防止 `packages/` 与 `.cursor/` 漂移）。

---

## 🏗️ 系统架构

### 核心组件

```
.cursor/
├── agents/              # AI代理系统
│   └── command-center.md          # 智能命令中枢
├── commands/            # 命令系统
│   ├── master.md                    # Master命令定义
│   ├── master-handler.js            # Master处理器
│   ├── master-router.js             # Master路由器
│   ├── vibe.md                      # VIBE开发模式
│   └── capability-maps/             # 能力映射
├── config/              # 配置系统
├── core/                # 核心脚本库 (75+ 脚本)
├── docs/                # 文档系统
├── features/            # 特性系统
│   ├── skills/          # 技能库 (45 个技能包)
│   ├── hooks/           # Git钩子系统
│   └── automation/      # 自动化脚本
├── plugins/             # 插件系统
├── rules/               # 规则系统 (75个规则)
└── skills/              # 项目技能
    └── skill-dispatcher/             # 技能调度器
```

---

## 🎯 组件职责详解

### 1. Agents (代理系统)

**位置**: `.cursor/agents/`

**职责**: 
- AI代理是智能意图处理器，理解用户需求并协调系统资源
- 提供专业领域知识和工作流程指导

**当前代理**:

#### command-center (智能命令中枢)
- **文件**: `command-center.md`
- **职责**: 统一调用和管理 `.cursor/commands` 系统
- **能力**:
  - 精通所有命令 (master, vibe, command-router)
  - 智能意图解析和路由
  - 21种AI人格角色系统
  - 宪法合规检查
  - VIBE专业开发流程

---

### 2. Commands (命令系统)

**位置**: `.cursor/commands/`

**职责**:
- 用户交互的入口点
- 定义命令的行为和处理器
- 提供能力映射和路由逻辑

**主要命令**:

#### `/master` (Master智能命令中心)
- **文件**: `master.md`, `master-handler.js`, `master-router.js`
- **定位**: 统一AI编程助手入口
- **功能**:
  - 全方位开发支持
  - 技术栈规划
  - 项目脚手架
  - 代码分析优化
  - 21种AI人格角色

#### `/vibe` (VIBE开发模式)
- **文件**: `vibe.md`
- **定位**: AI共生宪法系统下的专业开发模式
- **功能**:
  - 文档驱动 (Documentation)
  - 测试先行 (Testing)
  - 前后端对齐 (Interface)
  - 分层开发 (Backlog for Frontend)
  - 六维交互协议 (D1-D6)
  - 三大公理强制执行

---

### 3. Skills (技能系统)

#### 3.1 项目技能 (`.cursor/skills/`)

**定位**: 项目特定的技能定义，仅在当前项目中使用

**技能列表**:
- **skill-dispatcher**: 技能调度器
  - 发现、匹配和调用 `.cursor/features/skills/` 中的技能
  - 读取 `registry.json` 进行智能匹配
  - 支持技能组合和依赖检查

#### 3.2 技能库 (`.cursor/features/skills/`)

**定位**: 可跨项目共享的通用技能库

**技能分类** (45 个技能包):

**Development (开发)**:
- `api-design` - API设计
- `backend-development` - 后端开发
- `fullstack-development` - 全栈开发
- `web-artifacts-builder` - Web工件构建
- `debug-assistant` - 智能调试助手

**Testing (测试)**:
- `api-testing` - API测试
- `test-automation` - 测试自动化
- `webapp-testing` - Web应用测试
- `evaluation` - 技能评估框架

**Security (安全)**:
- `security-analysis` - 安全分析
- `vulnerability-scanning` - 漏洞扫描

**Analysis (分析)**:
- `code-analysis` - 代码分析
- `performance-analysis` - 性能分析
- `system-analysis` - 系统分析

**Optimization (优化)**:
- `optimization-tools` - 优化工具
- `refactoring-tools` - 重构工具
- `ssr-optimization` - SSR优化

**Documentation (文档)**:
- `documentation-tools` - 文档工具
- `docx` - Word文档处理
- `pdf` - PDF文档处理
- `pptx` - PowerPoint演示文稿
- `xlsx` - Excel电子表格

**Design (设计)**:
- `canvas-design` - 画布设计
- `frontend-design` - 前端界面设计
- `theme-factory` - 主题工厂
- `brand-guidelines` - 品牌指南

**Learning (学习)**:
- `learning-assistant` - 学习助手
- `code-examples` - 代码示例

**Collaboration (协作)**:
- `git-management` - Git管理
- `doc-coauthoring` - 文档协作
- `internal-comms` - 内部通讯

**AI Integration (AI集成)**:
- `mcp-builder` - MCP构建器
- `skill-creator` - 技能创建器

**Creative (创意)**:
- `algorithmic-art` - 算法艺术生成
- `slack-gif-creator` - Slack GIF创建器

**Reference (参考)**:
- `node_mcp_server` - Node.js MCP服务器
- `python_mcp_server` - Python MCP服务器
- `mcp-specification` - MCP规范文档
- `mcp_best_practices` - MCP最佳实践
- `python-sdk-README` - Python SDK说明
- `typescript-sdk-README` - TypeScript SDK说明

---

### 4. Core (核心脚本库)

**位置**: `.cursor/core/`

**职责**: 底层脚本工具和基础设施

**主要脚本分类**:

**初始化与环境**:
- `init.sh` - 初始化
- `env-perception.sh` - 环境感知
- `context-manager.sh` - 上下文管理

**质量管理**:
- `quality-manager.sh` - 质量管理
- `consistency-checker.sh` - 一致性检查
- `architecture-compliance-checker.sh` - 架构合规检查

**Git管理**:
- `git-manager.sh` - Git管理
- `refactor-manager.sh` - 重构管理

**Agent编排**:
- `agent-orchestration-engine.sh` - Agent编排引擎
- `agent-orchestration-smart-router.sh` - 智能路由
- `agent-orchestration-scheduler.sh` - 调度器

**性能优化**:
- `performance-optimizer.js` - 性能优化
- `optimizer.sh` - 优化器
- `adaptive-optimization-engine.sh` - 自适应优化引擎

**学习系统**:
- `continuous-learning-loop.sh` - 持续学习循环
- `learning-manager.sh` - 学习管理

---

### 5. Config (配置系统)

**位置**: `.cursor/config/`

**职责**: 系统配置文件和环境变量

---

### 6. Rules (规则系统)

**位置**: `.cursor/rules/`

**职责**: 项目规则和AI行为指导

**数量**: 75个规则文件

---

### 7. Hooks (钩子系统)

**位置**: `.cursor/features/hooks/`

**职责**: Git钩子和自动化触发

**主要钩子**:
- `pre-commit` - 提交前检查
- `post-commit` - 提交后操作
- `pre-push` - 推送前检查
- `commit-msg` - 提交信息验证

**功能**:
- 架构检查
- 代码质量检查
- 安全审计
- 性能监控
- 角色管理

---

### 8. Plugins (插件系统)

**位置**: `.cursor/plugins/`

**职责**: 可扩展的插件架构

---

## 🔗 系统间调用链

### 1. 用户请求流程

```
用户请求 (自然语言)
    ↓
命令入口 (/master, /vibe, 直接对话)
    ↓
command-center.md (Agent) 解析意图
    ↓
宪法合规检查
    ↓
智能路由决策
    ↓
┌─────────────────────────────────┐
│  选择执行路径:                   │
│  - 调用命令处理器                │
│  - 调用技能调度器                │
│  - 调用核心脚本                  │
│  - 组合调用                      │
└─────────────────────────────────┘
    ↓
执行具体任务
    ↓
返回结果给用户
```

### 2. Master命令调用链

```
/master [用户需求]
    ↓
master-handler.js (处理器)
    ↓
master-router.js (路由)
    ↓
command-center.md (Agent)
    ↓
分析意图 → 路由到合适的能力
    ↓
┌─────────────────────────────────┐
│  可能调用:                       │
│  - skill-dispatcher (技能调度)   │
│  - core/*.sh (核心脚本)          │
│  - /vibe (VIBE模式)              │
│  - role-system (角色系统)        │
└─────────────────────────────────┘
    ↓
整合结果
    ↓
返回用户
```

### 3. 技能调度调用链

```
需要专业技能
    ↓
skill-dispatcher (Skill)
    ↓
读取 .cursor/features/skills/skills/registry.json
    ↓
匹配技能 (关键词/语义/分类)
    ↓
检查依赖
    ↓
加载技能正文 (.cursor/skills/<skill-name>/references/full-guide.md)
    ↓
应用技能指导
    ↓
完成任务
```

### 4. Command-Center ↔ Skill-Dispatcher 协作

```
command-center (Agent)
    ↓
检测到需要专业技能
    ↓
调用 skill-dispatcher (Skill)
    ↓
skill-dispatcher 发现和匹配技能
    ↓
返回技能列表或应用技能
    ↓
command-center 整合结果
    ↓
返回给用户
```

---

## 🎭 角色系统

### 21种AI人格

**专业角色 (8种)**:
1. 专家导师
2. 架构师
3. 代码审查员
4. 测试工程师
5. 性能优化专家
6. 安全专家
7. DevOps工程师
8. 产品经理

**动漫风格角色 (13种)**:
9. 可爱萝莉
10. 御姐女王
11. 完美女仆
12. 魔法少女程序员
13. 赛博朋克黑客
14. 和风武士
15. 机娘助手
16. 哥特萝莉
17. 元气少女
18. 冷若冰山美人
19. 温柔大姐姐
20. 傲娇少女
21. 神秘预言家

### 昵称系统

支持为角色设置昵称，例如:
- 可爱萝莉 → 小妮、小妹
- 完美女仆 → 小可
- 魔法少女程序员 → 小魔

---

## ⚖️ 宪法系统

### 三大公理
1. **意图主权** - 用户的意图是最高指导原则
2. **信号可信** - 所有信号必须可信和可验证
3. **认知可审计** - 所有决策过程必须可审计

### 六维交互协议 (D1-D6)
- D1: 意图声明
- D2: 上下文确认
- D3: 执行计划
- D4: 进度更新
- D5: 结果验证
- D6: 反馈学习

---

## 🔍 技能目录说明

### 为什么有两个skills目录?

#### `.cursor/skills/` (项目技能)
- **作用域**: 当前项目
- **用途**: 项目特定的技能定义
- **示例**: `skill-dispatcher` - 本项目的技能调度器

#### `.cursor/features/skills/` (技能库)
- **作用域**: 跨项目共享
- **用途**: 通用的可重用技能
- **数量**: 45 个技能包
- **注册表**: `registry.json` (v2.0.0)

### 调用关系

```
.cursor/skills/skill-dispatcher/
    ↓
管理
    ↓
.cursor/skills/* (45 个官方技能包)
```

---

## 📋 术语表

| 术语 | 定义 |
|------|------|
| Agent (代理) | AI代理，处理用户意图并协调系统资源 |
| Command (命令) | 用户交互入口，如 `/master`, `/vibe` |
| Skill (技能) | 可重用的专业知识包 |
| Project Skill (项目技能) | `.cursor/skills/` 中的项目特定技能 |
| Library Skill (库技能) | `.cursor/features/skills/` 中的可重用技能 |
| Hook (钩子) | Git事件触发器 |
| Core Script (核心脚本) | 底层工具脚本 |
| 角色系统 | 21种AI人格和昵称系统 |
| 宪法系统 | 三大公理和六维协议 |
| VIBE模式 | 专业开发流程 |

---

## 🚀 快速开始

### 使用Master命令

```bash
# 学习类
/master 学习React高级特性

# 开发类
/master 创建一个Node.js后端API

# 分析类
/master 分析代码性能问题

# 角色类
/master 切换角色 loli
/master 呼叫 小妮
```

### 使用技能系统

```bash
# 查看可用技能
有什么可用的技能？

# 使用特定技能
使用 backend-development 技能设计用户认证系统

# 技能组合
/master 使用 api-design 和 security-analysis 技能设计支付API
```

### 使用VIBE模式

```bash
/vibe start    # 初始化VIBE模式
/vibe code     # 进入开发模式
/vibe prd      # 生成PRD文档
```

---

## 📊 系统统计

| 组件 | 数量 |
|------|------|
| Agents | 1 |
| Commands | 30+ |
| Core Scripts | 100+ |
| Agent Skills (`.cursor/skills/`) | 45 |
| Hooks | 30+ |
| Rules | 75 |
| Config Files | 22 |
| AI Roles | 21 |

---

## 🔧 维护指南

### 添加新技能

1. 在 `.cursor/features/skills/` 创建 `[skill-name].md`
2. 在 `registry.json` 中注册技能
3. 更新分类索引

### 添加新命令

1. 在 `.cursor/commands/` 创建命令文件
2. 定义元数据 (JSON/YAML frontmatter)
3. 创建处理器脚本 (可选)
4. 在 `command-center.md` 中注册

### 添加新Agent

1. 在 `.cursor/agents/` 创建 `[agent-name].md`
2. 定义Agent职责和能力
3. 在相关命令中引用

---

---

## 🔄 系统组件交互流程

### 完整请求处理链

```
用户输入 (自然语言 或 /master /vibe 命令)
    │
    ▼
┌──────────────────────────────────────────────────┐
│ 1. Agent 层 (agents/command-center.md)            │
│    - 意图解析                                    │
│    - 宪法合规检查 (constitution.md)               │
│    - 角色激活                                    │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────┐
│ 2. 路由决策                                     │
│                                                  │
│   需要规则指导?  ──→ rules-router.md              │
│                       ├── 激活 core/ 规则         │
│                       ├── 激活 system/ 规则       │
│                       ├── 激活 tech/ 规则         │
│                       └── 激活 workflow/ 规则     │
│                                                  │
│   需要专业技能?  ──→ skill-dispatcher              │
│                       ├── 读取 registry.json      │
│                       ├── 关键词/语义匹配         │
│                       ├── 依赖检查               │
│                       └── 加载技能 .md 文件       │
│                                                  │
│   需要执行脚本?  ──→ core/*.sh                    │
│                       ├── 环境感知                │
│                       ├── 质量检查                │
│                       └── 性能优化                │
│                                                  │
│   需要自动触发?  ──→ hooks-engine.sh              │
│                       ├── 读取 hooks.json         │
│                       ├── 匹配触发器 (事件)       │
│                       └── 异步/同步执行钩子       │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────┐
│ 3. 执行层                                       │
│    - 执行选定的规则/技能/脚本/钩子               │
│    - agent-orchestration-engine 协调多 Agent     │
│    - 日志记录 (logging.sh)                       │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────┐
│ 4. 结果整合与响应                                │
│    - 整合所有执行结果                            │
│    - 格式化为用户友好的响应                      │
│    - 记录到 .cursorGrowth/                        │
└──────────────────────────────────────────────────┘
```

### rules-router 与 skill-dispatcher 职责边界

| 维度 | rules-router | skill-dispatcher |
|------|-------------|------------------|
| **所在位置** | `.cursor/rules/rules-router.md` | `.cursor/skills/skill-dispatcher/SKILL.md` |
| **核心职责** | 规则激活与编排 | 技能发现与调用 |
| **管理对象** | `.cursor/rules/` 下的 75 个规则文件 | `.cursor/features/skills/` 下的 45 个技能包 |
| **触发方式** | 上下文感知自动匹配 | 用户明确请求或 Agent 按需调度 |
| **输出结果** | 激活的规则集（约束 AI 行为） | 技能指导内容（扩展 AI 能力） |
| **依赖关系** | 规则间通过 priority/conflicts_with 排序 | 技能间通过 dependencies 声明依赖 |
| **协同方式** | rule 约束 -> skill 执行: 规则定义"如何做"，技能提供"做什么" |

### hooks-engine 执行生命周期

```
会话开始 (onSessionStart)
    │
    ├── role-activation       ── 角色系统初始化
    ├── master-init           ── Master 命令初始化
    ├── env-perception        ── 环境感知
    ├── session-optimizer     ── 会话优化
    ├── growth-directory-check ── 生长目录检查
    └── session-state-guard   ── 状态守护
    │
    ▼
用户提交提示 (beforeSubmitPrompt)
    │
    ├── session-state-guard   ── 状态守护
    ├── role-sync             ── 角色同步
    ├── context-management    ── 上下文管理
    ├── prompt-security       ── 安全审查
    └── master-sync-trigger   ── 同步触发
    │
    ▼
AI 响应完成 (afterAgentResponse)
    │
    ├── growth-recorder       ── 生长记录
    ├── token-compression     ── Token 压缩
    ├── agent-orchestration   ── Agent 编排
    └── context-pool-manager  ── 上下文池管理
    │
    ▼
会话结束 (onSessionEnd)
    │
    ├── cursor-sync           ── 对话同步
    ├── session-learning      ── 学习总结
    └── continuous-learning   ── 持续学习循环
```

---

**文档版本**: 1.1.0  
**最后更新**: 2026-06-01  
**维护者**: cursor-ai-rules 项目
