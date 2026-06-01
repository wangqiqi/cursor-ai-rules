#!/usr/bin/env bash
# Sync .cursor/ → packages/cursor-ai-rules-plugin/ for Cursor marketplace / local plugin install.
# Run from repository root: bash scripts/sync-plugin-package.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_CURSOR="$REPO_ROOT/.cursor"
PKG_ROOT="$REPO_ROOT/packages/cursor-ai-rules-plugin"
PLUGIN_META="$PKG_ROOT/.cursor-plugin"

if [[ ! -d "$SRC_CURSOR/rules" ]]; then
  echo "❌ Missing $SRC_CURSOR — run from cursor-ai-rules repository root." >&2
  exit 1
fi

echo "📦 Syncing plugin package → $PKG_ROOT"

mkdir -p "$PLUGIN_META" "$PKG_ROOT/hooks" "$PKG_ROOT/core" "$PKG_ROOT/scripts" "$PKG_ROOT/templates"

# --- Rules, skills, agents, commands ---
rsync -a --delete \
  "$SRC_CURSOR/rules/" "$PKG_ROOT/rules/"

rsync -a --delete \
  "$SRC_CURSOR/skills/" "$PKG_ROOT/skills/"

rsync -a --delete \
  "$SRC_CURSOR/agents/" "$PKG_ROOT/agents/"

rsync -a --delete \
  --exclude='capability-maps' \
  "$SRC_CURSOR/commands/" "$PKG_ROOT/commands/"

rsync -a --delete \
  "$SRC_CURSOR/commands/capability-maps/" "$PKG_ROOT/commands/capability-maps/"

# --- Core (hooks depend on ../../core from .cursor/hooks → ../core from plugin/hooks) ---
rsync -a --delete \
  "$SRC_CURSOR/core/" "$PKG_ROOT/core/"

# --- Growth init ---
GROWTH_SRC="$SRC_CURSOR/features/automation/automation/scripts/growth_init.sh"
if [[ -f "$GROWTH_SRC" ]]; then
  cp "$GROWTH_SRC" "$PKG_ROOT/scripts/growth_init.sh"
  chmod +x "$PKG_ROOT/scripts/growth_init.sh"
fi

# --- Hooks: copy + patch paths ---
rsync -a --delete \
  "$SRC_CURSOR/hooks/" "$PKG_ROOT/hooks/"

# Remove project-only hooks.json if present in hooks dir
rm -f "$PKG_ROOT/hooks/hooks.json" 2>/dev/null || true

patch_hook_script() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  [[ "$(basename "$f")" == "_plugin-env.sh" ]] && return 0

  sed -i \
    -e 's|\.\./\.\./\.\./\.cursor/core|../core|g' \
    -e 's|\.\./\.\./core|../core|g' \
    -e 's|\$SCRIPT_DIR/\.\./automation/scripts/growth_init\.sh|\$SCRIPT_DIR/../scripts/growth_init.sh|g' \
    -e 's|\$SCRIPT_DIR/\.\./\.\./automation/scripts/growth_init\.sh|\$SCRIPT_DIR/../scripts/growth_init.sh|g' \
    -e 's|\.cursor/features/automation/automation/scripts/growth_init\.sh|./scripts/growth_init.sh|g' \
    "$f"

  if head -1 "$f" | grep -q '^#!' && ! grep -q '_plugin-env.sh' "$f"; then
    local tmp
    tmp="$(mktemp)"
    {
      head -1 "$f"
      echo '# shellcheck disable=SC1091'
      echo 'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"'
      echo 'source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true'
      tail -n +2 "$f"
    } > "$tmp"
    mv "$tmp" "$f"
  fi
  chmod +x "$f"
}

cat > "$PKG_ROOT/hooks/_plugin-env.sh" << 'EOF'
#!/usr/bin/env bash
# Cursor AI Rules plugin — roots for hook/core when project has no .cursor/
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CAR_PLUGIN_ROOT="$(cd "$HOOK_DIR/.." && pwd)"
export CAR_PLUGIN_MODE=1

