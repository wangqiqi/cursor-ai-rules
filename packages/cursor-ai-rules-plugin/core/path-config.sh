#!/bin/bash
# Cursor AI Rules - 统一路径配置（核心版）
# 零外部依赖，自动检测项目根目录
# 复制 .cursor/ 到任意项目即可使用

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find_project_root() {
    local current_dir="$(pwd)"
    PROJECT_ROOT="$current_dir"
    while [[ "$PROJECT_ROOT" != "/" ]]; do
        if [[ -d "$PROJECT_ROOT/.git" ]]; then
            break
        fi
        PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
    done
    if [[ "$PROJECT_ROOT" == "/" ]]; then
        PROJECT_ROOT="$current_dir"
    fi
    CURSOR_DIR="$PROJECT_ROOT/.cursor"
}

find_project_root

export PROJECT_ROOT
export CURSOR_DIR
