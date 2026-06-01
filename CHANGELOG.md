# Changelog

所有对本项目的 notable 变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

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
