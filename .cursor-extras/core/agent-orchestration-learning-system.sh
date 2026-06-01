#!/bin/bash
# ========================================
# Cursor AI Rules - 自适应学习系统
# 实现用户行为学习和模式推荐
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/agent-orchestration-common.sh"

# =============================================================================
# 自适应学习系统 - Phase 4核心模块
# =============================================================================

# 🤖 自适应学习系统

# =============================================================================
# 用户行为学习引擎
# =============================================================================

# 用户行为数据结构
declare -A USER_BEHAVIOR_PROFILE=(
    ["preferred_direct_threshold"]=2.0        # 用户偏好的直接模式阈值
    ["preferred_intelligent_threshold"]=3.5  # 用户偏好的智能模式阈值
    ["total_interactions"]=0                  # 总交互次数
    ["direct_mode_usage"]=0                   # 直接模式使用次数
    ["intelligent_mode_usage"]=0              # 智能模式使用次数
    ["satisfaction_score"]=0.8               # 用户满意度评分
    ["avg_response_time"]=0                   # 平均响应时间
    ["last_updated"]=""                       # 最后更新时间
)

# 记录用户行为
record_user_behavior() {
    local user_id="$1"
    local behavior_type="$2"
    local behavior_data="$3"

    # smart_echo "📊 记录用户行为: $user_id - $behavior_type" "info"

    # 加载现有用户画像
    load_user_profile "$user_id"

    # 更新行为数据
    case "$behavior_type" in
        "mode_selection")
            update_mode_selection_behavior "$behavior_type" "$behavior_data"
            ;;
        "confirmation_answer")
            update_confirmation_behavior "$behavior_type" "$behavior_data"
            ;;
        "task_completion")
            update_task_completion_behavior "$behavior_type" "$behavior_data"
            ;;
        "feedback")
            update_feedback_behavior "$behavior_type" "$behavior_data"
            ;;
    esac

    # 保存更新后的用户画像
    save_user_profile "$user_id"

    # smart_echo "✅ 用户行为已记录" "success"
}

# 更新模式选择行为
update_mode_selection_behavior() {
    local behavior_type="$1"
    local behavior_data="$2"

    local selected_mode=$(echo "$behavior_data" | jq -r '.selected_mode // "unknown"')
    local complexity=$(echo "$behavior_data" | jq -r '.complexity // 0')
    local user_satisfaction=$(echo "$behavior_data" | jq -r '.user_satisfaction // 0.8')

    # 更新使用统计
    ((USER_BEHAVIOR_PROFILE["total_interactions"]++))
    case "$selected_mode" in
        "direct")
            ((USER_BEHAVIOR_PROFILE["direct_mode_usage"]++))
            ;;
        "intelligent")
            ((USER_BEHAVIOR_PROFILE["intelligent_mode_usage"]++))
            ;;
    esac

    # 动态调整阈值
    adjust_dynamic_thresholds "$complexity" "$selected_mode" "$user_satisfaction"

    # 更新满意度 (加权平均)
    local current_satisfaction=${USER_BEHAVIOR_PROFILE["satisfaction_score"]}
    local total_interactions=${USER_BEHAVIOR_PROFILE["total_interactions"]}
    local new_satisfaction=$(echo "scale=3; ($current_satisfaction * ($total_interactions - 1) + $user_satisfaction) / $total_interactions" | bc -l 2>/dev/null || echo "$current_satisfaction")
    USER_BEHAVIOR_PROFILE["satisfaction_score"]=$new_satisfaction
}

# 动态调整阈值
adjust_dynamic_thresholds() {
    local complexity="$1"
    local selected_mode="$2"
    local satisfaction="$3"

    local current_direct_threshold=${USER_BEHAVIOR_PROFILE["preferred_direct_threshold"]}
    local current_intelligent_threshold=${USER_BEHAVIOR_PROFILE["preferred_intelligent_threshold"]}

    # 如果用户对选择满意，稍微调整阈值向该模式靠拢
    if (( $(echo "$satisfaction > 0.7" | bc -l 2>/dev/null || echo "0") )); then
        case "$selected_mode" in
            "direct")
                # 如果复杂度接近当前阈值，且用户满意，稍微降低直接模式阈值
                if (( $(echo "$complexity > $current_direct_threshold - 0.5 && $complexity < $current_direct_threshold + 0.5" | bc -l 2>/dev/null || echo "0") )); then
                    local new_threshold=$(echo "scale=2; $current_direct_threshold - 0.1" | bc -l 2>/dev/null || echo "$current_direct_threshold")
                    if (( $(echo "$new_threshold > 0.5" | bc -l 2>/dev/null || echo "0") )); then
                        USER_BEHAVIOR_PROFILE["preferred_direct_threshold"]=$new_threshold
                    fi
                fi
                ;;
            "intelligent")
                # 如果复杂度接近当前阈值，且用户满意，稍微提高智能模式阈值
                if (( $(echo "$complexity > $current_intelligent_threshold - 0.5 && $complexity < $current_intelligent_threshold + 0.5" | bc -l 2>/dev/null || echo "0") )); then
                    local new_threshold=$(echo "scale=2; $current_intelligent_threshold - 0.1" | bc -l 2>/dev/null || echo "$current_intelligent_threshold")
                    USER_BEHAVIOR_PROFILE["preferred_intelligent_threshold"]=$new_threshold
                fi
                ;;
        esac
    fi
}

