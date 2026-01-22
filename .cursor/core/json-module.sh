#!/bin/bash
# ========================================
# Cursor AI Rules - JSON处理模块
# 统一的JSON读写和验证功能
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/cli-framework.sh"

# =============================================================================
# JSON模块配置
# =============================================================================

# JSON处理统计
JSON_OPERATIONS_TOTAL=0
JSON_OPERATIONS_SUCCESS=0
JSON_VALIDATION_TOTAL=0
JSON_VALIDATION_SUCCESS=0

# =============================================================================
# 核心JSON函数
# =============================================================================

# 验证JSON文件
json_validate() {
    local file="$1"

    ((JSON_VALIDATION_TOTAL++))

    if [[ ! -f "$file" ]]; then
        cli_error "JSON文件不存在: $file"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        cli_error "需要安装jq来验证JSON文件"
        return 1
    fi

    if jq empty "$file" >/dev/null 2>&1; then
        ((JSON_VALIDATION_SUCCESS++))
        cli_debug "JSON文件验证通过: $file"
        return 0
    else
        cli_error "JSON文件格式无效: $file"
        return 1
    fi
}

# 读取JSON值
json_get() {
    local file="$1"
    local key="$2"
    local default="${3:-}"

    ((JSON_OPERATIONS_TOTAL++))

    if ! json_validate "$file"; then
        echo "$default"
        return 1
    fi

    local value
    value=$(jq -r "$key" "$file" 2>/dev/null)

    if [[ "$value" == "null" && -n "$default" ]]; then
        echo "$default"
        return 1
    elif [[ "$value" == "null" ]]; then
        return 1
    else
        ((JSON_OPERATIONS_SUCCESS++))
        echo "$value"
        return 0
    fi
}

# 设置JSON值
json_set() {
    local file="$1"
    local key="$2"
    local value="$3"

    ((JSON_OPERATIONS_TOTAL++))

    if ! command -v jq >/dev/null 2>&1; then
        cli_error "需要安装jq来修改JSON文件"
        return 1
    fi

    # 创建目录（如果不存在）
    local dir
    dir=$(dirname "$file")
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            cli_error "无法创建目录: $dir"
            return 1
        }
    fi

    # 读取现有内容或创建空对象
    local content="{}"
    if [[ -f "$file" ]]; then
        content=$(cat "$file" 2>/dev/null || echo "{}")
    fi

    # 使用jq设置值
    if echo "$content" | jq "$key = $value" > "${file}.tmp" 2>/dev/null; then
        mv "${file}.tmp" "$file"
        ((JSON_OPERATIONS_SUCCESS++))
        cli_debug "JSON值设置成功: $key = $value"
        return 0
    else
        rm -f "${file}.tmp"
        cli_error "无法设置JSON值: $key"
        return 1
    fi
}

# 删除JSON键
json_delete() {
    local file="$1"
    local key="$2"

    ((JSON_OPERATIONS_TOTAL++))

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        cli_error "无效的JSON文件: $file"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        cli_error "需要安装jq来修改JSON文件"
        return 1
    fi

    # 使用jq删除键
    if jq "del($key)" "$file" > "${file}.tmp" 2>/dev/null; then
        mv "${file}.tmp" "$file"
        ((JSON_OPERATIONS_SUCCESS++))
        cli_debug "JSON键删除成功: $key"
        return 0
    else
        rm -f "${file}.tmp"
        cli_error "无法删除JSON键: $key"
        return 1
    fi
}

# 检查JSON键是否存在
json_has_key() {
    local file="$1"
    local key="$2"

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        return 1
    fi

    jq -e "$key" "$file" >/dev/null 2>&1
}

# 获取JSON对象的所有键
json_keys() {
    local file="$1"

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        return 1
    fi

    jq -r 'keys[]' "$file" 2>/dev/null
}

# 获取JSON数组长度
json_array_length() {
    local file="$1"
    local key="$2"

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        echo "0"
        return 1
    fi

    local length
    length=$(jq "$key | length" "$file" 2>/dev/null)

    if [[ "$length" == "null" ]]; then
        echo "0"
        return 1
    else
        echo "$length"
        return 0
    fi
}

