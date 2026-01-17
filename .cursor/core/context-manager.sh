#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置


# 🎯 Cursor AI Rules - 智能上下文管理系统
# 实现分层加载、相关性评分、预测性预加载等高级上下文管理技术

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/token-compression.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 上下文配置
CONTEXT_CACHE_DIR="$AI_DIR"
CONTEXT_DEPENDENCY_FILE="$CONTEXT_CACHE_DIR/dependencies.json"
CONTEXT_RELEVANCE_FILE="$CONTEXT_CACHE_DIR/relevance.json"
CONTEXT_PREDICTION_FILE="$CONTEXT_CACHE_DIR/predictions.json"

# 上下文层级定义
declare -A CONTEXT_LAYERS=(
    ["critical"]="100"      # 核心上下文，必须加载
    ["important"]="75"      # 重要上下文，优先加载
    ["useful"]="50"         # 有用上下文，按需加载
    ["optional"]="25"       # 可选上下文，低优先级
)

# 初始化上下文管理系统
init_context_manager() {
    smart_echo "初始化智能上下文管理系统..." "processing"

    # 创建必要的目录结构
    mkdir -p "$CONTEXT_CACHE_DIR"
    mkdir -p "$AI_DIR"  # 创建AI目录
    mkdir -p "$CONFIG_DATA_DIR"

    # 初始化上下文数据文件
    [[ ! -f "$CONTEXT_DEPENDENCY_FILE" ]] && echo "{}" > "$CONTEXT_DEPENDENCY_FILE"
    [[ ! -f "$CONTEXT_RELEVANCE_FILE" ]] && echo "{}" > "$CONTEXT_RELEVANCE_FILE"
    [[ ! -f "$CONTEXT_PREDICTION_FILE" ]] && echo "{}" > "$CONTEXT_PREDICTION_FILE"

    # 初始化其他必要文件
    [[ ! -f "$AI_DIR/ai-patterns.json" ]] && echo "[]" > "$AI_DIR/ai-patterns.json"
    [[ ! -f "$CONFIG_DATA_DIR/config-user-profile.json" ]] && echo "{}" > "$CONFIG_DATA_DIR/config-user-profile.json"

    smart_echo "智能上下文管理系统初始化完成" "success"
}

# 🎯 上下文分层加载机制
# 按优先级分层加载上下文，避免超出token限制

load_context_hierarchically() {
    local operation="$1"
    local max_tokens="${2:-4096}"
    local context_level="${3:-balanced}"

    smart_echo "开始分层上下文加载 (操作: $operation, 最大token: $max_tokens)..." "processing"

    # 1. 确定上下文层级配置
    local layer_config
    case "$context_level" in
        "minimal")  layer_config=("critical") ;;
        "balanced") layer_config=("critical" "important") ;;
        "comprehensive") layer_config=("critical" "important" "useful") ;;
        "maximum") layer_config=("critical" "important" "useful" "optional") ;;
        *) layer_config=("critical" "important") ;;
    esac

    # 2. 按层级加载上下文
    local loaded_context=""
    local total_tokens=0

    for layer in "${layer_config[@]}"; do
        smart_echo "加载${layer}层上下文..." "info"

        # 获取该层级的上下文
        local layer_context=$(get_layer_context "$operation" "$layer")

        if [[ -n "$layer_context" ]]; then
            # 估算token消耗
            local layer_tokens=$(estimate_tokens "layer_context" "${#layer_context}")

            # 检查是否超出限制
            if (( total_tokens + layer_tokens > max_tokens )); then
                smart_echo "${layer}层上下文超出token限制，跳过" "warning"
                break
            fi

            # 合并上下文
            loaded_context="${loaded_context}${layer_context}"
            ((total_tokens += layer_tokens))

            smart_echo "${layer}层上下文加载完成 (${layer_tokens} tokens)" "success"
        fi
    done

    # 3. 应用token压缩优化
    local optimized_context=$(compress_context_aware "$loaded_context" "technical")

    smart_echo "上下文分层加载完成 (总token: $total_tokens)" "success"
    echo "$optimized_context"
}

# 获取指定层级的上下文
get_layer_context() {
    local operation="$1"
    local layer="$2"

    case "$layer" in
        "critical")
            # 核心上下文：项目基本信息、当前操作必需的数据
            get_critical_context "$operation"
            ;;
        "important")
            # 重要上下文：相关文件、历史操作、用户偏好
            get_important_context "$operation"
            ;;
        "useful")
            # 有用上下文：扩展信息、相关文档、辅助数据
            get_useful_context "$operation"
            ;;
        "optional")
            # 可选上下文：额外信息、统计数据、扩展功能
            get_optional_context "$operation"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 🔍 上下文相关性评分系统
# 基于使用频率、时间衰减、操作相关性计算上下文重要性

