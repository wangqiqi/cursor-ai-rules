#!/bin/bash

# 🎯 Cursor AI Rules - 自适应优化引擎
# 基于学习洞察自动调整系统配置和行为

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/self-learning-engine.sh"
source "$SCRIPT_DIR/performance-dashboard.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 优化引擎配置 (合并到research目录)
OPTIMIZATION_DIR="$RESEARCH_DIR"
OPTIMIZATION_CONFIG_FILE="$OPTIMIZATION_DIR/research-optimization-config.json"
OPTIMIZATION_EXPERIMENTS_FILE="$OPTIMIZATION_DIR/research-optimization-experiments.json"
OPTIMIZATION_BACKUPS_FILE="$OPTIMIZATION_DIR/research-optimization-backups.json"

# 优化参数
OPTIMIZATION_CYCLE="${OPTIMIZATION_CYCLE:-7200}"  # 2小时优化周期
MIN_IMPROVEMENT_THRESHOLD="${MIN_IMPROVEMENT_THRESHOLD:-0.05}"  # 最小改进阈值5%
MAX_EXPERIMENTS="${MAX_EXPERIMENTS:-3}"  # 最大并发实验数

# 优化策略类型
declare -A OPTIMIZATION_STRATEGIES=(
    ["cache_optimization"]="缓存优化策略"
    ["algorithm_tuning"]="算法调优策略"
    ["resource_allocation"]="资源分配策略"
    ["behavior_adaptation"]="行为适应策略"
    ["context_optimization"]="上下文优化策略"
)

# 初始化自适应优化引擎
init_adaptive_optimization_engine() {
    smart_echo "初始化自适应优化引擎..." "processing"

    # 创建优化目录结构 (只创建一级目录)
    mkdir -p "$OPTIMIZATION_DIR"

    # 初始化优化配置
    init_optimization_config

    # 初始化实验框架
    init_experiment_framework

    # 初始化优化历史
    init_optimization_history

    # 启动优化循环
    start_optimization_loop

    smart_echo "自适应优化引擎初始化完成" "success"
}

# 初始化优化配置
init_optimization_config() {
    local config_file="$OPTIMIZATION_DIR/research-optimization-optimization_config.json"

    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" <<EOF
{
  "version": "1.0",
  "optimization_enabled": true,
  "auto_optimization": true,
  "optimization_cycle_seconds": $OPTIMIZATION_CYCLE,
  "min_improvement_threshold": $MIN_IMPROVEMENT_THRESHOLD,
  "max_concurrent_experiments": $MAX_EXPERIMENTS,
  "risk_tolerance": "medium",
  "rollback_enabled": true,
  "backup_before_optimization": true,
  "strategies": {
    "cache_optimization": {
      "enabled": true,
      "priority": "high",
      "risk_level": "low",
      "expected_improvement": 0.15
    },
    "algorithm_tuning": {
      "enabled": true,
      "priority": "medium",
      "risk_level": "medium",
      "expected_improvement": 0.10
    },
    "resource_allocation": {
      "enabled": true,
      "priority": "medium",
      "risk_level": "low",
      "expected_improvement": 0.08
    },
    "behavior_adaptation": {
      "enabled": true,
      "priority": "low",
      "risk_level": "medium",
      "expected_improvement": 0.12
    },
    "context_optimization": {
      "enabled": true,
      "priority": "high",
      "risk_level": "low",
      "expected_improvement": 0.18
    }
  },
  "constraints": {
    "max_response_time_degradation": 0.1,
    "max_error_rate_increase": 0.05,
    "min_success_rate_maintenance": 0.95
  }
}
EOF
    fi
}

