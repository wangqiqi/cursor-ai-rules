#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true

# 🎭 角色同步脚本
# 强制同步项目角色到当前对话框
# 这是一个高优先级的同步机制

TMP_BASE="${TMPDIR:-/tmp}"
SYNC_LOG="$TMP_BASE/cursor-role-sync-${USER:-default}.log"

log() {
    echo "[ROLE-SYNC] $(date '+%H:%M:%S') $*" >> "$SYNC_LOG"
    echo "[ROLE-SYNC] $*" >&2
}

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"
# 确保到达项目根（.cursor 的父目录）
[[ -d "$PROJECT_ROOT/.cursor" ]] || PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"

# 使用 shared-functions 统一的项目状态路径（含迁移逻辑）
source "$PROJECT_ROOT/.cursor/core/shared-functions.sh" 2>/dev/null || true
init_project_state_env "$PROJECT_ROOT" 2>/dev/null || {
    PROJECT_STATE_PATH="$PROJECT_ROOT/.cursorGrowth/user/config/project_state.json"
    PROJECT_STATE_READ_PATH="${PROJECT_STATE_PATH}"
    [[ -f "$PROJECT_STATE_PATH" ]] || PROJECT_STATE_READ_PATH="$PROJECT_ROOT/.cursor-project.json"
}

log "开始角色同步检查..."

# 确保项目角色配置存在
if [[ ! -f "$PROJECT_STATE_READ_PATH" ]]; then
    mkdir -p "$(dirname "$PROJECT_STATE_PATH")"
    default_config="{
  \"currentRole\": \"professional_assistant\",
  \"lastUpdated\": \"$(date -Iseconds)\",
  \"projectPath\": \"$PROJECT_ROOT\"
}"
    echo "$default_config" > "$PROJECT_STATE_PATH"
    log "✅ 创建默认项目角色配置: professional_assistant"
    ROLE="professional_assistant"
else
    ROLE=$(grep -o '"currentRole"\s*:\s*"[^"]*"' "$PROJECT_STATE_READ_PATH" 2>/dev/null | sed 's/.*"currentRole"\s*:\s*"\([^"]*\)".*/\1/' 2>/dev/null)
fi

if [[ -n "$ROLE" ]]; then
    log "激活项目角色: $ROLE"

    # 强制激活角色
    ROLE_MANAGER="$CURSOR_DIR/../commands/role-manager.js"
    if [[ -f "$ROLE_MANAGER" ]]; then
        cd "$PROJECT_ROOT" || exit 1
        RESULT=$(node "$ROLE_MANAGER" switch "$ROLE" "force_sync" 2>&1)

        if [[ $? -eq 0 ]]; then
            log "✅ 角色同步成功: $ROLE"
            echo "角色同步完成: $ROLE"
        else
            log "❌ 角色同步失败: $RESULT"
            echo "角色同步失败"
            exit 1
        fi
    else
        log "❌ 角色管理器不存在: $ROLE_MANAGER"
        echo "角色管理器不存在"
        exit 1
    fi
else
    log "⚠️ 无法确定角色配置"
    echo "无法确定角色配置"
    exit 1
fi

log "角色同步检查完成"
exit 0