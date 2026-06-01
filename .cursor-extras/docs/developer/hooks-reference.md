# Hooks 参考文档

## 版本信息

本项目包含两套钩子系统，各有独立的版本和配置来源：

| 系统 | 版本 | 配置文件路径 |
|------|------|-------------|
| **Cursor 原生 Hooks** | v1 | `.cursor-extras/hooks.json` |
| **Hooks 引擎** | v3 | `.cursor-extras/features/hooks/hooks.json` |

> **Cursor 原生 Hooks**：由 Cursor IDE 1.7+ 内置支持，在 IDE 设置中启用后自动触发。
> **Hooks 引擎**：由 `core/hooks-engine.sh` 脚本驱动的自定义事件系统，支持更丰富的触发器和配置项。

---

## 全局配置（Hooks 引擎）

| 配置项 | 值 |
|--------|-----|
| 最大执行时间 | 30000 ms |
| 错误处理策略 | `log_and_continue` |
| 日志记录 | 启用 |
| 遥测 | 禁用 |

---

## 完整钩子列表

所有钩子按触发器（事件）分组，每组内部按优先级从高到低排列。

### `beforeSubmitPrompt` — 提交提示前

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| session-state-guard | beforeSubmitPrompt | 100 | 4000 | 否 | 是 | 会话状态守护 |
| role-sync | beforeSubmitPrompt | — | 5000 | 否 | 是 | 强制角色同步 — 确保每个对话框都有正确的角色状态 |
| context-management | beforeSubmitPrompt | — | 5000 | 否 | 是 | 智能上下文管理 |
| prompt-security | beforeSubmitPrompt | — | 2000 | 否 | 是 | 提示安全检查 |
| master-sync-trigger | beforeSubmitPrompt | — | 10000 | 是 | 是 | 检测对话框首次使用 /master 命令并触发同步 |
| ensure-growth-on-prompt | beforeSubmitPrompt | — | — | — | — | 确保 `.cursorGrowth` 目录存在（Cursor 原生钩子） |

### `onSessionStart` — 会话开始时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| role-activation | onSessionStart | 95 | 8000 | 是 | 是 | 会话开始角色系统初始化 |
| master-init | onSessionStart | 90 | 7000 | 是 | 是 | Master 命令初始化 |
| session-state-guard | onSessionStart | 80 | 2000 | 否 | 是 | 本地状态守护 |
| env-perception | onSessionStart | — | 5000 | 是 | 是 | 会话开始环境感知 |
| session-optimizer | onSessionStart | — | 6000 | 是 | 是 | 会话开始系统优化 |
| growth-directory-check | onSessionStart | — | 5000 | 是 | 是 | 会话开始时检查生长目录 |

### `onConversationStart` — 新对话框开始时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| session-state-guard | onConversationStart | 60 | 2500 | 是 | 是 | 确保多对话状态保持 |
| conversation-init | onConversationStart | — | 3000 | 是 | 是 | 新对话框初始化和角色激活 |
| master-sync-init | onConversationStart | — | 2000 | 是 | 是 | 新对话框开始时初始化 Master 同步状态 |

### `afterFileSave` — 文件保存后

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| consistency-check | afterFileSave | — | 10000 | 是 | 是 | 代码一致性自动检查 |
| architecture-check | afterFileSave | — | 8000 | 是 | 是 | 架构合规性检查 |
| code-quality | afterFileSave | — | 5000 | 是 | 是 | 代码质量检查 |
| quality-check | afterFileSave | — | 15000 | 是 | 是 | 统一质量管理系统检查 |
| config-validator | afterFileSave | — | 5000 | 是 | 是 | 配置文件自动验证 |
| dependency-check | afterFileSave | — | 8000 | 是 | 是 | 依赖关系自动检查 |

### `afterShellExecution` — Shell 执行后

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| command-log | afterShellExecution | 50 | 3000 | 是 | 是 | 命令执行日志记录 |
| event-logger | afterShellExecution | 40 | 2000 | 是 | 是 | 通用事件日志记录 |
| performance-monitor | afterShellExecution | — | 3000 | 是 | 是 | 命令执行性能监控 |

### `afterAgentResponse` — AI 响应后

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| agent-orchestration | afterAgentResponse | 70 | 15000 | 是 | 是 | 8 个智能代理协作编排 |
| growth-recorder | afterAgentResponse | — | 3000 | 是 | 是 | AI 响应后生长记录 |
| token-compression | afterAgentResponse | — | 5000 | 是 | 是 | AI 响应后 Token 压缩优化 |
| context-pool-manager | afterAgentResponse | — | 8000 | 是 | 是 | 上下文池动态管理 |

### `preCommitAnalysis` — 预提交分析

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| pre-commit-analyzer | preCommitAnalysis | — | 15000 | 是 | 是 | 预提交深度分析 |

### `commitMessageValidation` — 提交消息验证

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| commit-message-validator | commitMessageValidation | — | 5000 | 否 | 是 | 提交消息格式验证 |

### `preCommitOptimization` — 预提交优化

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| adaptive-optimization | preCommitOptimization | — | 12000 | 是 | 是 | 自适应优化和 A/B 测试 |
| experiment-framework | preCommitOptimization | — | 15000 | 是 | 是 | 实验框架自动化 |

### `postCommitLogging` — 后提交日志

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| post-commit-logger | postCommitLogging | — | 10000 | 是 | 是 | 后提交日志记录和分析 |

### `onSessionEnd` — 会话结束时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| cursor-sync | onSessionEnd | — | 10000 | 是 | 是 | 会话结束时同步 Cursor 对话记录 |
| session-learning | onSessionEnd | — | 15000 | 是 | 是 | 会话结束学习总结 |
| continuous-learning | onSessionEnd | — | 20000 | 是 | 是 | 持续学习循环 |

### `onEnvironmentChange` — 环境变化时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| mcp-integration | onEnvironmentChange | — | 20000 | 是 | 是 | 本地工具 MCP 集成 |

### `performanceReportGeneration` — 性能报告生成

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| performance-dashboard | performanceReportGeneration | — | 15000 | 是 | 是 | 性能仪表板报告 |

### `onDebugSessionStart` — 调试会话开始时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| pattern-analyzer | onDebugSessionStart | — | 20000 | 是 | 是 | 错误模式智能分析 |

### `onErrorDetected` — 错误检测时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| isolation-debugger | onErrorDetected | — | 15000 | 是 | 是 | 隔离调试环境 |

### `tokenOptimization` — Token 优化

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| token-compression | tokenOptimization | — | 10000 | 是 | 是 | Token 智能压缩 |

### `qualityReportGeneration` — 质量报告生成

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| quality-reporter | qualityReportGeneration | — | 12000 | 是 | 是 | 质量报告生成 |

### `onComplexConversation` — 复杂对话时

| 钩子名称 | 触发事件 | 优先级 | 超时时间(ms) | 异步 | 启用 | 描述 |
|----------|---------|--------|-------------|------|------|------|
| conversational-system | onComplexConversation | 55 | 13000 | 是 | 是 | 高级会话命令处理 |

---

## 说明

- **优先级**：数值越大优先级越高。未设置优先级（`—`）的钩子采用系统默认值。
- **超时时间**：钩子执行的最大等待时间（毫秒），超时后引擎将继续执行下一个钩子。
- **异步**：`是` 表示钩子异步执行，不阻塞主流程；`否` 表示同步执行。
- **启用**：`是` 表示钩子当前处于激活状态；`否` 表示已禁用。
- **Cursor 原生钩子**（来自 `.cursor-extras/hooks.json`）部分字段未在配置中显式定义，表中以 `—` 表示。
