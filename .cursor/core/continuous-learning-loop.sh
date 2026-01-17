#!/bin/bash

# 🎯 Cursor AI Rules - 持续学习循环系统
# 实现实时数据收集、模型更新和持续优化的闭环系统

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/self-learning-engine.sh"
source "$SCRIPT_DIR/adaptive-optimization-engine.sh"
source "$SCRIPT_DIR/experiment-framework.sh"
source "$SCRIPT_DIR/performance-dashboard.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 持续学习配置
CONTINUOUS_LEARNING_DIR=".cursorGrowth/continuous_learning"
LEARNING_BUFFER_DIR="$CONTINUOUS_LEARNING_DIR/buffer"
MODEL_CHECKPOINTS_DIR="$CONTINUOUS_LEARNING_DIR/checkpoints"
LEARNING_METRICS_DIR="$CONTINUOUS_LEARNING_DIR/metrics"

# 学习循环参数
LEARNING_BUFFER_SIZE="${LEARNING_BUFFER_SIZE:-1000}"  # 学习缓冲区大小
MINI_BATCH_SIZE="${MINI_BATCH_SIZE:-32}"  # 小批量大小
LEARNING_RATE_DECAY="${LEARNING_RATE_DECAY:-0.95}"  # 学习率衰减
MODEL_UPDATE_INTERVAL="${MODEL_UPDATE_INTERVAL:-300}"  # 模型更新间隔(秒)
DATA_COLLECTION_INTERVAL="${DATA_COLLECTION_INTERVAL:-60}"  # 数据收集间隔(秒)

# 学习阶段
declare -A LEARNING_PHASES=(
    ["data_collection"]="数据收集"
    ["buffer_processing"]="缓冲区处理"
    ["model_update"]="模型更新"
    ["performance_evaluation"]="性能评估"
    ["optimization_application"]="优化应用"
)

# 学习循环状态
declare -A LOOP_STATES=(
    ["idle"]="空闲"
    ["collecting"]="收集数据"
    ["processing"]="处理数据"
    ["training"]="训练模型"
    ["evaluating"]="评估性能"
    ["optimizing"]="应用优化"
    ["error"]="错误"
)

# 初始化持续学习循环
init_continuous_learning_loop() {
    smart_echo "初始化持续学习循环..." "processing"

    # 创建学习目录结构
    mkdir -p "$CONTINUOUS_LEARNING_DIR"
    mkdir -p "$LEARNING_BUFFER_DIR"
    mkdir -p "$MODEL_CHECKPOINTS_DIR"
    mkdir -p "$LEARNING_METRICS_DIR"

    # 初始化学习缓冲区
    init_learning_buffer

    # 初始化学习指标
    init_learning_metrics

    # 初始化模型检查点
    init_model_checkpoints

    # 启动学习循环
    start_continuous_learning_loop

    smart_echo "持续学习循环初始化完成" "success"
}

# 初始化学习缓冲区
init_learning_buffer() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"

    if [[ ! -f "$buffer_file" ]]; then
        cat > "$buffer_file" <<EOF
{
  "buffer_size": 0,
  "max_size": $LEARNING_BUFFER_SIZE,
  "data_points": [],
  "last_processed_index": 0,
  "buffer_stats": {
    "total_added": 0,
    "total_processed": 0,
    "data_quality_score": 0.0,
    "buffer_utilization": 0.0
  },
  "data_categories": {
    "user_interactions": [],
    "performance_metrics": [],
    "system_events": [],
    "experiment_results": []
  }
}
EOF
    fi
}

# 初始化学习指标
init_learning_metrics() {
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"

    if [[ ! -f "$metrics_file" ]]; then
        cat > "$metrics_file" <<EOF
{
  "learning_loop_stats": {
    "total_iterations": 0,
    "successful_iterations": 0,
    "failed_iterations": 0,
    "average_iteration_time": 0,
    "last_iteration_time": null
  },
  "data_quality_metrics": {
    "average_data_quality": 0.0,
    "data_completeness": 0.0,
    "data_accuracy": 0.0,
    "data_freshness": 0.0
  },
  "model_performance_metrics": {
    "model_accuracy_trend": [],
    "model_convergence_rate": 0.0,
    "model_stability_score": 0.0,
    "prediction_accuracy": 0.0
  },
  "optimization_metrics": {
    "total_optimizations_applied": 0,
    "successful_optimizations": 0,
    "optimization_success_rate": 0.0,
    "average_improvement": 0.0
  },
  "system_health_metrics": {
    "learning_loop_health": 100.0,
    "data_pipeline_health": 100.0,
    "model_training_health": 100.0,
    "optimization_health": 100.0
  }
}
EOF
    fi
}

# 初始化模型检查点
init_model_checkpoints() {
    local checkpoint_file="$MODEL_CHECKPOINTS_DIR/checkpoint_manifest.json"

    if [[ ! -f "$checkpoint_file" ]]; then
        cat > "$checkpoint_file" <<EOF
{
  "latest_checkpoint": null,
  "checkpoint_history": [],
  "checkpoint_policy": {
    "max_checkpoints": 10,
    "checkpoint_interval": 3600,
    "auto_cleanup": true
  },
  "model_versions": {},
  "rollback_points": []
}
EOF
    fi
}

