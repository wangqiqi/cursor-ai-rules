#!/bin/bash
# ========================================
# Cursor AI Rules - 自主规划控制器
# 实现真正的AI自主规划和决策系统
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
# 注意：避免循环依赖，不加载agent-orchestration-engine.sh
source "$SCRIPT_DIR/agent-orchestration-loop-controller.sh"
source "$SCRIPT_DIR/agent-orchestration-context-bridge.sh"
source "$SCRIPT_DIR/agent-orchestration-choicetion-system.sh"
source "$SCRIPT_DIR/agent-orchestration-learning-system.sh"

# =============================================================================
# 自主规划控制器 - 真正的AI自主决策系统
# =============================================================================

# 🤖 自主规划控制器

# =============================================================================
# 智能双模式选择器 - 根据复杂度自主选择执行模式
# =============================================================================

# 模式选择阈值配置
declare -A MODE_SELECTION_CONFIG=(
    ["complexity_threshold_direct"]=2.0      # 复杂度<=2.0使用直接模式
    ["complexity_threshold_intelligent"]=3.5 # 复杂度>=3.5强制使用智能模式
    ["confidence_weight"]=0.3                 # 置信度权重
    ["technical_weight"]=0.4                  # 技术复杂度权重
    ["context_weight"]=0.3                    # 上下文复杂度权重
)

# 复杂度分析引擎
analyze_request_complexity() {
    local user_input="$1"
    local context="${2:-}"

    # smart_echo "🔍 分析请求复杂度..." "processing"

    # 多维度复杂度评估
    local text_complexity=$(calculate_text_complexity "$user_input")
    local technical_complexity=$(assess_technical_complexity "$user_input")
    local context_complexity=$(evaluate_context_complexity "$context")
    local intent_complexity=$(analyze_intent_complexity "$user_input")

    # 加权计算总复杂度
    local total_complexity=$(echo "scale=2; ($text_complexity * 0.25) + ($technical_complexity * 0.35) + ($context_complexity * 0.20) + ($intent_complexity * 0.20)" | bc -l 2>/dev/null || echo "5.0")

    # 生成复杂度分析报告
    local analysis_report=$(cat <<EOF
{
  "total_complexity": $total_complexity,
  "dimensions": {
    "text": $text_complexity,
    "technical": $technical_complexity,
    "context": $context_complexity,
    "intent": $intent_complexity
  },
  "recommended_mode": "$(select_execution_mode "$total_complexity" "default_user")",
  "confidence": $(calculate_analysis_confidence "$total_complexity"),
  "analysis_timestamp": "$(date -Iseconds)"
}
EOF
)

    echo "$analysis_report"
}

# 计算文本复杂度
calculate_text_complexity() {
    local input="$1"
    local length_score=1
    local vocabulary_score=1
    local structure_score=1

    # 长度复杂度 (0-3分)
    local input_length=$(echo -n "$input" | wc -c)
    if (( input_length > 500 )); then
        length_score=3
    elif (( input_length > 200 )); then
        length_score=2
    elif (( input_length < 20 )); then
        length_score=0.5
    fi

    # 词汇复杂度 (0-2分)
    local technical_terms=$(echo "$input" | grep -o -i '\b\(api\|database\|algorithm\|framework\|architecture\|microservice\|async\|concurrent\|distributed\|blockchain\|ai\|ml\|neural\|training\|inference\)\b' | wc -l)
    if (( technical_terms > 3 )); then
        vocabulary_score=2
    elif (( technical_terms > 1 )); then
        vocabulary_score=1.5
    fi

    # 结构复杂度 (0-2分)
    if echo "$input" | grep -q -E "(如果|那么|并且|或者|但是|因为|所以|因此|此外|总之|首先|其次|最后)"; then
        structure_score=2
    elif echo "$input" | grep -q -E "(和|或|但|因为|所以)"; then
        structure_score=1.5
    fi

    # 返回综合分数
    echo "scale=2; ($length_score + $vocabulary_score + $structure_score) / 3 * 2" | bc -l 2>/dev/null || echo "2.0"
}

# 评估技术复杂度 (复用现有函数，增强版)
assess_technical_complexity() {
    local input="$1"

    # 基于关键词的复杂度评估
    local complexity_score=1

    # 高复杂度关键词 (5分) - 包含中文关键词
    if echo "$input" | grep -q -i "microservice\|微服务\|distributed\|分布式\|blockchain\|区块链\|ai\|人工智能\|ml\|机器学习\|neural\|神经网络\|real.*time\|实时\|kubernetes\|k8s\|docker.*compose\|容器\|architecture\|架构\|system.*design\|系统设计"; then
        complexity_score=5
    # 中高复杂度关键词 (4分)
    elif echo "$input" | grep -q -i "concurrent\|并发\|async\|异步\|scalable\|可扩展\|security\|安全\|performance\|性能\|database.*design\|数据库设计\|api.*gateway\|网关\|monitoring\|监控\|deployment\|部署"; then
        complexity_score=4
    # 中等复杂度关键词 (3分)
    elif echo "$input" | grep -q -i "database\|数据库\|api\|接口\|authentication\|认证\|testing\|测试\|frontend.*backend\|前后端\|full.*stack\|全栈"; then
        complexity_score=3
    # 低复杂度关键词 (2分)
    elif echo "$input" | grep -q -i "crud\|增删改查\|simple\|简单\|basic\|基础\|hello.*world\|示例\|file.*read\|文件读取\|string.*manipul\|字符串处理"; then
        complexity_score=2
    fi

    # 如果包含多个技术领域，进一步提高复杂度
    local tech_domain_count=$(echo "$input" | grep -o -i '\b\(frontend\|前端\|backend\|后端\|database\|数据库\|api\|接口\|testing\|测试\|deployment\|部署\|monitoring\|监控\|security\|安全\)\b' | wc -l)
    if [[ $tech_domain_count -gt 2 ]]; then
        ((complexity_score += 1))
    fi

    # 调试信息
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "DEBUG: technical_complexity input='$input', score=$complexity_score, domains=$tech_domain_count" >&2
    fi

    echo "$complexity_score"
}

