#!/bin/bash
# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"
# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"

source "$SCRIPT_DIR/../../core/path-config.sh"  # 统一路径配置

# 📋 会话摘要Hook - 在AI会话结束时生成总结报告
# 用于分析和改进AI协作效果

# 读取JSON输入
input=$(cat)
status=$(echo "$input" | jq -r '.status // empty')
loop_count=$(echo "$input" | jq -r '.loop_count // 0')
conversation_id=$(echo "$input" | jq -r '.conversation_id // empty')

# 创建日志目录（如果不存在）
safe_file_operation "mkdir" "$SYSTEM_LOGS_DIR"

# 记录会话结束
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$timestamp] SESSION_END: $conversation_id | Status: $status | Loops: $loop_count" >> "$SYSTEM_LOGS_DIR/session-summary.log"

# 如果会话完成，生成摘要报告
if [[ "$status" == "completed" ]]; then
    echo "📊 生成会话摘要报告..." >> $SYSTEM_LOGS_DIR/session-summary.log

    # 计算本次会话的统计信息
    session_start=$(grep "$conversation_id" $SYSTEM_LOGS_DIR/rule-usage.log | head -1 | cut -d'|' -f1)
    session_rules=$(grep "$conversation_id" $SYSTEM_LOGS_DIR/rule-usage.log | wc -l)
    session_commands=$(grep "$conversation_id" $SYSTEM_LOGS_DIR/command-execution.log | wc -l)

    # 获取使用的规则列表
    rules_used=$(grep "$conversation_id" $SYSTEM_LOGS_DIR/rule-usage.log | grep "USED:" | cut -d'|' -f3 | tr ',' '\n' | sort | uniq | tr '\n' ',' | sed 's/,$//')

    # 获取命令执行统计
    total_duration=$(grep "$conversation_id" $SYSTEM_LOGS_DIR/command-execution.log | cut -d'|' -f5 | paste -sd+ | bc 2>/dev/null || echo "0")

    # 生成摘要
    cat << EOF > $SYSTEM_LOGS_DIR/session-$conversation_id.md
# 📋 会话摘要报告
**会话ID:** $conversation_id
**开始时间:** $session_start
**结束时间:** $timestamp
**状态:** $status
**循环次数:** $loop_count

## 📊 统计数据
- **使用的规则数量:** $session_rules
- **执行的命令数量:** $session_commands
- **命令总执行时间:** ${total_duration}ms

## 🔧 使用的规则
$rules_used

## 📈 性能指标
- 平均命令执行时间: $((total_duration / (session_commands > 0 ? session_commands : 1)))ms
- 规则使用率: $((session_rules * 100 / (loop_count > 0 ? loop_count : 1)))%

---
*报告生成时间: $timestamp*
EOF

    echo "✅ 会话摘要已生成: $SYSTEM_LOGS_DIR/session-$conversation_id.md" >> $SYSTEM_LOGS_DIR/session-summary.log
fi

# 如果会话出错，记录错误信息
if [[ "$status" == "error" ]]; then
    echo "[$timestamp] SESSION_ERROR: $conversation_id | Loops: $loop_count" >> $SYSTEM_LOGS_DIR/session-errors.log

    # 分析可能的错误原因
    recent_errors=$(tail -10 $SYSTEM_LOGS_DIR/command-errors.log | grep -c "ERROR" || echo "0")
    security_blocks=$(grep "$conversation_id" $SYSTEM_LOGS_DIR/security-events.log | wc -l)

    if [[ $security_blocks -gt 0 ]]; then
        error_reason="安全策略阻止"
    elif [[ $recent_errors -gt 0 ]]; then
        error_reason="命令执行错误"
    else
        error_reason="未知错误"
    fi

    echo "[$timestamp] ERROR_ANALYSIS: $conversation_id | Reason: $error_reason | Security blocks: $security_blocks | Command errors: $recent_errors" >> $SYSTEM_LOGS_DIR/session-errors.log
fi

exit 0