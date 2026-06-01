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

## Do not copy

`.cursorGrowth/`, `.cursor-plugin/`, `scripts/`, `docs/`, `CHANGELOG.md`, `archive/`, etc.

## Plugin

```bash
ln -sfn "$(pwd)" ~/.cursor/plugins/local/cursor-ai-rules
```

Restart Cursor. Marketplace checklist: [docs/MARKETPLACE_SUBMIT.md](docs/MARKETPLACE_SUBMIT.md).
