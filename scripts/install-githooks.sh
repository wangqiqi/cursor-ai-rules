#!/usr/bin/env bash
# Point this repo's Git hooks at .githooks/ (maintainer workflow for plugin sync).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
echo "✅ core.hooksPath=.githooks (pre-commit will sync packages/ when .cursor/ changes)"
