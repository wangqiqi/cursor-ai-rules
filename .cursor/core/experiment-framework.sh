#!/bin/bash

# 🎯 Cursor AI Rules - 实验框架
# 实现A/B测试和优化策略评估系统

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/adaptive-optimization-engine.sh"
source "$SCRIPT_DIR/performance-dashboard.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 实验框架配置
EXPERIMENT_DIR=".cursorGrowth/experiments"
EXPERIMENT_CONFIG_DIR="$EXPERIMENT_DIR/config"
EXPERIMENT_DATA_DIR="$EXPERIMENT_DIR/data"
EXPERIMENT_RESULTS_DIR="$EXPERIMENT_DIR/results"

# 实验参数
DEFAULT_EXPERIMENT_DURATION="${DEFAULT_EXPERIMENT_DURATION:-3600}"  # 1小时默认实验时长
MIN_SAMPLE_SIZE="${MIN_SAMPLE_SIZE:-50}"  # 最小组样本大小
CONFIDENCE_LEVEL="${CONFIDENCE_LEVEL:-0.95}"  # 置信水平
STATISTICAL_SIGNIFICANCE="${STATISTICAL_SIGNIFICANCE:-0.05}"  # 统计显著性水平

# 实验类型
declare -A EXPERIMENT_TYPES=(
    ["a_b_test"]="A/B测试"
    ["multivariate_test"]="多变量测试"
    ["optimization_trial"]="优化试验"
    ["feature_flag_test"]="功能标记测试"
    ["performance_test"]="性能测试"
)

# 实验状态
declare -A EXPERIMENT_STATES=(
    ["planned"]="已规划"
    ["running"]="运行中"
    ["completed"]="已完成"
    ["failed"]="失败"
    ["cancelled"]="已取消"
)

# 初始化实验框架
init_experiment_framework() {
    smart_echo "初始化实验框架..." "processing"

    # 创建实验目录结构
    mkdir -p "$EXPERIMENT_CONFIG_DIR"
    mkdir -p "$EXPERIMENT_DATA_DIR"
    mkdir -p "$EXPERIMENT_RESULTS_DIR"

    # 初始化实验配置
    init_experiment_config

    # 初始化实验队列
    init_experiment_queue

    # 初始化统计引擎
    init_statistical_engine

    # 启动实验监控
    start_experiment_monitoring

    smart_echo "实验框架初始化完成" "success"
}

# 初始化实验配置
init_experiment_config() {
    local config_file="$EXPERIMENT_CONFIG_DIR/framework_config.json"

    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" <<EOF
{
  "version": "1.0",
  "framework_enabled": true,
  "auto_experimentation": true,
  "max_concurrent_experiments": 3,
  "default_experiment_duration": $DEFAULT_EXPERIMENT_DURATION,
  "min_sample_size": $MIN_SAMPLE_SIZE,
  "confidence_level": $CONFIDENCE_LEVEL,
  "statistical_significance": $STATISTICAL_SIGNIFICANCE,
  "risk_management": {
    "max_regression_risk": 0.1,
    "rollback_on_failure": true,
    "backup_before_experiment": true,
    "gradual_rollout": true
  },
  "experiment_types": {
    "a_b_test": {
      "enabled": true,
      "max_duration": 7200,
      "min_sample_size": 100,
      "required_confidence": 0.95
    },
    "multivariate_test": {
      "enabled": true,
      "max_variables": 5,
      "max_duration": 10800,
      "min_sample_size": 200
    },
    "optimization_trial": {
      "enabled": true,
      "max_iterations": 10,
      "convergence_threshold": 0.01,
      "max_duration": 3600
    },
    "feature_flag_test": {
      "enabled": true,
      "gradual_rollout": true,
      "rollback_enabled": true,
      "monitoring_required": true
    },
    "performance_test": {
      "enabled": true,
      "load_testing": true,
      "stress_testing": false,
      "benchmarking": true
    }
  },
  "success_criteria": {
    "performance_improvement": 0.05,
    "statistical_significance": $STATISTICAL_SIGNIFICANCE,
    "user_satisfaction_threshold": 0.8,
    "error_rate_threshold": 0.05
  }
}
EOF
    fi
}

