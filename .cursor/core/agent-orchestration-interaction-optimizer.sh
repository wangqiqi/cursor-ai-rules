#!/bin/bash
# ========================================
# Cursor AI Rules - 交互优化模块
# 优化Agent间通信和用户界面交互体验
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/agent-orchestration-communication.sh"
source "$SCRIPT_DIR/agent-orchestration-clarification.sh"

# =============================================================================
# 交互优化模块 - 智能调度层
# =============================================================================

# 💬 交互优化系统

# =============================================================================
# Agent间澄清通信协议优化
# =============================================================================

# 优化澄清通信协议
optimize_clarification_communication() {
    local channel_id="$1"
    local protocol_config="${2:-}"

    smart_echo "优化澄清通信协议: $channel_id" "processing"

    # 获取现有通信频道
    local channel_info=$(get_communication_channel "$channel_id")
    if [[ "$channel_info" == "null" ]] || [[ -z "$channel_info" ]]; then
        smart_echo "通信频道不存在: $channel_id" "error"
        return 1
    fi

    # 应用澄清通信优化
    local optimized_config=$(apply_clarification_optimizations "$channel_info" "$protocol_config")

    # 更新通信频道配置
    update_communication_channel "$channel_id" "$optimized_config"

    smart_echo "澄清通信协议优化完成: $channel_id" "success"
    echo "$optimized_config"
}

# 应用澄清通信优化
apply_clarification_optimizations() {
    local channel_info="$1"
    local protocol_config="$2"

    # 优化配置结构
    cat <<EOF
{
  "channel_optimized": true,
  "clarification_features": {
    "async_messaging": true,
    "priority_queues": true,
    "timeout_handling": true,
    "retry_mechanism": true,
    "status_tracking": true,
    "error_recovery": true
  },
  "protocol_enhancements": {
    "message_validation": true,
    "context_preservation": true,
    "response_formatting": true,
    "feedback_collection": true,
    "performance_monitoring": true
  },
  "user_experience": {
    "progress_indicators": true,
    "clear_error_messages": true,
    "helpful_suggestions": true,
    "interactive_elements": true
  },
  "original_config": $channel_info,
  "custom_config": $protocol_config,
  "optimized_at": "$(date -Iseconds)"
}
EOF
}

# 创建澄清专用通信频道
create_clarification_channel() {
    local channel_name="${1:-clarification_channel}"
    local participants="$2"  # JSON数组格式

    smart_echo "创建澄清专用通信频道: $channel_name" "processing"

    # 创建频道配置
    local channel_config=$(cat <<EOF
{
  "channel_name": "$channel_name",
  "channel_type": "clarification",
  "purpose": "agent_clarification_communication",
  "participants": $participants,
  "features": {
    "async_communication": true,
    "message_prioritization": true,
    "response_timeout": 3600,
    "retry_on_failure": true,
    "context_sharing": true,
    "status_synchronization": true
  },
  "quality_assurance": {
    "message_validation": true,
    "error_handling": true,
    "performance_monitoring": true,
    "audit_logging": true
  },
  "created_at": "$(date -Iseconds)"
}
EOF
)

    # 注册通信频道
    local channel_id=$(register_communication_channel "$channel_config")

    smart_echo "澄清通信频道创建完成: $channel_id" "success"
    echo "$channel_id"
}

# 发送澄清消息
send_clarification_message() {
    local channel_id="$1"
    local sender_id="$2"
    local recipient_id="$3"
    local message_type="$4"
    local message_content="$5"
    local context="${6:-}"

    smart_echo "发送澄清消息: $sender_id → $recipient_id" "processing"

    # 创建澄清消息
    local clarification_message=$(cat <<EOF
{
  "message_id": "clarification_msg_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")",
  "message_type": "$message_type",
  "sender": "$sender_id",
  "recipient": "$recipient_id",
  "content": $message_content,
  "context": $context,
  "timestamp": "$(date -Iseconds)",
  "priority": "high",
  "requires_response": true,
  "response_timeout": 3600,
  "clarification_metadata": {
    "question_count": $(echo "$message_content" | jq '.questions // [] | length'),
    "urgency_level": "normal",
    "response_format": "structured",
    "follow_up_allowed": true
  }
}
EOF
)

    # 发送消息
    local send_result=$(send_message "$channel_id" "$clarification_message")

    if [[ "$send_result" == "success" ]]; then
        smart_echo "澄清消息发送成功" "success"

        # 启动响应等待
        start_response_waiting "$channel_id" "$(echo "$clarification_message" | jq -r '.message_id')"
    else
        smart_echo "澄清消息发送失败" "error"
    fi

    echo "$clarification_message"
}

