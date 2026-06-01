#!/bin/bash
# ========================================
# Cursor AI Rules - 智能复杂度分析和任务分解模块
# 分析任务复杂度并提供智能分解建议
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/agent-orchestration-common.sh"
source "$SCRIPT_DIR/agent-orchestration-core.sh"

# =============================================================================
# 智能复杂度分析和任务分解模块 - 功能层
# =============================================================================

# 🎯 智能复杂度分析和任务分解

# 分析任务复杂度
analyze_task_complexity() {
    local task_description="$1"
    local task_type="$2"

    local complexity_score=$(calculate_complexity_score "$task_description" "$task_type")
    local decomposition_needed=$(should_decompose_task "$complexity_score" "$task_description")

    cat <<EOF
{
  "complexity_score": $complexity_score,
  "decomposition_needed": $decomposition_needed,
  "estimated_subtasks": $(estimate_subtask_count "$complexity_score"),
  "complexity_level": "$(get_complexity_level "$complexity_score")",
  "analysis_timestamp": "$(date -Iseconds)"
}
EOF
}

# 估算任务工作量
estimate_task_effort() {
    local task_description="$1"
    local task_type="$2"

    local analysis=$(analyze_task_complexity "$task_description" "$task_type")
    local complexity_score=$(echo "$analysis" | jq -r '.complexity_score')

    # 将复杂度评分转换为工作量估算 (1-10分)
    local effort
    if (( $(echo "$complexity_score < 20" | bc -l 2>/dev/null) )); then
        effort=1
    elif (( $(echo "$complexity_score < 40" | bc -l 2>/dev/null) )); then
        effort=3
    elif (( $(echo "$complexity_score < 60" | bc -l 2>/dev/null) )); then
        effort=5
    elif (( $(echo "$complexity_score < 80" | bc -l 2>/dev/null) )); then
        effort=7
    else
        effort=10
    fi

    echo "$effort"
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

    # 基于任务类型和描述识别所需能力
    local capabilities="[]"

    case "$task_type" in
        "planning")
            capabilities='["task_planning", "requirement_analysis"]'
            ;;
        "coding")
            capabilities='["code_generation", "documentation_creation"]'
            ;;
        "testing")
            capabilities='["test_creation", "test_execution"]'
            ;;
        "deployment")
            capabilities='["deployment_execution", "monitoring_configuration"]'
            ;;
        "review")
            capabilities='["code_review", "quality_assessment"]'
            ;;
        *)
            # 基于描述关键词识别
            if echo "$task_description" | grep -qi "代码\|编程\|开发"; then
                capabilities='["code_generation"]'
            elif echo "$task_description" | grep -qi "测试"; then
                capabilities='["test_execution"]'
            elif echo "$task_description" | grep -qi "部署\|发布"; then
                capabilities='["deployment_execution"]'
            else
                capabilities='["general_assistance"]'
            fi
            ;;
    esac

    echo "$capabilities"
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

# 计算复杂度评分 (1-100分)
calculate_complexity_score() {
    local task_description="$1"
    local task_type="$2"

    local base_score=50

    # 1. 基于描述长度 (权重: 20%)
    # 使用wc -m来正确计算字符数（包括中文字符）
    local description_length=$(echo -n "$task_description" | wc -m)
    local length_score
    if (( description_length < 10 )); then
        length_score=10
    elif (( description_length < 20 )); then
        length_score=20
    elif (( description_length < 50 )); then
        length_score=40
    elif (( description_length < 100 )); then
        length_score=60
    elif (( description_length < 200 )); then
        length_score=80
    else
        length_score=100
    fi

    # 2. 基于关键词复杂度 (权重: 30%)
    local keyword_score=$(analyze_keywords_complexity "$task_description")

    # 3. 基于任务类型复杂度 (权重: 25%)
    local type_score
    case "$task_type" in
        "planning") type_score=70 ;;
        "coding") type_score=85 ;;
        "testing") type_score=75 ;;
        "deployment") type_score=65 ;;
        "review") type_score=60 ;;
        "coordination") type_score=90 ;;
        "learning") type_score=80 ;;
        "monitoring") type_score=55 ;;
        *) type_score=50 ;;
    esac

    # 4. 基于依赖复杂度 (权重: 15%)
    local dependency_score=$(analyze_dependency_complexity "$task_description")

    # 5. 基于技术栈复杂度 (权重: 10%)
    local tech_score=$(analyze_technology_complexity "$task_description")

    # 计算综合复杂度评分
    local total_score=$(
        echo "scale=2;
        ($length_score * 0.2) +
        ($keyword_score * 0.3) +
        ($type_score * 0.25) +
        ($dependency_score * 0.15) +
        ($tech_score * 0.1)
        " | bc 2>/dev/null || echo "50.0"
    )

    # 确保分数在1-100范围内
    if (( $(echo "$total_score < 1" | bc -l 2>/dev/null) )); then
        total_score=1
    elif (( $(echo "$total_score > 100" | bc -l 2>/dev/null) )); then
        total_score=100
    fi

    echo "$total_score"
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

