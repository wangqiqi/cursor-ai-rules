# Cursor Agent Skills 使用指南

> 对齐 [Cursor Agent Skills 官方文档](https://cursor.com/cn/docs/skills)（2026-06 起本仓库全量采用官方包结构）。

## 架构一览

```text
.cursor/skills/<skill-name>/          # Cursor 自动发现（Agent Decides）
├── SKILL.md                          # 必填：name + description
├── references/
│   └── full-guide.md                 # 完整工作流（渐进式披露）
├── scripts/                          # 可选：可执行脚本
└── assets/                           # 可选：模板与静态资源

.cursor/features/skills/skills/
└── registry.json                     # Master / skills-loader 元数据索引（package、guide）
```

**45** 个技能包（43 个 registry 项 + `master` + `skill-dispatcher`）。历史扁平 `.md` 已归档至 `archive/*_skills_legacy_md/`。

## 与旧版「双目录」的区别

| 以前 | 现在 |
|------|------|
| 正文在 `features/skills/skills/*.md` | 正文在 `.cursor/skills/*/references/full-guide.md` |
| Cursor 难以自动发现 | 每个包独立 `SKILL.md`，Settings → Rules → Agent Decides 可见 |
| `skill-dispatcher` 扫扁平目录 | `list-skills.sh` 扫描 `.cursor/skills` |

## 如何使用

### 1. 让 Agent 自动选用

在对话中描述任务；Agent 根据各技能 `description` 判断是否加载对应 `SKILL.md`。

### 2. 显式引用

在对话中说明领域，或使用 Master：

```text
/master skill:api-design
/master skill:webapp-testing
```

### 3. 列出技能

```bash
bash .cursor/skills/skill-dispatcher/scripts/list-skills.sh
find .cursor/skills -name SKILL.md
```

### 4. 合规检查

```bash
bash .cursor/scripts/verify-skills.sh
bash .cursor/scripts/polish-skills-best-practice.py   # 批量抛光 description / Related
```

## 开发新技能

1. 创建目录 `.cursor/skills/<name>/`（`name` 仅 `a-z0-9-`，与文件夹同名）。
2. 编写 `SKILL.md`：

```yaml
---
name: my-skill
description: Clear English sentence. Use when ...
---

# My Skill

Short summary (under ~100 lines). Point to references/ for detail.
```

3. 将详细步骤放入 `references/full-guide.md`。
4. 在 `registry.json` 的 `skills.legacy` 中增加索引项（`package`、`guide`、`canonical_id`）。
5. 运行 `verify-skills.sh`。

## registry.json 字段

> **版本号别搞混**：`registry.json` 顶部的 `"version": "2.0.0"` 是**注册表 schema 版本**（条目结构约定），不是 Cursor 插件发版号。插件/仓库发版号见根目录 `CHANGELOG.md` 与 `.cursor-plugin/plugin.json`；README 标题的「核心版 v2.0.0」是产品线品牌版本。

| 字段 | 含义 |
|------|------|
| `package` | `.cursor/skills/<canonical>/SKILL.md` |
| `guide` | `.cursor/skills/<canonical>/references/full-guide.md` |
| `canonical_id` | 官方目录名（连字符） |
| `legacy_path` | 归档前的扁平文件名（只读历史） |

## 相关资源

- 调度器：`.cursor/skills/skill-dispatcher/SKILL.md`
- Master：`.cursor/skills/master/SKILL.md`
- 计划与验收：`plan.md` Phase 5
- 变更记录：`CHANGELOG.md`（发版号以首条为准）