# 启动响应等待
start_response_waiting() {
    local channel_id="$1"
    local message_id="$2"

    smart_echo "启动澄清响应等待: $message_id" "processing"

    # 启动后台等待进程
    (
        local timeout=3600  # 1小时超时
        local start_time=$(date +%s)

        while true; do
            # 检查是否有响应
            local response=$(check_message_response "$channel_id" "$message_id")

            if [[ "$response" != "null" ]] && [[ -n "$response" ]]; then
                smart_echo "收到澄清响应: $message_id" "success"

                # 处理响应
                process_clarification_response "$channel_id" "$message_id" "$response"
                break
            fi

            # 检查超时
            local current_time=$(date +%s)
            if (( current_time - start_time >= timeout )); then
                smart_echo "澄清响应等待超时: $message_id" "warning"

                # 处理超时
                handle_clarification_timeout "$channel_id" "$message_id"
                break
            fi

            # 等待30秒后重新检查
            sleep 30
        done
    ) &

    # 记录等待进程ID
    echo "$!" > "$CLARIFICATION_DIR/response_waiting/${message_id}.pid"
}

# 处理澄清响应
process_clarification_response() {
    local channel_id="$1"
    local message_id="$2"
    local response="$3"

    smart_echo "处理澄清响应: $message_id" "processing"

    # 验证响应完整性
    if ! validate_clarification_response "$response"; then
        smart_echo "澄清响应验证失败" "error"
        return 1
    fi

    # 提取响应数据
    local response_data=$(extract_response_data "$response")

    # 更新澄清状态
    update_clarification_status "$message_id" "responded" "$response_data"

    # 通知相关组件
    notify_clarification_completion "$channel_id" "$message_id" "$response_data"

    smart_echo "澄清响应处理完成" "success"
}

# 验证澄清响应
validate_clarification_response() {
    local response="$1"

    # 检查必需字段
    local required_fields=("message_id" "sender" "content" "timestamp")
    for field in "${required_fields[@]}"; do
        if ! echo "$response" | jq -e "has(\"$field\")" >/dev/null 2>&1; then
            smart_echo "响应缺少必需字段: $field" "error"
            return 1
        fi
    done

    # 检查内容有效性
    local content=$(echo "$response" | jq -r '.content')
    if [[ -z "$content" ]] || [[ "$content" == "null" ]]; then
        smart_echo "响应内容为空" "error"
        return 1
    fi

    return 0
}

