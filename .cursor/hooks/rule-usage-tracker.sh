#!/bin/bash
# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../.cursor/core/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../.cursor/core/path-config.sh"  # 统一路径配置

# 📊 规则使用追踪Hook - 监控AI规则系统使用情况
# 用于优化和改进Cursor AI Rules系统

# 读取JSON输入
input=$(cat)
conversation_id=$(echo "$input" | jq -r '.conversation_id // empty')
response_text=$(echo "$input" | jq -r '.text // empty')

# 如果没有响应文本，退出
if [[ -z "$response_text" ]]; then
    exit 0
fi

# 创建日志目录（如果不存在）
mkdir -p "$ANALYTICS_MONITORING_DIR"

# 定义规则列表（基于项目中的规则文件）
declare -a rules_list=(
    "constitution"
    "philosophy"
    "intelligent_evolution"
    "generator"
    "system_info"
    "templates"
    "i18n"
    "platform_adapter"
    "module_manager"
    "eslint"
    "evolution-philosophy"
    "evolution-manual"
    "evolution-automation"
    "evolution-governance"
    "master"
)

# 检测使用的规则
rules_used=""
for rule in "${rules_list[@]}"; do
    # 检查响应文本是否提到了该规则
    if [[ "$response_text" =~ $rule ]]; then
        rules_used="${rules_used}$rule,"
    fi
done

# 移除末尾逗号
rules_used=${rules_used%,}

# 记录规则使用情况
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
if [[ -n "$rules_used" ]]; then
    log_entry="$timestamp|$conversation_id|USED:$rules_used"
    echo "$log_entry" >> $SYSTEM_LOGS_DIR/rule-usage.log
    echo "📋 检测到规则使用: $rules_used" >> $SYSTEM_LOGS_DIR/rule-usage.log
else
    log_entry="$timestamp|$conversation_id|NO_RULES_DETECTED"
    echo "$log_entry" >> $SYSTEM_LOGS_DIR/rule-usage.log
fi

# 分析响应质量指标
response_length=${#response_text}
word_count=$(echo "$response_text" | wc -w)

# 检查是否包含代码块
code_blocks=$(echo "$response_text" | grep -c '\`\`\`')

# 检查是否包含列表
lists=$(echo "$response_text" | grep -c "^[*-]")

# 检查是否包含表格
tables=$(echo "$response_text" | grep -c "^|")

# 记录质量指标
quality_metrics="$timestamp|$conversation_id|length:$response_length|words:$word_count|code_blocks:$code_blocks|lists:$lists|tables:$tables"
echo "$quality_metrics" >> $SYSTEM_LOGS_DIR/response-quality.log

# 分析规则应用模式
if [[ "$response_text" == *"constitution"* ]] && [[ "$response_text" == *"安全"* ]]; then
    echo "$timestamp|$conversation_id|PATTERN:security_focus" >> $SYSTEM_LOGS_DIR/rule-patterns.log
fi

if [[ "$response_text" == *"system_info"* ]] && [[ "$response_text" == *"时间"* ]]; then
    echo "$timestamp|$conversation_id|PATTERN:context_awareness" >> $SYSTEM_LOGS_DIR/rule-patterns.log
fi

if [[ "$response_text" == *"generator"* ]] && [[ "$response_text" == *"配置"* ]]; then
    echo "$timestamp|$conversation_id|PATTERN:configuration_generation" >> $SYSTEM_LOGS_DIR/rule-patterns.log
fi

# 生成使用统计摘要（每100次响应更新一次）
usage_count=$(wc -l < $SYSTEM_LOGS_DIR/rule-usage.log)
if [[ $((usage_count % 100)) -eq 0 ]]; then
    echo "📈 生成使用统计摘要..." >> $SYSTEM_LOGS_DIR/rule-usage.log

    # 计算最常用的规则
    echo "# 规则使用统计 - 最近 $usage_count 次响应" > "$SYSTEM_LOGS_DIR/usage-summary.md"
    echo "" >> $SYSTEM_LOGS_DIR/usage-summary.md
    echo "| 规则 | 使用次数 | 使用率 |" >> $SYSTEM_LOGS_DIR/usage-summary.md
    echo "|------|--------|-------|" >> $SYSTEM_LOGS_DIR/usage-summary.md

    for rule in "${rules_list[@]}"; do
        count=$(grep -c "$rule" $SYSTEM_LOGS_DIR/rule-usage.log)
        percentage=$((count * 100 / usage_count))
        echo "| $rule | $count | ${percentage}% |" >> $SYSTEM_LOGS_DIR/usage-summary.md
    done

    echo "" >> $SYSTEM_LOGS_DIR/usage-summary.md
    echo "*Generated at: $(date)*" >> "$SYSTEM_LOGS_DIR/usage-summary.md"
fi

exit 0