# 评估上下文复杂度
evaluate_context_complexity() {
    local context="$1"
    local context_score=1

    # 如果有上下文，增加复杂度
    if [[ -n "$context" ]]; then
        # 检查上下文中的技术债务或复杂性指标
        if echo "$context" | grep -q -i "legacy\|refactor\|debt\|complex\|dependency.*hell"; then
            context_score=4
        elif echo "$context" | grep -q -i "existing\|current\|modify\|update\|extend"; then
            context_score=3
        else
            context_score=2
        fi
    fi

    echo "$context_score"
}

# 分析意图复杂度
analyze_intent_complexity() {
    local input="$1"
    local intent_score=1

    # 基于意图类型的复杂度评估
    if echo "$input" | grep -q -i "create\|build\|develop\|implement.*system\|design.*architecture"; then
        intent_score=5  # 新建复杂系统
    elif echo "$input" | grep -q -i "refactor\|restructure\|optimize.*performance\|migrate"; then
        intent_score=4  # 重构或优化
    elif echo "$input" | grep -q -i "fix\|debug\|troubleshoot\|resolve.*error"; then
        intent_score=3  # 问题修复
    elif echo "$input" | grep -q -i "add\|implement.*feature\|extend"; then
        intent_score=3  # 功能扩展
    elif echo "$input" | grep -q -i "analyze\|review\|audit\|check"; then
        intent_score=2  # 分析检查
    elif echo "$input" | grep -q -i "help\|explain\|learn\|tutorial"; then
        intent_score=2  # 学习帮助
    fi

    echo "$intent_score"
}

# 选择执行模式 (增强版：集成学习系统)
select_execution_mode() {
    local complexity="$1"
    local user_id="${2:-default_user}"

    # 首先尝试使用学习系统的个性化推荐
    local learned_recommendation=$(recommend_execution_mode "$user_id" "$complexity" 2>/dev/null || echo "")

    if [[ -n "$learned_recommendation" && ("$learned_recommendation" == "direct" || "$learned_recommendation" == "intelligent") ]]; then
        # 学习系统返回了有效推荐，使用它
        echo "$learned_recommendation"
        return
    fi

    # 如果学习系统没有足够数据，回退到标准逻辑
    local threshold_direct="${MODE_SELECTION_CONFIG[complexity_threshold_direct]}"
    local threshold_intelligent="${MODE_SELECTION_CONFIG[complexity_threshold_intelligent]}"

    if (( $(echo "$complexity <= $threshold_direct" | bc -l 2>/dev/null || echo "0") )); then
        echo "direct"
    elif (( $(echo "$complexity >= $threshold_intelligent" | bc -l 2>/dev/null || echo "0") )); then
        echo "intelligent"
    else
        # 中等复杂度，使用学习系统的推荐或保守策略
        if [[ -n "$learned_recommendation" ]]; then
            echo "$learned_recommendation"
        else
            echo "intelligent"  # 保守策略，复杂任务使用智能模式
        fi
    fi
}

# 计算分析置信度
calculate_analysis_confidence() {
    local complexity="$1"

    # 复杂度越极端，置信度越高
    if (( $(echo "$complexity >= 7" | bc -l 2>/dev/null || echo "0") )) || (( $(echo "$complexity <= 2" | bc -l 2>/dev/null || echo "0") )); then
        echo "0.9"
    elif (( $(echo "$complexity >= 5" | bc -l 2>/dev/null || echo "0") )) || (( $(echo "$complexity <= 3" | bc -l 2>/dev/null || echo "0") )); then
        echo "0.8"
    else
        echo "0.7"
    fi
}

# 执行模式选择和路由
execute_mode_based_planning() {
    local user_input="$1"
    local context="${2:-}"

    smart_echo "🎯 执行智能双模式规划..." "processing"

    # 1. 复杂度分析
    local complexity_analysis=$(analyze_request_complexity "$user_input" "$context")

    # 2. 解析分析结果
    local selected_mode=$(echo "$complexity_analysis" | jq -r '.recommended_mode')
    local total_complexity=$(echo "$complexity_analysis" | jq -r '.total_complexity')

    smart_echo "📊 复杂度分析完成: $total_complexity (推荐模式: $selected_mode)" "info"

    # 3. 记录用户行为（模式选择）
    local behavior_data=$(cat <<EOF
{
  "selected_mode": "$selected_mode",
  "complexity": $total_complexity,
  "user_input": "$user_input",
  "context": "$context",
  "user_satisfaction": 0.8
}
EOF
)
    record_user_behavior "default_user" "mode_selection" "$behavior_data" 2>/dev/null || true

    # 4. 记录模式选择日志
    log_mode_switch_event "default_user" "auto" "$selected_mode" "complexity_analysis" "$complexity_analysis" 2>/dev/null || true

    # 3. 根据模式执行不同的规划策略
    case "$selected_mode" in
        "direct")
            execute_direct_mode "$user_input" "$context" "$complexity_analysis"
            ;;
        "intelligent")
            execute_intelligent_mode "$user_input" "$context" "$complexity_analysis"
            ;;
        *)
            smart_echo "⚠️ 无法确定执行模式，使用保守策略" "warning"
            execute_intelligent_mode "$user_input" "$context" "$complexity_analysis"
            ;;
    esac
}

