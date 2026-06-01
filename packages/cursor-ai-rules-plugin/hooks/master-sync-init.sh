#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 🎯 Master同步初始化钩子 - 在新对话框开始时初始化同步状态
# 为每个对话框创建唯一标识符和同步标记

# 读取输入参数（JSON格式）
input=$(cat)

echo "🎯 新对话框Master同步初始化..." >&2

# 生成对话框唯一标识符（基于时间戳和随机数）
CONVERSATION_ID="$(date +%s)_$RANDOM"

# 获取项目路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

# 创建对话框标识符文件（使用 TMPDIR 保持跨平台兼容）
TMP_BASE="${TMPDIR:-/tmp}"
CONVERSATION_ID_FILE="$TMP_BASE/cursor-master-sync-conversation-${USER:-default}.id"
echo "$CONVERSATION_ID" > "$CONVERSATION_ID_FILE"

# 创建对话框同步标记文件
SYNC_MARKER_FILE="$TMP_BASE/cursor-master-sync-$CONVERSATION_ID.marker"
echo "ready" > "$SYNC_MARKER_FILE"

echo "✅ 对话框 $CONVERSATION_ID Master同步状态已初始化" >&2

# 返回原始输入，保持钩子链正常工作
echo "$input"