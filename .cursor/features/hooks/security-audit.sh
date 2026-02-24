#!/bin/bash
# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/path-config.sh"  # 统一路径配置

# 🚨 安全审计Hook - 阻止危险命令执行
# 基于Cursor AI Rules的安全协作原则

# 读取JSON输入
input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# 定义危险命令模式
dangerous_patterns=(
    "rm -rf /"
    "rm -rf /*"
    "rm -rf /home"
    "rm -rf /usr"
    "rm -rf /etc"
    "dd if="
    "mkfs"
    "format"
    "fdisk"
    ":(){ :|:& };"  # fork炸弹
    "shutdown"
    "reboot"
    "halt"
    "poweroff"
    "systemctl.*disable"
    "systemctl.*stop.*sshd"
    "systemctl.*stop.*network"
    "iptables -F"
    "ufw disable"
    "chmod -R 777 /"
    "chown -R root:root /"
)

# 定义敏感文件路径
sensitive_paths=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/fstab"
    "/etc/hosts"
    "/etc/resolv.conf"
    "/root"
    "/home"
    "/usr/bin"
    "/usr/sbin"
    "/var/log/auth.log"   # Linux (Debian/Ubuntu)
    "/var/log/secure"     # Linux (RHEL/CentOS)
)

# 检查是否包含危险命令
for pattern in "${dangerous_patterns[@]}"; do
    if [[ "$command" == *"$pattern"* ]]; then
        echo "🚫 检测到危险命令，已阻止: $pattern" >&2

    # 记录安全事件
    mkdir -p "$ANALYTICS_MONITORING_DIR"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] SECURITY_BLOCK: $command (pattern: $pattern)" >> "$SYSTEM_LOGS_DIR/security-events.log"

        cat << EOF
{
  "continue": false,
  "permission": "deny",
  "user_message": "🚫 检测到潜在危险命令，已自动阻止执行\\n\\n为确保安全，AI助手无法执行可能损害系统或数据的命令。",
  "agent_message": "该命令包含潜在危险操作，已被安全策略阻止。如确需执行此类操作，请手动在终端中运行，并确保您完全理解后果。"
}
EOF
        exit 0
    fi
done

# 检查是否涉及敏感路径
for path in "${sensitive_paths[@]}"; do
    if [[ "$command" == *"$path"* ]]; then
        echo "⚠️ 检测到敏感路径访问: $path" >&2

        # 对于敏感路径，请求用户确认
        cat << EOF
{
  "continue": true,
  "permission": "ask",
  "user_message": "⚠️ 该命令涉及敏感系统路径，是否允许执行？\\n\\n路径: $path",
  "agent_message": "命令涉及敏感系统路径，已请求用户确认。建议谨慎操作。"
}
EOF
        exit 0
    fi
done

# 检查是否是git操作，引导使用gh工具
if [[ "$command" =~ git[[:space:]] ]] || [[ "$command" == "git" ]]; then
    if [[ "$command" == *"git push"* ]] || [[ "$command" == *"git pull"* ]] || [[ "$command" == *"git clone"* ]]; then
        cat << EOF
{
  "continue": true,
  "permission": "ask",
  "user_message": "💡 建议使用GitHub CLI (gh) 替代git命令\\n\\nGitHub CLI提供更好的GitHub集成和安全性。",
  "agent_message": "检测到git命令，建议使用gh工具以获得更好的集成体验。"
}
EOF
        exit 0
    fi
fi

# 检查数据库相关命令
if [[ "$command" == *"DROP"* ]] || [[ "$command" == *"DELETE"* ]] || [[ "$command" == *"TRUNCATE"* ]]; then
    echo "⚠️ 检测到数据库删除操作" >&2
    cat << EOF
{
  "continue": true,
  "permission": "ask",
  "user_message": "⚠️ 检测到数据库删除操作，是否确认执行？\\n\\n请确保已备份重要数据。",
  "agent_message": "检测到潜在的数据库破坏性操作，已请求用户确认。"
}
EOF
    exit 0
fi

# 记录审计日志
mkdir -p "$SYSTEM_LOGS_DIR"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
mkdir -p "$SYSTEM_LOGS_DIR"
echo "[$timestamp] ALLOWED: $command (cwd: $cwd)" >> "$SYSTEM_LOGS_DIR/command-audit.log"

# 允许执行
cat << EOF
{
  "continue": true,
  "permission": "allow"
}
EOF