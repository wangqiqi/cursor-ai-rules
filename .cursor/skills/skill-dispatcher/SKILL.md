---
name: skill-dispatcher
description: Discover and route to project skills under .cursor/skills. Use when matching tasks to skills or listing available skills.
---

# Skill Dispatcher

Official [Agent Skills](https://cursor.com/cn/docs/skills) entry point for this project.

## Canonical layout

| Layer | Path | Role |
|-------|------|------|
| **Cursor discovers** | `.cursor/skills/<name>/SKILL.md` | Required `name` + `description`; optional `paths`, `scripts/`, `references/` |
| **This dispatcher** | `.cursor/skills/skill-dispatcher/` | Match tasks to skill packages |
| **Registry index** | `.cursor/features/skills/skills/registry.json` | Metadata for Master/skills-loader; not used for Cursor auto-discovery |

Always prefer **`.cursor/skills/*/SKILL.md`**. For full workflows, read **`references/full-guide.md`** inside the matched skill folder.

## When to use

- User asks what skills exist or which skill fits a task
- Multiple domains apply (e.g. API + security + tests)
- Routing `/master skill:<name>` or explicit skill invocation

## Discovery (official)

```bash
# List all Cursor-discoverable skill packages
find .cursor/skills -name SKILL.md

# Or use the helper script (relative to skill-dispatcher/)
scripts/list-skills.sh
```

Parse each `SKILL.md` frontmatter: `name`, `description`, optional `paths`.

## Matching workflow

1. Extract intent and tech context from the user message.
2. Score skills by `description` relevance and optional `paths` vs open files.
3. Pick the best match; load that skill's `SKILL.md`, then `references/full-guide.md` if needed.
4. Run `scripts/` in that skill directory with paths relative to the skill root.

## Registry index (optional)

`registry.json` maps registry keys to `package` and `guide` paths under `.cursor/skills/`. See **`references/operator-manual.md`** for matching tables.

## Related

- Package root: `.cursor/skills/skill-dispatcher/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