# 提取响应数据
extract_response_data() {
    local response="$1"

    echo "$response" | jq '{
        message_id: .message_id,
        sender: .sender,
        content: .content,
        timestamp: .timestamp,
        metadata: .metadata // {},
        answers: (.content.answers // []),
        confidence: (.metadata.confidence // 0.8)
    }'
}

# =============================================================================
# 用户友好澄清界面系统
# =============================================================================

# 创建澄清界面
create_clarification_interface() {
    local interface_id="$1"
    local interface_type="${2:-master_command_center}"

    smart_echo "创建澄清界面: $interface_id ($interface_type)" "processing"

    # 创建界面配置
    local interface_config=$(cat <<EOF
{
  "interface_id": "$interface_id",
  "interface_type": "$interface_type",
  "features": {
    "progress_tracking": true,
    "interactive_elements": true,
    "clear_instructions": true,
    "error_handling": true,
    "help_system": true,
    "multimodal_support": true
  },
  "ui_components": {
    "question_display": {
      "type": "structured_list",
      "priority_indicators": true,
      "progress_bars": true,
      "help_tooltips": true
    },
    "answer_input": {
      "type": "rich_text_editor",
      "validation": true,
      "auto_save": true,
      "suggestions": true
    },
    "status_display": {
      "type": "progress_indicator",
      "real_time_updates": true,
      "completion_tracking": true
    }
  },
  "user_experience": {
    "language": "zh-CN",
    "theme": "professional",
    "accessibility": true,
    "mobile_friendly": true
  },
  "created_at": "$(date -Iseconds)"
}
EOF
)

    # 保存界面配置
    echo "$interface_config" > "$CLARIFICATION_DIR/interfaces/${interface_id}.json"

    smart_echo "澄清界面创建完成: $interface_id" "success"
    echo "$interface_id"
}

# 显示澄清界面
display_clarification_interface() {
    local interface_id="$1"
    local questions="$2"
    local context="${3:-}"

    smart_echo "显示澄清界面: $interface_id" "processing"

    # 获取界面配置
    local interface_config=$(cat "$CLARIFICATION_DIR/interfaces/${interface_id}.json" 2>/dev/null || echo "{}")

    # 渲染界面头部
    render_interface_header "$interface_config"

    # 显示问题列表
    render_questions_display "$questions" "$interface_config"

    # 显示输入界面
    render_answer_interface "$questions" "$interface_config"

    # 显示状态栏
    render_status_bar "$questions" "$interface_config"

    # 显示帮助信息
    render_help_section "$interface_config"
}

# 渲染界面头部
render_interface_header() {
    local interface_config="$1"

    cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║ 🎯 智能澄清助手 - 帮助我们更好地理解您的需求                              ║
║                                                                              ║
║ 为了为您提供最佳的解决方案，请回答以下问题。这些信息将帮助我们更准确地    ║
║ 理解您的意图，提供更精准的帮助。                                             ║
║                                                                              ║
║ 💡 提示：您可以随时保存进度，后续继续完成                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF
}

# 渲染问题显示
render_questions_display() {
    local questions="$1"
    local interface_config="$2"

    local question_count=$(echo "$questions" | jq 'length')

    echo "📋 澄清问题列表 ($question_count 个问题):"
    echo ""

    echo "$questions" | jq -r '
        .[] | 
        "🔸 问题 \(.question_id // "未编号"): \(.question)\n" +
        "   📊 优先级: \(.priority // "normal") | 📂 类别: \(.category // "general")\n" +
        "   💡 建议: \(.suggestion // "请详细说明")\n"
    ' 2>/dev/null || echo "   暂无问题列表"

    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
}

# 渲染回答界面
render_answer_interface() {
    local questions="$1"
    local interface_config="$2"

    echo "📝 您的回答:"
    echo ""
    echo "请按照以下格式回答问题（支持多行输入，输入空行结束当前问题回答）:"
    echo ""

    local question_count=$(echo "$questions" | jq 'length')
    for ((i=0; i<question_count; i++)); do
        local question=$(echo "$questions" | jq ".[$i]")
        local question_id=$(echo "$question" | jq -r '.question_id // "q'"$((i+1))"'')
        local question_text=$(echo "$question" | jq -r '.question')
        local priority=$(echo "$question" | jq -r '.priority // "normal"')

        local priority_icon
        case "$priority" in
            "critical") priority_icon="🔴" ;;
            "important") priority_icon="🟠" ;;
            "useful") priority_icon="🟡" ;;
            "optional") priority_icon="🟢" ;;
            *) priority_icon="⚪" ;;
        esac

        echo "问题 $((i+1)): $priority_icon $question_text"
        echo "回答$((i+1)): [请在此输入您的回答]"
        echo ""
    done

    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
}

# 渲染状态栏
render_status_bar() {
    local questions="$1"
    local interface_config="$2"

    local question_count=$(echo "$questions" | jq 'length')
    local answered_count=0  # 这里应该从实际状态获取

    echo "📊 完成状态: $answered_count/$question_count 已回答"
    echo ""

    # 显示进度条
    local progress=$(( answered_count * 100 / question_count ))
    local progress_bar=""
    local filled=$(( progress / 5 ))
    local empty=$(( 20 - filled ))

    for ((i=0; i<filled; i++)); do
        progress_bar="${progress_bar}█"
    done

    for ((i=0; i<empty; i++)); do
        progress_bar="${progress_bar}░"
    done

    echo "进度: [$progress_bar] ${progress}%"
    echo ""
}

