# Changelog

所有对本项目的 notable 变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [4.7.4] - 2026-06-01

### Added

- **`scripts/check-plugin-package-drift.sh`** — CI/发版前检测 `packages/` 是否与 `.cursor/` 同步。
- **`.githooks/pre-commit`** + **`scripts/install-githooks.sh`** — 改 `.cursor/` 时自动 sync 并 stage 插件包。
- **`.github/workflows/release.yml`** — `v*` tag 打包 `cursor-ai-rules-plugin-*.tar.gz` 并创建 GitHub Release。
- **`docs/MARKETPLACE_SUBMIT.md`** — Cursor 插件市场上架自检清单。

### Changed

- **CI**：`test.yml` 增加 jq、漂移检查；`verify-plugin-package.sh` 校验版本与 CHANGELOG 一致。
- **文档**：`README.en.md`、`getting-started.md`、`faq.md`、`ROADMAP.md`、`.cursor/docs/README.md`、`SYSTEM_ARCHITECTURE.md`、`extension-guide.md` 双轨说明。

### Tests

- `bash scripts/check-plugin-package-drift.sh` — 通过
- `bash scripts/verify-plugin-package.sh` — 版本与 CHANGELOG 一致 (4.7.4)

## [4.7.3] - 2026-06-01

### Added

- **双轨分发（Phase 6）**：`packages/cursor-ai-rules-plugin/` — Cursor 插件包（rules/skills/agents/commands/hooks/core），由 `scripts/sync-plugin-package.sh` 从 `.cursor/` 同步；`scripts/verify-plugin-package.sh` 校验。
- **`.cursor-plugin/plugin.json`** — 本地/市场插件清单（`~/.cursor/plugins/local/cursor-ai-rules` 可链式安装）。
- **根 README**：「复制 `.cursor/`」与「插件安装」并列说明。
- **CI**：`test.yml` 增加插件包同步与校验步骤。

### Changed

- 合并 **[4.7.2] 文档清扫**（见下方条目）：开发文档与 Agent 说明统一官方技能路径。

### Tests

- `bash .cursor/tests/test-common.sh` — **107/107**
- `bash scripts/verify-plugin-package.sh` — 通过

## [4.7.2] - 2026-06-01

### Changed

- **文档清扫**：`.cursor/docs`、`agents`、`skill-dispatcher` 文档与 `ROADMAP.md` 等统一为 `.cursor/skills/<name>/` 官方路径；移除对已废弃 `features/skills/skills/*.md` 的运行时引用说明。
- **`.cursor/scripts/docs-sweep-skills-paths.py`** — 可重复执行的文档路径清扫脚本。

## [4.7.1] - 2026-06-01

### Changed

- **Skills 最佳实践抛光**：45 个 `SKILL.md` 的 `description` 统一为英文「能力 + Use when…」；`Related` 节标准化，移除对已废弃扁平 `features/skills/skills/*.md` 的引用。
- **skill-dispatcher**：`operator-manual.md` 重写为官方路径；`SKILL.md` 表格与 Registry 说明更新。
- **SKILL_GUIDE.md**：改为以 `.cursor/skills/` 为主的官方架构说明。
- **verify-skills.sh**：禁止 SKILL 内引用 legacy `.md`；校验 description 含英文关键词。

### Added

- **`.cursor/scripts/polish-skills-best-practice.py`** — 可重复执行的技能抛光脚本。

## [4.7.0] - 2026-06-01

### Changed

- **Agent Skills 全量迁移（Phase 5 完成）**：`registry.json` 全部 **43** 项迁入 `.cursor/skills/<canonical>/`（`canonical_id` 小写连字符；含 `reference/*` 与下划线键如 `python_mcp_server` → `python-mcp-server`）；每项含 `SKILL.md` + `references/full-guide.md`。
- **registry.json**：新增 `package`、`guide`、`canonical_id`、`legacy_path`；`path` 改为 `skills/...` 索引；标记 `deprecated_flat_md`。
- **skills-loader.sh**：优先从 `guide` / `package` 加载官方技能包正文。
- **skill-dispatcher** / **master**：保留精简 `SKILL.md`；P0 共 8 个技能保留既有英文 `description` 正文。

### Added

- **45 个 Cursor 可发现技能包**（43 registry + `master` + `skill-dispatcher`）。
- **`.cursor/scripts/verify-skills.sh`**、**`migrate-skills-to-official.py`**（全量 registry 驱动）；`test-common.sh` 测试组 7。

