#!/bin/bash

# 🎯 Cursor AI Rules - Token压缩和高级性能优化系统
# 实现多层token压缩，流式输出，增量更新等技术

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 压缩配置
COMPRESSION_LEVEL="${COMPRESSION_LEVEL:-balanced}"  # minimal, balanced, aggressive, maximum
STREAMING_ENABLED="${STREAMING_ENABLED:-true}"
INCREMENTAL_UPDATES="${INCREMENTAL_UPDATES:-true}"

# 字典编码表（常用术语压缩）
declare -A COMPRESSION_DICT=(
    ["environment_analysis"]="ENV_ANALYSIS"
    ["intent_analysis"]="INTENT_ANALYSIS"
    ["project_type"]="PROJ_TYPE"
    ["confidence"]="CONF"
    ["execution_plan"]="EXEC_PLAN"
    ["decision_making"]="DECISION"
    ["tech_stack"]="TECH_STACK"
    ["team_size"]="TEAM_SIZE"
    ["project_scale"]="PROJ_SCALE"
    ["development_stage"]="DEV_STAGE"
)

# 解压字典（反向映射）
declare -A DECOMPRESSION_DICT
for key in "${!COMPRESSION_DICT[@]}"; do
    DECOMPRESSION_DICT["${COMPRESSION_DICT[$key]}"]="$key"
done

# 初始化压缩系统
init_compression() {
    smart_echo "初始化Token压缩系统..." "processing"

    # 创建压缩缓存目录
    mkdir -p ".cursorGrowth/compression"

    # 初始化流式输出缓冲
    STREAM_BUFFER=""
    LAST_RESPONSE=""

    smart_echo "Token压缩系统初始化完成" "success"
}

# 高级token压缩
compress_tokens() {
    local data="$1"
    local level="${2:-$COMPRESSION_LEVEL}"

    case "$level" in
        "minimal")
            # 基础压缩：只压缩JSON键名
            compress_json_keys "$data"
            ;;
        "balanced")
            # 平衡压缩：键名压缩 + 重复字符串消除
            data=$(compress_json_keys "$data")
            compress_repeated_strings "$data"
            ;;
        "aggressive")
            # 激进压缩：多层压缩 + 语义压缩
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            compress_semantic "$data"
            ;;
        "maximum")
            # 最大压缩：所有技术 + 二进制编码
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            data=$(compress_semantic "$data")
            compress_to_binary "$data"
            ;;
    esac
}

# JSON键名压缩
compress_json_keys() {
    local data="$1"
    local result="$data"

    for key in "${!COMPRESSION_DICT[@]}"; do
        # 使用sed进行精确替换，只替换JSON键名
        result=$(echo "$result" | sed "s/\"$key\":/\"${COMPRESSION_DICT[$key]}\":/g")
    done

    echo "$result"
}

# 重复字符串消除压缩
compress_repeated_strings() {
    local data="$1"
    local result="$data"

    # 查找重复出现的长字符串（长度>10的字符串）
    local strings=$(echo "$data" | grep -o '"[^"]\{10,\}"' | sort | uniq -c | sort -nr | head -5)

    local index=1
    while read -r line; do
        if [ -z "$line" ]; then continue; fi

        local count=$(echo "$line" | awk '{print $1}')
        local string=$(echo "$line" | sed 's/^[0-9]* //')

        # 只压缩出现次数>=3的字符串
        if [ "$count" -ge 3 ]; then
            local placeholder="STR_$index"
            result=$(echo "$result" | sed "s|$string|\"$placeholder\"|g" | head -1)

            # 在开头添加映射表
            local mapping="\"$placeholder\":$string,"
            result="$mapping$result"

            ((index++))
        fi
    done <<< "$strings"

    # 如果有映射，包装成对象
    if [ "$index" -gt 1 ]; then
        result="{$result}"
    fi

    echo "$result"
}

