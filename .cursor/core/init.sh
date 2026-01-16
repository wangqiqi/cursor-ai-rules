#!/bin/bash

# 🚀 Cursor AI Rules - 核心初始化引导器
# 基础的初始化引导功能，专注于核心系统设置

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🚀 Cursor AI Rules - 核心初始化引导器"
echo "===================================="
echo ""

# 检查基础依赖
check_basic_dependencies() {
    echo "📦 检查基础系统依赖..."

    local deps=("git" "curl")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ 缺少必需依赖: ${missing_deps[*]}"
        echo "请先安装这些基础工具，然后重新运行初始化。"
        exit 1
    fi

    echo "✅ 基础依赖检查通过"
}

# 设置目录结构
setup_directory_structure() {
    echo "📁 设置核心目录结构..."

    # 创建核心目录
    mkdir -p "$SCRIPT_DIR/../core"
    mkdir -p "$SCRIPT_DIR/../features"
    mkdir -p "$SCRIPT_DIR/../config"
    mkdir -p "$SCRIPT_DIR/../quality"
    mkdir -p "$SCRIPT_DIR/../docs"

    # 创建功能层目录
    mkdir -p "$SCRIPT_DIR/../features/automation"
    mkdir -p "$SCRIPT_DIR/../features/skills"
    mkdir -p "$SCRIPT_DIR/../features/hooks"
    mkdir -p "$SCRIPT_DIR/../features/plugins"

    echo "✅ 目录结构设置完成"
}

# 初始化配置文件
initialize_config_files() {
    echo "⚙️ 初始化基础配置文件..."

    # 确保系统默认配置存在
    if [ ! -f "$SCRIPT_DIR/../config/system-defaults.json" ]; then
        echo "❌ 系统默认配置文件缺失，请重新安装系统"
        exit 1
    fi

    # 创建用户配置目录（如果不存在）
    mkdir -p "$HOME/.cursor/config"

    # 初始化项目级配置
    if [ ! -f "$SCRIPT_DIR/../config/project.json" ]; then
        echo "📝 创建项目配置模板..."
        # 这里可以调用配置管理器来生成初始配置
        echo "{}" > "$SCRIPT_DIR/../config/project.json"
    fi

    echo "✅ 配置文件初始化完成"
}

# 验证系统完整性
verify_system_integrity() {
    echo "🔍 验证系统完整性..."

    local critical_files=(
        "core/env-perception.sh"
        "config/config-manager.sh"
        "quality/quality-manager.sh"
        "commands/master.md"
        "commands/command-router.md"
        "commands/capability-map.json"
    )

    local missing_files=()

    for file in "${critical_files[@]}"; do
        if [ ! -f "$SCRIPT_DIR/../$file" ]; then
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -ne 0 ]; then
        echo "❌ 缺少关键系统文件:"
        for file in "${missing_files[@]}"; do
            echo "   - $file"
        done
        echo "系统可能已损坏，请重新安装。"
        exit 1
    fi

    echo "✅ 系统完整性验证通过"
}

# 设置基本环境变量
setup_environment_variables() {
    echo "🌍 设置基础环境变量..."

    # 设置Cursor根目录
    export CURSOR_ROOT="$PROJECT_ROOT"
    export CURSOR_CONFIG_DIR="$PROJECT_ROOT/.cursor/config"
    export CURSOR_CORE_DIR="$PROJECT_ROOT/.cursor/core"
    export CURSOR_FEATURES_DIR="$PROJECT_ROOT/.cursor/features"

    # 添加到shell配置文件
    local shell_rc="$HOME/.bashrc"
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    fi

    if ! grep -q "CURSOR_ROOT" "$shell_rc" 2>/dev/null; then
        cat >> "$shell_rc" << 'EOF'

# Cursor AI Rules Environment Variables
export CURSOR_ROOT="$PROJECT_ROOT/.cursor"
export CURSOR_CONFIG_DIR="$CURSOR_ROOT/config"
export CURSOR_CORE_DIR="$CURSOR_ROOT/core"
export CURSOR_FEATURES_DIR="$CURSOR_ROOT/features"
EOF
        echo "✅ 环境变量已添加到 $shell_rc"
        echo "💡 请运行 'source $shell_rc' 使环境变量生效"
    fi
}

# 主函数
main() {
    echo "开始核心初始化引导..."
    echo ""

    check_basic_dependencies
    echo ""

    setup_directory_structure
    echo ""

    initialize_config_files
    echo ""

    verify_system_integrity
    echo ""

    setup_environment_variables
    echo ""

    echo "🎉 核心初始化引导完成！"
    echo ""
    echo "💡 下一步建议："
    echo "   • 运行完整初始化: ./cursor/init.sh"
    echo "   • 运行环境感知: ./cursor/core/env-perception.sh"
    echo "   • 查看帮助: @master help"
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi