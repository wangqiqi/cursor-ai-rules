---
name: documentation-tools
description: Author and maintain technical documentation, READMEs, and API docs. Use when writing or restructuring project docs.
---

# Documentation Tools

提供智能文档生成功能，支持代码注释分析、API文档自动生成、技术文档撰写、文档质量检查等，帮助开发者维护高质量的文档体系。

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:documentation-tools` when the project uses the command center.

## Related

- Package root: `.cursor/skills/documentation-tools/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
