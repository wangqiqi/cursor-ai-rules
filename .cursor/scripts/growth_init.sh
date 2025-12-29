#!/bin/bash

# 🔄 Cursor AI 生长文件夹初始化脚本
# 初始化.cursorGrowth目录结构和基础配置文件

set -e

echo "🌱 Cursor AI 生长文件夹初始化"
echo "================================"

# 获取项目根目录
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GROWTH_DIR="${PROJECT_ROOT}/.cursorGrowth"

echo "📁 项目根目录: $PROJECT_ROOT"
echo "🌳 生长文件夹: $GROWTH_DIR"

# 创建完整的目录结构
echo ""
echo "🏗️  创建目录结构..."
mkdir -p \
  "$GROWTH_DIR/data/perception" \
  "$GROWTH_DIR/data/user_preferences" \
  "$GROWTH_DIR/data/project_metrics" \
  "$GROWTH_DIR/cache/analysis" \
  "$GROWTH_DIR/cache/templates" \
  "$GROWTH_DIR/cache/rules" \
  "$GROWTH_DIR/learning" \
  "$GROWTH_DIR/monitoring" \
  "$GROWTH_DIR/backups/config_backups"

echo "✅ 目录结构创建完成"

# 检查并创建基础配置文件
echo ""
echo "📄 检查配置文件..."

# 生长元数据文件
if [ ! -f "$GROWTH_DIR/growth_meta.json" ]; then
    cat > "$GROWTH_DIR/growth_meta.json" << 'EOF'
{
  "version": "1.0.0",
  "created_at": "'"$(date '+%Y-%m-%d %H:%M:%S %Z')"'",
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
if [ ! -f "$GROWTH_DIR/learning/preferences.json" ]; then
    cat > "$GROWTH_DIR/learning/preferences.json" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "'"$(date '+%Y-%m-%d %H:%M:%S %Z')"'",
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
if [ ! -f "$GROWTH_DIR/monitoring/usage_metrics.json" ]; then
    cat > "$GROWTH_DIR/monitoring/usage_metrics.json" << 'EOF'
{
  "version": "1.0.0",
  "tracking_started": "'"$(date '+%Y-%m-%d %H:%M:%S %Z')"'",
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
echo "📊 生长文件夹结构:"
echo "   $GROWTH_DIR/"
echo "   ├── data/"
echo "   │   ├── perception/          # 感知数据"
echo "   │   ├── user_preferences/    # 用户偏好"
echo "   │   └── project_metrics/     # 项目指标"
echo "   ├── cache/"
echo "   │   ├── analysis/           # 分析缓存"
echo "   │   ├── templates/          # 模板缓存"
echo "   │   └── rules/              # 规则缓存"
echo "   ├── learning/               # 学习数据"
echo "   ├── monitoring/             # 监控数据"
echo "   └── backups/                # 备份数据"
echo ""
echo "💡 提示:"
echo "   • 生长文件夹已被 .gitignore 忽略，不会在仓库中跟踪"
echo "   • 运行感知分析: ./.cursor/rules/intelligent_evolution/perception.sh"
echo "   • 查看插件管理: ./.cursor/scripts/plugin_manager.sh"
echo ""
echo "🚀 现在可以开始智能协作了！"
