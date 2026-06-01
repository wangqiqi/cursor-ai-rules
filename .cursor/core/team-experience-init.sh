#!/usr/bin/env bash
# 初始化 .cursorGrowth/team-experience/（团队可复用规则沉淀区）

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shared-functions.sh
source "$SCRIPT_DIR/shared-functions.sh"

PROJECT_ROOT="$(get_project_root_path)" || exit 1
export PROJECT_ROOT
validate_project_context || exit 1
GROWTH="$PROJECT_ROOT/.cursorGrowth"
TE="$GROWTH/team-experience"
TEMPLATE_ROOT="$PROJECT_ROOT/.cursor/templates/team-experience"

mkdir -p "$TE/rules" "$TE/inbox"

_copy_if_missing() {
  local src="$1" dest="$2"
  if [[ -f "$src" && ! -f "$dest" ]]; then
    cp "$src" "$dest"
  fi
}

if [[ -d "$TEMPLATE_ROOT" ]]; then
  _copy_if_missing "$TEMPLATE_ROOT/README.md" "$TE/README.md"
  _copy_if_missing "$TEMPLATE_ROOT/manifest.json" "$TE/manifest.json"
  _copy_if_missing "$TEMPLATE_ROOT/rules/_example.mdc" "$TE/rules/_example.mdc"
fi

if [[ ! -f "$TE/manifest.json" ]]; then
  cat >"$TE/manifest.json" <<'EOF'
{
  "version": "1.0.0",
  "description": "团队经验规则索引 — 与 rules/*.mdc 对应",
  "entries": []
}
EOF
fi

if [[ ! -f "$TE/README.md" ]]; then
  cat >"$TE/README.md" <<'EOF'
# team-experience

团队在多项目、多成员间共享的沉淀规则目录。正式规则放在 `rules/*.mdc`，草案放在 `inbox/`。

见 `.cursor/rules/workflow/growth-team-experience-bridge.mdc` 与技能 `team-experience`。
EOF
fi

touch "$TE/inbox/.gitkeep" "$TE/rules/.gitkeep" 2>/dev/null || true

echo "✅ team-experience 已就绪: $TE"