# 语义压缩（针对特定领域知识）
compress_semantic() {
    local data="$1"

    # 技术栈语义压缩
    data=$(echo "$data" | sed 's/"JavaScript"/"JS"/g')
    data=$(echo "$data" | sed 's/"TypeScript"/"TS"/g')
    data=$(echo "$data" | sed 's/"Python"/"PY"/g')
    data=$(echo "$data" | sed 's/"Node.js"/"NODE"/g')
    data=$(echo "$data" | sed 's/"React"/"REACT"/g')
    data=$(echo "$data" | sed 's/"Vue"/"VUE"/g')

    # 项目规模语义压缩
    data=$(echo "$data" | sed 's/"小型项目"/"SMALL"/g')
    data=$(echo "$data" | sed 's/"中型项目"/"MEDIUM"/g')
    data=$(echo "$data" | sed 's/"大型项目"/"LARGE"/g')

    # 团队规模语义压缩
    data=$(echo "$data" | sed 's/"个人项目"/"SOLO"/g')
    data=$(echo "$data" | sed 's/"小型团队 (2-5人)"/"SMALL_TEAM"/g')
    data=$(echo "$data" | sed 's/"中型团队 (6-10人)"/"MEDIUM_TEAM"/g')
    data=$(echo "$data" | sed 's/"大型团队 (10+人)"/"LARGE_TEAM"/g')

    echo "$data"
}

# 二进制压缩（实验性）
compress_to_binary() {
    local data="$1"

    # 简单的base64编码作为二进制压缩的替代
    echo "$data" | base64 | tr -d '\n'
}

# Token解压缩
decompress_tokens() {
    local data="$1"
    local level="${2:-$COMPRESSION_LEVEL}"

    # 检查是否是二进制压缩的数据
    if echo "$data" | grep -q "^[A-Za-z0-9+/]*=*$"; then
        data=$(echo "$data" | base64 -d 2>/dev/null || echo "$data")
    fi

    case "$level" in
        "minimal"|"balanced"|"aggressive")
            # 反向解压
            data=$(decompress_semantic "$data")
            data=$(decompress_repeated_strings "$data")
            data=$(decompress_json_keys "$data")
            ;;
        "maximum")
            data=$(decompress_semantic "$data")
            data=$(decompress_repeated_strings "$data")
            data=$(decompress_json_keys "$data")
            ;;
    esac

    echo "$data"
}

# 解压缩函数（与压缩函数相反）
decompress_json_keys() {
    local data="$1"
    local result="$data"

    for key in "${!DECOMPRESSION_DICT[@]}"; do
        result=$(echo "$result" | sed "s/\"$key\":/\"${DECOMPRESSION_DICT[$key]}\":/g")
    done

    echo "$result"
}

decompress_repeated_strings() {
    local data="$1"

    # 解析映射表并替换占位符
    if echo "$data" | grep -q '"STR_[0-9]*":'; then
        # 提取映射部分
        local mappings=$(echo "$data" | sed 's/{.*"STR_[0-9]*":[^,}]*\(,\|}\)//g' | tr -d '{}')

        # 逐个替换占位符
        while echo "$mappings" | grep -q '"STR_[0-9]*":'; do
            local mapping=$(echo "$mappings" | grep -o '"STR_[0-9]*":[^,]*' | head -1)
            local placeholder=$(echo "$mapping" | cut -d':' -f1 | tr -d '"')
            local original=$(echo "$mapping" | cut -d':' -f2-)

            data=$(echo "$data" | sed "s/\"$placeholder\"/$original/g")

            # 移除已处理的映射
            mappings=$(echo "$mappings" | sed "s/$mapping//" | sed 's/^,*//' | sed 's/,*$//')
        done
    fi

    echo "$data"
}