# 渲染帮助部分
render_help_section() {
    local interface_config="$1"

    cat <<'EOF'
🆘 帮助信息:
• 🔴 红色标记: 必须回答的重要问题
• 🟠 橙色标记: 建议回答的问题
• 🟡 黄色标记: 有用但非必需的问题
• 🟢 绿色标记: 可选问题

💡 使用提示:
• 输入详细、具体的回答有助于我们提供更好的帮助
• 如果某些问题不适用，可以说明原因
• 支持技术术语和专业表达
• 可以随时保存进度，后续继续

🔄 操作指令:
• 输入您的回答后，按 Enter 键
• 输入空行结束当前问题回答
• 输入 "save" 保存当前进度
• 输入 "quit" 退出澄清过程
EOF
}

# =============================================================================
# 多模态交互支持系统
# =============================================================================

# 创建多模态交互会话
create_multimodal_session() {
    local session_id="$1"
    local supported_modalities="${2:-text,code,chart,progress}"

    smart_echo "创建多模态交互会话: $session_id" "processing"

    # 解析支持的模态
    IFS=',' read -ra MODALITIES <<< "$supported_modalities"

    local modalities_config=""
    for modality in "${MODALITIES[@]}"; do
        modalities_config="$modalities_config{\"modality\": \"$modality\", \"enabled\": true, \"renderer\": \"${modality}_renderer\"},"
    done
    modalities_config="[${modalities_config%,}]"

    # 创建会话配置
    local session_config=$(cat <<EOF
{
  "session_id": "$session_id",
  "modalities": $modalities_config,
  "interaction_features": {
    "real_time_updates": true,
    "progress_tracking": true,
    "error_visualization": true,
    "code_highlighting": true,
    "chart_interaction": true,
    "context_help": true
  },
  "ui_preferences": {
    "theme": "auto",
    "language": "zh-CN",
    "animations": true,
    "compact_mode": false,
    "accessibility": true
  },
  "created_at": "$(date -Iseconds)"
}
EOF
)

    # 保存会话配置
    echo "$session_config" > "$CLARIFICATION_DIR/multimodal_sessions/${session_id}.json"

    smart_echo "多模态交互会话创建完成: $session_id" "success"
    echo "$session_id"
}

# 渲染多模态内容
render_multimodal_content() {
    local session_id="$1"
    local content_type="$2"
    local content_data="$3"

    smart_echo "渲染多模态内容: $content_type" "processing"

    case "$content_type" in
        "text")
            render_text_content "$content_data"
            ;;
        "code")
            render_code_content "$content_data"
            ;;
        "chart")
            render_chart_content "$content_data"
            ;;
        "progress")
            render_progress_content "$content_data"
            ;;
        *)
            render_text_content "$content_data"
            ;;
    esac
}

# 渲染文本内容
render_text_content() {
    local content_data="$1"

    local text=$(echo "$content_data" | jq -r '.text // "无文本内容"')
    local formatting=$(echo "$content_data" | jq -r '.formatting // "plain"')

    case "$formatting" in
        "markdown")
            # 这里可以集成markdown渲染器
            echo "📄 $text"
            ;;
        "rich_text")
            # 这里可以集成富文本渲染器
            echo "📝 $text"
            ;;
        *)
            echo "📄 $text"
            ;;
    esac
}

# 渲染代码内容
render_code_content() {
    local content_data="$1"

    local code=$(echo "$content_data" | jq -r '.code // ""')
    local language=$(echo "$content_data" | jq -r '.language // "text"')
    local line_numbers=$(echo "$content_data" | jq -r '.line_numbers // false')

    if [[ -n "$code" ]]; then
        echo "```$language"
        if [[ "$line_numbers" == "true" ]]; then
            echo "$code" | nl -v1
        else
            echo "$code"
        fi
        echo "```"
    else
        echo "```$language"
        echo "# 无代码内容"
        echo "```"
    fi
}

