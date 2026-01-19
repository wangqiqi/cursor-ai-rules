#!/bin/bash

# 🎭 角色同步脚本
# 强制同步项目角色到当前对话框
# 这是一个高优先级的同步机制

SYNC_LOG="/tmp/cursor-role-sync-$USER.log"

log() {
    echo "[ROLE-SYNC] $(date '+%H:%M:%S') $*" >> "$SYNC_LOG"
    echo "[ROLE-SYNC] $*" >&2
}

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

# 再次向上查找项目根目录
if [[ ! -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
fi

log "开始角色同步检查..."

# 检查项目角色配置
if [[ -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    ROLE=$(grep -o '"currentRole"\s*:\s*"[^"]*"' "$PROJECT_ROOT/.cursor-project.json" | sed 's/.*"currentRole"\s*:\s*"\([^"]*\)".*/\1/')

    if [[ -n "$ROLE" ]]; then
        log "检测到项目角色: $ROLE"

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
        log "⚠️ 项目角色配置无效"
        echo "项目角色配置无效"
        exit 1
    fi
else
    log "⚠️ 未找到项目角色配置"
    echo "未找到项目角色配置"
    exit 1
fi

log "角色同步检查完成"
exit 0