### Removed

- **legacy 扁平 `.md`**：自 `features/skills/skills/` 删除（已归档至 `archive/20260601_224608_skills_legacy_md/`）。

### Tests

- `bash .cursor/scripts/verify-skills.sh` — **45** 包全部通过
- `bash .cursor/tests/test-common.sh` — **106/106** 通过

## [4.6.3] - 2026-06-01

### Changed

- **规则官方化对齐**：76 个 `.mdc` 交叉引用统一为 `@规则名`（去除 `.md`/`.mdc` 后缀）；`rules-router` 架构图改为 `.mdc`；`module-monitor` / `module_manager` 移除已废弃 `RULE.md` 目录布局说明，改为 Cursor Project Rules 标准；更新 `RULE_ACTIVATION_FLOW.md`。

### Removed

- **冗余规则 `.md`**: 删除与同名 `.mdc` 重复的 `eslint.md`、`vibe-coding.md`、`javascript.md`（Cursor 会忽略无 frontmatter 的 `.md`）。

### Fixed

- **`constitution.mdc` 及全量 `.mdc` frontmatter**: 修复 `priority: N---` 粘连，闭合 `---` 分隔符（共 76 个规则文件）。
- **`unified-check.sh`**: 规则统计改为 `*.mdc`；技能统计改为 `.cursor/skills/*/SKILL.md`；避免零规则时除零。

### Added

- **Cursor 标准技能包** (`.cursor/skills/`): 新增 9 个目录（`master`、`api-design`、`backend-development`、`webapp-testing`、`mcp-builder`、`security-analysis`、`test-automation`、`fullstack-development`、`code-analysis`），与既有 `skill-dispatcher` 共 **10** 个可发现技能；正文引用 `.cursor/features/skills/skills/*.md`。

### Tests

- `bash .cursor/tests/run-verify-test.sh` — 通过
- `bash .cursor/tests/test-agent-orchestration.sh` — **33/33** 通过

## [4.6.2] - 2026-06-01

### Fixed

- **logging-common.sh**：修复 `\"` 误转义导致在仓库根创建带 `"` 的畸形目录及 `event.log"` 文件名；日志正确写入 `.cursor/monitoring/logs/hooks/`。
- **command-log.sh**：改为委托 `logging-common.sh`，修复未加引号的重定向与错误的 `source` 路径。
- **test-common.sh**：宪法规则改为检查 `.mdc`；jq/node 检查仅限引导脚本，不再对全部 `core/*.sh` 误报（消除 55 项假失败）。

### Added

- **unified-check.sh**：Hook 脚本路径引号防回归检查。
- **.gitignore**：忽略 `.cursor/monitoring/` 运行时目录。

## [4.6.1] - 2026-06-01

### Changed

- **README.en.md**: 英文长文档迁至 `.cursor/README.en.md`，根目录软链改为 `.cursor/README.en.md`。
- **CI** (`.github/workflows/test.yml`): 测试改为 `.cursor/tests/test-agent-orchestration.sh` 与 `run-verify-test.sh`，不再引用已删除的 `.cursor-extras/`。
- **运行时补齐**: 自原扩展层迁入 `commands/capability-maps/`、`verify-system.sh`、`features/hooks/hooks.json`（hooks-engine）、`docs/`、`config/`、`plugins/` 等至 `.cursor/`。

### Fixed

- **verify-system / unified-check.sh**: 修正 `SCRIPT_DIR` 在 `source colors.sh` 之前未定义导致的验证失败。

### Removed

- **`.cursor-extras/`**: Phase 3 收尾后整目录删除；运行时唯一入口为 `.cursor/`。说明见 `archive/20260601_222100_cursor-extras_官方对齐收尾说明.md`。

## [4.6.0] - 2026-06-01

### Changed

- **100% 对齐 Cursor 官方目录规范（Phase 2）**: 规则迁移为 `.cursor/rules/**/*.mdc`（76 个，含 `constitution.mdc`）；技能迁至 `.cursor/skills/skill-dispatcher/SKILL.md`；子代理迁至 `.cursor/agents/{master,command-center}.md`；项目根新增 `AGENTS.md`。
- **Hooks 官方 schema**: 新增 `.cursor/hooks.json`（`version: 1`），标准事件名 `sessionStart` / `sessionEnd` / `beforeSubmitPrompt` / `afterFileEdit` / `afterShellExecution` / `afterAgentResponse`；钩子脚本置于 `.cursor/hooks/`，`command` 相对项目根，`timeout` 单位为秒，`failClosed` 按安全级别配置。
- **路径自洽**: `.cursor/` 树内脚本、规则、技能路径统一为 `.cursor/`；核心 shell 与 `features/skills` 注册表并入 `.cursor/core` 与 `.cursor/features/`。

