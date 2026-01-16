#!/bin/bash

# 🛠️ Cursor AI Rules - 公共工具函数库
# 提供通用的工具函数，避免代码重复

# 加载日志库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

# 🔍 通用验证函数
validate_file_exists() {
    local file_path="$1"
    local file_description="${2:-文件}"

    if [ ! -f "$file_path" ]; then
        log_error "$file_description不存在: $file_path"
        return 1
    fi

    log_debug "$file_description存在: $file_path"
    return 0
}

validate_directory_exists() {
    local dir_path="$1"
    local dir_description="${2:-目录}"

    if [ ! -d "$dir_path" ]; then
        log_error "$dir_description不存在: $dir_path"
        return 1
    fi

    log_debug "$dir_description存在: $dir_path"
    return 0
}

validate_command_available() {
    local command="$1"
    local command_description="${2:-命令}"

    if ! command -v "$command" >/dev/null 2>&1; then
        log_error "$command_description不可用: $command"
        return 1
    fi

    log_debug "$command_description可用: $command"
    return 0
}

# 📊 通用统计函数
increment_counter() {
    local counter_name="$1"
    local increment="${2:-1}"

    # 使用间接变量引用
    local current_value="${!counter_name}"
    eval "$counter_name=$((current_value + increment))"
}

reset_counters() {
    CHECKS_TOTAL=0
    CHECKS_PASSED=0
    ISSUES_FOUND=0
    WARNINGS_FOUND=0
}

print_summary() {
    local component="${1:-unknown}"

    log_info "执行统计 - 总检查: $CHECKS_TOTAL, 通过: $CHECKS_PASSED, 问题: $ISSUES_FOUND, 警告: $WARNINGS_FOUND" "$component"
}

# 🔧 通用配置函数
load_config_file() {
    local config_file="$1"
    local default_config="${2:-{}}"

    if [ -f "$config_file" ]; then
        if command -v jq >/dev/null 2>&1; then
            cat "$config_file"
        else
            log_warn "jq不可用，无法解析JSON配置" "common"
            echo "$default_config"
        fi
    else
        log_debug "使用默认配置: $config_file" "common"
        echo "$default_config"
    fi
}

save_config_file() {
    local config_file="$1"
    local config_data="$2"

    local config_dir=$(dirname "$config_file")
    mkdir -p "$config_dir" 2>/dev/null || handle_error "无法创建配置目录: $config_dir" "common"

    echo "$config_data" > "$config_file" 2>/dev/null || handle_error "无法保存配置文件: $config_file" "common"

    log_debug "配置已保存: $config_file" "common"
}

# 🏗️ 通用项目信息获取函数
get_project_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}

get_git_info() {
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1 2>/dev/null; then
        local author_name=$(git config --get user.name 2>/dev/null || echo "本地用户")
        local author_email=$(git config --get user.email 2>/dev/null || echo "local@example.com")
        local commit_count=$(git log --oneline 2>/dev/null | wc -l || echo "0")

        cat << EOF
{
  "enabled": true,
  "author_name": "$author_name",
  "author_email": "$author_email",
  "commit_count": $commit_count
}
EOF
    else
        cat << EOF
{
  "enabled": false,
  "author_name": "本地用户",
  "author_email": "local@example.com",
  "commit_count": 0
}
EOF
    fi
}

get_system_info() {
    local os_type=$(uname -s 2>/dev/null || echo "Unknown")
    local os_version=$(uname -r 2>/dev/null || echo "Unknown")
    local os_arch=$(uname -m 2>/dev/null || echo "Unknown")
    local cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
    local total_memory=$(free -h 2>/dev/null | grep '^Mem:' | awk '{print $2}' 2>/dev/null || echo "Unknown")

    cat << EOF
{
  "os_type": "$os_type",
  "os_version": "$os_version",
  "os_arch": "$os_arch",
  "cpu_cores": "$cpu_cores",
  "total_memory": "$total_memory"
}
EOF
}

# 📋 通用JSON处理函数
json_get_value() {
    local json_data="$1"
    local key="$2"
    local default_value="${3:-}"

    if command -v jq >/dev/null 2>&1; then
        echo "$json_data" | jq -r "$key // \"$default_value\"" 2>/dev/null || echo "$default_value"
    else
        log_warn "jq不可用，无法解析JSON" "common"
        echo "$default_value"
    fi
}

json_set_value() {
    local json_data="$1"
    local key="$2"
    local value="$3"

    if command -v jq >/dev/null 2>&1; then
        echo "$json_data" | jq "$key = $value" 2>/dev/null || echo "$json_data"
    else
        log_warn "jq不可用，无法修改JSON" "common"
        echo "$json_data"
    fi
}

# 🎯 通用模式检测函数
detect_project_type() {
    local project_root="${1:-$(get_project_root)}"

    # 检测技术栈
    if [ -f "$project_root/package.json" ]; then
        echo "javascript"
    elif [ -f "$project_root/requirements.txt" ] || [ -f "$project_root/pyproject.toml" ]; then
        echo "python"
    elif [ -f "$project_root/Cargo.toml" ]; then
        echo "rust"
    elif [ -f "$project_root/go.mod" ]; then
        echo "go"
    elif [ -f "$project_root/pom.xml" ] || [ -f "$project_root/build.gradle" ]; then
        echo "java"
    else
        echo "unknown"
    fi
}

# 如果直接运行此脚本，显示帮助信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🛠️ Cursor AI Rules - 公共工具函数库"
    echo ""
    echo "此库提供通用的工具函数，避免代码重复"
    echo ""
    echo "使用方法:"
    echo "  source .cursor/core/common.sh"
    echo ""
    echo "可用函数分类:"
    echo "  🔍 验证函数: validate_file_exists, validate_directory_exists, validate_command_available"
    echo "  📊 统计函数: increment_counter, reset_counters, print_summary"
    echo "  🔧 配置函数: load_config_file, save_config_file"
    echo "  🏗️ 项目函数: get_project_root, get_git_info, get_system_info"
    echo "  📋 JSON函数: json_get_value, json_set_value"
    echo "  🎯 检测函数: detect_project_type"
    echo ""
    echo "示例:"
    echo '  source .cursor/core/common.sh'
    echo '  validate_command_available "git" "Git版本控制"'
    echo '  project_type=$(detect_project_type)'
fi