#!/bin/bash

# 🎯 Cursor AI Rules - 性能缓存系统
# 为各种性能监控和优化功能提供统一的缓存支持

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/shared-functions.sh"  # 共享函数

# 缓存配置
CACHE_DIR="${CACHE_DIR:-$ANALYTICS_DIR/cache}"
PERFORMANCE_CACHE_FILE="$CACHE_DIR/performance-cache.json"
COMPRESSION_CACHE_FILE="$CACHE_DIR/compression-cache.json"

# 缓存配置参数
MAX_CACHE_ENTRIES="${MAX_CACHE_ENTRIES:-1000}"
CACHE_TTL_HOURS="${CACHE_TTL_HOURS:-24}"
COMPRESSION_RATIO_TARGET="${COMPRESSION_RATIO_TARGET:-30}"

# 初始化缓存系统
init_performance_cache() {
    smart_echo "初始化性能缓存系统..." "processing"

    # 创建缓存目录
    mkdir -p "$CACHE_DIR"

    # 初始化性能缓存文件
    if [ ! -f "$PERFORMANCE_CACHE_FILE" ]; then
        cat > "$PERFORMANCE_CACHE_FILE" << EOF
{
  "version": "1.0.0",
  "created_at": "$(date -Iseconds)",
  "cache_entries": {},
  "stats": {
    "total_entries": 0,
    "hits": 0,
    "misses": 0,
    "evictions": 0,
    "last_cleanup": "$(date -Iseconds)"
  },
  "config": {
    "max_entries": $MAX_CACHE_ENTRIES,
    "ttl_hours": $CACHE_TTL_HOURS,
    "compression_target": $COMPRESSION_RATIO_TARGET
  }
}
EOF
    fi

    # 初始化压缩缓存文件
    if [ ! -f "$COMPRESSION_CACHE_FILE" ]; then
        cat > "$COMPRESSION_CACHE_FILE" << EOF
{
  "version": "1.0.0",
  "created_at": "$(date -Iseconds)",
  "patterns": {},
  "compression_stats": {
    "total_compressed": 0,
    "average_ratio": 0,
    "last_update": "$(date -Iseconds)"
  }
}
EOF
    fi

    smart_echo "性能缓存系统初始化完成" "success"
}

# 获取缓存条目
get_cache_entry() {
    local key="$1"
    local cache_file="${2:-$PERFORMANCE_CACHE_FILE}"

    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    # 使用jq获取缓存条目
    if command -v jq >/dev/null 2>&1; then
        local entry
        entry=$(jq -r ".cache_entries.\"$key\" // empty" "$cache_file" 2>/dev/null)
        if [ -n "$entry" ] && [ "$entry" != "null" ]; then
            echo "$entry"
            return 0
        fi
    else
        # 回退方案：使用grep和sed
        local line
        line=$(grep -F "\"$key\":" "$cache_file" | head -1 | sed 's/.*"'"$key"'"://;s/,.*//')
        if [ -n "$line" ]; then
            echo "$line"
            return 0
        fi
    fi

    return 1
}

# 设置缓存条目
set_cache_entry() {
    local key="$1"
    local value="$2"
    local ttl_hours="${3:-$CACHE_TTL_HOURS}"
    local cache_file="${4:-$PERFORMANCE_CACHE_FILE}"

    # 计算过期时间
    local expiry_time
    expiry_time=$(date -d "+$ttl_hours hours" +%s 2>/dev/null || echo "$(($(date +%s) + ttl_hours * 3600))")

    local entry="{\"value\": $value, \"expiry\": $expiry_time, \"created\": $(date +%s)}"

    if command -v jq >/dev/null 2>&1; then
        # 使用jq更新缓存
        jq ".cache_entries.\"$key\" = $entry | .stats.total_entries = (.cache_entries | length)" "$cache_file" > "${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file"
    else
        # 简化的回退方案
        echo "缓存功能需要jq支持" >&2
        return 1
    fi
}

# 清理过期缓存
cleanup_expired_cache() {
    local cache_file="${1:-$PERFORMANCE_CACHE_FILE}"
    local current_time
    current_time=$(date +%s)

    if command -v jq >/dev/null 2>&1 && [ -f "$cache_file" ]; then
        jq "del(.cache_entries[] | select(.expiry < $current_time)) | .stats.last_cleanup = \"$(date -Iseconds)\"" "$cache_file" > "${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file"
    fi
}

# 获取缓存统计信息
get_cache_stats() {
    local cache_file="${1:-$PERFORMANCE_CACHE_FILE}"

    if [ -f "$cache_file" ] && command -v jq >/dev/null 2>&1; then
        jq -r '.stats' "$cache_file"
    else
        echo "{}"
    fi
}

