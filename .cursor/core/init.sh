#!/bin/bash
# Cursor AI Rules - 一键初始化（核心版）
# 零外部依赖，自动检测项目类型，复制即用

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"

detect_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "CMakeLists.txt" ]; then
        echo "cpp"
    else
        echo "unknown"
    fi
}

init_quickstart() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║  Cursor AI Rules 快速初始化          ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    local project_type=$(detect_project_type)
    echo "✅ 项目检测: $project_type 项目"
    echo "✅ 项目根目录: $PROJECT_ROOT"
    echo "✅ Cursor 目录: $CURSOR_DIR"

    if [ -f "$CURSOR_DIR/hooks.json" ] && [ -d "$CURSOR_DIR/skills" ]; then
        echo "✅ 官方规范布局: rules / skills / agents / hooks 已就绪"
    fi

    echo ""
    echo "🎉 准备就绪！在 Cursor 中尝试:"
    echo "   /master 分析这个项目"
    echo "   /master 切换角色"
    echo ""

    # 检测 Git 忽略配置
    local gitignore="$PROJECT_ROOT/.gitignore"
    if [ -f "$gitignore" ] && grep -q "\.cursorGrowth" "$gitignore" 2>/dev/null; then
        echo "✅ .gitignore 已包含 .cursorGrowth 保护"
    else
        echo "💡 建议: 将 .cursorGrowth/ 添加到 .gitignore"
    fi
}

case "${1:-}" in
    --quickstart|-q)
        init_quickstart
        ;;
    --help|-h)
        echo "用法: bash init.sh [选项]"
        echo ""
        echo "选项:"
        echo "  --quickstart, -q    一键初始化（默认）"
        echo "  --help, -h          显示此帮助"
        ;;
    *)
        init_quickstart
        ;;
esac
