#!/bin/bash
# ========================================
# Cursor AI Rules - 选择题确认系统
# 实现选择题为主的多轮确认机制，确保充分沟通后再编码
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-core.sh"

# =============================================================================
# 选择题确认系统 - 智能调度层核心模块
# =============================================================================

# 🎯 选择题确认系统

# =============================================================================
# 选择题模板库
# =============================================================================

# 技术栈选择题模板
declare -A TECH_STACK_TEMPLATES=(
    ["frontend"]="前端技术栈选择"
    ["backend"]="后端技术栈选择"
    ["database"]="数据库选择"
    ["deployment"]="部署方式选择"
    ["architecture"]="架构模式选择"
)

# 选择题模板定义
get_frontend_stack_template() {
    cat <<EOF
{
  "category": "technology_stack",
  "question_type": "single_choice",
  "question": "请选择您偏好的前端技术栈：",
  "options": [
    {"id": "react", "label": "React + TypeScript (推荐)", "description": "现代化前端框架，类型安全，生态丰富"},
    {"id": "vue", "label": "Vue.js + JavaScript", "description": "轻量级框架，学习曲线平缓"},
    {"id": "angular", "label": "Angular + TypeScript", "description": "企业级框架，功能完整"},
    {"id": "vanilla", "label": "原生JavaScript + HTML/CSS", "description": "无框架，轻量级"},
    {"id": "other", "label": "其他 (请说明)", "description": "自定义技术栈", "allow_custom": true}
  ],
  "required": true,
  "priority": "critical"
}
EOF
}

get_backend_stack_template() {
    cat <<EOF
{
  "category": "technology_stack",
  "question_type": "single_choice",
  "question": "请选择您偏好的后端技术栈：",
  "options": [
    {"id": "nodejs", "label": "Node.js + Express", "description": "JavaScript全栈，开发效率高"},
    {"id": "python", "label": "Python + FastAPI", "description": "现代化Python框架，性能优秀"},
    {"id": "java", "label": "Java + Spring Boot", "description": "企业级Java框架，稳定可靠"},
    {"id": "go", "label": "Go + Gin", "description": "高性能微服务框架"},
    {"id": "other", "label": "其他 (请说明)", "description": "自定义技术栈", "allow_custom": true}
  ],
  "required": true,
  "priority": "critical"
}
EOF
}

get_project_scale_template() {
    cat <<EOF
{
  "category": "project_scale",
  "question_type": "single_choice",
  "question": "这个项目的预期规模是：",
  "options": [
    {"id": "prototype", "label": "原型/概念验证", "description": "快速验证想法，功能简单"},
    {"id": "small_app", "label": "小型应用", "description": "个人项目或小型工具"},
    {"id": "medium_app", "label": "中型应用", "description": "团队项目，有一定复杂度"},
    {"id": "large_system", "label": "大型系统", "description": "企业级应用，高并发要求"},
    {"id": "platform", "label": "平台级产品", "description": "复杂分布式系统"}
  ],
  "required": true,
  "priority": "important"
}
EOF
}

get_timeline_template() {
    cat <<EOF
{
  "category": "timeline",
  "question_type": "single_choice",
  "question": "项目的预期交付时间是：",
  "options": [
    {"id": "rush", "label": "紧急 (1-2周)", "description": "快速原型，功能简化"},
    {"id": "normal", "label": "正常 (1个月)", "description": "标准开发周期"},
    {"id": "extended", "label": "延展 (2-3个月)", "description": "充分考虑质量和完善性"},
    {"id": "long_term", "label": "长期项目", "description": "持续迭代，长期维护"}
  ],
  "required": false,
  "priority": "useful"
}
EOF
}

get_architecture_template() {
    cat <<EOF
{
  "category": "architecture",
  "question_type": "single_choice",
  "question": "您希望采用的系统架构是：",
  "options": [
    {"id": "monolithic", "label": "单体架构", "description": "简单统一，易于开发和部署"},
    {"id": "microservices", "label": "微服务架构", "description": "可扩展性强，技术栈灵活"},
    {"id": "serverless", "label": "Serverless架构", "description": "无服务器，自动扩展"},
    {"id": "hybrid", "label": "混合架构", "description": "根据需求选择合适架构"}
  ],
  "required": false,
  "priority": "useful"
}
EOF
}

