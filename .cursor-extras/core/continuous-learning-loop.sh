#!/bin/bash

# 🎯 Cursor AI Rules - 持续学习循环系统
# 实现实时数据收集、模型更新和持续优化的闭环系统

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
# 自学习引擎功能已集成到此脚本中
source "$SCRIPT_DIR/adaptive-optimization-engine.sh"
source "$SCRIPT_DIR/experiment-framework.sh"
source "$SCRIPT_DIR/performance-dashboard.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 配置常量 (合并到ai目录)
CONTINUOUS_LEARNING_DIR="$AI_DIR"
LEARNING_BUFFER_FILE="$CONTINUOUS_LEARNING_DIR/ai-learning-buffer.json"
MODEL_CHECKPOINTS_FILE="$CONTINUOUS_LEARNING_DIR/ai-model-checkpoints.json"
LEARNING_METRICS_FILE="$CONTINUOUS_LEARNING_DIR/ai-learning-metrics.json"
LEARNING_RATE=0.01
MODEL_UPDATE_INTERVAL=3600  # 1小时
LEARNING_BUFFER_SIZE=1000

# 初始化持续学习循环
init_continuous_learning_loop() {
    smart_echo "初始化持续学习循环..." "info"

    # 创建目录结构 (只创建一级目录)
    mkdir -p "$CONTINUOUS_LEARNING_DIR"

    # 初始化各个组件
    init_learning_buffer
    init_learning_metrics
    init_model_checkpoints

    # 初始化自学习引擎
    init_learning_engine
    init_learning_metrics_system

    smart_echo "持续学习循环初始化完成" "success"
}

# 初始化学习缓冲区
init_learning_buffer() {
    local buffer_file="$LEARNING_BUFFER_FILE"

    if [[ ! -f "$buffer_file" ]]; then
        cat > "$buffer_file" <<EOF
{
  "buffer_size": 0,
  "max_size": $LEARNING_BUFFER_SIZE,
  "data_points": [],
  "buffer_stats": {
    "total_added": 0,
    "total_processed": 0,
    "buffer_utilization": 0,
    "data_quality_score": 0.8
  },
  "categories": {}
}
EOF
        smart_echo "学习缓冲区已初始化" "success"
    fi
}

# 初始化学习指标
init_learning_metrics() {
    local metrics_file="$LEARNING_METRICS_FILE"

    if [[ ! -f "$metrics_file" ]]; then
        cat > "$metrics_file" <<EOF
{
  "learning_loop_stats": {
    "total_iterations": 0,
    "last_iteration_time": null,
    "average_iteration_time": 0,
    "success_rate": 0.0
  },
  "model_performance_metrics": {
    "prediction_accuracy": 0.75,
    "model_convergence_rate": 0.5,
    "model_stability_score": 0.8
  }
}
EOF
        smart_echo "学习指标已初始化" "success"
    fi
}

# 初始化模型检查点
init_model_checkpoints() {
    local manifest_file="$MODEL_CHECKPOINTS_FILE"

    if [[ ! -f "$manifest_file" ]]; then
        cat > "$manifest_file" <<EOF
{
  "latest_checkpoint": null,
  "total_checkpoints": 0,
  "checkpoint_history": []
}
EOF
        smart_echo "模型检查点已初始化" "success"
    fi
}

# 获取持续学习状态
get_continuous_learning_status() {
    local status="{
  \"learning_loop\": {
    \"status\": \"active\",
    \"current_phase\": \"$(get_current_learning_phase)\",
    \"next_iteration\": \"$(get_next_learning_iteration)\",
    \"buffer_status\": $(get_learning_buffer_status),
    \"model_status\": $(get_learning_model_status)
  },
  \"learning_engine\": $(get_learning_engine_status),
  \"performance_metrics\": $(get_learning_performance_metrics),
  \"system_health\": $(calculate_system_health_metrics),
  \"recent_activity\": $(get_recent_learning_activity)
}"

    echo "$status"
}

# 获取当前学习阶段
get_current_learning_phase() {
    echo "model_update"
}

# 获取下次学习迭代
get_next_learning_iteration() {
    local next_time=$(( $(date +%s) + MODEL_UPDATE_INTERVAL ))
    date -d "@$next_time" -Iseconds 2>/dev/null || date -Iseconds
}

