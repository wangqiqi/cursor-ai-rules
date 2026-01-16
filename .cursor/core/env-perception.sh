#!/bin/bash

# 🌟 Cursor AI Rules - 统一环境感知引擎
# 整合环境检测 + 项目感知 + 智能分析功能

set -e

# 加载标准日志库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"
init_logging "INFO" "env-perception"

log_info "启动统一环境感知引擎"

# 🎯 核心功能：统一环境检测与感知分析

# 初始化统计变量
CHECKS_TOTAL=0
CHECKS_PASSED=0
ISSUES_FOUND=0
WARNINGS_FOUND=0

# 结果数据结构
declare -A RESULTS

# 📊 通用检查函数
check_command() {
    local cmd="$1"
    local description="$2"
    local required="${3:-true}"

    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "   ✅ $description: 已安装"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        RESULTS["cmd_$cmd"]="installed"
        return 0
    else
        if [ "$required" = true ]; then
            echo "   ❌ $description: 未安装 (必需)"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
            RESULTS["cmd_$cmd"]="missing_required"
        else
            echo "   ⚠️  $description: 未安装 (可选)"
            WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
            RESULTS["cmd_$cmd"]="missing_optional"
        fi
        return 1
    fi
}

# 🎯 环境检测功能
perform_environment_check() {
    log_info "执行环境完整性检查"

    # 系统基础命令检查
    echo "🖥️  系统基础命令检查:"
    check_command "git" "Git版本控制"
    check_command "node" "Node.js运行时" false
    check_command "npm" "Node.js包管理器" false
    check_command "python3" "Python 3" false
    check_command "pip" "Python包管理器" false
    check_command "java" "Java运行时" false
    check_command "go" "Go语言" false
    check_command "rustc" "Rust编译器" false

    # 开发工具检查
    echo ""
    echo "🛠️  开发工具检查:"
    check_command "curl" "HTTP客户端" false
    check_command "wget" "文件下载工具" false
    check_command "jq" "JSON处理器" false
    check_command "docker" "容器化平台" false
    check_command "kubectl" "Kubernetes客户端" false

    # 目录结构检查
    echo ""
    echo "📁 目录结构检查:"
    local required_dirs=(".cursor" ".cursor/rules" ".cursor/features/automation/scripts")
    local all_dirs_exist=true

    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "   ❌ 缺少目录: $dir"
            all_dirs_exist=false
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
            RESULTS["dir_$dir"]="missing"
        else
            echo "   ✅ 目录存在: $dir"
            RESULTS["dir_$dir"]="exists"
        fi
    done

    if [ "$all_dirs_exist" = true ]; then
        echo "   ✅ 所有必需目录都存在"
        RESULTS["dirs_complete"]="true"
    else
        echo "   ❌ 部分必需目录缺失"
        RESULTS["dirs_complete"]="false"
    fi

    echo ""
}