# 压缩文本缓存
cache_compressed_text() {
    local text_key="$1"
    local compressed_text="$2"

    if command -v jq >/dev/null 2>&1; then
        jq ".patterns.\"$text_key\" = {\"compressed\": \"$compressed_text\", \"ratio\": $((${#compressed_text} * 100 / ${#1:-1}))}" "$COMPRESSION_CACHE_FILE" > "${COMPRESSION_CACHE_FILE}.tmp" && mv "${COMPRESSION_CACHE_FILE}.tmp" "$COMPRESSION_CACHE_FILE"
    fi
}

# 获取压缩文本
get_compressed_text() {
    local text_key="$1"

    if [ -f "$COMPRESSION_CACHE_FILE" ] && command -v jq >/dev/null 2>&1; then
        jq -r ".patterns.\"$text_key\".compressed // empty" "$COMPRESSION_CACHE_FILE"
    fi
}

# 性能监控缓存
cache_performance_metric() {
    local operation="$1"
    local response_time="$2"
    local token_usage="$3"
    local timestamp="${4:-$(date +%s)}"

    local metric_key="${operation}_$(date +%s)"
    local metric_data="{\"operation\": \"$operation\", \"response_time\": $response_time, \"token_usage\": $token_usage, \"timestamp\": $timestamp}"

    set_cache_entry "$metric_key" "$metric_data" 168 "$PERFORMANCE_CACHE_FILE" # 7天TTL
}

# 批量缓存操作
batch_cache_operation() {
    local operation="$1"

    case "$operation" in
        "cleanup")
            cleanup_expired_cache "$PERFORMANCE_CACHE_FILE"
            cleanup_expired_cache "$COMPRESSION_CACHE_FILE"
            ;;
        "stats")
            get_cache_stats "$PERFORMANCE_CACHE_FILE"
            ;;
        "clear")
            # 清空缓存但保留结构
            if command -v jq >/dev/null 2>&1; then
                jq '.cache_entries = {} | .stats.total_entries = 0 | .stats.hits = 0 | .stats.misses = 0 | .stats.evictions = 0' "$PERFORMANCE_CACHE_FILE" > "${PERFORMANCE_CACHE_FILE}.tmp" && mv "${PERFORMANCE_CACHE_FILE}.tmp" "$PERFORMANCE_CACHE_FILE"
            fi
            ;;
        *)
            echo "未知的批量操作: $operation" >&2
            return 1
            ;;
    esac
}

# 缓存健康检查
health_check_cache() {
    local issues=()

    # 检查缓存文件是否存在
    if [ ! -f "$PERFORMANCE_CACHE_FILE" ]; then
        issues+=("performance-cache.json缺失")
    fi

    if [ ! -f "$COMPRESSION_CACHE_FILE" ]; then
        issues+=("compression-cache.json缺失")
    fi

    # 检查缓存目录权限
    if [ ! -w "$CACHE_DIR" ]; then
        issues+=("缓存目录无写权限")
    fi

    # 检查jq依赖
    if ! command -v jq >/dev/null 2>&1; then
        issues+=("jq命令不可用")
    fi

    if [ ${#issues[@]} -eq 0 ]; then
        echo "✅ 缓存系统健康"
        return 0
    else
        echo "❌ 缓存系统问题:"
        printf '   - %s\n' "${issues[@]}"
        return 1
    fi
}

# 导出函数供其他脚本使用
export -f init_performance_cache
export -f get_cache_entry
export -f set_cache_entry
export -f cleanup_expired_cache
export -f get_cache_stats
export -f cache_compressed_text
export -f get_compressed_text
export -f cache_performance_metric
export -f batch_cache_operation
export -f health_check_cache

# 如果直接执行此脚本，显示帮助信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🎯 Cursor AI Rules - 性能缓存系统"
    echo ""
    echo "用法: $0 [command]"
    echo ""
    echo "命令:"
    echo "  init     初始化缓存系统"
    echo "  cleanup  清理过期缓存"
    echo "  stats    显示缓存统计"
    echo "  clear    清空缓存"
    echo "  health   健康检查"
    echo "  help     显示此帮助信息"
    echo ""

    case "${1:-help}" in
        "init")
            init_performance_cache
            ;;
        "cleanup")
            batch_cache_operation "cleanup"
            ;;
        "stats")
            batch_cache_operation "stats"
            ;;
        "clear")
            batch_cache_operation "clear"
            ;;
        "health")
            health_check_cache
            ;;
        "help"|*)
            exit 0
            ;;
    esac
fi