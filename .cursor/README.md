# 🚀 Cursor AI Rules - 宪法驱动的超级 AI 编程伙伴

[![Cursor](https://img.shields.io/badge/Cursor-AI-blue?style=for-the-badge&logo=cursor&logoColor=white)](https://cursor.com)
[![Version](https://img.shields.io/badge/version-2.0.0-green?style=for-the-badge)](https://github.com/wangqiqi/cursor-ai-rules/releases)
[![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)](LICENSE)

[![Constitution](https://img.shields.io/badge/constitution-三大公理-red?style=flat-square)]()
[![Agnostic](https://img.shields.io/badge/agnostic-三大无关-blue?style=flat-square)]()
[![Rules](https://img.shields.io/badge/rules-77-blue?style=flat-square)]()
[![Scripts](https://img.shields.io/badge/scripts-75+-cyan?style=flat-square)]()
[![Roles](https://img.shields.io/badge/roles-21-red?style=flat-square)]()
[![Skills](https://img.shields.io/badge/skills-46-purple?style=flat-square)]()
[![Team Experience](https://img.shields.io/badge/team--experience-Growth-orange?style=flat-square)]()

🌍 **[English](README.en.md) | [中文](README.md)**

**🌟 宪法驱动的超级 AI 编程伙伴 — 三大公理 + 三大无关原则 + 双目录架构 + VIBE 开发方法论**

将 `.cursor/`、`AGENTS.md`、**`.cursorignore`** 复制到任意项目即可零配置使用，或将本仓库安装为 Cursor 插件。安装清单见根目录 **[INSTALL.md](../INSTALL.md)**。

---

## 📌 本仓库是什么（不是什么）

本仓库是通过 Git 分享的 **开源 Cursor 项目配置模板**（规则、技能、命令、工作流脚本）。它 **不是** 托管服务，也 **不会** 在访客或克隆者的环境中自动启动 Agent。

| 主题 | 说明 |
|------|------|
| **是什么** | 静态 `.cursor/` 配置与文档，供开发者 **自愿** 复制或引用到自己的项目 |
| **不是什么** | 非 Cursor 官方产品；非远程多 Agent 集群；非「代跑代码」服务平台 |
| **并行能力** | `max_parallel_executions` 与编排脚本仅描述 **可选的本地** 工作流；是否执行完全由用户在自己的 Cursor 会话中决定 |
| **参考文档** | 如 `.cursor/skills/python-sdk/references/full-guide.md` 等为上游文档（如 [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)）的 **本地副本**，供 `mcp-builder` 等技能引用，非运行时组件 |

若收到第三方邮件（安全扫描、生态合作等）询问「并行 Agent」或 `.cursor` 路径，多为对 **公开配置** 的误读；上表为官方澄清。

---

## 🏆 核心能力概览

### ⚖️ 宪法驱动的 AI 体系
- **三大公理**：意图主权、信号可信、认知可审计
- **六维协议**：完整的 D1–D6 交互协议
- **合规机制**：自动 STOP 机制，约束 AI 行为边界

### 🎯 能力全覆盖
- ✅ **规则体系**：77 条技术规则（`.mdc`，含 1 条 Growth 桥接）
- ✅ **核心脚本**：`.cursor/core/` 下 75+ Shell 脚本
- ✅ **自动化钩子**：通过 `.cursor/hooks.json` 接入 Git/系统钩子
- ✅ **技能体系**：46 个官方 Agent Skills 包
- ✅ **团队经验沉淀**：`team-experience` — 从 CHANGELOG / Git / 踩坑对话归纳规则，写入 `.cursorGrowth`，**不污染** `.cursor` 主规则树

### 🎭 21 种 AI 人格角色
- **专业风格**（8 种）：专家导师、架构师、代码审查等
- **动漫风格**（13 种）：可爱萝莉、御姐女王、完美女仆等
- **昵称系统**：支持「小妮」「小可」等亲昵称呼

### 🚀 VIBE 开发方法论
- **Documentation**（文档驱动）
- **Testing**（测试优先）
- **Interface**（前后端对齐）
- **Backlog for Frontend**（分层开发）

---

## 🏛️ 三大公理 — 宪法驱动 AI

### 1. 意图主权公理
人类永远保留对「为什么做」和「什么是对的」的最终解释权与决策权

- ✅ **项目创建意图检测**：自动识别并强制先讨论需求
- ✅ **讨论优先**：禁止跳过讨论直接创建项目
- ✅ **人类确认**：重要操作需明确批准

### 2. 信号可信公理
AI 的一切输出必须附带可追溯、可验证、可归因的原始信号链

- ✅ **完整追溯链**：输出包含推理过程与数据来源
- ✅ **规则透明**：展示已激活规则的匹配状态
- ✅ **信号时效**：验证关键信号的新鲜度

### 3. 认知可审计公理
所有 AI 协作过程支持「三秒回溯」—— 约 3 秒内理解当时 AI 所知、所求、所禁、所依、所出

- ✅ **审计日志**：结构化记录写入 `.cursorGrowth/`
- ✅ **决策路径可视化**：从输入到输出的完整路径
- ✅ **历史可追溯**：支持任意历史会话回放理解

| 公理 | 含义 |
|------|------|
| **意图主权** | 人类保留「为何做」与「何为正确」的最终决策权 |
| **信号可信** | 每条 AI 输出须能追溯到可验证的原始信号 |
| **认知可审计** | 协作任一刻可在数秒内回溯上下文与规则 |

---

## 🤝 核心协作原则

基于三大公理，构建 **人机共生** 协作模式：

### 人类意图主权
- ✅ **宪法强制**：100% 遵循三大公理
- ✅ **讨论优先**：创建类需求须先澄清方案
- ✅ **人类终审**：重要操作由人签字确认

### 信号透明
- ✅ **完整追溯链**：推理过程与数据来源可查证
- ✅ **规则透明**：展示规则激活矩阵与优先级
- ✅ **信号可验证**：所有关键结论可归因

---

## 🚀 核心功能

### 🧠 智能 Master 命令中枢
- **统一入口**：`/master` 编排 75+ 脚本 + 76 条规则 + 45 个技能
- **意图理解**：自然语言解析复杂需求
- **自学习**：A/B 测试、反馈闭环、持续优化
- **性能监控**：本地响应与资源监控（目标 &lt;500ms 级感知）

### 🎯 智能能力编排
- **75+ 脚本**：环境感知、质量检查、性能监控、部署辅助
- **76 条规则**：宪法合规、代码质量、开发规范
- **Hooks**：Git 钩子、质量门禁、事件记录

### 🛠️ 增强能力
- **错误处理优化**：智能诊断与分级恢复
- **智能缓存**：多级缓存加速重复操作
- **学习数据隔离**：`.cursorGrowth/` 隐私隔离设计

### ⚡ Token 优化（约 25–35% 节省）
- **多层压缩**：四级压缩策略可选
- **流式输出**：分块输出避免超大响应
- **上下文缓存**：减少重复传输
- **实时监控**：Token 消耗预警

### 🧠 自学习与适配
- **模式学习**：识别用户行为模式
- **性能优化**：A/B 测试与自动调优
- **持续改进**：采集反馈并更新策略
- **个性化**：学习偏好与习惯

### 💬 VIBE 对话式开发
```bash
/vibe start    # 一键初始化项目与开发环境
/vibe prd      # 自动生成产品需求文档
/vibe code     # 智能生成与审查代码
/vibe test     # 自动化测试生成与执行
/vibe deploy   # 一键部署与环境配置
```

---

## 🏗️ 系统架构

### 双目录设计

#### `.cursor/` 📁 项目无关配置
- 规则定义、核心脚本、文档
- 可安全复制到任意项目
- 支持版本管理与团队共享

#### `.cursorGrowth/` 🌱 项目私有数据
- AI 学习记录、缓存、性能监控
- **`team-experience/`**：团队可复用 `.mdc` 规则（多项目、多成员统一路径）
- 各项目独立生长；`team-experience/` 可在 `.gitignore` / `.cursorignore` 中 **白名单** 后选择性提交或纳入索引

### 三大无关设计原则

#### 📦 项目无关
- ✅ **即插即用**：复制 `.cursor/` 即可获得完整 AI 能力
- ✅ **自动适配**：识别项目类型、技术栈、环境
- ✅ **多项目复用**：同一套配置可用于多个仓库

#### 🖥️ 系统无关
- ✅ **跨平台**：Linux / macOS / Windows（含 WSL）
- ✅ **自动检测**：识别 OS 与环境变量
- ✅ **统一接口**：屏蔽底层差异

#### 👤 用户无关
- ✅ **核心能力不绑定用户**：AI 内核与用户身份解耦
- ✅ **数据隔离**：用户数据落在 `.cursorGrowth/`
- ✅ **隐私保护**：偏好与学习数据本地化

### 架构优势
- **🔄 可复制**：`.cursor` 可在项目间迁移
- **🔒 隐私**：`.cursorGrowth` 不随配置共享
- **👥 协作友好**：团队共享配置，个人数据独立
- **⚡ 性能**：本地缓存与学习数据加速响应

### 📦 自包含与迁移
- **完全自包含**：规则、脚本、技能、文档、Agent 说明均在 `.cursor/` 内
- **一键迁移**：复制整个 `.cursor/` 即可
- **根目录快捷方式**：根目录 `AGENTS.md`、`README.md` 等为软链，便于 GitHub 展示

### 本仓库目录（单仓库双轨）

```
cursor-ai-rules/
├── AGENTS.md
├── .cursor-plugin/plugin.json    ← 插件清单（指向 .cursor/）
├── .cursor/                      ← 唯一权威源
├── scripts/verify-plugin-manifest.sh
└── docs/MARKETPLACE_SUBMIT.md
```

维护者可选：`bash scripts/install-githooks.sh`（修改 `.cursor/` 时校验插件清单）

---

## 🎭 21 种 AI 人格角色

所有角色 **能力等价** —— 差异仅在 **对话风格**，而非专业上限。

### 专业风格（8 种）
| 角色 | 风格 | 适用场景 |
|------|------|----------|
| 专业助手 | 正式、精准、高效 | 工作文档、正式交付 |
| 谦逊助手 | 礼貌、尊重、细致 | 客户沟通、正式场合 |
| 友好伙伴 | 轻松、温暖、协作 | 日常开发、团队协作 |
| 专家导师 | 权威、博学、引导 | 学习、技能提升 |
| 创意艺术家 | 灵感、创新、审美 | 设计、创意编码 |
| 严格教师 | 严谨、要求高 | 代码审查、质量把控 |
| 搞笑演员 | 幽默、轻松 | 减压、间歇放松 |
| 极简禅者 | 简洁、专注 | 深度工作、专注模式 |

### 动漫风格（13 种）
| 角色 | 风格 | 特点 |
|------|------|------|
| 可爱萝莉 | 活泼、天真 | 可爱表达、轻快互动 |
| 御姐女王 | 高贵、掌控 | 权威指引、气场强 |
| 完美女仆 | 优雅、忠诚 | 极致服务体验 |
| 赛博朋克黑客 | 酷、技术范 | 极客气质、网络梗 |
| 魔法少女程序员 | 魔法、开朗 | 咒语式写码、励志 |
| … | … | … |

### 角色切换示例
```bash
/master 切换角色 loli              # 可爱萝莉风格
/master 切换角色 expert_mentor     # 专家导师风格
/master List roles                 # 列出全部角色
/master 切换角色 queen_sister      # 御姐女王（英文别名亦可）
/master Call 小妮                  # 昵称呼叫
```

---

## 🚀 快速开始

### 安装：复制（完整运行时）或插件（全局）

**方式 A — 复制到项目（推荐：完整 hooks + `core/`）**

```bash
git clone https://github.com/wangqiqi/cursor-ai-rules.git
cp -r cursor-ai-rules/.cursor your-project/
cp cursor-ai-rules/AGENTS.md your-project/
cp cursor-ai-rules/.cursorignore your-project/   # 推荐：缩小 @codebase 索引
```

**方式 B — Cursor 插件（单仓库，软链整个仓库）**

```bash
git clone https://github.com/wangqiqi/cursor-ai-rules.git
cd cursor-ai-rules
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)" ~/.cursor/plugins/local/cursor-ai-rules
# 重启 Cursor；可选：cp AGENTS.md your-project/
```

`.cursor-plugin/plugin.json` **直接指向** `.cursor/`，无需 `packages/` 副本。

详见 [INSTALL.md](../INSTALL.md) 与 [docs/MARKETPLACE_SUBMIT.md](../docs/MARKETPLACE_SUBMIT.md)。

| 能力 | 复制 `.cursor/` | 安装本仓库为插件 |
|------|-----------------|------------------|
| 77 rules / 46 skills | ✅ | ✅（同一 `.cursor/`） |
| `/master`、`/vibe` | ✅ | ✅ |
| Hooks + `core/` | ✅ | ✅ |
| `.cursorGrowth` | ✅ 各项目独立 | ✅ 各项目独立 |

**方式 C — 可选初始化**

```bash
bash your-project/.cursor/core/init.sh --quickstart
```

### 安装后常用命令

| 命令 | 说明 |
|------|------|
| `/master` | 进入 AI 命令模式 |
| `/master 分析这个项目` | 分析项目结构和技术栈 |
| `/master 切换角色 [角色名]` | 切换对话风格 |
| `/vibe start` | 启动 VIBE 开发模式 |

### 方式一：`/master`（新手推荐）
```bash
/master 创建一个 React 项目
/master 学习 JavaScript 基础
/master 优化代码性能
/master 分析项目架构
```

### 方式二：VIBE 开发流
```bash
/vibe start              # 初始化开发模式
/vibe prd                # 生成产品需求文档
/vibe code               # 智能代码生成
/vibe test               # 自动化测试
/vibe deploy             # 一键部署
```

### 方式三：Skills 技能系统
```bash
# 查看可用技能
有哪些 skills 可用？

# 使用指定技能
用 backend-development 技能设计 API
用 security-analysis 技能检查代码
```

### 方式四：人格角色
```bash
/master 切换角色 expert_mentor
/master 切换角色 loli
/master 切换角色 queen_sister
```

### 方式五：团队经验沉淀（⭐ 重要）

反复出现的 bug、发版教训 → 固化为规则，供全团队复用：

```bash
bash .cursor/core/team-experience-init.sh
bash .cursor/skills/team-experience/scripts/collect-context.sh   # 仅采集 CHANGELOG/git 原文
/master 沉淀规则
/master skill:team-experience
```

| 组件 | 路径 |
|------|------|
| 沉淀目录 | `.cursorGrowth/team-experience/rules/`（草案在 `inbox/`） |
| 桥接规则（`.cursor` 内唯一相关新增） | `.cursor/rules/workflow/growth-team-experience-bridge.mdc` |
| 技能 | `.cursor/skills/team-experience/` |

大模型阅读原文并生成 `.mdc`；**不用脚本解析** CHANGELOG。详见下文 **「团队经验沉淀」** 专节。

---

## 📁 目录结构

**你的项目（复制安装后）**

```
your-project/
├── AGENTS.md                     ← 子代理与 Master 入口说明
├── .cursorignore                 ← 推荐；team-experience 已白名单
├── .cursorGrowth/                ← 运行后生成（可选提交 team-experience/）
│   └── team-experience/          ← 团队沉淀规则（固定目录名）
│       ├── rules/*.mdc
│       ├── inbox/
│       └── manifest.json
└── .cursor/
    ├── hooks.json                # Cursor 官方 Hooks schema
    ├── hooks/                    # 钩子脚本
    ├── rules/                    # 76 条 .mdc 规则
    ├── skills/                   # 45 个 Agent Skills 包
    ├── agents/                   # master、command-center
    ├── commands/                 # /master、/vibe 等命令实现
    ├── core/                     # Shell 核心与编排
    ├── features/                 # registry、自动化、hooks-engine
    ├── config/                   # 项目与人格配置
    ├── docs/                     # 完整文档
    ├── tests/                    # CI 测试脚本
    ├── README.md                 # 中文（本文件）
    └── README.en.md              # 英文（与仓库根目录软链一致）
```

**`.cursor/` 内部结构（概要）**

```
.cursor/
├── README.md / README.en.md
├── agents/               # command-center、master
├── commands/             # master.md、vibe.md、处理器
├── config/
├── core/                 # init.sh、env-perception、quality-manager 等
├── docs/                 # developer/、guides/、reference/、admin/
├── features/             # skills 注册表、hooks
├── rules/                # core/、system/、tech/、workflow/、evolution/
└── skills/               # 45 个 SKILL.md + skill-dispatcher
```

---

## 📊 技术指标

| 指标 | v1.0 | v2.0 | 提升 |
|------|------|------|------|
| 初始化时间 | ~30s | ~3s | **约 90%↑** |
| 感知时间 | ~10s | ~0.5s | **约 95%↑** |
| Token 节省 | 基线 | 约 70%↓ | **约 70%↑** |
| 组件数量 | 42 | 161+ | **约 283%↑** |
| 系统稳定性 | 95% | 99.9% | **设计目标** |

*指标为设计目标与内部基准，实际环境可能有所差异。*

---

## 🔧 系统要求

### 环境要求
- **Cursor 编辑器** v0.40+
- **Git** 2.0+（可选；核心复制路径不强制）
- **Bash** 4.0+
- **jq**（可选；hooks-engine 与部分 Master 脚本推荐安装）

### 开箱能力

#### 🚀 项目无关
- ✅ 自动识别技术栈（JavaScript、Python、Go、Rust、Java、C/C++ 等）
- ✅ 分析团队规模与开发阶段
- ✅ 按项目复杂度动态调整

#### 👤 用户无关
- ✅ 通过 Git 配置获取用户信息
- ✅ 无 Git 环境时使用通用默认值
- ✅ 自动获取本地时区
- ✅ **隐私保护**：主动维护 `.gitignore`，避免 `.cursorGrowth` 泄露

#### 🌍 语言无关
- ✅ 自动检测项目文件结构
- ✅ 支持主流编程语言
- ✅ 推荐语言相关最佳实践

---

## 📚 完整文档

详细文档位于 **[.cursor/docs/](docs/README.md)**：

| 文档 | 说明 |
|------|------|
| [快速开始](docs/getting-started.md) | 5 分钟上手 |
| [用户指南](docs/user-guide.md) | 完整功能说明 |
| [系统架构](docs/developer/SYSTEM_ARCHITECTURE.md) | 架构设计 |
| [调用链](docs/developer/CALL_CHAIN.md) | 系统调用流程 |
| [技能指南](docs/guides/SKILL_GUIDE.md) | Skills 使用 |
| [自洽性报告](docs/reference/CURSOR_SELF_CONSISTENCY_REPORT.md) | 系统自洽评估 |
| [市场上架说明](../docs/MARKETPLACE_SUBMIT.md) | 插件 / 市场上架 |

---

## 🌱 项目生长系统（`.cursorGrowth`）

系统可在项目中创建 `.cursorGrowth` 目录，存放项目私有数据：

### 🔒 自动隐私保护
```gitignore
# Cursor AI 生长数据（默认忽略）
.cursorGrowth/
# 可选：仅共享团队沉淀规则
!.cursorGrowth/team-experience/
!.cursorGrowth/team-experience/**
```

### 📊 典型记录内容
- **AI 核心数据**：Agent 状态与配置
- **分析与监控**：代码质量、性能、依赖分析
- **配置数据**：压缩策略、用户配置
- **外部集成**：缓存、服务、工具检测
- **研究与实验**：实验队列、优化历史

### 🧠 智能学习机制
- **被动学习**：每次调用记录模式
- **主动学习**：特定命令触发深度学习
- **持续优化**：基于历史数据改进响应

---

## 🤝 团队经验沉淀（`team-experience`）⭐

> **核心思路**：教训写在 **Growth**，生效靠 **桥接**；`.cursor/rules` 主树保持稳定，团队经验可跨项目、可多人、可选进 Git。

### 为什么需要

| 场景 | 做法 |
|------|------|
| 同一小 bug 反复出现 | 沉淀为 `rules/*.mdc`，下次自动加载 |
| 发版记录在 CHANGELOG | 大模型从原文归纳「必须 / 禁止」 |
| 多人协作 | 统一目录名 `team-experience/`，只提交该子树即可共享 |

### 架构（双轨）

```mermaid
flowchart LR
  A[CHANGELOG + git log + 对话] --> B[大模型归纳]
  B --> C[inbox 草案]
  C -->|用户确认| D[team-experience/rules/*.mdc]
  D --> E[growth-team-experience-bridge.mdc]
  E --> F[Agent 遵守补充规则]
```

- **不修改** `.cursor/rules/` 主树（除桥接文件 `growth-team-experience-bridge.mdc`）。
- **脚本** `collect-context.sh` 只输出原文，**不解析** CHANGELOG。

### 固定路径（所有项目一致）

| 路径 | 说明 |
|------|------|
| `.cursorGrowth/team-experience/rules/` | 已采纳的 `.mdc` |
| `.cursorGrowth/team-experience/inbox/` | 待确认草案 |
| `.cursorGrowth/team-experience/manifest.json` | 作者、日期、来源 commit/版本、status |
| `.cursor/rules/workflow/growth-team-experience-bridge.mdc` | 加载 `rules/` 下全部 `.mdc` |
| `.cursor/skills/team-experience/` | 技能与工作流说明 |

初始化：`bash .cursor/core/team-experience-init.sh`（`growth_init.sh` 也会创建）。

### 索引与 Git

- **`.cursorignore`** 已对 `team-experience/` 白名单 → 支持 `@codebase` 检索。
- **`.gitignore`** 同路径白名单 → 团队可 **只 commit** `team-experience/` 汇聚整体经验。

更多细节：[配置说明](docs/admin/configuration.md) · [模板说明](templates/team-experience/README.md)

---

## 🤝 贡献与支持

### 贡献方式
- Issue 反馈缺陷
- Pull Request 提交改进
- 与主仓库保持同步

### 系统校验
```bash
./.cursor/verify-system.sh         # 完整校验
./.cursor/verify-system.sh --quick  # 快速校验
```

---

## 📜 许可证

MIT License — 详见 [LICENSE](../LICENSE)

---

**🚀 Cursor AI Rules v2.0.0 - 宪法驱动的超级 AI 编程伙伴**

*最后更新：2026-06-01 | 作者：wangqiqi (https://github.com/wangqiqi)*

*基于 Cursor 官方规范：宪法驱动 + 智能感知 + 智能决策 + 持续进化*
