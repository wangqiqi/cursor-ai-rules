#!/usr/bin/env bash
# 可复现：测试 token-compression.sh 对真实文本的字符/token 变化
# 需要: bash, python3；可选 pip install tiktoken

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT="$ROOT" CURSOR_DIR="$ROOT/.cursor"
export CONFIG_DATA_DIR="$ROOT/.cursorGrowth/user/config"
export ANALYTICS_DIR="$ROOT/.cursorGrowth/analytics"
export LOGS_DIR="$ROOT/.cursorGrowth/logs"
export PERCEPTION_DIR="$ROOT/.cursorGrowth/perception"
export USER_DATA_DIR="$ROOT/.cursorGrowth/user"
mkdir -p "$CONFIG_DATA_DIR" "$ANALYTICS_DIR/cache" "$LOGS_DIR"

compress_level() {
  local level="$1"
  local data="$2"
  COMPRESSION_LEVEL="$level" bash -c '
    export PROJECT_ROOT="'"$ROOT"'" CURSOR_DIR="'"$ROOT/.cursor"'"
    export CONFIG_DATA_DIR="'"$CONFIG_DATA_DIR"'" ANALYTICS_DIR="'"$ANALYTICS_DIR"'" LOGS_DIR="'"$LOGS_DIR"'"
    export PERCEPTION_DIR="'"$PERCEPTION_DIR"'" USER_DATA_DIR="'"$USER_DATA_DIR"'"
    source "'"$ROOT"'/.cursor/core/compact-output.sh"
    source "'"$ROOT"'/.cursor/core/performance-cache.sh"
    source "'"$ROOT"'/.cursor/core/token-compression.sh"
    compress_tokens "$(cat)"
  ' <<<"$data"
}

USE_TIKTOKEN=0
python3 -c "import tiktoken" 2>/dev/null && USE_TIKTOKEN=1

count_tokens() {
  local text="$1"
  if [[ "$USE_TIKTOKEN" -eq 1 ]]; then
    python3 -c "import tiktoken; print(len(tiktoken.get_encoding('cl100k_base').encode(open(0).read())))" <<<"$text"
  else
    echo $(( ${#text} / 4 ))
  fi
}

bench_file() {
  local label="$1" file="$2" max_bytes="${3:-12000}"
  local data
  data="$(head -c "$max_bytes" "$file")"
  echo ""
  echo "========== $label ($(wc -c <<<"$data" | awk '{print $1}') bytes) =========="
  local t0
  t0=$(count_tokens "$data")
  echo "  original: ~$t0 tokens ($([ "$USE_TIKTOKEN" -eq 1 ] && echo tiktoken || echo chars/4))"
  for level in minimal balanced aggressive maximum; do
    local out t1 pct
    out=$(compress_level "$level" "$data")
    t1=$(count_tokens "$out")
    pct=$(awk -v a="$t0" -v b="$t1" 'BEGIN { if (a>0) printf "%.1f", (1-b/a)*100; else print "0" }')
    echo "  [$level] ~$t1 tokens (${pct}% vs original)"
  done
}

echo "Token compression benchmark — $(date -Iseconds)"
echo ""

bench_file "CHANGELOG.md" "$ROOT/CHANGELOG.md" 12000
bench_file "constitution.mdc" "$ROOT/.cursor/rules/core/constitution.mdc" 8000
bench_file "README.md" "$ROOT/.cursor/README.md" 6000

echo ""
echo "See .cursor/docs/reference/TOKEN_COMPRESSION_BENCHMARK.md"