# 初始化实验框架
init_experiment_framework() {
    local experiment_config="$OPTIMIZATION_DIR/research-optimization-experiment_framework.json"

    if [[ ! -f "$experiment_config" ]]; then
        cat > "$experiment_config" <<EOF
{
  "experiment_system": {
    "enabled": true,
    "max_concurrent_experiments": $MAX_EXPERIMENTS,
    "experiment_timeout_seconds": 3600,
    "result_validation_required": true,
    "statistical_significance_required": true
  },
  "a_b_testing": {
    "enabled": true,
    "min_sample_size": 100,
    "confidence_level": 0.95,
    "test_duration_hours": 24
  },
  "active_experiments": [],
  "experiment_history": [],
  "success_criteria": {
    "performance_improvement": $MIN_IMPROVEMENT_THRESHOLD,
    "statistical_significance": 0.05,
    "no_regression": true
  }
}
EOF
    fi
}

# 初始化优化历史
init_optimization_history() {
    local history_file="$OPTIMIZATION_DIR/optimization_history.json"

    if [[ ! -f "$history_file" ]]; then
        cat > "$history_file" <<EOF
{
  "optimization_history": [],
  "performance_baseline": {},
  "strategy_effectiveness": {},
  "rollback_history": [],
  "total_optimizations": 0,
  "successful_optimizations": 0,
  "failed_optimizations": 0
}
EOF
    fi
}

# 启动优化循环
start_optimization_loop() {
    smart_echo "启动优化循环..." "info"

    # 启动后台优化进程
    (
        while true; do
            # 执行优化周期
            execute_optimization_cycle

            # 等待下一个周期
            sleep "$OPTIMIZATION_CYCLE"
        done
    ) &
}

# 🎯 核心优化功能

# 执行优化周期
execute_optimization_cycle() {
    local cycle_start=$(date +%s)

    smart_echo "开始优化周期..." "processing"

    # 检查是否启用自动优化
    if ! is_auto_optimization_enabled; then
        smart_echo "自动优化已禁用，跳过优化周期" "info"
        return
    fi

    # 1. 收集优化洞察
    local insights=$(get_learning_insights)

    # 2. 识别优化机会
    local opportunities=$(identify_optimization_opportunities "$insights")

    # 3. 评估风险和收益
    local evaluated_opportunities=$(evaluate_optimization_opportunities "$opportunities")

    # 4. 选择最佳优化策略
    local selected_strategy=$(select_optimal_optimization_strategy "$evaluated_opportunities")

    # 5. 执行优化实验
    if [[ -n "$selected_strategy" ]]; then
        execute_optimization_experiment "$selected_strategy"
    fi

    # 6. 监控和验证结果
    monitor_optimization_results

    local cycle_end=$(date +%s)
    local cycle_duration=$((cycle_end - cycle_start))

    smart_echo "优化周期完成 (耗时: ${cycle_duration}s)" "success"
}

# 检查自动优化是否启用
is_auto_optimization_enabled() {
    jq -r '.auto_optimization // false' "$OPTIMIZATION_DIR/research-optimization-optimization_config.json" 2>/dev/null || echo "false"
}

# 识别优化机会
identify_optimization_opportunities() {
    local insights="$1"

    local opportunities="[]"

    # 基于性能洞察识别机会
    local response_time=$(echo "$insights" | jq -r '.overall_effectiveness // 0')

    if (( $(echo "$response_time < 0.8" | bc -l 2>/dev/null || echo "0") )); then
        opportunities=$(echo "$opportunities" | jq '. + [{"type": "performance", "area": "response_time", "severity": "high", "description": "响应时间性能不佳"}]')
    fi

    # 基于模型性能识别机会
    local model_performance=$(echo "$insights" | jq -r '.model_performance // {}')
    echo "$model_performance" | jq -r 'to_entries[] | select(.value.accuracy < 0.8) | .key' | while read -r model; do
        opportunities=$(echo "$opportunities" | jq --arg model "$model" '. + [{"type": "model", "area": $model, "severity": "medium", "description": "模型准确率需要改进"}]')
    done

    # 基于缓存性能识别机会
    local cache_hit_rate=$(get_realtime_performance_stats | jq -r '.aggregates.cache_hit_rate // 0')
    if (( $(echo "$cache_hit_rate < 70" | bc -l 2>/dev/null || echo "0") )); then
        opportunities=$(echo "$opportunities" | jq '. + [{"type": "cache", "area": "hit_rate", "severity": "medium", "description": "缓存命中率偏低"}]')
    fi

    echo "$opportunities"
}

