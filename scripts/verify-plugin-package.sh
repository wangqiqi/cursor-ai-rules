#!/usr/bin/env bash
# Verify packages/cursor-ai-rules-plugin after sync-plugin-package.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG="$REPO_ROOT/packages/cursor-ai-rules-plugin"
PLUGIN_JSON="$PKG/.cursor-plugin/plugin.json"
FAIL=0

check() {
  if [[ "$1" -eq 0 ]]; then
    echo "✅ $2"
  else
    echo "❌ $2"
    FAIL=$((FAIL + 1))
  fi
}

[[ -f "$PLUGIN_JSON" ]] && check 0 "plugin.json exists" || check 1 "plugin.json exists"

if command -v jq >/dev/null 2>&1; then
  name="$(jq -r '.name // empty' "$PLUGIN_JSON")"
  [[ "$name" == "cursor-ai-rules" ]] && check 0 "plugin name" || check 1 "plugin name"
  for dir in rules skills agents commands; do
    [[ -d "$PKG/$dir" ]] && check 0 "directory $dir" || check 1 "directory $dir"
  done
  [[ -f "$PKG/hooks/hooks.json" ]] && check 0 "hooks/hooks.json" || check 1 "hooks/hooks.json"
  rules_count="$(find "$PKG/rules" -name '*.mdc' 2>/dev/null | wc -l)"
  skills_count="$(find "$PKG/skills" -name 'SKILL.md' 2>/dev/null | wc -l)"
  [[ "$rules_count" -ge 70 ]] && check 0 "rules count >= 70 ($rules_count)" || check 1 "rules count >= 70 ($rules_count)"
  [[ "$skills_count" -ge 40 ]] && check 0 "skills count >= 40 ($skills_count)" || check 1 "skills count >= 40 ($skills_count)"
  # Plugin hook commands must not reference .cursor/ paths
  if jq -r '.. | objects | select(has("command")) | .command' "$PKG/hooks/hooks.json" 2>/dev/null | grep -q '\.cursor/'; then
    check 1 "hook commands have no .cursor/ paths"
  else
    check 0 "hook commands have no .cursor/ paths"
  fi
else
  echo "⚠️  jq not installed — skipping JSON checks"
fi

[[ -f "$PKG/templates/AGENTS.md" ]] && check 0 "templates/AGENTS.md" || check 1 "templates/AGENTS.md"

if command -v jq >/dev/null 2>&1 && [[ -f "$REPO_ROOT/CHANGELOG.md" ]]; then
  changelog_ver="$(grep -m1 '^## \[' "$REPO_ROOT/CHANGELOG.md" | sed 's/^## \[\([^]]*\)\].*/\1/')"
  plugin_ver="$(jq -r '.version // empty' "$PLUGIN_JSON")"
  if [[ -n "$changelog_ver" && "$changelog_ver" == "$plugin_ver" ]]; then
    check 0 "version matches CHANGELOG ($plugin_ver)"
  else
    check 1 "version matches CHANGELOG (plugin=$plugin_ver changelog=$changelog_ver)"
  fi
fi

if [[ "$FAIL" -gt 0 ]]; then
  echo "❌ Plugin package verification failed ($FAIL errors)"
  exit 1
fi
echo "✅ Plugin package verification passed"
