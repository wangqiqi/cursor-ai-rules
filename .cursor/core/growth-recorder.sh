#!/bin/bash

# 🌱 Cursor AI Rules - 生长数据记录器
# 专门为 /master 规则提供生长数据记录功能
#
# 使用方法:
#   ./growth-recorder.sh record "用户输入" "决策结果" "意图类型"
#   ./growth-recorder.sh learn "用户输入"
#   ./growth-recorder.sh stats

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"

# 加载统一路径配置（设置非严格模式）
export STRICT_MODE=0
export DEBUG=0
if ! source "$SCRIPT_DIR/path-config.sh" 2>/dev/null; then
    handle_error 1 "路径配置加载失败"
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 初始化生长目录 - 通过生长管理器完成
init_growth_if_needed() {
    # 调用生长管理器进行初始化和验证
    if [ -f "$CURSOR_DIR/core/growth-manager.sh" ]; then
        bash "$CURSOR_DIR/core/growth-manager.sh" init >/dev/null 2>&1
        echo -e "${GREEN}✅ 生长目录已通过管理器初始化${NC}"
    else
        echo -e "${YELLOW}⚠️  生长管理器未找到，使用备用初始化${NC}"
        # 备用初始化逻辑（使用统一目录创建）
        ensure_directory_structure
        ensure_gitignore_protection
    fi
}

# 创建初始文件
create_initial_files() {
    # README (只有在不存在时创建)
    if [ ! -f "$CURSOR_GROWTH/README.md" ]; then
        cat > "$CURSOR_GROWTH/README.md" << 'EOF'
# 🌱 项目生长目录 ($CURSOR_GROWTH)

此目录包含项目的AI学习数据和生长信息。
这些数据不会被提交到版本控制，是项目私有的。

## 目录结构
- learning/ - AI学习数据
- conversations/ - 对话记录
- debug/ - 调试信息
- growth/ - 生长指标
- personal/ - 个性化数据
- cache/ - 缓存数据
- monitoring/ - 监控数据
EOF
    fi

    # 初始配置文件 (只有在不存在时创建)
    if [ ! -f "$AI_METRICS_DIR/ai-profile.json" ]; then
        cat > "$AI_METRICS_DIR/ai-profile.json" << EOF
{
  "profile": {
    "created_at": "$(date '+%Y-%m-%d %H:%M:%S')",
    "project_root": "$PROJECT_ROOT",
    "cursor_version": "5.0.0",
    "total_interactions": 0,
    "successful_interactions": 0,
    "learning_enabled": true,
    "preferred_language": "zh-CN",
    "common_intents": {},
    "skill_usage": {},
    "rule_activation": {}
  }
}
EOF
    fi

    # 初始对话记录 (只有在不存在时创建)
    if [ ! -f "$CONVERSATIONS_DIR/initial_conversation.json" ]; then
        cat > "$CONVERSATIONS_DIR/initial_conversation.json" << EOF
{
  "conversation_id": "initial_$(date +%s)",
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "type": "initialization",
  "messages": [
    {
      "role": "system",
      "content": "项目生长目录已初始化。开始记录AI助手与用户的交互数据。",
      "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
    }
  ],
  "metadata": {
    "user_id": "cursor-user",
    "project_root": "$PROJECT_ROOT",
    "cursor_version": "4.3.0"
  }
}
EOF
    fi

    # 初始生长指标 (只有在不存在时创建)
    if [ ! -f "$GROWTH_METRICS_DIR/metrics.json" ]; then
        cat > "$GROWTH_METRICS_DIR/metrics.json" << EOF
{
  "metrics": {
    "start_date": "$(date '+%Y-%m-%d')",
    "total_interactions": 0,
    "successful_interactions": 0,
    "failed_interactions": 0,
    "average_response_time_ms": 0,
    "learning_progress": 0,
    "skill_adoption_rate": 0,
    "rule_activation_rate": 0
  }
}
EOF
    fi
}

