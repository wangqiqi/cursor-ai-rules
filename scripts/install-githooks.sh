#!/usr/bin/env bash
# Point this repo's Git hooks at .githooks/ (verify plugin manifest on .cursor/ changes).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

git config core.hooksPath .githooks
chmod +x .githooks/pre-commit scripts/verify-plugin-manifest.sh scripts/bump-plugin-version.sh
echo "✅ core.hooksPath=.githooks (pre-commit verifies .cursor-plugin → .cursor/)"