# =============================================================================
# 选择题生成引擎
# =============================================================================

# 生成选择题序列
generate_choicetion_sequence() {
    local user_input="$1"
    local complexity_analysis="$2"
    local context="${3:-}"

    # smart_echo "🎯 生成选择题确认序列" "processing"

    # 基于复杂度分析确定问题序列
    local total_complexity=3.0  # 默认值
    if [[ -n "$complexity_analysis" ]]; then
        total_complexity=$(echo "$complexity_analysis" | jq -r '.total_complexity // 3.0' 2>/dev/null || echo "3.0")
    fi

    # 生成固定的测试序列 (确保基本功能工作)
    local session_id="choicetion_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"
    local generated_at="$(date -Iseconds)"

    local question_sequence=$(cat <<EOF
{
  "session_id": "$session_id",
  "generated_at": "$generated_at",
  "total_complexity": 3.8,
  "required_confirmations": 3,
  "current_confirmations": 0,
  "core_questions": [
    {
      "category": "technology_stack",
      "question_type": "single_choice",
      "question": "请选择您偏好的前端技术栈：",
      "options": [
        {"id": "react", "label": "React + TypeScript (推荐)", "description": "现代化前端框架，类型安全，生态丰富"},
        {"id": "vue", "label": "Vue.js + JavaScript", "description": "轻量级框架，学习曲线平缓"},
        {"id": "other", "label": "其他 (请说明)", "description": "自定义技术栈", "allow_custom": true}
      ],
      "required": true,
      "priority": "critical"
    },
    {
      "category": "project_scale",
      "question_type": "single_choice",
      "question": "这个项目的预期规模是：",
      "options": [
        {"id": "small_app", "label": "小型应用", "description": "个人项目或小型工具"},
        {"id": "medium_app", "label": "中型应用", "description": "团队项目，有一定复杂度"},
        {"id": "large_system", "label": "大型系统", "description": "企业级应用，高并发要求"}
      ],
      "required": true,
      "priority": "important"
    }
  ],
  "additional_questions": [
    {
      "category": "timeline",
      "question_type": "single_choice",
      "question": "项目的预期交付时间是：",
      "options": [
        {"id": "normal", "label": "正常 (1个月)", "description": "标准开发周期"},
        {"id": "extended", "label": "延展 (2-3个月)", "description": "充分考虑质量和完善性"}
      ],
      "required": false,
      "priority": "useful"
    }
  ],
  "user_answers": [],
  "confirmation_status": "in_progress",
  "can_proceed_to_coding": false
}
EOF
)

    # smart_echo "✅ 选择题序列生成完成: $(echo "$question_sequence" | jq '.core_questions | length' 2>/dev/null || echo "2") 个核心问题" "success"
    echo "$question_sequence"
}

# 获取下一个需要回答的问题
get_next_choicetion_question() {
    local session_data="$1"

    local core_questions=$(echo "$session_data" | jq -r '.core_questions')
    local additional_questions=$(echo "$session_data" | jq -r '.additional_questions')
    local user_answers=$(echo "$session_data" | jq -r '.user_answers')
    local current_confirmations=$(echo "$session_data" | jq -r '.current_confirmations')

    # 检查是否已完成核心问题
    local core_count=$(echo "$core_questions" | jq 'length')
    local answered_core=0

    # 计算已回答的核心问题数
    for ((i=0; i<core_count; i++)); do
        local question_category=$(echo "$core_questions" | jq -r ".[$i].category")
        if echo "$user_answers" | jq -e ".[] | select(.category == \"$question_category\")" >/dev/null 2>&1; then
            ((answered_core++))
        fi
    done

    # 如果核心问题还没答完，返回下一个核心问题
    if (( answered_core < core_count )); then
        local next_question=$(echo "$core_questions" | jq ".[$answered_core]")
        echo "$next_question"
        return
    fi

    # 核心问题答完后，如果确认次数不够，返回确认问题
    local required_confirmations=$(echo "$session_data" | jq -r '.required_confirmations')
    if (( current_confirmations < required_confirmations )); then
        get_confirmation_question "$session_data"
        return
    fi

    # 如果还有附加问题且确认次数足够，可以询问附加问题
    local additional_count=$(echo "$additional_questions" | jq 'length')
    local answered_additional=0

    for ((i=0; i<additional_count; i++)); do
        local question_category=$(echo "$additional_questions" | jq -r ".[$i].category")
        if echo "$user_answers" | jq -e ".[] | select(.category == \"$question_category\")" >/dev/null 2>&1; then
            ((answered_additional++))
        fi
    done

    if (( answered_additional < additional_count )); then
        local next_question=$(echo "$additional_questions" | jq ".[$answered_additional]")
        echo "$next_question"
        return
    fi

    # 所有问题都答完了
    echo '{"status": "completed"}'
}

