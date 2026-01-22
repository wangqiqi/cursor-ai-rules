#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../core/path-config.sh"  # 统一路径配置

# 🎯 Cursor AI Rules - 学习进度跟踪Hook
# 跟踪和记录学习活动，生成学习报告

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 学习统计
LEARNING_SESSIONS=0
LEARNING_TIME=0
TOPICS_COVERED=0
QUESTIONS_ASKED=0

# 日志函数
log_info() {
    echo -e "${BLUE}[LEARNING-TRACKER]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[LEARNING-TRACKER]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[LEARNING-TRACKER]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[LEARNING-TRACKER]${NC} ❌ $1"
}

log_learning() {
    echo -e "${PURPLE}[LEARNING-TRACKER]${NC} 📚 $1"
}

# 检测学习活动
detect_learning_activity() {
    local input="$1"

    # 定义学习关键词
    local learning_keywords=(
        "学习" "学习" "掌握" "了解" "教程" "指南" "入门"
        "learn" "study" "master" "understand" "tutorial" "guide" "beginner"
        "what" "how" "why" "explain" "teach" "help"
        "什么是" "怎么做" "为什么" "解释" "教" "帮助"
    )

    # 检查是否包含学习关键词
    for keyword in "${learning_keywords[@]}"; do
        if echo "$input" | grep -qi "$keyword"; then
            return 0
        fi
    done

    return 1
}

# 分析学习主题
analyze_learning_topic() {
    local input="$1"
    local topic=""

    # 技术领域识别
    if echo "$input" | grep -qiE "(javascript|js|node|react|vue|angular)"; then
        topic="JavaScript/TypeScript"
    elif echo "$input" | grep -qiE "(python|django|flask|fastapi)"; then
        topic="Python"
    elif echo "$input" | grep -qiE "(java|spring|maven|gradle)"; then
        topic="Java"
    elif echo "$input" | grep -qiE "(go|golang)"; then
        topic="Go"
    elif echo "$input" | grep -qiE "(rust|cargo)"; then
        topic="Rust"
    elif echo "$input" | grep -qiE "(docker|kubernetes|k8s|container)"; then
        topic="容器化/DevOps"
    elif echo "$input" | grep -qiE "(git|github|version.control)"; then
        topic="版本控制"
    elif echo "$input" | grep -qiE "(database|sql|mysql|postgresql|mongodb)"; then
        topic="数据库"
    elif echo "$input" | grep -qiE "(html|css|web|frontend)"; then
        topic="Web开发"
    elif echo "$input" | grep -qiE "(api|rest|graphql)"; then
        topic="API设计"
    elif echo "$input" | grep -qiE "(test|testing|tdd|bdd)"; then
        topic="测试"
    elif echo "$input" | grep -qiE "(security|auth|oauth)"; then
        topic="安全"
    else
        topic="通用编程"
    fi

    echo "$topic"
}

# 确定学习难度
determine_difficulty_level() {
    local input="$1"

    # 难度关键词
    local beginner_keywords=("入门" "基础" "初学" "开始" "beginner" "basic" "start")
    local intermediate_keywords=("进阶" "高级" "深入" "intermediate" "advanced" "deep")
    local expert_keywords=("专家" "大师" "优化" "expert" "master" "optimize")

    if echo "$input" | grep -qiE "($(IFS=\|; echo "${beginner_keywords[*]}"))"; then
        echo "beginner"
    elif echo "$input" | grep -qiE "($(IFS=\|; echo "${expert_keywords[*]}"))"; then
        echo "expert"
    elif echo "$input" | grep -qiE "($(IFS=\|; echo "${intermediate_keywords[*]}"))"; then
        echo "intermediate"
    else
        echo "intermediate"  # 默认中等难度
    fi
}

# 记录学习会话
record_learning_session() {
    local input="$1"
    local topic="$2"
    local difficulty="$3"
    local timestamp="$4"

    # 创建学习记录目录
    local learning_dir="$GROWTH_DIR/learning"
    mkdir -p "$learning_dir"

    # 生成会话ID
    local session_id="session_$(date +%Y%m%d_%H%M%S)_$RANDOM"

    # 创建学习记录
    local record_file="$learning_dir/$session_id.json"
    cat > "$record_file" << EOF
{
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "topic": "$topic",
  "difficulty": "$difficulty",
  "input": "$input",
  "type": "learning_request",
  "status": "active"
}
EOF

    log_learning "学习会话已记录: $session_id ($topic - $difficulty)"

    # 更新学习统计
    ((LEARNING_SESSIONS++))
    ((TOPICS_COVERED++))

    echo "$session_id"
}

# 更新学习进度
update_learning_progress() {
    local session_id="$1"
    local status="${2:-completed}"

    local learning_dir="$GROWTH_DIR/learning"
    local record_file="$learning_dir/$session_id.json"

    if [ -f "$record_file" ]; then
        # 更新状态
        local temp_file=$(mktemp)
        jq --arg status "$status" --arg end_time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.status = $status | .end_time = $end_time' "$record_file" > "$temp_file"
        mv "$temp_file" "$record_file"

        log_learning "学习会话状态更新: $session_id -> $status"
    fi
}

