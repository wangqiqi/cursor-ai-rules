# Changelog

所有对本项目的 notable 变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

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
