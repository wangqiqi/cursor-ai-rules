# Changelog

所有对本项目的 notable 变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

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
- **技能工具归位** (2026-06-01): `converter.sh` / `discovery.sh` 迁至 `.cursor-extras/core/`。

### Fixed

- **配置写入** (2026-06-01): `common.sh` 中 `save_config_file` 错误处理不再默认强制退出。
- **环境变量** (2026-06-01): `init.sh` heredoc 单引号→双引号，修复变量未展开。
- **Hooks** (2026-06-01): 修复 `hooks.json` 中 `growth-directory-check` copy-paste 错误。

### Removed

- **扩展层冗余** (2026-06-01): 删除 `.cursor-extras/` 内重复的 `LICENSE`、`hooks.json`、`web/`、`patterns.json`、`stop-web.sh` 及旧版 skills 工具路径。

## [4.4.1] - 2026-05-27

### Added

- **仓库性质说明** (2026-05-27): 在 `README.md` / `README.en.md` 增加「本仓库是什么 / 不是什么」说明，澄清非托管多 Agent 服务、并行配置与 `reference/` 文档用途，便于回应第三方扫描或调研误读。
- **reference 目录说明** (2026-05-27): 新增 `.cursor/features/skills/reference/README.md`，标明 SDK 参考文档为静态副本、非运行时组件。

## [Unreleased]

### Changed

- **精简 Master 入口** (2026-03-08): 删除冗余的 master 技能，保留 master-skill 规则。Master 等效能力现为：命令 + 子代理 + 规则（三者）。
- **批量修复** (2026-03-08): 全项目 `@master`→`/master`、`@vibe`→`/vibe` 替换；修正 vibe-coding 规则引用；精简 master-skill 规则，以子代理为唯一实现。

### Added

- **master subagent** (2026-03-08): 新增 `.cursor/agents/master.md`，Master 专用子代理，通过 `mcp_task(subagent_type: "master", ...)` 调用。
- **master-skill 规则** (2026-03-08): 新增 `.cursor/rules/master-skill.md`，实现与 `/master` 命令相同的效果和功能。