calculate_context_relevance() {
    local context_key="$1"
    local operation="$2"
    local current_time="${3:-$(date +%s)}"

    # 从缓存中获取相关性数据
    local relevance_data=$(get_cached_relevance "$context_key")
    local last_used="${relevance_data[last_used]:-0}"
    local usage_count="${relevance_data[usage_count]:-0}"
    local operation_relevance="${relevance_data[operation_relevance]:-0}"

    # 计算时间衰减因子 (最近7天内使用过权重更高)
    local days_since_used=$(( (current_time - last_used) / 86400 ))
    local time_decay_factor
    if (( days_since_used <= 7 )); then
        time_decay_factor=1.0
    elif (( days_since_used <= 30 )); then
        time_decay_factor=0.7
    elif (( days_since_used <= 90 )); then
        time_decay_factor=0.4
    else
        time_decay_factor=0.1
    fi

    # 计算操作相关性 (当前操作与历史操作的相似度)
    local operation_match_score=$(calculate_operation_similarity "$operation" "${relevance_data[last_operation]}")

    # 计算综合相关性评分
    # 公式: (使用频率 * 时间衰减 + 操作相关性) / 2
    local relevance_score=$(echo "scale=3; ($usage_count * 0.1 * $time_decay_factor + $operation_match_score) / 2" | bc 2>/dev/null || echo "0.5")

    # 确保评分在0-1范围内
    if (( $(echo "$relevance_score > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        relevance_score=1.0
    fi
    if (( $(echo "$relevance_score < 0.0" | bc -l 2>/dev/null || echo "0") )); then
        relevance_score=0.0
    fi

    echo "$relevance_score"
}

# 更新上下文相关性数据
update_context_relevance() {
    local context_key="$1"
    local operation="$2"
    local current_time="${3:-$(date +%s)}"

    # 获取现有数据
    local relevance_data=$(get_cached_relevance "$context_key")

    # 更新统计信息
    local new_usage_count=$(( ${relevance_data[usage_count]:-0} + 1 ))

    # 更新缓存
    local updated_data=$(cat <<EOF
{
  "context_key": "$context_key",
  "last_used": $current_time,
  "last_operation": "$operation",
  "usage_count": $new_usage_count,
  "operation_relevance": $(calculate_operation_similarity "$operation" "${relevance_data[last_operation]:-}")
}
EOF
)

    # 缓存相关性数据
    cache_set "context_relevance:$context_key" "$updated_data" 604800  # 7天TTL
}

# 🎯 预测性上下文预加载
# 基于用户行为模式预测并预加载可能需要的上下文

predictive_context_preload() {
    local current_operation="$1"
    local max_preload_tokens="${2:-1024}"

    smart_echo "开始预测性上下文预加载..." "processing"

    # 1. 分析用户行为模式
    local behavior_patterns=$(analyze_behavior_patterns "$current_operation")

    # 2. 预测可能需要的上下文
    local predicted_contexts=$(predict_needed_contexts "$behavior_patterns" "$max_preload_tokens")

    # 3. 预加载高概率上下文
    local preloaded_count=0
    local total_tokens=0

    while IFS= read -r context_item; do
        [[ -z "$context_item" ]] && continue

        local context_key=$(echo "$context_item" | jq -r '.key // empty' 2>/dev/null)
        local context_data=$(echo "$context_item" | jq -r '.data // empty' 2>/dev/null)
        local token_cost=$(echo "$context_item" | jq -r '.tokens // 0' 2>/dev/null)

        if [[ -n "$context_key" && -n "$context_data" ]]; then
            if (( total_tokens + token_cost <= max_preload_tokens )); then
                # 预加载到缓存
                cache_set "predicted_context:$context_key" "$context_data" 300  # 5分钟TTL
                ((preloaded_count++))
                ((total_tokens += token_cost))
            fi
        fi
    done <<< "$(echo "$predicted_contexts" | jq -c '.[] // empty' 2>/dev/null)"

    smart_echo "预测性预加载完成: $preloaded_count 个上下文 ($total_tokens tokens)" "success"
}

# 📊 上下文依赖图系统
# 建立和维护上下文间的依赖关系

build_context_dependency_graph() {
    smart_echo "构建上下文依赖图..." "processing"

    # 1. 扫描项目文件，建立依赖关系
    local file_dependencies=$(scan_file_dependencies)

    # 2. 分析操作间的上下文依赖
    local operation_dependencies=$(analyze_operation_dependencies)

    # 3. 合并依赖关系
    local dependency_graph=$(merge_dependencies "$file_dependencies" "$operation_dependencies")

    # 4. 保存依赖图
    echo "$dependency_graph" > "$CONTEXT_DEPENDENCY_FILE"

    smart_echo "上下文依赖图构建完成" "success"
}

# 扫描文件依赖关系
scan_file_dependencies() {
    smart_echo "扫描文件依赖关系..." "info"

    # 查找所有代码文件
    local code_files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.java" -o -name "*.go" \) -not -path "./node_modules/*" -not -path "./.git/*" 2>/dev/null | head -100)

    local dependencies="{}"

    for file in $code_files; do
        if [[ -f "$file" ]]; then
            # 分析文件中的import/require语句
            local imports=$(grep -h "^import\|^from\|^require" "$file" 2>/dev/null || echo "")

            if [[ -n "$imports" ]]; then
                # 提取依赖文件路径
                local dep_files=$(echo "$imports" | sed 's/.*["'"'"']\(.*\)["'"'"'].*/\1/' | grep -E '\.(js|ts|jsx|tsx|py|java|go)$' | sort | uniq)

                # 构建依赖关系JSON
                for dep in $dep_files; do
                    if [[ -f "$dep" ]]; then
                        dependencies=$(echo "$dependencies" | jq --arg file "$file" --arg dep "$dep" '.dependencies[$file] += [$dep]' 2>/dev/null || echo "$dependencies")
                    fi
                done
            fi
        fi
    done

    echo "$dependencies"
}

# 🎯 核心上下文获取函数

get_critical_context() {
    local operation="$1"

    # 核心上下文：项目基本信息和当前操作必需数据
    cat <<EOF
{
  "project_info": {
    "name": "$(basename "$PWD")",
    "type": "$(detect_project_type)",
    "root": "$PWD",
    "operation": "$operation"
  },
  "current_state": {
    "timestamp": "$(date -Iseconds)",
    "git_branch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')",
    "working_directory": "$PWD"
  }
}
EOF
}

get_important_context() {
    local operation="$1"

    # 重要上下文：相关文件、历史操作、用户偏好
    cat <<EOF
{
  "relevant_files": $(get_relevant_files "$operation" | jq -R . | jq -s . 2>/dev/null || echo "[]"),
  "recent_operations": $(get_recent_operations | jq -R . | jq -s . 2>/dev/null || echo "[]"),
  "user_preferences": $(get_user_preferences 2>/dev/null || echo "{}")
}
EOF
}

get_useful_context() {
    local operation="$1"

    # 有用上下文：扩展信息、相关文档
    cat <<EOF
{
  "related_documentation": $(find_related_docs "$operation" | jq -R . | jq -s . 2>/dev/null || echo "[]"),
  "similar_operations": $(find_similar_operations "$operation" | jq -R . | jq -s . 2>/dev/null || echo "[]"),
  "context_extensions": $(get_context_extensions "$operation" 2>/dev/null || echo "{}")
}
EOF
}

get_optional_context() {
    local operation="$1"

    # 可选上下文：额外统计数据
    cat <<EOF
{
  "performance_stats": $(get_performance_stats 2>/dev/null || echo "{}"),
  "usage_patterns": $(get_usage_patterns 2>/dev/null || echo "{}"),
  "context_metadata": {
    "generated_at": "$(date -Iseconds)",
    "operation": "$operation",
    "context_version": "2.0"
  }
}
EOF
}

# 🛠️ 辅助函数

detect_project_type() {
    if [[ -f "package.json" ]]; then echo "javascript"
    elif [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then echo "python"
    elif [[ -f "Cargo.toml" ]]; then echo "rust"
    elif [[ -f "go.mod" ]]; then echo "golang"
    else echo "unknown"
    fi
}

get_relevant_files() {
    local operation="$1"
    # 简化的文件相关性判断
    find . -name "*.md" -o -name "*.json" | head -10
}

get_recent_operations() {
    # 获取最近的操作历史
    echo "recent_operation_1"
}

get_user_preferences() {
    # 获取用户偏好设置
    echo '{"output_mode": "compact", "language": "zh"}'
}

find_related_docs() {
    local operation="$1"
    find . -name "*.md" -exec grep -l "$operation" {} \; 2>/dev/null | head -5
}

find_similar_operations() {
    local operation="$1"
    echo "similar_operation_1"
}

get_context_extensions() {
    local operation="$1"
    echo '{"extensions": []}'
}

get_performance_stats() {
    echo '{"response_time": "300ms", "token_usage": "350"}'
}

get_usage_patterns() {
    echo '{"patterns": []}'
}

# 缓存相关性数据
get_cached_relevance() {
    local context_key="$1"
    cache_get "context_relevance:$context_key" || echo '{"last_used": 0, "usage_count": 0, "operation_relevance": 0}'
}

# 计算操作相似度
calculate_operation_similarity() {
    local op1="$1"
    local op2="$2"

    if [[ "$op1" == "$op2" ]]; then
        echo "1.0"
    elif [[ "$op1" == *"$op2"* || "$op2" == *"$op1"* ]]; then
        echo "0.7"
    else
        echo "0.3"
    fi
}

# 🎯 高级预测性上下文预加载系统

# 分析用户行为模式
analyze_behavior_patterns() {
    local current_operation="$1"

    smart_echo "分析用户行为模式..." "info"

    # 1. 获取历史操作数据
    local history_data=$(get_operation_history)

    # 2. 分析操作序列模式
    local sequence_patterns=$(analyze_operation_sequences "$history_data")

    # 3. 计算操作间的转移概率
    local transition_probabilities=$(calculate_transition_probabilities "$sequence_patterns")

    # 4. 识别当前操作的后续操作模式
    local next_operation_patterns=$(predict_next_operations "$current_operation" "$transition_probabilities")

    echo "$next_operation_patterns"
}

# 预测需要的上下文
predict_needed_contexts() {
    local behavior_patterns="$1"
    local max_tokens="$2"

    smart_echo "预测需要的上下文..." "info"

    # 解析行为模式
    local predicted_operations=$(echo "$behavior_patterns" | jq -r '.predicted_operations[] // empty' 2>/dev/null)

    # 为每个预测的操作生成可能需要的上下文
    local predicted_contexts="[]"

    for operation in $predicted_operations; do
        if [[ -n "$operation" ]]; then
            # 获取操作的相关上下文
            local operation_contexts=$(get_operation_contexts "$operation")

            # 合并到预测列表
            predicted_contexts=$(echo "$predicted_contexts" | jq --arg op "$operation" --argjson ctx "$operation_contexts" '. + $ctx' 2>/dev/null || echo "$predicted_contexts")
        fi
    done

    # 根据token限制筛选上下文
    local filtered_contexts=$(filter_contexts_by_tokens "$predicted_contexts" "$max_tokens")

    echo "$filtered_contexts"
}

# 🎯 高级上下文依赖图系统
# 建立和维护上下文间的复杂关联关系

# 分析操作依赖关系
analyze_operation_dependencies() {
    smart_echo "分析操作依赖关系..." "info"

    # 1. 获取操作历史
    local history_data=$(get_operation_history)

    # 2. 构建操作依赖图
    local operation_graph=$(build_operation_dependency_graph "$history_data")

    # 3. 分析操作间的语义关系
    local semantic_relations=$(analyze_semantic_relations "$history_data")

    # 4. 计算操作相关性矩阵
    local relevance_matrix=$(calculate_operation_relevance_matrix "$operation_graph" "$semantic_relations")

    cat <<EOF
{
  "operation_graph": $operation_graph,
  "semantic_relations": $semantic_relations,
  "relevance_matrix": $relevance_matrix,
  "analysis_timestamp": "$(date -Iseconds)"
}
EOF
}

# 构建操作依赖图
build_operation_dependency_graph() {
    local history_data="$1"

    # 提取操作序列和时间戳
    local operations=$(echo "$history_data" | jq -r '.operations[] | {op: .operation, time: .timestamp}' 2>/dev/null)

    # 构建时序依赖关系
    local graph="{}"

    # 按时间顺序处理操作
    while IFS= read -r operation_data; do
        [[ -z "$operation_data" ]] && continue

        local current_op=$(echo "$operation_data" | jq -r '.op // empty' 2>/dev/null)
        local current_time=$(echo "$operation_data" | jq -r '.time // 0' 2>/dev/null)

        if [[ -n "$current_op" ]]; then
            # 查找后续操作（时间相近的操作）
            local subsequent_ops=$(find_subsequent_operations "$current_op" "$current_time" "$history_data")

            # 建立依赖关系
            for subsequent_op in $subsequent_ops; do
                if [[ -n "$subsequent_op" ]]; then
                    graph=$(echo "$graph" | jq --arg from "$current_op" --arg to "$subsequent_op" '.dependencies[$from] += [$to]' 2>/dev/null || echo "$graph")
                fi
            done
        fi
    done <<< "$(echo "$operations" | jq -c '. // empty' 2>/dev/null)"

    echo "$graph"
}

# 查找后续操作
find_subsequent_operations() {
    local current_op="$1"
    local current_time="$2"
    local history_data="$3"

    # 查找当前操作之后1小时内的操作
    local time_window=$((current_time + 3600))  # 1小时窗口

    echo "$history_data" | jq -r --arg op "$current_op" --arg time "$time_window" '
        .operations[] |
        select(.timestamp > ($time | tonumber) and .operation != $op) |
        .operation
    ' 2>/dev/null || echo ""
}

# 分析语义关系
analyze_semantic_relations() {
    local history_data="$1"

    # 定义操作语义组
    local semantic_groups='{
        "code_quality": ["检查代码", "运行测试", "修复错误"],
        "version_control": ["提交代码", "推送代码", "拉取代码"],
        "project_setup": ["初始化项目", "配置环境", "安装依赖"],
        "documentation": ["生成文档", "更新说明", "编写注释"],
        "deployment": ["构建项目", "部署应用", "发布版本"]
    }'

    # 计算操作间的语义相似度
    local relations="{}"

    # 为每个操作找到语义相关的其他操作
    for group_name in $(echo "$semantic_groups" | jq -r 'keys[]' 2>/dev/null); do
        local group_ops=$(echo "$semantic_groups" | jq -r ".\"$group_name\"[]" 2>/dev/null)

        for op1 in $group_ops; do
            for op2 in $group_ops; do
                if [[ "$op1" != "$op2" ]]; then
                    relations=$(echo "$relations" | jq --arg from "$op1" --arg to "$op2" --arg group "$group_name" '.semantic[$from][$to] = $group' 2>/dev/null || echo "$relations")
                fi
            done
        done
    done

    echo "$relations"
}

# 计算操作相关性矩阵
calculate_operation_relevance_matrix() {
    local operation_graph="$1"
    local semantic_relations="$2"

    # 合并时间依赖和语义依赖
    local matrix="{}"

    # 处理时间依赖
    for from_op in $(echo "$operation_graph" | jq -r '.dependencies | keys[]' 2>/dev/null); do
        local to_ops=$(echo "$operation_graph" | jq -r ".dependencies.\"$from_op\"[]" 2>/dev/null)

        for to_op in $to_ops; do
            matrix=$(echo "$matrix" | jq --arg from "$from_op" --arg to "$to_op" '.relations[$from][$to].temporal = 0.7' 2>/dev/null || echo "$matrix")
        done
    done

    # 处理语义依赖
    for from_op in $(echo "$semantic_relations" | jq -r '.semantic | keys[]' 2>/dev/null); do
        local to_ops=$(echo "$semantic_relations" | jq -r ".semantic.\"$from_op\" | keys[]" 2>/dev/null)

        for to_op in $to_ops; do
            matrix=$(echo "$matrix" | jq --arg from "$from_op" --arg to "$to_op" '.relations[$from][$to].semantic = 0.8' 2>/dev/null || echo "$matrix")
        done
    done

    echo "$matrix"
}

# 智能上下文推荐引擎
# 基于依赖图推荐相关上下文

recommend_related_contexts() {
    local current_operation="$1"
    local available_contexts="$2"

    smart_echo "基于依赖图推荐相关上下文..." "info"

    # 1. 获取依赖图
    local dependency_graph
    if [[ -f "$CONTEXT_DEPENDENCY_FILE" ]]; then
        dependency_graph=$(cat "$CONTEXT_DEPENDENCY_FILE")
    else
        # 重新构建依赖图
        dependency_graph=$(build_context_dependency_graph)
    fi

    # 2. 查找相关操作
    local related_operations=$(find_related_operations "$current_operation" "$dependency_graph")

    # 3. 根据相关操作推荐上下文
    local recommendations="[]"

    for related_op in $related_operations; do
        if [[ -n "$related_op" ]]; then
            # 查找该操作相关的上下文
            local op_contexts=$(get_operation_contexts "$related_op")

            # 计算相关性评分
            local relevance_score=$(calculate_operation_relevance "$current_operation" "$related_op" "$dependency_graph")

            # 添加到推荐列表
            recommendations=$(echo "$recommendations" | jq --argjson ctx "$op_contexts" --arg score "$relevance_score" --arg op "$related_op" '. + [{operation: $op, contexts: $ctx, relevance_score: ($score | tonumber)}]' 2>/dev/null || echo "$recommendations")
        fi
    done

    # 按相关性评分排序
    local sorted_recommendations=$(echo "$recommendations" | jq 'sort_by(.relevance_score) | reverse' 2>/dev/null || echo "$recommendations")

    echo "$sorted_recommendations"
}

# 查找相关操作
find_related_operations() {
    local current_operation="$1"
    local dependency_graph="$2"

    # 从依赖图中查找直接相关的操作
    local related_ops=""

    # 检查时间依赖
    related_ops="$related_ops $(echo "$dependency_graph" | jq -r ".operation_dependencies.relevance_matrix.relations.\"$current_operation\" // {} | keys[]" 2>/dev/null || echo "")"

    # 检查语义依赖
    related_ops="$related_ops $(echo "$dependency_graph" | jq -r ".operation_dependencies.semantic_relations.semantic.\"$current_operation\" // {} | keys[]" 2>/dev/null || echo "")"

    # 去重并返回
    echo "$related_ops" | tr ' ' '\n' | sort | uniq
}

# 计算操作间相关性
calculate_operation_relevance() {
    local op1="$1"
    local op2="$2"
    local dependency_graph="$3"

    # 获取时间相关性和语义相关性
    local temporal_relevance=$(echo "$dependency_graph" | jq -r ".operation_dependencies.relevance_matrix.relations.\"$op1\".\"$op2\".temporal // 0" 2>/dev/null || echo "0")
    local semantic_relevance=$(echo "$dependency_graph" | jq -r ".operation_dependencies.relevance_matrix.relations.\"$op1\".\"$op2\".semantic // 0" 2>/dev/null || echo "0")

    # 计算综合相关性
    local combined_relevance=$(echo "scale=3; ($temporal_relevance + $semantic_relevance) / 2" | bc 2>/dev/null || echo "0.5")

    echo "$combined_relevance"
}

# 上下文完整性验证
validate_context_integrity() {
    local current_context="$1"
    local operation="$2"

    smart_echo "验证上下文完整性..." "info"

    # 1. 分析当前上下文的覆盖范围
    local context_coverage=$(analyze_context_coverage "$current_context")

    # 2. 识别缺失的关键上下文
    local missing_contexts=$(identify_missing_contexts "$context_coverage" "$operation")

    # 3. 评估上下文完整性
    local integrity_score=$(assess_context_integrity "$context_coverage" "$missing_contexts")

    cat <<EOF
{
  "context_coverage": $context_coverage,
  "missing_contexts": $missing_contexts,
  "integrity_score": $integrity_score,
  "recommendations": $(generate_integrity_recommendations "$missing_contexts" "$integrity_score")
}
EOF
}

# 分析上下文覆盖范围
analyze_context_coverage() {
    local context="$1"

    # 分析上下文包含哪些类型的信息
    local coverage='{
        "project_info": false,
        "code_files": false,
        "dependencies": false,
        "configuration": false,
        "documentation": false,
        "test_coverage": false,
        "performance_data": false
    }'

    # 检查项目信息
    if echo "$context" | grep -q "project_name\|project_type\|root"; then
        coverage=$(echo "$coverage" | jq '.project_info = true')
    fi

    # 检查代码文件
    if echo "$context" | grep -q "\.js\|\.ts\|\.py\|\.java"; then
        coverage=$(echo "$coverage" | jq '.code_files = true')
    fi

    # 检查依赖关系
    if echo "$context" | grep -q "dependencies\|imports\|requires"; then
        coverage=$(echo "$coverage" | jq '.dependencies = true')
    fi

    # 检查配置信息
    if echo "$context" | grep -q "config\|settings\|environment"; then
        coverage=$(echo "$coverage" | jq '.configuration = true')
    fi

    echo "$coverage"
}

