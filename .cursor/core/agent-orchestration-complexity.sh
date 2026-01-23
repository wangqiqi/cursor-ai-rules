#!/bin/bash
# ========================================
# Cursor AI Rules - 智能复杂度分析和任务分解模块
# 分析任务复杂度并提供智能分解建议
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-core.sh"

# =============================================================================
# 智能复杂度分析和任务分解模块 - 功能层
# =============================================================================

# 🎯 智能复杂度分析和任务分解

# 分析任务复杂度
analyze_task_complexity() {
    local task_description="$1"
    local task_type="$2"

    smart_echo "分析任务复杂度: $task_type" "processing"

    # TODO: 迁移自原agent-orchestration-engine.sh的复杂度分析逻辑

    # 计算复杂度得分 (0-100)
    local complexity_score=$(calculate_complexity_score "$task_description" "$task_type")

    # 判断是否需要分解
    local decomposition_needed=$(should_decompose_task "$complexity_score" "$task_description")

    # 生成复杂度分析报告
    cat <<EOF
{
  "complexity_score": $complexity_score,
  "decomposition_needed": $decomposition_needed,
  "estimated_effort": $(estimate_task_effort "$task_description" "$task_type"),
  "risk_factors": $(identify_risk_factors "$task_description" "$task_type"),
  "recommended_approach": "$(get_recommended_approach "$complexity_score" "$decomposition_needed")",
  "analysis_timestamp": "$(date -Iseconds)"
}
EOF
}

# 估算任务工作量
estimate_task_effort() {
    local task_description="$1"
    local task_type="$2"

    # TODO: 迁移自原agent-orchestration-engine.sh的estimate_task_effort函数

    # 基于描述长度、关键词复杂度估算工作量
    local description_length=${#task_description}
    local keyword_complexity=$(count_complex_keywords "$task_description")

    # 基础估算 (单位: 小时)
    local base_effort=1

    # 长度影响 (+0.5小时 per 100字符)
    local length_bonus=$((description_length / 100 / 2))

    # 关键词复杂度影响 (+0.25小时 per 复杂关键词)
    local complexity_bonus=$((keyword_complexity / 4))

    # 任务类型系数
    local type_multiplier=$(get_task_type_multiplier "$task_type")

    local total_effort=$((base_effort + length_bonus + complexity_bonus))
    total_effort=$((total_effort * type_multiplier / 100))

    echo "$total_effort"
}

# 分解复杂任务
decompose_complex_task() {
    local task_description="$1"
    local task_type="$2"
    local complexity_analysis="$3"

    smart_echo "分解复杂任务: $task_type" "processing"

    # TODO: 实现任务分解逻辑
    local decomposition_needed=$(echo "$complexity_analysis" | jq -r '.decomposition_needed' 2>/dev/null || echo "false")

    if [[ "$decomposition_needed" != "true" ]]; then
        smart_echo "任务不需要分解" "info"
        return 1
    fi

    # 生成子任务列表
    generate_subtasks "$task_description" "$task_type" "$complexity_analysis"
}

# 识别所需能力
identify_required_capabilities() {
    local task_description="$1"
    local task_type="$2"

    # TODO: 迁移自原agent-orchestration-engine.sh的identify_required_capabilities函数

    # 基于任务类型和描述识别所需能力
    local capabilities=()

    # 基础能力
    capabilities+=("task_execution")

    # 根据任务类型添加特定能力
    case "$task_type" in
        "code_generation")
            capabilities+=("code_writing" "syntax_knowledge")
            ;;
        "code_review")
            capabilities+=("code_analysis" "quality_assessment")
            ;;
        "testing")
            capabilities+=("test_design" "debugging")
            ;;
        "deployment")
            capabilities+=("infrastructure" "automation")
            ;;
        "documentation")
            capabilities+=("technical_writing" "documentation")
            ;;
        "analysis")
            capabilities+=("data_processing" "problem_solving")
            ;;
        *)
            capabilities+=("general_processing")
            ;;
    esac

    # 从描述中提取关键词能力
    local keyword_capabilities=$(extract_capabilities_from_text "$task_description")
    capabilities+=($keyword_capabilities)

    # 去重并格式化输出
    local unique_capabilities=$(printf '%s\n' "${capabilities[@]}" | sort | uniq)

    # 输出JSON格式
    echo "$unique_capabilities" | jq -R . | jq -s . 2>/dev/null || echo '["general_processing"]'
}

# 计算任务优先级
calculate_task_priority() {
    local task_description="$1"
    local task_type="$2"
    local deadline="${3:-}"

    # TODO: 实现任务优先级计算逻辑

    # 基于任务类型、紧急程度、复杂度计算优先级
    local base_priority=50

    # 任务类型优先级调整
    case "$task_type" in
        "critical"|"emergency")
            base_priority=90
            ;;
        "high"|"urgent")
            base_priority=75
            ;;
        "medium"|"normal")
            base_priority=50
            ;;
        "low"|"trivial")
            base_priority=25
            ;;
    esac

    # 截止时间影响
    if [[ -n "$deadline" ]]; then
        local hours_until_deadline=$(calculate_hours_until_deadline "$deadline")
        if (( hours_until_deadline <= 24 )); then
            base_priority=$((base_priority + 15))
        elif (( hours_until_deadline <= 72 )); then
            base_priority=$((base_priority + 10))
        fi
    fi

    # 确保在0-100范围内
    if (( base_priority > 100 )); then
        base_priority=100
    elif (( base_priority < 0 )); then
        base_priority=0
    fi

    echo "$base_priority"
}

# =============================================================================
# 内部辅助函数
# =============================================================================

# 计算复杂度得分
calculate_complexity_score() {
    local task_description="$1"
    local task_type="$2"

    # 基于多个维度计算复杂度
    local length_score=$(calculate_length_complexity "$task_description")
    local keyword_score=$(calculate_keyword_complexity "$task_description")
    local type_score=$(calculate_type_complexity "$task_type")

    # 加权平均 (长度40%, 关键词40%, 类型20%)
    local total_score=$(
        echo "scale=2; ($length_score * 0.4) + ($keyword_score * 0.4) + ($type_score * 0.2)" | bc 2>/dev/null || echo "50.00"
    )

    # 转换为整数
    echo "${total_score%.*}"
}

# 判断是否需要分解任务
should_decompose_task() {
    local complexity_score="$1"
    local task_description="$2"

    # 复杂度超过70或描述过长的任务需要分解
    if (( complexity_score >= 70 )) || (( ${#task_description} >= 500 )); then
        echo "true"
    else
        echo "false"
    fi
}

# 获取推荐方法
get_recommended_approach() {
    local complexity_score="$1"
    local decomposition_needed="$2"

    if [[ "$decomposition_needed" == "true" ]]; then
        echo "decompose_and_parallel"
    elif (( complexity_score >= 80 )); then
        echo "expert_agent_required"
    elif (( complexity_score >= 60 )); then
        echo "specialized_agent_preferred"
    else
        echo "standard_agent_sufficient"
    fi
}

# 计算长度复杂度
calculate_length_complexity() {
    local task_description="$1"
    local length=${#task_description}

    # 长度复杂度 (0-100)
    if (( length <= 50 )); then
        echo "20"
    elif (( length <= 100 )); then
        echo "40"
    elif (( length <= 200 )); then
        echo "60"
    elif (( length <= 500 )); then
        echo "80"
    else
        echo "100"
    fi
}

# 计算关键词复杂度
calculate_keyword_complexity() {
    local task_description="$1"

    # 定义复杂关键词列表
    local complex_keywords=("architecture" "optimization" "security" "performance" "scalability" "integration" "migration" "refactoring")
    local count=0

    for keyword in "${complex_keywords[@]}"; do
        if [[ "$task_description" == *"$keyword"* ]]; then
            ((count++))
        fi
    done

    # 关键词复杂度 (0-100)
    echo $((count * 15))
}

# 计算任务类型复杂度
calculate_type_complexity() {
    local task_type="$1"

    case "$task_type" in
        "architecture"|"design"|"planning")
            echo "80"
            ;;
        "development"|"coding"|"implementation")
            echo "60"
            ;;
        "testing"|"review"|"analysis")
            echo "50"
            ;;
        "deployment"|"maintenance"|"documentation")
            echo "40"
            ;;
        *)
            echo "30"
            ;;
    esac
}

# 计算复杂关键词数量
count_complex_keywords() {
    local task_description="$1"
    local complex_keywords=("复杂" "优化" "安全" "性能" "扩展" "集成" "迁移" "重构" "architecture" "optimization" "security" "performance")
    local count=0

    for keyword in "${complex_keywords[@]}"; do
        if [[ "$task_description" == *"$keyword"* ]]; then
            ((count++))
        fi
    done

    echo "$count"
}

# 获取任务类型乘数
get_task_type_multiplier() {
    local task_type="$1"

    case "$task_type" in
        "architecture"|"design")
            echo "200"  # 2.0x
            ;;
        "development"|"coding")
            echo "150"  # 1.5x
            ;;
        "testing"|"review")
            echo "120"  # 1.2x
            ;;
        "deployment"|"documentation")
            echo "100"  # 1.0x
            ;;
        *)
            echo "100"
            ;;
    esac
}

# 识别风险因素
identify_risk_factors() {
    local task_description="$1"
    local task_type="$2"

    # TODO: 实现风险因素识别逻辑
    cat <<EOF
["time_constraints", "technical_complexity"]
EOF
}

# 生成子任务
generate_subtasks() {
    local task_description="$1"
    local task_type="$2"
    local complexity_analysis="$3"

    # TODO: 实现子任务生成逻辑
    smart_echo "生成子任务列表" "info"

    # 简单的子任务示例
    cat <<EOF
[
  {
    "id": "subtask_1",
    "description": "分析任务需求",
    "type": "analysis",
    "priority": "high"
  },
  {
    "id": "subtask_2",
    "description": "设计解决方案",
    "type": "design",
    "priority": "high"
  },
  {
    "id": "subtask_3",
    "description": "实施解决方案",
    "type": "implementation",
    "priority": "medium"
  }
]
EOF
}

# 从文本中提取能力
extract_capabilities_from_text() {
    local text="$1"

    # TODO: 实现文本能力提取逻辑
    local additional_capabilities=("text_processing")
    echo "${additional_capabilities[@]}"
}

# 计算截止时间前的剩余小时数
calculate_hours_until_deadline() {
    local deadline="$1"

    # TODO: 实现截止时间计算逻辑
    echo "48"
}

# =============================================================================
# 函数导出
# =============================================================================

export -f analyze_task_complexity
export -f estimate_task_effort
export -f decompose_complex_task
export -f identify_required_capabilities
export -f calculate_task_priority