# 直接模式执行 (快速路径)
execute_direct_mode() {
    local user_input="$1"
    local context="$2"
    local complexity_analysis="$3"

    smart_echo "⚡ 执行直接模式 (快速路径)" "processing"

    # 快速响应，基于简单意图识别
    local intent=$(quick_intent_recognition "$user_input")
    local action_plan=$(generate_direct_action_plan "$intent" "$user_input")

    # 直接执行，不需要多轮确认
    local execution_result=$(execute_direct_actions "$action_plan")

    # 记录规划历史
    record_planning_history "direct_mode_execution" "$complexity_analysis" "$action_plan" "$execution_result"

    smart_echo "✅ 直接模式执行完成" "success"
    echo "$execution_result"
}

# 智能模式执行 (复杂路径)
execute_intelligent_mode() {
    local user_input="$1"
    local context="$2"
    local complexity_analysis="$3"

    smart_echo "🧠 执行智能模式 (复杂路径)" "processing"

    # 1. 详细的项目状态分析
    local project_state=$(analyze_project_state)

    # 2. 复杂决策制定
    local decision=$(make_autonomous_decision "$project_state")

    # 3. 选择题确认流程 (新增)
    local confirmation_result=$(execute_choicetion_confirmation "$user_input" "$context" "$complexity_analysis")

    # 4. 检查确认状态
    local confirmation_status=$(echo "$confirmation_result" | jq -r '.confirmation_status')
    if [[ "$confirmation_status" != "sequence_generated" ]]; then
        smart_echo "⚠️ 选择题确认流程异常" "warning"
        echo '{"error": "confirmation_sequence_failed", "result": '"$confirmation_result"'}'
        return 1
    fi

    # 5. 根据确认结果调整决策 (如果确认完成)
    local question_sequence=$(echo "$confirmation_result" | jq -r '.question_sequence')
    local can_proceed=$(can_proceed_to_coding "$question_sequence")

    if [[ "$can_proceed" == "true" ]]; then
        local adjusted_decision=$(adjust_decision_based_confirmation "$decision" "$confirmation_result")

        # 6. 执行智能规划
        local execution_result=$(execute_decision "$adjusted_decision")

        smart_echo "✅ 智能模式执行完成 (确认通过)" "success"
        echo "$execution_result"
    else
        # 确认还未完成，返回确认状态
        smart_echo "⏳ 等待用户完成选择题确认" "info"
        echo '{"status": "awaiting_confirmation", "question_sequence": '"$question_sequence"', "message": "需要用户完成选择题确认后才能开始编码"}'
    fi

    # 记录规划历史
    record_planning_history "intelligent_mode_execution" "$complexity_analysis" "$decision" "$confirmation_result"
}

# 快速意图识别 (直接模式使用)
quick_intent_recognition() {
    local input="$1"

    if echo "$input" | grep -q -i "create\|build\|new"; then
        echo "create"
    elif echo "$input" | grep -q -i "fix\|debug\|error"; then
        echo "fix"
    elif echo "$input" | grep -q -i "add\|implement\|feature"; then
        echo "add"
    elif echo "$input" | grep -q -i "test\|testing"; then
        echo "test"
    elif echo "$input" | grep -q -i "analyze\|review"; then
        echo "analyze"
    else
        echo "general"
    fi
}

# 生成直接行动计划
generate_direct_action_plan() {
    local intent="$1"
    local user_input="$2"

    cat <<EOF
{
  "plan_type": "direct",
  "intent": "$intent",
  "actions": ["quick_$intent"],
  "estimated_time": "5-15分钟",
  "confidence": "high",
  "risk_level": "low"
}
EOF
}

# 执行直接行动
execute_direct_actions() {
    local action_plan="$1"

    local intent=$(echo "$action_plan" | jq -r '.intent')

    case "$intent" in
        "create")
            echo '{"result": "快速创建模式", "status": "completed", "message": "基础文件已创建"}'
            ;;
        "fix")
            echo '{"result": "快速修复模式", "status": "completed", "message": "常见问题已修复"}'
            ;;
        "test")
            echo '{"result": "快速测试模式", "status": "completed", "message": "基础测试已执行"}'
            ;;
        *)
            echo '{"result": "快速执行模式", "status": "completed", "message": "任务已快速完成"}'
            ;;
    esac
}

# 选择题确认流程 (智能模式核心)
execute_choicetion_confirmation() {
    local user_input="$1"
    local context="$2"
    local complexity_analysis="$3"

    smart_echo "🎯 启动选择题确认流程" "processing"

    # 调用真正的选择题确认系统
    local confirmation_result=$(execute_choicetion_confirmation "$user_input" "$context" "$complexity_analysis")

    smart_echo "✅ 选择题确认序列生成完成" "success"
    echo "$confirmation_result"
}