# 初始化实验队列
init_experiment_queue() {
    local queue_file="$EXPERIMENT_DIR/experiment_queue.json"

    if [[ ! -f "$queue_file" ]]; then
        cat > "$queue_file" <<EOF
{
  "queue": [],
  "active_experiments": [],
  "completed_experiments": [],
  "failed_experiments": [],
  "statistics": {
    "total_experiments": 0,
    "successful_experiments": 0,
    "failed_experiments": 0,
    "average_duration": 0,
    "success_rate": 0.0
  }
}
EOF
    fi
}

# 初始化统计引擎
init_statistical_engine() {
    smart_echo "初始化统计引擎..." "info"

    # 这里可以初始化统计计算所需的工具和配置
    # 目前使用基本的bash数学运算
    true
}

# 启动实验监控
start_experiment_monitoring() {
    smart_echo "启动实验监控..." "info"

    # 启动后台监控进程
    (
        while true; do
            # 监控活跃实验
            monitor_active_experiments

            # 检查实验超时
            check_experiment_timeouts

            # 评估实验结果
            evaluate_experiment_results

            sleep 60  # 每分钟检查一次
        done
    ) &
}

# 🎯 核心实验功能

# 创建新实验
create_experiment() {
    local experiment_type="$1"
    local experiment_name="$2"
    local description="$3"
    local parameters="$4"

    smart_echo "创建实验: $experiment_name ($experiment_type)" "processing"

    # 生成实验ID
    local experiment_id="exp_$(date +%s%3N)_$(openssl rand -hex 4)"

    # 创建实验记录
    local experiment_record=$(cat <<EOF
{
  "experiment_id": "$experiment_id",
  "name": "$experiment_name",
  "type": "$experiment_type",
  "description": "$description",
  "status": "planned",
  "created_at": "$(date -Iseconds)",
  "planned_start": null,
  "actual_start": null,
  "completed_at": null,
  "duration_seconds": $DEFAULT_EXPERIMENT_DURATION,
  "parameters": $parameters,
  "variants": $(generate_experiment_variants "$experiment_type" "$parameters"),
  "baseline_metrics": {},
  "results": {},
  "statistics": {
    "sample_size": 0,
    "confidence_level": 0.0,
    "statistical_significance": false,
    "effect_size": 0.0
  },
  "success_criteria": $(get_experiment_success_criteria "$experiment_type"),
  "risk_assessment": $(assess_experiment_risk "$experiment_type" "$parameters")
}
EOF
)

    # 保存实验配置
    echo "$experiment_record" > "$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"

    # 添加到实验队列
    add_experiment_to_queue "$experiment_id"

    smart_echo "实验已创建: $experiment_id" "success"
    echo "$experiment_id"
}

# 生成实验变体
generate_experiment_variants() {
    local experiment_type="$1"
    local parameters="$2"

    case "$experiment_type" in
        "a_b_test")
            # A/B测试：控制组 vs 实验组
            cat <<EOF
{
  "control": {"name": "控制组", "parameters": $(echo "$parameters" | jq '.control // {}')},
  "treatment": {"name": "实验组", "parameters": $(echo "$parameters" | jq '.treatment // {}')}
}
EOF
            ;;
        "multivariate_test")
            # 多变量测试：多个变量组合
            cat <<EOF
{
  "combinations": $(generate_multivariate_combinations "$parameters")
}
EOF
            ;;
        "optimization_trial")
            # 优化试验：参数调优
            cat <<EOF
{
  "baseline": {"name": "基准", "parameters": $(echo "$parameters" | jq '.baseline // {}')},
  "optimized": {"name": "优化", "parameters": $(echo "$parameters" | jq '.optimized // {}')}
}
EOF
            ;;
        *)
            # 默认单变量
            cat <<EOF
{
  "default": {"name": "默认配置", "parameters": $parameters}
}
EOF
            ;;
    esac
}