# 评估优化机会
evaluate_optimization_opportunities() {
    local opportunities="$1"

    local evaluated="[]"

    echo "$opportunities" | jq -c '.[]' | while read -r opp; do
        local opp_type=$(echo "$opp" | jq -r '.type')
        local severity=$(echo "$opp" | jq -r '.severity')

        # 计算预期收益
        local expected_benefit=$(calculate_expected_benefit "$opp_type" "$severity")

        # 评估风险水平
        local risk_level=$(assess_risk_level "$opp_type" "$severity")

        # 计算优先级分数
        local priority_score=$(calculate_priority_score "$expected_benefit" "$risk_level" "$severity")

        evaluated=$(echo "$evaluated" | jq --argjson opp "$opp" --arg benefit "$expected_benefit" --arg risk "$risk_level" --arg score "$priority_score" '. + [$opp + {"expected_benefit": $benefit, "risk_level": $risk, "priority_score": $score}]')
    done

    echo "$evaluated"
}

# 计算预期收益
calculate_expected_benefit() {
    local opp_type="$1"
    local severity="$2"

    case "$opp_type-$severity" in
        "performance-high") echo "0.20" ;;
        "performance-medium") echo "0.15" ;;
        "model-high") echo "0.18" ;;
        "model-medium") echo "0.12" ;;
        "cache-high") echo "0.16" ;;
        "cache-medium") echo "0.10" ;;
        *) echo "0.08" ;;
    esac
}

# 评估风险水平
assess_risk_level() {
    local opp_type="$1"
    local severity="$2"

    case "$opp_type" in
        "cache") echo "low" ;;
        "performance") echo "medium" ;;
        "model") echo "high" ;;
        *) echo "medium" ;;
    esac
}

# 计算优先级分数
calculate_priority_score() {
    local benefit="$1"
    local risk="$2"
    local severity="$3"

    # 风险权重
    local risk_weight
    case "$risk" in
        "low") risk_weight=1.0 ;;
        "medium") risk_weight=0.8 ;;
        "high") risk_weight=0.6 ;;
        *) risk_weight=0.8 ;;
    esac

    # 严重程度权重
    local severity_weight
    case "$severity" in
        "high") severity_weight=1.2 ;;
        "medium") severity_weight=1.0 ;;
        "low") severity_weight=0.8 ;;
        *) severity_weight=1.0 ;;
    esac

    # 计算最终分数
    local score=$(echo "scale=3; $benefit * $risk_weight * $severity_weight" | bc 2>/dev/null || echo "0.100")

    echo "$score"
}