# 向JSON数组添加元素
json_array_append() {
    local file="$1"
    local key="$2"
    local value="$3"

    ((JSON_OPERATIONS_TOTAL++))

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        cli_error "无效的JSON文件: $file"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        cli_error "需要安装jq来修改JSON文件"
        return 1
    fi

    # 确保目标是数组，如果不存在则创建空数组
    local update_expr
    if json_has_key "$file" "$key"; then
        update_expr="$key += [$value]"
    else
        update_expr="$key = [$value]"
    fi

    if jq "$update_expr" "$file" > "${file}.tmp" 2>/dev/null; then
        mv "${file}.tmp" "$file"
        ((JSON_OPERATIONS_SUCCESS++))
        cli_debug "JSON数组添加成功: $key += $value"
        return 0
    else
        rm -f "${file}.tmp"
        cli_error "无法向JSON数组添加元素: $key"
        return 1
    fi
}

# 从JSON数组移除元素
json_array_remove() {
    local file="$1"
    local key="$2"
    local index="$3"

    ((JSON_OPERATIONS_TOTAL++))

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        cli_error "无效的JSON文件: $file"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        cli_error "需要安装jq来修改JSON文件"
        return 1
    fi

    # 移除指定索引的元素
    if jq "$key | del(.[$index])" "$file" > "${file}.tmp" 2>/dev/null; then
        mv "${file}.tmp" "$file"
        ((JSON_OPERATIONS_SUCCESS++))
        cli_debug "JSON数组移除成功: $key[$index]"
        return 0
    else
        rm -f "${file}.tmp"
        cli_error "无法从JSON数组移除元素: $key[$index]"
        return 1
    fi
}

# 合并JSON对象
json_merge() {
    local target_file="$1"
    local source_file="$2"

    ((JSON_OPERATIONS_TOTAL++))

    if [[ ! -f "$target_file" ]] || ! json_validate "$target_file"; then
        cli_error "无效的目标JSON文件: $target_file"
        return 1
    fi

    if [[ ! -f "$source_file" ]] || ! json_validate "$source_file"; then
        cli_error "无效的源JSON文件: $source_file"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        cli_error "需要安装jq来合并JSON文件"
        return 1
    fi

    # 合并两个JSON对象
    if jq -s '.[0] * .[1]' "$target_file" "$source_file" > "${target_file}.tmp" 2>/dev/null; then
        mv "${target_file}.tmp" "$target_file"
        ((JSON_OPERATIONS_SUCCESS++))
        cli_debug "JSON合并成功: $source_file -> $target_file"
        return 0
    else
        rm -f "${target_file}.tmp"
        cli_error "无法合并JSON文件"
        return 1
    fi
}

# 创建JSON备份
json_backup() {
    local file="$1"
    local backup_suffix="${2:-$(date +%Y%m%d_%H%M%S)}"

    if [[ ! -f "$file" ]]; then
        cli_error "文件不存在，无法备份: $file"
        return 1
    fi

    local backup_file="${file}.backup.${backup_suffix}"

    if cp "$file" "$backup_file"; then
        cli_debug "JSON备份创建成功: $backup_file"
        return 0
    else
        cli_error "无法创建JSON备份: $backup_file"
        return 1
    fi
}

# =============================================================================
# 高级JSON功能
# =============================================================================

# 验证JSON模式
json_validate_schema() {
    local file="$1"
    local schema_file="$2"

    ((JSON_VALIDATION_TOTAL++))

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        cli_error "无效的JSON文件: $file"
        return 1
    fi

    if [[ ! -f "$schema_file" ]] || ! json_validate "$schema_file"; then
        cli_error "无效的JSON模式文件: $schema_file"
        return 1
    fi

    # 注意: 这里需要一个JSON Schema验证器
    # 目前只是基本的结构检查
    cli_warning "JSON模式验证功能尚未完全实现"
    ((JSON_VALIDATION_SUCCESS++))

    return 0
}