# 生成多变量组合
generate_multivariate_combinations() {
    local parameters="$1"

    # 简化的组合生成（实际应该更复杂）
    cat <<EOF
[
  {"name": "组合1", "variables": {"param1": "value1", "param2": "value2"}},
  {"name": "组合2", "variables": {"param1": "value1", "param2": "value3"}},
  {"name": "组合3", "variables": {"param1": "value2", "param2": "value2"}}
]
EOF
}

# 获取实验成功标准
get_experiment_success_criteria() {
    local experiment_type="$1"

    case "$experiment_type" in
        "a_b_test")
            echo '{"improvement_threshold": 0.05, "statistical_significance": 0.05, "confidence_level": 0.95}'
            ;;
        "performance_test")
            echo '{"performance_gain": 0.10, "no_regression": true, "stability_check": true}'
            ;;
        "optimization_trial")
            echo '{"convergence_achieved": true, "improvement_threshold": 0.03, "stability_check": true}'
            ;;
        *)
            echo '{"general_success": true, "no_negative_impact": true}'
            ;;
    esac
}

# 评估实验风险
assess_experiment_risk() {
    local experiment_type="$1"
    local parameters="$2"

    case "$experiment_type" in
        "performance_test")
            echo '{"risk_level": "medium", "potential_impact": "性能影响", "rollback_complexity": "low"}'
            ;;
        "a_b_test")
            echo '{"risk_level": "low", "potential_impact": "用户体验变化", "rollback_complexity": "medium"}'
            ;;
        "optimization_trial")
            echo '{"risk_level": "high", "potential_impact": "系统行为变化", "rollback_complexity": "high"}'
            ;;
        *)
            echo '{"risk_level": "medium", "potential_impact": "未知", "rollback_complexity": "medium"}'
            ;;
    esac
}

# 添加实验到队列
add_experiment_to_queue() {
    local experiment_id="$1"

    local queue_file="$EXPERIMENT_DIR/experiment_queue.json"
    local temp_queue=$(mktemp)

    jq --arg exp_id "$experiment_id" '.queue += [$exp_id] | .statistics.total_experiments += 1' "$queue_file" > "$temp_queue"
    mv "$temp_queue" "$queue_file"
}

# 启动实验
start_experiment() {
    local experiment_id="$1"

    smart_echo "启动实验: $experiment_id" "processing"

    local exp_config="$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"

    if [[ ! -f "$exp_config" ]]; then
        smart_echo "实验配置不存在: $experiment_id" "error"
        return 1
    fi

    # 更新实验状态
    update_experiment_status "$experiment_id" "running"

    # 记录开始时间和基准指标
    local baseline_metrics=$(get_realtime_performance_stats)
    local temp_config=$(mktemp)

    jq --arg start_time "$(date -Iseconds)" --argjson baseline "$baseline_metrics" '
        .status = "running" |
        .actual_start = $start_time |
        .baseline_metrics = $baseline
    ' "$exp_config" > "$temp_config"
    mv "$temp_config" "$exp_config"

    # 初始化实验数据收集
    init_experiment_data_collection "$experiment_id"

    smart_echo "实验已启动: $experiment_id" "success"
}

# 初始化实验数据收集
init_experiment_data_collection() {
    local experiment_id="$1"

    local data_file="$EXPERIMENT_DATA_DIR/${experiment_id}_data.json"

    cat > "$data_file" <<EOF
{
  "experiment_id": "$experiment_id",
  "data_points": [],
  "start_time": "$(date -Iseconds)",
  "collection_interval": 60,
  "total_samples": 0
}
EOF
}

# 监控活跃实验
monitor_active_experiments() {
    local active_experiments=$(get_active_experiments)

    for exp_id in $active_experiments; do
        # 收集实验数据
        collect_experiment_data "$exp_id"

        # 检查实验完成条件
        check_experiment_completion "$exp_id"
    done
}

# 获取活跃实验
get_active_experiments() {
    find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -exec jq -r 'select(.status == "running") | .experiment_id' {} \; 2>/dev/null || echo ""
}