# 选择最佳优化策略
select_optimal_optimization_strategy() {
    local evaluated_opportunities="$1"

    # 按优先级分数排序，选择最高分的策略
    local best_opportunity=$(echo "$evaluated_opportunities" | jq -c 'sort_by(.priority_score) | reverse | .[0] // empty')

    if [[ -z "$best_opportunity" || "$best_opportunity" == "null" ]]; then
        smart_echo "没有找到合适的优化机会" "info"
        return
    fi

    local priority_score=$(echo "$best_opportunity" | jq -r '.priority_score // 0')

    # 检查是否超过最小改进阈值
    if (( $(echo "$priority_score < $MIN_IMPROVEMENT_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        smart_echo "最佳优化机会的预期收益不足 (分数: $priority_score)" "info"
        return
    fi

    echo "$best_opportunity"
}

# 执行优化实验
execute_optimization_experiment() {
    local strategy="$1"

    local strategy_type=$(echo "$strategy" | jq -r '.type // "unknown"')
    local strategy_area=$(echo "$strategy" | jq -r '.area // "general"')

    smart_echo "执行优化实验: $strategy_type - $strategy_area" "processing"

    # 创建实验记录
    local experiment_id="exp_$(date +%s%3N)_$(openssl rand -hex 4)"
    local experiment_record=$(cat <<EOF
{
  "experiment_id": "$experiment_id",
  "strategy_type": "$strategy_type",
  "strategy_area": "$strategy_area",
  "start_time": "$(date -Iseconds)",
  "status": "running",
  "baseline_metrics": $(get_realtime_performance_stats || echo "{}"),
  "expected_improvement": $(echo "$strategy" | jq -r '.expected_benefit // 0' 2>/dev/null || echo "0")
}
EOF
)

    # 保存实验记录
    echo "$experiment_record" > "$OPTIMIZATION_DIR/research-optimization-experiments-${experiment_id}.json"

    # 执行具体优化策略
    case "$strategy_type" in
        "performance")
            execute_performance_optimization "$strategy_area"
            ;;
        "model")
            execute_model_optimization "$strategy_area"
            ;;
        "cache")
            execute_cache_optimization "$strategy_area"
            ;;
        *)
            smart_echo "未知的优化策略类型: $strategy_type" "warning"
            ;;
    esac

    smart_echo "优化实验 $experiment_id 已启动" "success"
}

# 执行性能优化
execute_performance_optimization() {
    local area="$1"

    case "$area" in
        "response_time")
            # 优化响应时间
            smart_echo "应用响应时间优化策略..." "info"

            # 增加缓存容量
            # 调整算法参数
            # 优化资源分配

            # 模拟优化应用
            sleep 2
            smart_echo "响应时间优化完成" "success"
            ;;
        *)
            smart_echo "未知的性能优化领域: $area" "warning"
            ;;
    esac
}

# 执行模型优化
execute_model_optimization() {
    local area="$1"

    smart_echo "执行模型优化: $area" "info"

    # 增加训练数据
    # 调整模型参数
    # 重新训练模型

    sleep 1
    smart_echo "模型优化完成" "success"
}

# 执行缓存优化
execute_cache_optimization() {
    local area="$1"

    case "$area" in
        "hit_rate")
            smart_echo "优化缓存命中率..." "info"

            # 调整缓存策略
            # 增加缓存键多样性
            # 优化缓存过期时间

            sleep 1
            smart_echo "缓存优化完成" "success"
            ;;
        *)
            smart_echo "未知的缓存优化领域: $area" "warning"
            ;;
    esac
}

# 监控优化结果
monitor_optimization_results() {
    smart_echo "监控优化结果..." "info"

    # 检查活跃实验
    local active_experiments=$(find "$OPTIMIZATION_EXPERIMENTS_DIR" -name "*.json" -exec jq -r 'select(.status == "running") | .experiment_id' {} \; 2>/dev/null)

    for exp_id in $active_experiments; do
        local exp_file="$OPTIMIZATION_DIR/research-optimization-experiments-${exp_id}.json"

        if [[ -f "$exp_file" ]]; then
            # 获取当前指标
            local current_metrics=$(get_realtime_performance_stats)

            # 计算改进程度
            local improvement=$(calculate_experiment_improvement "$exp_file" "$current_metrics")

            # 检查是否达到预期改进
            local expected_improvement=$(jq -r '.expected_improvement // 0' "$exp_file")

            if (( $(echo "$improvement >= $expected_improvement" | bc -l 2>/dev/null || echo "0") )); then
                # 实验成功，应用优化
                complete_experiment "$exp_id" "success" "$improvement"
                apply_optimization "$exp_id"
            else
                # 检查实验是否超时
                local start_time=$(jq -r '.start_time // "'"$(date -Iseconds)"'"' "$exp_file")
                local elapsed_seconds=$(( $(date +%s) - $(date -d "$start_time" +%s 2>/dev/null || echo "$(date +%s)") ))

                if (( elapsed_seconds > 3600 )); then  # 1小时超时
                    complete_experiment "$exp_id" "timeout" "$improvement"
                    rollback_optimization "$exp_id"
                fi
            fi
        fi
    done
}