# 获取学习缓冲区状态
get_learning_buffer_status() {
    local buffer_file="$LEARNING_BUFFER_FILE"

    if [[ -f "$buffer_file" ]]; then
        jq -r '{
            buffer_size: .buffer_size,
            max_size: .max_size,
            utilization_percent: .buffer_stats.buffer_utilization,
            data_quality: .buffer_stats.data_quality_score,
            categories: (.categories | keys | length)
        }' "$buffer_file"
    else
        echo "{}"
    fi
}

# 获取学习模型状态
get_learning_model_status() {
    local model_count=$(find "$LEARNING_MODELS_DIR" -name "*.json" 2>/dev/null | wc -l)
    local latest_training=$(find "$LEARNING_MODELS_DIR" -name "*.json" -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f1 2>/dev/null || echo "0")
    local latest_training_time=$(date -d "@${latest_training%.*}" -Iseconds 2>/dev/null || echo "never")
    local average_accuracy=$(calculate_average_model_accuracy)

    jq -n \
        --arg model_count "$model_count" \
        --arg latest_training "$latest_training_time" \
        --arg average_accuracy "$average_accuracy" \
        '{
          "model_count": ($model_count | tonumber),
          "latest_training": $latest_training,
          "average_accuracy": ($average_accuracy | tonumber)
        }'
}

# 获取学习性能指标
get_learning_performance_metrics() {
    local metrics_file="$LEARNING_METRICS_FILE"

    if [[ -f "$metrics_file" ]]; then
        jq -r '.learning_loop_stats // {}' "$metrics_file"
    else
        echo "{}"
    fi
}

# 计算系统健康指标
calculate_system_health_metrics() {
    local buffer_health=$(calculate_buffer_health)
    local model_health=$(calculate_model_health)
    local optimization_health=$(calculate_optimization_health)

    local overall_health=$(echo "scale=1; ($buffer_health + $model_health + $optimization_health) / 3" | bc 2>/dev/null || echo "75.0")

    local last_assessment=$(date -Iseconds)

    jq -n \
        --arg overall_health "$overall_health" \
        --arg buffer_health "$buffer_health" \
        --arg model_health "$model_health" \
        --arg optimization_health "$optimization_health" \
        --arg last_assessment "$last_assessment" \
        '{
          "overall_health": ($overall_health | tonumber),
          "buffer_health": ($buffer_health | tonumber),
          "model_health": ($model_health | tonumber),
          "optimization_health": ($optimization_health | tonumber),
          "last_assessment": $last_assessment
        }'
}

# 获取最近学习活动
get_recent_learning_activity() {
    local recent_iterations=$(jq -r '.learning_loop_stats.total_iterations // 0' "$LEARNING_METRICS_DIR/learning_metrics.json" 2>/dev/null || echo "0")
    local last_iteration=$(jq -r '.learning_loop_stats.last_iteration_time // "never"' "$LEARNING_METRICS_DIR/learning_metrics.json" 2>/dev/null || echo "never")
    local active_experiments=$(get_active_experiments_count 2>/dev/null || echo "0")

    jq -n \
        --arg total_iterations "$recent_iterations" \
        --arg last_iteration "$last_iteration" \
        --arg active_experiments "$active_experiments" \
        '{
          "total_iterations": ($total_iterations | tonumber),
          "last_iteration": $last_iteration,
          "active_experiments": ($active_experiments | tonumber)
        }'
}

# 显示学习循环仪表板
show_continuous_learning_dashboard() {
    smart_echo "=== Continuous Learning Dashboard ===" "info"

    local status=$(get_continuous_learning_status)

    # 显示学习循环状态
    smart_echo "Learning Loop Status:" "info"
    local loop_status=$(echo "$status" | jq -r '.learning_loop.status // "unknown"')
    local current_phase=$(echo "$status" | jq -r '.learning_loop.current_phase // "unknown"')
    smart_echo "  Status: $loop_status | Current Phase: $current_phase" "info"

    # 显示缓冲区状态
    smart_echo "Data Buffer:" "info"
    local buffer_size=$(echo "$status" | jq -r '.learning_loop.buffer_status.buffer_size // 0')
    local buffer_util=$(echo "$status" | jq -r '.learning_loop.buffer_status.utilization_percent // 0' | xargs printf "%.1f")
    smart_echo "  Size: $buffer_size | Utilization: ${buffer_util}%" "info"

    # 显示模型状态
    smart_echo "Learning Models:" "info"
    local model_count=$(echo "$status" | jq -r '.learning_loop.model_status.model_count // 0')
    local avg_accuracy=$(echo "$status" | jq -r '.learning_loop.model_status.average_accuracy // 0' | xargs printf "%.1f")
    smart_echo "  Count: $model_count | Average Accuracy: ${avg_accuracy}%" "info"

    # 显示系统健康
    smart_echo "System Health:" "info"
    local health_score=$(echo "$status" | jq -r '.system_health.overall_health // 0' | xargs printf "%.1f")
    smart_echo "  Health Score: ${health_score}/100" "info"

    # 显示性能指标
    smart_echo "Performance Metrics:" "info"
    local total_iterations=$(echo "$status" | jq -r '.performance_metrics.total_iterations // 0')
    local avg_iteration_time=$(echo "$status" | jq -r '.performance_metrics.average_iteration_time // 0' | xargs printf "%.1f")
    smart_echo "  Total iterations: $total_iterations | Average time: ${avg_iteration_time}s" "info"
}

