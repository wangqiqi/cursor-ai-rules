#!/bin/bash

# 🎯 Cursor AI Rules - Token压缩和高级性能优化系统
# 实现多层token压缩，流式输出，增量更新等技术

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 加载token优化配置（如果存在）
if [ -f "$SCRIPT_DIR/../config/token-optimization.env" ]; then
    source "$SCRIPT_DIR/../config/token-optimization.env"
fi

# 压缩配置 - 优化为节省token
COMPRESSION_LEVEL="${COMPRESSION_LEVEL:-minimal}"  # minimal, balanced, aggressive, maximum
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
    mkdir -p "$CONFIG_DATA_DIR"

    # 初始化数据模式文件
    [[ ! -f "$SCRIPT_DIR/patterns.json" ]] && echo "{}" > "$SCRIPT_DIR/patterns.json"
    [[ ! -f "$CONFIG_DATA_DIR/config-compression-strategies.json" ]] && echo "{}" > "$CONFIG_DATA_DIR/config-compression-strategies.json"

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
            # 基础压缩：只压缩JSON键名 + 移除装饰性字符
            data=$(compress_json_keys "$data")
            data=$(remove_decorative_chars "$data")
            ;;
        "balanced")
            # 平衡压缩：键名压缩 + 重复字符串消除 + 装饰字符移除
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            data=$(remove_decorative_chars "$data")
            ;;
        "aggressive")
            # 激进压缩：多层压缩 + 语义压缩 + 流式优化
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            data=$(compress_semantic "$data")
            data=$(remove_decorative_chars "$data")
            ;;
        "maximum")
            # 最大压缩：所有技术 + 二进制编码 + 流式传输
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            data=$(compress_semantic "$data")
            data=$(compress_to_binary "$data")
            data=$(remove_decorative_chars "$data")
            ;;
    esac

    echo "$data"
}

