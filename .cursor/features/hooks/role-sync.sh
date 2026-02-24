#!/bin/bash

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
# 项目持久化状态路径（.cursorGrowth/user/config/project_state.json）
PROJECT_STATE="$PROJECT_ROOT/.cursorGrowth/user/config/project_state.json"
LEGACY_STATE="$PROJECT_ROOT/.cursor-project.json"

# 迁移：旧文件存在且新文件不存在时迁移
if [[ -f "$LEGACY_STATE" && ! -f "$PROJECT_STATE" ]]; then
    mkdir -p "$(dirname "$PROJECT_STATE")"
    cp "$LEGACY_STATE" "$PROJECT_STATE" 2>/dev/null && rm -f "$LEGACY_STATE" 2>/dev/null || true
fi
# 读取路径：优先新路径
STATE_FILE="$PROJECT_STATE"
[[ -f "$STATE_FILE" ]] || STATE_FILE="$LEGACY_STATE"

log "开始角色同步检查..."

# 确保项目角色配置存在
if [[ ! -f "$STATE_FILE" ]]; then
    mkdir -p "$(dirname "$PROJECT_STATE")"
    default_config="{
  \"currentRole\": \"professional_assistant\",
  \"lastUpdated\": \"$(date -Iseconds)\",
  \"projectPath\": \"$PROJECT_ROOT\"
}"
    echo "$default_config" > "$PROJECT_STATE"
    log "✅ 创建默认项目角色配置: professional_assistant"
    ROLE="professional_assistant"
else
    ROLE=$(grep -o '"currentRole"\s*:\s*"[^"]*"' "$STATE_FILE" 2>/dev/null | sed 's/.*"currentRole"\s*:\s*"\([^"]*\)".*/\1/' 2>/dev/null)
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