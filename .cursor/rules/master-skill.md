---
description: "Master 智能命令中心等效规则 - 实现与 /master 相同的效果和功能，支持意图解析、智能路由、规则/技能/脚本调用、21种AI人格"
alwaysApply: false
priority: 25
---

# 🎯 Master 智能命令中心等效规则

当用户**未使用 `/master` 命令**但表达类似需求时，本规则指导 AI 采用 Master 的完整处理流程，达到与 `/master` 相同的效果。

## 触发条件

以下任一情况触发本规则：
- 用户提及「master」「命令中枢」「命令中心」
- 用户表达学习、创建、优化、分析、角色切换等 Master 支持的意图
- 用户请求需要智能路由、技能匹配、规则调用的任务

## ⚠️ 前置步骤（必须执行）

在处理任何 Master 等效请求前：
1. **检查** `.cursorGrowth` 目录是否存在
2. **若不存在**，运行：`bash .cursor/features/automation/scripts/growth_init.sh`
3. **然后再**继续处理用户请求

## 首选执行方式：调用 command-center

**优先使用** `mcp_task` 工具调用 `command-center` 子 agent：

```
mcp_task(
  subagent_type: "command-center",
  description: "Master 等效处理",
  prompt: "用户请求: [用户完整输入]\n\n请按 Master 命令中心流程处理：意图解析 → 宪法合规检查 → 智能路由 → 执行编排 → 结果整合"
)
```

command-center 精通 master、vibe、command-router 等所有命令，支持 21 种 AI 人格和宪法合规检查。

## 备选：直接按 Master 流程处理

若无法调用 mcp_task，则按以下流程自行处理：

### 1. 意图解析

识别用户意图类型：
- **学习类**：学习、了解、掌握、教程、指南
- **创建类**：创建、开发、构建、搭建、实现
- **优化类**：优化、改进、重构、修复、增强
- **分析类**：分析、检查、评估、诊断、审计
- **角色类**：切换角色、呼叫、昵称
- **直接调用**：`rule X`、`script X`、`skill X`、`hook X`、`workflow X`

### 2. 宪法合规检查

- 对高风险操作执行合规检查
- 项目创建意图需先讨论需求，确认后再执行

### 3. 智能路由与执行

| 意图/类型 | 执行动作 |
|----------|----------|
| rule X | 读取 `.cursor/rules/` 下对应规则并应用 |
| script X | 执行 `.cursor/` 下对应脚本 |
| skill X | 读取 skill-dispatcher，匹配并加载 `.cursor/features/skills/` 下技能 |
| hook X | 执行 `.cursor/features/hooks/` 下钩子 |
| workflow X | 按工作流配置顺序执行 |
| 角色切换/呼叫 | 读取 `.cursor/commands/role-manager` 相关配置，切换人格 |
| 学习/创建/优化/分析 | 结合 skill-dispatcher 匹配技能，提供专业指导 |

### 4. 技能匹配

当任务需要专业技能时：
1. 读取 `.cursor/features/skills/registry.json`
2. 根据用户输入关键词匹配技能
3. 加载对应 `.cursor/features/skills/*.md` 并应用

### 5. 角色系统

支持 21 种 AI 人格，包括：
- 专业角色：professional_assistant、architect、mentor 等
- 动漫风格：loli、queen_sister、cyberpunk_hacker 等
- 昵称呼叫：如「呼叫 小妮」「切换角色 loli」

## 示例

**用户**：「帮我学习 React Hooks」
**触发**：学习类意图
**执行**：调用 mcp_task command-center，或匹配 learning-assistant / react 相关技能并应用

**用户**：「切换角色 小妮」
**触发**：角色呼叫
**执行**：按昵称查找角色配置，切换人格并返回欢迎消息

**用户**：「skill api-design」
**触发**：直接调用
**执行**：加载 `.cursor/features/skills/api-design.md` 并应用

## 相关资源

- Master 命令定义：`.cursor/commands/master.md`
- 命令中枢 Agent：`.cursor/agents/command-center.md`
- 技能调度器：`.cursor/skills/skill-dispatcher/SKILL.md`
- 技能注册表：`.cursor/features/skills/registry.json`
