#!/bin/bash
# Cursor AI Rules - 公共函数库（核心版）
# 提供基本的文件/目录/命令验证工具

validate_file_exists() {
    [ -f "$1" ]
}

validate_directory_exists() {
    [ -d "$1" ]
}

validate_command_available() {
    command -v "$1" >/dev/null 2>&1
}

get_project_root() {
    cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" && pwd
}
