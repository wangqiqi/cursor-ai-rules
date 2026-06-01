# Skill Dispatcher — Operator Manual

> **Current layout (2026-06+)**: All skills live under **`.cursor/skills/<name>/SKILL.md`**.  
> Full workflows are in **`references/full-guide.md`** per package.  
> **`registry.json`** only indexes `package` / `guide` paths for Master and `skills-loader.sh`.

---

## Canonical paths

| What | Path |
|------|------|
| Cursor-discoverable skill | `.cursor/skills/<name>/SKILL.md` |
| Full workflow body | `.cursor/skills/<name>/references/full-guide.md` |
| List packages | `bash .cursor/skills/skill-dispatcher/scripts/list-skills.sh` |
| Registry metadata | `.cursor/features/skills/skills/registry.json` |
| Verify compliance | `bash .cursor/scripts/verify-skills.sh` |

Registry keys with underscores map to hyphen folders (e.g. `python_mcp_server` → `python-mcp-server`).

---

## Discovery workflow

1. Scan `.cursor/skills/*/SKILL.md` (or run `list-skills.sh`).
2. Parse frontmatter: `name`, `description`, optional `paths`.
3. Score by user intent vs `description` and open files vs `paths`.
4. Load matched `SKILL.md`, then `references/full-guide.md` for detailed steps.
5. Optional: cross-check `registry.json` for `category`, `dependencies`, Master routing.

---

## Matching examples

| User intent | Likely skill |
|-------------|----------------|
| API design / OpenAPI | `api-design` |
| Playwright / E2E UI | `webapp-testing` |
| MCP server in Python | `python-mcp-server` |
| Security audit | `security-analysis` |
| Full stack feature | `fullstack-development` |

---

## Master integration

- `/master skill:<canonical-name>` — route to a skill package
- Subagent: `mcp_task(subagent_type: "master", ...)`
- Prelude: ensure `.cursorGrowth` exists (`growth_init.sh`)

---

## Historical note

Flat `.md` files formerly under `.cursor/features/skills/skills/` were archived to `archive/*_skills_legacy_md/`. Do not reference `*.md` paths under `features/skills/skills/` in new docs or SKILL frontmatter.