# 收集实验数据
collect_experiment_data() {
    local experiment_id="$1"

    local data_file="$EXPERIMENT_DATA_DIR/${experiment_id}_data.json"
    local current_metrics=$(get_realtime_performance_stats)
    local timestamp=$(date -Iseconds)

    # 添加数据点
    local temp_data=$(mktemp)
    jq --arg timestamp "$timestamp" --argjson metrics "$current_metrics" '.data_points += [{"timestamp": $timestamp, "metrics": $metrics}] | .total_samples += 1' "$data_file" > "$temp_data"
    mv "$temp_data" "$data_file"
}

# 检查实验完成条件
check_experiment_completion() {
    local experiment_id="$1"

    local exp_config="$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"
    local data_file="$EXPERIMENT_DATA_DIR/${experiment_id}_data.json"

    # 检查样本大小
    local sample_size=$(jq -r '.total_samples // 0' "$data_file")
    local min_samples=$(jq -r '.parameters.min_sample_size // '$MIN_SAMPLE_SIZE'' "$exp_config")

    if (( sample_size < min_samples )); then
        return  # 样本不足，继续收集
    fi

    # 检查实验时长
    local start_time=$(jq -r '.actual_start // "'$(date -Iseconds)'"' "$exp_config")
    local duration=$(jq -r '.duration_seconds // '$DEFAULT_EXPERIMENT_DURATION'' "$exp_config")
    local elapsed=$(( $(date +%s) - $(date -d "$start_time" +%s 2>/dev/null || echo "$(date +%s)") ))

    if (( elapsed >= duration )); then
        # 实验时长到达，完成实验
        complete_experiment "$experiment_id"
    fi
}

# 完成实验
complete_experiment() {
    local experiment_id="$1"

    smart_echo "完成实验: $experiment_id" "processing"

    # 分析实验结果
    analyze_experiment_results "$experiment_id"

    # 更新实验状态
    update_experiment_status "$experiment_id" "completed"

    # 记录完成时间
    local temp_config=$(mktemp)
    jq --arg end_time "$(date -Iseconds)" '.completed_at = $end_time' "$EXPERIMENT_CONFIG_DIR/${experiment_id}.json" > "$temp_config"
    mv "$temp_config" "$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"

    # 清理实验数据（可选）
    cleanup_experiment_data "$experiment_id"

    smart_echo "实验完成: $experiment_id" "success"
}

# 分析实验结果
analyze_experiment_results() {
    local experiment_id="$1"

    smart_echo "分析实验结果: $experiment_id" "info"

    local exp_config="$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"
    local data_file="$EXPERIMENT_DATA_DIR/${experiment_id}_data.json"

    # 提取实验数据
    local baseline_metrics=$(jq -r '.baseline_metrics' "$exp_config")
    local experiment_data=$(jq -r '.data_points' "$data_file")

    # 执行统计分析
    local analysis_result=$(perform_statistical_analysis "$baseline_metrics" "$experiment_data")

    # 保存分析结果
    local results_file="$EXPERIMENT_RESULTS_DIR/${experiment_id}_results.json"
    echo "$analysis_result" > "$results_file"

    # 更新实验配置中的结果
    local temp_config=$(mktemp)
    jq --argjson results "$analysis_result" '.results = $results' "$exp_config" > "$temp_config"
    mv "$temp_config" "$exp_config"

    smart_echo "实验结果分析完成" "info"
}

