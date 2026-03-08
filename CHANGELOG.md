# Changelog

所有对本项目的 notable 变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [Unreleased]

### Added

- **master-skill 规则** (2026-03-08): 新增 `.cursor/rules/master-skill.md`，实现与 `/master` 命令相同的效果和功能。当用户未使用 `/master` 但表达类似需求时，AI 将采用 Master 的完整处理流程，包括意图解析、智能路由、规则/技能/脚本调用、21 种 AI 人格支持。优先通过 mcp_task 调用 command-center 子 agent 执行。