# 移除装饰性字符（节省token）
remove_decorative_chars() {
    local data="$1"

    # 移除emoji和装饰性符号
    data=$(echo "$data" | sed 's/[🎯✨🚀💡📚🎭🔧⚡🎨🏗️📁✅❌⚠️🔄📊🎯]//g')

    # 移除多余的换行符和空格
    data=$(echo "$data" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/\n\n\n*/\n\n/g')

    # 移除重复的标点符号
    data=$(echo "$data" | sed 's/!!!*/!/g; s/???*/?/g; s/,,*/,/g')

    echo "$data"
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

# 🎯 智能自适应压缩系统
# 基于内容特征和使用模式自动选择最佳压缩策略

# 智能压缩分析器
intelligent_compression_analyzer() {
    local data="$1"
    local operation="${2:-general}"
    local max_tokens="${3:-4096}"

    smart_echo "启动智能压缩分析..." "processing"

    # 1. 分析数据特征
    local data_features=$(analyze_data_features "$data")

    # 2. 评估压缩潜力
    local compression_potential=$(evaluate_compression_potential "$data_features")

    # 3. 选择最优压缩策略
    local optimal_strategy=$(select_optimal_strategy "$compression_potential" "$operation" "$max_tokens")

    # 4. 应用智能压缩
    local compressed_data=$(apply_intelligent_compression "$data" "$optimal_strategy")

    # 5. 验证压缩效果
    local compression_stats=$(validate_compression_effectiveness "$data" "$compressed_data")

    smart_echo "智能压缩分析完成 - 节省: $(echo "$compression_stats" | jq -r '.token_savings // 0') tokens" "success"

    # 返回压缩后的数据和统计信息
    cat <<EOF
{
  "compressed_data": $compressed_data,
  "compression_stats": $compression_stats,
  "strategy_used": "$optimal_strategy"
}
EOF
}

# 分析数据特征
analyze_data_features() {
    local data="$1"

    # 计算各种特征指标
    local data_size=${#data}
    local json_keys=$(echo "$data" | jq 'keys | length' 2>/dev/null || echo "0")
    local repeated_patterns=$(detect_repeated_patterns "$data")
    local semantic_density=$(calculate_semantic_density "$data")
    local structural_complexity=$(assess_structural_complexity "$data")

    cat <<EOF
{
  "data_size": $data_size,
  "json_keys": $json_keys,
  "repeated_patterns": $repeated_patterns,
  "semantic_density": $semantic_density,
  "structural_complexity": $structural_complexity,
  "data_type": "$(detect_data_type "$data")"
}
EOF
}

# 检测重复模式
detect_repeated_patterns() {
    local data="$1"
    local repeated_count=$(echo "$data" | grep -o '"[^"]*"' | sort | uniq -c | awk '$1 > 1 {count++} END {print count+0}')
    echo "$repeated_count"
}

# 计算语义密度
calculate_semantic_density() {
    local data="$1"
    local total_chars=${#data}
    local meaningful_chars=$(echo "$data" | sed 's/[[:space:]]//g' | sed 's/["{},:]//g' | wc -c)

    if (( total_chars > 0 )); then
        echo "scale=2; $meaningful_chars / $total_chars" | bc 2>/dev/null || echo "0.5"
    else
        echo "0"
    fi
}

# 评估结构复杂度
assess_structural_complexity() {
    local data="$1"
    local nesting_level=$(echo "$data" | jq '[paths | length] | max' 2>/dev/null || echo "1")
    local branch_count=$(echo "$data" | jq 'walk(if type == "object" then keys else . end) | flatten | length' 2>/dev/null || echo "1")
    echo "scale=2; $nesting_level * 0.3 + $branch_count * 0.1" | bc 2>/dev/null || echo "1.0"
}

# 检测数据类型
detect_data_type() {
    local data="$1"
    if echo "$data" | jq empty 2>/dev/null; then
        echo "json"
    elif echo "$data" | grep -q "^import\|^export\|^function\|^class"; then
        echo "code"
    elif echo "$data" | grep -q "^#\|^[[:space:]]*//\|^/\*"; then
        echo "documentation"
    else
        echo "text"
    fi
}

# 评估压缩潜力
evaluate_compression_potential() {
    local features="$1"
    local data_size=$(echo "$features" | jq -r '.data_size // 0')
    local repeated_patterns=$(echo "$features" | jq -r '.repeated_patterns // 0')
    local semantic_density=$(echo "$features" | jq -r '.semantic_density // 0.5')
    local structural_complexity=$(echo "$features" | jq -r '.structural_complexity // 1.0')

    local dict_compression_potential=$(echo "scale=2; $repeated_patterns * 0.15" | bc 2>/dev/null || echo "0")
    local semantic_compression_potential=$(echo "scale=2; (1 - $semantic_density) * 0.25" | bc 2>/dev/null || echo "0")
    local structural_compression_potential=$(echo "scale=2; $structural_complexity * 0.1" | bc 2>/dev/null || echo "0")

    cat <<EOF
{
  "overall_potential": $(echo "scale=2; $dict_compression_potential + $semantic_compression_potential + $structural_compression_potential" | bc 2>/dev/null || echo "0"),
  "dict_compression": $dict_compression_potential,
  "semantic_compression": $semantic_compression_potential,
  "structural_compression": $structural_compression_potential,
  "recommended_strategy": "$(select_recommended_strategy "$dict_compression_potential" "$semantic_compression_potential" "$structural_compression_potential")"
}
EOF
}

# 选择推荐策略
select_recommended_strategy() {
    local dict="$1"
    local semantic="$2"
    local structural="$3"

    if (( $(echo "$dict > 0.3" | bc -l 2>/dev/null || echo "0") )); then
        echo "balanced"
    elif (( $(echo "$semantic > 0.2" | bc -l 2>/dev/null || echo "0") )); then
        echo "aggressive"
    elif (( $(echo "$structural > 1.5" | bc -l 2>/dev/null || echo "0") )); then
        echo "minimal"
    else
        echo "balanced"
    fi
}

# 选择最优压缩策略
select_optimal_strategy() {
    local compression_potential="$1"
    local operation="$2"
    local max_tokens="$3"

    local recommended=$(echo "$compression_potential" | jq -r '.recommended_strategy // "balanced"')

    case "$operation" in
        "code_review"|"debugging")
            echo "minimal"
            ;;
        "documentation"|"learning")
            echo "aggressive"
            ;;
        "automation"|"batch_processing")
            echo "maximum"
            ;;
        *)
            echo "$recommended"
            ;;
    esac
}