# 确保gitignore保护
ensure_gitignore_protection() {
    local gitignore_file="$PROJECT_ROOT/.gitignore"

    if [ ! -f "$gitignore_file" ]; then
        # 如果.gitignore不存在，只创建必要的Cursor AI相关规则
        cat > "$gitignore_file" << 'EOF'
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
$CURSOR_GROWTH/

# Cursor AI Rules - 通用规则保持跟踪
!.cursor/
!.cursor/**# 保留生长文件夹的占位符
!$CURSOR_GROWTH/.gitkeep
EOF
    elif ! grep -q -E "(^\.cursorGrowth/|\$CURSOR_GROWTH/)" "$gitignore_file" 2>/dev/null; then
        # 在文件开头添加保护规则（只有在不存在任何cursorGrowth相关条目时）
        local temp_file=$(mktemp)
        cat > "$temp_file" << 'EOF'
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/

EOF
        cat "$gitignore_file" >> "$temp_file"
        mv "$temp_file" "$gitignore_file"
    fi
}

# 记录交互数据
record_interaction() {
    local user_input="$1"
    local decision_result="$2"
    local intent_type="${3:-unknown}"

    init_growth_if_needed

    echo -e "${BLUE}📝 记录交互数据...${NC}"

    # 解析决策结果
    local success=$(echo "$decision_result" | jq -r '.decision_making.should_execute // false' 2>/dev/null || echo "false")
    local explanation=$(echo "$decision_result" | jq -r '.decision_making.explanation // "未知"' 2>/dev/null || echo "未知")

    # 创建交互记录
    local interaction_record=$(cat << EOF
{
  "interaction": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "decision_result": $decision_result,
    "success": $success,
    "explanation": "$explanation",
    "session_id": "session_$(date +%s)"
  }
}
EOF
)

    # 追加到学习文件
    local learning_file="$LEARNING_PROGRESS_DIR/ai-master-interactions.json"
    echo "$interaction_record" >> "$learning_file"
    echo -e "${GREEN}✅ 交互数据已记录${NC}"

    # 更新统计信息
    update_statistics "$success" "$intent_type"
}

# 更新统计信息
update_statistics() {
    local success="$1"
    local intent_type="$2"

    local profile_file="$AI_METRICS_DIR/ai-profile.json"
    local metrics_file="$GROWTH_METRICS_DIR/metrics.json"

    if [ -f "$profile_file" ] && [ -f "$metrics_file" ]; then
        # 更新profile统计
        local temp_profile=$(mktemp)
        jq --arg intent "$intent_type" '
            .profile.total_interactions += 1 |
            .profile.successful_interactions += (if '$success' then 1 else 0 end) |
            .profile.common_intents[$intent] = (.profile.common_intents[$intent] // 0) + 1
        ' "$profile_file" > "$temp_profile"
        mv "$temp_profile" "$profile_file"

        # 更新metrics统计
        local temp_metrics=$(mktemp)
        jq '
            .metrics.total_interactions += 1 |
            .metrics.successful_interactions += (if '$success' then 1 else 0 end) |
            .metrics.failed_interactions += (if '$success' then 0 else 1 end)
        ' "$metrics_file" > "$temp_metrics"
        mv "$temp_metrics" "$metrics_file"
    fi
}

# 简单的学习功能
learn_from_input() {
    local user_input="$1"

    init_growth_if_needed

    echo -e "${PURPLE}🧠 分析用户输入模式...${NC}"

    # 简单的意图识别
    local intent="unknown"
    if echo "$user_input" | grep -qiE "(创建|新建|搭建)"; then
        intent="project_creation"
    elif echo "$user_input" | grep -qiE "(优化|改进|修复)"; then
        intent="code_optimization"
    elif echo "$user_input" | grep -qiE "(分析|检查|查看)"; then
        intent="project_analysis"
    elif echo "$user_input" | grep -qiE "(学习|了解|教程)"; then
        intent="learning"
    fi

    # 记录学习数据
    local learning_record=$(cat << EOF
{
  "learning": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "user_input": "$user_input",
    "detected_intent": "$intent",
    "confidence": 0.8,
    "learning_type": "pattern_recognition"
  }
}
EOF
)

    echo "$learning_record" >> "$AI_METRICS_DIR/ai-patterns.json"
    echo -e "${GREEN}✅ 学习数据已记录${NC}"
}

# 显示统计信息
show_stats() {
    init_growth_if_needed

    echo -e "${CYAN}📊 生长统计信息${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f "$GROWTH_METRICS_DIR/metrics.json" ]; then
        local total=$(jq -r '.metrics.total_interactions' "$GROWTH_METRICS_DIR/metrics.json" 2>/dev/null || echo "0")
        local success=$(jq -r '.metrics.successful_interactions' "$GROWTH_METRICS_DIR/metrics.json" 2>/dev/null || echo "0")

        echo -e "${BLUE}📈 总交互次数: ${NC}$total"
        echo -e "${BLUE}✅ 成功交互: ${NC}$success"
        echo -e "${BLUE}❌ 失败交互: ${NC}$((total - success))"
        echo -e "${BLUE}📊 成功率: ${NC}$(awk "BEGIN {printf \"%.1f\", $success/$total*100}")%"
    fi

    if [ -f "$LEARNING_PROGRESS_DIR/profile.json" ]; then
        echo ""
        echo -e "${PURPLE}🎯 最常使用的意图:${NC}"
        jq -r '.profile.common_intents | to_entries | sort_by(.value) | reverse[] | "  \(.key): \(.value)次"' "$AI_METRICS_DIR/ai-profile.json" 2>/dev/null || echo "  无数据"
    fi

    echo ""
    echo -e "${GREEN}🌱 生长目录位置: $CURSOR_GROWTH${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        "record")
            shift
            record_interaction "$@"
            ;;
        "learn")
            shift
            learn_from_input "$@"
            ;;
        "stats"|"status")
            show_stats
            ;;
        "init")
            init_growth_if_needed
            ;;
        "help"|"-h"|"--help")
            echo "🌱 Cursor AI Rules - 生长数据记录器"
            echo ""
            echo "使用方法:"
            echo "  $0 record \"用户输入\" \"决策结果\" [意图类型]  # 记录交互"
            echo "  $0 learn \"用户输入\"                        # 学习模式"
            echo "  $0 stats                                      # 显示统计"
            echo "  $0 init                                       # 初始化生长目录"
            echo "  $0 help                                       # 显示帮助"
            ;;
        *)
            echo -e "${YELLOW}💡 使用 '$0 help' 查看帮助信息${NC}"
            # 默认执行学习模式
            if [ -n "$1" ]; then
                learn_from_input "$*"
            else
                show_stats
            fi
            ;;
    esac
}

# 执行主函数
main "$@"