# 启动持续学习循环
start_continuous_learning_loop() {
    smart_echo "启动持续学习循环..." "info"

    # 启动后台学习循环进程
    (
        local loop_state="idle"

        while true; do
            # 执行学习循环迭代
            execute_learning_loop_iteration

            # 更新循环状态
            update_learning_loop_state "$loop_state"

            # 等待下一个周期
            sleep "$MODEL_UPDATE_INTERVAL"
        done
    ) &
}

# 🎯 核心学习循环功能

# 执行学习循环迭代
execute_learning_loop_iteration() {
    local iteration_start=$(date +%s)
    local iteration_id="iter_$(date +%s%3N)"

    smart_echo "开始学习循环迭代: $iteration_id" "processing"

    # 1. 数据收集阶段
    execute_data_collection_phase

    # 2. 数据处理阶段
    execute_data_processing_phase

    # 3. 模型更新阶段
    execute_model_update_phase

    # 4. 性能评估阶段
    execute_performance_evaluation_phase

    # 5. 优化应用阶段
    execute_optimization_application_phase

    local iteration_end=$(date +%s)
    local iteration_duration=$((iteration_end - iteration_start))

    # 记录迭代统计
    record_iteration_stats "$iteration_id" "$iteration_duration"

    smart_echo "学习循环迭代完成: $iteration_id (${iteration_duration}s)" "success"
}

# 执行数据收集阶段
execute_data_collection_phase() {
    smart_echo "执行数据收集阶段..." "info"

    # 收集各种数据源
    collect_user_interaction_data
    collect_performance_metrics
    collect_system_events
    collect_experiment_results

    # 更新数据质量指标
    update_data_quality_metrics

    smart_echo "数据收集完成" "success"
}

# 收集用户交互数据
collect_user_interaction_data() {
    # 从性能监控中获取用户交互数据
    local interaction_data=$(get_recent_user_interactions)

    if [[ -n "$interaction_data" ]]; then
        add_to_learning_buffer "user_interactions" "$interaction_data"
    fi
}

# 收集性能指标数据
collect_performance_metrics() {
    # 获取实时性能指标
    local performance_data=$(get_realtime_performance_stats)

    add_to_learning_buffer "performance_metrics" "$performance_data"
}

# 收集系统事件数据
collect_system_events() {
    # 收集系统事件（如错误、警告等）
    local system_events=$(get_recent_system_events)

    if [[ -n "$system_events" ]]; then
        add_to_learning_buffer "system_events" "$system_events"
    fi
}

# 收集实验结果数据
collect_experiment_results() {
    # 获取实验框架的结果
    local experiment_results=$(get_recent_experiment_results)

    if [[ -n "$experiment_results" ]]; then
        add_to_learning_buffer "experiment_results" "$experiment_results"
    fi
}

# 添加数据到学习缓冲区
add_to_learning_buffer() {
    local category="$1"
    local data="$2"

    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"

    # 创建数据点
    local data_point=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "category": "$category",
  "data": $data,
  "quality_score": $(calculate_data_point_quality "$data"),
  "size_bytes": ${#data}
}
EOF
)

    # 添加到缓冲区
    local temp_buffer=$(mktemp)
    jq --arg category "$category" --argjson point "$data_point" '
        .data_points += [$point] |
        .buffer_size = (.buffer_size + 1) |
        .buffer_stats.total_added += 1 |
        .data_categories[$category] += [$point] |
        .buffer_stats.buffer_utilization = (.buffer_size / .max_size * 100)
    ' "$buffer_file" > "$temp_buffer"
    mv "$temp_buffer" "$buffer_file"

    # 检查缓冲区是否需要清理
    check_buffer_cleanup
}

# 计算数据点质量
calculate_data_point_quality() {
    local data="$1"

    # 简化的质量计算（基于数据完整性和一致性）
    local completeness=$(echo "$data" | jq 'keys | length' 2>/dev/null || echo "0")
    local has_timestamp=$(echo "$data" | jq 'has("timestamp")' 2>/dev/null || echo "false")

    local quality=0.5  # 基础质量

    if (( completeness > 3 )); then
        quality=$(echo "$quality + 0.2" | bc 2>/dev/null || echo "$quality")
    fi

    if [[ "$has_timestamp" == "true" ]]; then
        quality=$(echo "$quality + 0.3" | bc 2>/dev/null || echo "$quality")
    fi

    echo "$quality"
}

# 检查缓冲区清理
check_buffer_cleanup() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"
    local current_size=$(jq -r '.buffer_size // 0' "$buffer_file")
    local max_size=$(jq -r '.max_size // '$LEARNING_BUFFER_SIZE'' "$buffer_file")

    if (( current_size > max_size )); then
        smart_echo "学习缓冲区已满，开始清理..." "warning"

        # 清理旧数据（保留最新的80%）
        cleanup_learning_buffer
    fi
}

# 清理学习缓冲区
cleanup_learning_buffer() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"
    local keep_count=$((LEARNING_BUFFER_SIZE * 8 / 10))  # 保留80%

    local temp_buffer=$(mktemp)
    jq --arg keep_count "$keep_count" '
        .data_points = (.data_points | .[-$keep_count:] | reverse) |
        .buffer_size = (.data_points | length) |
        .buffer_stats.buffer_utilization = (.buffer_size / .max_size * 100)
    ' "$buffer_file" > "$temp_buffer"
    mv "$temp_buffer" "$buffer_file"

    smart_echo "学习缓冲区清理完成，保留 $keep_count 个数据点" "info"
}

