#!/bin/bash

# 🎭 对话框初始化脚本
# 在每个新对话框开始时自动激活角色
# 这是一个独立的初始化脚本，确保角色激活的可靠性

CONVERSATION_INIT_MARKER="/tmp/cursor-ai-rules-conversation-init-$USER"

# 检查是否已经在这个对话框中初始化过
if [[ -f "$CONVERSATION_INIT_MARKER" ]]; then
    # 检查文件是否是今天的（避免过期的标记文件）
    if [[ $(find "$CONVERSATION_INIT_MARKER" -mtime -1 2>/dev/null) ]]; then
        echo "[对话框已初始化] $(date '+%H:%M:%S')" >&2
        exit 0
    fi
fi

echo "[对话框初始化] $(date '+%H:%M:%S')" >&2

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

# 再次向上查找项目根目录
if [[ ! -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
fi

# 确保项目角色配置存在
if [[ ! -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    # 创建默认的项目配置文件
    local default_config="{
  \"currentRole\": \"professional_assistant\",
  \"lastUpdated\": \"$(date -Iseconds)\",
  \"projectPath\": \"$PROJECT_ROOT\"
}"
    echo "$default_config" > "$PROJECT_ROOT/.cursor-project.json"
    echo "[创建默认配置] professional_assistant $(date '+%H:%M:%S')" >&2
fi

# 读取项目角色配置
ROLE=$(grep -o '"currentRole"\s*:\s*"[^"]*"' "$PROJECT_ROOT/.cursor-project.json" 2>/dev/null | sed 's/.*"currentRole"\s*:\s*"\([^"]*\)".*/\1/' 2>/dev/null)

if [[ -n "$ROLE" ]]; then
    echo "[角色激活] $ROLE $(date '+%H:%M:%S')" >&2

    # 调用角色激活脚本
    bash "$SCRIPT_DIR/role-activation.sh" "onConversationStart" "" 2>/dev/null || true

    # 标记已初始化
    touch "$CONVERSATION_INIT_MARKER"

    echo "[初始化完成] $(date '+%H:%M:%S')" >&2
    exit 0
else
    echo "[配置错误] $(date '+%H:%M:%S')" >&2
    exit 1
fi