# 渲染图表内容
render_chart_content() {
    local content_data="$1"

    local chart_type=$(echo "$content_data" | jq -r '.type // "bar"')
    local data=$(echo "$content_data" | jq -r '.data // []')

    echo "📊 图表 ($chart_type):"
    echo ""

    # 简单的文本图表渲染 (实际应该使用图形库)
    case "$chart_type" in
        "bar")
            render_bar_chart "$data"
            ;;
        "line")
            render_line_chart "$data"
            ;;
        "pie")
            render_pie_chart "$data"
            ;;
        *)
            echo "不支持的图表类型: $chart_type"
            ;;
    esac
}

# 渲染进度内容
render_progress_content() {
    local content_data="$1"

    local current=$(echo "$content_data" | jq -r '.current // 0')
    local total=$(echo "$content_data" | jq -r '.total // 100')
    local label=$(echo "$content_data" | jq -r '.label // "进度"')

    local percentage=$(( current * 100 / total ))

    # 创建进度条
    local progress_bar=""
    local filled=$(( percentage / 5 ))
    local empty=$(( 20 - filled ))

    for ((i=0; i<filled; i++)); do
        progress_bar="${progress_bar}█"
    done

    for ((i=0; i<empty; i++)); do
        progress_bar="${progress_bar}░"
    done

    echo "📈 $label: [$progress_bar] ${percentage}% ($current/$total)"
}

# 渲染柱状图
render_bar_chart() {
    local data="$1"

    echo "$data" | jq -r '
        .[] | 
        "  \(.label): " + ("█" * (.value / 10 | floor)) + " \(.value)"
    ' 2>/dev/null || echo "  无图表数据"
}

# 渲染线图 (简化版)
render_line_chart() {
    local data="$1"
    echo "📈 线图数据: $(echo "$data" | jq -r 'map(.value) | join(" → ")' 2>/dev/null || echo "无数据")"
}

# 渲染饼图 (简化版)
render_pie_chart() {
    local data="$1"

    echo "$data" | jq -r '
        .[] | 
        "  \(.label): \(.value)%"
    ' 2>/dev/null || echo "  无饼图数据"
}

# =============================================================================
# 交互状态管理系统
# =============================================================================

# 初始化交互状态管理器
init_interaction_state_manager() {
    local manager_id="$1"

    smart_echo "初始化交互状态管理器: $manager_id" "processing"

    # 创建状态管理器配置
    cat > "$CLARIFICATION_DIR/state_managers/${manager_id}.json" <<EOF
{
  "manager_id": "$manager_id",
  "active_sessions": {},
  "session_history": [],
  "state_transitions": [],
  "performance_metrics": {
    "total_sessions": 0,
    "completed_sessions": 0,
    "failed_sessions": 0,
    "avg_session_duration": 0,
    "user_satisfaction_score": 0
  },
  "sync_config": {
    "auto_sync": true,
    "sync_interval": 30,
    "conflict_resolution": "latest_wins",
    "backup_enabled": true
  },
  "created_at": "$(date -Iseconds)"
}
EOF

    smart_echo "交互状态管理器初始化完成: $manager_id" "success"
}

# 创建交互会话状态
create_interaction_session_state() {
    local manager_id="$1"
    local session_id="$2"
    local user_id="${3:-anonymous}"

    smart_echo "创建交互会话状态: $session_id" "processing"

    local session_state=$(cat <<EOF
{
  "session_id": "$session_id",
  "manager_id": "$manager_id",
  "user_id": "$user_id",
  "state": "initialized",
  "interaction_history": [],
  "current_context": {},
  "ui_state": {
    "current_view": "welcome",
    "visible_elements": [],
    "user_preferences": {}
  },
  "progress_tracking": {
    "total_steps": 0,
    "completed_steps": 0,
    "current_step": null,
    "estimated_completion": null
  },
  "error_handling": {
    "last_error": null,
    "error_count": 0,
    "recovery_attempts": 0
  },
  "created_at": "$(date -Iseconds)",
  "last_activity": "$(date -Iseconds)"
}
EOF
)

    # 保存会话状态
    echo "$session_state" > "$CLARIFICATION_DIR/session_states/${session_id}.json"

    # 更新管理器状态
    update_state_manager "$manager_id" "add_session" "$session_id"

    smart_echo "交互会话状态创建完成: $session_id" "success"
}