# 执行统计分析
perform_statistical_analysis() {
    local baseline="$1"
    local experiment_data="$2"

    # 简化的统计分析（实际应该使用更复杂的统计方法）
    local baseline_avg=$(echo "$baseline" | jq -r '.aggregates.avg_response_time // 1000')
    local experiment_avgs=$(echo "$experiment_data" | jq -r 'map(.metrics.aggregates.avg_response_time // 1000) | .[]' | paste -sd+ | bc 2>/dev/null || echo "0")
    local experiment_count=$(echo "$experiment_data" | jq 'length')

    local experiment_avg=0
    if (( experiment_count > 0 )); then
        experiment_avg=$(echo "scale=2; $experiment_avgs / $experiment_count" | bc 2>/dev/null || echo "0")
    fi

    # 计算改进百分比
    local improvement=0
    if (( baseline_avg > 0 )); then
        improvement=$(echo "scale=3; ($baseline_avg - $experiment_avg) / $baseline_avg" | bc 2>/dev/null || echo "0")
    fi

    # 简化的统计显著性检查
    local significance=$(calculate_statistical_significance "$baseline_avg" "$experiment_avg" "$experiment_count")

    cat <<EOF
{
  "baseline_average": $baseline_avg,
  "experiment_average": $experiment_avg,
  "improvement_percentage": $improvement,
  "sample_size": $experiment_count,
  "statistical_significance": $significance,
  "confidence_level": $(calculate_confidence_level "$significance"),
  "effect_size": $(calculate_effect_size "$baseline_avg" "$experiment_avg"),
  "conclusion": "$(generate_experiment_conclusion "$improvement" "$significance")"
}
EOF
}

# 计算统计显著性（简化版）
calculate_statistical_significance() {
    local baseline="$1"
    local experiment="$2"
    local sample_size="$3"

    # 简化的显著性计算（实际应该使用t检验等方法）
    if (( sample_size < 30 )); then
        echo "0.1"  # 小样本，低显著性
    else
        local diff=$(echo "$baseline - $experiment" | bc -l 2>/dev/null || echo "0")
        if (( $(echo "$diff > 50" | bc -l 2>/dev/null || echo "0") )); then
            echo "0.01"  # 大差异，高显著性
        elif (( $(echo "$diff > 20" | bc -l 2>/dev/null || echo "0") )); then
            echo "0.05"  # 中等差异，中等显著性
        else
            echo "0.2"   # 小差异，低显著性
        fi
    fi
}

# 计算置信水平
calculate_confidence_level() {
    local significance="$1"

    if (( $(echo "$significance <= 0.01" | bc -l 2>/dev/null || echo "0") )); then
        echo "0.99"
    elif (( $(echo "$significance <= 0.05" | bc -l 2>/dev/null || echo "0") )); then
        echo "0.95"
    else
        echo "0.90"
    fi
}

# 计算效应量
calculate_effect_size() {
    local baseline="$1"
    local experiment="$2"

    if (( baseline == 0 )); then
        echo "0"
    else
        echo "scale=2; ($baseline - $experiment) / $baseline" | bc 2>/dev/null || echo "0"
    fi
}

# 生成实验结论
generate_experiment_conclusion() {
    local improvement="$1"
    local significance="$2"

    if (( $(echo "$improvement > 0.05" | bc -l 2>/dev/null || echo "0") )) && (( $(echo "$significance < 0.05" | bc -l 2>/dev/null || echo "0") )); then
        echo "实验成功：显著改进"
    elif (( $(echo "$improvement > 0.02" | bc -l 2>/dev/null || echo "0") )); then
        echo "实验部分成功：有改进但不显著"
    elif (( $(echo "$improvement > -0.02" | bc -l 2>/dev/null || echo "0") )); then
        echo "实验中性：无显著变化"
    else
        echo "实验失败：性能下降"
    fi
}

# 检查实验超时
check_experiment_timeouts() {
    local running_experiments=$(find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -exec jq -r 'select(.status == "running") | .experiment_id' {} \; 2>/dev/null)

    local current_time=$(date +%s)

    for exp_id in $running_experiments; do
        local exp_config="$EXPERIMENT_CONFIG_DIR/${exp_id}.json"
        local start_time_str=$(jq -r '.actual_start // "'$(date -Iseconds)'"' "$exp_config")
        local duration=$(jq -r '.duration_seconds // '$DEFAULT_EXPERIMENT_DURATION'' "$exp_config")

        local start_time=$(date -d "$start_time_str" +%s 2>/dev/null || echo "$current_time")
        local elapsed=$((current_time - start_time))

        if (( elapsed > duration * 2 )); then  # 超过预期时长的2倍
            smart_echo "实验超时: $exp_id" "warning"
            fail_experiment "$exp_id" "timeout"
        fi
    done
}

