# 共享函数库设计 (shared-functions.sh)

## 🎯 设计目标

创建统一的共享函数库，将所有脚本中重复的代码抽象为可重用的函数，降低维护成本，提高代码质量和一致性。

## 🏗️ 架构设计

### 函数分类

#### 1. 项目识别相关函数
**目的**: 识别脚本所属的项目，避免环境变量污染

#### 2. 路径操作相关函数
**目的**: 提供安全的文件和目录操作接口

#### 3. 日志记录相关函数
**目的**: 统一的日志格式和记录方式

#### 4. 配置管理相关函数
**目的**: 标准化的配置读取和写入

#### 5. 目录管理相关函数
**目的**: 自动创建项目目录结构

#### 6. 错误处理相关函数
**目的**: 统一的错误处理和清理机制

#### 7. 校验和相关函数
**目的**: 文件完整性校验

## 📋 详细函数设计

### 1. 项目识别相关函数

#### `generate_project_identifier()`
```bash
# 功能: 基于项目路径生成唯一标识符
# 输入: 无
# 输出: 设置 PROJECT_IDENTIFIER 变量
# 副作用: 在 .cursor/project_id 文件中持久化标识符

generate_project_identifier() {
    local project_path
    project_path=$(get_project_root_path)

    local project_hash
    project_hash=$(echo "$project_path" | md5sum | cut -d' ' -f1 | cut -c1-16)

    PROJECT_IDENTIFIER="proj_${project_hash}"
    export PROJECT_IDENTIFIER

    # 持久化存储
    echo "$PROJECT_IDENTIFIER" > "$project_path/.cursor/project_id"
}
```

#### `get_project_root_path()`
```bash
# 功能: 查找项目根目录 (.cursor 目录所在位置)
# 输入: 无
# 输出: 项目根目录路径

get_project_root_path() {
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

    echo "ERROR: 无法找到项目根目录 (.cursor 目录)" >&2
    return 1
}
```

#### `validate_project_context()`
```bash
# 功能: 验证脚本是否在正确的项目上下文中运行
# 输入: 无
# 输出: 成功返回0，失败返回1并输出错误信息

validate_project_context() {
    local current_project_id
    local stored_project_id

    current_project_id=$(generate_project_identifier 2>/dev/null)

    if [[ -f ".cursor/project_id" ]]; then
        stored_project_id=$(cat ".cursor/project_id")
    else
        echo "$current_project_id" > ".cursor/project_id"
        stored_project_id="$current_project_id"
    fi

    if [[ "$current_project_id" != "$stored_project_id" ]]; then
        echo "❌ 项目上下文验证失败!" >&2
        echo "  当前项目ID: $current_project_id" >&2
        echo "  存储项目ID: $stored_project_id" >&2
        echo "  可能原因: 脚本在错误的目录中运行" >&2
        return 1
    fi

    echo "✅ 项目上下文验证通过: $PROJECT_IDENTIFIER"
    return 0
}
```

### 2. 路径操作相关函数

#### `safe_file_operation()`
```bash
# 功能: 提供安全的文件操作接口
# 输入: operation (read/write/append/mkdir/rm/exists), target_path, [content]
# 输出: 根据操作返回相应结果

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
```

### 3. 日志记录相关函数

#### `log_message()`
```bash
# 功能: 统一的日志记录函数
# 输入: level (ERROR/WARN/INFO/DEBUG), message, [log_file]
# 输出: 控制台输出和文件记录

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
```

### 4. 配置管理相关函数

#### `safe_read_config()`
```bash
# 功能: 安全读取配置文件
# 输入: config_file, key, default_value
# 输出: 配置值或默认值

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
```

#### `safe_write_config()`
```bash
# 功能: 安全写入配置文件
# 输入: config_file, key, value
# 输出: 无

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
```

### 5. 目录管理相关函数