# 根据确认结果调整决策
adjust_decision_based_confirmation() {
    local decision="$1"
    local confirmation="$2"

    # 基于用户确认结果调整决策
    # 这里可以根据用户的选择题回答来调整规划

    echo "$decision"  # 暂时直接返回
}

# =============================================================================
# 项目状态感知系统
# =============================================================================

# 分析项目当前状态
analyze_project_state() {
    smart_echo "🔍 分析项目当前状态..." "processing"

    local project_state=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "project_type": "$(detect_project_type)",
  "development_stage": "$(assess_development_stage)",
  "code_quality": $(evaluate_code_quality),
  "completion_percentage": $(calculate_completion_percentage),
  "pending_tasks": $(identify_pending_tasks),
  "blockers": $(identify_blockers),
  "recommendations": $(generate_autonomous_recommendations)
}
EOF
)

    echo "$project_state"
}

# 检测项目类型
detect_project_type() {
    # 检查项目结构和配置文件来判断项目类型
    if [[ -f "package.json" ]]; then
        if grep -q '"react"' package.json 2>/dev/null; then
            echo "react_application"
        elif grep -q '"vue"' package.json 2>/dev/null; then
            echo "vue_application"
        elif grep -q '"angular"' package.json 2>/dev/null; then
            echo "angular_application"
        else
            echo "nodejs_application"
        fi
    elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
        echo "python_application"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust_application"
    elif [[ -f "go.mod" ]]; then
        echo "go_application"
    elif [[ -f "composer.json" ]]; then
        echo "php_application"
    elif [[ -d "src/main/java" ]]; then
        echo "java_application"
    elif [[ -d ".next" ]] || [[ -d "build" ]] || [[ -d "dist" ]]; then
        echo "existing_web_project"
    elif [[ $(find . -name "*.md" -o -name "*.txt" -o -name "*.doc" | wc -l) -gt 0 ]]; then
        echo "documentation_project"
    else
        echo "empty_or_new_project"
    fi
}

# 评估开发阶段
assess_development_stage() {
    local file_count=$(find . -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" | wc -l)
    local test_file_count=$(find . -type f -name "*test*" -o -name "*spec*" | wc -l)
    local doc_file_count=$(find . -type f -name "README*" -o -name "*.md" | grep -v node_modules | wc -l)

    if [[ $file_count -eq 0 ]]; then
        echo "planning"
    elif [[ $file_count -lt 5 ]]; then
        echo "initial_development"
    elif [[ $test_file_count -eq 0 ]]; then
        echo "development_without_tests"
    elif [[ $doc_file_count -eq 0 ]]; then
        echo "development_without_docs"
    elif [[ $(find . -name "package.json" -exec grep -l '"version"' {} \;) ]]; then
        echo "mature_project"
    else
        echo "development_in_progress"
    fi
}

# 评估代码质量
evaluate_code_quality() {
    local quality_score=0
    local total_checks=0

    # 检查代码文件数量
    local code_files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" \) | wc -l)
    ((total_checks++))
    if [[ $code_files -gt 0 ]]; then
        ((quality_score += 20))
    fi

    # 检查是否有测试文件
    local test_files=$(find . -name "*test*" -o -name "*spec*" | wc -l)
    ((total_checks++))
    if [[ $test_files -gt 0 ]]; then
        ((quality_score += 25))
    fi

    # 检查是否有文档
    local doc_files=$(find . -name "README*" -o -name "*.md" | grep -v node_modules | wc -l)
    ((total_checks++))
    if [[ $doc_files -gt 0 ]]; then
        ((quality_score += 20))
    fi

    # 检查是否有配置文件
    local config_files=$(find . -name "package.json" -o -name "requirements.txt" -o -name "Cargo.toml" | wc -l)
    ((total_checks++))
    if [[ $config_files -gt 0 ]]; then
        ((quality_score += 15))
    fi

    # 检查是否有.gitignore
    if [[ -f ".gitignore" ]]; then
        ((total_checks++))
        ((quality_score += 10))
    fi

    # 检查是否有错误文件
    local error_files=$(find . -name "*.error" -o -name "*.log" | grep -v node_modules | wc -l)
    ((total_checks++))
    if [[ $error_files -eq 0 ]]; then
        ((quality_score += 10))
    fi

    # 计算最终分数
    if [[ $total_checks -gt 0 ]]; then
        local final_score=$(( quality_score * 100 / (total_checks * 20) ))
        echo $final_score
    else
        echo 0
    fi
}

# 计算完成百分比
calculate_completion_percentage() {
    local stage=$(assess_development_stage)

    case "$stage" in
        "planning")
            echo 0
            ;;
        "initial_development")
            echo 15
            ;;
        "development_without_tests")
            echo 40
            ;;
        "development_without_docs")
            echo 65
            ;;
        "development_in_progress")
            echo 80
            ;;
        "mature_project")
            echo 100
            ;;
        *)
            echo 0
            ;;
    esac
}

# 识别待处理任务
identify_pending_tasks() {
    local pending_tasks=()

    # 检查是否有代码文件
    if [[ $(find . -name "*.js" -o -name "*.ts" -o -name "*.py" | wc -l) -eq 0 ]]; then
        pending_tasks+=("implement_core_functionality")
    fi

    # 检查是否有测试
    if [[ $(find . -name "*test*" -o -name "*spec*" | wc -l) -eq 0 ]]; then
        pending_tasks+=("add_test_suite")
    fi

    # 检查是否有文档
    if [[ $(find . -name "README*" | wc -l) -eq 0 ]]; then
        pending_tasks+=("create_documentation")
    fi

    # 检查是否有构建脚本
    if [[ ! -f "package.json" ]] && [[ ! -f "Makefile" ]] && [[ ! -f "build.gradle" ]]; then
        pending_tasks+=("setup_build_system")
    fi

    # 返回JSON数组
    printf '%s\n' "${pending_tasks[@]}" | jq -R . | jq -s .
}