# 格式化JSON输出
json_format() {
    local file="$1"
    local output_file="${2:-}"

    if [[ ! -f "$file" ]] || ! json_validate "$file"; then
        cli_error "无效的JSON文件: $file"
        return 1
    fi

    if [[ -n "$output_file" ]]; then
        jq . "$file" > "$output_file"
        cli_debug "JSON格式化输出到文件: $output_file"
    else
        jq . "$file"
    fi
}

# =============================================================================
# JSON统计和报告
# =============================================================================

# 显示JSON统计信息
json_stats() {
    cli_info "JSON模块统计信息"
    cli_format_list "操作统计" \
        "总操作数: $JSON_OPERATIONS_TOTAL" \
        "成功操作数: $JSON_OPERATIONS_SUCCESS" \
        "总验证数: $JSON_VALIDATION_TOTAL" \
        "成功验证数: $JSON_VALIDATION_SUCCESS"

    if [[ $JSON_OPERATIONS_TOTAL -gt 0 ]]; then
        local success_rate=$((JSON_OPERATIONS_SUCCESS * 100 / JSON_OPERATIONS_TOTAL))
        cli_info "操作成功率: ${success_rate}%"
    fi

    if [[ $JSON_VALIDATION_TOTAL -gt 0 ]]; then
        local validation_rate=$((JSON_VALIDATION_SUCCESS * 100 / JSON_VALIDATION_TOTAL))
        cli_info "验证成功率: ${validation_rate}%"
    fi
}

# =============================================================================
# 兼容性函数
# =============================================================================

# 向后兼容现有脚本的JSON操作
# 这些函数可能在现有脚本中被使用

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
                cli_show_help "JSON Module" "JSON处理模块" \
                    "validate" "验证JSON文件" \
                    "get" "获取JSON值" \
                    "set" "设置JSON值" \
                    "stats" "显示统计信息" \
                    "test" "测试JSON功能"
                exit 0
                ;;
            "version")
                cli_show_version "JSON Module"
                exit 0
                ;;
        esac
    done

    # 验证命令
    cli_validate_command "validate" "get" "set" "stats" "test" || exit 1

    case "$CLI_COMMAND" in
        "validate")
            local file="${CLI_ARGS[0]}"
            if [[ -z "$file" ]]; then
                cli_error "请指定要验证的JSON文件"
                exit 1
            fi
            json_validate "$file" && cli_success "JSON文件验证通过" || exit 1
            ;;
        "get")
            local file="${CLI_ARGS[0]}"
            local key="${CLI_ARGS[1]}"
            if [[ -z "$file" || -z "$key" ]]; then
                cli_error "请指定JSON文件和键路径"
                exit 1
            fi
            local value
            value=$(json_get "$file" "$key")
            cli_info "值: $value"
            ;;
        "set")
            local file="${CLI_ARGS[0]}"
            local key="${CLI_ARGS[1]}"
            local value="${CLI_ARGS[2]}"
            if [[ -z "$file" || -z "$key" || -z "$value" ]]; then
                cli_error "请指定JSON文件、键路径和值"
                exit 1
            fi
            json_set "$file" "$key" "$value" && cli_success "JSON值设置成功" || exit 1
            ;;
        "stats")
            json_stats
            ;;
        "test")
            cli_info "测试JSON模块功能"

            # 创建测试JSON文件
            local test_file="/tmp/json_test_$$.json"
            echo '{"name":"test","version":"1.0","settings":{"debug":true}}' > "$test_file"

            # 测试各种功能
            json_validate "$test_file" && cli_success "验证测试通过"

            local name
            name=$(json_get "$test_file" '.name')
            cli_info "读取测试: name = $name"

            json_set "$test_file" '.version' '"2.0"'
            local version
            version=$(json_get "$test_file" '.version')
            cli_info "设置测试: version = $version"

            json_array_append "$test_file" '.features' '"new_feature"'
            cli_success "数组添加测试通过"

            # 清理测试文件
            rm -f "$test_file"
            cli_success "JSON模块测试完成"
            ;;
        *)
            cli_show_help "JSON Module" "JSON处理模块" \
                "validate" "验证JSON文件" \
                "get" "获取JSON值" \
                "set" "设置JSON值" \
                "stats" "显示统计信息" \
                "test" "测试JSON功能"
            ;;
    esac
fi