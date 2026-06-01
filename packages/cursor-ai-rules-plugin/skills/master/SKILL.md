---
name: master
description: Master command center: intent routing, rules/skills orchestration, and 21 AI personas. Use when invoking /master or unified project orchestration.
---

# Master (Command Center)

Equivalent to `/master`: parse intent, route rules/skills/scripts, optional subagents.

## When to use

- User says「master」「命令中枢」「命令中心」
- Learning, creation, optimization, analysis, role switch
- Tasks needing skill-dispatcher or VIBE flows

## Required prelude

1. Ensure `.cursorGrowth` exists; if not:  
   `bash .cursor/features/automation/automation/scripts/growth_init.sh`
2. Prefer `mcp_task(subagent_type: "master", ...)` when available.

## Related paths

| Resource | Path |
|----------|------|
| Slash command | `.cursor/commands/master.md` |
| Subagent | `.cursor/agents/master.md` |
| Rule (no slash) | `.cursor/rules/master-skill.mdc` |
| Skill dispatcher | `.cursor/skills/skill-dispatcher/SKILL.md` |
| Capability maps | `.cursor/commands/capability-maps/` |

## Skill library (official)

Discover and load skills from **`.cursor/skills/<name>/SKILL.md`** (see [Agent Skills](https://cursor.com/cn/docs/skills)).

- List packages: `bash .cursor/skills/skill-dispatcher/scripts/list-skills.sh`
- Route via **skill-dispatcher** or `/master skill:<name>`
- Full guides: `references/full-guide.md` inside each skill folder