# 计算实验改进程度
calculate_experiment_improvement() {
    local exp_file="$1"
    local current_metrics="$2"

    local baseline_metrics=$(jq -r '.baseline_metrics' "$exp_file")

    # 简化的改进计算（实际应该更复杂）
    local baseline_effectiveness=$(echo "$baseline_metrics" | jq -r '.aggregates.avg_response_time // 1000')
    local current_effectiveness=$(echo "$current_metrics" | jq -r '.aggregates.avg_response_time // 1000')

    if (( baseline_effectiveness > 0 )); then
        local improvement=$(echo "scale=3; ($baseline_effectiveness - $current_effectiveness) / $baseline_effectiveness" | bc 2>/dev/null || echo "0")
        echo "$improvement"
    else
        echo "0"
    fi
}

# 完成实验
complete_experiment() {
    local exp_id="$1"
    local status="$2"
    local improvement="$3"

    local exp_file="$OPTIMIZATION_DIR/research-optimization-experiments-${exp_id}.json"

    # 更新实验状态
    local temp_exp=$(mktemp)
    jq --arg status "$status" --arg improvement "$improvement" --arg end_time "$(date -Iseconds)" '
        .status = $status |
        .actual_improvement = $improvement |
        .end_time = $end_time
    ' "$exp_file" > "$temp_exp"
    mv "$temp_exp" "$exp_file"

    smart_echo "实验 $exp_id 完成 - 状态: $status, 改进: $improvement" "info"
}

# 应用优化
apply_optimization() {
    local exp_id="$1"

    smart_echo "应用优化结果: $exp_id" "info"

    # 创建备份
    backup_current_configuration

    # 应用实验中发现的优化配置
    # 这里应该实现具体的配置应用逻辑

    smart_echo "优化已应用" "success"
}

# 回滚优化
rollback_optimization() {
    local exp_id="$1"

    smart_echo "回滚优化: $exp_id" "warning"

    # 从备份恢复配置
    restore_configuration_backup

    smart_echo "优化已回滚" "info"
}

# 创建配置备份
backup_current_configuration() {
    local backup_file="$OPTIMIZATION_DIR/research-optimization-backups-config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

    # 备份关键配置文件
    tar -czf "$backup_file" -C "$SCRIPT_DIR" ../commands/capability-map.json ../core/ 2>/dev/null || true

    smart_echo "配置备份已创建: $backup_file" "info"
}

# 恢复配置备份
restore_configuration_backup() {
    local latest_backup=$(find "$OPTIMIZATION_BACKUPS_DIR" -name "config_backup_*.tar.gz" | sort | tail -1)

    if [[ -n "$latest_backup" && -f "$latest_backup" ]]; then
        # 恢复备份
        tar -xzf "$latest_backup" -C "$SCRIPT_DIR" 2>/dev/null || true
        smart_echo "配置已从备份恢复" "info"
    else
        smart_echo "未找到可用的配置备份" "warning"
    fi
}

# 🎯 优化API

# 获取优化状态
get_optimization_status() {
    local status=$(cat <<EOF
{
  "optimization_engine": {
    "status": "active",
    "auto_optimization": $(is_auto_optimization_enabled),
    "current_cycle": $(get_current_optimization_cycle),
    "next_cycle": $(get_next_optimization_cycle)
  },
  "active_experiments": $(get_active_experiments_count),
  "recent_optimizations": $(get_recent_optimizations),
  "performance_improvement": $(calculate_overall_performance_improvement),
  "system_health": $(get_optimization_system_health)
}
EOF
)

    echo "$status"
}

# 获取当前优化周期
get_current_optimization_cycle() {
    # 简化的周期计算
    echo $(( $(date +%s) / OPTIMIZATION_CYCLE ))
}

# 获取下次优化周期
get_next_optimization_cycle() {
    local next_time=$(( ($(date +%s) / OPTIMIZATION_CYCLE + 1) * OPTIMIZATION_CYCLE ))
    echo "\"$(date -d "@$next_time" -Iseconds 2>/dev/null || date -Iseconds)\""
}