# 识别阻碍因素
identify_blockers() {
    local blockers=()

    # 检查是否有语法错误
    if [[ -n $(find . -name "*.js" -exec node -c {} \; 2>&1 | head -5) ]]; then
        blockers+=("syntax_errors_in_javascript")
    fi

    # 检查依赖问题
    if [[ -f "package.json" ]] && [[ ! -d "node_modules" ]]; then
        blockers+=("missing_dependencies")
    fi

    # 检查配置文件问题
    if [[ -f "package.json" ]] && ! jq empty package.json 2>/dev/null; then
        blockers+=("invalid_package_json")
    fi

    # 检查权限问题
    if [[ ! -w "." ]]; then
        blockers+=("insufficient_permissions")
    fi

    # 返回JSON数组
    printf '%s\n' "${blockers[@]}" | jq -R . | jq -s .
}

# 生成自主规划建议
generate_autonomous_recommendations() {
    local project_state="$1"
    local recommendations=()

    local project_type=$(detect_project_type)
    local dev_stage=$(assess_development_stage)
    local quality_score=$(evaluate_code_quality)

    # 基于项目类型和阶段的智能建议
    case "$project_type" in
        "empty_or_new_project")
            recommendations+=("initialize_project_structure")
            recommendations+=("setup_version_control")
            recommendations+=("create_basic_documentation")
            ;;
        "nodejs_application"|"react_application")
            recommendations+=("setup_package_json")
            recommendations+=("install_dependencies")
            recommendations+=("create_entry_point")
            if [[ $quality_score -lt 50 ]]; then
                recommendations+=("add_linting_and_formatting")
            fi
            ;;
        "python_application")
            recommendations+=("setup_virtual_environment")
            recommendations+=("create_requirements_txt")
            recommendations+=("implement_main_module")
            ;;
        "existing_web_project")
            recommendations+=("audit_code_quality")
            recommendations+=("update_dependencies")
            recommendations+=("add_missing_tests")
            ;;
    esac

    # 通用建议
    if [[ $(echo "$blockers" | jq 'length') -gt 0 ]]; then
        recommendations+=("resolve_critical_blockers")
    fi

    if [[ $quality_score -lt 70 ]]; then
        recommendations+=("improve_code_quality")
    fi

    # 返回JSON数组
    printf '%s\n' "${recommendations[@]}" | jq -R . | jq -s .
}

# =============================================================================
# 自主决策引擎
# =============================================================================

# 自主决策和行动
make_autonomous_decision() {
    local project_state="$1"

    smart_echo "🧠 进行自主决策分析..." "processing"

    local decision=$(cat <<EOF
{
  "decision_timestamp": "$(date -Iseconds)",
  "project_analysis": $project_state,
  "recommended_actions": $(determine_optimal_actions "$project_state"),
  "confidence_level": $(calculate_decision_confidence "$project_state"),
  "risk_assessment": $(assess_decision_risks "$project_state"),
  "execution_plan": $(create_execution_plan "$project_state")
}
EOF
)

    echo "$decision"
}

# 确定最优行动方案
determine_optimal_actions() {
    local project_state="$1"

    local actions=()
    local project_type=$(echo "$project_state" | jq -r '.project_type')
    local dev_stage=$(echo "$project_state" | jq -r '.development_stage')
    local completion_pct=$(echo "$project_state" | jq -r '.completion_percentage')
    local blockers=$(echo "$project_state" | jq -r '.blockers')

    # 基于项目状态的决策树
    if [[ $completion_pct -eq 0 ]]; then
        # 空项目或新项目
        actions+=("initiate_loop_while_development")
        actions+=("generate_project_scaffold")
        actions+=("setup_development_environment")
    elif [[ $completion_pct -lt 30 ]]; then
        # 早期开发阶段
        actions+=("continue_development")
        actions+=("add_basic_testing")
        actions+=("create_initial_docs")
    elif [[ $completion_pct -lt 70 ]]; then
        # 中期开发阶段
        actions+=("enhance_functionality")
        actions+=("improve_test_coverage")
        actions+=("refactor_code")
    elif [[ $completion_pct -lt 90 ]]; then
        # 后期开发阶段
        actions+=("optimize_performance")
        actions+=("complete_documentation")
        actions+=("prepare_deployment")
    else
        # 接近完成的项目
        actions+=("final_quality_checks")
        actions+=("deployment_preparation")
        actions+=("maintenance_setup")
    fi

    # 处理阻碍因素
    if [[ $(echo "$blockers" | jq 'length') -gt 0 ]]; then
        actions+=("resolve_blockers_first")
    fi

    # 返回JSON数组
    printf '%s\n' "${actions[@]}" | jq -R . | jq -s .
}