_pr="$(pwd)"
export PROJECT_ROOT="$_pr"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  if [[ -d "$PROJECT_ROOT/.git" ]]; then
    break
  fi
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
if [[ ! -d "${PROJECT_ROOT}/.cursor" ]]; then
  export CURSOR_DIR="${CAR_PLUGIN_ROOT}"
else
  export CURSOR_DIR="${PROJECT_ROOT}/.cursor"
fi
EOF
chmod +x "$PKG_ROOT/hooks/_plugin-env.sh"

while IFS= read -r -d '' hook; do
  patch_hook_script "$hook"
done < <(find "$PKG_ROOT/hooks" -maxdepth 1 -name '*.sh' -print0)

# --- Generate hooks/hooks.json from project .cursor/hooks.json ---
PROJECT_HOOKS="$SRC_CURSOR/hooks.json"
PLUGIN_HOOKS="$PKG_ROOT/hooks/hooks.json"

if [[ -f "$PROJECT_HOOKS" ]] && command -v jq >/dev/null 2>&1; then
  jq '
    .description = "Cursor AI Rules — plugin hooks (synced from .cursor/hooks.json)"
    | walk(
        if type == "object" and has("command") and (.command | type) == "string" then
          .command |= (
            gsub("^\\.cursor/hooks/"; "./hooks/")
            | gsub("^\\.cursor/core/"; "./core/")
            | gsub("^\\.cursor/features/automation/automation/scripts/growth_init\\.sh$"; "./scripts/growth_init.sh")
          )
        else . end
      )
  ' "$PROJECT_HOOKS" > "$PLUGIN_HOOKS"
else
  echo "⚠️  jq not found — copying hooks.json with sed fallback" >&2
  sed \
    -e 's|\.cursor/hooks/|./hooks/|g' \
    -e 's|\.cursor/core/|./core/|g' \
    -e 's|\.cursor/features/automation/automation/scripts/growth_init.sh|./scripts/growth_init.sh|g' \
    "$PROJECT_HOOKS" > "$PLUGIN_HOOKS"
fi

# --- templates ---
cp "$REPO_ROOT/AGENTS.md" "$PKG_ROOT/templates/AGENTS.md"

# --- plugin.json version from CHANGELOG ---
VERSION="4.7.1"
if [[ -f "$REPO_ROOT/CHANGELOG.md" ]]; then
  ver="$(grep -m1 '^## \[' CHANGELOG.md | sed 's/^## \[\([^]]*\)\].*/\1/')" || true
  [[ -n "$ver" ]] && VERSION="$ver"
fi

mkdir -p "$PLUGIN_META"
cat > "$PLUGIN_META/plugin.json" << EOF
{
  "name": "cursor-ai-rules",
  "displayName": "Cursor AI Rules",
  "version": "${VERSION}",
  "description": "Constitution-driven AI pair programming: 70+ rules, 45+ skills, Master/VIBE commands, and optional hooks. Dual install: copy .cursor/ or install this plugin.",
  "author": {
    "name": "wangqiqi",
    "email": "zhou24388@163.com"
  },
  "homepage": "https://github.com/wangqiqi/cursor-ai-rules",
  "repository": "https://github.com/wangqiqi/cursor-ai-rules",
  "license": "MIT",
  "keywords": [
    "cursor-ai-rules",
    "rules",
    "skills",
    "master",
    "vibe",
    "constitution",
    "agent-skills"
  ],
  "skills": "./skills/",
  "rules": "./rules/",
  "agents": "./agents/",
  "commands": "./commands/",
  "hooks": "./hooks/hooks.json"
}
EOF

# Stamp sync manifest
cat > "$PKG_ROOT/SYNC_MANIFEST.json" << EOF
{
  "synced_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": ".cursor/",
  "version": "${VERSION}",
  "repository": "https://github.com/wangqiqi/cursor-ai-rules"
}
EOF

echo "✅ Plugin package synced (version ${VERSION})"
echo "   Local install: ln -sf \"$PKG_ROOT\" ~/.cursor/plugins/local/cursor-ai-rules"
echo "   Rules: $(find "$PKG_ROOT/rules" -name '*.mdc' 2>/dev/null | wc -l) | Skills: $(find "$PKG_ROOT/skills" -name 'SKILL.md' 2>/dev/null | wc -l)"
