#!/bin/bash
# ========================================
# Cursor AI Rules - 文件操作模块
# 统一的文件和目录操作功能
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/cli-framework.sh"

# =============================================================================
# 文件模块配置
# =============================================================================

# 文件操作统计
FILE_OPERATIONS_TOTAL=0
FILE_OPERATIONS_SUCCESS=0
DIRECTORY_OPERATIONS_TOTAL=0
DIRECTORY_OPERATIONS_SUCCESS=0

# 文件权限配置
DEFAULT_FILE_PERMS=644
DEFAULT_DIR_PERMS=755

# =============================================================================
# 核心文件操作函数
# =============================================================================

# 安全地创建文件
file_create() {
    local file="$1"
    local content="${2:-}"
    local perms="${3:-$DEFAULT_FILE_PERMS}"

    ((FILE_OPERATIONS_TOTAL++))

    # 检查目标路径
    if [[ -z "$file" ]]; then
        cli_error "文件路径不能为空"
        return 1
    fi

    # 创建目录（如果不存在）
    local dir
    dir=$(dirname "$file")
    if [[ ! -d "$dir" ]]; then
        dir_create "$dir" || return 1
    fi

    # 检查文件是否已存在
    if [[ -f "$file" ]]; then
        if [[ "$CLI_DRY_RUN" == true ]]; then
            cli_info "[DRY RUN] 文件已存在，跳过创建: $file"
            return 0
        fi
        cli_confirm "文件已存在，是否覆盖? $file" || return 1
    fi

    # 创建文件
    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将创建文件: $file"
        return 0
    fi

    if echo "$content" > "$file" 2>/dev/null; then
        # 设置权限
        chmod "$perms" "$file" 2>/dev/null || cli_warning "无法设置文件权限: $file"

        ((FILE_OPERATIONS_SUCCESS++))
        cli_debug "文件创建成功: $file"
        return 0
    else
        cli_error "无法创建文件: $file"
        return 1
    fi
}

# 安全地删除文件
file_delete() {
    local file="$1"
    local force="${2:-false}"

    ((FILE_OPERATIONS_TOTAL++))

    # 检查文件是否存在
    if [[ ! -f "$file" && ! -L "$file" ]]; then
        cli_warning "文件不存在: $file"
        return 0  # 不存在的文件不算错误
    fi

    # 确认删除（除非强制）
    if [[ "$force" != true && "$CLI_DRY_RUN" != true ]]; then
        cli_confirm "确认删除文件? $file" || return 1
    fi

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将删除文件: $file"
        return 0
    fi

    if rm -f "$file" 2>/dev/null; then
        ((FILE_OPERATIONS_SUCCESS++))
        cli_debug "文件删除成功: $file"
        return 0
    else
        cli_error "无法删除文件: $file"
        return 1
    fi
}

# 复制文件
file_copy() {
    local src="$1"
    local dst="$2"
    local preserve="${3:-false}"

    ((FILE_OPERATIONS_TOTAL++))

    # 检查源文件
    if [[ ! -f "$src" && ! -L "$src" ]]; then
        cli_error "源文件不存在: $src"
        return 1
    fi

    # 检查目标文件
    if [[ -f "$dst" && "$CLI_DRY_RUN" != true ]]; then
        cli_confirm "目标文件已存在，是否覆盖? $dst" || return 1
    fi

    # 创建目标目录
    local dst_dir
    dst_dir=$(dirname "$dst")
    if [[ ! -d "$dst_dir" ]]; then
        dir_create "$dst_dir" || return 1
    fi

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将复制文件: $src -> $dst"
        return 0
    fi

    local cp_opts="-f"
    if [[ "$preserve" == true ]]; then
        cp_opts="$cp_opts -p"
    fi

    if cp $cp_opts "$src" "$dst" 2>/dev/null; then
        ((FILE_OPERATIONS_SUCCESS++))
        cli_debug "文件复制成功: $src -> $dst"
        return 0
    else
        cli_error "无法复制文件: $src -> $dst"
        return 1
    fi
}

