#!/bin/bash
# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/path-config.sh"  # 统一路径配置

# 🔒 Prompt安全检查Hook - 检查用户输入是否包含敏感信息
# 防止意外泄露API密钥、密码等敏感信息

# 读取JSON输入
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty')
attachments=$(echo "$input" | jq -r '.attachments // []')

# 如果没有prompt内容，退出
if [[ -z "$prompt" ]]; then
    exit 0
fi

# 创建日志目录（如果不存在）
mkdir -p "$ANALYTICS_MONITORING_DIR"

# 定义敏感信息模式
sensitive_patterns=(
    # API密钥模式
    "sk-[a-zA-Z0-9]{48}"
    "xoxb-[0-9]+-[0-9]+-[a-zA-Z0-9]+"
    "AKIA[0-9A-Z]{16}"
    "AIza[0-9A-Za-z_-]{35}"

    # 数据库连接字符串
    "(mysql|postgresql|mongodb)://[^@]+@"

    # 密码模式
    "password[:=][\"']?[^\"'\s]+"
    "passwd[:=][\"']?[^\"'\s]+"
    "secret[:=][\"']?[^\"'\s]+"

    # 私有密钥
    "-----BEGIN.*PRIVATE KEY-----"

    # JWT令牌
    "eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*"
)

# 检查prompt是否包含敏感信息
is_sensitive=false
detected_patterns=""

for pattern in "${sensitive_patterns[@]}"; do
    if [[ "$prompt" =~ $pattern ]]; then
        is_sensitive=true
        detected_patterns="$detected_patterns$pattern,"
    fi
done

# 记录安全检查
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
if [[ "$is_sensitive" == true ]]; then
    echo "[$timestamp] SENSITIVE_CONTENT_DETECTED: ${detected_patterns%,}" >> $SYSTEM_LOGS_DIR/prompt-security.log

    # 阻止包含敏感信息的prompt
    cat << EOF
{
  "continue": false,
  "user_message": "🚫 检测到可能包含敏感信息的prompt，已阻止提交\\n\\n为了您的安全，请避免在prompt中包含API密钥、密码或其他敏感信息。"
}
EOF
    exit 0
else
    echo "[$timestamp] PROMPT_CHECKED: clean" >> $SYSTEM_LOGS_DIR/prompt-security.log
fi

# 检查附件是否包含敏感文件
if [[ "$attachments" != "[]" ]]; then
    # 解析附件信息
    attachment_count=$(echo "$attachments" | jq length)

    for ((i=0; i<attachment_count; i++)); do
        file_path=$(echo "$attachments" | jq -r ".[$i].filePath // empty")
        file_type=$(echo "$attachments" | jq -r ".[$i].type // empty")

        # 检查是否是敏感文件
        if [[ "$file_path" =~ (\.env|config\.json|secrets\.|credentials\.) ]]; then
            echo "[$timestamp] SENSITIVE_FILE_ATTACHED: $file_path" >> $SYSTEM_LOGS_DIR/prompt-security.log

            cat << EOF
{
  "continue": true,
  "permission": "ask",
  "user_message": "⚠️ 检测到附件包含敏感文件\\n\\n文件: $file_path\\n\\n是否确认要包含此文件？",
  "agent_message": "用户附加了潜在的敏感文件，已请求确认。"
}
EOF
            exit 0
        fi
    done
fi

# 允许正常提交
cat << EOF
{
  "continue": true
}
EOF