# 获取确认问题
get_confirmation_question() {
    local session_data="$1"

    local current_confirmations=$(echo "$session_data" | jq -r '.current_confirmations')
    local required_confirmations=$(echo "$session_data" | jq -r '.required_confirmations')

    cat <<EOF
{
  "category": "confirmation",
  "question_type": "single_choice",
  "question": "确认问题 $(($current_confirmations + 1))/$required_confirmations：您是否满意以上选择？",
  "description": "这是第 $(($current_confirmations + 1)) 次确认，确保您已经充分考虑了所有选项。",
  "options": [
    {"id": "confirm", "label": "✅ 确认，继续下一步", "description": "我满意当前的选择"},
    {"id": "modify", "label": "🔄 修改之前的选择", "description": "我想重新选择某些选项"},
    {"id": "add_info", "label": "📝 补充更多信息", "description": "我想提供更多需求细节"},
    {"id": "cancel", "label": "❌ 取消项目", "description": "暂时不需要这个项目"}
  ],
  "required": true,
  "priority": "critical",
  "confirmation_round": $(($current_confirmations + 1))
}
EOF
}

# 提交选择题答案
submit_choicetion_answer() {
    local session_data="$1"
    local question_category="$2"
    local answer="$3"
    local custom_input="${4:-}"

    smart_echo "📝 提交选择题答案: $question_category = $answer" "processing"

    # 创建答案记录
    local answer_record=$(cat <<EOF
{
  "category": "$question_category",
  "answer": "$answer",
  "custom_input": "$custom_input",
  "submitted_at": "$(date -Iseconds)",
  "confirmation_round": $(echo "$session_data" | jq -r '.current_confirmations // 0')
}
EOF
)

    # 更新会话数据
    local updated_session=$(echo "$session_data" | jq --argjson answer "$answer_record" '.user_answers += [$answer]')

    # 如果是确认问题，增加确认计数
    if [[ "$question_category" == "confirmation" && "$answer" == "confirm" ]]; then
        local current_confirmations=$(echo "$updated_session" | jq -r '.current_confirmations')
        updated_session=$(echo "$updated_session" | jq --arg count "$(($current_confirmations + 1))" '.current_confirmations = ($count | tonumber)')
    fi

    # 检查是否可以开始编码
    local required_confirmations=$(echo "$updated_session" | jq -r '.required_confirmations')
    local current_confirmations=$(echo "$updated_session" | jq -r '.current_confirmations')
    local all_core_answered=true

    # 检查所有核心问题是否已回答
    local core_questions=$(echo "$updated_session" | jq -r '.core_questions')
    local core_count=$(echo "$core_questions" | jq 'length')

    for ((i=0; i<core_count; i++)); do
        local question_category_check=$(echo "$core_questions" | jq -r ".[$i].category")
        if ! echo "$updated_session" | jq -e ".user_answers[] | select(.category == \"$question_category_check\")" >/dev/null 2>&1; then
            all_core_answered=false
            break
        fi
    done

    # 更新编码权限
    if [[ "$all_core_answered" == "true" ]] && (( current_confirmations >= required_confirmations )); then
        updated_session=$(echo "$updated_session" | jq '.can_proceed_to_coding = true | .confirmation_status = "completed"')
        smart_echo "🎉 所有确认完成，可以开始编码！" "success"
    fi

    echo "$updated_session"
}

