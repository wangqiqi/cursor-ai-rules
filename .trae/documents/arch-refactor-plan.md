# 核心-扩展分层架构重构计划

## 目标

将系统从"全量加载"重构为"核心极简 + 扩展按需"，实现：
1. **开箱即用** — 复制 `.cursor/` 到任意项目，无需任何配置即可使用
2. **零门槛** — 无需安装 `jq`、`openssl` 等外部依赖
3. **所有角色全能** — 21 种人格角色是对话风格不是专业分工

---

## 架构设计

```
.cursor/                          ← 核心层：复制即用，~8 个文件
├── init.sh                       # 一键初始化
├── cursor-master.sh              # 主入口
├── core/
│   ├── path-config.sh            # 路径配置（零依赖版）
│   ├── common.sh                 # 公共函数
│   └── compact-output.sh         # 输出格式化
├── rules/
│   ├── constitution.md           # 宪法（必选）
│   └── constitution_architecture.md  # 架构宪法
├── config/
│   └── project.json              # 项目配置
└── README.md

.cursor-extras/                   ← 扩展层：按需复制
├── rules/                        # +70 个额外规则
├── core/                         # +80 个额外脚本
├── features/skills/              # +37 个技能
├── features/hooks/               # +42 个钩子
├── agents/                       # Agent 定义
├── plugins/                      # 插件
├── docs/                         # 文档
├── tests/                        # 测试
└── roles/                        # 21 种人格角色定义
```

---

## 阶段划分

### 阶段一：核心层精简

将 `.cursor/` 精简到最小可用集，其余移到 `.cursor-extras/`

| 当前 | → | 核心层 | 扩展层 |
|------|---|--------|--------|
| core/ 下 89 个文件 | → | 3 个 | 86 个 |
| rules/ 下 75 个文件 | → | 2 个 | 73 个 |
| features/ 下 80+ 个文件 | → | 0 个 | 全部 |
| config/ 下 22 个文件 | → | 1 个 | 21 个 |

**核心层规则**：constitution.md + constitution_architecture.md

为什么选这两个？
- `constitution.md` — 三大公理（意图主权、信号可信、认知可审计），是所有行为的底层约束
- `constitution_architecture.md` — 架构宪法，定义系统交互原则

这两条规则构成"元规则"——它们不约束技术细节，而是约束 AI 的**行为准则**和**系统交互方式**。适用于任何项目、任何技术栈。

### 阶段二：零依赖初始化

`init.sh` 重构：
1. 不再依赖 `jq` — 用 shell 原生的字符串处理代替 JSON 解析
2. 不再依赖 `openssl` — 用 `/dev/urandom` 生成 ID
3. 自动检测项目类型（Node.js/Python/Rust/Go/Java 等）
4. 自动生成 `project.json`，无需手动编辑
5. 交互式引导：`bash init.sh --quickstart`

### 阶段三：模块化加载机制

核心层自动加载扩展层（如果存在）：

```bash
# 核心层 init.sh 中
if [ -d "$CURSOR_DIR/../.cursor-extras" ]; then
    source "$CURSOR_DIR/../.cursor-extras/init.sh"
fi
```

这样用户只需要：
1. `cp -r cursor-ai-rules/.cursor my-project/`
2. （可选）`cp -r cursor-ai-rules/.cursor-extras my-project/`

---

## 详细步骤

### 步骤 1：创建核心层目录结构

```
.cursor/                          ← 核心目录
├── init.sh                       # 零依赖初始化
├── cursor-master.sh              # 主入口（简化版）
├── core/
│   ├── path-config.sh            # 路径配置
│   ├── common.sh                 # 公共函数库
│   └── compact-output.sh         # 紧凑输出
├── rules/
│   ├── constitution.md           # 三大公理
│   └── constitution_architecture.md  # 架构宪法
├── config/
│   └── project.json              # 自动生成，无需手动编辑
└── README.md                     # 使用说明
```

### 步骤 2：创建扩展层目录（从当前 .cursor/ 移出）

```
.cursor-extras/
├── rules/                        # 所有技术/工作流/系统/进化规则
├── core/                         # 所有额外脚本
├── features/                     # 技能、钩子、自动化
├── agents/                       # Agent 定义
├── plugins/                      # 插件系统
├── docs/                         # 完整文档
├── tests/                        # 测试
├── config/roles/                 # 21 种人格角色配置
├── skills/                       # 技能调度器
├── commands/                     # 命令系统
└── init.sh                       # 扩展层初始化
```

### 步骤 3：重构 `init.sh` — 零依赖、自动检测

```bash
# 新的 init.sh 流程
1. 自动检测项目类型（检测 package.json / Cargo.toml / go.mod / pom.xml / requirements.txt）
2. 检查核心依赖（仅 bash 4+）
3. 生成 project.json（基于检测结果，无需 jq）
4. 检测 .cursor-extras/ 是否存在，如果存在则加载
5. 输出成功信息
```

### 步骤 4：重构 `path-config.sh` — 零依赖路径解析

- 移除对 `jq` 的依赖
- 使用 shell 原生的 `JSON.sh` 风格解析，或读取纯文本配置文件
- 如果找不到项目文件，使用合理默认值

### 步骤 5：更新文档

- `README.md` — 简化为一页："复制 .cursor/ → 打开 Cursor → 开始使用"
- 21 种人格角色说明统一更新为"对话风格"而非"专业分工"

---

## 预期效果

| 指标 | 当前 | 优化后 |
|------|------|--------|
| 核心文件数 | ~200 | ~8 |
| 使用步骤 | 5 步 + 环境准备 | 1 步 |
| 外部依赖 | jq, openssl, git | 无 |
| 适用项目 | Git 项目 | 任意目录 |
| 用户门槛 | 需要 shell 经验 | 零门槛 |

---

## 讨论点

1. **扩展层的位置**：`.cursor-extras/` 放在项目根目录 vs 放在 `.cursor/extras/` 内部？
2. **人格角色配置**：21 种人格的 JSON 配置放在哪？核心层只保留 3-5 种基础风格？
3. **项目类型检测**：支持哪些项目类型？检测到未知类型时的降级策略？
4. **扩展层加载方式**：自动加载 vs 显式 `--install` 命令？
