---
name: internal-comms
description: Draft internal announcements, updates, and team communications. Use for status reports, memos, or internal messaging.
---

# Internal Comms

A set of resources to help me write all kinds of internal communications, using the formats that my company likes to use. Claude should use this skill whenever asked to write some sort of internal communications (status reports, leadership updates, 3P updates, company newsletters, FAQs, incident reports, project updates, etc.).

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:internal-comms` when the project uses the command center.

## Related

- Package root: `.cursor/skills/internal-comms/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
