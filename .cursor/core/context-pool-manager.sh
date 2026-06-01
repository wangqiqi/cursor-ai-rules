#!/bin/bash

# 🎯 Cursor AI Rules - 上下文池管理系统
# 实现上下文共享、池化管理和跨会话传递，减少Token重复消耗

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/context-manager.sh"
source "$SCRIPT_DIR/token-compression.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 上下文池配置 (合并到ai目录)
CONTEXT_POOL_DIR="$AI_DIR"
CONTEXT_POOL_INDEX="$CONTEXT_POOL_DIR/ai-context-pool-index.json"
CONTEXT_POOL_STATS="$CONTEXT_POOL_DIR/ai-context-pool-stats.json"
CONTEXT_POOL_SHARED="$CONTEXT_POOL_DIR/ai-context-pool-shared.json"

# 上下文池参数
POOL_MAX_SIZE="${CONTEXT_POOL_MAX_SIZE:-100}"  # 池最大容量
POOL_CLEANUP_INTERVAL="${CONTEXT_POOL_CLEANUP_INTERVAL:-3600}"  # 清理间隔(秒)
POOL_COMPRESSION_ENABLED="${CONTEXT_POOL_COMPRESSION_ENABLED:-true}"  # 启用压缩
POOL_SHARING_ENABLED="${CONTEXT_POOL_SHARING_ENABLED:-true}"  # 启用共享

# 上下文类型定义
declare -A CONTEXT_TYPES=(
    ["project"]="项目级上下文，长期有效"
    ["session"]="会话级上下文，会话内有效"
    ["operation"]="操作级上下文，操作内有效"
    ["user"]="用户级上下文，用户相关"
    ["system"]="系统级上下文，全局有效"
)

# 初始化上下文池
init_context_pool() {
    smart_echo "初始化上下文池管理系统..." "processing"

    # 创建必要的目录结构 (只创建一级目录)
    mkdir -p "$CONTEXT_POOL_DIR"

    # 初始化池索引文件
    [[ ! -f "$CONTEXT_POOL_INDEX" ]] && cat > "$CONTEXT_POOL_INDEX" << EOF
{
  "version": "1.0",
  "created_at": "$(date -Iseconds)",
  "pool_size": 0,
  "max_size": $POOL_MAX_SIZE,
  "contexts": {},
  "sharing_rules": {
    "project": {"shareable": true, "ttl": 86400, "max_uses": 50},
    "session": {"shareable": true, "ttl": 3600, "max_uses": 20},
    "operation": {"shareable": false, "ttl": 300, "max_uses": 5},
    "user": {"shareable": true, "ttl": 604800, "max_uses": 100},
    "system": {"shareable": true, "ttl": 2592000, "max_uses": 500}
  },
  "compression_stats": {
    "enabled": $POOL_COMPRESSION_ENABLED,
    "total_saved_tokens": 0,
    "compression_ratio": 0
  }
}
EOF

    # 初始化统计文件
    [[ ! -f "$CONTEXT_POOL_STATS" ]] && cat > "$CONTEXT_POOL_STATS" << EOF
{
  "stats": {
    "total_contexts_created": 0,
    "total_contexts_reused": 0,
    "total_tokens_saved": 0,
    "average_reuse_rate": 0,
    "last_cleanup": "$(date -Iseconds)"
  },
  "performance": {
    "avg_pool_lookup_time": 0,
    "avg_context_load_time": 0,
    "cache_hit_rate": 0
  },
  "usage_patterns": {
    "most_reused_contexts": [],
    "context_lifecycle": {},
    "sharing_effectiveness": {}
  }
}
EOF

    smart_echo "上下文池管理系统初始化完成" "success"
}

# 🎯 上下文池核心管理函数

# 获取或创建上下文
get_or_create_context() {
    local context_key="$1"
    local context_type="$2"
    local generator_function="$3"
    local additional_params="${4:-}"

    smart_echo "上下文池: 获取/创建上下文 $context_key ($context_type)..." "info"

    # 1. 检查池中是否已存在
    local existing_context=$(lookup_context_in_pool "$context_key" "$context_type")
    if [[ -n "$existing_context" ]]; then
        smart_echo "上下文池命中: 重用现有上下文" "success"
        update_context_usage "$context_key"
        echo "$existing_context"
        return 0
    fi

    # 2. 上下文不存在，创建新的
    smart_echo "上下文池未命中: 创建新上下文" "info"

    # 调用生成函数创建上下文
    local new_context
    if [[ -n "$additional_params" ]]; then
        new_context=$($generator_function "$additional_params")
    else
        new_context=$($generator_function)
    fi

    # 3. 将新上下文添加到池中
    add_context_to_pool "$context_key" "$context_type" "$new_context"

    # 4. 返回新创建的上下文
    echo "$new_context"
}

