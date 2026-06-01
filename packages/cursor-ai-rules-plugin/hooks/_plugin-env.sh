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
