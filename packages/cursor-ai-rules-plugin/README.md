# Cursor AI Rules — Marketplace / Local Plugin Package

> **Synced artifact** — do not edit rules/skills/agents here by hand.  
> Run from repository root: `bash scripts/sync-plugin-package.sh`

## Install

### Cursor local plugin (development)

```bash
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)/packages/cursor-ai-rules-plugin" ~/.cursor/plugins/local/cursor-ai-rules
```

Restart Cursor. Components load globally for all workspaces.

### Cursor marketplace (future)

Submit `packages/cursor-ai-rules-plugin` (or this repo with `plugin.json` path) per [Cursor Plugins Building](https://cursor.com/docs/plugins/building).

## vs copy `.cursor/` (full runtime)

| Capability | Copy `.cursor/` + `AGENTS.md` | This plugin |
|------------|-------------------------------|-------------|
| Rules (`.mdc`) | ✅ | ✅ |
| Skills (`SKILL.md`) | ✅ | ✅ |
| Agents / Commands | ✅ | ✅ (handler JS bundled) |
| Hooks + `core/` scripts | ✅ project paths | ✅ plugin-relative paths |
| `.cursorGrowth` / per-project state | ✅ workspace | ✅ workspace (unchanged) |

For **maximum** parity (custom project hooks, local tests), still use root [README.md](../../README.md) copy install.

## Optional: project `AGENTS.md`

```bash
cp packages/cursor-ai-rules-plugin/templates/AGENTS.md ./AGENTS.md
```

## Maintainer workflow

```bash
bash scripts/sync-plugin-package.sh
bash scripts/check-plugin-package-drift.sh
bash scripts/install-githooks.sh   # optional: auto-sync on commit
```

## Sync manifest

See `SYNC_MANIFEST.json` for last sync time and version.

Marketplace checklist: [docs/MARKETPLACE_SUBMIT.md](../../docs/MARKETPLACE_SUBMIT.md).
