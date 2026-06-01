#!/bin/bash
# 验证 .cursor/skills 符合 Cursor Agent Skills 官方标准
# https://cursor.com/cn/docs/skills

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_ROOT="$CURSOR_DIR/skills"
errors=0

err() { echo "✗ $1"; errors=$((errors + 1)); }
ok() { echo "✓ $1"; }

echo "Cursor Agent Skills 合规检查: $SKILLS_ROOT"
echo ""

if [[ ! -d "$SKILLS_ROOT" ]]; then
  err "技能根目录不存在: $SKILLS_ROOT"
  exit 1
fi

mapfile -t skill_files < <(find "$SKILLS_ROOT" -name 'SKILL.md' | sort)
total=${#skill_files[@]}

if [[ $total -eq 0 ]]; then
  err "未找到任何 SKILL.md"
  exit 1
fi

for skill_md in "${skill_files[@]}"; do
  dir=$(dirname "$skill_md")
  folder=$(basename "$dir")
  rel=${skill_md#$CURSOR_DIR/}

  if ! head -1 "$skill_md" | grep -q '^---$'; then
    err "$rel: 缺少 frontmatter"
    continue
  fi

  fm=$(awk '/^---$/{c++; next} c==1' "$skill_md")

  name=$(echo "$fm" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//;s/^["'\'']//;s/["'\'']$//')
  desc=$(echo "$fm" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//')

  if [[ -z "$name" ]]; then
    err "$rel: 缺少 name"
  elif [[ "$name" != "$folder" ]]; then
    err "$rel: name=$name 与目录 $folder 不一致"
  elif ! [[ "$name" =~ ^[a-z0-9-]+$ ]]; then
    err "$rel: name 含非法字符（仅允许 a-z0-9-）"
  else
    ok "$rel: name 合法"
  fi

  if [[ -z "$desc" ]]; then
    err "$rel: 缺少 description"
  fi

  if echo "$fm" | grep -qE '^(alwaysApply|globs|priority):'; then
    err "$rel: 含 Rules 专用 frontmatter（应使用 paths，非 globs/alwaysApply）"
  fi

  if grep -qE 'features/skills/skills/[^`]*\.md' "$skill_md"; then
    err "$rel: 仍引用已废弃的扁平 legacy .md 路径"
  fi

  desc_en=$(echo "$desc" | grep -cE '[A-Za-z]{4,}' || true)
  if [[ "$desc_en" -lt 1 ]]; then
    err "$rel: description 应含清晰英文说明（便于 Agent 匹配）"
  fi

  body_lines=$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2' "$skill_md" | wc -l)
  if [[ $body_lines -lt 8 ]]; then
    err "$rel: 正文过短（${body_lines} 行），可能仅为外链包装"
  fi
done

echo ""
echo "共检查 $total 个技能包"
if [[ $errors -gt 0 ]]; then
  echo "失败: $errors"
  exit 1
fi
echo "全部通过"
exit 0
