#!/bin/bash

# 🌟 Cursor AI Rules - 通用依赖检查器
# 为所有脚本提供统一的依赖验证功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 依赖检查结果
declare -a MISSING_DEPS=()
declare -a MISSING_COMMANDS=()

# 检查文件依赖
check_file_dependency() {
    local file_path="$1"
    local description="$2"

    if [ ! -f "$file_path" ]; then
        MISSING_DEPS+=("$description ($file_path)")
        return 1
    fi
    return 0
}

# 检查命令依赖
check_command_dependency() {
    local command="$1"
    local description="$2"

    if ! command -v "$command" >/dev/null 2>&1; then
        MISSING_COMMANDS+=("$description ($command)")
        return 1
    fi
    return 0
}

# 检查目录存在
check_directory_dependency() {
    local dir_path="$1"
    local description="$2"

    if [ ! -d "$dir_path" ]; then
        MISSING_DEPS+=("$description ($dir_path)")
        return 1
    fi
    return 0
}

# 显示检查结果并退出（如果有错误）
show_check_results() {
    local script_name="$1"

    if [ ${#MISSING_DEPS[@]} -eq 0 ] && [ ${#MISSING_COMMANDS[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ $script_name 依赖检查通过${NC}"
        return 0
    fi

    echo -e "${RED}❌ $script_name 依赖检查失败${NC}"

    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo -e "${YELLOW}缺少文件依赖:${NC}"
        for dep in "${MISSING_DEPS[@]}"; do
            echo "  - $dep"
        done
    fi

    if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
        echo -e "${YELLOW}缺少命令依赖:${NC}"
        for cmd in "${MISSING_COMMANDS[@]}"; do
            echo "  - $cmd"
        done
    fi

    echo -e "${BLUE}请安装缺失的依赖后重试${NC}"
    exit 1
}

# 快速检查函数（用于脚本开头）
quick_dependency_check() {
    local script_name="$1"
    shift  # 移除第一个参数（脚本名）

    # 解析参数：file:路径:描述 或 cmd:命令:描述 或 dir:路径:描述
    while [ $# -gt 0 ]; do
        case "$1" in
            file:*) check_file_dependency "${1#file:}" "${2:-}" ;;
            cmd:*)  check_command_dependency "${1#cmd:}" "${2:-}" ;;
            dir:*)  check_directory_dependency "${1#dir:}" "${2:-}" ;;
        esac
        shift 2
    done

    show_check_results "$script_name"
}