# 更新确认行为
update_confirmation_behavior() {
    local behavior_type="$1"
    local behavior_data="$2"

    # 这里可以记录用户对不同类型问题的回答偏好
    # 暂时简化处理
    local question_category=$(echo "$behavior_data" | jq -r '.question_category // "unknown"')
    local answer=$(echo "$behavior_data" | jq -r '.answer // ""')
    local time_taken=$(echo "$behavior_data" | jq -r '.time_taken // 0')

    # 更新平均响应时间
    local current_avg=${USER_BEHAVIOR_PROFILE["avg_response_time"]}
    local total_interactions=${USER_BEHAVIOR_PROFILE["total_interactions"]}

    if (( total_interactions > 0 )); then
        local new_avg=$(echo "scale=2; ($current_avg * ($total_interactions - 1) + $time_taken) / $total_interactions" | bc -l 2>/dev/null || echo "$current_avg")
        USER_BEHAVIOR_PROFILE["avg_response_time"]=$new_avg
    fi
}

# 更新任务完成行为
update_task_completion_behavior() {
    local behavior_type="$1"
    local behavior_data="$2"

    # 记录任务完成情况，用于后续推荐
    local task_type=$(echo "$behavior_data" | jq -r '.task_type // "unknown"')
    local completion_time=$(echo "$behavior_data" | jq -r '.completion_time // 0')
    local success=$(echo "$behavior_data" | jq -r '.success // true')

    # 这里可以存储历史任务数据，用于模式推荐
    # 暂时记录在行为配置中
    # TODO: 实现更复杂的历史任务存储
}

# 更新反馈行为
update_feedback_behavior() {
    local behavior_type="$1"
    local behavior_data="$2"

    local feedback_score=$(echo "$behavior_data" | jq -r '.score // 0.8')
    local feedback_type=$(echo "$behavior_data" | jq -r '.type // "general"')

    # 更新满意度评分
    local current_satisfaction=${USER_BEHAVIOR_PROFILE["satisfaction_score"]}
    local new_satisfaction=$(echo "scale=3; ($current_satisfaction + $feedback_score) / 2" | bc -l 2>/dev/null || echo "$current_satisfaction")
    USER_BEHAVIOR_PROFILE["satisfaction_score"]=$new_satisfaction
}

# 加载用户画像
load_user_profile() {
    local user_id="$1"

    local profile_file="$USER_DATA_DIR/learning/${user_id}_profile.json"

    if [[ -f "$profile_file" ]]; then
        # 从文件中加载配置
        local profile_data=$(cat "$profile_file" 2>/dev/null || echo "{}")

        # 解析并更新全局变量
        USER_BEHAVIOR_PROFILE["preferred_direct_threshold"]=$(echo "$profile_data" | jq -r '.preferred_direct_threshold // 2.0')
        USER_BEHAVIOR_PROFILE["preferred_intelligent_threshold"]=$(echo "$profile_data" | jq -r '.preferred_intelligent_threshold // 3.5')
        USER_BEHAVIOR_PROFILE["total_interactions"]=$(echo "$profile_data" | jq -r '.total_interactions // 0')
        USER_BEHAVIOR_PROFILE["direct_mode_usage"]=$(echo "$profile_data" | jq -r '.direct_mode_usage // 0')
        USER_BEHAVIOR_PROFILE["intelligent_mode_usage"]=$(echo "$profile_data" | jq -r '.intelligent_mode_usage // 0')
        USER_BEHAVIOR_PROFILE["satisfaction_score"]=$(echo "$profile_data" | jq -r '.satisfaction_score // 0.8')
        USER_BEHAVIOR_PROFILE["avg_response_time"]=$(echo "$profile_data" | jq -r '.avg_response_time // 0')
        USER_BEHAVIOR_PROFILE["last_updated"]=$(echo "$profile_data" | jq -r '.last_updated // ""')
    fi
}