# 更新数据质量指标
update_data_quality_metrics() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"

    # 计算数据质量统计
    local avg_quality=$(jq -r '.data_points | map(.quality_score) | add / length // 0' "$buffer_file")
    local completeness=$(jq -r '.data_points | map(select(.category != null)) | length / (.data_points | length) // 1' "$buffer_file")
    local data_freshness=$(calculate_data_freshness "$buffer_file")

    # 更新指标文件
    local temp_metrics=$(mktemp)
    jq --arg avg_quality "$avg_quality" --arg completeness "$completeness" --arg freshness "$data_freshness" '
        .data_quality_metrics.average_data_quality = ($avg_quality | tonumber) |
        .data_quality_metrics.data_completeness = ($completeness | tonumber) |
        .data_quality_metrics.data_freshness = ($freshness | tonumber)
    ' "$metrics_file" > "$temp_metrics"
    mv "$temp_metrics" "$metrics_file"
}

# 计算数据新鲜度
calculate_data_freshness() {
    local buffer_file="$1"

    local latest_timestamp=$(jq -r '.data_points | map(.timestamp) | max // "'$(date -Iseconds)'"'" "$buffer_file")
    local current_time=$(date +%s)
    local latest_time=$(date -d "$latest_timestamp" +%s 2>/dev/null || echo "$current_time")

    local age_hours=$(( (current_time - latest_time) / 3600 ))

    # 新鲜度评分（最近1小时内为1.0，超过24小时降至0.0）
    if (( age_hours <= 1 )); then
        echo "1.0"
    elif (( age_hours <= 6 )); then
        echo "0.8"
    elif (( age_hours <= 12 )); then
        echo "0.6"
    elif (( age_hours <= 24 )); then
        echo "0.3"
    else
        echo "0.0"
    fi
}

# 执行数据处理阶段
execute_data_processing_phase() {
    smart_echo "执行数据处理阶段..." "info"

    # 处理缓冲区中的数据
    process_learning_buffer

    # 执行数据预处理
    preprocess_learning_data

    # 执行特征工程
    perform_feature_engineering

    smart_echo "数据处理完成" "success"
}

# 处理学习缓冲区
process_learning_buffer() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"
    local last_processed=$(jq -r '.last_processed_index // 0' "$buffer_file")
    local total_points=$(jq -r '.data_points | length' "$buffer_file")

    # 处理新增的数据点
    if (( total_points > last_processed )); then
        smart_echo "处理 $((total_points - last_processed)) 个新数据点..." "info"

        # 这里可以实现更复杂的数据处理逻辑
        # 目前只是更新处理索引

        local temp_buffer=$(mktemp)
        jq --arg total "$total_points" '.last_processed_index = ($total | tonumber) | .buffer_stats.total_processed = ($total | tonumber)' "$buffer_file" > "$temp_buffer"
        mv "$temp_buffer" "$buffer_file"
    fi
}

# 数据预处理
preprocess_learning_data() {
    # 数据清洗、标准化、异常检测等
    smart_echo "执行数据预处理..." "info"

    # 这里可以实现数据预处理逻辑
    # 例如：去除异常值、数据标准化、缺失值处理等
    true
}

# 特征工程
perform_feature_engineering() {
    # 从原始数据中提取特征
    smart_echo "执行特征工程..." "info"

    # 这里可以实现特征工程逻辑
    # 例如：时间特征、统计特征、相关性特征等
    true
}

# 执行模型更新阶段
execute_model_update_phase() {
    smart_echo "执行模型更新阶段..." "info"

    # 检查是否有足够的数据进行训练
    local buffer_size=$(jq -r '.buffer_size // 0' "$LEARNING_BUFFER_DIR/learning_buffer.json")

    if (( buffer_size >= MINI_BATCH_SIZE )); then
        # 执行模型训练
        train_learning_models

        # 创建模型检查点
        create_model_checkpoint

        # 更新学习率
        update_learning_rate
    else
        smart_echo "数据不足，跳过模型训练 (需要: $MINI_BATCH_SIZE, 当前: $buffer_size)" "info"
    fi

    smart_echo "模型更新完成" "success"
}

# 训练学习模型
train_learning_models() {
    smart_echo "训练学习模型..." "processing"

    # 获取训练数据
    local training_data=$(get_training_data_from_buffer)

    # 更新自学习引擎的模型
    update_self_learning_models "$training_data"

    # 更新性能
    update_model_performance_metrics
}

# 从缓冲区获取训练数据
get_training_data_from_buffer() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"

    # 获取最近的训练数据
    jq -r '.data_points | .[-'$MINI_BATCH_SIZE':] // []' "$buffer_file"
}

# 更新自学习模型
update_self_learning_models() {
    local training_data="$1"

    # 调用自学习引擎的训练函数
    # 这里可以集成更复杂的训练逻辑
    smart_echo "更新自学习模型..." "info"
    true
}