# 🧠 对话意图分析功能
analyze_conversation_intent() {
    echo "💬 执行对话意图分析..." >&2

    # 从环境变量或参数获取对话内容
    local conversation_text="${CONVERSATION_TEXT:-}"
    local recent_messages="${RECENT_MESSAGES:-}"

    # 如果没有对话内容，返回空结果
    if [ -z "$conversation_text" ] && [ -z "$recent_messages" ]; then
        echo '{"intent_analysis": {"available": false, "reason": "no_conversation_data"}}'
        return
    fi

    # 关键词分析
    local intent_categories=""
    local tech_domains=""
    local confidence=0

    # 意图关键词检测
    local combined_text="$conversation_text $recent_messages"

    if echo "$combined_text" | grep -qiE "(我想做一个|开发一个|构建|创建|设计|实现|搭建)"; then
        intent_categories="${intent_categories}creation,"
        confidence=$((confidence + 30))
    fi

    if echo "$combined_text" | grep -qiE "(优化|改进|重构|升级|修复)"; then
        intent_categories="${intent_categories}optimization,"
        confidence=$((confidence + 25))
    fi

    if echo "$combined_text" | grep -qiE "(分析|评估|诊断|检查|审计)"; then
        intent_categories="${intent_categories}analysis,"
        confidence=$((confidence + 20))
    fi

    if echo "$combined_text" | grep -qiE "(测试|单元测试|集成测试)"; then
        intent_categories="${intent_categories}testing,"
        confidence=$((confidence + 20))
    fi

    if echo "$combined_text" | grep -qiE "(部署|发布|上线)"; then
        intent_categories="${intent_categories}deployment,"
        confidence=$((confidence + 25))
    fi

    # 技术领域关键词检测
    if echo "$combined_text" | grep -qiE "(前端|界面|UI|React|Vue|Angular|TypeScript)"; then
        tech_domains="${tech_domains}frontend,"
        confidence=$((confidence + 15))
    fi

    if echo "$combined_text" | grep -qiE "(后端|API|服务端|Node|Python|Java|Go|Spring|Django)"; then
        tech_domains="${tech_domains}backend,"
        confidence=$((confidence + 15))
    fi

    if echo "$combined_text" | grep -qiE "(AI|机器学习|深度学习|训练|推理)"; then
        tech_domains="${tech_domains}ai_ml,"
        confidence=$((confidence + 20))
    fi

    if echo "$combined_text" | grep -qiE "(数据|数据库|MySQL|PostgreSQL|MongoDB)"; then
        tech_domains="${tech_domains}data,"
        confidence=$((confidence + 10))
    fi

    # 限制置信度范围
    confidence=$(( confidence > 100 ? 100 : confidence ))

    # 构建结果JSON
    cat << EOF
{
  "intent_analysis": {
    "available": true,
    "conversation_text": "$conversation_text",
    "intent_categories": "${intent_categories%,}",
    "tech_domains": "${tech_domains%,}",
    "confidence": $confidence,
    "analysis_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
}

# 📊 项目感知分析功能
analyze_project_comprehensive() {
    echo "🔍 执行项目综合感知分析..." >&2

    # 1. 技术栈分析
    echo "📊 分析技术栈..." >&2
    local tech_stack="未知"
    local tech_details=""

    if [ -f "package.json" ]; then
        tech_stack="JavaScript/Node.js"
        if grep -q '"react"' package.json 2>/dev/null; then
            tech_details="${tech_details}React "
        fi
        if grep -q '"vue"' package.json 2>/dev/null; then
            tech_details="${tech_details}Vue "
        fi
        if grep -q '"typescript"' package.json 2>/dev/null; then
            tech_details="${tech_details}TypeScript "
        fi
        if grep -q '"next"' package.json 2>/dev/null; then
            tech_details="${tech_details}Next.js "
        fi
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        tech_stack="Python"
        if grep -q "django" requirements.txt 2>/dev/null || grep -q "Django" setup.py 2>/dev/null; then
            tech_details="${tech_details}Django "
        fi
        if grep -q "fastapi" requirements.txt 2>/dev/null; then
            tech_details="${tech_details}FastAPI "
        fi
        if grep -q "flask" requirements.txt 2>/dev/null; then
            tech_details="${tech_details}Flask "
        fi
    elif [ -f "Cargo.toml" ]; then
        tech_stack="Rust"
    elif [ -f "go.mod" ]; then
        tech_stack="Go"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        tech_stack="Java"
    elif [ -f "composer.json" ]; then
        tech_stack="PHP"
    elif [ -f "Gemfile" ]; then
        tech_stack="Ruby"
    fi

    # 2. 团队规模分析
    echo "👥 分析团队规模..." >&2
    local team_size="个人项目"
    local contributor_count=0

    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        contributor_count=$(git shortlog -sn --no-merges 2>/dev/null | wc -l || echo "1")
        if [ "$contributor_count" -gt 10 ]; then
            team_size="大型团队 (10+人)"
        elif [ "$contributor_count" -gt 5 ]; then
            team_size="中型团队 (6-10人)"
        elif [ "$contributor_count" -gt 1 ]; then
            team_size="小型团队 (2-5人)"
        else
            team_size="个人项目"
        fi
    fi

    # 3. 项目规模评估
    echo "📏 评估项目规模..." >&2
    local total_files=$(find . -type f -not -path './.*' -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null | wc -l || echo "0")
    local code_lines=0
    local project_scale="小型项目"

    # 计算代码行数（简化版）
    if [ -f "package.json" ]; then
        code_lines=$(find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        code_lines=$(find . -name "*.py" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    fi

    if [ "$total_files" -gt 500 ] || [ "$code_lines" -gt 50000 ]; then
        project_scale="大型项目"
    elif [ "$total_files" -gt 100 ] || [ "$code_lines" -gt 10000 ]; then
        project_scale="中型项目"
    else
        project_scale="小型项目"
    fi

    # 4. 开发阶段判断
    echo "📈 判断开发阶段..." >&2
    local dev_stage="未知"
    local commit_count=0
    local has_tests=false
    local has_docs=false
    local has_ci=false

    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")

        # 检查是否有测试文件
        if find . -name "*test*" -o -name "*spec*" | grep -v node_modules | grep -q . 2>/dev/null; then
            has_tests=true
        fi

        # 检查是否有文档
        if [ -f "README.md" ] || [ -d "docs" ]; then
            has_docs=true
        fi

        # 检查是否有CI配置
        if [ -f ".github/workflows/*.yml" ] || [ -f ".github/workflows/*.yaml" ] || [ -f ".gitlab-ci.yml" ] || [ -f "Jenkinsfile" ]; then
            has_ci=true
        fi

        # 根据特征判断开发阶段
        if [ "$commit_count" -lt 10 ] && [ "$has_tests" = false ]; then
            dev_stage="概念验证阶段"
        elif [ "$has_tests" = true ] && [ "$has_ci" = false ]; then
            dev_stage="早期开发阶段"
        elif [ "$has_ci" = true ] && [ "$has_docs" = true ]; then
            dev_stage="成熟产品阶段"
        else
            dev_stage="成长发展阶段"
        fi
    fi

    # 5. 系统环境感知
    echo "🖥️  感知系统环境..." >&2
    local os_info=$(uname -s 2>/dev/null || echo "Unknown")
    local arch_info=$(uname -m 2>/dev/null || echo "Unknown")
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')

    # 生成高级分析结果
    generate_advanced_analysis "$tech_stack" "$team_size" "$project_scale" "$dev_stage"

    # 构建综合结果JSON
    cat << EOF
{
  "project_perception": {
    "timestamp": "$timestamp",
    "tech_stack": {
      "primary": "$tech_stack",
      "details": "$tech_details",
      "confidence": "high"
    },
    "team_dynamics": {
      "size": "$team_size",
      "contributor_count": $contributor_count,
      "collaboration_style": "$(analyze_collaboration_style "$team_size" "$contributor_count")"
    },
    "project_scale": {
      "total_files": $total_files,
      "code_lines": $code_lines,
      "scale_category": "$project_scale",
      "complexity_level": "$(assess_complexity "$total_files" "$code_lines")"
    },
    "development_stage": {
      "current_stage": "$dev_stage",
      "commit_count": $commit_count,
      "has_tests": $has_tests,
      "has_docs": $has_docs,
      "has_ci": $has_ci,
      "maturity_score": $(calculate_maturity_score "$has_tests" "$has_docs" "$has_ci" "$commit_count")
    },
    "system_environment": {
      "os": "$os_info",
      "architecture": "$arch_info",
      "working_directory": "$(pwd)",
      "project_root": "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    },
    "advanced_analysis": $(get_advanced_analysis_json)
  }
}
EOF
}

# 🎯 主执行函数
main() {
    local mode="${1:-comprehensive}"

    case "$mode" in
        "env-check")
            # 仅执行环境检查
            perform_environment_check
            ;;
        "perception")
            # 仅执行项目感知
            analyze_project_comprehensive
            ;;
        "intent")
            # 仅执行意图分析
            analyze_conversation_intent
            ;;
        "comprehensive"|*)
            # 执行完整分析
            perform_environment_check
            echo ""
            analyze_project_comprehensive
            echo ""
            analyze_conversation_intent
            ;;
    esac

    # 输出最终统计
    echo ""
    echo "📊 执行统计:"
    echo "   🔍 总检查数: $CHECKS_TOTAL"
    echo "   ✅ 通过检查: $CHECKS_PASSED"
    echo "   ❌ 发现问题: $ISSUES_FOUND"
    echo "   ⚠️  发现警告: $WARNINGS_FOUND"

    # 根据结果给出建议
    if [ $ISSUES_FOUND -gt 0 ]; then
        echo ""
        echo "💡 建议:"
        echo "   - 运行修复脚本自动解决环境问题"
        echo "   - 检查系统依赖是否正确安装"
        echo "   - 验证目录权限设置"
    fi

    if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
        echo ""
        echo "🎉 环境检查完成！所有组件都已正确配置。"
    fi
}

# 🔮 高级分析功能

# 全局变量存储高级分析结果
ADVANCED_ANALYSIS_RESULT="{}"

# 协作风格分析
analyze_collaboration_style() {
    local team_size="$1"
    local contributor_count="$2"

    case "$team_size" in
        "personal")
            echo "solo_development"
            ;;
        "small")
            if [ "$contributor_count" -le 3 ]; then
                echo "tight_knit_team"
            else
                echo "growing_team"
            fi
            ;;
        "medium")
            echo "structured_collaboration"
            ;;
        "large")
            echo "enterprise_development"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 复杂度评估