# 检查是否可以开始编码
can_proceed_to_coding() {
    local session_data="$1"

    local can_proceed=$(echo "$session_data" | jq -r '.can_proceed_to_coding // false')
    echo "$can_proceed"
}

# 获取选择题确认摘要
get_choicetion_summary() {
    local session_data="$1"

    local summary=$(cat <<EOF
{
  "session_id": "$(echo "$session_data" | jq -r '.session_id')",
  "total_questions": $(($(echo "$session_data" | jq '.core_questions | length') + $(echo "$session_data" | jq '.additional_questions | length'))),
  "answered_questions": $(echo "$session_data" | jq '.user_answers | length'),
  "confirmations_completed": $(echo "$session_data" | jq -r '.current_confirmations'),
  "required_confirmations": $(echo "$session_data" | jq -r '.required_confirmations'),
  "can_proceed_to_coding": $(echo "$session_data" | jq -r '.can_proceed_to_coding // false'),
  "status": "$(echo "$session_data" | jq -r '.confirmation_status')",
  "user_choices": $(echo "$session_data" | jq '[.user_answers[] | {category: .category, answer: .answer, custom_input: .custom_input}]')
}
EOF
)

    echo "$summary"
}

# =============================================================================
# 选择题用户界面
# =============================================================================

# 显示选择题问题
display_choicetion_question() {
    local question="$1"

    local question_text=$(echo "$question" | jq -r '.question')
    local question_type=$(echo "$question" | jq -r '.question_type')
    local category=$(echo "$question" | jq -r '.category')
    local priority=$(echo "$question" | jq -r '.priority')
    local description=$(echo "$question" | jq -r '.description // empty')

    echo ""
    echo "🎯 $question_text"
    if [[ -n "$description" ]]; then
        echo "ℹ️  $description"
    fi
    echo ""

    # 显示选项
    local options=$(echo "$question" | jq -r '.options')
    local option_count=$(echo "$options" | jq 'length')

    for ((i=0; i<option_count; i++)); do
        local option=$(echo "$options" | jq ".[$i]")
        local id=$(echo "$option" | jq -r '.id')
        local label=$(echo "$option" | jq -r '.label')
        local option_desc=$(echo "$option" | jq -r '.description // empty')
        local allow_custom=$(echo "$option" | jq -r '.allow_custom // false')

        echo "$((i+1)). $label"
        if [[ -n "$option_desc" ]]; then
            echo "   $option_desc"
        fi
        if [[ "$allow_custom" == "true" ]]; then
            echo "   💡 选择此项可提供自定义输入"
        fi
        echo ""
    done

    echo "请输入选项编号 (1-$option_count):"
}

# =============================================================================
# 选择题执行引擎
# =============================================================================

# 执行完整的选择题确认流程
execute_choicetion_confirmation() {
    local user_input="$1"
    local context="$2"
    local complexity_analysis="$3"

    smart_echo "🎯 启动选择题确认流程" "processing"

    # 生成选择题序列
    local question_sequence=$(generate_choicetion_sequence "$user_input" "$complexity_analysis" "$context")

    # 模拟用户交互过程 (实际实现中会与用户交互)
    local current_session="$question_sequence"

    smart_echo "📋 开始多轮确认过程 (至少需要3次确认)" "info"

    # 这里返回确认状态，实际的交互逻辑会在更高层实现
    cat <<EOF
{
  "confirmation_status": "sequence_generated",
  "question_sequence": $question_sequence,
  "message": "选择题确认序列已生成，请开始回答问题",
  "next_action": "get_next_question"
}
EOF
}

# =============================================================================
# 函数导出
# =============================================================================

export -f generate_choicetion_sequence
export -f get_next_choicetion_question
export -f submit_choicetion_answer
export -f can_proceed_to_coding
export -f get_choicetion_summary
export -f display_choicetion_question
export -f execute_choicetion_confirmation

# 初始化目录
CHOICETION_DIR="$AI_DIR/choicetion_system"
mkdir -p "$CHOICETION_DIR"

smart_echo "🎯 选择题确认系统模块已加载" "success"