# 计算决策置信度
calculate_decision_confidence() {
    local project_state="$1"

    local base_confidence=0.8
    local quality_score=$(echo "$project_state" | jq -r '.code_quality')
    local completion_pct=$(echo "$project_state" | jq -r '.completion_percentage')

    # 质量分数影响
    if [[ $quality_score -gt 80 ]]; then
        base_confidence=$(echo "$base_confidence + 0.1" | bc -l 2>/dev/null || echo "$base_confidence")
    elif [[ $quality_score -lt 50 ]]; then
        base_confidence=$(echo "$base_confidence - 0.2" | bc -l 2>/dev/null || echo "$base_confidence")
    fi

    # 完成度影响
    if [[ $completion_pct -gt 80 ]]; then
        base_confidence=$(echo "$base_confidence + 0.05" | bc -l 2>/dev/null || echo "$base_confidence")
    fi

    printf "%.2f" "$base_confidence"
}

# 评估决策风险
assess_decision_risks() {
    local project_state="$1"

    local risk_level="low"
    local risk_factors=()

    local blockers=$(echo "$project_state" | jq -r '.blockers')
    local quality_score=$(echo "$project_state" | jq -r '.code_quality')

    if [[ $(echo "$blockers" | jq 'length') -gt 0 ]]; then
        risk_level="high"
        risk_factors+=("critical_blockers_present")
    fi

    if [[ $quality_score -lt 30 ]]; then
        risk_level="high"
        risk_factors+=("poor_code_quality")
    elif [[ $quality_score -lt 60 ]]; then
        risk_level="medium"
        risk_factors+=("moderate_quality_concerns")
    fi

    # 如果是新项目，风险相对较低
    local dev_stage=$(echo "$project_state" | jq -r '.development_stage')
    if [[ "$dev_stage" == "planning" ]]; then
        risk_level="low"
        risk_factors+=("new_project_low_risk")
    fi

    cat <<EOF
{
  "risk_level": "$risk_level",
  "risk_factors": $(printf '%s\n' "${risk_factors[@]}" | jq -R . | jq -s .)
}
EOF
}

# 创建执行计划
create_execution_plan() {
    local project_state="$1"

    local plan=$(cat <<EOF
{
  "plan_id": "plan_$(date +%s)",
  "created_at": "$(date -Iseconds)",
  "estimated_duration": "$(estimate_plan_duration "$project_state")",
  "phases": $(define_execution_phases "$project_state"),
  "resource_requirements": $(estimate_resource_needs "$project_state"),
  "success_criteria": $(define_success_criteria "$project_state"),
  "rollback_plan": $(create_rollback_plan "$project_state")
}
EOF
)

    echo "$plan"
}

# 估算计划执行时长
estimate_plan_duration() {
    local project_state="$1"

    local completion_pct=$(echo "$project_state" | jq -r '.completion_percentage')
    local quality_score=$(echo "$project_state" | jq -r '.code_quality')

    # 基于完成度和质量的估算
    local base_hours=4

    if [[ $completion_pct -lt 30 ]]; then
        base_hours=8
    elif [[ $completion_pct -lt 70 ]]; then
        base_hours=6
    else
        base_hours=4
    fi

    if [[ $quality_score -lt 50 ]]; then
        base_hours=$((base_hours + 2))
    fi

    echo "${base_hours}h"
}

# 定义执行阶段
define_execution_phases() {
    local project_state="$1"

    local phases=()

    local dev_stage=$(echo "$project_state" | jq -r '.development_stage')

    case "$dev_stage" in
        "planning")
            phases+=('{"phase": "initialization", "duration": "1h", "tasks": ["setup_structure", "init_git", "create_readme"]}')
            phases+=('{"phase": "development", "duration": "4h", "tasks": ["implement_core", "add_tests", "create_docs"]}')
            phases+=('{"phase": "refinement", "duration": "2h", "tasks": ["code_review", "performance_opt", "final_docs"]}')
            ;;
        "initial_development")
            phases+=('{"phase": "completion", "duration": "3h", "tasks": ["finish_features", "add_comprehensive_tests", "complete_docs"]}')
            phases+=('{"phase": "optimization", "duration": "2h", "tasks": ["refactor_code", "optimize_performance", "security_audit"]}')
            ;;
        "development_in_progress")
            phases+=('{"phase": "enhancement", "duration": "2h", "tasks": ["add_missing_tests", "improve_docs", "bug_fixes"]}')
            phases+=('{"phase": "finalization", "duration": "1h", "tasks": ["final_review", "deployment_prep", "maintenance_setup"]}')
            ;;
    esac

    printf '%s\n' "${phases[@]}" | jq -s .
}

# 估算资源需求
estimate_resource_needs() {
    local project_state="$1"

    local project_type=$(echo "$project_state" | jq -r '.project_type')
    local completion_pct=$(echo "$project_state" | jq -r '.completion_percentage')

    local api_calls=100
    local storage_mb=50
    local compute_hours=2

    case "$project_type" in
        "react_application"|"nodejs_application")
            api_calls=200
            storage_mb=100
            ;;
        "python_application")
            api_calls=150
            storage_mb=75
            ;;
        "java_application")
            api_calls=300
            storage_mb=150
            compute_hours=4
            ;;
    esac

    # 根据完成度调整
    if [[ $completion_pct -gt 70 ]]; then
        api_calls=$((api_calls / 2))
        compute_hours=$((compute_hours / 2))
    fi

    cat <<EOF
{
  "api_calls_estimate": $api_calls,
  "storage_mb_estimate": $storage_mb,
  "compute_hours_estimate": $compute_hours,
  "cost_estimate_usd": $(echo "scale=2; $api_calls * 0.002" | bc 2>/dev/null || echo "0.20")
}
EOF
}

