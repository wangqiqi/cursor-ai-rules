#!/bin/bash
# ========================================
# Cursor AI Rules - 澄清机制集成模块
# 将澄清提问机制集成到Agent编排系统
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-core.sh"
source "$SCRIPT_DIR/agent-orchestration-persistence.sh"

# =============================================================================
# 澄清机制集成模块 - 智能调度层
# =============================================================================

# 🎯 澄清机制集成系统

# =============================================================================
# 澄清状态管理
# =============================================================================

# 澄清状态枚举
declare -A CLARIFICATION_STATES=(
    ["idle"]="空闲 - 等待澄清请求"
    ["analyzing"]="分析中 - 分析用户意图"
    ["generating_questions"]="生成中 - 生成澄清问题"
    ["waiting_response"]="等待中 - 等待用户回答"
    ["processing_answer"]="处理中 - 处理用户回答"
    ["integrating"]="整合中 - 整合澄清结果"
    ["completed"]="已完成 - 澄清流程结束"
    ["failed"]="失败 - 澄清流程失败"
)

# 澄清优先级
declare -A CLARIFICATION_PRIORITIES=(
    ["critical"]="100"    # 核心需求澄清，必须回答
    ["important"]="75"    # 重要细节澄清，强烈建议回答
    ["useful"]="50"       # 有用信息澄清，建议回答
    ["optional"]="25"     # 可选信息澄清，可跳过
)

# =============================================================================
# 核心澄清机制函数
# =============================================================================

# 初始化澄清系统
init_clarification_system() {
    local system_id="$1"

    smart_echo "初始化澄清机制集成系统: $system_id" "processing"

    # 创建澄清系统目录
    mkdir -p "$CLARIFICATION_DIR/$system_id"
    mkdir -p "$CLARIFICATION_DIR/$system_id/sessions"
    mkdir -p "$CLARIFICATION_DIR/$system_id/questions"
    mkdir -p "$CLARIFICATION_DIR/$system_id/answers"

    # 创建系统配置文件
    cat > "$CLARIFICATION_DIR/$system_id/config.json" <<EOF
{
  "system_id": "$system_id",
  "max_sessions": 100,
  "question_timeout": 3600,
  "auto_resolve": true,
  "intelligent_ranking": true,
  "context_awareness": true,
  "created_at": "$(date -Iseconds)",
  "stats": {
    "total_questions": 0,
    "answered_questions": 0,
    "pending_questions": 0,
    "avg_response_time": 0
  }
}
EOF

    smart_echo "澄清机制集成系统初始化完成: $system_id" "success"
}

# 创建澄清会话
create_clarification_session() {
    local system_id="$1"
    local session_type="${2:-agent_orchestration}"
    local context_data="${3:-}"

    local session_id="clarification_session_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"
    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"

    mkdir -p "$session_dir"

    # 创建会话元数据
    cat > "$session_dir/metadata.json" <<EOF
{
  "session_id": "$session_id",
  "system_id": "$system_id",
  "type": "$session_type",
  "status": "analyzing",
  "created_at": "$(date -Iseconds)",
  "last_updated": "$(date -Iseconds)",
  "question_count": 0,
  "answered_count": 0,
  "pending_count": 0,
  "context_data": $context_data
}
EOF

    # 创建空的问题列表
    echo "[]" > "$session_dir/questions.json"
    echo "[]" > "$session_dir/answers.json"

    smart_echo "澄清会话已创建: $session_id" "success"
    echo "$session_id"
}

# =============================================================================
# 智能澄清问题生成器
# =============================================================================

# 生成澄清问题
generate_clarification_questions() {
    local session_id="$1"
    local system_id="$2"
    local user_input="$3"
    local context="${4:-}"

    smart_echo "生成澄清问题: $session_id" "processing"

    # 更新会话状态
    update_clarification_session_status "$session_id" "$system_id" "generating_questions"

    # 分析用户输入和上下文
    local analysis_result=$(analyze_input_for_clarification "$user_input" "$context")

    # 生成澄清问题
    local questions=$(generate_questions_from_analysis "$analysis_result")

    # 智能排序问题
    local ranked_questions=$(rank_questions_by_priority "$questions")

    # 保存问题到会话
    save_questions_to_session "$session_id" "$system_id" "$ranked_questions"

    # 更新会话状态
    update_clarification_session_status "$session_id" "$system_id" "waiting_response"

    smart_echo "澄清问题生成完成: $(echo "$ranked_questions" | jq 'length') 个问题" "success"
    echo "$ranked_questions"
}