# 分析关键词复杂度 (新实现)
analyze_keywords_complexity() {
    local task_description="$1"

    # 定义不同权重的关键词组
    local high_complexity_keywords=(
        "架构" "architecture" "design.*system" "infrastructure"
        "微服务" "microservice" "分布式" "distributed"
        "高并发" "high.concurrency" "可扩展" "scalability"
        "容错" "fault.tolerant" "负载均衡" "load.balancing"
        "云计算" "cloud" "容器化" "containerization"
    )

    local medium_complexity_keywords=(
        "优化" "optimization" "性能" "performance" "安全" "security"
        "集成" "integration" "api" "算法" "algorithm"
        "机器学习" "ai" "数据分析" "analytics"
        "并发" "concurrent" "异步" "async" "并行" "parallel"
        "数据库" "database" "查询优化" "query" "schema"
        "前端" "frontend" "后端" "backend" "服务端" "server"
    )

    local low_complexity_keywords=(
        "创建" "create" "添加" "add" "修改" "update" "删除" "delete"
        "配置" "config" "设置" "setup" "安装" "install"
        "测试" "test" "检查" "check" "验证" "validate"
    )

    # 计算各权重关键词的数量
    local high_count=0
    local medium_count=0
    local low_count=0

    for keyword in "${high_complexity_keywords[@]}"; do
        if echo "$task_description" | grep -qi "$keyword"; then
            ((high_count++))
        fi
    done

    for keyword in "${medium_complexity_keywords[@]}"; do
        if echo "$task_description" | grep -qi "$keyword"; then
            ((medium_count++))
        fi
    done

    for keyword in "${low_complexity_keywords[@]}"; do
        if echo "$task_description" | grep -qi "$keyword"; then
            ((low_count++))
        fi
    done

    # 计算加权复杂度分数
    local complexity_score=$(( high_count * 20 + medium_count * 10 + low_count * 5 ))
    echo "$complexity_score"
}

# 分析依赖复杂度
analyze_dependency_complexity() {
    local task_description="$1"

    local dependency_indicators=(
        "依赖" "depends" "requires" "needs" "after"
        "必须" "should" "prerequisite" "前提" "先决"
        "顺序" "sequence" "order" "先后" "串行"
        "并行" "parallel" "同时" "concurrent"
    )

    local dependency_count=0
    for indicator in "${dependency_indicators[@]}"; do
        if echo "$task_description" | grep -qi "$indicator"; then
            ((dependency_count++))
        fi
    done

    # 根据依赖指示器数量计算复杂度
    local dependency_score=$(( dependency_count * 25 ))
    if (( dependency_score > 100 )); then
        dependency_score=100
    fi

    echo "$dependency_score"
}

# 分析技术栈复杂度
analyze_technology_complexity() {
    local task_description="$1"

    local tech_stacks=(
        "kubernetes\|docker\|container" "cloud\|aws\|azure\|gcp"
        "react\|vue\|angular\|typescript" "python\|java\|golang\|rust"
        "database\|mysql\|postgres\|mongodb" "microservice\|distributed"
        "ai\|ml\|machine.learning" "blockchain\|crypto"
    )

    local tech_count=0
    for tech in "${tech_stacks[@]}"; do
        if echo "$task_description" | grep -qi "$tech"; then
            ((tech_count++))
        fi
    done

    # 计算技术栈复杂度
    local tech_score=$(( tech_count * 20 ))
    if (( tech_score > 100 )); then
        tech_score=100
    fi

    echo "$tech_score"
}

# 估算子任务数量
estimate_subtask_count() {
    local complexity_score="$1"

    if (( $(echo "$complexity_score >= 80" | bc -l 2>/dev/null || echo "0") )); then
        echo "5"
    elif (( $(echo "$complexity_score >= 60" | bc -l 2>/dev/null || echo "0") )); then
        echo "3"
    elif (( $(echo "$complexity_score >= 40" | bc -l 2>/dev/null || echo "0") )); then
        echo "2"
    else
        echo "1"
    fi
}

# 获取复杂度等级
get_complexity_level() {
    local complexity_score="$1"

    if (( $(echo "$complexity_score >= 80" | bc -l 2>/dev/null || echo "0") )); then
        echo "高"
    elif (( $(echo "$complexity_score >= 60" | bc -l 2>/dev/null || echo "0") )); then
        echo "中"
    elif (( $(echo "$complexity_score >= 40" | bc -l 2>/dev/null || echo "0") )); then
        echo "低"
    else
        echo "极低"
    fi
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