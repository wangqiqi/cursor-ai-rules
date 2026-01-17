#!/bin/bash

# 🎯 Cursor AI Rules - 统一路径配置
# 提供所有脚本使用的标准化路径配置
#
# 使用方法:
#   source "$(dirname "${BASH_SOURCE[0]}")/path-config.sh"
#
# 提供的变量:
#   PROJECT_ROOT    - 项目根目录
#   CURSOR_DIR      - .cursor目录
#   CURSOR_GROWTH   - .cursorGrowth目录
#   CONFIG_DIR      - 配置目录
#   CORE_DIR        - 核心脚本目录
#   DOCS_DIR        - 文档目录

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 标准化路径计算
if [[ "$SCRIPT_DIR" == *"/.cursor/core" ]]; then
    # 脚本在 .cursor/core/ 目录中
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    CURSOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [[ "$SCRIPT_DIR" == *"/.cursor/config" ]]; then
    # 脚本在 .cursor/config/ 目录中 (如果有的话)
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    CURSOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [[ "$SCRIPT_DIR" == *"/.cursor/features/hooks" ]]; then
    # 钩子脚本在 .cursor/features/hooks/ 目录中
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
    CURSOR_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
    # 其他位置的脚本
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    CURSOR_DIR="$SCRIPT_DIR"
fi

# 导出标准化路径变量
export PROJECT_ROOT
export CURSOR_DIR="$PROJECT_ROOT/.cursor"
export CURSOR_GROWTH="$PROJECT_ROOT/.cursorGrowth"
export CONFIG_DIR="$CURSOR_DIR/config"
export CORE_DIR="$CURSOR_DIR/core"
export DOCS_DIR="$CURSOR_DIR/docs"

# 调试信息 (仅在DEBUG=1时显示)
if [[ "${DEBUG:-0}" == "1" ]]; then
    echo "🔍 Path Config Debug:"
    echo "  SCRIPT_DIR: $SCRIPT_DIR"
    echo "  PROJECT_ROOT: $PROJECT_ROOT"
    echo "  CURSOR_DIR: $CURSOR_DIR"
    echo "  CURSOR_GROWTH: $CURSOR_GROWTH"
    echo "  CONFIG_DIR: $CONFIG_DIR"
    echo "  CORE_DIR: $CORE_DIR"
    echo "  DOCS_DIR: $DOCS_DIR"
    echo ""
fi