# 识别缺失的关键上下文
identify_missing_contexts() {
    local coverage="$1"
    local operation="$2"

    local missing="[]"

    # 根据操作类型确定必需的上下文
    case "$operation" in
        "检查代码")
            if ! $(echo "$coverage" | jq -r '.code_files'); then
                missing=$(echo "$missing" | jq '. + ["code_files"]')
            fi
            if ! $(echo "$coverage" | jq -r '.configuration'); then
                missing=$(echo "$missing" | jq '. + ["eslint_config"]')
            fi
            ;;
        "提交代码")
            if ! $(echo "$coverage" | jq -r '.project_info'); then
                missing=$(echo "$missing" | jq '. + ["git_status"]')
            fi
            ;;
        "运行测试")
            if ! $(echo "$coverage" | jq -r '.code_files'); then
                missing=$(echo "$missing" | jq '. + ["test_files"]')
            fi
            ;;
    esac

    echo "$missing"
}

# 评估上下文完整性
assess_context_integrity() {
    local coverage="$1"
    local missing="$2"

    local covered_count=$(echo "$coverage" | jq 'to_entries | map(.value) | map(select(. == true)) | length')
    local total_count=$(echo "$coverage" | jq 'to_entries | length')
    local missing_count=$(echo "$missing" | jq 'length')

    # 计算完整性评分
    local coverage_ratio=$(echo "scale=2; $covered_count / $total_count" | bc 2>/dev/null || echo "0")
    local penalty_factor=$(echo "scale=2; $missing_count * 0.1" | bc 2>/dev/null || echo "0")
    local integrity_score=$(echo "scale=2; $coverage_ratio - $penalty_factor" | bc 2>/dev/null || echo "0")

    # 确保评分在0-1范围内
    if (( $(echo "$integrity_score > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        integrity_score=1.0
    fi
    if (( $(echo "$integrity_score < 0.0" | bc -l 2>/dev/null || echo "0") )); then
        integrity_score=0.0
    fi

    echo "$integrity_score"
}

# 生成完整性建议
generate_integrity_recommendations() {
    local missing="$1"
    local score="$2"

    local recommendations="[]"

    # 根据缺失的上下文生成建议
    while IFS= read -r missing_item; do
        [[ -z "$missing_item" ]] && continue

        case "$missing_item" in
            '"code_files"')
                recommendations=$(echo "$recommendations" | jq '. + ["建议加载相关代码文件信息"]')
                ;;
            '"eslint_config"')
                recommendations=$(echo "$recommendations" | jq '. + ["建议加载ESLint配置文件"]')
                ;;
            '"git_status"')
                recommendations=$(echo "$recommendations" | jq '. + ["建议加载Git状态信息"]')
                ;;
            '"test_files"')
                recommendations=$(echo "$recommendations" | jq '. + ["建议加载测试文件信息"]')
                ;;
        esac
    done <<< "$(echo "$missing" | jq -r '.[] // empty' 2>/dev/null)"

    # 根据完整性评分添加通用建议
    if (( $(echo "$score < 0.7" | bc -l 2>/dev/null || echo "0") )); then
        recommendations=$(echo "$recommendations" | jq '. + ["建议启用智能上下文加载以提升完整性"]')
    fi

    echo "$recommendations"
}