# 保存用户画像
save_user_profile() {
    local user_id="$1"

    # 确保目录存在
    mkdir -p "$USER_DATA_DIR/learning"

    local profile_file="$USER_DATA_DIR/learning/${user_id}_profile.json"

    # 更新最后更新时间
    USER_BEHAVIOR_PROFILE["last_updated"]=$(date -Iseconds)

    # 构建JSON数据
    local profile_json=$(cat <<EOF
{
  "user_id": "$user_id",
  "preferred_direct_threshold": ${USER_BEHAVIOR_PROFILE["preferred_direct_threshold"]},
  "preferred_intelligent_threshold": ${USER_BEHAVIOR_PROFILE["preferred_intelligent_threshold"]},
  "total_interactions": ${USER_BEHAVIOR_PROFILE["total_interactions"]},
  "direct_mode_usage": ${USER_BEHAVIOR_PROFILE["direct_mode_usage"]},
  "intelligent_mode_usage": ${USER_BEHAVIOR_PROFILE["intelligent_mode_usage"]},
  "satisfaction_score": ${USER_BEHAVIOR_PROFILE["satisfaction_score"]},
  "avg_response_time": ${USER_BEHAVIOR_PROFILE["avg_response_time"]},
  "last_updated": "${USER_BEHAVIOR_PROFILE["last_updated"]}",
  "version": "1.0"
}
EOF
)

    # 保存到文件
    echo "$profile_json" > "$profile_file"
}

# =============================================================================
# 模式推荐系统
# =============================================================================

# 基于历史表现推荐模式
recommend_execution_mode() {
    local user_id="$1"
    local complexity="$2"
    local task_type="${3:-unknown}"

    # 加载用户画像
    load_user_profile "$user_id"

    local total_interactions=${USER_BEHAVIOR_PROFILE["total_interactions"]}

    # 如果没有足够的历史数据，使用默认逻辑
    if (( total_interactions < 3 )); then
        # 使用标准复杂度阈值
        if (( $(echo "$complexity <= 2.0" | bc -l 2>/dev/null || echo "0") )); then
            echo "direct"
        else
            echo "intelligent"
        fi
        return
    fi

    # 计算用户偏好
    local direct_usage=${USER_BEHAVIOR_PROFILE["direct_mode_usage"]}
    local intelligent_usage=${USER_BEHAVIOR_PROFILE["intelligent_mode_usage"]}
    local satisfaction=${USER_BEHAVIOR_PROFILE["satisfaction_score"]}

    # 使用偏好的阈值
    local preferred_direct=${USER_BEHAVIOR_PROFILE["preferred_direct_threshold"]}
    local preferred_intelligent=${USER_BEHAVIOR_PROFILE["preferred_intelligent_threshold"]}

    # 基于用户偏好调整阈值
    if (( $(echo "$satisfaction > 0.8" | bc -l 2>/dev/null || echo "0") )); then
        # 高满意度用户，信任他们的偏好
        if (( $(echo "$complexity <= $preferred_direct" | bc -l 2>/dev/null || echo "0") )); then
            echo "direct"
        elif (( $(echo "$complexity >= $preferred_intelligent" | bc -l 2>/dev/null || echo "0") )); then
            echo "intelligent"
        else
            # 中等复杂度，基于使用频率选择
            if (( direct_usage > intelligent_usage )); then
                echo "direct"
            else
                echo "intelligent"
            fi
        fi
    else
        # 低满意度用户，使用更保守的策略
        if (( $(echo "$complexity <= 1.5" | bc -l 2>/dev/null || echo "0") )); then
            echo "direct"
        else
            echo "intelligent"
        fi
    fi
}