# 从池中查找上下文
lookup_context_in_pool() {
    local context_key="$1"
    local context_type="$2"

    # 检查池索引
    if [[ ! -f "$CONTEXT_POOL_INDEX" ]]; then
        return 1
    fi

    # 查找上下文记录
    local context_record=$(jq -r ".contexts.\"$context_key\" // empty" "$CONTEXT_POOL_INDEX" 2>/dev/null)

    if [[ -z "$context_record" || "$context_record" == "null" ]]; then
        return 1
    fi

    # 验证上下文是否仍然有效
    if ! is_context_valid "$context_key" "$context_record"; then
        # 上下文已过期，移除
        remove_expired_context "$context_key"
        return 1
    fi

    # 获取上下文数据
    local context_file="$CONTEXT_POOL_SHARED/$(echo "$context_record" | jq -r '.file_id')"
    if [[ -f "$context_file" ]]; then
        local context_data=$(cat "$context_file")

        # 如果启用了压缩，需要解压
        if [[ "$POOL_COMPRESSION_ENABLED" == "true" ]]; then
            local compression_info=$(echo "$context_record" | jq -r '.compression // empty')
            if [[ -n "$compression_info" ]]; then
                context_data=$(decompress_context_data "$context_data" "$compression_info")
            fi
        fi

        echo "$context_data"
        return 0
    fi

    return 1
}

