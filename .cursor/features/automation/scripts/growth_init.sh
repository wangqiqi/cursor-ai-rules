#!/bin/bash
# 🔄 Cursor AI 生长文件夹初始化脚本
# 初始化.cursorGrowth目录结构和基础配置文件

set -e

echo "🌱 Cursor AI 生长文件夹初始化"
echo "================================"

# 🔧 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../core/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"

# 在加载 path-config.sh 之前设置非严格模式，确保验证失败时不会退出
export STRICT_MODE=0
export DEBUG=0  # 减少调试输出，避免干扰

if ! source "$SCRIPT_DIR/../../../core/path-config.sh" 2>/dev/null; then
    echo "⚠️  路径配置加载失败，尝试手动设置..." >&2

    # 手动设置关键路径变量
    export PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
    export CURSOR_DIR="$PROJECT_ROOT/.cursor"
    export CURSOR_GROWTH="$PROJECT_ROOT/.cursorGrowth"

    echo "📁 使用手动设置的路径: $CURSOR_GROWTH" >&2
fi

# 设置生长目录变量
GROWTH_DIR="$CURSOR_GROWTH"

echo "📁 项目根目录: $PROJECT_ROOT"
echo "🌳 生长文件夹: $GROWTH_DIR"

# 创建完整的目录结构
echo ""
echo "🏗️  创建目录结构..."
ensure_directory_structure
echo "✅ 目录结构创建完成"

# 检查并创建基础配置文件
echo ""
echo "📄 检查配置文件..."

# 生长元数据文件
if [ ! -f "$CURSOR_GROWTH/growth_meta.json" ]; then
    cat > "$CURSOR_GROWTH/growth_meta.json" << EOF
{
  "version": "1.0.0",
  "created_at": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
  "description": "Cursor AI 生长数据元信息",
  "perception_runs": 0,
  "first_perception": null,
  "last_perception": null,
  "user_learning": {
    "communication_patterns": {},
    "preference_patterns": {},
    "interaction_history": []
  },
  "project_evolution": {
    "rule_adjustments": [],
    "performance_metrics": {},
    "optimization_suggestions": []
  },
  "system_health": {
    "last_backup": null,
    "data_integrity": true,
    "storage_usage": "0MB"
  }
}
EOF
    echo "✅ 创建生长元数据文件"
else
    echo "ℹ️  生长元数据文件已存在"
fi

# 用户偏好学习文件
if [ ! -f "$USER_DATA_DIR/preferences.json" ]; then
    cat > "$USER_DATA_DIR/preferences.json" << EOF
{
  "version": "1.0.0",
  "last_updated": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
  "communication_style": {
    "preferred_language": "auto",
    "detail_level": "balanced",
    "response_speed": "normal",
    "confirmation_needed": "auto"
  },
  "coding_preferences": {
    "naming_conventions": {},
    "code_style": {},
    "framework_preferences": {},
    "tool_preferences": {}
  },
  "project_patterns": {
    "team_size_adaptations": {},
    "stage_based_behaviors": {},
    "technology_adaptations": {}
  },
  "interaction_patterns": {
    "frequent_commands": [],
    "response_effectiveness": {},
    "feedback_patterns": []
  }
}
EOF
    echo "✅ 创建用户偏好学习文件"
else
    echo "ℹ️  用户偏好学习文件已存在"
fi

# 监控统计文件
if [ ! -f "$LOGS_DIR/usage_metrics.json" ]; then
    mkdir -p "$LOGS_DIR" && cat > "$LOGS_DIR/usage_metrics.json" << EOF
{
  "version": "1.0.0",
  "tracking_started": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
  "session_count": 0,
  "total_interactions": 0,
  "command_usage": {},
  "rule_activation": {},
  "performance_metrics": {
    "average_response_time": 0,
    "perception_runs": 0,
    "cache_hit_rate": 0,
    "token_savings": 0
  },
  "error_tracking": {
    "total_errors": 0,
    "error_types": {},
    "recovery_attempts": 0
  },
  "learning_progress": {
    "patterns_learned": 0,
    "preferences_adapted": 0,
    "optimizations_applied": 0
  }
}
EOF
    echo "✅ 创建监控统计文件"
else
    echo "ℹ️  监控统计文件已存在"
fi

echo ""
echo "🎯 初始化完成！"
echo ""
echo "📊 生长文件夹结构 (严格7目录结构):"
echo "   $CURSOR_GROWTH/"
echo "   ├── perception/             # 环境感知数据"
echo "   ├── user_data/              # 用户相关数据"
echo "   ├── project_data/           # 项目相关数据"
echo "   ├── ai/                     # AI相关数据"
echo "   ├── analytics/              # 分析数据"
echo "   ├── logs/                   # 统一日志"
echo "   └── integrations/           # 第三方集成"
echo ""
echo "💡 提示:"
echo "   • 生长文件夹已被 .gitignore 忽略，不会在仓库中跟踪"
echo "   • 运行感知分析: ./.cursor/scripts/perception.sh"
echo "   • 查看插件管理: ./.cursor/scripts/plugin_manager.sh"
echo ""
echo "🚀 现在可以开始智能协作了！"