# 分析输入是否需要澄清
analyze_input_for_clarification() {
    local user_input="$1"
    local context="$2"

    # 基于conversation_intent_analyzer.md的分析逻辑
    local analysis_result=$(cat <<EOF
{
  "input_length": $(echo -n "$user_input" | wc -c),
  "has_ambiguity": $(detect_ambiguity "$user_input"),
  "missing_details": $(identify_missing_details "$user_input" "$context"),
  "technical_complexity": $(assess_technical_complexity "$user_input"),
  "domain_knowledge": $(check_domain_knowledge "$user_input"),
  "confidence_score": $(calculate_confidence_score "$user_input" "$context"),
  "suggested_questions": $(generate_suggested_questions "$user_input" "$context")
}
EOF
)

    echo "$analysis_result"
}

# 检测歧义
detect_ambiguity() {
    local input="$1"

    # 简单的歧义检测逻辑
    local ambiguity_indicators=(
        "大概\|可能\|或许\|也许"
        "之类的\|什么的\|等等"
        "不确定\|不清楚\|不明白"
        "或者\|还是\|或者说"
    )

    for indicator in "${ambiguity_indicators[@]}"; do
        if echo "$input" | grep -q "$indicator"; then
            echo "true"
            return
        fi
    done

    echo "false"
}

# 识别缺失细节
identify_missing_details() {
    local input="$1"
    local context="$2"

    # 检查常见的缺失信息
    local missing_details=()

    # 检查技术栈
    if ! echo "$input" | grep -q -i "python\|java\|javascript\|typescript\|go\|rust\|c++\|php"; then
        missing_details+=("technology_stack")
    fi

    # 检查项目类型
    if ! echo "$input" | grep -q -i "web\|api\|mobile\|desktop\|cli\|library\|framework"; then
        missing_details+=("project_type")
    fi

    # 检查具体需求
    if ! echo "$input" | grep -q -i "功能\|feature\|requirement\|spec"; then
        missing_details+=("specific_requirements")
    fi

    # 检查时间限制
    if ! echo "$input" | grep -q -i "deadline\|time\|urgent\|quick"; then
        missing_details+=("timeline_constraints")
    fi

    # 返回JSON数组
    printf '%s\n' "${missing_details[@]}" | jq -R . | jq -s .
}

# 评估技术复杂度
assess_technical_complexity() {
    local input="$1"

    # 基于关键词的复杂度评估
    local complexity_score=1

    # 高复杂度关键词
    if echo "$input" | grep -q -i "microservice\|distributed\|blockchain\|ai\|ml\|real.*time"; then
        complexity_score=5
    # 中高复杂度关键词
    elif echo "$input" | grep -q -i "concurrent\|async\|scalable\|security\|performance"; then
        complexity_score=4
    # 中等复杂度关键词
    elif echo "$input" | grep -q -i "database\|api\|authentication\|testing"; then
        complexity_score=3
    # 低复杂度关键词
    elif echo "$input" | grep -q -i "crud\|simple\|basic\|hello.*world"; then
        complexity_score=2
    fi

    echo "$complexity_score"
}

# 检查领域知识
check_domain_knowledge() {
    local input="$1"

    # 检查是否包含领域特定术语
    local domain_terms=(
        "frontend\|backend\|fullstack"
        "react\|vue\|angular\|svelte"
        "nodejs\|django\|flask\|spring"
        "postgresql\|mysql\|mongodb\|redis"
        "docker\|kubernetes\|aws\|azure"
    )

    local domain_score=0
    for term in "${domain_terms[@]}"; do
        if echo "$input" | grep -q -i "$term"; then
            ((domain_score++))
        fi
    done

    echo "$domain_score"
}

