# team-experience — 团队经验沉淀

与 `.cursor/` 同级的 **`.cursorGrowth/team-experience/`**，用于存放可复用的 **`.mdc` 规则**（非修改 `.cursor/rules` 主树）。

## 目录

| 路径 | 说明 |
|------|------|
| `rules/` | 已采纳规则（Cursor 与桥接规则会加载） |
| `inbox/` | 大模型草案，确认后移至 `rules/` |
| `manifest.json` | 元数据：作者、日期、来源 commit/CHANGELOG、status |

## 工作流

1. `/master 沉淀规则` 或启用 **team-experience** 技能  
2. 将 `CHANGELOG.md`、`git log`、对话上下文交给大模型归纳（**不**用脚本解析）  
3. 草案 → `inbox/` → 确认 → `rules/` + 更新 `manifest.json`

## Git 共享（可选）

根目录 `.gitignore` 已白名单本目录，团队可只提交 `team-experience/` 以共享经验。

## 桥接

加载逻辑见：`.cursor/rules/workflow/growth-team-experience-bridge.mdc`
