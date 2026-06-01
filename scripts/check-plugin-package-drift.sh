#!/usr/bin/env bash
# Fail if packages/cursor-ai-rules-plugin is out of sync with .cursor/ (run after sync-plugin-package.sh).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

bash scripts/sync-plugin-package.sh

# SYNC_MANIFEST.json only stores sync timestamp — exclude from drift compare
if git diff --quiet -- packages/cursor-ai-rules-plugin \
  ':(exclude)packages/cursor-ai-rules-plugin/SYNC_MANIFEST.json' 2>/dev/null; then
  echo "✅ packages/cursor-ai-rules-plugin is in sync with .cursor/"
  exit 0
fi

echo "❌ packages/cursor-ai-rules-plugin is OUT OF SYNC with .cursor/" >&2
echo "   Run: bash scripts/sync-plugin-package.sh && git add packages/cursor-ai-rules-plugin" >&2
echo "" >&2
git diff --stat -- packages/cursor-ai-rules-plugin \
  ':(exclude)packages/cursor-ai-rules-plugin/SYNC_MANIFEST.json' >&2 || true
exit 1