# 计算置信度分数
calculate_confidence_score() {
    local input="$1"
    local context="$2"

    # 基于多个因素计算置信度
    local base_score=0.5

    # 输入长度因子
    local input_length=$(echo -n "$input" | wc -c)
    if (( input_length > 100 )); then
        base_score=$(( base_score + 0.2 ))
    elif (( input_length < 20 )); then
        base_score=$(( base_score - 0.2 ))
    fi

    # 技术细节因子
    local tech_count=$(check_domain_knowledge "$input")
    base_score=$(( base_score + tech_count * 0.1 ))

    # 歧义因子
    if [[ "$(detect_ambiguity "$input")" == "true" ]]; then
        base_score=$(( base_score - 0.3 ))
    fi

    # 确保分数在0-1范围内
    if (( $(echo "$base_score > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        base_score=1.0
    elif (( $(echo "$base_score < 0.0" | bc -l 2>/dev/null || echo "0") )); then
        base_score=0.0
    fi

    printf "%.2f" "$base_score"
}

# 生成建议问题
generate_suggested_questions() {
    local input="$1"
    local context="$2"

    # 基于分析结果生成针对性问题
    local questions=()

    # 如果没有指定技术栈
    if ! echo "$input" | grep -q -i "python\|java\|javascript\|typescript"; then
        questions+=("{\"question\": \"您希望使用哪种编程语言和技术栈？\", \"priority\": \"critical\", \"category\": \"technology\"}")
    fi

    # 如果没有指定项目类型
    if ! echo "$input" | grep -q -i "web\|api\|mobile\|desktop"; then
        questions+=("{\"question\": \"这是一个什么类型的项目？(Web应用/API/移动应用/桌面应用等)\", \"priority\": \"important\", \"category\": \"project_type\"}")
    fi

    # 如果没有具体需求描述
    if ! echo "$input" | grep -q -i "功能\|feature\|requirement"; then
        questions+=("{\"question\": \"能详细描述一下项目的具体功能需求吗？\", \"priority\": \"important\", \"category\": \"requirements\"}")
    fi

    # 如果没有时间要求
    if ! echo "$input" | grep -q -i "deadline\|time\|urgent"; then
        questions+=("{\"question\": \"项目的交付时间有什么要求吗？\", \"priority\": \"useful\", \"category\": \"timeline\"}")
    fi

    # 返回JSON数组
    printf '%s\n' "${questions[@]}" | jq -s .
}

# 从分析结果生成问题
generate_questions_from_analysis() {
    local analysis="$1"

    local suggested_questions=$(echo "$analysis" | jq -r '.suggested_questions')

    # 如果建议问题不够，生成额外的通用问题
    local question_count=$(echo "$suggested_questions" | jq 'length')
    if (( question_count < 3 )); then
        local additional_questions=(
            "{\"question\": \"您对项目的技术选型有什么偏好或限制吗？\", \"priority\": \"useful\", \"category\": \"preferences\"}"
            "{\"question\": \"项目需要考虑哪些非功能性需求？(性能、安全、可扩展性等)\", \"priority\": \"optional\", \"category\": \"non_functional\"}"
            "{\"question\": \"您希望项目采用什么样的架构模式？\", \"priority\": \"optional\", \"category\": \"architecture\"}"
        )

        for question in "${additional_questions[@]}"; do
            if (( question_count < 5 )); then
                suggested_questions=$(echo "$suggested_questions" | jq --arg q "$question" '. += [$q | fromjson]')
                ((question_count++))
            fi
        done
    fi

    echo "$suggested_questions"
}

# 按优先级排序问题
rank_questions_by_priority() {
    local questions="$1"

    echo "$questions" | jq '
        sort_by(
            if .priority == "critical" then 100
            elif .priority == "important" then 75
            elif .priority == "useful" then 50
            elif .priority == "optional" then 25
            else 0 end
        ) | reverse
    '
}

# 保存问题到会话
save_questions_to_session() {
    local session_id="$1"
    local system_id="$2"
    local questions="$3"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"

    # 保存问题列表
    echo "$questions" > "$session_dir/questions.json"

    # 更新会话元数据
    local question_count=$(echo "$questions" | jq 'length')
    jq --arg count "$question_count" '.question_count = ($count | tonumber) | .pending_count = ($count | tonumber)' \
       "$session_dir/metadata.json" > "${session_dir}/metadata.json.tmp" && mv "${session_dir}/metadata.json.tmp" "$session_dir/metadata.json"

    # 保存每个问题到单独文件
    echo "$questions" | jq -c '.[]' | while read -r question; do
        local question_id=$(echo "$question" | jq -r '.question_id // empty')
        if [[ -z "$question_id" ]]; then
            question_id="question_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"
            question=$(echo "$question" | jq --arg id "$question_id" '.question_id = $id')
        fi

        echo "$question" > "$CLARIFICATION_DIR/$system_id/questions/${question_id}.json"
    done
}

# =============================================================================
# 异步澄清等待和答案整合
# =============================================================================

# 等待澄清答案
wait_for_clarification_answers() {
    local session_id="$1"
    local system_id="$2"
    local timeout="${3:-3600}"  # 默认1小时超时

    smart_echo "开始等待澄清答案: $session_id (超时: ${timeout}s)" "processing"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"
    local start_time=$(date +%s)
    local answered_count=0
    local total_questions=$(jq -r '.question_count' "$session_dir/metadata.json")

    while true; do
        # 检查是否所有问题都已回答
        answered_count=$(jq -r '.answered_count' "$session_dir/metadata.json")
        if (( answered_count >= total_questions )); then
            smart_echo "所有澄清问题已回答完成" "success"
            update_clarification_session_status "$session_id" "$system_id" "integrating"
            integrate_clarification_answers "$session_id" "$system_id"
            return 0
        fi

        # 检查超时
        local current_time=$(date +%s)
        if (( current_time - start_time >= timeout )); then
            smart_echo "澄清等待超时 (${timeout}s)" "warning"
            handle_clarification_timeout "$session_id" "$system_id"
            return 1
        fi

        # 等待一段时间后重新检查
        sleep 30  # 每30秒检查一次
    done
}

# 提交澄清答案
submit_clarification_answer() {
    local session_id="$1"
    local system_id="$2"
    local question_id="$3"
    local answer="$4"

    smart_echo "提交澄清答案: $question_id" "processing"

    # 验证问题是否存在
    if [[ ! -f "$CLARIFICATION_DIR/$system_id/questions/${question_id}.json" ]]; then
        smart_echo "问题不存在: $question_id" "error"
        return 1
    fi

    # 创建答案记录
    local answer_record=$(cat <<EOF
{
  "question_id": "$question_id",
  "answer": "$answer",
  "submitted_at": "$(date -Iseconds)",
  "session_id": "$session_id",
  "validated": false
}
EOF
)

    # 保存答案
    echo "$answer_record" > "$CLARIFICATION_DIR/$system_id/answers/${question_id}.json"

    # 更新会话状态
    update_session_answer_count "$session_id" "$system_id"

    smart_echo "澄清答案已提交: $question_id" "success"
}

# 更新会话答案计数
update_session_answer_count() {
    local session_id="$1"
    local system_id="$2"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"
    local answers_dir="$CLARIFICATION_DIR/$system_id/answers"

    # 计算已回答的问题数
    local answered_count=$(find "$answers_dir" -name "*.json" -exec jq -r '.session_id' {} \; 2>/dev/null | grep -c "^$session_id$" || echo "0")

    # 更新会话元数据
    jq --arg answered "$answered_count" \
       '.answered_count = ($answered | tonumber) | .pending_count = (.question_count - ($answered | tonumber))' \
       "$session_dir/metadata.json" > "${session_dir}/metadata.json.tmp" && mv "${session_dir}/metadata.json.tmp" "$session_dir/metadata.json"
}

# 整合澄清答案
integrate_clarification_answers() {
    local session_id="$1"
    local system_id="$2"

    smart_echo "整合澄清答案: $session_id" "processing"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"
    local answers_dir="$CLARIFICATION_DIR/$system_id/answers"

    # 收集所有答案
    local integrated_answers=$(find "$answers_dir" -name "*.json" -exec jq -c 'select(.session_id == "'$session_id'")' {} \; 2>/dev/null | jq -s '.')

    # 按类别组织答案
    local categorized_answers=$(categorize_answers "$integrated_answers")

    # 生成整合报告
    local integration_report=$(cat <<EOF
{
  "session_id": "$session_id",
  "integration_timestamp": "$(date -Iseconds)",
  "total_answers": $(echo "$integrated_answers" | jq 'length'),
  "categorized_answers": $categorized_answers,
  "confidence_score": $(calculate_integration_confidence "$integrated_answers"),
  "recommendations": $(generate_integration_recommendations "$categorized_answers")
}
EOF
)

    # 保存整合结果
    echo "$integration_report" > "$session_dir/integration_report.json"

    # 更新会话状态
    update_clarification_session_status "$session_id" "$system_id" "completed"

    smart_echo "澄清答案整合完成" "success"
}

# 按类别组织答案
categorize_answers() {
    local answers="$1"

    # 按问题类别分组
    echo "$answers" | jq '
        group_by(.question.category // "general") |
        map({
            category: .[0].question.category // "general",
            answers: map({
                question: .question.question,
                answer: .answer,
                submitted_at: .submitted_at
            })
        })
    '
}

# 计算整合置信度
calculate_integration_confidence() {
    local answers="$1"

    # 基于答案质量和完整性计算置信度
    local answer_count=$(echo "$answers" | jq 'length')
    local avg_answer_length=$(echo "$answers" | jq '[.[] | (.answer | length)] | add / length')

    # 简单的置信度计算
    local base_confidence=0.8
    if (( answer_count > 5 )); then
        base_confidence=$(( base_confidence + 0.1 ))
    fi
    if (( avg_answer_length > 50 )); then
        base_confidence=$(( base_confidence + 0.1 ))
    fi

    printf "%.2f" "$base_confidence"
}

# 生成整合建议
generate_integration_recommendations() {
    local categorized_answers="$1"

    # 基于答案分析生成建议
    local recommendations=()

    # 检查技术栈一致性
    local tech_stack_answers=$(echo "$categorized_answers" | jq '.[] | select(.category == "technology") | .answers' 2>/dev/null || echo "[]")
    if [[ "$(echo "$tech_stack_answers" | jq 'length')" -eq "0" ]]; then
        recommendations+=("建议明确技术栈选择")
    fi

    # 检查需求完整性
    local req_answers=$(echo "$categorized_answers" | jq '.[] | select(.category == "requirements") | .answers' 2>/dev/null || echo "[]")
    if [[ "$(echo "$req_answers" | jq 'length')" -eq "0" ]]; then
        recommendations+=("建议完善需求规格说明")
    fi

    # 返回JSON数组
    printf '%s\n' "${recommendations[@]}" | jq -R . | jq -s .
}

# 处理澄清超时
handle_clarification_timeout() {
    local session_id="$1"
    local system_id="$2"

    smart_echo "处理澄清超时: $session_id" "warning"

    # 使用默认答案或标记为可选
    auto_resolve_pending_questions "$session_id" "$system_id"

    # 更新状态
    update_clarification_session_status "$session_id" "$system_id" "completed"
}

# 自动解决待决问题
auto_resolve_pending_questions() {
    local session_id="$1"
    local system_id="$2"

    smart_echo "自动解决待决澄清问题" "processing"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"
    local questions=$(cat "$session_dir/questions.json")

    # 为每个未回答的问题生成默认答案
    echo "$questions" | jq -c '.[]' | while read -r question; do
        local question_id=$(echo "$question" | jq -r '.question_id')
        local priority=$(echo "$question" | jq -r '.priority')

        # 只为非critical问题生成默认答案
        if [[ "$priority" != "critical" ]]; then
            local default_answer="用户未提供具体信息，使用默认设置"
            submit_clarification_answer "$session_id" "$system_id" "$question_id" "$default_answer"
        fi
    done
}

# =============================================================================
# 澄清状态持久化
# =============================================================================

# 持久化澄清状态
persist_clarification_state() {
    local session_id="$1"
    local system_id="$2"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"

    # 创建状态快照
    local state_snapshot=$(cat <<EOF
{
  "session_id": "$session_id",
  "system_id": "$system_id",
  "persisted_at": "$(date -Iseconds)",
  "metadata": $(cat "$session_dir/metadata.json"),
  "questions": $(cat "$session_dir/questions.json"),
  "answers": $(find "$CLARIFICATION_DIR/$system_id/answers" -name "*.json" -exec jq -c 'select(.session_id == "'$session_id'")' {} \; 2>/dev/null | jq -s '.'),
  "integration_report": $(cat "$session_dir/integration_report.json" 2>/dev/null || echo "null")
}
EOF
)

    # 保存状态快照
    echo "$state_snapshot" > "$session_dir/state_snapshot.json"

    smart_echo "澄清状态已持久化: $session_id" "success"
}

# 从持久化状态恢复
restore_clarification_state() {
    local session_id="$1"
    local system_id="$2"

    local session_dir="$CLARIFICATION_DIR/$system_id/sessions/$session_id"
    local state_file="$session_dir/state_snapshot.json"

    if [[ ! -f "$state_file" ]]; then
        smart_echo "状态快照不存在: $session_id" "error"
        return 1
    fi

    smart_echo "从持久化状态恢复: $session_id" "processing"

    # 恢复元数据
    cat "$state_file" | jq -r '.metadata' > "$session_dir/metadata.json"

    # 恢复问题
    cat "$state_file" | jq -r '.questions' > "$session_dir/questions.json"

    # 恢复答案
    local answers=$(cat "$state_file" | jq -r '.answers')
    echo "$answers" | jq -c '.[]' | while read -r answer; do
        local question_id=$(echo "$answer" | jq -r '.question_id')
        echo "$answer" > "$CLARIFICATION_DIR/$system_id/answers/${question_id}.json"
    done

    # 恢复整合报告
    if [[ "$(cat "$state_file" | jq -r '.integration_report')" != "null" ]]; then
        cat "$state_file" | jq -r '.integration_report' > "$session_dir/integration_report.json"
    fi

    smart_echo "澄清状态恢复完成: $session_id" "success"
}

# =============================================================================
# 辅助函数
# =============================================================================

# 更新澄清会话状态
update_clarification_session_status() {
    local session_id="$1"
    local system_id="$2"
    local status="$3"

    local metadata_file="$CLARIFICATION_DIR/$system_id/sessions/$session_id/metadata.json"

    if [[ -f "$metadata_file" ]]; then
        jq --arg status "$status" --arg time "$(date -Iseconds)" \
           '.status = $status | .last_updated = $time' \
           "$metadata_file" > "${metadata_file}.tmp" && mv "${metadata_file}.tmp" "$metadata_file"
    fi
}

# 获取澄清会话状态
get_clarification_session_status() {
    local session_id="$1"
    local system_id="$2"

    local metadata_file="$CLARIFICATION_DIR/$system_id/sessions/$session_id/metadata.json"

    if [[ -f "$metadata_file" ]]; then
        cat "$metadata_file"
    else
        echo '{"status": "not_found"}'
    fi
}

# 获取系统统计
get_clarification_system_stats() {
    local system_id="$1"

    local config_file="$CLARIFICATION_DIR/$system_id/config.json"

    if [[ ! -f "$config_file" ]]; then
        echo '{"status": "not_found"}'
        return 1
    fi

    local session_count=$(find "$CLARIFICATION_DIR/$system_id/sessions" -name "metadata.json" 2>/dev/null | wc -l)
    local question_count=$(find "$CLARIFICATION_DIR/$system_id/questions" -name "*.json" 2>/dev/null | wc -l)
    local answer_count=$(find "$CLARIFICATION_DIR/$system_id/answers" -name "*.json" 2>/dev/null | wc -l)

    jq --arg sessions "$session_count" --arg questions "$question_count" --arg answers "$answer_count" \
       '. + {active_sessions: ($sessions | tonumber), total_questions: ($questions | tonumber), total_answers: ($answers | tonumber)}' \
       "$config_file"
}

# =============================================================================
# 函数导出
# =============================================================================

export -f init_clarification_system
export -f create_clarification_session
export -f generate_clarification_questions
export -f wait_for_clarification_answers
export -f submit_clarification_answer
export -f integrate_clarification_answers
export -f persist_clarification_state
export -f restore_clarification_state
export -f get_clarification_session_status
export -f get_clarification_system_stats

# 初始化目录
CLARIFICATION_DIR="$AI_DIR/clarification_systems"
mkdir -p "$CLARIFICATION_DIR"

smart_echo "澄清机制集成模块已加载" "success"