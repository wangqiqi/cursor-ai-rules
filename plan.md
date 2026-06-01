# Cursor AI Rules — 项目计划 (plan.md)

> 运行时以 `.cursor/` + 根目录 `AGENTS.md` 为准。历史 Phase 1–4 已完成，见文末讨论记录。

---

## Phase 5：Agent Skills 官方标准对齐

**目标**：与 [Cursor Agent Skills 官方文档](https://cursor.com/cn/docs/skills) 一致——`.cursor/skills/<name>/SKILL.md` 自包含、`name`/`description` 合规、详细内容进 `references/`，Cursor 可自动发现全部常用技能。

**现状摘要**（2026-06-01 审计）：

| 项 | 数量 |
|----|------|
| 官方可发现包（`.cursor/skills/*/SKILL.md`） | **45**（43 registry + master + skill-dispatcher） |
| legacy 扁平 `.md` | 已归档至 `archive/*_skills_legacy_md/` |
| `skill-dispatcher` 主文件 | 已精简（~52 行 + references/） |

### 待办任务清单 — Phase 5

- [x] **Task 5.1: 技能合规验证脚本** — `verify-skills.sh` + 接入 `test-common.sh` [completed]
- [x] **Task 5.2: 重构 skill-dispatcher** — 主 `SKILL.md` 精简；`references/operator-manual.md`；`list-skills.sh` 扫描 `.cursor/skills` [completed]
- [x] **Task 5.3: 迁移 8 个已登记技能（P0）** — `references/full-guide.md` + 标准 `SKILL.md` [completed]
- [x] **Task 5.4: 迁移高频 legacy 技能（P1）** [completed 2026-06-01]
- [x] **Task 5.5: 迁移其余 legacy 技能（P2 + reference/*）** [completed 2026-06-01]
- [x] **Task 5.6: 统一 registry.json** — `package` / `guide` / `canonical_id` 指向 `.cursor/skills`；`skills-loader.sh` 优先加载 guide [completed]
- [x] **Task 5.7: 归档与清理** — `archive/20260601_224608_skills_legacy_md/`；`features/skills/skills/` 仅保留 `registry.json` [completed]
- [x] **Task 5.8: 全量验证** — `verify-skills.sh` 45 包、`test-common.sh` **106/106** [completed]
- [x] **Task 5.9: 最佳实践抛光** — 英文 `description`、`SKILL_GUIDE` / `operator-manual`、`polish-skills-best-practice.py` [completed 2026-06-01]
- [x] **Task 5.10: 文档清扫** — `docs-sweep-skills-paths.py`；更新 CALL_CHAIN / SYSTEM_ARCHITECTURE / agents / ROADMAP 等 [completed 2026-06-01]

### 官方标准技能包模板（Task 5.1 产出）

```text
.cursor/skills/<skill-name>/
├── SKILL.md              # 必填：name, description；可选 paths, disable-model-invocation
├── references/           # 可选：详细文档（按需 Read）
│   └── full-guide.md
├── scripts/              # 可选：可执行脚本
└── assets/               # 可选：模板/静态资源
```

**SKILL.md 最小 frontmatter**：

```yaml
---
name: <skill-name>          # 必须与目录名一致，仅 a-z0-9-
description: <何时使用>    # Agent 用于相关性判断
paths:                      # 可选；留空=全局可用
  - "**/*.tsx"
---
```

### P1 技能清单（Task 5.4）

`frontend-design`, `debug-assistant`, `learning-assistant`, `git-management`, `documentation-tools`, `code-formatting`, `optimization-tools`, `performance-analysis`, `refactoring-tools`, `system-analysis`, `api-testing`, `vulnerability-scanning`

### P2 技能清单（Task 5.5）

`algorithmic-art`, `brand-guidelines`, `canvas-design`, `doc-coauthoring`, `docx`, `pptx`, `pdf`, `xlsx`, `internal-comms`, `slack-gif-creator`, `theme-factory`, `web-artifacts-builder`, `skill-creator`, `ssr-optimization`, `code-examples`, 及 `reference/*` 附属文档

### 验收标准

1. Cursor Settings → Rules → Agent Decides 可列出 **≥43** 个技能（或 Phase 5 完成后的目标数量）
2. 任意技能目录不含 `alwaysApply`/`globs`/`priority`（Rules 专用字段）
3. 无「仅见 `.cursor/features/skills/...`」的薄包装 `SKILL.md`
4. `bash .cursor/scripts/verify-skills.sh` 退出码 0

---

## 历史 Phase（已完成）

### Phase 1–4

见 Git 历史与 `CHANGELOG.md` `[4.6.0]`–`[4.6.3]`。

### Phase 4 讨论记录

- **2026-06-01**: 规则 `.mdc` 官方化、`@规则名` 无后缀、删除重复 `.md` 规则；10 个技能薄包装就位。

---

## Phase 6：双轨分发（复制 + 插件包）

**目标**：同一仓库维护 `.cursor/`（复制开箱即用）与 `packages/cursor-ai-rules-plugin/`（Cursor 本地/市场插件），由脚本同步，避免双份手写漂移。

### 待办任务清单 — Phase 6

- [x] **Task 6.1: `scripts/sync-plugin-package.sh`** — rsync rules/skills/agents/commands/core/hooks [completed]
- [x] **Task 6.2: `scripts/verify-plugin-package.sh` + `.cursor-plugin/plugin.json`** [completed]
- [x] **Task 6.3: 根 README 双安装说明 + `packages/.../README.md`** [completed]
- [x] **Task 6.4: CI 接入 sync + verify** [completed]
- [x] **Task 6.5: 市场上架清单** — `docs/MARKETPLACE_SUBMIT.md`（人工向 Cursor 提交）[completed]
- [x] **Task 6.6: CI 漂移检查** — `scripts/check-plugin-package-drift.sh` [completed]
- [x] **Task 6.7: 文档双轨同步** — README.en / getting-started / faq / ROADMAP / docs README / SYSTEM_ARCHITECTURE / extension-guide [completed]
- [x] **Task 6.8: Git hooks** — `.githooks/pre-commit` + `scripts/install-githooks.sh` [completed]
- [x] **Task 6.9: Release workflow** — `.github/workflows/release.yml`（tag `v*` 打包插件） [completed]

### 同步命令

```bash
bash scripts/sync-plugin-package.sh
bash scripts/verify-plugin-package.sh
bash scripts/check-plugin-package-drift.sh   # CI / 发版前
bash scripts/install-githooks.sh             # 维护者可选
```

---

## 讨论与决策记录

- **2026-06-01 (Phase 6)**: 插件包放在本仓 `packages/cursor-ai-rules-plugin/`，不另建仓库；hooks 路径由 jq 从 `.cursor/hooks.json` 转换。
- **2026-06-01 (Phase 5 启动)**: 采用「SKILL.md 精简 + references/full-guide.md」策略，避免单文件超 500 行；保留 `registry.json` 作 Master 路由索引，路径指向 `.cursor/skills`。
- **官方文档**: https://cursor.com/cn/docs/skills | https://cursor.com/docs/plugins/building