# 将上下文添加到池中
add_context_to_pool() {
    local context_key="$1"
    local context_type="$2"
    local context_data="$3"

    # 生成唯一文件ID
    local file_id=$(generate_unique_id)
    local context_file="$CONTEXT_POOL_SHARED/$file_id"

    # 准备上下文数据
    local processed_data="$context_data"
    local compression_info=""

    # 如果启用了压缩，进行压缩处理
    if [[ "$POOL_COMPRESSION_ENABLED" == "true" ]]; then
        processed_data=$(compress_context_for_pool "$context_data")
        compression_info=$(echo "$processed_data" | jq -r '.compression_info // empty' 2>/dev/null)
        processed_data=$(echo "$processed_data" | jq -r '.compressed_data // empty' 2>/dev/null)
    fi

    # 保存上下文数据到文件
    echo "$processed_data" > "$context_file"

    # 获取上下文类型的配置
    local type_config=$(jq -r ".sharing_rules.\"$context_type\" // empty" "$CONTEXT_POOL_INDEX" 2>/dev/null)

    # 创建上下文记录
    local context_record=$(cat <<EOF
{
  "context_key": "$context_key",
  "context_type": "$context_type",
  "file_id": "$file_id",
  "created_at": "$(date -Iseconds)",
  "size_bytes": ${#processed_data},
  "estimated_tokens": $(estimate_tokens "context" "${#processed_data}"),
  "usage_count": 1,
  "last_used": "$(date -Iseconds)",
  "ttl_seconds": $(echo "$type_config" | jq -r '.ttl // 3600'),
  "max_uses": $(echo "$type_config" | jq -r '.max_uses // 10'),
  "compression": "$compression_info"
}
EOF
)

    # 更新池索引
    local temp_index=$(mktemp)
    jq --arg key "$context_key" --argjson record "$context_record" '.contexts[$key] = $record | .pool_size = (.pool_size + 1)' "$CONTEXT_POOL_INDEX" > "$temp_index"
    mv "$temp_index" "$CONTEXT_POOL_INDEX"

    # 检查池大小限制
    check_pool_size_limit

    # 更新统计信息
    update_pool_stats "context_created" "$context_type"

    smart_echo "上下文已添加到池中: $context_key" "success"
}

# 验证上下文是否仍然有效
is_context_valid() {
    local context_key="$1"
    local context_record="$2"

    # 检查使用次数限制
    local usage_count=$(echo "$context_record" | jq -r '.usage_count // 0')
    local max_uses=$(echo "$context_record" | jq -r '.max_uses // 10')

    if (( usage_count >= max_uses )); then
        return 1
    fi

    # 检查TTL
    local created_at=$(echo "$context_record" | jq -r '.created_at // "1970-01-01T00:00:00Z"')
    local ttl_seconds=$(echo "$context_record" | jq -r '.ttl_seconds // 3600')

    local created_timestamp=$(date -d "$created_at" +%s 2>/dev/null || echo "0")
    local current_timestamp=$(date +%s)
    local age_seconds=$((current_timestamp - created_timestamp))

    if (( age_seconds > ttl_seconds )); then
        return 1
    fi

    return 0
}

# 更新上下文使用情况
update_context_usage() {
    local context_key="$1"

    # 更新索引中的使用统计
    local temp_index=$(mktemp)
    local current_time="$(date -Iseconds)"
    jq --arg key "$context_key" --arg timestamp "$current_time" '.contexts[$key].usage_count = (.contexts[$key].usage_count + 1) | .contexts[$key].last_used = $timestamp' "$CONTEXT_POOL_INDEX" > "$temp_index"
    mv "$temp_index" "$CONTEXT_POOL_INDEX"

    # 更新统计信息
    update_pool_stats "context_reused"
}

# 检查池大小限制
check_pool_size_limit() {
    local current_size=$(jq -r '.pool_size // 0' "$CONTEXT_POOL_INDEX")

    if (( current_size > POOL_MAX_SIZE )); then
        smart_echo "上下文池达到大小限制，开始清理..." "warning"

        # 执行LRU清理
        cleanup_pool_by_lru
    fi
}

# LRU清理策略
cleanup_pool_by_lru() {
    local contexts_to_remove=$(jq -r '.contexts | to_entries | sort_by(.value.last_used) | .[0:10] | map(.key) | join(" ")' "$CONTEXT_POOL_INDEX")

    for context_key in $contexts_to_remove; do
        remove_context_from_pool "$context_key"
    done

    smart_echo "LRU清理完成: 移除了 ${#contexts_to_remove[@]} 个过期上下文" "info"
}

# 移除上下文
remove_context_from_pool() {
    local context_key="$1"

    # 获取文件ID
    local file_id=$(jq -r ".contexts.\"$context_key\".file_id // empty" "$CONTEXT_POOL_INDEX")

    # 删除数据文件
    if [[ -n "$file_id" && -f "$CONTEXT_POOL_SHARED/$file_id" ]]; then
        rm -f "$CONTEXT_POOL_SHARED/$file_id"
    fi

    # 从索引中移除
    local temp_index=$(mktemp)
    jq --arg key "$context_key" 'del(.contexts[$key]) | .pool_size = (.pool_size - 1)' "$CONTEXT_POOL_INDEX" > "$temp_index"
    mv "$temp_index" "$CONTEXT_POOL_INDEX"

    smart_echo "上下文已从池中移除: $context_key" "info"
}

# 移除过期上下文
remove_expired_context() {
    local context_key="$1"
    remove_context_from_pool "$context_key"
}

# 🎯 上下文共享策略

# 智能共享决策
should_share_context() {
    local context_key="$1"
    local context_type="$2"
    local context_data="$3"

    # 检查全局共享开关
    if [[ "$POOL_SHARING_ENABLED" != "true" ]]; then
        return 1
    fi

    # 检查上下文类型是否可共享
    local shareable=$(jq -r ".sharing_rules.\"$context_type\".shareable // false" "$CONTEXT_POOL_INDEX")
    if [[ "$shareable" != "true" ]]; then
        return 1
    fi

    # 检查上下文大小是否值得共享
    local data_size=${#context_data}
    local estimated_tokens=$(estimate_tokens "context" "$data_size")

    # 只共享相对较大的上下文（估计>50个token）
    if (( estimated_tokens < 50 )); then
        return 1
    fi

    # 检查是否包含敏感信息
    if contains_sensitive_data "$context_data"; then
        return 1
    fi

    return 0
}

# 检查是否包含敏感数据
contains_sensitive_data() {
    local data="$1"

    # 检查常见的敏感数据模式
    local sensitive_patterns=(
        "password"
        "secret"
        "token"
        "key"
        "credential"
        "private"
        "api_key"
        "access_token"
    )

    for pattern in "${sensitive_patterns[@]}"; do
        if echo "$data" | grep -qi "$pattern"; then
            return 0
        fi
    done

    return 1
}

# 🎯 上下文压缩优化

# 为池压缩上下文
compress_context_for_pool() {
    local context_data="$1"

    if [[ "$POOL_COMPRESSION_ENABLED" != "true" ]]; then
        cat <<EOF
{
  "compressed_data": "$context_data",
  "compression_info": null
}
EOF
        return
    fi

    # 使用智能压缩分析器
    local compression_result=$(intelligent_compression_analyzer "$context_data" "context_pool")

    # 提取压缩后的数据和统计信息
    local compressed_data=$(echo "$compression_result" | jq -r '.compressed_data // empty')
    local compression_stats=$(echo "$compression_result" | jq -r '.compression_stats // {}')

    cat <<EOF
{
  "compressed_data": "$compressed_data",
  "compression_info": $compression_stats
}
EOF
}

# 解压上下文数据
decompress_context_data() {
    local compressed_data="$1"
    local compression_info="$2"

    if [[ -z "$compression_info" || "$compression_info" == "null" ]]; then
        echo "$compressed_data"
        return
    fi

    # 根据压缩信息进行解压
    local compression_level=$(echo "$compression_info" | jq -r '.strategy_used // "balanced"')
    decompress_tokens "$compressed_data" "$compression_level"
}

# 🎯 跨会话上下文传递

# 导出上下文到会话
export_context_to_session() {
    local session_id="$1"
    local context_keys="${2:-all}"

    smart_echo "导出上下文到会话: $session_id..." "info"

    local session_dir="$CONTEXT_POOL_DIR/sessions/$session_id"
    mkdir -p "$session_dir"

    if [[ "$context_keys" == "all" ]]; then
        # 导出所有可共享的上下文
        jq -r '.contexts | to_entries[] | select(.value.context_type as $type | .sharing_rules[$type].shareable) | .key' "$CONTEXT_POOL_INDEX" | while read -r key; do
            export_single_context "$key" "$session_dir"
        done
    else
        # 导出指定的上下文
        for key in $context_keys; do
            export_single_context "$key" "$session_dir"
        done
    fi

    smart_echo "上下文导出完成" "success"
}

# 导出单个上下文
export_single_context() {
    local context_key="$1"
    local session_dir="$2"

    local context_record=$(jq -r ".contexts.\"$context_key\" // empty" "$CONTEXT_POOL_INDEX")
    if [[ -z "$context_record" ]]; then
        return
    fi

    # 复制上下文数据文件
    local file_id=$(echo "$context_record" | jq -r '.file_id')
    if [[ -f "$CONTEXT_POOL_SHARED/$file_id" ]]; then
        cp "$CONTEXT_POOL_SHARED/$file_id" "$session_dir/"
    fi

    # 保存上下文元数据
    echo "$context_record" > "$session_dir/${context_key}.meta.json"
}

# 从会话导入上下文
import_context_from_session() {
    local session_id="$1"

    smart_echo "从会话导入上下文: $session_id..." "info"

    local session_dir="$CONTEXT_POOL_DIR/sessions/$session_id"
    if [[ ! -d "$session_dir" ]]; then
        smart_echo "会话目录不存在: $session_dir" "warning"
        return
    fi

    # 遍历会话中的上下文文件
    for meta_file in "$session_dir"/*.meta.json; do
        if [[ -f "$meta_file" ]]; then
            local context_key=$(basename "$meta_file" .meta.json)
            local context_record=$(cat "$meta_file")

            # 检查上下文是否仍然有效
            if is_context_valid "$context_key" "$context_record"; then
                # 将上下文重新添加到池中
                local file_id=$(echo "$context_record" | jq -r '.file_id')
                if [[ -f "$session_dir/$file_id" ]]; then
                    cp "$session_dir/$file_id" "$CONTEXT_POOL_SHARED/"
                    # 更新池索引
                    local temp_index=$(mktemp)
                    jq --arg key "$context_key" --argjson record "$context_record" '.contexts[$key] = $record' "$CONTEXT_POOL_INDEX" > "$temp_index"
                    mv "$temp_index" "$CONTEXT_POOL_INDEX"
                fi
            fi
        fi
    done

    smart_echo "上下文导入完成" "success"
}

# 🎯 性能监控和统计

# 更新池统计信息
update_pool_stats() {
    local event_type="$1"
    local context_type="$2"

    local stats_file="$CONTEXT_POOL_STATS"
    local temp_stats=$(mktemp)

    case "$event_type" in
        "context_created")
            jq --arg type "$context_type" '.stats.total_contexts_created += 1 | .usage_patterns.context_lifecycle[$type].created = (.usage_patterns.context_lifecycle[$type].created // 0) + 1' "$stats_file" > "$temp_stats"
            ;;
        "context_reused")
            jq '.stats.total_contexts_reused += 1' "$stats_file" > "$temp_stats"
            ;;
        "cleanup_performed")
            local current_time="$(date -Iseconds)"
            jq --arg timestamp "$current_time" '.stats.last_cleanup = $timestamp' "$stats_file" > "$temp_stats"
            ;;
    esac

    if [[ -s "$temp_stats" ]]; then
        mv "$temp_stats" "$stats_file"
    fi
}

# 获取池性能统计
get_pool_performance_stats() {
    if [[ ! -f "$CONTEXT_POOL_STATS" ]]; then
        echo "{}"
        return
    fi

    # 计算实时统计信息
    local pool_size=$(jq -r '.pool_size // 0' "$CONTEXT_POOL_INDEX")
    local total_created=$(jq -r '.stats.total_contexts_created // 0' "$CONTEXT_POOL_STATS")
    local total_reused=$(jq -r '.stats.total_contexts_reused // 0' "$CONTEXT_POOL_STATS")

    # 计算重用率
    local reuse_rate=0
    if (( total_created + total_reused > 0 )); then
        reuse_rate=$(echo "scale=2; $total_reused * 100 / ($total_created + $total_reused)" | bc 2>/dev/null || echo "0")
    fi

    # 合并统计信息
    jq --arg pool_size "$pool_size" --arg reuse_rate "$reuse_rate" '. + {current_pool_size: $pool_size, reuse_rate_percent: $reuse_rate}' "$CONTEXT_POOL_STATS"
}

# 显示池状态
show_pool_status() {
    smart_echo "=== 上下文池状态 ===" "info"

    if [[ ! -f "$CONTEXT_POOL_INDEX" ]]; then
        smart_echo "上下文池未初始化" "warning"
        return
    fi

    local pool_size=$(jq -r '.pool_size // 0' "$CONTEXT_POOL_INDEX")
    local max_size=$(jq -r '.max_size // 0' "$CONTEXT_POOL_INDEX")

    smart_echo "池大小: $pool_size / $max_size" "info"

    # 显示各类型上下文的数量
    jq -r '.contexts | to_entries | group_by(.value.context_type) | map({type: .[0].value.context_type, count: length}) | .[] | "\(.type): \(.count)"' "$CONTEXT_POOL_INDEX" | while read -r line; do
        smart_echo "  $line" "info"
    done

    # 显示性能统计
    local stats=$(get_pool_performance_stats)
    local reuse_rate=$(echo "$stats" | jq -r '.reuse_rate_percent // 0')
    local total_saved=$(echo "$stats" | jq -r '.stats.total_tokens_saved // 0')

    smart_echo "重用率: ${reuse_rate}%" "info"
    smart_echo "累计Token节省: $total_saved" "info"
}

# 🎯 高级上下文池管理

# 智能上下文预取
intelligent_context_prefetch() {
    local current_operation="$1"
    local context_hints="${2:-}"

    smart_echo "智能上下文预取..." "processing"

    # 基于当前操作预测需要的上下文
    local predicted_contexts=$(predict_needed_contexts_based_on_operation "$current_operation" "$context_hints")

    # 预加载预测的上下文
    local prefetch_count=0
    while IFS= read -r context_info; do
        [[ -z "$context_info" ]] && continue

        local context_key=$(echo "$context_info" | jq -r '.key // empty')
        local context_type=$(echo "$context_info" | jq -r '.type // "operation"')
        local generator=$(echo "$context_info" | jq -r '.generator // empty')

        if [[ -n "$context_key" && -n "$generator" ]]; then
            # 异步预加载
            (
                get_or_create_context "$context_key" "$context_type" "$generator" > /dev/null
            ) &
            ((prefetch_count++))
        fi
    done <<< "$(echo "$predicted_contexts" | jq -c '.[] // empty' 2>/dev/null)"

    smart_echo "预取完成: $prefetch_count 个上下文" "success"
}

# 基于操作预测需要的上下文
predict_needed_contexts_based_on_operation() {
    local operation="$1"
    local hints="$2"

    # 定义操作到上下文的映射
    local operation_context_map='{
        "analyze_project": [
            {"key": "project_structure", "type": "project", "generator": "get_project_structure_context"},
            {"key": "dependency_info", "type": "project", "generator": "get_dependency_context"}
        ],
        "check_code_quality": [
            {"key": "eslint_config", "type": "project", "generator": "get_eslint_context"},
            {"key": "code_metrics", "type": "operation", "generator": "get_code_metrics_context"}
        ],
        "deploy_application": [
            {"key": "deployment_config", "type": "project", "generator": "get_deployment_context"},
            {"key": "environment_info", "type": "session", "generator": "get_environment_context"}
        ]
    }'

    # 查找匹配的操作
    echo "$operation_context_map" | jq -r ".\"$operation\" // []"
}

# 上下文池维护任务
perform_pool_maintenance() {
    smart_echo "执行上下文池维护..." "processing"

    # 1. 清理过期上下文
    cleanup_expired_contexts

    # 2. 优化池大小
    optimize_pool_size

    # 3. 更新统计信息
    update_maintenance_stats

    # 4. 压缩池索引
    compress_pool_index

    smart_echo "上下文池维护完成" "success"
}

# 清理过期上下文
cleanup_expired_contexts() {
    smart_echo "清理过期上下文..." "info"

    local expired_count=0
    local current_time=$(date +%s)

    # 查找所有上下文记录
    jq -r '.contexts | to_entries[] | .key' "$CONTEXT_POOL_INDEX" | while read -r context_key; do
        local context_record=$(jq -r ".contexts.\"$context_key\"" "$CONTEXT_POOL_INDEX")
        local created_at=$(echo "$context_record" | jq -r '.created_at // "1970-01-01T00:00:00Z"')
        local ttl_seconds=$(echo "$context_record" | jq -r '.ttl_seconds // 3600')

        local created_timestamp=$(date -d "$created_at" +%s 2>/dev/null || echo "0")
        local age_seconds=$((current_time - created_timestamp))

        if (( age_seconds > ttl_seconds )); then
            remove_context_from_pool "$context_key"
            ((expired_count++))
        fi
    done

    smart_echo "清理了 $expired_count 个过期上下文" "info"
}

# 优化池大小
optimize_pool_size() {
    local current_size=$(jq -r '.pool_size // 0' "$CONTEXT_POOL_INDEX")
    local max_size=$POOL_MAX_SIZE

    if (( current_size > max_size * 0.9 )); then
        smart_echo "池大小接近上限，执行LRU清理..." "warning"
        cleanup_pool_by_lru
    fi
}

# 更新维护统计
update_maintenance_stats() {
    update_pool_stats "cleanup_performed"
}

# 压缩池索引
compress_pool_index() {
    if [[ "$POOL_COMPRESSION_ENABLED" == "true" ]]; then
        smart_echo "压缩池索引..." "info"
        # 这里可以实现索引压缩逻辑
    fi
}

# 🎯 工具函数

# 生成唯一ID
generate_unique_id() {
    echo "$(date +%s%N)_$(openssl rand -hex 4 2>/dev/null || echo "random")"
}

# 估算token数量（简化版）
estimate_tokens() {
    local content_type="$1"
    local size="$2"

    # 粗略估算：每4个字符约等于1个token
    echo $(( size / 4 ))
}

# 获取内存使用情况
get_memory_usage() {
    if command -v free >/dev/null 2>&1; then
        free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'
    else
        echo "0"
    fi
}

# 获取CPU使用情况
get_cpu_usage() {
    if command -v top >/dev/null 2>&1; then
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
    else
        echo "0"
    fi
}

# 导出函数
export -f init_context_pool
export -f get_or_create_context
export -f export_context_to_session
export -f import_context_from_session
export -f show_pool_status
export -f perform_pool_maintenance
export -f intelligent_context_prefetch
export -f get_pool_performance_stats

# 初始化
init_context_pool