# 导出依赖图相关函数
export -f recommend_related_contexts
export -f validate_context_integrity

# 合并依赖关系
merge_dependencies() {
    local file_deps="$1"
    local op_deps="$2"

    cat <<EOF
{
  "file_dependencies": $file_deps,
  "operation_dependencies": $op_deps,
  "merged_at": "$(date -Iseconds)"
}
EOF
}

# 导出函数
export -f init_context_manager
export -f load_context_hierarchically
export -f calculate_context_relevance
export -f update_context_relevance
export -f predictive_context_preload
export -f build_context_dependency_graph
export -f analyze_behavior_patterns
export -f predict_needed_contexts
export -f recommend_related_contexts
export -f validate_context_integrity

# 获取操作历史数据
get_operation_history() {
    # 从缓存或日志中获取历史操作数据
    local history_file="$CONTEXT_CACHE_DIR/operation_history.json"

    if [[ -f "$history_file" ]]; then
        cat "$history_file"
    else
        # 初始化默认历史数据
        cat <<EOF
{
  "operations": [
    {"operation": "检查代码", "timestamp": $(date +%s), "success": true},
    {"operation": "运行测试", "timestamp": $(date +%s), "success": true},
    {"operation": "提交代码", "timestamp": $(date +%s), "success": true}
  ]
}
EOF
    fi
}

