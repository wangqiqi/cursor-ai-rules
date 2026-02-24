#!/bin/bash
# 🌱 Cursor beforeSubmitPrompt 钩子 - 确保 .cursorGrowth 存在
# 当用户在对话框输入任何内容（包括 /master）时自动创建目录
# Cursor 会读取 .cursor/hooks.json 并执行此脚本

set -e

# 读取 Cursor 传入的 JSON（必须保留并原样输出）
INPUT=$(cat)

# 获取项目根目录（从 workspace_roots 或当前目录）
PROJECT_ROOT=$(echo "$INPUT" | jq -r '.workspace_roots[0] // empty' 2>/dev/null)
if [[ -z "$PROJECT_ROOT" || "$PROJECT_ROOT" == "null" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"
CURSOR_DIR="$PROJECT_ROOT/.cursor"

# 确保 .cursorGrowth 存在
if [[ ! -d "$GROWTH_DIR" ]]; then
    if [[ -f "$CURSOR_DIR/features/automation/scripts/growth_init.sh" ]]; then
        cd "$PROJECT_ROOT" && bash "$CURSOR_DIR/features/automation/scripts/growth_init.sh" >/dev/null 2>&1 || true
    else
        mkdir -p "$GROWTH_DIR"/{perception,user/config,ai/agents,ai/tasks,ai/commands,ai/training,ai/cache,ai/metrics,ai/skills,analytics/cache,logs,integrations/sync,conversations}
        echo '{}' > "$GROWTH_DIR/.gitkeep"
    fi
else
    # 已存在：确保子目录完整
    for d in perception user/config ai/agents ai/tasks ai/commands ai/training ai/cache ai/metrics ai/skills analytics/cache logs integrations/sync conversations; do
        mkdir -p "$GROWTH_DIR/$d"
    done
fi

# 必须原样输出输入，保持钩子链
echo "$INPUT"
