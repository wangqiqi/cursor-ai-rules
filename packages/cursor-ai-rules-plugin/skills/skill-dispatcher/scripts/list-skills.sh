#!/bin/bash
# List Cursor Agent Skills under .cursor/skills (official discovery path)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# skill-dispatcher/scripts -> skill-dispatcher -> skills -> .cursor
CURSOR_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SKILLS_ROOT="$CURSOR_DIR/skills"
REGISTRY_FILE="$CURSOR_DIR/features/skills/skills/registry.json"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${CYAN}══════════════════════════════════════${NC}"
  echo -e "${CYAN}  Cursor Agent Skills (.cursor/skills)${NC}"
  echo -e "${CYAN}══════════════════════════════════════${NC}\n"
}

print_header

count=0
while IFS= read -r -d '' skill_md; do
  dir=$(dirname "$skill_md")
  name=$(basename "$dir")
  desc=$(awk '/^---$/{c++; next} c==1 && /^description:/{sub(/^description:[[:space:]]*/,""); gsub(/^["'\'']|["'\'']$/,""); print; exit}' "$skill_md")
  echo -e "${GREEN}• ${name}${NC}"
  echo "  ${desc:-(no description)}"
  echo "  $skill_md"
  count=$((count + 1))
done < <(find "$SKILLS_ROOT" -name 'SKILL.md' -print0 | sort -z)

echo -e "\n${GREEN}Total discoverable packages: ${count}${NC}"

if [[ -f "$REGISTRY_FILE" ]] && command -v jq >/dev/null 2>&1; then
  legacy=$(jq '[.skills | to_entries[] | .value | to_entries[] | .key] | length' "$REGISTRY_FILE" 2>/dev/null || echo "?")
  echo -e "${YELLOW}Legacy registry entries (may not be in .cursor/skills): ${legacy}${NC}"
  echo -e "${YELLOW}See plan.md Phase 5 for migration.${NC}"
fi
