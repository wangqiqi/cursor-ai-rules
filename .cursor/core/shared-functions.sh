#!/bin/bash
# ========================================
# Cursor AI Rules - 共享函数库
# 所有共同函数的抽象，降低维护成本
# ========================================

# ------------------------------------------------------------------------------
# 项目识别相关函数 (所有脚本都需要)
# ------------------------------------------------------------------------------

# 生成项目唯一标识符
generate_project_identifier() {
    # 基于项目根目录路径生成唯一标识
    # 用于识别脚本属于哪个项目，避免环境变量污染
    local project_path
    project_path=$(get_project_root_path)

    # 检查get_project_root_path是否成功
    if [[ $? -ne 0 || -z "$project_path" ]]; then
        echo "ERROR: generate_project_identifier: 无法确定项目根目录" >&2
        return 1
    fi

    # 使用项目路径的哈希值作为唯一标识
    local project_hash
    project_hash=$(echo "$project_path" | md5sum | cut -d' ' -f1 | cut -c1-16)

    # 检查md5sum是否成功
    if [[ -z "$project_hash" ]]; then
        echo "ERROR: generate_project_identifier: 无法生成项目哈希" >&2
        return 1
    fi

    # 转换为bash变量安全的格式 (只包含字母数字下划线)
    PROJECT_IDENTIFIER="proj_${project_hash}"
    export PROJECT_IDENTIFIER

    # 统一管理：写入项目配置到 .cursor-project.json
    local project_config_file="$project_path/.cursor-project.json"
    local current_time
    current_time=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)

    # 读取现有配置或创建默认配置
    local project_config="{}"
    if [[ -f "$project_config_file" ]]; then
        project_config=$(cat "$project_config_file" 2>/dev/null || echo "{}")
    fi

    # 使用jq更新项目ID，如果没有jq则手动更新JSON
    if command -v jq >/dev/null 2>&1; then
        # 使用jq更新配置
        project_config=$(echo "$project_config" | jq --arg id "$PROJECT_IDENTIFIER" --arg time "$current_time" '.projectId = $id | .lastUpdated = $time | .projectPath = "'$project_path'"')
    else
        # 手动更新JSON (简化实现)
        local temp_config="$project_config"
        # 移除可能存在的旧projectId
        temp_config=$(echo "$temp_config" | sed 's/"projectId":[^,]*,\?//g' | sed 's/,$//' | sed 's/{\s*,/{/' | sed 's/,\s*}/}/')
        # 添加新的projectId
        if [[ "$temp_config" == "{}" ]]; then
            project_config="{\"projectId\":\"$PROJECT_IDENTIFIER\",\"lastUpdated\":\"$current_time\",\"projectPath\":\"$project_path\"}"
        else
            # 确保JSON格式正确
            temp_config=$(echo "$temp_config" | sed 's/}$/,\"projectId\":\"'$PROJECT_IDENTIFIER'\",\"lastUpdated\":\"'$current_time'\",\"projectPath\":\"'$project_path'\"}/')
            project_config="$temp_config"
        fi
    fi

    # 写入更新后的配置
    echo "$project_config" > "$project_config_file"
}

# 获取项目根目录路径
get_project_root_path() {
    # 首先尝试从当前工作目录查找
    local current_path="$PWD"
    local max_depth=10
    local depth=0

    while [[ $depth -lt $max_depth ]]; do
        if [[ -d "$current_path/.cursor" ]]; then
            echo "$current_path"
            return 0
        fi
        current_path=$(dirname "$current_path")
        ((depth++))
    done

    # 如果从工作目录没找到，尝试从脚本目录查找
    if [[ -n "$SCRIPT_DIR" ]]; then
        current_path="$SCRIPT_DIR"
        depth=0
        while [[ $depth -lt $max_depth ]]; do
            if [[ -d "$current_path/.cursor" ]]; then
                echo "$current_path"
                return 0
            fi
            current_path=$(dirname "$current_path")
            ((depth++))
        done
    fi

    echo "ERROR: 无法找到项目根目录 (.cursor 目录)" >&2
    return 1
}

