---
name: code-formatting
description: Format and style code consistently across languages and linters. Use when standardizing style, applying formatters, or fixing lint noise.
---

# Code Formatting

提供智能代码格式化能力，支持多种编程语言和格式化工具，自动检测项目配置并应用一致的代码风格。

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:code-formatting` when the project uses the command center.

## Related

- Package root: `.cursor/skills/code-formatting/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