# 评估实验结果
evaluate_experiment_results() {
    local completed_experiments=$(find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -exec jq -r 'select(.status == "completed") | .experiment_id' {} \; 2>/dev/null)

    for exp_id in $completed_experiments; do
        local results_file="$EXPERIMENT_RESULTS_DIR/${exp_id}_results.json"

        if [[ -f "$results_file" ]]; then
            # 检查是否满足成功标准
            local conclusion=$(jq -r '.conclusion // ""' "$results_file")

            if [[ "$conclusion" == *"成功"* ]]; then
                # 实验成功，可以考虑应用更改
                smart_echo "实验成功: $exp_id - $conclusion" "success"
                # 这里可以触发优化应用逻辑
            else
                smart_echo "实验未达到预期: $exp_id - $conclusion" "info"
            fi
        fi
    done
}

# 失败实验
fail_experiment() {
    local experiment_id="$1"
    local reason="$2"

    update_experiment_status "$experiment_id" "failed"

    local temp_config=$(mktemp)
    jq --arg reason "$reason" --arg end_time "$(date -Iseconds)" '.failure_reason = $reason | .completed_at = $end_time' "$EXPERIMENT_CONFIG_DIR/${experiment_id}.json" > "$temp_config"
    mv "$temp_config" "$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"

    smart_echo "实验失败: $experiment_id ($reason)" "error"
}

# 更新实验状态
update_experiment_status() {
    local experiment_id="$1"
    local new_status="$2"

    local exp_config="$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"
    local temp_config=$(mktemp)

    jq --arg status "$new_status" ".status = \"$new_status\"" "$exp_config" > "$temp_config"
    mv "$temp_config" "$exp_config"
}

# 清理实验数据
cleanup_experiment_data() {
    local experiment_id="$1"

    # 可选：删除实验数据文件以节省空间
    # rm -f "$EXPERIMENT_DATA_DIR/${experiment_id}_data.json"
    true
}

# 🎯 实验API

# 获取实验状态
get_experiment_status() {
    local experiment_id="$1"

    if [[ -n "$experiment_id" ]]; then
        # 获取特定实验状态
        local exp_config="$EXPERIMENT_CONFIG_DIR/${experiment_id}.json"
        if [[ -f "$exp_config" ]]; then
            cat "$exp_config"
        else
            echo "{\"error\": \"Experiment not found: $experiment_id\"}"
        fi
    else
        # 获取所有实验状态
        local all_experiments=$(find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -exec jq -s '.' {} \; 2>/dev/null | jq -s 'flatten' 2>/dev/null || echo "[]")
        echo "$all_experiments"
    fi
}

# 显示实验仪表板
show_experiment_dashboard() {
    smart_echo "=== 🧪 实验框架仪表板 ===" "info"

    # 显示实验统计
    local total_experiments=$(find "$EXPERIMENT_CONFIG_DIR" -name "*.json" | wc -l)
    local running_experiments=$(find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -exec jq -r 'select(.status == "running") | .experiment_id' {} \; 2>/dev/null | wc -l)
    local completed_experiments=$(find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -exec jq -r 'select(.status == "completed") | .experiment_id' {} \; 2>/dev/null | wc -l)

    smart_echo "实验统计:" "info"
    smart_echo "  总数: $total_experiments" "info"
    smart_echo "  运行中: $running_experiments" "info"
    smart_echo "  已完成: $completed_experiments" "info"

    # 显示最近实验
    smart_echo "最近实验:" "info"
    find "$EXPERIMENT_CONFIG_DIR" -name "*.json" -printf '%T@ %p\n' | sort -nr | head -5 | while read -r timestamp file; do
        local exp_name=$(jq -r '.name // "Unknown"' "$file" 2>/dev/null)
        local exp_status=$(jq -r '.status // "unknown"' "$file" 2>/dev/null)
        smart_echo "  $exp_name: $exp_status" "info"
    done
}

# 导出函数
export -f init_experiment_framework
export -f create_experiment
export -f start_experiment
export -f get_experiment_status
export -f show_experiment_dashboard

# 初始化
init_experiment_framework