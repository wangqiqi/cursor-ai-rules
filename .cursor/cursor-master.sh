#!/bin/bash
# Cursor AI Rules - 核心主入口（核心版）
# 零外部依赖，复制 .cursor/ 到任意项目即可使用
# 检测 .cursor-extras/ 扩展层并自动加载完整功能

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core/path-config.sh"

show_banner() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║  Cursor AI Rules - 核心版           ║"
    echo "║  宪法驱动 · 复制即用 · 零依赖        ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
}

show_help() {
    show_banner
    echo "用法: ./cursor-master.sh [命令]"
    echo ""
    echo "命令:"
    echo "  (空)                   显示此帮助"
    echo "  help, -h, --help       显示此帮助"
    echo ""
    echo "在 Cursor IDE 中:"
    echo "  /master [需求描述]      智能命令入口"
    echo "  /master 切换角色 [角色] 切换对话风格"
    echo "  /vibe start            启动 VIBE 开发模式"
    echo ""
    if [ -d "$PROJECT_ROOT/.cursor-extras" ]; then
        local extras_files=$(find "$PROJECT_ROOT/.cursor-extras" -maxdepth 1 -type d | wc -l)
        echo "🔌 检测到扩展层 (.cursor-extras/) — 完整功能可用"
        echo "   运行 bash .cursor-extras/init.sh 加载扩展"
    elif [ -d "$SCRIPT_DIR/../.cursor-extras" ]; then
        local extras_files=$(find "$SCRIPT_DIR/../.cursor-extras" -maxdepth 1 -type d | wc -l)
        echo "🔌 检测到扩展层 (.cursor-extras/) — 完整功能可用"
        echo "   运行 bash .cursor-extras/init.sh 加载扩展"
    fi
    echo ""
    echo "💡 首次使用: bash .cursor/core/init.sh --quickstart"
    echo ""
}

case "${1:-}" in
    ""|"help"|"-h"|"--help")
        show_help
        ;;
    *)
        show_banner
        echo "🔧 正在处理: $*"
        echo ""
        echo "💡 请在 Cursor IDE 中使用 /master 命令"
        echo "   或安装 .cursor-extras/ 扩展层获得完整 CLI 支持"
        echo ""
        ;;
esac