# 分析操作序列模式
analyze_operation_sequences() {
    local history_data="$1"

    # 提取操作序列
    local operations=$(echo "$history_data" | jq -r '.operations[].operation' 2>/dev/null)

    # 构建操作对序列
    local sequences="[]"
    local prev_op=""

    for op in $operations; do
        if [[ -n "$prev_op" ]]; then
            sequences=$(echo "$sequences" | jq --arg from "$prev_op" --arg to "$op" '. + [{"from": $from, "to": $to}]' 2>/dev/null || echo "$sequences")
        fi
        prev_op="$op"
    done

    echo "$sequences"
}

# 计算操作间的转移概率
calculate_transition_probabilities() {
    local sequences="$1"

    # 统计转移频率
    local transitions="{}"

    local sequence_count=$(echo "$sequences" | jq '. | length' 2>/dev/null || echo "0")

    if (( sequence_count > 0 )); then
        # 按转移对分组统计
        transitions=$(echo "$sequences" | jq 'group_by(.from + "->" + .to) | map({key: .[0].from + "->" + .[0].to, count: length}) | from_entries' 2>/dev/null || echo "{}")

        # 计算总的起始操作数
        local total_starts=$(echo "$sequences" | jq 'group_by(.from) | map({key: .[0].from, count: length}) | from_entries' 2>/dev/null || echo "{}")

        # 计算转移概率
        local probabilities="{}"
        for key in $(echo "$transitions" | jq -r 'keys[]' 2>/dev/null); do
            local from_op=$(echo "$key" | cut -d'-' -f1)
            local to_op=$(echo "$key" | cut -d'>' -f2)
            local transition_count=$(echo "$transitions" | jq -r ".\"$key\"" 2>/dev/null || echo "0")
            local start_count=$(echo "$total_starts" | jq -r ".\"$from_op\"" 2>/dev/null || echo "1")

            local probability=$(echo "scale=3; $transition_count / $start_count" | bc 2>/dev/null || echo "0")
            probabilities=$(echo "$probabilities" | jq --arg key "$key" --arg prob "$probability" '. + {($key): $prob}' 2>/dev/null || echo "$probabilities")
        done

        echo "$probabilities"
    else
        echo "{}"
    fi
}

