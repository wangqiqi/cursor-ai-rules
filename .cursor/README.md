# Cursor AI Rules - 核心版 v2.0.0

> **宪法驱动的超级 AI 编程伙伴**
> 复制 `.cursor/` 到任意项目，零配置，立即使用。

---

## 🚀 使用方式

### 方式一：复制即用（推荐）

```bash
# 1. 把 .cursor/ 复制到你的项目根目录
cp -r cursor-ai-rules/.cursor your-project/

# 2. 打开 Cursor IDE，开始使用
```

在 Cursor 聊天框中输入：

| 命令 | 说明 |
|------|------|
| `/master` | 进入 AI 命令模式 |
| `/master 分析这个项目` | 分析项目结构和技术栈 |
| `/master 切换角色 [角色名]` | 切换对话风格 |
| `/vibe start` | 启动 VIBE 开发模式 |

### 方式二：全功能安装

```bash
# 复制核心层 + 扩展层
cp -r cursor-ai-rules/.cursor your-project/
cp -r cursor-ai-rules/.cursor-extras your-project/

# 一键初始化
bash your-project/.cursor/core/init.sh --quickstart
```

扩展层包含 70+ 规则、80+ 脚本、37 个技能、42 个钩子、21 种人格角色。

---

## 📦 目录结构

```
.cursor/                          ← 核心层（7 个文件，零依赖）
├── init.sh                       # 一键初始化
├── cursor-master.sh              # 命令行入口
├── core/
│   ├── path-config.sh            # 路径配置
│   ├── common.sh                 # 公共函数
│   └── compact-output.sh         # 输出格式化
├── rules/
│   ├── constitution.md           # 三大公理
│   └── core/
│       └── constitution_architecture.md  # 架构宪法
├── config/
│   └── project.json
└── README.md

.cursor-extras/                   ← 扩展层（按需复制）
├── rules/                        # 70+ 技术/工作流规则
├── core/                         # 80+ 脚本
├── features/                     # 技能、钩子、自动化
├── agents/                       # Agent 定义
├── commands/                     # 命令系统
├── skills/                       # 技能调度器
├── plugins/                      # 插件
├── docs/                         # 文档
├── tests/                        # 测试
└── config/roles/                 # 21 种人格角色
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

无其他外部依赖。`jq`、`node`、`openssl` 等仅在扩展层中使用。

---

## 📄 许可证

MIT License