### Added

- **开箱即用**: 复制 `.cursor/` + 根目录 `AGENTS.md` 即可被 Cursor 自动发现 Rules、Skills、Subagents、Hooks。

### Note

- v4.6.1 起已移除 `.cursor-extras/`；历史分层说明见 CHANGELOG `4.5.x` 与 `archive/`。

## [4.5.1] - 2026-06-01

### Fixed

- **README 英文版软链接**: 修复了 `README.en.md` 的错误软链接，将其重定向到正确的相对路径 `.cursor/README.en.md`，经验证文件完全可读。
- **路径一致性扫描与批量修复**: 针对核心层 `.cursor/` 精简后导致的 59 个失效路径引用，在全仓 51 个文本文件（包括 `.cursor/AGENTS.md`、`.cursor/rules/master-skill.md`、`plan.md` 等）中进行了高精度的批量文本替换，使路径引用恢复完全自洽。经最终扫描验证，全仓已无悬挂失效引用。

## [4.5.0] - 2026-06-01

### Changed

- **核心-扩展分层架构** (2026-06-01): 将 `.cursor/` 精简为核心层（11 个文件），新增 `.cursor-extras/` 扩展层（374 文件）按需复制；核心层零外部依赖（无 jq/node/openssl）。
- **扩展层路径统一** (2026-06-01): `.cursor-extras/` 内 40+ 脚本改为引用 `.cursor/core/path-config.sh` 与 `colors.sh`，消除与核心层的路径配置重复。
- **日志与入口规范** (2026-06-01): 统一 `logging.sh` 函数命名（`log_warning`/`log_success`）；入口脚本统一 `set -euo pipefail`。
- **代码去重** (2026-06-01): 消除 24 个 agent-orchestration 样板重复；29 个文件颜色变量迁移至 `colors.sh`。
- **README 精简** (2026-06-01): 简化 `.cursor/README.md` 为一页快速入门。

### Added

- **集成测试** (2026-06-01): 核心层 22 用例 + Agent Orchestration 33 用例；统一技能分类映射（补 21 个缺失项）。
- **CI 与文档** (2026-06-01): GitHub Actions 测试工作流；36 个 hooks 参考文档；系统组件交互文档。
- **技能工具归位** (2026-06-01): `converter.sh` / `discovery.sh` 迁至 `.cursor/core/`。

### Fixed

- **配置写入** (2026-06-01): `common.sh` 中 `save_config_file` 错误处理不再默认强制退出。
- **环境变量** (2026-06-01): `init.sh` heredoc 单引号→双引号，修复变量未展开。
- **Hooks** (2026-06-01): 修复 `hooks.json` 中 `growth-directory-check` copy-paste 错误。

### Removed

- **扩展层冗余** (2026-06-01): 删除 `.cursor-extras/` 内重复的 `LICENSE`、`hooks.json`、`web/`、`patterns.json`、`stop-web.sh` 及旧版 skills 工具路径。

## [4.4.1] - 2026-05-27

### Added

- **仓库性质说明** (2026-05-27): 在 `README.md` / `README.en.md` 增加「本仓库是什么 / 不是什么」说明，澄清非托管多 Agent 服务、并行配置与 `reference/` 文档用途，便于回应第三方扫描或调研误读。
- **reference 目录说明** (2026-05-27): 新增 `.cursor/skills/skill-dispatcher/README.md`，标明 SDK 参考文档为静态副本、非运行时组件。

## [Unreleased]

### Changed

- **精简 Master 入口** (2026-03-08): 删除冗余的 master 技能，保留 master-skill 规则。Master 等效能力现为：命令 + 子代理 + 规则（三者）。
- **批量修复** (2026-03-08): 全项目 `@master`→`/master`、`@vibe`→`/vibe` 替换；修正 vibe-coding 规则引用；精简 master-skill 规则，以子代理为唯一实现。

### Added

- **master subagent** (2026-03-08): 新增 `.cursor/agents/master.md`，Master 专用子代理，通过 `mcp_task(subagent_type: "master", ...)` 调用。
- **master-skill 规则** (2026-03-08): 新增 `.cursor/rules/master-skill.md`，实现与 `/master` 命令相同的效果和功能。
