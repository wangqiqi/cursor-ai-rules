#!/usr/bin/env bash
# 仅收集原文供大模型阅读 — 不做解析或归纳

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT"

echo "========== CHANGELOG.md =========="
if [[ -f CHANGELOG.md ]]; then
  cat CHANGELOG.md
else
  echo "(无 CHANGELOG.md)"
fi

echo ""
echo "========== git log --oneline -40 =========="
if git rev-parse --git-dir >/dev/null 2>&1; then
  git log --oneline -40 2>/dev/null || echo "(git log 失败)"
else
  echo "(非 git 仓库)"
fi

echo ""
echo "========== plan.md（若存在）=========="
[[ -f plan.md ]] && cat plan.md || echo "(无 plan.md)"

echo ""
echo ">>> 将以上全文交给大模型，按 team-experience/references/prompt-template.md 生成 .mdc 与 manifest 条目。"
