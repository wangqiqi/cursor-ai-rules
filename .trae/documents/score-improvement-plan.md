# 项目评分提升计划

## 目标

从 **7.65 分** 提升至 **8.5 分**，针对四大短板精准优化。

| 维度 | 当前 | 目标 | 提升 |
|------|:----:|:----:|:----:|
| 🧪 测试覆盖 | 5.5 | 7.0 | +1.5 |
| 📝 代码质量 | 7.0 | 8.0 | +1.0 |
| 📖 文档质量 | 7.5 | 8.5 | +1.0 |
| 🚀 用户体验 | 8.5 | 9.0 | +0.5 |

---

## 任务分解

### 任务 A：补充 agent-orchestration 系列测试（🧪 +1.0）

为 25 个 agent-orchestration 文件中最核心的函数补充 bats 风格测试。

**涉及文件**：
- `agent-orchestration-core.sh` — submit_task, assign_task_to_agent, add_task_to_queue
- `agent-orchestration-engine.sh` — 入口流程
- `agent-orchestration-scheduler.sh` — select_optimal_agent

**方案**：新建 `.cursor-extras/tests/test-agent-orchestration.sh`，对关键函数进行：
- 语法检查
- 函数存在性检查
- 核心逻辑的黑盒测试

### 任务 B：消除扩展层颜色变量重复（📝 +0.5）

扩展层中约 30+ 个脚本独立定义了颜色变量（RED/GREEN/YELLOW/BLUE/NC）。

**方案**：在 `.cursor-extras/core/` 中创建一个 `colors.sh` 统一颜色定义，其他脚本通过 source 引用，消除重复定义。

### 任务 C：补充 hooks 文档（📖 +0.5）

42 个钩子在 `hooks.json` 中有定义但没有独立文档。

**方案**：创建 `.cursor-extras/docs/developer/hooks-reference.md`，记录所有钩子的用途、触发条件、超时配置。

### 任务 D：添加 CI 配置（🧪/🚀 +0.5）

**方案**：创建 `.github/workflows/test.yml`，在 push/PR 时自动运行：
- 核心层测试（test-common.sh）
- 扩展层测试

### 任务 E：统一文档版本号 + 更新 plan.md（📝 +0.2）

**方案**：在 `.cursor/README.md` 中添加统一的版本号声明。

---

## 执行顺序

```
任务 A (测试) ──────────→ 并行
任务 B (颜色统一) ───────→ 并行
任务 C (hooks 文档) ─────→ 并行
任务 D (CI) ────────────→ 并行
任务 E (版本号) ─────────→ 并行

验证 ──→ 运行所有测试 ──→ 完成
```

所有任务无依赖，可并行执行。