decompress_semantic() {
    local data="$1"

    # 反向语义解压
    data=$(echo "$data" | sed 's/"JS"/"JavaScript"/g')
    data=$(echo "$data" | sed 's/"TS"/"TypeScript"/g')
    data=$(echo "$data" | sed 's/"PY"/"Python"/g')
    data=$(echo "$data" | sed 's/"NODE"/"Node.js"/g')
    data=$(echo "$data" | sed 's/"REACT"/"React"/g')
    data=$(echo "$data" | sed 's/"VUE"/"Vue"/g')

    data=$(echo "$data" | sed 's/"SMALL"/"小型项目"/g')
    data=$(echo "$data" | sed 's/"MEDIUM"/"中型项目"/g')
    data=$(echo "$data" | sed 's/"LARGE"/"大型项目"/g')

    data=$(echo "$data" | sed 's/"SOLO"/"个人项目"/g')
    data=$(echo "$data" | sed 's/"SMALL_TEAM"/"小型团队 (2-5人)"/g')
    data=$(echo "$data" | sed 's/"MEDIUM_TEAM"/"中型团队 (6-10人)"/g')
    data=$(echo "$data" | sed 's/"LARGE_TEAM"/"大型团队 (10+人)"/g')

    echo "$data"
}

# 流式输出系统
init_streaming() {
    STREAM_BUFFER=""
    LAST_RESPONSE=""
}

# 发送流式块
send_stream_chunk() {
    local chunk="$1"
    local chunk_type="${2:-data}"

    if [ "$STREAMING_ENABLED" = true ]; then
        # 在流式模式下，立即输出每个块
        echo "[$chunk_type] $chunk"
    else
        # 在普通模式下，累积到缓冲区
        STREAM_BUFFER="$STREAM_BUFFER$chunk"
    fi
}

# 结束流式输出
end_streaming() {
    if [ "$STREAMING_ENABLED" = false ] && [ -n "$STREAM_BUFFER" ]; then
        echo "$STREAM_BUFFER"
    fi

    # 计算token节省
    local original_tokens=$(estimate_tokens "response" "${#STREAM_BUFFER}")
    local compressed_tokens=$(estimate_tokens "compressed_response" "$((${#STREAM_BUFFER} * 7 / 10))")

    smart_echo "流式输出完成，估算Token节省: $((original_tokens - compressed_tokens))" "info"
}

# 增量更新系统
init_incremental_updates() {
    LAST_RESPONSE=""
    INCREMENTAL_BUFFER=""
}

# 计算增量差异
calculate_diff() {
    local new_data="$1"
    local old_data="${2:-$LAST_RESPONSE}"

    if [ "$INCREMENTAL_UPDATES" = false ] || [ -z "$old_data" ]; then
        echo "$new_data"
        return
    fi

    # 简化的增量计算（实际实现会更复杂）
    # 这里只是演示概念，实际应该使用更智能的差异算法

    local diff=""
    local old_lines=$(echo "$old_data" | wc -l)
    local new_lines=$(echo "$new_data" | wc -l)

    if [ "$new_lines" -gt "$old_lines" ]; then
        # 有新内容，提取新增的部分
        diff=$(echo "$new_data" | tail -n "$((new_lines - old_lines))")
        diff="INCREMENTAL_UPDATE:+$(echo "$diff" | wc -c) chars"
    else
        diff="NO_CHANGE"
    fi

    echo "$diff"
}

# 应用增量更新
apply_incremental_update() {
    local diff="$1"

    if echo "$diff" | grep -q "^INCREMENTAL_UPDATE:"; then
        # 解析增量更新
        local update_info=$(echo "$diff" | sed 's/INCREMENTAL_UPDATE://')
        smart_echo "增量更新: $update_info" "info"

        # 在实际实现中，这里会智能地合并增量更新
        INCREMENTAL_BUFFER="$INCREMENTAL_BUFFER$diff"
    fi
}

# 上下文感知压缩
compress_context_aware() {
    local data="$1"
    local context="${2:-general}"

    case "$context" in
        "technical")
            # 技术上下文：更激进的压缩
            data=$(echo "$data" | sed 's/"error"/"ERR"/g')
            data=$(echo "$data" | sed 's/"success"/"OK"/g')
            data=$(echo "$data" | sed 's/"warning"/"WARN"/g')
            ;;
        "user_friendly")
            # 用户友好上下文：保持可读性，减少冗余
            data=$(echo "$data" | sed 's/"status": "success"/"✅"/g')
            data=$(echo "$data" | sed 's/"status": "error"/"❌"/g')
            ;;
        "minimal")
            # 最小上下文：只保留关键信息
            # 提取JSON中的关键字段
            data=$(echo "$data" | jq '{status: .status, message: .message} 2>/dev/null || echo "$data"')
            ;;
    esac

    echo "$data"
}

