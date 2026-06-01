# Cursor AI Rules — 项目计划 (plan.md)

> 运行时以 `.cursor/` + 根目录 `AGENTS.md` 为准。插件与复制**共用同一 `.cursor/`**（单仓库）。

---

## Phase 6：双轨分发（单仓库）

**目标**：`.cursor/` 保持复制开箱即用；`.cursor-plugin/plugin.json` 指向 `.cursor/`，无需 `packages/` 副本。

### 待办任务清单 — Phase 6

- [x] **Task 6.1–6.4** 初版 `packages/` 同步方案 [superseded]
- [x] **Task 6.10: 单仓库重构** — 根 `.cursor-plugin/plugin.json` → `.cursor/`；删除 `packages/` [completed]
- [x] **Task 6.6–6.9** CI verify、hooks、release、文档 [completed，已改为 manifest 校验]
- [ ] **Task 6.5: 提交 Cursor 插件市场** [pending，见 docs/MARKETPLACE_SUBMIT.md]

### 维护命令

```bash
bash scripts/verify-plugin-manifest.sh
bash scripts/bump-plugin-version.sh    # 与 CHANGELOG 对齐版本
bash scripts/install-githooks.sh       # 可选
```

---

## Phase 5（已完成）

见 CHANGELOG `[4.7.0]`–`[4.7.2]`。45 个官方技能包、registry 指向 `.cursor/skills`。

---

## 讨论与决策记录

- **2026-06-01 (Phase 6 单仓库)**：放弃 `packages/` 双份树；插件安装 = 链式克隆本仓库；权威源仅 `.cursor/`。
- **官方文档**: https://cursor.com/docs/skills | https://cursor.com/docs/plugins/building