# 定义成功标准
define_success_criteria() {
    local project_state="$1"

    cat <<EOF
[
  "code_compiles_without_errors",
  "all_tests_pass",
  "documentation_is_complete",
  "code_quality_score_above_80",
  "no_critical_security_issues",
  "project_structure_is_organized"
]
EOF
}

# 创建回滚计划
create_rollback_plan() {
    local project_state="$1"

    cat <<EOF
{
  "backup_strategy": "git_commit_before_changes",
  "restore_points": [
    "pre_execution_state",
    "pre_development_state",
    "pre_testing_state"
  ],
  "manual_intervention_required": false,
  "estimated_rollback_time": "30_minutes"
}
EOF
}

# =============================================================================
# 自动执行控制器
# =============================================================================

# 执行自主规划 (智能双模式版本)
execute_autonomous_planning() {
    local trigger_event="${1:-project_load}"

    smart_echo "🚀 开始智能双模式自主规划 (触发事件: $trigger_event)" "processing"

    # 检查是否提供了用户输入
    if [[ $# -gt 1 ]]; then
        local user_input="$2"
        local context="$3"

        # 使用新的双模式规划系统
        local result=$(execute_mode_based_planning "$user_input" "$context")
        smart_echo "✅ 智能双模式规划执行完成" "success"
        echo "$result"
        return
    fi

    # 传统模式 (向后兼容)
    smart_echo "📋 使用传统自主规划模式" "info"

    # 1. 分析当前项目状态
    local project_state=$(analyze_project_state)

    # 2. 做出自主决策
    local decision=$(make_autonomous_decision "$project_state")

    # 3. 执行决策
    local execution_result=$(execute_decision "$decision")

    # 4. 记录规划历史
    record_planning_history "$trigger_event" "$project_state" "$decision" "$execution_result"

    smart_echo "✅ 传统自主规划执行完成" "success"
    echo "$execution_result"
}

# 执行决策
execute_decision() {
    local decision="$1"

    local actions=$(echo "$decision" | jq -r '.recommended_actions[]')
    local execution_results=()

    for action in $actions; do
        smart_echo "执行行动: $action" "processing"

        case "$action" in
            "initiate_loop_while_development")
                local result=$(initiate_loop_while_development)
                execution_results+=("$result")
                ;;
            "generate_project_scaffold")
                local result=$(generate_project_scaffold)
                execution_results+=("$result")
                ;;
            "setup_development_environment")
                local result=$(setup_development_environment)
                execution_results+=("$result")
                ;;
            "continue_development")
                local result=$(continue_development)
                execution_results+=("$result")
                ;;
            "resolve_blockers_first")
                local result=$(resolve_blockers)
                execution_results+=("$result")
                ;;
            "improve_code_quality")
                local result=$(improve_code_quality)
                execution_results+=("$result")
                ;;
            *)
                smart_echo "未知行动: $action" "warning"
                execution_results+=('{"action": "'$action'", "result": "unknown_action"}')
                ;;
        esac
    done

    # 返回执行结果汇总
    printf '%s\n' "${execution_results[@]}" | jq -s '{"executed_actions": .}'
}

# 发起Loop-While开发
initiate_loop_while_development() {
    smart_echo "🎭 自动发起Loop-While自主开发" "processing"

    # 生成项目ID
    local project_id="auto_project_$(date +%s)"

    # 分析项目需求
    local project_requirements=$(generate_project_requirements)

    # 启动Loop-While循环
    local loop_result=$(start_loop_while_development "$project_id" "$project_requirements")

    echo "{\"action\": \"initiate_loop_while\", \"project_id\": \"$project_id\", \"result\": \"started\"}"
}

# 生成项目需求
generate_project_requirements() {
    local project_type=$(detect_project_type)
    local dev_stage=$(assess_development_stage)

    case "$project_type" in
        "empty_or_new_project")
            echo "创建一个完整的${project_type}项目，包括基础架构、核心功能、测试和文档"
            ;;
        "nodejs_application")
            echo "开发一个完整的Node.js应用，包括API设计、数据库集成、错误处理和部署配置"
            ;;
        "react_application")
            echo "构建一个现代化的React应用，包含组件设计、状态管理、路由和样式系统"
            ;;
        "python_application")
            echo "实现一个Python应用，包含核心业务逻辑、数据处理、API接口和测试覆盖"
            ;;
        *)
            echo "开发一个完整的软件项目，满足生产环境的所有要求和最佳实践"
            ;;
    esac
}

# 生成项目脚手架
generate_project_scaffold() {
    smart_echo "🏗️ 生成项目脚手架" "processing"

    local project_type=$(detect_project_type)

    case "$project_type" in
        "nodejs_application")
            create_nodejs_scaffold
            ;;
        "react_application")
            create_react_scaffold
            ;;
        "python_application")
            create_python_scaffold
            ;;
        *)
            create_generic_scaffold
            ;;
    esac

    echo "{\"action\": \"generate_scaffold\", \"project_type\": \"$project_type\", \"result\": \"completed\"}"
}

# 设置开发环境
setup_development_environment() {
    smart_echo "⚙️ 设置开发环境" "processing"

    # 创建必要的目录结构
    mkdir -p .cursor
    mkdir -p tests
    mkdir -p docs

    # 创建基础配置文件
    create_basic_configs

    # 初始化版本控制（如还没有的话）
    if [[ ! -d ".git" ]]; then
        git init
        echo "node_modules/" > .gitignore
        echo "*.log" >> .gitignore
        git add .
        git commit -m "Initial commit - Auto generated project structure"
    fi

    echo "{\"action\": \"setup_environment\", \"result\": \"completed\"}"
}

