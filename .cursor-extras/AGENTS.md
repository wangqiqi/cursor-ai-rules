# Agent 指令

本项目使用 Cursor AI Rules 的智能命令中枢，提供统一的 AI 编程助手能力。

## 可用 Agent

- **command-center** (`.cursor/agents/command-center.md`): 智能命令中枢，统一调用 master、vibe、command-router 等命令，支持 21 种 AI 人格角色和宪法合规检查。
- **master** (`.cursor/agents/master.md`): Master 智能命令中心专用子代理，实现与 `/master` 同等功能，支持意图解析、智能路由、规则/技能/脚本调用、21 种 AI 人格。

## Master 等效能力（统一入口）

> **说明**：Cursor 仅支持 `/命令`（斜杠命令），不支持 `@命令`。

| 类型 | 位置 | 调用方式 |
|------|------|----------|
| 命令 | `/master` | 聊天输入 `/master 需求描述` |
| 子代理 | `.cursor/agents/master.md` | AI 内部 `mcp_task(subagent_type: "master", ...)` |
| 规则 | `.cursor/rules/master-skill.md` | 语义匹配时自动触发（未输入 /master 时等效） |

## 使用方式

- 在聊天中输入 `/master 需求描述` 触发 Master 命令中心
- 使用 `/vibe` 进入 VIBE 专业开发流程（如 `/vibe start`、`/vibe code`）
- 提及「命令中枢」时，AI 可调用 command-center 子代理
- master 子代理由 AI 通过 mcp_task 内部调用，用户无直接入口

## 更多信息

详见 [.cursor/README.md](README.md) 和 [.cursor/docs/](docs/)。
