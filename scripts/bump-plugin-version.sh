#!/usr/bin/env bash
# Set .cursor-plugin/plugin.json version from CHANGELOG.md top entry.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/.cursor-plugin/plugin.json"
CHANGELOG="$REPO_ROOT/CHANGELOG.md"

command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }
[[ -f "$CHANGELOG" ]] || { echo "CHANGELOG.md not found" >&2; exit 1; }

ver="$(grep -m1 '^## \[' "$CHANGELOG" | sed 's/^## \[\([^]]*\)\].*/\1/')"
tmp="$(mktemp)"
jq --arg v "$ver" '.version = $v' "$MANIFEST" > "$tmp"
mv "$tmp" "$MANIFEST"
echo "✅ plugin.json version → $ver"