# 应用智能压缩
apply_intelligent_compression() {
    local data="$1"
    local strategy="$2"

    case "$strategy" in
        "minimal")
            compress_json_keys "$data"
            ;;
        "balanced")
            data=$(compress_json_keys "$data")
            compress_repeated_strings "$data"
            ;;
        "aggressive")
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            compress_semantic "$data"
            ;;
        "maximum")
            data=$(compress_json_keys "$data")
            data=$(compress_repeated_strings "$data")
            data=$(compress_semantic "$data")
            compress_to_binary "$data"
            ;;
        *)
            echo "$data"
            ;;
    esac
}

# 验证压缩效果
validate_compression_effectiveness() {
    local original="$1"
    local compressed="$2"

    local original_tokens=$(estimate_tokens "original" "${#original}")
    local compressed_tokens=$(estimate_tokens "compressed" "${#compressed}")
    local token_savings=$((original_tokens - compressed_tokens))
    local compression_ratio

    if (( original_tokens > 0 )); then
        compression_ratio=$(echo "scale=2; $compressed_tokens / $original_tokens" | bc 2>/dev/null || echo "1.00")
    else
        compression_ratio="1.00"
    fi

    cat <<EOF
{
  "original_tokens": $original_tokens,
  "compressed_tokens": $compressed_tokens,
  "token_savings": $token_savings,
  "compression_ratio": $compression_ratio,
  "effectiveness": "$(calculate_compression_effectiveness "$token_savings" "$original_tokens")"
}
EOF
}

# 计算压缩效果等级
calculate_compression_effectiveness() {
    local savings="$1"
    local original="$2"

    if (( original == 0 )); then
        echo "neutral"
        return
    fi

    local ratio=$(echo "scale=2; $savings / $original" | bc 2>/dev/null || echo "0")

    if (( $(echo "$ratio >= 0.7" | bc -l 2>/dev/null || echo "0") )); then
        echo "excellent"
    elif (( $(echo "$ratio >= 0.5" | bc -l 2>/dev/null || echo "0") )); then
        echo "good"
    elif (( $(echo "$ratio >= 0.3" | bc -l 2>/dev/null || echo "0") )); then
        echo "fair"
    elif (( $(echo "$ratio >= 0.1" | bc -l 2>/dev/null || echo "0") )); then
        echo "poor"
    else
        echo "minimal"
    fi
}

# 🎯 自适应压缩学习系统
adaptive_compression_learning() {
    local operation="$1"
    local original_data="$2"
    local compressed_data="$3"
    local user_feedback="${4:-neutral}"

    local stats=$(validate_compression_effectiveness "$original_data" "$compressed_data")
    local effectiveness=$(echo "$stats" | jq -r '.effectiveness')

    update_compression_strategy "$operation" "$effectiveness" "$user_feedback"
    learn_data_patterns "$original_data" "$operation"

    smart_echo "自适应压缩学习完成 - 效果: $effectiveness" "info"
}