# 验证项目上下文 (强制函数)
# 确保脚本在正确的项目上下文中运行，避免环境变量污染
validate_project_context() {
    local stored_project_id

    # 确保PROJECT_ROOT已设置
    if [[ -z "$PROJECT_ROOT" ]]; then
        PROJECT_ROOT=$(get_project_root_path)
        if [[ $? -ne 0 || -z "$PROJECT_ROOT" ]]; then
            echo "❌ 项目上下文验证失败: 无法确定项目根目录" >&2
            return 1
        fi
        export PROJECT_ROOT
    fi

    # 生成当前项目标识
    if ! generate_project_identifier; then
        echo "❌ 项目上下文验证失败: 无法生成项目标识" >&2
        return 1
    fi

    local current_project_id="$PROJECT_IDENTIFIER"

    # 从统一的项目配置文件中读取项目ID
    local project_config_file="$PROJECT_ROOT/.cursor-project.json"
    if [[ -f "$project_config_file" ]]; then
        # 从.cursor-project.json中读取项目ID
        if command -v jq >/dev/null 2>&1; then
            stored_project_id=$(jq -r '.projectId // empty' "$project_config_file" 2>/dev/null)
        else
            # 如果没有jq，手动解析JSON中的projectId
            stored_project_id=$(grep -o '"projectId"\s*:\s*"[^"]*"' "$project_config_file" 2>/dev/null | sed 's/.*"projectId"\s*:\s*"\([^"]*\)".*/\1/' 2>/dev/null)
        fi
    fi

    # 如果配置文件中没有项目ID，使用当前生成的ID
    if [[ -z "$stored_project_id" ]]; then
        stored_project_id="$current_project_id"
    fi

    # 验证项目上下文 - 确保脚本在正确的项目中运行
    if [[ "$current_project_id" != "$stored_project_id" ]]; then
        echo "❌ 项目上下文验证失败!" >&2
        echo "  当前项目ID: $current_project_id" >&2
        echo "  存储项目ID: $stored_project_id" >&2
        echo "  可能原因: 脚本在错误的目录中运行，或项目标识被篡改" >&2
        return 1
    fi

    echo "✅ 项目上下文验证通过: $PROJECT_IDENTIFIER"
    return 0
}

# ------------------------------------------------------------------------------
# 路径操作相关函数 (所有脚本都需要)
# 提供安全的文件和目录操作接口
# ------------------------------------------------------------------------------

# 安全文件操作 (统一接口)
safe_file_operation() {
    local operation="$1"
    local target_path="$2"

    case "$operation" in
        "read")
            [[ -f "$target_path" ]] && cat "$target_path" ;;
        "write")
            local content="$3"
            echo "$content" > "$target_path" ;;
        "append")
            local content="$3"
            echo "$content" >> "$target_path" ;;
        "mkdir")
            mkdir -p "$target_path" ;;
        "rm")
            rm -f "$target_path" ;;
        "exists")
            [[ -e "$target_path" ]] ;;
        *)
            echo "❌ 不支持的操作: $operation" >&2
            return 1 ;;
    esac
}

# ------------------------------------------------------------------------------
# 日志记录相关函数 (日志脚本需要)
# 统一的日志格式和记录方式
# ------------------------------------------------------------------------------

# 统一日志记录函数
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${3:-$SYSTEM_LOGS_DIR/app.log}"

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local log_entry="[$timestamp] [$level] $message"

    # 控制台输出
    case "$level" in
        "ERROR") echo "❌ $message" >&2 ;;
        "WARN")  echo "⚠️  $message" >&2 ;;
        "INFO")  echo "ℹ️  $message" ;;
        "DEBUG") echo "🔍 $message" ;;
        *)       echo "$message" ;;
    esac

    # 文件记录
    safe_file_operation "append" "$log_file" "$log_entry"
}

# ------------------------------------------------------------------------------
# 配置管理相关函数 (配置脚本需要)
# 标准化的配置读取和写入
# ------------------------------------------------------------------------------