# 移动文件
file_move() {
    local src="$1"
    local dst="$2"

    ((FILE_OPERATIONS_TOTAL++))

    # 检查源文件
    if [[ ! -f "$src" && ! -L "$src" ]]; then
        cli_error "源文件不存在: $src"
        return 1
    fi

    # 创建目标目录
    local dst_dir
    dst_dir=$(dirname "$dst")
    if [[ ! -d "$dst_dir" ]]; then
        dir_create "$dst_dir" || return 1
    fi

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将移动文件: $src -> $dst"
        return 0
    fi

    if mv "$src" "$dst" 2>/dev/null; then
        ((FILE_OPERATIONS_SUCCESS++))
        cli_debug "文件移动成功: $src -> $dst"
        return 0
    else
        cli_error "无法移动文件: $src -> $dst"
        return 1
    fi
}

# 获取文件信息
file_info() {
    local file="$1"

    if [[ ! -f "$file" && ! -L "$file" ]]; then
        cli_error "文件不存在: $file"
        return 1
    fi

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        # JSON格式输出
        local size perms owner group mtime
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        perms=$(stat -f%p "$file" 2>/dev/null || stat -c%a "$file" 2>/dev/null || echo "0")
        owner=$(stat -f%Su "$file" 2>/dev/null || stat -c%U "$file" 2>/dev/null || echo "unknown")
        group=$(stat -f%Sg "$file" 2>/dev/null || stat -c%G "$file" 2>/dev/null || echo "unknown")
        mtime=$(stat -f%Sm "$file" 2>/dev/null || stat -c%y "$file" 2>/dev/null || echo "unknown")

        cat << EOF
{
  "path": "$file",
  "type": "file",
  "size": $size,
  "permissions": "$perms",
  "owner": "$owner",
  "group": "$group",
  "modified": "$mtime"
}
EOF
    else
        # 文本格式输出
        ls -la "$file" 2>/dev/null || cli_error "无法获取文件信息"
    fi
}

# =============================================================================
# 目录操作函数
# =============================================================================

# 创建目录
dir_create() {
    local dir="$1"
    local perms="${2:-$DEFAULT_DIR_PERMS}"

    ((DIRECTORY_OPERATIONS_TOTAL++))

    if [[ -z "$dir" ]]; then
        cli_error "目录路径不能为空"
        return 1
    fi

    if [[ -d "$dir" ]]; then
        cli_debug "目录已存在: $dir"
        return 0
    fi

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将创建目录: $dir"
        return 0
    fi

    if mkdir -p "$dir" 2>/dev/null; then
        # 设置权限
        chmod "$perms" "$dir" 2>/dev/null || cli_warning "无法设置目录权限: $dir"

        ((DIRECTORY_OPERATIONS_SUCCESS++))
        cli_debug "目录创建成功: $dir"
        return 0
    else
        cli_error "无法创建目录: $dir"
        return 1
    fi
}

