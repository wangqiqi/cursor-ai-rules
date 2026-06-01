#!/usr/bin/env bash
# Verify single-repo Cursor plugin: .cursor-plugin/plugin.json → .cursor/*

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/.cursor-plugin/plugin.json"
FAIL=0

check() {
  if [[ "$1" -eq 0 ]]; then
    echo "✅ $2"
  else
    echo "❌ $2"
    FAIL=$((FAIL + 1))
  fi
}

[[ -f "$MANIFEST" ]] && check 0 "plugin.json exists" || check 1 "plugin.json exists"

if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq not installed — skipping JSON checks"
  exit 0
fi

name="$(jq -r '.name // empty' "$MANIFEST")"
[[ "$name" == "cursor-ai-rules" ]] && check 0 "plugin name" || check 1 "plugin name"

resolve_path() {
  local rel="$1"
  rel="${rel#./}"
  echo "$REPO_ROOT/$rel"
}

for key in rules skills agents commands; do
  rel="$(jq -r ".[\"$key\"] // empty" "$MANIFEST")"
  dir="$(resolve_path "$rel")"
  [[ -d "$dir" ]] && check 0 "path $key → $rel" || check 1 "path $key → $rel (missing)"
done

hooks_rel="$(jq -r '.hooks // empty' "$MANIFEST")"
hooks_file="$(resolve_path "$hooks_rel")"
[[ -f "$hooks_file" ]] && check 0 "hooks → $hooks_rel" || check 1 "hooks → $hooks_rel (missing)"

rules_count="$(find "$REPO_ROOT/.cursor/rules" -name '*.mdc' 2>/dev/null | wc -l)"
skills_count="$(find "$REPO_ROOT/.cursor/skills" -name 'SKILL.md' 2>/dev/null | wc -l)"
[[ "$rules_count" -ge 70 ]] && check 0 "rules count >= 70 ($rules_count)" || check 1 "rules count >= 70 ($rules_count)"
[[ "$skills_count" -ge 40 ]] && check 0 "skills count >= 40 ($skills_count)" || check 1 "skills count >= 40 ($skills_count)"

if jq -r '.. | objects | select(has("command")) | .command' "$hooks_file" 2>/dev/null | grep -qE '^\.cursor/'; then
  check 0 "hook commands use .cursor/ (single-repo layout)"
else
  check 1 "hook commands should use .cursor/ paths in single-repo mode"
fi

if [[ -f "$REPO_ROOT/CHANGELOG.md" ]]; then
  changelog_ver="$(grep -m1 '^## \[' "$REPO_ROOT/CHANGELOG.md" | sed 's/^## \[\([^]]*\)\].*/\1/')"
  plugin_ver="$(jq -r '.version // empty' "$MANIFEST")"
  if [[ -n "$changelog_ver" && "$changelog_ver" == "$plugin_ver" ]]; then
    check 0 "version matches CHANGELOG ($plugin_ver)"
  else
    check 1 "version matches CHANGELOG (plugin=$plugin_ver changelog=$changelog_ver)"
  fi
fi

[[ -f "$REPO_ROOT/AGENTS.md" ]] && check 0 "AGENTS.md at repo root" || check 1 "AGENTS.md at repo root"

if [[ "$FAIL" -gt 0 ]]; then
  echo "❌ Plugin manifest verification failed ($FAIL errors)"
  exit 1
fi
echo "✅ Single-repo plugin manifest OK (.cursor/ is the only source tree)"