assess_complexity() {
    local total_files="$1"
    local code_lines="$2"

    local complexity_score=0

    # 文件数量评分
    if [ "$total_files" -lt 10 ]; then
        complexity_score=$((complexity_score + 1))
    elif [ "$total_files" -lt 50 ]; then
        complexity_score=$((complexity_score + 2))
    elif [ "$total_files" -lt 100 ]; then
        complexity_score=$((complexity_score + 3))
    else
        complexity_score=$((complexity_score + 4))
    fi

    # 代码行数评分
    if [ "$code_lines" -lt 1000 ]; then
        complexity_score=$((complexity_score + 1))
    elif [ "$code_lines" -lt 10000 ]; then
        complexity_score=$((complexity_score + 2))
    elif [ "$code_lines" -lt 50000 ]; then
        complexity_score=$((complexity_score + 3))
    else
        complexity_score=$((complexity_score + 4))
    fi

    # 根据总分判断复杂度等级
    if [ $complexity_score -le 3 ]; then
        echo "low"
    elif [ $complexity_score -le 5 ]; then
        echo "medium"
    elif [ $complexity_score -le 7 ]; then
        echo "high"
    else
        echo "very_high"
    fi
}

# 成熟度评分计算
calculate_maturity_score() {
    local has_tests="$1"
    local has_docs="$2"
    local has_ci="$3"
    local commit_count="$4"

    local score=0

    # 测试覆盖评分
    [ "$has_tests" = "true" ] && score=$((score + 25))

    # 文档完整性评分
    [ "$has_docs" = "true" ] && score=$((score + 20))

    # CI/CD评分
    [ "$has_ci" = "true" ] && score=$((score + 25))

    # 提交频率评分
    if [ "$commit_count" -gt 100 ]; then
        score=$((score + 20))
    elif [ "$commit_count" -gt 50 ]; then
        score=$((score + 15))
    elif [ "$commit_count" -gt 10 ]; then
        score=$((score + 10))
    fi

    # 限制最大分数
    [ $score -gt 100 ] && score=100

    echo $score
}

