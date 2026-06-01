# Installation Guide

See [INSTALL.md](INSTALL.md) for the full Chinese guide. Summary:

## Copy into your project (recommended)

```bash
cp -r cursor-ai-rules/.cursor /path/to/your-project/
cp    cursor-ai-rules/AGENTS.md /path/to/your-project/
cp    cursor-ai-rules/.cursorignore /path/to/your-project/
```

| Item | Purpose |
|------|---------|
| `.cursor/` | Rules, skills, commands, hooks, `core/` scripts |
| `AGENTS.md` | Agent entrypoints |
| `.cursorignore` | Shrinks `@codebase` index; **does not** remove `alwaysApply` rules from chat |

## Team experience (important)

Recurring bugs and release lessons → `.cursorGrowth/team-experience/rules/*.mdc`, loaded via bridge rule (main `.cursor/rules` tree unchanged). See [.cursor/README.en.md](.cursor/README.en.md) section **Team Experience** and skill `team-experience`.

```bash
bash .cursor/core/team-experience-init.sh
/master skill:team-experience
```

## Do not copy

`.cursorGrowth/`, `.cursor-plugin/`, `scripts/`, `docs/`, `CHANGELOG.md`, `archive/`, etc.

## Plugin

```bash
ln -sfn "$(pwd)" ~/.cursor/plugins/local/cursor-ai-rules
```

Restart Cursor. Marketplace checklist: [docs/MARKETPLACE_SUBMIT.md](docs/MARKETPLACE_SUBMIT.md).
