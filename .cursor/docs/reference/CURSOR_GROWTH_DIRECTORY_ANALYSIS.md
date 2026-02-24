# .cursorGrowth 目录结构分析报告

> 分析所有目录的产生来源、合理性及潜在问题
> **已实施扁平化修复 (2026-02-24)**

## 一、规范目录结构（扁平化后）

```
.cursorGrowth/
├── perception/          # 环境感知
├── user/                # 用户数据 (原 user_data)
│   └── config/         # 用户配置
│       └── project_state.json  # 项目持久化状态 (原 .cursor-project.json)
├── ai/                  # AI 核心
│   ├── agents/         # Agent 配置 (原 agent-data)
│   ├── tasks/          # 任务状态 (原 task-states)
│   ├── commands/       # 命令日志 (原 command_logs)
│   ├── training/       # 学习数据 (原 training_data)
│   ├── cache/          # 缓存
│   ├── metrics/        # 指标 (ai-profile.json)
│   └── skills/         # 已加载技能
├── analytics/           # 分析 (含 cache)
│   └── cache/
├── logs/                # 统一日志 (原 monitoring/logs)
├── integrations/        # 第三方集成
│   └── sync/
└── conversations/       # 对话记录
```

## 二、历史结构（修复前，供参考）

```
.cursorGrowth/
├── ai/                          # AI 相关数据
│   ├── agent-data/              # 8 个 Agent 配置 (planner, generator, tester...)
│   ├── agent-trees/             # Agent 树执行状态 (tree_*.json)
│   ├── task-states/             # 任务状态 (task_*.json)
│   ├── command_logs/            # Master 命令执行日志
│   ├── training_data/           # 学习交互数据
│   ├── ai-agent-*.json           # 各 Agent 状态文件
│   ├── agent-registry.json
│   ├── health-monitor.json
│   ├── ai-profile.json          # ⚠️ 与根目录重复
│   └── ...
├── perception/                  # 环境感知数据
├── user_data/
│   └── config/
│       └── config-user-profile.json
├── analytics/                   # 分析数据
│   ├── cursor.log
│   ├── token-usage.log
│   └── cache/
├── monitoring/
│   └── logs/                    # 系统日志
├── integrations/
│   └── sync/
│       └── cursor_sync_status.json
├── conversations/               # 对话记录 (cursor_*.json)
├── ai-conversation-cursor-*.json # ⚠️ 根目录遗留（应为 ai-conversations/ 或 conversations/）
├── ai-profile.json              # ⚠️ 根目录，与 ai/ 内重复
├── growth_meta.json             # 生长元数据
└── README.md
```

---

## 三、各目录产生来源

### 1. 规范定义来源：`path-config.sh` + `shared-functions.sh`

| 目录 | 定义位置 | 创建方式 |
|------|----------|----------|
| `perception` | `path-config.sh` STANDARD_DIRS | `ensure_directory_structure()` |
| `user_data` | 同上 | 同上 |
| `project_data` | 同上 | 同上 |
| `ai` | 同上 | 同上 |
| `analytics` | 同上 | 同上 |
| `monitoring` | 同上 | 同上 |
| `integrations` | 同上 | 同上 |
| `conversations` | 同上 | 同上 |
| `ai/models` | path-config 变量 | ensure_directory_structure |
| `ai/training_data` | 同上 | 同上 |
| `ai/metrics` | AI_METRICS_DIR | 同上 |
| `ai/results` | 同上 | 同上 |
| `ai/skills` | 兼容旧代码 | 同上 |
| `ai/cache` | 同上 | 同上 |
| `analytics/data` | 同上 | 同上 |
| `analytics/cache` | 同上 | 同上 |
| `monitoring/logs` | SYSTEM_LOGS_DIR | 同上 |
| `monitoring/pids` | 同上 | 同上 |
| `integrations/sync` | INTEGRATIONS_SYNC_DIR | 同上 |
| `integrations/mcp-configs` | 同上 | 同上 |
| `user_data/config` | CONFIG_DATA_DIR | context-manager.sh 按需创建 |

### 2. 运行时产生来源

| 目录/文件 | 产生来源 | 代码位置 |
|-----------|----------|----------|
| `ai/command_logs/` | Master 命令执行日志 | `master-handler.js:1133,1156` |
| `ai/agent-data/` | Agent 编排各角色配置 | `agent-orchestration-lifecycle.sh:63-99` |
| `ai/task-states/` | 任务状态持久化 | `agent-orchestration-persistence.sh:116,131` |
| `ai/agent-trees/` | Agent 树执行状态 | 由 `create_agent_tree` 调用链产生（具体实现待查） |
| `ai/training_data/` | 学习交互记录 | `cursor-master.sh:2089`、growth-recorder |
| `perception/*.json` | 环境感知结果 | `env-perception.sh:848,853`、`master-handler.js:1191` |
| `user_data/config/config-user-profile.json` | 用户配置 | `context-manager.sh:48` |
| `user_data/preferences.json` | 用户偏好 | `growth_init.sh:82` |
| `analytics/token-usage.log` | Token 监控 | `token-monitor.js:16` |
| `analytics/cache/` | 智能缓存 | `smart-cache.js:13` |
| `monitoring/logs/` | 各类日志 | `master-executor.js:1863`、`master-handler.js:3848`、`master-router.js:340`、`hooks-engine.sh:40`、`error-handler.js:163` |
| `integrations/sync/cursor_sync_status.json` | Cursor 同步状态 | `cursor-sync.sh:66` |
| `conversations/cursor_*.json` | 对话记录同步 | `cursor-sync.sh:92` (sync_transcript_file) |
| `growth_meta.json` | 生长元数据 | `master-handler.js:1480`、`growth_init.sh:50` |