# 预测后续操作
predict_next_operations() {
    local current_operation="$1"
    local transition_probabilities="$2"

    # 查找以当前操作为起始的所有转移
    local possible_transitions=$(echo "$transition_probabilities" | jq -r "to_entries[] | select(.key | startswith(\"$current_operation->\")) | {operation: (.key | split(\"->\")[1]), probability: .value}" 2>/dev/null)

    # 按概率排序，取前3个最可能的操作
    local top_predictions=$(echo "$possible_transitions" | jq 'sort_by(.probability) | reverse | .[0:3]' 2>/dev/null || echo "[]")

    cat <<EOF
{
  "current_operation": "$current_operation",
  "predicted_operations": $(echo "$top_predictions" | jq -r 'map(.operation) // []' 2>/dev/null),
  "prediction_confidence": $(echo "$top_predictions" | jq -r 'map(.probability) // []' 2>/dev/null),
  "timestamp": "$(date -Iseconds)"
}
EOF
}

# 获取操作相关的上下文
get_operation_contexts() {
    local operation="$1"

    case "$operation" in
        "检查代码")
            cat <<EOF
[
  {"key": "eslint_config", "data": $(get_eslint_config), "tokens": 50},
  {"key": "code_files", "data": $(get_code_files_list), "tokens": 100}
]
EOF
            ;;
        "运行测试")
            cat <<EOF
