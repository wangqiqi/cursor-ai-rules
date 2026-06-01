#!/bin/bash
# ========================================
# Cursor AI Rules - Agent 编排公共加载模块
# 提供统一的路径配置和工具函数加载，消除代码重复
# 所有 agent-orchestration-*.sh 文件都应 source 此文件
# ========================================

# 统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 兼容核心层和扩展层两种目录结构
if [ -f "$SCRIPT_DIR/path-config.sh" ]; then
    source "$SCRIPT_DIR/path-config.sh"
elif [ -f "$SCRIPT_DIR/../.cursor/core/path-config.sh" ]; then
    source "$SCRIPT_DIR/../.cursor/core/path-config.sh"
elif [ -f "$SCRIPT_DIR/../../.cursor/core/path-config.sh" ]; then
    source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"
fi

# 恢复 SCRIPT_DIR（因为 path-config.sh 可能覆盖了它）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/compact-output.sh"
