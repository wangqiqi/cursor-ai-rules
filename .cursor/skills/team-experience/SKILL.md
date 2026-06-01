---
name: team-experience
description: Turn CHANGELOG, git history, and incident dialogue into team rules under .cursorGrowth/team-experience (LLM-only, no parsing). Use for 沉淀规则, 团队经验, 从 changelog 学习, 反复出现的 bug.
---

# Team Experience（团队经验沉淀）

将 **Git 历史 + CHANGELOG + 当前踩坑经过** 交给大模型归纳，输出 `.mdc` 写入 `.cursorGrowth/team-experience/`，由桥接规则加载，**不修改** `.cursor/rules` 主树。

## When to use

- 同一类 bug 反复出现，希望固化为规则  
- 发版后希望从 `CHANGELOG.md` 提炼教训  
- 用户说：沉淀、团队经验、不要再犯、写成规则  

## Required prelude

1. `bash .cursor/core/team-experience-init.sh`（或 `growth_init.sh`）  
2. 阅读 **`references/workflow.md`** 与 **`references/prompt-template.md`**

## Steps（不解析，只采集文本）

1. 运行（可选，仅拼接原文）：  
   `bash .cursor/skills/team-experience/scripts/collect-context.sh`  
2. 将输出 + 用户叙述 + 桥接规则要求，按 prompt 模板请大模型生成：  
   - 完整 `.mdc` 内容  
   - `manifest.json` 的新 `entries` 项  
3. 默认写入 `inbox/<slug>.mdc`；用户确认后移至 `rules/<slug>.mdc` 并更新 manifest。  
4. **禁止** 写入 `.cursor/rules/`（除已存在的桥接文件）。

## Related

| 资源 | 路径 |
|------|------|
| 桥接规则 | `.cursor/rules/workflow/growth-team-experience-bridge.mdc` |
| 沉淀目录 | `.cursorGrowth/team-experience/` |
| Master | `/master skill:team-experience` |