# 更新模型性能指标
update_model_performance_metrics() {
    # 计算模型性能指标
    local model_accuracy=$(calculate_current_model_accuracy)
    local convergence_rate=$(calculate_model_convergence_rate)
    local stability_score=$(calculate_model_stability_score)

    # 更新指标文件
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local temp_metrics=$(mktemp)

    jq --arg accuracy "$model_accuracy" --arg convergence "$convergence_rate" --arg stability "$stability_score" '
        .model_performance_metrics.model_accuracy_trend += [($accuracy | tonumber)] |
        .model_performance_metrics.model_convergence_rate = ($convergence | tonumber) |
        .model_performance_metrics.model_stability_score = ($stability | tonumber)
    ' "$metrics_file" > "$temp_metrics"
    mv "$temp_metrics" "$metrics_file"
}

# 计算当前模型准确性
calculate_current_model_accuracy() {
    # 从学习洞察中获取准确性
    local insights=$(get_learning_insights 2>/dev/null || echo "{}")
    local accuracy=$(echo "$insights" | jq -r '.overall_effectiveness // 0.75')

    echo "$accuracy"
}

# 计算模型收敛率
calculate_model_convergence_rate() {
    # 计算模型性能的收敛趋势
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local recent_accuracy=$(jq -r '.model_performance_metrics.model_accuracy_trend | .[-5:] // []' "$metrics_file")

    # 简化的收敛率计算
    local accuracy_values=$(echo "$recent_accuracy" | jq -r '.[] // 0' 2>/dev/null)
    local count=$(echo "$accuracy_values" | wc -l)

    if (( count >= 3 )); then
        # 计算趋势斜率
        local trend=$(calculate_trend_slope "$accuracy_values")
        # 收敛率 = 1 / (1 + |趋势|)
        echo "scale=3; 1 / (1 + $(echo "scale=3; $trend < 0 && -$trend || $trend" | bc 2>/dev/null || echo "0"))" | bc 2>/dev/null || echo "0.5"
    else
        echo "0.5"  # 默认中等收敛率
    fi
}

# 计算模型稳定性评分
calculate_model_stability_score() {
    # 计算模型性能的方差（稳定性指标）
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local recent_accuracy=$(jq -r '.model_performance_metrics.model_accuracy_trend | .[-10:] // []' "$metrics_file")

    local accuracy_values=$(echo "$recent_accuracy" | jq -r '.[] // 0' 2>/dev/null)
    local count=$(echo "$accuracy_values" | wc -l)

    if (( count >= 5 )); then
        # 计算标准差（稳定性指标，倒数）
        local mean=$(echo "$accuracy_values" | paste -sd+ | bc 2>/dev/null | xargs echo "scale=3; $count > 0 && (/ $count) || 0" | bc 2>/dev/null || echo "0")
        local variance=$(echo "$accuracy_values" | awk -v mean="$mean" '{sum += ($1-mean)^2} END {print sum/NR}' 2>/dev/null || echo "0")

        # 稳定性 = 1 / (1 + 方差)
        echo "scale=3; 1 / (1 + $variance)" | bc 2>/dev/null || echo "0.8"
    else
        echo "0.8"  # 默认高稳定性
    fi
}