# 获取用户画像摘要
get_user_profile_summary() {
    local user_id="$1"

    # 加载用户画像
    load_user_profile "$user_id"

    local total=${USER_BEHAVIOR_PROFILE["total_interactions"]}
    local direct=${USER_BEHAVIOR_PROFILE["direct_mode_usage"]}
    local intelligent=${USER_BEHAVIOR_PROFILE["intelligent_mode_usage"]}
    local satisfaction=${USER_BEHAVIOR_PROFILE["satisfaction_score"]}
    local direct_threshold=${USER_BEHAVIOR_PROFILE["preferred_direct_threshold"]}
    local intelligent_threshold=${USER_BEHAVIOR_PROFILE["preferred_intelligent_threshold"]}

    # 计算百分比
    local direct_percentage=0
    local intelligent_percentage=0

    if (( total > 0 )); then
        direct_percentage=$(echo "scale=1; ($direct * 100) / $total" | bc -l 2>/dev/null || echo "0")
        intelligent_percentage=$(echo "scale=1; ($intelligent * 100) / $total" | bc -l 2>/dev/null || echo "0")
    fi

    cat <<EOF
{
  "user_id": "$user_id",
  "total_interactions": $total,
  "mode_usage": {
    "direct": {
      "count": $direct,
      "percentage": ${direct_percentage}
    },
    "intelligent": {
      "count": $intelligent,
      "percentage": ${intelligent_percentage}
    }
  },
  "satisfaction_score": $satisfaction,
  "preferred_thresholds": {
    "direct_mode": $direct_threshold,
    "intelligent_mode": $intelligent_threshold
  },
  "last_updated": "${USER_BEHAVIOR_PROFILE["last_updated"]}"
}
EOF
}

# =============================================================================
# 模式切换日志系统
# =============================================================================

# 记录模式切换事件
log_mode_switch_event() {
    local user_id="$1"
    local from_mode="$2"
    local to_mode="$3"
    local reason="$4"
    local context="${5:-}"

    # 确保日志目录存在
    mkdir -p "$USER_DATA_DIR/learning/logs"

    local log_file="$USER_DATA_DIR/learning/logs/mode_switch_$(date +%Y%m%d).log"

    local log_entry=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "user_id": "$user_id",
  "from_mode": "$from_mode",
  "to_mode": "$to_mode",
  "reason": "$reason",
  "context": "$context",
  "version": "1.0"
}
EOF
)

    # 追加到日志文件
    echo "$log_entry" >> "$log_file"
}

# 获取模式切换统计
get_mode_switch_stats() {
    local user_id="${1:-all}"
    local days="${2:-7}"

    local log_files=$(find "$USER_DATA_DIR/learning/logs" -name "mode_switch_*.log" -mtime -$days 2>/dev/null || echo "")

    local total_switches=0
    local direct_to_intelligent=0
    local intelligent_to_direct=0

    for log_file in $log_files; do
        if [[ -f "$log_file" ]]; then
            while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    if [[ "$user_id" == "all" ]] || [[ $(echo "$line" | jq -r '.user_id') == "$user_id" ]]; then
                        ((total_switches++))
                        local from_mode=$(echo "$line" | jq -r '.from_mode')
                        local to_mode=$(echo "$line" | jq -r '.to_mode')

                        if [[ "$from_mode" == "direct" && "$to_mode" == "intelligent" ]]; then
                            ((direct_to_intelligent++))
                        elif [[ "$from_mode" == "intelligent" && "$to_mode" == "direct" ]]; then
                            ((intelligent_to_direct++))
                        fi
                    fi
                fi
            done < "$log_file"
        fi
    done

    cat <<EOF
{
  "period_days": $days,
  "user_filter": "$user_id",
  "total_switches": $total_switches,
  "switch_types": {
    "direct_to_intelligent": $direct_to_intelligent,
    "intelligent_to_direct": $intelligent_to_direct
  },
  "generated_at": "$(date -Iseconds)"
}
EOF
}

# =============================================================================
# Master命令中心集成
# =============================================================================

# 获取学习系统状态
get_learning_system_status() {
    local user_id="${1:-default_user}"

    local profile_summary=$(get_user_profile_summary "$user_id")
    local switch_stats=$(get_mode_switch_stats "$user_id" 7)

    cat <<EOF
{
  "learning_system": {
    "status": "active",
    "user_profiles": $(echo "$profile_summary" | jq -c .),
    "recent_switches": $(echo "$switch_stats" | jq -c .),
    "features": [
      "user_behavior_learning",
      "adaptive_thresholds",
      "mode_recommendations",
      "switch_logging"
    ]
  },
  "last_updated": "$(date -Iseconds)",
  "version": "1.0"
}
EOF
}

# =============================================================================
# 函数导出
# =============================================================================

export -f record_user_behavior
export -f recommend_execution_mode
export -f get_user_profile_summary
export -f log_mode_switch_event
export -f get_mode_switch_stats
export -f get_learning_system_status

# 初始化目录
mkdir -p "$USER_DATA_DIR/learning"
mkdir -p "$USER_DATA_DIR/learning/logs"

# smart_echo "🎓 自适应学习系统模块已加载" "success"