[
  {"key": "test_config", "data": $(get_test_config), "tokens": 30},
  {"key": "test_files", "data": $(get_test_files_list), "tokens": 80}
]
EOF
            ;;
        "提交代码")
            cat <<EOF
[
  {"key": "git_status", "data": $(get_git_status), "tokens": 40},
  {"key": "commit_history", "data": $(get_commit_history), "tokens": 60}
]
EOF
            ;;
        *)
            echo "[]"
            ;;
    esac
}

# 根据token限制筛选上下文
filter_contexts_by_tokens() {
    local contexts="$1"
    local max_tokens="$2"

    local filtered="[]"
    local current_tokens=0

    # 按tokens升序排序，优先选择小token的上下文
    local sorted_contexts=$(echo "$contexts" | jq 'sort_by(.tokens)' 2>/dev/null || echo "$contexts")

    while IFS= read -r context_item; do
        [[ -z "$context_item" ]] && continue

        local tokens=$(echo "$context_item" | jq -r '.tokens // 0' 2>/dev/null)

        if (( current_tokens + tokens <= max_tokens )); then
            filtered=$(echo "$filtered" | jq --argjson item "$context_item" '. + [$item]' 2>/dev/null || echo "$filtered")
            ((current_tokens += tokens))
        fi
    done <<< "$(echo "$sorted_contexts" | jq -c '.[] // empty' 2>/dev/null)"

    echo "$filtered"
}

