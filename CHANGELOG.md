# Changelog

所有对本项目的 notable 变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [Unreleased]

### Changed

- **精简 Master 入口** (2026-03-08): 删除冗余的 master 技能，保留 master-skill 规则。Master 等效能力现为：命令 + 子代理 + 规则（三者）。
- **批量修复** (2026-03-08): 全项目 `@master`→`/master`、`@vibe`→`/vibe` 替换；修正 vibe-coding 规则引用；精简 master-skill 规则，以子代理为唯一实现。

### Added

- **master subagent** (2026-03-08): 新增 `.cursor/agents/master.md`，Master 专用子代理，通过 `mcp_task(subagent_type: "master", ...)` 调用。
- **master-skill 规则** (2026-03-08): 新增 `.cursor/rules/master-skill.md`，实现与 `/master` 命令相同的效果和功能。