# 删除目录
dir_delete() {
    local dir="$1"
    local force="${2:-false}"

    ((DIRECTORY_OPERATIONS_TOTAL++))

    if [[ ! -d "$dir" ]]; then
        cli_warning "目录不存在: $dir"
        return 0
    fi

    # 检查目录是否为空
    if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
        : # 空目录，可以安全删除
    elif [[ "$force" != true ]]; then
        cli_error "目录不为空，请使用force=true或手动清空: $dir"
        return 1
    fi

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将删除目录: $dir"
        return 0
    fi

    # 确认删除非空目录
    if [[ "$force" == true && -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
        cli_confirm "确认删除非空目录? $dir" || return 1
    fi

    if rm -rf "$dir" 2>/dev/null; then
        ((DIRECTORY_OPERATIONS_SUCCESS++))
        cli_debug "目录删除成功: $dir"
        return 0
    else
        cli_error "无法删除目录: $dir"
        return 1
    fi
}

# 复制目录
dir_copy() {
    local src="$1"
    local dst="$2"

    ((DIRECTORY_OPERATIONS_TOTAL++))

    if [[ ! -d "$src" ]]; then
        cli_error "源目录不存在: $src"
        return 1
    fi

    if [[ -e "$dst" ]]; then
        cli_confirm "目标已存在，是否覆盖? $dst" || return 1
    fi

    if [[ "$CLI_DRY_RUN" == true ]]; then
        cli_info "[DRY RUN] 将复制目录: $src -> $dst"
        return 0
    fi

    if cp -r "$src" "$dst" 2>/dev/null; then
        ((DIRECTORY_OPERATIONS_SUCCESS++))
        cli_debug "目录复制成功: $src -> $dst"
        return 0
    else
        cli_error "无法复制目录: $src -> $dst"
        return 1
    fi
}

# 获取目录信息
dir_info() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        cli_error "目录不存在: $dir"
        return 1
    fi

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        # JSON格式输出
        local file_count dir_count total_size
        file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
        dir_count=$(find "$dir" -type d 2>/dev/null | wc -l)
        total_size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")

        cat << EOF
{
  "path": "$dir",
  "type": "directory",
  "file_count": $file_count,
  "directory_count": $dir_count,
  "total_size": $total_size
}
EOF
    else
        # 文本格式输出
        cli_info "目录信息: $dir"
        ls -la "$dir" 2>/dev/null || cli_error "无法获取目录信息"
    fi
}

# =============================================================================
# 高级文件操作
# =============================================================================

# 查找文件
file_find() {
    local dir="$1"
    local pattern="$2"
    local type="${3:-f}"  # f=file, d=directory

    if [[ ! -d "$dir" ]]; then
        cli_error "搜索目录不存在: $dir"
        return 1
    fi

    cli_debug "搜索文件: $dir (模式: $pattern, 类型: $type)"

    local find_cmd="find \"$dir\" -name \"$pattern\""
    if [[ "$type" == "d" ]]; then
        find_cmd="$find_cmd -type d"
    elif [[ "$type" == "f" ]]; then
        find_cmd="$find_cmd -type f"
    fi

    if [[ "$CLI_JSON_OUTPUT" == true ]]; then
        # JSON格式输出
        echo "{"
        echo "  \"search_directory\": \"$dir\","
        echo "  \"pattern\": \"$pattern\","
        echo "  \"type\": \"$type\","
        echo "  \"results\": ["

        local first=true
        eval "$find_cmd" | while read -r file; do
            if [[ "$first" == true ]]; then
                first=false
            else
                echo ","
            fi
            echo "    \"$file\""
        done

        echo "  ]"
        echo "}"
    else
        # 文本格式输出
        eval "$find_cmd"
    fi
}

# 备份文件
file_backup() {
    local file="$1"
    local backup_dir="${2:-./backup}"
    local suffix="${3:-$(date +%Y%m%d_%H%M%S)}"

    if [[ ! -f "$file" && ! -L "$file" ]]; then
        cli_error "要备份的文件不存在: $file"
        return 1
    fi

    # 创建备份目录
    dir_create "$backup_dir" || return 1

    local filename
    filename=$(basename "$file")
    local backup_file="$backup_dir/${filename}.backup.${suffix}"

    file_copy "$file" "$backup_file" || return 1

    cli_success "文件备份成功: $backup_file"
    return 0
}

# 计算文件哈希
file_hash() {
    local file="$1"
    local algorithm="${2:-sha256}"

    if [[ ! -f "$file" ]]; then
        cli_error "文件不存在: $file"
        return 1
    fi

    case "$algorithm" in
        "md5")
            if command -v md5sum >/dev/null 2>&1; then
                md5sum "$file" | cut -d' ' -f1
            else
                cli_error "系统不支持MD5哈希"
                return 1
            fi
            ;;
        "sha1")
            if command -v sha1sum >/dev/null 2>&1; then
                sha1sum "$file" | cut -d' ' -f1
            elif command -v shasum >/dev/null 2>&1; then
                shasum -a 1 "$file" | cut -d' ' -f1
            else
                cli_error "系统不支持SHA1哈希"
                return 1
            fi
            ;;
        "sha256")
            if command -v sha256sum >/dev/null 2>&1; then
                sha256sum "$file" | cut -d' ' -f1
            elif command -v shasum >/dev/null 2>&1; then
                shasum -a 256 "$file" | cut -d' ' -f1
            else
                cli_error "系统不支持SHA256哈希"
                return 1
            fi
            ;;
        *)
            cli_error "不支持的哈希算法: $algorithm"
            return 1
            ;;
    esac
}

# =============================================================================
# 文件操作统计
# =============================================================================

# 显示文件操作统计
file_stats() {
    cli_info "文件操作模块统计信息"
    cli_format_list "文件操作统计" \
        "总文件操作数: $FILE_OPERATIONS_TOTAL" \
        "成功文件操作数: $FILE_OPERATIONS_SUCCESS" \
        "总目录操作数: $DIRECTORY_OPERATIONS_TOTAL" \
        "成功目录操作数: $DIRECTORY_OPERATIONS_SUCCESS"

    if [[ $FILE_OPERATIONS_TOTAL -gt 0 ]]; then
        local file_success_rate=$((FILE_OPERATIONS_SUCCESS * 100 / FILE_OPERATIONS_TOTAL))
        cli_info "文件操作成功率: ${file_success_rate}%"
    fi

    if [[ $DIRECTORY_OPERATIONS_TOTAL -gt 0 ]]; then
        local dir_success_rate=$((DIRECTORY_OPERATIONS_SUCCESS * 100 / DIRECTORY_OPERATIONS_TOTAL))
        cli_info "目录操作成功率: ${dir_success_rate}%"
    fi
}

