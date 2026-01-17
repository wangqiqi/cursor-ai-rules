#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置


# 🚀 Cursor AI Rules - 性能缓存系统
# 提升对话速度，降低token消耗

set -e

# 缓存配置
CACHE_DIR="$CURSOR_GROWTH/cache"
CACHE_TTL=300  # 5分钟缓存有效期
PERFORMANCE_LOG="$CACHE_DIR/performance.log"

# 初始化缓存目录
init_cache() {
    mkdir -p "$CACHE_DIR"
    touch "$PERFORMANCE_LOG"
}

# 获取缓存键
get_cache_key() {
    local type="$1"
    local input="$2"
    echo "$type:$(echo "$input" | md5sum | cut -d' ' -f1)"
}

# 检查缓存是否有效
is_cache_valid() {
    local cache_file="$1"
    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    local cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local age=$((current_time - cache_time))

    [ $age -lt $CACHE_TTL ]
}

# 从缓存读取数据
read_cache() {
    local cache_key="$1"
    local cache_file="$CACHE_DIR/$cache_key.cache"

    if is_cache_valid "$cache_file"; then
        cat "$cache_file" 2>/dev/null
        return 0
    else
        return 1
    fi
}

# 写入缓存数据
write_cache() {
    local cache_key="$1"
    local data="$2"
    local cache_file="$CACHE_DIR/$cache_key.cache"

    echo "$data" > "$cache_file"
}

# 清除过期缓存
clean_expired_cache() {
    find "$CACHE_DIR" -name "*.cache" -type f -mmin +5 -delete 2>/dev/null || true
}

# 记录性能指标
log_performance() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    local token_estimate="$4"
    local cache_hit="${5:-false}"

    local duration=$((end_time - start_time))
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$operation,$duration,$token_estimate,$cache_hit" >> "$PERFORMANCE_LOG"
}

# 获取性能统计
get_performance_stats() {
    if [ ! -f "$PERFORMANCE_LOG" ]; then
        echo '{"error": "No performance data available"}'
        return
    fi

    # 分析最近的性能数据
    local recent_data=$(tail -n 100 "$PERFORMANCE_LOG" 2>/dev/null || cat "$PERFORMANCE_LOG")

    # 计算平均响应时间
    local avg_duration=$(echo "$recent_data" | awk -F',' '{sum += $3; count++} END {print count > 0 ? sum/count : 0}')

    # 计算缓存命中率
    local total_requests=$(echo "$recent_data" | wc -l)
    local cache_hits=$(echo "$recent_data" | grep ",true$" | wc -l)
    local cache_hit_rate=0
    if [ "$total_requests" -gt 0 ]; then
        cache_hit_rate=$((cache_hits * 100 / total_requests))
    fi

    # 计算平均token消耗
    local avg_tokens=$(echo "$recent_data" | awk -F',' '{sum += $4; count++} END {print count > 0 ? sum/count : 0}')

    cat << EOF
{
  "performance_stats": {
    "average_response_time_ms": ${avg_duration:-0},
    "cache_hit_rate_percent": $cache_hit_rate,
    "average_token_consumption": ${avg_tokens:-0},
    "total_requests_analyzed": $total_requests,
    "time_range": "last_100_requests"
  }
}
EOF
}

# 智能缓存的环境感知
cached_env_perception() {
    local cache_key=$(get_cache_key "env_perception" "full_scan")
    local start_time=$(date +%s)

    # 尝试从缓存读取
    if read_cache "$cache_key" >/dev/null 2>&1; then
        # 缓存命中：读取并输出缓存内容
        local cached_data=$(read_cache "$cache_key")
        local end_time=$(date +%s)
        log_performance "env_perception" "$start_time" "$end_time" "50" "true"
        echo "$cached_data"
        return 0
    fi

    # 缓存未命中，执行实际感知（精简版）
    local result=$(quick_env_scan)
    write_cache "$cache_key" "$result"

    local end_time=$(date +%s)
    log_performance "env_perception" "$start_time" "$end_time" "500" "false"

    echo "$result"
}

# 快速环境扫描（精简版）
quick_env_scan() {
    cat << EOF
{
  "quick_env_scan": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "project_type": "$(detect_project_type)",
    "has_git": $(git rev-parse --git-dir >/dev/null 2>&1 && echo "true" || echo "false"),
    "has_package_json": $([ -f "package.json" ] && echo "true" || echo "false"),
    "has_requirements_txt": $([ -f "requirements.txt" ] || [ -f "pyproject.toml" ] && echo "true" || echo "false"),
    "working_directory": "$PWD"
  }
}
EOF
}

# 快速项目类型检测
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "javascript"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "golang"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

# 智能缓存的意图分析
cached_intent_analysis() {
    local user_input="$1"
    local cache_key=$(get_cache_key "intent_analysis" "$user_input")
    local start_time=$(date +%s)

    # 对于简单意图，直接使用缓存
    if read_cache "$cache_key" >/dev/null 2>&1; then
        # 缓存命中：读取并输出缓存内容
        local cached_data=$(read_cache "$cache_key")
        local end_time=$(date +%s)
        log_performance "intent_analysis" "$start_time" "$end_time" "30" "true"
        echo "$cached_data"
        return 0
    fi

    # 执行简化的意图分析
    local result=$(quick_intent_analysis "$user_input")
    write_cache "$cache_key" "$result"

    local end_time=$(date +%s)
    log_performance "intent_analysis" "$start_time" "$end_time" "150" "false"

    echo "$result"
}

# 快速意图分析（精简版）
quick_intent_analysis() {
    local user_input="$1"

    # 简单的意图识别规则
    local intent_type="unknown"
    local confidence=0

    if echo "$user_input" | grep -qiE "(创建|开发|构建|搭建|做一个)"; then
        intent_type="project_creation"
        confidence=90
    elif echo "$user_input" | grep -qiE "(优化|改进|重构|质量|检查)"; then
        intent_type="code_optimization"
        confidence=85
    elif echo "$user_input" | grep -qiE "(分析|评估|诊断|状态)"; then
        intent_type="project_analysis"
        confidence=80
    elif echo "$user_input" | grep -qiE "(提交|推送|push)"; then
        intent_type="git_operation"
        confidence=95
    fi

    cat << EOF
{
  "quick_intent_analysis": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
}

# 初始化
init_cache