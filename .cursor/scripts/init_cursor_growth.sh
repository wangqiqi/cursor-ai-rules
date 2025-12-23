#!/bin/bash

# .cursorGrowth 目录初始化脚本
# 为新项目创建智能进化数据存储结构

set -e

PROJECT_ROOT="$(pwd)"
GROWTH_DIR="${PROJECT_ROOT}/.cursorGrowth"

echo "🌱 初始化 .cursorGrowth 智能进化目录..."
echo "📁 项目根目录: ${PROJECT_ROOT}"

# 检查是否已存在
if [ -d "$GROWTH_DIR" ]; then
    echo "ℹ️  .cursorGrowth 目录已存在，跳过初始化"
    echo "📂 位置: ${GROWTH_DIR}"
    exit 0
fi

# 创建目录结构
echo "📁 创建目录结构..."
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

# 创建初始元数据文件
echo "📝 创建成长元数据..."
cat > "${GROWTH_DIR}/growth_meta.json" << EOF
{
  "version": "1.0.0",
  "created_at": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
  "project_root": "${PROJECT_ROOT}",
  "cursor_rules_version": "2.0.0",
  "growth_phases": {
    "initialization": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
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

# 创建初始用户配置文件
cat > "${GROWTH_DIR}/user_profile/profile.json" << EOF
{
  "created_at": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
  "communication_preferences": {
    "language": "auto",
    "verbosity": "balanced",
    "technical_detail_level": "intermediate"
  },
  "interaction_patterns": {
    "preferred_response_style": "helpful",
    "feedback_frequency": "adaptive",
    "learning_rate": "medium"
  },
  "technical_focus": {
    "primary_concerns": ["reliability", "maintainability"],
    "avoided_topics": [],
    "preferred_solutions": []
  },
  "collaboration_style": {
    "decision_making": "consultative",
    "autonomy_level": "guided",
    "feedback_style": "constructive"
  }
}
EOF

echo "✅ .cursorGrowth 目录初始化完成"
echo "📂 位置: ${GROWTH_DIR}"
echo ""
echo "📊 检测到项目特征:"
echo "   🛠️  技术栈: ${TECH_STACK}"
echo "   👥 团队规模: ${TEAM_SIZE}"
echo "   📈 提交数量: ${COMMIT_COUNT}"
echo ""
echo "🎯 现在可以运行智能感知分析了！"