# 生成学习建议
generate_learning_suggestions() {
    local topic="$1"
    local difficulty="$2"

    log_learning "基于 $topic ($difficulty) 生成学习建议..."

    case "$topic" in
        "JavaScript/TypeScript")
            case "$difficulty" in
                "beginner")
                    echo "建议从MDN Web Docs开始学习基础语法，然后练习DOM操作"
                    ;;
                "intermediate")
                    echo "推荐学习ES6+特性，异步编程，模块化开发"
                    ;;
                "expert")
                    echo "可以深入性能优化，设计模式，框架源码分析"
                    ;;
            esac
            ;;
        "Python")
            case "$difficulty" in
                "beginner")
                    echo "从Python官方教程开始，重点学习基础语法和数据结构"
                    ;;
                "intermediate")
                    echo "学习面向对象，装饰器，上下文管理器，常用库使用"
                    ;;
                "expert")
                    echo "深入异步编程，元编程，性能优化，框架开发"
                    ;;
            esac
            ;;
        "容器化/DevOps")
            echo "推荐学习Docker基础，容器编排，然后是CI/CD流程"
            ;;
        "数据库")
            echo "从关系型数据库开始，学习SQL，然后了解NoSQL数据库"
            ;;
        *)
            echo "建议制定学习计划，分解知识点，循序渐进"
            ;;
    esac
}

# 生成学习报告
generate_learning_report() {
    local learning_dir="$GROWTH_DIR/learning"
    local report_file="$learning_dir/learning-report-$(date +%Y%m%d).md"

    log_info "生成学习报告..."

    # 统计学习数据
    local total_sessions=$(find "$learning_dir" -name "*.json" | wc -l)
    local completed_sessions=$(find "$learning_dir" -name "*.json" -exec jq -r '.status' {} \; | grep -c "completed" || echo "0")
    local active_sessions=$(find "$learning_dir" -name "*.json" -exec jq -r '.status' {} \; | grep -c "active" || echo "0")

    # 统计热门主题
    local popular_topics=$(find "$learning_dir" -name "*.json" -exec jq -r '.topic' {} \; 2>/dev/null | sort | uniq -c | sort -nr | head -5)

    cat > "$report_file" << EOF
# 📚 学习进度报告
**生成时间**: $(date)
**报告周期**: 每日

## 📊 学习统计
- **总会话数**: $total_sessions
- **完成会话**: $completed_sessions
- **活跃会话**: $active_sessions
- **完成率**: $((completed_sessions * 100 / (total_sessions > 0 ? total_sessions : 1)))%

## 🔥 热门学习主题
$popular_topics

## 🎯 今日学习活动
$(find "$learning_dir" -name "*.json" -newermt "1 day ago" -exec jq -r '"- " + .topic + " (" + .difficulty + ")"' {} \; 2>/dev/null | head -10)

## 💡 学习建议
- 保持每日学习习惯
- 多动手实践代码
- 参与开源项目
- 定期复习基础知识

---
*报告由Cursor AI Rules自动生成*
EOF

    log_success "学习报告已生成: $report_file"
}

# 检查学习里程碑
check_learning_milestones() {
    local learning_dir="$GROWTH_DIR/learning"

    # 检查是否达到学习里程碑
    local total_sessions=$(find "$learning_dir" -name "*.json" 2>/dev/null | wc -l)
    local milestones=(10 25 50 100 250 500 1000)

    for milestone in "${milestones[@]}"; do
        if [ "$total_sessions" -eq "$milestone" ]; then
            log_learning "🎉 恭喜！达到学习里程碑: $milestone 个学习会话"
            log_learning "继续保持学习热情！"
            break
        fi
    done
}

# 主函数 - 跟踪学习活动
track_learning_activity() {
    local input="$1"
    local timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    # 检测是否是学习活动
    if detect_learning_activity "$input"; then
        log_learning "检测到学习活动"

        # 分析学习主题和难度
        local topic=$(analyze_learning_topic "$input")
        local difficulty=$(determine_difficulty_level "$input")

        log_learning "主题: $topic | 难度: $difficulty"

        # 记录学习会话
        local session_id=$(record_learning_session "$input" "$topic" "$difficulty" "$timestamp")

        # 生成学习建议
        local suggestion=$(generate_learning_suggestions "$topic" "$difficulty")
        if [ -n "$suggestion" ]; then
            log_learning "💡 $suggestion"
        fi

        # 检查里程碑
        check_learning_milestones

        # 每10个会话生成一次报告
        if [ $((LEARNING_SESSIONS % 10)) -eq 0 ]; then
            generate_learning_report
        fi

        return 0
    else
        return 1
    fi
}

# 完成学习会话
complete_learning_session() {
    local session_id="$1"

    if [ -n "$session_id" ]; then
        update_learning_progress "$session_id" "completed"
        log_learning "学习会话已完成: $session_id"
    fi
}

# 只有在直接调用时才执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        "track")
            shift
            track_learning_activity "$*"
            ;;
        "complete")
            complete_learning_session "$2"
            ;;
        "report")
            generate_learning_report
            ;;
        "stats")
            check_learning_milestones
            ;;
        *)
            echo "用法: $0 <command> [args]"
            echo ""
            echo "命令:"
            echo "  track <input>    跟踪学习活动"
            echo "  complete <id>   完成学习会话"
            echo "  report          生成学习报告"
            echo "  stats           显示学习统计"
            exit 1
            ;;
    esac
fi