# 生成高级分析结果
generate_advanced_analysis() {
    local tech_stack="$1"
    local team_size="$2"
    local project_scale="$3"
    local dev_stage="$4"

    echo "🔮 执行高级项目分析..." >&2

    # 趋势预测
    local trend_analysis=$(predict_trends "$tech_stack" "$dev_stage")

    # 模式分析
    local pattern_analysis=$(analyze_patterns "$team_size" "$project_scale")

    # 洞察生成
    local insights=$(generate_insights "$tech_stack" "$team_size" "$project_scale" "$dev_stage")

    # 风险评估
    local risk_assessment=$(assess_risks "$project_scale" "$dev_stage")

    # 优化建议
    local recommendations=$(generate_recommendations "$tech_stack" "$team_size" "$project_scale")

    # 构建高级分析JSON
    ADVANCED_ANALYSIS_RESULT=$(cat << EOF
{
  "trend_analysis": $trend_analysis,
  "pattern_analysis": $pattern_analysis,
  "insights": $insights,
  "risk_assessment": $risk_assessment,
  "recommendations": $recommendations,
  "analysis_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
)
}

# 趋势预测
predict_trends() {
    local tech_stack="$1"
    local dev_stage="$2"

    echo "🔮 预测技术趋势..." >&2

    # 基于当前技术栈和开发阶段预测未来趋势
    local trends="[]"

    # JavaScript/Node.js项目趋势
    if [[ "$tech_stack" == *"JavaScript"* ]] || [[ "$tech_stack" == *"Node.js"* ]]; then
        trends=$(echo "$trends" | jq '. += ["TypeScript迁移", "现代化框架升级", "性能优化需求"]')
    fi

    # Python项目趋势
    if [[ "$tech_stack" == *"Python"* ]]; then
        trends=$(echo "$trends" | jq '. += ["异步编程 adoption", "类型注解增加", "云原生迁移"]')
    fi

    # 根据开发阶段调整预测
    case "$dev_stage" in
        "概念验证阶段")
            trends=$(echo "$trends" | jq '. += ["架构重构", "可扩展性设计"]')
            ;;
        "早期开发阶段")
            trends=$(echo "$trends" | jq '. += ["测试覆盖率提升", "CI/CD建设"]')
            ;;
        "成熟产品阶段")
            trends=$(echo "$trends" | jq '. += ["性能优化", "可观测性建设", "云原生迁移"]')
            ;;
    esac

    cat << EOF
{
  "predicted_trends": $trends,
  "timeframe": "6-12_months",
  "confidence": "medium",
  "rationale": "基于当前技术栈和行业发展趋势预测"
}
EOF
}