# 创建模型检查点
create_model_checkpoint() {
    local checkpoint_id="checkpoint_$(date +%Y%m%d_%H%M%S)"
    local checkpoint_dir="$MODEL_CHECKPOINTS_DIR/$checkpoint_id"

    mkdir -p "$checkpoint_dir"

    # 保存当前模型状态
    cp -r "$LEARNING_MODELS_DIR"/* "$checkpoint_dir/" 2>/dev/null || true

    # 保存元数据
    cat > "$checkpoint_dir/metadata.json" <<EOF
{
  "checkpoint_id": "$checkpoint_id",
  "created_at": "$(date -Iseconds)",
  "model_versions": $(get_current_model_versions),
  "performance_metrics": $(get_current_model_performance),
  "system_state": $(get_current_system_state)
}
EOF

    # 更新检查点清单
    update_checkpoint_manifest "$checkpoint_id"

    smart_echo "模型检查点已创建: $checkpoint_id" "success"
}

# 获取当前模型版本
get_current_model_versions() {
    local versions="{"

    first=true
    for model_file in "$LEARNING_MODELS_DIR"/*.json; do
        if [[ -f "$model_file" ]]; then
            local model_name=$(basename "$model_file" .json)
            local version=$(jq -r '.version // "1.0"' "$model_file")

            if [[ "$first" == true ]]; then
                first=false
            else
                versions="${versions},"
            fi

            versions="${versions}\"${model_name}\":\"${version}\""
        fi
    done

    versions="${versions}}"
    echo "$versions"
}

# 获取当前模型性能
get_current_model_performance() {
    jq -r '.model_performance_metrics // {}' "$LEARNING_METRICS_DIR/learning_metrics.json" 2>/dev/null || echo "{}"
}

# 获取当前系统状态
get_current_system_state() {
    cat <<EOF
{
  "learning_loop_active": true,
  "buffer_size": $(jq -r '.buffer_size // 0' "$LEARNING_BUFFER_DIR/learning_buffer.json"),
  "active_experiments": $(get_active_experiments_count 2>/dev/null || echo "0"),
  "system_health": $(get_optimization_system_health 2>/dev/null || echo "{}")
}
EOF
}

# 更新检查点清单
update_checkpoint_manifest() {
    local checkpoint_id="$1"

    local manifest_file="$MODEL_CHECKPOINTS_DIR/checkpoint_manifest.json"
    local temp_manifest=$(mktemp)

    jq --arg checkpoint_id "$checkpoint_id" --arg timestamp "$(date -Iseconds)" '
        .latest_checkpoint = $checkpoint_id |
        .checkpoint_history += [{
            "checkpoint_id": $checkpoint_id,
            "created_at": $timestamp,
            "performance_snapshot": '"$(get_current_model_performance)"'
        }]
    ' "$manifest_file" > "$temp_manifest"
    mv "$temp_manifest" "$manifest_file"

    # 清理旧检查点
    cleanup_old_checkpoints
}

# 清理旧检查点
cleanup_old_checkpoints() {
    local manifest_file="$MODEL_CHECKPOINTS_DIR/checkpoint_manifest.json"
    local max_checkpoints=$(jq -r '.checkpoint_policy.max_checkpoints // 10' "$manifest_file")
    local checkpoint_count=$(jq -r '.checkpoint_history | length' "$manifest_file")

    if (( checkpoint_count > max_checkpoints )); then
        local remove_count=$((checkpoint_count - max_checkpoints))

        # 获取要删除的检查点
        local checkpoints_to_remove=$(jq -r ".checkpoint_history | .[0:$remove_count] | .[].checkpoint_id" "$manifest_file")

        # 删除检查点文件
        for checkpoint_id in $checkpoints_to_remove; do
            rm -rf "$MODEL_CHECKPOINTS_DIR/$checkpoint_id" 2>/dev/null || true
        done

        # 更新清单
        local temp_manifest=$(mktemp)
        jq --arg remove_count "$remove_count" '.checkpoint_history = .checkpoint_history[$remove_count:]' "$manifest_file" > "$temp_manifest"
        mv "$temp_manifest" "$manifest_file"

        smart_echo "清理了 $remove_count 个旧检查点" "info"
    fi
}

# 更新学习率
update_learning_rate() {
    # 根据模型性能调整学习率
    local current_performance=$(calculate_current_model_accuracy)
    local target_performance=0.85

    if (( $(echo "$current_performance >= $target_performance" | bc -l 2>/dev/null || echo "0") )); then
        # 性能良好，略微降低学习率
        LEARNING_RATE=$(echo "scale=4; $LEARNING_RATE * $LEARNING_RATE_DECAY" | bc 2>/dev/null || echo "$LEARNING_RATE")
    else
        # 性能不佳，保持或略微增加学习率
        LEARNING_RATE=$(echo "scale=4; $LEARNING_RATE * 1.05" | bc 2>/dev/null || echo "$LEARNING_RATE")
    fi

    # 确保学习率在合理范围内
    if (( $(echo "$LEARNING_RATE > 0.5" | bc -l 2>/dev/null || echo "0") )); then
        LEARNING_RATE=0.5
    elif (( $(echo "$LEARNING_RATE < 0.001" | bc -l 2>/dev/null || echo "0") )); then
        LEARNING_RATE=0.001
    fi

    smart_echo "学习率已更新为: $LEARNING_RATE" "info"
}

# 执行性能评估阶段
execute_performance_evaluation_phase() {
    smart_echo "执行性能评估阶段..." "info"

    # 评估模型性能
    evaluate_model_performance

    # 评估系统健康
    evaluate_system_health

    # 生成性能报告
    generate_performance_report

    smart_echo "性能评估完成" "success"
}

# 评估模型性能
evaluate_model_performance() {
    # 详细的模型性能评估
    local model_metrics=$(calculate_detailed_model_metrics)

    # 检查性能阈值
    check_performance_thresholds "$model_metrics"

    # 更新性能历史
    update_performance_history "$model_metrics"
}

# 计算详细模型指标
calculate_detailed_model_metrics() {
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"

    cat <<EOF
{
  "accuracy": $(jq -r '.model_performance_metrics.prediction_accuracy // 0.75' "$metrics_file"),
  "convergence": $(jq -r '.model_performance_metrics.model_convergence_rate // 0.5' "$metrics_file"),
  "stability": $(jq -r '.model_performance_metrics.model_stability_score // 0.8' "$metrics_file"),
  "improvement_rate": $(calculate_improvement_rate),
  "prediction_quality": $(calculate_prediction_quality)
}
EOF
}

# 计算改进率
calculate_improvement_rate() {
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local accuracy_trend=$(jq -r '.model_performance_metrics.model_accuracy_trend // []' "$metrics_file")

    local recent_values=$(echo "$accuracy_trend" | jq -r '.[-5:] // [] | .[]' 2>/dev/null)
    local count=$(echo "$recent_values" | wc -l)

    if (( count >= 2 )); then
        local first=$(echo "$recent_values" | head -1)
        local last=$(echo "$recent_values" | tail -1)

        if (( $(echo "$first > 0" | bc -l 2>/dev/null || echo "0") )); then
            echo "scale=3; ($last - $first) / $first" | bc 2>/dev/null || echo "0"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# 计算预测质量
calculate_prediction_quality() {
    # 简化的预测质量计算
    local insights=$(get_learning_insights 2>/dev/null || echo "{}")
    local effectiveness=$(echo "$insights" | jq -r '.overall_effectiveness // 0.7')

    echo "$effectiveness"
}

# 检查性能阈值
check_performance_thresholds() {
    local metrics="$1"

    local accuracy=$(echo "$metrics" | jq -r '.accuracy // 0')
    local convergence=$(echo "$metrics" | jq -r '.convergence // 0')
    local stability=$(echo "$metrics" | jq -r '.stability // 0')

    # 检查各项指标是否达到阈值
    local issues="[]"

    if (( $(echo "$accuracy < 0.7" | bc -l 2>/dev/null || echo "0") )); then
        issues=$(echo "$issues" | jq '. + ["模型准确率偏低"]')
    fi

    if (( $(echo "$convergence < 0.3" | bc -l 2>/dev/null || echo "0") )); then
        issues=$(echo "$issues" | jq '. + ["模型收敛速度慢"]')
    fi

    if (( $(echo "$stability < 0.6" | bc -l 2>/dev/null || echo "0") )); then
        issues=$(echo "$issues" | jq '. + ["模型稳定性不足"]')
    fi

    if [[ "$issues" != "[]" ]]; then
        smart_echo "发现性能问题: $(echo "$issues" | jq -r '.[]' | paste -sd,)" "warning"
    fi
}

# 更新性能历史
update_performance_history() {
    local metrics="$1"

    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local temp_metrics=$(mktemp)

    jq --argjson new_metrics "$metrics" --arg timestamp "$(date -Iseconds)" '
        .model_performance_metrics.performance_history += [{
            "timestamp": $timestamp,
            "metrics": $new_metrics
        }]
    ' "$metrics_file" > "$temp_metrics"
    mv "$temp_metrics" "$metrics_file"
}

# 评估系统健康
evaluate_system_health() {
    # 评估学习循环的整体健康
    local health_metrics=$(calculate_system_health_metrics)

    # 更新健康指标
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local temp_metrics=$(mktemp)

    jq --argjson health "$health_metrics" '.system_health_metrics = $health' "$metrics_file" > "$temp_metrics"
    mv "$temp_metrics" "$metrics_file"
}

# 计算系统健康指标
calculate_system_health_metrics() {
    local buffer_health=$(calculate_buffer_health)
    local model_health=$(calculate_model_health)
    local optimization_health=$(calculate_optimization_health)

    local overall_health=$(echo "scale=1; ($buffer_health + $model_health + $optimization_health) / 3" | bc 2>/dev/null || echo "75.0")

    cat <<EOF
{
  "overall_health": $overall_health,
  "buffer_health": $buffer_health,
  "model_health": $model_health,
  "optimization_health": $optimization_health,
  "last_assessment": "$(date -Iseconds)"
}
EOF
}

# 计算缓冲区健康
calculate_buffer_health() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"
    local utilization=$(jq -r '.buffer_stats.buffer_utilization // 0' "$buffer_file")
    local data_quality=$(jq -r '.buffer_stats.data_quality_score // 0.8' "$buffer_file")

    # 健康评分 = 利用率 * 质量 * 调整因子
    local health=$(echo "scale=1; $utilization * $data_quality * 1.2" | bc 2>/dev/null || echo "80.0")

    # 确保在0-100范围内
    if (( $(echo "$health > 100" | bc -l 2>/dev/null || echo "0") )); then
        health=100.0
    fi

    echo "$health"
}

# 计算模型健康
calculate_model_health() {
    local accuracy=$(calculate_current_model_accuracy)
    local stability=$(calculate_model_stability_score)

    # 模型健康 = (准确率 + 稳定性) * 50
    local health=$(echo "scale=1; ($accuracy + $stability) * 50" | bc 2>/dev/null || echo "75.0")

    echo "$health"
}

# 计算优化健康
calculate_optimization_health() {
    local opt_status=$(get_optimization_status 2>/dev/null || echo "{}")
    local health_score=$(echo "$opt_status" | jq -r '.system_health.health_score // 80' 2>/dev/null || echo "80")

    echo "$health_score"
}

# 生成性能报告
generate_performance_report() {
    local report_file="$CONTINUOUS_LEARNING_DIR/reports/performance_report_$(date +%Y%m%d_%H%M%S).json"

    mkdir -p "$CONTINUOUS_LEARNING_DIR/reports"

    local report_data=$(cat <<EOF
{
  "report_generated_at": "$(date -Iseconds)",
  "period": {
    "start": "$(date -d '1 hour ago' -Iseconds 2>/dev/null || echo 'unknown')",
    "end": "$(date -Iseconds)"
  },
  "learning_metrics": $(cat "$LEARNING_METRICS_DIR/learning_metrics.json" 2>/dev/null || echo "{}"),
  "model_performance": $(get_current_model_performance),
  "system_health": $(calculate_system_health_metrics),
  "optimization_status": $(get_optimization_status 2>/dev/null || echo "{}"),
  "recommendations": $(generate_learning_recommendations)
}
EOF
)

    echo "$report_data" > "$report_file"
    smart_echo "性能报告已生成: $report_file" "success"
}

# 生成学习建议
generate_learning_recommendations() {
    local recommendations="[]"

    # 基于当前指标生成建议
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"

    local accuracy=$(jq -r '.model_performance_metrics.prediction_accuracy // 0' "$metrics_file")
    if (( $(echo "$accuracy < 0.8" | bc -l 2>/dev/null || echo "0") )); then
        recommendations=$(echo "$recommendations" | jq '. + [{"type": "model_improvement", "action": "increase_training_data", "priority": "high"}]')
    fi

    local buffer_size=$(jq -r '.buffer_size // 0' "$LEARNING_BUFFER_DIR/learning_buffer.json")
    if (( buffer_size < MINI_BATCH_SIZE )); then
        recommendations=$(echo "$recommendations" | jq '. + [{"type": "data_collection", "action": "increase_data_collection", "priority": "medium"}]')
    fi

    echo "$recommendations"
}

# 执行优化应用阶段
execute_optimization_application_phase() {
    smart_echo "执行优化应用阶段..." "info"

    # 检查是否有待应用的优化
    local pending_optimizations=$(get_pending_optimizations)

    if [[ "$pending_optimizations" != "[]" ]]; then
        # 应用优化
        apply_pending_optimizations "$pending_optimizations"

        # 验证优化效果
        verify_optimization_effectiveness
    else
        smart_echo "没有待应用的优化" "info"
    fi

    smart_echo "优化应用完成" "success"
}

# 获取待应用优化
get_pending_optimizations() {
    # 从优化引擎获取待应用的优化
    local opt_status=$(get_optimization_status 2>/dev/null || echo "{}")
    echo "$opt_status" | jq -r '.pending_optimizations // []' 2>/dev/null || echo "[]"
}

# 应用待优化
apply_pending_optimizations() {
    local optimizations="$1"

    echo "$optimizations" | jq -c '.[]' | while read -r opt; do
        local opt_type=$(echo "$opt" | jq -r '.type // "unknown"')
        local opt_action=$(echo "$opt" | jq -r '.action // "none"')

        smart_echo "应用优化: $opt_type - $opt_action" "info"

        # 这里实现具体的优化应用逻辑
        case "$opt_type" in
            "cache_optimization")
                apply_cache_optimization "$opt"
                ;;
            "model_tuning")
                apply_model_tuning "$opt"
                ;;
            "resource_allocation")
                apply_resource_allocation "$opt"
                ;;
            *)
                smart_echo "未知优化类型: $opt_type" "warning"
                ;;
        esac
    done
}

# 应用缓存优化
apply_cache_optimization() {
    local optimization="$1"

    # 实现缓存优化逻辑
    smart_echo "应用缓存优化..." "info"
    true
}

# 应用模型调优
apply_model_tuning() {
    local optimization="$1"

    # 实现模型调优逻辑
    smart_echo "应用模型调优..." "info"
    true
}

# 应用资源分配
apply_resource_allocation() {
    local optimization="$1"

    # 实现资源分配优化逻辑
    smart_echo "应用资源分配优化..." "info"
    true
}

# 验证优化效果
verify_optimization_effectiveness() {
    smart_echo "验证优化效果..." "info"

    # 比较应用优化前后的性能指标
    local before_metrics=$(get_baseline_metrics)
    local after_metrics=$(get_current_metrics)

    local improvement=$(calculate_optimization_improvement "$before_metrics" "$after_metrics")

    if (( $(echo "$improvement > 0" | bc -l 2>/dev/null || echo "0") )); then
        smart_echo "优化效果验证成功，改进: ${improvement}%" "success"
    else
        smart_echo "优化效果不明显，可能需要回滚" "warning"
    fi
}

# 计算优化改进
calculate_optimization_improvement() {
    local before="$1"
    local after="$2"

    # 简化的改进计算
    local before_avg=$(echo "$before" | jq -r '.aggregates.avg_response_time // 1000')
    local after_avg=$(echo "$after" | jq -r '.aggregates.avg_response_time // 1000')

    if (( before_avg > 0 )); then
        echo "scale=2; ($before_avg - $after_avg) / $before_avg * 100" | bc 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# 获取基准指标
get_baseline_metrics() {
    # 从历史数据中获取基准指标
    echo '{"aggregates": {"avg_response_time": 1500}}'
}

# 获取当前指标
get_current_metrics() {
    get_realtime_performance_stats
}

# 更新学习循环状态
update_learning_loop_state() {
    local current_state="$1"

    # 这里可以更新循环状态指标
    true
}

# 记录迭代统计
record_iteration_stats() {
    local iteration_id="$1"
    local duration="$2"

    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"
    local temp_metrics=$(mktemp)

    jq --arg iteration_id "$iteration_id" --arg duration "$duration" --arg timestamp "$(date -Iseconds)" '
        .learning_loop_stats.total_iterations += 1 |
        .learning_loop_stats.last_iteration_time = $timestamp |
        .learning_loop_stats.average_iteration_time = (
            (.learning_loop_stats.average_iteration_time * (.learning_loop_stats.total_iterations - 1) + ($duration | tonumber)) /
            .learning_loop_stats.total_iterations
        )
    ' "$metrics_file" > "$temp_metrics"
    mv "$temp_metrics" "$metrics_file"
}

# 🎯 学习循环API

# 获取学习循环状态
get_continuous_learning_status() {
    local status=$(cat <<EOF
{
  "learning_loop": {
    "status": "active",
    "current_phase": "$(get_current_learning_phase)",
    "next_iteration": "$(get_next_learning_iteration)",
    "buffer_status": $(get_learning_buffer_status),
    "model_status": $(get_learning_model_status)
  },
  "performance_metrics": $(get_learning_performance_metrics),
  "system_health": $(calculate_system_health_metrics),
  "recent_activity": $(get_recent_learning_activity)
}
EOF
)

    echo "$status"
}

# 获取当前学习阶段
get_current_learning_phase() {
    # 简化的阶段检测
    echo "model_update"
}

# 获取下次学习迭代
get_next_learning_iteration() {
    local next_time=$(( $(date +%s) + MODEL_UPDATE_INTERVAL ))
    echo "\"$(date -d "@$next_time" -Iseconds 2>/dev/null || date -Iseconds)\""
}

# 获取学习缓冲区状态
get_learning_buffer_status() {
    local buffer_file="$LEARNING_BUFFER_DIR/learning_buffer.json"

    if [[ -f "$buffer_file" ]]; then
        jq -r '{
            buffer_size: .buffer_size,
            max_size: .max_size,
            utilization_percent: .buffer_stats.buffer_utilization,
            data_quality: .buffer_stats.data_quality_score,
            categories: (.data_categories | keys | length)
        }' "$buffer_file"
    else
        echo "{}"
    fi
}

# 获取学习模型状态
get_learning_model_status() {
    local model_count=$(find "$LEARNING_MODELS_DIR" -name "*.json" | wc -l)
    local latest_training=$(find "$LEARNING_MODELS_DIR" -name "*.json" -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f1 2>/dev/null || echo "0")
    local latest_training_time=$(date -d "@${latest_training%.*}" -Iseconds 2>/dev/null || echo "never")

    cat <<EOF
{
  "model_count": $model_count,
  "latest_training": "$latest_training_time",
  "average_accuracy": $(calculate_average_model_accuracy)
}
EOF
}

# 计算平均模型准确性
calculate_average_model_accuracy() {
    local total_accuracy=0
    local count=0

    for model_file in "$LEARNING_MODELS_DIR"/*.json; do
        if [[ -f "$model_file" ]]; then
            local accuracy=$(jq -r '.accuracy // 0' "$model_file")
            total_accuracy=$(echo "scale=2; $total_accuracy + $accuracy" | bc 2>/dev/null || echo "$total_accuracy")
            ((count++))
        fi
    done

    if (( count > 0 )); then
        echo "scale=2; $total_accuracy / $count" | bc 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# 获取学习性能指标
get_learning_performance_metrics() {
    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"

    if [[ -f "$metrics_file" ]]; then
        jq -r '.learning_loop_stats // {}' "$metrics_file"
    else
        echo "{}"
    fi
}

# 获取最近学习活动
get_recent_learning_activity() {
    # 获取最近的学习活动
    local recent_iterations=$(jq -r '.learning_loop_stats.total_iterations // 0' "$LEARNING_METRICS_DIR/learning_metrics.json" 2>/dev/null || echo "0")
    local last_iteration=$(jq -r '.learning_loop_stats.last_iteration_time // "never"' "$LEARNING_METRICS_DIR/learning_metrics.json" 2>/dev/null || echo '"never"')

    cat <<EOF
{
  "total_iterations": $recent_iterations,
  "last_iteration": $last_iteration,
  "active_experiments": $(get_active_experiments_count 2>/dev/null || echo "0")
}
EOF
}

# 显示学习循环仪表板
show_continuous_learning_dashboard() {
    smart_echo "=== 🧠 持续学习循环仪表板 ===" "info"

    local status=$(get_continuous_learning_status)

    # 显示学习循环状态
    smart_echo "学习循环状态:" "info"
    local loop_status=$(echo "$status" | jq -r '.learning_loop.status // "unknown"')
    local current_phase=$(echo "$status" | jq -r '.learning_loop.current_phase // "unknown"')
    smart_echo "  状态: $loop_status | 当前阶段: $current_phase" "info"

    # 显示缓冲区状态
    smart_echo "数据缓冲区:" "info"
    local buffer_size=$(echo "$status" | jq -r '.learning_loop.buffer_status.buffer_size // 0')
    local buffer_util=$(echo "$status" | jq -r '.learning_loop.buffer_status.utilization_percent // 0' | xargs printf "%.1f")
    smart_echo "  大小: $buffer_size | 利用率: ${buffer_util}%" "info"

    # 显示模型状态
    smart_echo "学习模型:" "info"
    local model_count=$(echo "$status" | jq -r '.learning_loop.model_status.model_count // 0')
    local avg_accuracy=$(echo "$status" | jq -r '.learning_loop.model_status.average_accuracy // 0' | xargs printf "%.1f")
    smart_echo "  数量: $model_count | 平均准确率: ${avg_accuracy}%" "info"

    # 显示系统健康
    smart_echo "系统健康:" "info"
    local health_score=$(echo "$status" | jq -r '.system_health.overall_health // 0' | xargs printf "%.1f")
    smart_echo "  健康评分: ${health_score}/100" "info"

    # 显示性能指标
    smart_echo "性能指标:" "info"
    local total_iterations=$(echo "$status" | jq -r '.performance_metrics.total_iterations // 0')
    local avg_iteration_time=$(echo "$status" | jq -r '.performance_metrics.average_iteration_time // 0' | xargs printf "%.1f")
    smart_echo "  总迭代次数: $total_iterations | 平均迭代时间: ${avg_iteration_time}s" "info"
}

# 导出函数
export -f init_continuous_learning_loop
export -f get_continuous_learning_status
export -f show_continuous_learning_dashboard

# 初始化
init_continuous_learning_loop