# 🎯 上下文智能调度器
# 统一管理所有上下文相关功能

intelligent_context_scheduler() {
    local operation="$1"
    local max_tokens="${2:-4096}"
    local enable_prediction="${3:-true}"

    smart_echo "启动智能上下文调度器..." "processing"

    # 1. 分层加载上下文
    local context=$(load_context_hierarchically "$operation" "$max_tokens")

    # 2. 更新相关性评分
    update_context_relevance "operation:$operation" "$operation"

    # 3. 预测性预加载（如果启用）
    if [[ "$enable_prediction" == "true" ]]; then
        predictive_context_preload "$operation" "$((max_tokens / 4))" &
    fi

    # 4. 构建依赖图（定期更新）
    if should_update_dependency_graph; then
        build_context_dependency_graph &
    fi

    smart_echo "智能上下文调度器执行完成" "success"
    echo "$context"
}

# 判断是否需要更新依赖图
should_update_dependency_graph() {
    local last_update_file="$CONTEXT_CACHE_DIR/last_dependency_update"

    if [[ ! -f "$last_update_file" ]]; then
        echo "$(date +%s)" > "$last_update_file"
        return 0
    fi

    local last_update=$(cat "$last_update_file")
    local now=$(date +%s)
    local days_since_update=$(( (now - last_update) / 86400 ))

    # 每7天更新一次依赖图
    if (( days_since_update >= 7 )); then
        echo "$now" > "$last_update_file"
        return 0
    fi

    return 1
}

# 🛠️ 辅助数据获取函数

get_eslint_config() {
    if [[ -f ".eslintrc.js" || -f ".eslintrc.json" ]]; then
        echo '"eslint_configured"'
    else
        echo '"no_eslint_config"'
    fi
}

get_code_files_list() {
    local files=$(find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | wc -l 2>/dev/null || echo "0")
    echo "\"$files code files\""
}

get_test_config() {
    if [[ -f "jest.config.js" || -f "jest.config.json" ]]; then
        echo '"jest_configured"'
    else
        echo '"no_test_config"'
    fi
}

get_test_files_list() {
    local files=$(find . -name "*.test.js" -o -name "*.test.ts" -o -name "*.spec.js" -o -name "*.spec.ts" | wc -l 2>/dev/null || echo "0")
    echo "\"$files test files\""
}

get_git_status() {
    local status=$(git status --porcelain 2>/dev/null | wc -l 2>/dev/null || echo "0")
    echo "\"$status changed files\""
}

get_commit_history() {
    local commits=$(git log --oneline -10 2>/dev/null | wc -l 2>/dev/null || echo "0")
    echo "\"$commits recent commits\""
}

# 初始化
init_context_manager

# 导出函数 (在所有函数定义之后)
export -f calculate_context_relevance
export -f update_context_relevance
export -f predictive_context_preload
export -f build_context_dependency_graph
export -f analyze_behavior_patterns
export -f predict_needed_contexts
export -f recommend_related_contexts
export -f validate_context_integrity
export -f intelligent_context_scheduler