# =============================================================================
# 如果直接运行此脚本，显示测试功能
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 解析CLI参数
    parse_cli_args "$@" || exit 1

    # 处理全局标志
    for flag in "${CLI_FLAGS[@]}"; do
        case "$flag" in
            "help")
                cli_show_help "File Module" "文件操作模块" \
                    "create" "创建文件" \
                    "delete" "删除文件" \
                    "copy" "复制文件" \
                    "move" "移动文件" \
                    "info" "获取文件信息" \
                    "find" "查找文件" \
                    "backup" "备份文件" \
                    "stats" "显示统计信息" \
                    "test" "测试文件操作功能"
                exit 0
                ;;
            "version")
                cli_show_version "File Module"
                exit 0
                ;;
        esac
    done

    # 验证命令
    cli_validate_command "create" "delete" "copy" "move" "info" "find" "backup" "stats" "test" || exit 1

    case "$CLI_COMMAND" in
        "create")
            local file="${CLI_ARGS[0]}"
            local content="${CLI_ARGS[1]:-test content}"
            if [[ -z "$file" ]]; then
                cli_error "请指定要创建的文件路径"
                exit 1
            fi
            file_create "$file" "$content" && cli_success "文件创建成功" || exit 1
            ;;
        "delete")
            local file="${CLI_ARGS[0]}"
            if [[ -z "$file" ]]; then
                cli_error "请指定要删除的文件路径"
                exit 1
            fi
            file_delete "$file" && cli_success "文件删除成功" || exit 1
            ;;
        "copy")
            local src="${CLI_ARGS[0]}"
            local dst="${CLI_ARGS[1]}"
            if [[ -z "$src" || -z "$dst" ]]; then
                cli_error "请指定源文件和目标文件路径"
                exit 1
            fi
            file_copy "$src" "$dst" && cli_success "文件复制成功" || exit 1
            ;;
        "move")
            local src="${CLI_ARGS[0]}"
            local dst="${CLI_ARGS[1]}"
            if [[ -z "$src" || -z "$dst" ]]; then
                cli_error "请指定源文件和目标文件路径"
                exit 1
            fi
            file_move "$src" "$dst" && cli_success "文件移动成功" || exit 1
            ;;
        "info")
            local file="${CLI_ARGS[0]}"
            if [[ -z "$file" ]]; then
                cli_error "请指定要查看的文件路径"
                exit 1
            fi
            file_info "$file" || exit 1
            ;;
        "find")
            local dir="${CLI_ARGS[0]:-.}"
            local pattern="${CLI_ARGS[1]:-*}"
            file_find "$dir" "$pattern" || exit 1
            ;;
        "backup")
            local file="${CLI_ARGS[0]}"
            if [[ -z "$file" ]]; then
                cli_error "请指定要备份的文件路径"
                exit 1
            fi
            file_backup "$file" || exit 1
            ;;
        "stats")
            file_stats
            ;;
        "test")
            cli_info "测试文件操作模块功能"

            # 创建测试文件
            local test_file="/tmp/file_test_$$.txt"
            file_create "$test_file" "test content" && cli_success "创建测试通过"

            # 测试文件信息
            file_info "$test_file"

            # 测试复制
            local copy_file="/tmp/file_copy_$$.txt"
            file_copy "$test_file" "$copy_file" && cli_success "复制测试通过"

            # 测试移动
            local move_file="/tmp/file_move_$$.txt"
            file_move "$copy_file" "$move_file" && cli_success "移动测试通过"

            # 清理测试文件
            file_delete "$test_file"
            file_delete "$move_file"
            cli_success "文件模块测试完成"
            ;;
        *)
            cli_show_help "File Module" "文件操作模块" \
                "create" "创建文件" \
                "delete" "删除文件" \
                "copy" "复制文件" \
                "move" "移动文件" \
                "info" "获取文件信息" \
                "find" "查找文件" \
                "backup" "备份文件" \
                "stats" "显示统计信息" \
                "test" "测试文件操作功能"
            ;;
    esac
fi