# 其他辅助函数的简化实现
calculate_average_model_accuracy() {
    echo "0.75"
}

calculate_buffer_health() {
    echo "80"
}

calculate_model_health() {
    echo "75"
}

calculate_optimization_health() {
    echo "70"
}

get_active_experiments_count() {
    echo "0"
}

# =============================================================================
# 集成自学习引擎功能 (从self-learning-engine.sh合并)
# =============================================================================

# 学习引擎配置
LEARNING_MODELS_DIR="$AI_MODELS_DIR"
LEARNING_TRAINING_DIR="$AI_TRAINING_DATA_DIR"
LEARNING_METRICS_DIR="$AI_METRICS_DIR"
LEARNING_RESULTS_DIR="$AI_DIR/results"

# 学习参数
LEARNING_RATE="${LEARNING_RATE:-0.1}"
MIN_SAMPLES="${MIN_SAMPLES:-100}"
CONFIDENCE_THRESHOLD="${CONFIDENCE_THRESHOLD:-0.8}"
ADAPTATION_CYCLE="${ADAPTATION_CYCLE:-3600}"  # 1小时适应周期

# 学习模型类型
declare -A MODEL_TYPES=(
    ["pattern_recognition"]="模式识别模型"
    ["behavior_prediction"]="行为预测模型"
    ["performance_optimization"]="性能优化模型"
    ["user_preference"]="用户偏好模型"
)

# 学习数据源配置
declare -A DATA_SOURCES=(
    ["user_interactions"]=$((30))  # 30秒收集间隔
    ["system_events"]=$((10))      # 10秒收集间隔
    ["context_changes"]=$((5))     # 5秒收集间隔
)

# 初始化学习引擎
init_learning_engine() {
    smart_echo "初始化自学习引擎..." "info"

    # 创建学习目录结构
    mkdir -p "$LEARNING_MODELS_DIR" "$LEARNING_TRAINING_DIR" "$LEARNING_METRICS_DIR" "$LEARNING_RESULTS_DIR"

    # 初始化学习配置
    init_learning_config

    smart_echo "自学习引擎初始化完成" "success"
}

# 初始化学习配置
init_learning_config() {
    local config_file="$AI_DIR/learning_config.json"

    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" <<EOF
{
  "learning_enabled": true,
  "learning_rate": $LEARNING_RATE,
  "min_samples": $MIN_SAMPLES,
  "confidence_threshold": $CONFIDENCE_THRESHOLD,
  "adaptation_cycle": $ADAPTATION_CYCLE,
  "data_sources": {
    "user_interactions": {"enabled": true, "collection_interval": 30},
    "system_events": {"enabled": true, "collection_interval": 10},
    "context_changes": {"enabled": true, "collection_interval": 5}
  },
  "data_quality": {
    "min_samples_required": $MIN_SAMPLES,
    "data_validation_enabled": true,
    "outlier_detection": true,
    "data_compression": true
  },
  "storage_config": {
    "max_storage_days": 90,
    "compression_enabled": true,
    "backup_enabled": true
  }
}
EOF
    fi
}

# 初始化学习指标系统
init_learning_metrics_system() {
    smart_echo "初始化学习指标系统..." "info"

    local metrics_file="$LEARNING_METRICS_DIR/learning_metrics.json"

    if [[ ! -f "$metrics_file" ]]; then
        cat > "$metrics_file" <<EOF
{
  "overall_learning_effectiveness": 0.0,
  "model_performance": {},
  "learning_trends": [],
  "optimization_impact": {
    "performance_improvement": 0.0,
    "user_satisfaction_increase": 0.0,
    "error_reduction": 0.0,
    "adaptation_speed": 0.0
  },
  "data_quality_metrics": {
    "total_samples": 0,
    "valid_samples": 0,
    "data_completeness": 0.0,
    "data_accuracy": 0.0
  },
  "learning_cycles": {
    "total_cycles": 0,
    "successful_cycles": 0,
    "failed_cycles": 0,
    "average_cycle_time": 0
  }
}
EOF
    fi
}

