---
name: refactoring-tools
description: Safe refactors, structure improvements, and technical debt reduction. Use when restructuring code without behavior change.
---

# Refactoring Tools

提供智能代码重构能力，包括方法提取、变量重命名、类重构、架构优化等高级重构操作，支持安全的重构执行和质量保证。

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:refactoring-tools` when the project uses the command center.

## Related

- Package root: `.cursor/skills/refactoring-tools/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
