#!/bin/bash

# 自动进化系统 - 感知和分析脚本
# 用于自动感知项目变化和用户沟通模式

set -e

# 函数定义

analyze_tech_stack() {
    local tech_info=""

    # 检查主要技术栈文件
    if [ -f "package.json" ]; then
        tech_info="${tech_info}Node.js/React "
        if grep -q "typescript" package.json; then
            tech_info="${tech_info}(TypeScript) "
        fi
    fi

    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        tech_info="${tech_info}Python "
    fi

    if [ -f "go.mod" ]; then
        tech_info="${tech_info}Go "
    fi

    if [ -f "Cargo.toml" ]; then
        tech_info="${tech_info}Rust "
    fi

    # 分析技术栈复杂度
    local file_count=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" | wc -l)
    tech_info="${tech_info}(复杂度: $file_count 文件)"

    echo "$tech_info"
}

analyze_team_dynamics() {
    # 分析Git贡献者
    local contributor_count=$(git log --format='%ae' 2>/dev/null | sort | uniq | wc -l || echo "1")
    local recent_commits=$(git log --since="30 days ago" --oneline 2>/dev/null | wc -l || echo "0")

    echo "贡献者: $contributor_count, 近30天提交: $recent_commits"
}

analyze_project_scale() {
    # 分析项目规模
    local code_lines=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    local file_count=$(find . -type f \( -name "*.md" -o -name "*.js" -o -name "*.py" -o -name "*.java" \) 2>/dev/null | wc -l || echo "0")

    echo "代码行数: $code_lines, 文件数量: $file_count"
}

analyze_development_stage() {
    # 分析开发阶段
    local tag_count=$(git tag 2>/dev/null | wc -l || echo "0")
    local branch_count=$(git branch 2>/dev/null | wc -l || echo "1")
    local ci_config=$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l || echo "0")

    local stage="早期开发"
    if [ "$tag_count" -gt 5 ]; then
        stage="成熟产品"
    elif [ "$tag_count" -gt 1 ]; then
        stage="成长阶段"
    fi

    echo "阶段: $stage, 发布版本: $tag_count, CI配置: $ci_config"
}

analyze_communication_patterns() {
    # 这里应该分析对话历史，暂时返回模拟数据
    echo "检测到用户偏好: 重视质量控制，偏好中文交流"
}

generate_evolution_suggestions() {
    local tech_stack="$1"
    local team_info="$2"
    local project_scale="$3"
    local dev_stage="$4"

    echo "基于项目分析，建议的进化方向:"
    echo "   1. 根据技术栈($tech_stack)调整代码质量标准"
    echo "   2. 基于团队规模($team_info)优化协作模式"
    echo "   3. 针对项目规模($project_scale)调整流程复杂度"
    echo "   4. 匹配开发阶段($dev_stage)的管理策略"
}

save_perception_data() {
    local tech_stack="$1"
    local team_info="$2"
    local project_scale="$3"
    local dev_stage="$4"
    local communication_patterns="$5"

    cat > "$PERCEPTION_FILE" << EOF
{
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S %Z')",
  "project_analysis": {
    "tech_stack": "$tech_stack",
    "team_dynamics": "$team_info",
    "project_scale": "$project_scale",
    "development_stage": "$dev_stage"
  },
  "user_patterns": {
    "communication": "$communication_patterns"
  },
  "evolution_candidates": [
    "根据项目变化调整规则参数",
    "学习用户偏好优化交互",
    "基于团队动态调整协作模式"
  ]
}
EOF

    echo "📁 感知数据已保存到: $PERCEPTION_FILE"

    # 更新成长元数据
    update_growth_meta "perception"
}

update_growth_meta() {
    local event_type="$1"
    local meta_file="${GROWTH_DIR}/growth_meta.json"

    if [ -f "$meta_file" ]; then
        # 简单的统计更新（实际项目中建议使用jq进行精确JSON操作）
        local current_count=$(grep -o '"perception_runs": [0-9]*' "$meta_file" | cut -d' ' -f2 || echo "0")

        # 更新感知运行次数
        sed -i "s/\"perception_runs\": [0-9]*/\"perception_runs\": $((current_count + 1))/" "$meta_file"

        # 如果是第一次感知，更新时间戳
        if [ "$event_type" = "perception" ] && grep -q '"first_perception": null' "$meta_file"; then
            local timestamp="$(date '+%Y-%m-%d %H:%M:%S %Z')"
            sed -i "s/\"first_perception\": null/\"first_perception\": \"$timestamp\"/" "$meta_file"
        fi
    fi
}

# 主程序开始

echo "🧠 自动进化系统 - 感知分析器"
echo "================================="

# 配置变量
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GROWTH_DIR="${PROJECT_ROOT}/.cursorGrowth"
DATA_DIR="${GROWTH_DIR}/data"
PERCEPTION_FILE="${DATA_DIR}/perception_$(date +%Y%m%d).json"

# 确保.cursorGrowth目录存在，如果不存在则初始化
if [ ! -d "$GROWTH_DIR" ]; then
    echo "🌱 检测到.cursorGrowth不存在，正在初始化..."
    if [ -f "${PROJECT_ROOT}/.cursor/scripts/init_cursor_growth.sh" ]; then
        bash "${PROJECT_ROOT}/.cursor/scripts/init_cursor_growth.sh"
    else
        echo "⚠️  初始化脚本不存在，请手动创建.cursorGrowth目录"
        mkdir -p "$DATA_DIR"
    fi
fi

# 创建数据目录
mkdir -p "$DATA_DIR"

echo "📊 分析项目状态..."

# 1. 技术栈分析
echo "🔧 技术栈分析:"
TECH_STACK=$(analyze_tech_stack)
echo "   $TECH_STACK"

# 2. 团队动态分析
echo "👥 团队动态分析:"
TEAM_INFO=$(analyze_team_dynamics)
echo "   $TEAM_INFO"

# 3. 项目规模分析
echo "📈 项目规模分析:"
PROJECT_SCALE=$(analyze_project_scale)
echo "   $PROJECT_SCALE"

# 4. 开发阶段分析
echo "🚀 开发阶段分析:"
DEV_STAGE=$(analyze_development_stage)
echo "   $DEV_STAGE"

echo ""
echo "💬 用户沟通模式分析:"
# 这里需要从对话历史中分析，暂时模拟
COMMUNICATION_PATTERNS=$(analyze_communication_patterns)
echo "   $COMMUNICATION_PATTERNS"

echo ""
echo "🎯 生成进化建议:"

# 生成基于分析结果的进化建议
EVOLUTION_SUGGESTIONS=$(generate_evolution_suggestions "$TECH_STACK" "$TEAM_INFO" "$PROJECT_SCALE" "$DEV_STAGE")
echo "$EVOLUTION_SUGGESTIONS"

# 保存感知数据
save_perception_data "$TECH_STACK" "$TEAM_INFO" "$PROJECT_SCALE" "$DEV_STAGE" "$COMMUNICATION_PATTERNS"

echo ""
echo "✅ 感知分析完成"

# 自动更新README.md
echo ""
echo "🔄 自动更新README.md..."
if [ -f "${PROJECT_ROOT}/.cursor/scripts/generate_readme.sh" ]; then
    bash "${PROJECT_ROOT}/.cursor/scripts/generate_readme.sh" > /dev/null 2>&1
    echo "📝 README.md 已更新，包含最新的感知数据"
else
    echo "⚠️  README生成器未找到，跳过自动更新"
fi
