#!/bin/bash

# 🚀 Cursor AI Rules - 智能环境适配器
# 为项目自动配置AI协作规则

set -e

echo "🚀 Cursor AI Rules - 智能环境适配器"
echo "===================================="
echo "⚡ 自动适配项目环境和AI协作规则"
echo ""

# 🎯 获取环境信息
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
CURRENT_TIME_ISO=$(date '+%Y-%m-%dT%H:%M:%S+08:00')

# Git用户信息（优雅降级）
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
    AUTHOR_NAME=$(git config --get user.name 2>/dev/null || echo "本地用户")
    AUTHOR_EMAIL=$(git config --get user.email 2>/dev/null || echo "local@example.com")
    PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
else
    AUTHOR_NAME="本地用户"
    AUTHOR_EMAIL="local@example.com"
    PROJECT_ROOT=$(pwd)
    echo "⚠️  未检测到Git环境，使用默认配置"
fi

echo "📋 环境信息:"
echo "   📅 时间: $CURRENT_TIME"
echo "   👤 用户: $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo "   📁 项目: $PROJECT_ROOT"
echo ""

# 🎯 初始化.cursorGrowth目录结构
echo "🏗️  初始化智能进化存储..."
GROWTH_DIR=".cursorGrowth"

if [ ! -d "$GROWTH_DIR" ]; then
    mkdir -p "${GROWTH_DIR}/data"
    mkdir -p "${GROWTH_DIR}/evolution_history"
    mkdir -p "${GROWTH_DIR}/user_profile"
    mkdir -p "${GROWTH_DIR}/project_metrics"
    mkdir -p "${GROWTH_DIR}/adaptations"

    # 获取项目基本信息
    TECH_STACK="unknown"
    if [ -f "package.json" ]; then
        TECH_STACK="Node.js/React"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        TECH_STACK="Python"
    elif [ -f "go.mod" ]; then
        TECH_STACK="Go"
    elif [ -f "Cargo.toml" ]; then
        TECH_STACK="Rust"
    fi

    TEAM_SIZE="personal"
    COMMIT_COUNT=$(git log --oneline 2>/dev/null | wc -l || echo "0")
    if [ "$COMMIT_COUNT" -gt 50 ]; then
        TEAM_SIZE="team"
    elif [ "$COMMIT_COUNT" -gt 10 ]; then
        TEAM_SIZE="small_team"
    fi

    # 创建成长元数据文件
    cat > "${GROWTH_DIR}/growth_meta.json" << EOF
{
  "version": "1.0.0",
  "created_at": "$CURRENT_TIME",
  "project_root": "$PROJECT_ROOT",
  "cursor_rules_version": "2.0.0",
  "growth_phases": {
    "initialization": "$CURRENT_TIME",
    "first_perception": null,
    "first_adaptation": null
  },
  "statistics": {
    "perception_runs": 0,
    "evolution_events": 0,
    "user_interactions": 0,
    "total_adaptations": 0
  },
  "project_characteristics": {
    "tech_stack": "${TECH_STACK}",
    "team_size": "${TEAM_SIZE}",
    "development_stage": "early",
    "complexity_level": "low"
  }
}
EOF

    echo "   ✅ .cursorGrowth目录创建完成"
    echo "   🛠️  检测到技术栈: ${TECH_STACK}"
    echo "   👥 团队规模: ${TEAM_SIZE}"
else
    echo "   ℹ️  .cursorGrowth目录已存在"
fi

echo ""

# 📝 处理命令行参数
case "${1:-}" in
    "help"|"-h"|"--help")
        echo "🤖 Cursor AI Rules - 智能环境适配器"
        echo "===================================="
        echo ""
        echo "📖 使用方法:"
        echo "   $0                    # 自动环境适配（推荐）"
        echo "   $0 help              # 显示此帮助信息"
        echo ""
        echo "🎯 主要功能:"
        echo "   • 自动检测项目环境和Git配置"
        echo "   • 替换模板变量为实际值"
        echo "   • 初始化.cursorGrowth目录"
        echo "   • 创建备份确保安全"
        echo ""
        echo "📋 相关命令:"
        echo "   ./.cursor/rules/intelligent_evolution/perception.sh  # 智能感知分析"
        echo "   cat .cursorGrowth/data/perception_*.json              # 查看感知结果"
        echo "   cat .cursorGrowth/growth_meta.json                    # 查看系统状态"
        exit 0
        ;;
    "interactive"|"-i"|"--interactive")
        echo "🎮 进入交互式引导模式..."
        echo "👋 欢迎使用 Cursor AI Rules！"
        echo ""
        echo "这个系统将为您的项目提供AI协作优化。"
        echo "继续将自动配置环境..."
        echo ""
        read -p "是否继续？(y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ 已取消"
            exit 1
        fi
        ;;
    "")
        # 默认自动模式，继续执行
        ;;
    *)
        echo "❌ 未知参数: $1"
        echo "💡 使用 '$0 help' 查看帮助"
        exit 1
        ;;
esac

# 🔄 变量替换处理
echo "🔄 正在适配规则文件..."

# 备份目录
BACKUP_DIR=".cursor/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 需要处理的文件
FILES_TO_UPDATE=(
    ".cursor/README.md"
    ".cursor/rules/constitution/RULE.md"
    ".cursor/rules/philosophy/RULE.md"
    ".cursor/rules/generator/RULE.md"
    ".cursor/rules/templates/templates.json"
)

# 备份和替换
for file in "${FILES_TO_UPDATE[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/"
        # 替换模板变量
        sed -i "s/{{GENERATION_TIME}}/$CURRENT_TIME/g" "$file" 2>/dev/null || true
        sed -i "s/{{GENERATION_TIME_ISO}}/$CURRENT_TIME_ISO/g" "$file" 2>/dev/null || true
        sed -i "s/{{AUTHOR_NAME}}/$AUTHOR_NAME/g" "$file" 2>/dev/null || true
        sed -i "s/{{AUTHOR_EMAIL}}/$AUTHOR_EMAIL/g" "$file" 2>/dev/null || true
    fi
done

echo ""
echo "✅ 适配完成！"
echo ""
echo "📁 备份文件: $BACKUP_DIR"
echo ""
echo "🎯 AI协作规则已成功适配到您的项目环境！"
echo ""
        echo "💡 接下来您可以："
        echo "   • 运行智能感知: ./.cursor/rules/intelligent_evolution/perception.sh"
        echo "   • 查看项目分析: cat .cursorGrowth/growth_meta.json"