# 更新压缩策略
update_compression_strategy() {
    local operation="$1"
    local effectiveness="$2"
    local feedback="$3"

    local strategy_file="$SCRIPT_DIR/compression_strategies.json"

    local strategies="{}"
    [[ -f "$strategy_file" ]] && strategies=$(cat "$strategy_file")

    local current_preference=$(echo "$strategies" | jq -r ".operations.\"$operation\".preferred_strategy // \"balanced\"")
    local new_preference="$current_preference"

    case "$feedback:$effectiveness" in
        "positive:excellent"|"positive:good")
            ;;
        "positive:fair"|"positive:poor")
            new_preference=$(get_more_aggressive_strategy "$current_preference")
            ;;
        "negative:excellent"|"negative:good")
            new_preference=$(get_more_conservative_strategy "$current_preference")
            ;;
        "negative:fair"|"negative:poor")
            new_preference=$(get_more_conservative_strategy "$current_preference")
            ;;
    esac

    strategies=$(echo "$strategies" | jq --arg op "$operation" --arg strategy "$new_preference" '.operations[$op].preferred_strategy = $strategy')
    echo "$strategies" > "$strategy_file"
}

# 获取更激进的策略
get_more_aggressive_strategy() {
    local current="$1"
    case "$current" in
        "minimal") echo "balanced" ;;
        "balanced") echo "aggressive" ;;
        "aggressive") echo "maximum" ;;
        *) echo "$current" ;;
    esac
}

# 获取更保守的策略
get_more_conservative_strategy() {
    local current="$1"
    case "$current" in
        "maximum") echo "aggressive" ;;
        "aggressive") echo "balanced" ;;
        "balanced") echo "minimal" ;;
        *) echo "$current" ;;
    esac
}

# 学习数据模式
learn_data_patterns() {
    local data="$1"
    local operation="$2"

    local patterns_file="$SCRIPT_DIR/patterns.json"
    local features=$(analyze_data_features "$data")

    local patterns="{}"
    [[ -f "$patterns_file" ]] && patterns=$(cat "$patterns_file")

    patterns=$(echo "$patterns" | jq --arg op "$operation" --argjson features "$features" '.operations[$op].patterns += [$features]')
    echo "$patterns" > "$patterns_file"
}

# 导出新函数
export -f intelligent_compression_analyzer
export -f adaptive_compression_learning

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

# 流式输出函数
stream_output() {
    local content="$1"
    local chunk_size="${2:-1000}"

    if [ "$STREAMING_ENABLED" = true ]; then
        # 分块输出，避免一次性发送大量内容
        local content_length=${#content}
        local offset=0

        while [ $offset -lt $content_length ]; do
            local chunk="${content:$offset:$chunk_size}"
            echo "$chunk"
            offset=$((offset + chunk_size))

            # 小延迟以支持真正的流式处理
            if [ "$INCREMENTAL_UPDATES" = true ]; then
                sleep 0.01
            fi
        done
    else
        # 非流式模式，直接输出
        echo "$content"
    fi
}

# 增量响应生成器
generate_incremental_response() {
    local base_response="$1"
    local context="$2"

    # 压缩基础响应
    local compressed_response
    compressed_response=$(compress_tokens "$base_response")

    # 添加增量更新标记
    if [ "$INCREMENTAL_UPDATES" = true ]; then
        compressed_response="INCREMENTAL_START\n$compressed_response\nINCREMENTAL_END"
    fi

    # 使用流式输出
    stream_output "$compressed_response"
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
export -f stream_output
export -f generate_incremental_response

# 如果直接执行此脚本，显示帮助信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🎯 Cursor AI Rules - Token压缩系统"
    echo ""
    echo "用法: $0 [command]"
    echo ""
    echo "命令:"
    echo "  init     初始化缓存系统"
    echo "  cleanup  清理过期缓存"
    echo "  stats    显示缓存统计"
    echo "  clear    清空缓存"
    echo "  health   健康检查"
    echo "  stream   测试流式输出"
    echo "  help     显示此帮助信息"
    echo ""

    case "${1:-help}" in
        "init")
            init_compression
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
        "stream")
            # 测试流式输出
            echo "测试流式输出功能..." >&2
            generate_incremental_response "这是一个测试响应，用于验证流式输出功能是否正常工作。"
            ;;
        "help"|*)
            exit 0
            ;;
    esac
fi