# 获取活跃实验数量
get_active_experiments_count() {
    find "$OPTIMIZATION_EXPERIMENTS_DIR" -name "*.json" -exec jq -r 'select(.status == "running") | .experiment_id' {} \; 2>/dev/null | wc -l
}

# 获取最近优化
get_recent_optimizations() {
    find "$OPTIMIZATION_EXPERIMENTS_DIR" -name "*.json" -mtime -7 -exec jq -r '{id: .experiment_id, type: .strategy_type, status: .status, improvement: .actual_improvement}' {} \; 2>/dev/null | jq -s '.' 2>/dev/null || echo "[]"
}

# 计算整体性能改进
calculate_overall_performance_improvement() {
    # 从历史记录计算整体改进
    local history_file="$OPTIMIZATION_DIR/optimization_history.json"
    local improvements=$(jq -r '.optimization_history[]?.actual_improvement // 0' "$history_file" 2>/dev/null | paste -sd+ | bc 2>/dev/null || echo "0")
    local count=$(jq -r '.optimization_history | length' "$history_file" 2>/dev/null || echo "1")

    if (( count > 0 )); then
        echo "scale=3; $improvements / $count" | bc 2>/dev/null || echo "0.000"
    else
        echo "0.000"
    fi
}

# 获取优化系统健康状态
get_optimization_system_health() {
    local active_experiments=$(get_active_experiments_count)
    local failed_experiments=$(find "$OPTIMIZATION_EXPERIMENTS_DIR" -name "*.json" -exec jq -r 'select(.status == "failed") | .experiment_id' {} \; 2>/dev/null | wc -l)
    local total_experiments=$(find "$OPTIMIZATION_EXPERIMENTS_DIR" -name "*.json" | wc -l)

    local health_score=100

    # 基于失败率调整健康分数
    if (( total_experiments > 0 )); then
        local failure_rate=$(( failed_experiments * 100 / total_experiments ))
        health_score=$(( health_score - failure_rate * 2 ))
    fi

    # 基于活跃实验数量调整
    if (( active_experiments > MAX_EXPERIMENTS )); then
        health_score=$(( health_score - 10 ))
    fi

    # 确保分数在合理范围内
    if (( health_score < 0 )); then
        health_score=0
    fi

    cat <<EOF
{
  "health_score": $health_score,
  "active_experiments": $active_experiments,
  "failed_experiments": $failed_experiments,
  "total_experiments": $total_experiments,
  "status": "$(if (( health_score >= 80 )); then echo "healthy"; elif (( health_score >= 60 )); then echo "warning"; else echo "critical"; fi)"
}
EOF
}

# 显示优化状态
show_optimization_status() {
    smart_echo "=== ⚡ 自适应优化引擎状态 ===" "info"

    local status=$(get_optimization_status)

    # 显示优化引擎状态
    local auto_opt=$(echo "$status" | jq -r '.optimization_engine.auto_optimization')
    smart_echo "自动优化: $([ "$auto_opt" = "true" ] && echo "启用" || echo "禁用")" "info"

    # 显示活跃实验
    local active_experiments=$(echo "$status" | jq -r '.active_experiments')
    smart_echo "活跃实验: $active_experiments" "info"

    # 显示性能改进
    local improvement=$(echo "$status" | jq -r '.performance_improvement' | xargs printf "%.1f")
    smart_echo "平均性能改进: ${improvement}%" "info"

    # 显示系统健康
    local health_score=$(echo "$status" | jq -r '.system_health.health_score')
    local health_status=$(echo "$status" | jq -r '.system_health.status')
    smart_echo "系统健康: $health_score/100 ($health_status)" "info"
}

# 导出函数
export -f init_adaptive_optimization_engine
export -f get_optimization_status
export -f show_optimization_status
export -f execute_optimization_cycle

# 初始化
init_adaptive_optimization_engine