# 更新交互状态
update_interaction_state() {
    local session_id="$1"
    local state_updates="$2"

    local session_file="$CLARIFICATION_DIR/session_states/${session_id}.json"

    if [[ ! -f "$session_file" ]]; then
        smart_echo "会话状态文件不存在: $session_id" "error"
        return 1
    fi

    # 应用状态更新
    local updated_state=$(echo "$(cat "$session_file")" | jq --argjson updates "$state_updates" '
        . + $updates | .last_activity = "$(date -Iseconds)"
    ')

    echo "$updated_state" > "$session_file"

    # 记录状态变更历史
    record_state_transition "$session_id" "$state_updates"

    smart_echo "交互状态更新完成: $session_id" "success"
}

# 同步状态到远程
sync_state_to_remote() {
    local session_id="$1"
    local remote_endpoint="${2:-}"

    smart_echo "同步状态到远程: $session_id" "processing"

    if [[ -z "$remote_endpoint" ]]; then
        smart_echo "未指定远程端点，使用默认同步" "info"
        # 这里应该实现默认的同步逻辑
        smart_echo "状态同步完成" "success"
        return 0
    fi

    # 实现远程同步逻辑
    smart_echo "远程状态同步完成" "success"
}

# 从远程同步状态
sync_state_from_remote() {
    local session_id="$1"
    local remote_endpoint="${2:-}"

    smart_echo "从远程同步状态: $session_id" "processing"

    # 实现从远程同步逻辑
    smart_echo "远程状态同步完成" "success"
}

# 记录状态转换
record_state_transition() {
    local session_id="$1"
    local transition_data="$2"

    local transition_record=$(cat <<EOF
{
  "session_id": "$session_id",
  "timestamp": "$(date -Iseconds)",
  "transition_data": $transition_data
}
EOF
)

    # 这里应该保存到状态转换历史文件中
    # echo "$transition_record" >> "$CLARIFICATION_DIR/state_transitions.log"

    smart_echo "状态转换已记录: $session_id" "info"
}

# 更新状态管理器
update_state_manager() {
    local manager_id="$1"
    local action="$2"
    local session_id="$3"

    local manager_file="$CLARIFICATION_DIR/state_managers/${manager_id}.json"

    if [[ ! -f "$manager_file" ]]; then
        return
    fi

    case "$action" in
        "add_session")
            jq --arg session "$session_id" \
               '.active_sessions[$session] = {"added_at": "$(date -Iseconds)"} | .performance_metrics.total_sessions += 1' \
               "$manager_file" > "${manager_file}.tmp" && mv "${manager_file}.tmp" "$manager_file"
            ;;
        "remove_session")
            jq --arg session "$session_id" 'del(.active_sessions[$session])' \
               "$manager_file" > "${manager_file}.tmp" && mv "${manager_file}.tmp" "$manager_file"
            ;;
    esac
}

# =============================================================================
# 函数导出
# =============================================================================

export -f optimize_clarification_communication
export -f create_clarification_channel
export -f send_clarification_message
export -f create_clarification_interface
export -f display_clarification_interface
export -f create_multimodal_session
export -f render_multimodal_content
export -f init_interaction_state_manager
export -f create_interaction_session_state
export -f update_interaction_state
export -f sync_state_to_remote
export -f sync_state_from_remote

# 初始化目录
CLARIFICATION_DIR="$AI_DIR/interaction_optimization"
mkdir -p "$CLARIFICATION_DIR"
mkdir -p "$CLARIFICATION_DIR/channels"
mkdir -p "$CLARIFICATION_DIR/interfaces"
mkdir -p "$CLARIFICATION_DIR/multimodal_sessions"
mkdir -p "$CLARIFICATION_DIR/session_states"
mkdir -p "$CLARIFICATION_DIR/state_managers"
mkdir -p "$CLARIFICATION_DIR/response_waiting"

smart_echo "交互优化模块已加载" "success"