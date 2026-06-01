# Cursor AI Rules - 核心版 v2.0.0

> **宪法驱动的超级 AI 编程伙伴**
> 复制 `.cursor/` 与根目录 `AGENTS.md` 到任意项目，零配置，立即使用。

---

## 🚀 使用方式

### 方式一：复制即用（完整运行时，推荐）

```bash
# 1. 把 .cursor/ 与 AGENTS.md 复制到你的项目根目录
cp -r cursor-ai-rules/.cursor your-project/
cp cursor-ai-rules/AGENTS.md your-project/

# 2. 打开 Cursor IDE，开始使用
```

### 方式二：Cursor 插件（全局 rules/skills/agents/commands）

本仓库同步生成市场插件包：`packages/cursor-ai-rules-plugin/`（由 `scripts/sync-plugin-package.sh` 从 `.cursor/` 同步）。

**本地安装（开发 / 自用）：**

```bash
bash scripts/sync-plugin-package.sh
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)/packages/cursor-ai-rules-plugin" ~/.cursor/plugins/local/cursor-ai-rules
```

重启 Cursor 后，规则与技能对所有工作区生效。可选将子代理说明复制到项目根：

```bash
cp packages/cursor-ai-rules-plugin/templates/AGENTS.md your-project/
```

**与复制安装对比：**

| 能力 | 复制 `.cursor/` | 插件包 |
|------|-----------------|--------|
| 70+ rules / 45+ skills | ✅ | ✅ |
| `/master`、`/vibe` 命令 | ✅ | ✅ |
| Hooks + `core/` | ✅ 项目路径 | ✅ 插件相对路径 |
| 每项目 `.cursorGrowth` | ✅ | ✅（仍写在项目根） |

详见 [packages/cursor-ai-rules-plugin/README.md](packages/cursor-ai-rules-plugin/README.md)。

在 Cursor 聊天框中输入：

| 命令 | 说明 |
|------|------|
| `/master` | 进入 AI 命令模式 |
| `/master 分析这个项目` | 分析项目结构和技术栈 |
| `/master 切换角色 [角色名]` | 切换对话风格 |
| `/vibe start` | 启动 VIBE 开发模式 |

### 方式三：可选初始化

```bash
bash your-project/.cursor/core/init.sh --quickstart
```

`.cursor/` 已包含 70+ 规则（`.mdc`）、技能、子代理、钩子与核心脚本；`AGENTS.md` 供 Cursor 发现子代理说明。

---

## 📦 目录结构

**本仓库（维护者）**

```
cursor-ai-rules/
├── AGENTS.md
├── .cursor/                      ← 权威源：复制即用
├── packages/cursor-ai-rules-plugin/  ← 同步生成的 Cursor 插件包
├── scripts/
│   ├── sync-plugin-package.sh
│   ├── verify-plugin-package.sh
│   └── check-plugin-package-drift.sh
└── docs/MARKETPLACE_SUBMIT.md    ← 市场上架清单
```

维护者可选：`bash scripts/install-githooks.sh`（改 `.cursor/` 时自动 sync 并 stage `packages/`）

**你的项目（复制安装后）**

```
your-project/
├── AGENTS.md                     ← 子代理与 Master 入口说明
└── .cursor/                      ← 官方结构（复制即用）
    ├── hooks.json                # Cursor 官方 Hooks schema
    ├── hooks/                    # 钩子脚本
    ├── rules/                    # 70+ .mdc 规则
    ├── skills/                   # 45 个官方 Agent Skills 包
    ├── agents/                   # master、command-center 子代理
    ├── commands/                 # /master、/vibe 等命令实现
    ├── core/                     # Shell 核心与 agent-orchestration
    ├── features/                 # registry 索引、自动化、hooks-engine 配置
    ├── config/                   # 项目与人格角色配置
    ├── docs/                     # 开发与使用文档
    ├── tests/                    # CI 测试脚本
    ├── README.md
    └── README.en.md              # 英文长文档（根 README.en.md 软链至此）
```

---

## ⚖️ 核心宪法（三大公理）

所有行为遵循以下三条基本原理：

| 公理 | 含义 |
|------|------|
| **意图主权** | 人类永远保留"为什么做"和"什么是对的"的最终决策权 |
| **信号可信** | AI 的所有输出必须附带可追溯、可验证的原始信号链 |
| **认知可审计** | 所有 AI 协作过程支持"三秒回溯" |

---

## 🎭 21 种人格角色

所有角色都是**全能的** —— 差异仅在于**对话风格**，而非专业能力：

| 类型 | 包含 |
|------|------|
| 专业风格（8 种） | 专业助手、谦逊助手、友好伙伴、专家导师、创意艺术家、严格教师、搞笑演员、极简禅者 |
| 动漫风格（13 种） | 可爱萝莉、御姐女王、完美女仆、赛博朋克黑客、魔法少女程序员、和风武士、哥特侦探等 |

```bash
/master 切换角色 loli              # 切换为可爱萝莉风格
/master 切换角色 expert_mentor     # 切换为专家导师风格
```

---

## 🔧 系统要求

- **Cursor** v0.40+
- **Bash** 4.0+
- **Git**（可选，没有也能用）

部分扩展能力（hooks-engine、部分 Master 脚本）可选依赖 `jq`；核心复制即用路径不强制外部工具。

---

## 📄 许可证

MIT License