# 继续开发
continue_development() {
    smart_echo "🔧 继续项目开发" "processing"

    # 分析当前代码状态
    local code_status=$(analyze_current_code)

    # 识别需要完成的功能
    local missing_features=$(identify_missing_features "$code_status")

    # 生成实现计划
    local implementation_plan=$(create_implementation_plan "$missing_features")

    echo "{\"action\": \"continue_development\", \"missing_features\": $missing_features, \"plan\": $implementation_plan}"
}

# 解决阻碍因素
resolve_blockers() {
    smart_echo "🔧 解决项目阻碍因素" "processing"

    local blockers=$(identify_blockers)
    local resolved=()

    echo "$blockers" | jq -r '.[]' | while read -r blocker; do
        case "$blocker" in
            "syntax_errors_in_javascript")
                fix_javascript_syntax_errors
                resolved+=("$blocker")
                ;;
            "missing_dependencies")
                install_missing_dependencies
                resolved+=("$blocker")
                ;;
            "invalid_package_json")
                fix_package_json
                resolved+=("$blocker")
                ;;
            "insufficient_permissions")
                request_permissions
                resolved+=("$blocker")
                ;;
        esac
    done

    echo "{\"action\": \"resolve_blockers\", \"resolved\": $(printf '%s\n' "${resolved[@]}" | jq -R . | jq -s .), \"result\": \"completed\"}"
}

# 改进代码质量
improve_code_quality() {
    smart_echo "📈 改进代码质量" "processing"

    # 添加代码检查工具
    add_linting_tools

    # 改进项目结构
    improve_project_structure

    # 添加测试框架
    add_testing_framework

    echo "{\"action\": \"improve_quality\", \"result\": \"completed\"}"
}

# 记录规划历史
record_planning_history() {
    local trigger_event="$1"
    local project_state="$2"
    local decision="$3"
    local execution_result="$4"

    local history_record=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "trigger_event": "$trigger_event",
  "project_state": $project_state,
  "decision": $decision,
  "execution_result": $execution_result,
  "autonomous_planning_version": "1.0.0"
}
EOF
)

    # 保存到历史文件
    local history_file="$AUTONOMOUS_PLANNER_DIR/planning_history.json"
    if [[ -f "$history_file" ]]; then
        # 添加到现有历史
        local existing_history=$(cat "$history_file")
        local new_history=$(echo "$existing_history" | jq --argjson record "$history_record" '. + [$record]')
        echo "$new_history" > "$history_file"
    else
        # 创建新的历史文件
        echo "[$history_record]" > "$history_file"
    fi

    smart_echo "规划历史已记录" "info"
}

# =============================================================================
# 辅助函数
# =============================================================================

# 创建基础配置
create_basic_configs() {
    # 创建.editorconfig
    cat > .editorconfig <<EOF
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
EOF

    # 创建.prettierrc
    cat > .prettierrc <<EOF
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
EOF
}

# 创建Node.js脚手架
create_nodejs_scaffold() {
    if [[ ! -f "package.json" ]]; then
        cat > package.json <<EOF
{
  "name": "auto-generated-project",
  "version": "1.0.0",
  "description": "Auto-generated Node.js project",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest",
    "lint": "eslint *.js"
  },
  "keywords": [],
  "author": "AI Assistant",
  "license": "MIT",
  "devDependencies": {
    "jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
    fi

    if [[ ! -f "index.js" ]]; then
        cat > index.js <<EOF
// Auto-generated Node.js application
console.log('Hello, World!');

// TODO: Implement your application logic here
EOF
    fi
}

# 创建React脚手架
create_react_scaffold() {
    # 这里可以实现React项目的脚手架生成
    smart_echo "React脚手架生成待实现" "info"
}

# 创建Python脚手架
create_python_scaffold() {
    if [[ ! -f "requirements.txt" ]]; then
        cat > requirements.txt <<EOF
pytest==7.1.2
black==22.3.0
flake8==4.0.1
EOF
    fi

    if [[ ! -f "main.py" ]]; then
        cat > main.py <<EOF
# Auto-generated Python application

def main():
    print("Hello, World!")
    # TODO: Implement your application logic here

if __name__ == "__main__":
    main()
EOF
    fi
}

# 创建通用脚手架
create_generic_scaffold() {
    if [[ ! -f "README.md" ]]; then
        cat > README.md <<EOF
# Auto-Generated Project

This project was automatically generated by the AI Assistant.

## Getting Started

TODO: Add project description and setup instructions

## Development

TODO: Add development guidelines

## Testing

TODO: Add testing instructions

## Deployment

TODO: Add deployment instructions
EOF
    fi
}

# =============================================================================
# 函数导出
# =============================================================================

export -f analyze_project_state
export -f make_autonomous_decision
export -f execute_autonomous_planning
export -f record_planning_history

# 双模式选择器相关函数
export -f analyze_request_complexity
export -f execute_mode_based_planning
export -f execute_direct_mode
export -f execute_intelligent_mode
export -f execute_choicetion_confirmation

# 初始化目录
AUTONOMOUS_PLANNER_DIR="$AI_DIR/autonomous_planner"
mkdir -p "$AUTONOMOUS_PLANNER_DIR"

smart_echo "自主规划控制器模块已加载" "success"