#### `ensure_directory_structure()`
```bash
# 功能: 确保项目目录结构完整
# 输入: 无
# 输出: 创建所有需要的目录

ensure_directory_structure() {
    local dirs_to_create=(
        "$CORE_DATA_DIR"
        "$AI_LEARNING_DIR"
        "$ANALYTICS_MONITORING_DIR"
        "$STORAGE_CACHE_DIR"
        "$RECORDS_LOGS_DIR"
        "$SYSTEM_SERVICES_DIR"
        "$PERCEPTION_DIR"
        "$USER_DATA_DIR"
        "$PROJECT_DATA_DIR"
        "$AI_MODELS_DIR"
        "$AI_TRAINING_DATA_DIR"
        "$AI_METRICS_DIR"
        "$AI_RESULTS_DIR"
        "$ANALYTICS_DATA_DIR"
        "$ANALYTICS_CACHE_DIR"
        "$MONITORING_DIR"
        "$CACHE_RULES_DIR"
        "$CACHE_TEMPLATES_DIR"
        "$BACKUPS_DIR"
        "$CONVERSATIONS_DIR"
        "$GROWTH_METRICS_DIR"
        "$LEARNING_PROGRESS_DIR"
        "$SYSTEM_LOGS_DIR"
        "$CONFIG_DIR"
        "$DEBUG_DIR"
        "$COMPRESSION_DIR"
        "$SYNC_DIR"
        "$INTEGRATIONS_DIR"
    )

    for dir in "${dirs_to_create[@]}"; do
        safe_file_operation "mkdir" "$dir"
    done

    log_message "INFO" "项目目录结构创建完成"
}
```

### 6. 错误处理相关函数

#### `handle_error()`
```bash
# 功能: 统一错误处理
# 输入: error_code, error_message, [script_name]
# 输出: 记录错误并退出

handle_error() {
    local error_code="$1"
    local error_message="$2"
    local script_name="${3:-$(basename "$0")}"

    log_message "ERROR" "$script_name: $error_message"

    # 可以在这里添加错误恢复逻辑
    exit "$error_code"
}
```

#### `setup_error_handling()`
```bash
# 功能: 设置错误处理机制
# 输入: 无
# 输出: 配置错误处理

setup_error_handling() {
    # 捕获错误
    set -e

    # 设置退出时清理
    trap 'cleanup_on_exit $?' EXIT

    # 初始化临时文件列表
    TEMP_FILES=""
}
```

#### `cleanup_on_exit()`
```bash
# 功能: 退出时清理资源
# 输入: exit_code
# 输出: 清理临时文件并记录退出状态

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
```

### 7. 校验和相关函数

#### `calculate_checksum()`
```bash
# 功能: 计算文件校验和
# 输入: file_path
# 输出: MD5校验和

calculate_checksum() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo ""
        return 1
    fi

    md5sum "$file_path" | cut -d' ' -f1
}
```

#### `verify_checksum()`
```bash
# 功能: 验证文件校验和
# 输入: file_path, expected_checksum
# 输出: 验证结果

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
```

## 🎯 使用模式

### 脚本模板
```bash
#!/bin/bash

# 加载共享函数库
source "$SCRIPT_DIR/shared-functions.sh"

# 项目上下文验证
validate_project_context || handle_error 1 "项目上下文验证失败"

# 设置错误处理
setup_error_handling

# 使用日志函数
log_message "INFO" "脚本开始执行"

# 使用配置函数
debug_mode=$(safe_read_config "$CONFIG_DIR/app.conf" "debug_mode" "false")

# 使用目录管理
ensure_directory_structure

# 使用文件操作
safe_file_operation "write" "$log_file" "开始处理..."

log_message "INFO" "脚本执行完成"
```

## 📊 维护成本降低评估

### 代码重用率提升
- **项目识别代码**: 从 N个脚本的重复 → 1个共享函数
- **日志记录代码**: 从 N个脚本的重复 → 1个共享函数
- **文件操作代码**: 从 N个脚本的重复 → 1个共享函数
- **错误处理代码**: 从 N个脚本的重复 → 1个共享函数

### 修改效率提升
- **单点修改**: 修改一处，影响所有使用脚本
- **一致性保证**: 所有脚本行为自动保持一致
- **错误减少**: 集中测试，减少重复错误

### 预估收益
- **代码行数减少**: 30-50%
- **维护时间减少**: 60-80%
- **错误发生率降低**: 70-90%