# 模式分析
analyze_patterns() {
    local team_size="$1"
    local project_scale="$2"

    echo "🔍 分析项目模式..." >&2

    # 分析团队协作模式
    local collaboration_patterns=$(analyze_collaboration_patterns "$team_size")

    # 分析代码组织模式
    local code_patterns=$(analyze_code_patterns "$project_scale")

    # 分析开发流程模式
    local workflow_patterns=$(analyze_workflow_patterns "$team_size")

    cat << EOF
{
  "collaboration_patterns": $collaboration_patterns,
  "code_patterns": $code_patterns,
  "workflow_patterns": $workflow_patterns,
  "dominant_pattern": "$(determine_dominant_pattern "$team_size" "$project_scale")",
  "pattern_confidence": "high"
}
EOF
}

# 洞察生成
generate_insights() {
    local tech_stack="$1"
    local team_size="$2"
    local project_scale="$3"
    local dev_stage="$4"

    echo "💡 生成项目洞察..." >&2

    local insights="[]"

    # 技术洞察
    if [[ "$tech_stack" == *"JavaScript"* ]]; then
        insights=$(echo "$insights" | jq '. += {"type": "technology", "insight": "前端现代化转型时机成熟", "impact": "high"}')
    fi

    # 团队洞察
    case "$team_size" in
        "personal")
            insights=$(echo "$insights" | jq '. += {"type": "team", "insight": "考虑引入代码审查机制", "impact": "medium"}')
            ;;
        "large")
            insights=$(echo "$insights" | jq '. += {"type": "team", "insight": "标准化开发流程至关重要", "impact": "high"}')
            ;;
    esac

    # 规模洞察
    case "$project_scale" in
        "大型项目")
            insights=$(echo "$insights" | jq '. += {"type": "architecture", "insight": "模块化重构可以提升可维护性", "impact": "high"}')
            ;;
        "小型项目")
            insights=$(echo "$insights" | jq '. += {"type": "agility", "insight": "快速原型验证适合当前规模", "impact": "medium"}')
            ;;
    esac

    cat << EOF
{
  "key_insights": $insights,
  "insight_count": $(echo "$insights" | jq length),
  "high_impact_count": $(echo "$insights" | jq '[.[] | select(.impact == "high")] | length'),
  "generated_at": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
}