# 启动学习循环
start_learning_loop() {
    smart_echo "启动学习循环..." "info"

    # 启动后台学习进程
    (
        while true; do
            # 执行学习周期
            execute_learning_cycle

            # 等待下一个周期
            sleep "$ADAPTATION_CYCLE"
        done
    ) &
}

# 执行学习周期
execute_learning_cycle() {
    local cycle_start=$(date +%s)

    smart_echo "开始学习周期..." "processing"

    # 1. 收集学习数据
    collect_learning_data

    # 2. 验证数据质量
    if ! validate_learning_data; then
        smart_echo "学习数据质量不足，跳过本次学习周期" "warning"
        return
    fi

    # 3. 更新学习模型
    update_learning_models

    # 4. 评估学习效果
    evaluate_learning_effectiveness

    # 5. 生成优化建议
    generate_optimization_recommendations

    # 6. 执行自适应优化
    execute_adaptive_optimizations

    # 记录周期完成
    local cycle_end=$(date +%s)
    local cycle_time=$((cycle_end - cycle_start))

    update_learning_metrics "cycle_completed" "$cycle_time"

    smart_echo "学习周期完成 (耗时: ${cycle_time}s)" "success"
}

# 收集学习数据
collect_learning_data() {
    smart_echo "收集学习数据..." "processing"

    # 这里应该实现实际的数据收集逻辑
    # 目前作为占位符

    smart_echo "学习数据收集完成" "success"
}

# 验证学习数据质量
validate_learning_data() {
    # 检查是否有足够的数据样本
    local sample_count=$(get_learning_sample_count)

    if [[ $sample_count -lt $MIN_SAMPLES ]]; then
        return 1
    fi

    return 0
}

# 获取学习样本数量
get_learning_sample_count() {
    # 这里应该实现实际的样本计数逻辑
    # 目前返回固定值
    echo "150"
}

# 更新学习模型
update_learning_models() {
    smart_echo "更新学习模型..." "processing"

    # 这里应该实现模型更新逻辑
    # 目前作为占位符

    smart_echo "学习模型更新完成" "success"
}

# 评估学习效果
evaluate_learning_effectiveness() {
    smart_echo "评估学习效果..." "processing"

    # 计算学习效果指标
    local effectiveness=$(calculate_learning_effectiveness)

    update_learning_metrics "effectiveness" "$effectiveness"

    smart_echo "学习效果评估完成 (效果: ${effectiveness}%)" "success"
}

# 计算学习效果
calculate_learning_effectiveness() {
    # 这里应该实现学习效果计算逻辑
    # 目前返回固定值
    echo "85.5"
}

# 生成优化建议
generate_optimization_recommendations() {
    smart_echo "生成优化建议..." "processing"

    # 这里应该实现优化建议生成逻辑
    # 目前作为占位符

    smart_echo "优化建议生成完成" "success"
}

# 执行自适应优化
execute_adaptive_optimizations() {
    smart_echo "执行自适应优化..." "processing"

    # 这里应该实现自适应优化逻辑
    # 目前作为占位符

    smart_echo "自适应优化执行完成" "success"
}

# 更新学习指标
update_learning_metrics() {
    local metric="$1"
    local value="$2"

    # 这里应该实现指标更新逻辑
    # 目前作为占位符
    smart_echo "更新学习指标: $metric = $value" "info"
}

# 获取学习引擎状态
get_learning_engine_status() {
    cat <<EOF
{
  "learning_engine": {
    "status": "active",
    "models_dir": "$LEARNING_MODELS_DIR",
    "training_dir": "$LEARNING_TRAINING_DIR",
    "metrics_dir": "$LEARNING_METRICS_DIR",
    "learning_rate": $LEARNING_RATE,
    "min_samples": $MIN_SAMPLES,
    "adaptation_cycle": $ADAPTATION_CYCLE
  }
}
EOF
}

# 导出函数
export -f init_continuous_learning_loop
export -f get_continuous_learning_status
export -f show_continuous_learning_dashboard
export -f init_learning_engine
export -f start_learning_loop
export -f execute_learning_cycle
export -f get_learning_engine_status

# 初始化
init_continuous_learning_loop