# Team Experience 工作流

## 原则

- **不**用脚本解析 CHANGELOG/Git；脚本只 **读出原文**。
- **理解与生成的唯一执行者**：当前大模型。
- **落盘位置**：`.cursorGrowth/team-experience/`（固定名，跨项目一致）。
- **生效方式**：`growth-team-experience-bridge.mdc` 要求 Agent 读取 `rules/*.mdc`。

## manifest.json 条目示例

```json
{
  "id": "plugin-manifest-verify",
  "file": "rules/plugin-manifest-verify.mdc",
  "status": "active",
  "author": "zhangsan",
  "created_at": "2026-06-01",
  "source": "changelog@4.7.7; commits: 15be4f3",
  "summary": "改 plugin.json 后必须 verify-plugin-manifest"
}
```

`status`: `draft` | `active` | `deprecated`

## .mdc 写作要求

- `alwaysApply: false`，用窄 `globs`
- `priority` ≤ 12（低于桥接与宪法相关规则）
- 正文：现象 / 根因 / 必须 / 禁止 / 推荐做法

## 团队 Git

若需共享：只 commit `.cursorGrowth/team-experience/`（见根 `.gitignore` 白名单）。