# 风险评估
assess_risks() {
    local project_scale="$1"
    local dev_stage="$2"

    echo "⚠️ 评估项目风险..." >&2

    local risks="[]"
    local risk_score=0

    # 规模风险
    if [ "$project_scale" = "大型项目" ]; then
        risks=$(echo "$risks" | jq '. += {"risk": "技术债务积累", "level": "high", "mitigation": "定期重构"}')
        risk_score=$((risk_score + 30))
    fi

    # 阶段风险
    if [ "$dev_stage" = "概念验证阶段" ]; then
        risks=$(echo "$risks" | jq '. += {"risk": "架构设计不足", "level": "medium", "mitigation": "及早规划架构"}')
        risk_score=$((risk_score + 20))
    fi

    cat << EOF
{
  "identified_risks": $risks,
  "overall_risk_score": $risk_score,
  "risk_level": "$( [ $risk_score -gt 50 ] && echo "high" || [ $risk_score -gt 25 ] && echo "medium" || echo "low" )",
  "assessment_date": "$(date '+%Y-%m-%d')"
}
EOF
}

# 优化建议生成
generate_recommendations() {
    local tech_stack="$1"
    local team_size="$2"
    local project_scale="$3"

    echo "💡 生成优化建议..." >&2

    local recommendations="[]"

    # 技术栈建议
    if [[ "$tech_stack" == *"JavaScript"* ]] && [[ ! "$tech_stack" == *"TypeScript"* ]]; then
        recommendations=$(echo "$recommendations" | jq '. += {"category": "technology", "recommendation": "考虑迁移到TypeScript提升代码质量", "priority": "medium"}')
    fi

    # 团队建议
    if [ "$team_size" = "personal" ]; then
        recommendations=$(echo "$recommendations" | jq '. += {"category": "process", "recommendation": "建立代码审查习惯，即使是个人项目", "priority": "low"}')
    fi

    # 规模建议
    if [ "$project_scale" = "大型项目" ]; then
        recommendations=$(echo "$recommendations" | jq '. += {"category": "architecture", "recommendation": "实施模块化架构和自动化测试", "priority": "high"}')
    fi

    echo "$recommendations"
}

# 协作模式分析
analyze_collaboration_patterns() {
    local team_size="$1"

    case "$team_size" in
        "personal")
            echo '"solo_development","code_reviews_missing"'
            ;;
        "small")
            echo '"pair_programming","agile_methodology"'
            ;;
        "medium")
            echo '"scrum","code_reviews","continuous_integration"'
            ;;
        "large")
            echo '"enterprise_agile","microservices","devops"'
            ;;
        *)
            echo '"unknown"'
            ;;
    esac
}

# 代码模式分析
analyze_code_patterns() {
    local project_scale="$1"

    case "$project_scale" in
        "小型项目")
            echo '"monolithic","simple_architecture"'
            ;;
        "中型项目")
            echo '"modular","layered_architecture"'
            ;;
        "大型项目")
            echo '"microservices","domain_driven_design","event_driven"'
            ;;
        *)
            echo '"unknown"'
            ;;
    esac
}

# 工作流模式分析
analyze_workflow_patterns() {
    local team_size="$1"

    case "$team_size" in
        "personal")
            echo '"git_flow_simple","manual_testing"'
            ;;
        "small")
            echo '"git_flow","basic_ci","manual_reviews"'
            ;;
        "medium")
            echo '"github_flow","automated_testing","pull_requests"'
            ;;
        "large")
            echo '"trunk_based","comprehensive_ci_cd","automated_reviews"'
            ;;
        *)
            echo '"unknown"'
            ;;
    esac
}

# 确定主导模式
determine_dominant_pattern() {
    local team_size="$1"
    local project_scale="$2"

    if [ "$team_size" = "personal" ] && [ "$project_scale" = "小型项目" ]; then
        echo "solo_startup"
    elif [ "$team_size" = "large" ] && [ "$project_scale" = "大型项目" ]; then
        echo "enterprise_scale"
    elif [ "$project_scale" = "大型项目" ]; then
        echo "complex_system"
    else
        echo "standard_development"
    fi
}

# 获取高级分析JSON
get_advanced_analysis_json() {
    echo "$ADVANCED_ANALYSIS_RESULT"
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi