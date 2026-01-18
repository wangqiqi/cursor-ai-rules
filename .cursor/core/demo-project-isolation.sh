#!/bin/bash
# 🎯 Cursor AI Rules - 项目隔离功能演示
# 展示如何在多项目环境下安全地使用路径配置

echo "🎯 Cursor AI Rules - 项目隔离功能演示"
echo "======================================"

# 加载路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"

echo ""
echo "📋 项目信息:"
echo "  项目标识符: $PROJECT_IDENTIFIER"
echo "  项目显示名: $PROJECT_DISPLAY_NAME"
echo "  项目根目录: $PROJECT_ROOT"
echo ""

echo "🔧 通用路径变量 (推荐用于单项目或当前项目):"
echo "  AI_DIR: $AI_DIR"
echo "  ANALYTICS_DIR: $ANALYTICS_DIR"
echo "  CACHE_DIR: $CACHE_DIR"
echo "  LEARNING_DIR: $LEARNING_DIR"
echo ""

echo "🔒 项目隔离路径变量 (推荐用于多项目环境):"
echo "  AI_DIR: ${PROJECT_IDENTIFIER}_AI_DIR = $(eval echo \${${PROJECT_IDENTIFIER}_AI_DIR})"
echo "  ANALYTICS_DIR: ${PROJECT_IDENTIFIER}_ANALYTICS_DIR = $(eval echo \${${PROJECT_IDENTIFIER}_ANALYTICS_DIR})"
echo "  CACHE_DIR: ${PROJECT_IDENTIFIER}_CACHE_DIR = $(eval echo \${${PROJECT_IDENTIFIER}_CACHE_DIR})"
echo "  LEARNING_DIR: ${PROJECT_IDENTIFIER}_LEARNING_DIR = $(eval echo \${${PROJECT_IDENTIFIER}_LEARNING_DIR})"
echo ""

echo "💡 使用建议:"
echo "  1. 单项目环境: 使用通用变量 (AI_DIR, ANALYTICS_DIR)"
echo "  2. 多项目环境: 使用项目隔离变量 (${PROJECT_IDENTIFIER}_AI_DIR)"
echo "  3. 脚本开发: 优先使用项目隔离变量确保兼容性"
echo ""

echo "🛡️  安全特性:"
echo "  ✅ 自动项目识别和验证"
echo "  ✅ Git仓库完整性检查"
echo "  ✅ .cursor配置存在性检查"
echo "  ✅ 目录结构自动初始化"
echo "  ✅ 非常规目录自动清理"
echo "  ✅ 项目根目录持久化缓存"
echo "  ✅ 缓存自动验证和更新"
echo ""
echo "💾 缓存状态检查:"
if [[ -f ".cursorGrowth/PROJECT_ROOT" ]]; then
    cached_root=$(cat ".cursorGrowth/PROJECT_ROOT" 2>/dev/null)
    echo "  ✅ 项目根目录缓存: $cached_root"
    if [[ "$cached_root" == "$PROJECT_ROOT" ]]; then
        echo "  ✅ 缓存一致性: 正常"
    else
        echo "  ⚠️  缓存不一致: 缓存=$cached_root, 当前=$PROJECT_ROOT"
    fi
else
    echo "  ❌ 项目根目录缓存: 不存在"
fi

echo ""
echo "🎉 项目隔离和缓存功能演示完成！"