### 3. 遗留/不一致来源

| 路径 | 问题 | 来源 |
|------|------|------|
| `ai-conversation-cursor-*.json`（根目录） | 应放入 `conversations/` 或 `ai-conversations/` | `cursor-sync.sh:269` 使用 `sync_directory(..., "ai-conversations", ...)`，但目标为 `GROWTH_DIR/ai-conversations`，根目录文件可能是旧版同步遗留 |
| `ai-profile.json`（根目录） | 与 `ai/ai-profile.json` 或 `ai/metrics/ai-profile.json` 重复 | `growth-manager.sh:181`、`master-init.sh:47` 写入根目录；`growth-recorder.sh:73` 写入 `AI_METRICS_DIR` |
| `GROWTH_METRICS_DIR` | **未在 path-config 中定义** | `cursor-master.sh`、`growth-manager.sh`、`growth-recorder.sh` 使用，但 path-config 无此变量 |

---

## 四、path-config 规范 vs 实际

### path-config.sh 定义的 STANDARD_DIRS（8 个顶级）

```bash
"perception" "user_data" "project_data" "ai" "analytics" "monitoring" "integrations" "conversations"
```

### growth-manager.sh 的 STANDARD_DIRS（缺少 conversations）

```bash
"perception" "user_data" "project_data" "ai" "analytics" "monitoring" "integrations"
```

**不一致**：growth-manager 未包含 `conversations`。

---

## 五、合理性评估

### ✅ 合理的目录

| 目录 | 理由 |
|------|------|
| `perception/` | 环境感知结果，符合「项目感知」语义 |
| `user_data/` | 用户偏好、配置，符合「用户相关」语义 |
| `ai/` | AI 状态、编排、学习数据集中存放 |
| `analytics/` | Token、缓存、分析数据 |
| `monitoring/` | 日志、监控 |
| `integrations/` | 第三方同步、MCP 配置 |
| `conversations/` | 对话记录 |
| `ai/command_logs/` | 命令执行审计 |
| `ai/agent-data/` | Agent 配置 |
| `ai/task-states/` | 任务状态 |
| `ai/training_data/` | 学习数据 |

### ⚠️ 需关注的问题

| 问题 | 影响 | 建议 |
|------|------|------|
| `ai-conversations` vs `conversations` | cursor-sync 使用 `ai-conversations`，path-config 只有 `conversations` | 统一为 `conversations/`，或显式增加 `ai-conversations` 并文档化 |
| `ai-profile.json` 多位置 | 根目录、`ai/`、`AI_METRICS_DIR` 均有写入 | 统一为 `ai/metrics/ai-profile.json` |
| `GROWTH_METRICS_DIR` 未定义 | 可能导致写入失败或路径错误 | 在 path-config 中定义，如 `export GROWTH_METRICS_DIR="$MONITORING_DIR"` 或 `"$AI_DIR/metrics"` |
| `project_data/` | 规范中有，实际使用较少 | 确认是否有脚本写入，若无可保留作扩展 |
| `agent-trees/` | 未见显式创建逻辑 | 可能由 agent 编排内部逻辑创建，需在编排模块中确认 |

### ❌ 明确的缺陷

1. **GROWTH_METRICS_DIR 未定义**：`growth-manager.sh`、`growth-recorder.sh`、`cursor-master.sh` 依赖该变量，path-config 未导出，存在运行风险。
2. **ai-profile.json 写入位置不一致**：至少三处写入（根目录、growth-manager、growth-recorder），易产生冲突与混淆。
3. **growth-manager STANDARD_DIRS 缺少 conversations**：与 path-config 不一致，可能导致 `conversations` 未被创建。

---

## 六、迁移脚本兼容性

`migrate-extra-directories.sh` 的迁移映射：

| 旧路径 | 新路径 |
|--------|--------|
| `.cursorGrowth/cache/skills` | `ai/cache` |
| `.cursorGrowth/skills/loaded` | `ai/skills` |
| `.cursorGrowth/logs` | `monitoring/logs` |
| `.cursorGrowth/pids` | `monitoring/pids` |

与当前规范一致，迁移逻辑合理。

---

## 七、修复建议优先级（已实施）

1. **高**：在 `path-config.sh` 中定义 `GROWTH_METRICS_DIR`（建议 `$MONITORING_DIR` 或 `$AI_DIR/metrics`）。
2. **高**：统一 `ai-profile.json` 写入路径为 `ai/metrics/ai-profile.json`，并移除根目录写入。
3. **中**：在 `growth-manager.sh` 的 STANDARD_DIRS 中补充 `conversations`。
4. **中**：统一 cursor-sync 的对话存储路径为 `conversations/`，废弃 `ai-conversations` 或明确其用途。
5. **低**：补充 `agent-trees` 的创建逻辑与文档说明。

---

*分析完成时间：2026-02-24*