# 安全读取配置文件
safe_read_config() {
    local config_file="$1"
    local key="$2"
    local default_value="$3"

    if [[ ! -f "$config_file" ]]; then
        echo "$default_value"
        return 1
    fi

    local value
    value=$(grep "^${key}=" "$config_file" | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//')
    echo "${value:-$default_value}"
}

# 安全写入配置文件
safe_write_config() {
    local config_file="$1"
    local key="$2"
    local value="$3"

    # 创建配置目录
    local config_dir
    config_dir=$(dirname "$config_file")
    safe_file_operation "mkdir" "$config_dir"

    # 读取现有配置
    local temp_config=""
    if [[ -f "$config_file" ]]; then
        temp_config=$(cat "$config_file")
    fi

    # 更新或添加配置项
    if echo "$temp_config" | grep -q "^${key}="; then
        # 更新现有项
        temp_config=$(echo "$temp_config" | sed "s|^${key}=.*|${key}=\"${value}\"|")
    else
        # 添加新项
        temp_config="${temp_config}
${key}=\"${value}\""
    fi

    # 写入配置
    safe_file_operation "write" "$config_file" "$temp_config"
}

# ------------------------------------------------------------------------------
# 目录管理相关函数 (目录脚本需要)
# 自动创建项目目录结构
# ------------------------------------------------------------------------------

# 统一目录创建函数 (按照path-config.sh的完整目录结构)
ensure_directory_structure() {
    # 按照path-config.sh中定义的完整目录结构创建
    local all_dirs=(
        # 7个核心顶级目录
        "$PERCEPTION_DIR"          # 环境感知数据
        "$USER_DATA_DIR"           # 用户相关数据
        "$PROJECT_DATA_DIR"        # 项目相关数据
        "$AI_DIR"                  # AI相关数据
        "$ANALYTICS_DIR"           # 分析数据
        "$MONITORING_DIR"          # 系统监控
        "$INTEGRATIONS_DIR"        # 第三方集成

        # AI相关子目录
        "$AI_MODELS_DIR"           # AI_DIR/models
        "$AI_TRAINING_DATA_DIR"    # AI_DIR/training_data
        "$AI_METRICS_DIR"          # AI_DIR/metrics
        "$AI_RESULTS_DIR"          # AI_DIR/results
        "$AI_DIR/skills"           # 已加载的AI技能 (兼容旧代码)
        "$AI_DIR/cache"            # AI缓存数据 (兼容旧代码)

        # Analytics相关子目录
        "$ANALYTICS_DATA_DIR"      # ANALYTICS_DIR/data
        "$ANALYTICS_CACHE_DIR"     # ANALYTICS_DIR/cache

        # Monitoring相关子目录
        "$SYSTEM_LOGS_DIR"         # MONITORING_DIR/logs (系统日志)
        "$MONITORING_DIR/pids"     # 进程ID文件 (兼容旧代码)
    )

    # 创建所有定义的目录
    for dir in "${all_dirs[@]}"; do
        safe_file_operation "mkdir" "$dir"
    done

    log_message "INFO" "项目目录结构创建完成 (完整path-config.sh目录结构)"
}

# ------------------------------------------------------------------------------
# 错误处理相关函数 (所有脚本都需要)
# 统一的错误处理和清理机制
# ------------------------------------------------------------------------------

# 统一错误处理函数
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local script_name="${3:-$(basename "$0")}"

    log_message "ERROR" "$script_name: $error_message"

    # 可以在这里添加错误恢复逻辑
    # 比如发送通知、清理临时文件等

    exit "$error_code"
}

# 统一清理函数
cleanup_on_exit() {
    local exit_code="$1"

    # 清理临时文件
    if [[ -n "$TEMP_FILES" ]]; then
        for temp_file in $TEMP_FILES; do
            [[ -f "$temp_file" ]] && rm -f "$temp_file"
        done
    fi

    # 记录退出状态
    if [[ $exit_code -eq 0 ]]; then
        log_message "INFO" "脚本执行成功完成"
    else
        log_message "ERROR" "脚本执行失败 (退出码: $exit_code)"
    fi
}

# 设置错误处理
setup_error_handling() {
    # 捕获错误
    set -e

    # 设置退出时清理
    trap 'cleanup_on_exit $?' EXIT

    # 初始化临时文件列表
    TEMP_FILES=""
}

# ------------------------------------------------------------------------------
# 校验和相关函数 (校验脚本需要)
# 文件完整性校验
# ------------------------------------------------------------------------------

# 计算文件校验和
calculate_checksum() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo ""
        return 1
    fi

    md5sum "$file_path" | cut -d' ' -f1
}

# 验证文件校验和
verify_checksum() {
    local file_path="$1"
    local expected_checksum="$2"

    local actual_checksum
    actual_checksum=$(calculate_checksum "$file_path")

    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo "❌ 校验和验证失败: $file_path"
        echo "  期望: $expected_checksum"
        echo "  实际: $actual_checksum"
        return 1
    fi

    return 0
}

echo "✅ 共享函数库加载完成"