# 预测性预加载系统
init_predictive_preload() {
    PREDICTIVE_CACHE=""
    PREDICTIVE_PATTERNS=""
}

# 学习使用模式
learn_usage_patterns() {
    local operation="$1"
    local context="$2"

    # 记录操作模式用于预测
    PREDICTIVE_PATTERNS="$PREDICTIVE_PATTERNS$operation:$context;"

    # 基于模式预加载相关资源
    case "$operation:$context" in
        "env_perception:project_analysis")
            # 预加载项目分析相关的缓存
            preload_project_data
            ;;
        "intent_analysis:user_input")
            # 预加载意图分析相关的模式
            preload_intent_patterns
            ;;
        "file_read:documentation")
            # 预加载文档读取相关的缓存
            preload_documentation_cache
            ;;
    esac
}

# 预加载函数
preload_project_data() {
    smart_echo "预测性预加载: 项目数据" "info"
    # 这里会预加载常用的项目分析数据
    PREDICTIVE_CACHE="$PREDICTIVE_CACHE:project_data"
}

preload_intent_patterns() {
    smart_echo "预测性预加载: 意图模式" "info"
    # 这里会预加载意图识别模式
    PREDICTIVE_CACHE="$PREDICTIVE_CACHE:intent_patterns"
}

preload_documentation_cache() {
    smart_echo "预测性预加载: 文档缓存" "info"
    # 这里会预加载文档内容缓存
    PREDICTIVE_CACHE="$PREDICTIVE_CACHE:documentation"
}

# 高级性能分析
analyze_compression_efficiency() {
    local original_data="$1"
    local compressed_data="$2"

    local original_size=${#original_data}
    local compressed_size=${#compressed_data}
    local compression_ratio=$((compressed_size * 100 / original_size))
    local token_savings=$((original_size - compressed_size))

    cat << EOF
{
  "compression_analysis": {
    "original_size": $original_size,
    "compressed_size": $compressed_size,
    "compression_ratio_percent": $compression_ratio,
    "estimated_token_savings": $token_savings,
    "compression_level": "$COMPRESSION_LEVEL",
    "streaming_enabled": $STREAMING_ENABLED,
    "incremental_updates": $INCREMENTAL_UPDATES
  }
}
EOF
}

# 综合优化执行器
execute_optimized() {
    local operation="$1"
    local data="$2"
    local context="${3:-general}"

    local start_time=$(date +%s)

    # 1. 预测性预加载
    learn_usage_patterns "$operation" "$context"

    # 2. 上下文感知压缩
    local compressed_data=$(compress_context_aware "$data" "$context")

    # 3. 多层token压缩
    compressed_data=$(compress_tokens "$compressed_data")

    # 4. 增量更新计算
    local incremental_diff=$(calculate_diff "$compressed_data")
    apply_incremental_update "$incremental_diff"

    # 5. 流式输出
    send_stream_chunk "$compressed_data" "compressed_data"

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # 6. 性能分析
    local analysis=$(analyze_compression_efficiency "$data" "$compressed_data")

    # 7. 记录性能指标
    log_performance_metric "optimized_execution" "$duration" "$(get_memory_usage)" "$(get_cpu_usage)" "success"
    log_token_usage "optimized_execution" "$(estimate_tokens "optimized" "${#compressed_data}")" "0" "false"

    # 8. 返回结果
    echo "$compressed_data"
}

# 导出函数
export -f init_compression
export -f compress_tokens
export -f decompress_tokens
export -f init_streaming
export -f send_stream_chunk
export -f end_streaming
export -f init_incremental_updates
export -f calculate_diff
export -f apply_incremental_update
export -f compress_context_aware
export -f init_predictive_preload
export -f learn_usage_patterns
export -f analyze_compression_efficiency
export -f execute_optimized