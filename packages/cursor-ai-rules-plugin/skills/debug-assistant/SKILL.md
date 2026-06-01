---
name: debug-assistant
description: Systematic debugging, root-cause analysis, and fix verification. Use when investigating bugs, failures, or unexpected behavior.
---

# Debug Assistant

Intelligent debugging assistant using isolation and pattern analysis techniques. Supports module isolation testing, error pattern recognition, and safe batch error fixing.

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:debug-assistant` when the project uses the command center.

## Related

- Package root: `.cursor/skills/debug-assistant/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
