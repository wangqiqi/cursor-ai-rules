#!/bin/bash
# 📊 命令日志Hook - 记录所有shell命令执行结果
# 用于审计和性能监控

# 读取JSON输入
input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')
output=$(echo "$input" | jq -r '.output // empty')
duration=$(echo "$input" | jq -r '.duration // 0')

# 获取其他上下文信息
conversation_id=$(echo "$input" | jq -r '.conversation_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# 计算输出长度（用于性能分析）
output_length=${#output}

# 分析命令类型
command_type="unknown"
if [[ "$command" =~ ^(ls|pwd|cd|mkdir|touch) ]]; then
    command_type="file_system"
elif [[ "$command" =~ ^(git|gh) ]]; then
    command_type="version_control"
elif [[ "$command" =~ ^(npm|yarn|pnpm|pip|python|node) ]]; then
    command_type="package_management"
elif [[ "$command" =~ ^(curl|wget|http) ]]; then
    command_type="network"
elif [[ "$command" =~ ^(ps|top|kill|systemctl) ]]; then
    command_type="system"
elif [[ "$command" =~ ^(\./|\.cursor/scripts/) ]]; then
    command_type="project_script"
fi

# 记录详细日志
mkdir -p .cursorGrowth/logs
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_entry="$timestamp|$conversation_id|$command_type|$command|$duration|$output_length|$cwd"

echo "$log_entry" >> .cursorGrowth/logs/command-execution.log

# 如果执行时间过长，记录警告
if [[ $duration -gt 10000 ]]; then
    mkdir -p .cursorGrowth/logs
    echo "[$timestamp] SLOW_COMMAND: $command took ${duration}ms" >> .cursorGrowth/logs/performance-warnings.log
fi

# 如果命令失败（可以从输出中检测），记录错误
if [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]] || [[ "$output" == *"ERROR"* ]]; then
    mkdir -p .cursorGrowth/logs
    echo "[$timestamp] COMMAND_ERROR: $command" >> .cursorGrowth/logs/command-errors.log
    echo "Error output: $output" >> .cursorGrowth/logs/command-errors.log
fi

# 保持简洁的输出
exit 0