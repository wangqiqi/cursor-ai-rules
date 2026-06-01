---
description: "当用户使用 /master 时确保 .cursorGrowth 目录存在"
alwaysApply: true
priority: 20
---

# 🌱 /master 命令前置：.cursorGrowth 目录保障

## 触发条件

当用户输入包含 `/master` 时，必须执行以下前置步骤。

## 必须执行

1. **检查** `.cursorGrowth` 目录是否存在
2. **若不存在**，运行：`bash .cursor/features/automation/scripts/growth_init.sh`
3. **然后再**继续处理用户的 /master 请求

## 执行方式

使用 `run_terminal_cmd` 执行上述脚本，无需等待用户确认。
