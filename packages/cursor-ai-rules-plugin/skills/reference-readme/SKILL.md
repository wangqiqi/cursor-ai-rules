---
name: reference-readme
description: Navigate MCP reference documentation and README conventions. Use when locating official MCP reference material.
---

# Reference Readme

Bundled documentation for Cursor skills (not executed at runtime).

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:reference-readme` when the project uses the command center.

## Related

- Package root: `.cursor/skills/reference-readme/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
