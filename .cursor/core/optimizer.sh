#!/bin/bash

# 🎯 Cursor AI Rules - 统一优化控制器
# 整合所有性能优化功能，提供简单易用的接口

set -e

# 加载所有优化模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/compact-output.sh"
source "$SCRIPT_DIR/batch-executor.sh"
source "$SCRIPT_DIR/performance-monitor.sh"
source "$SCRIPT_DIR/token-compression.sh"

# 优化配置
OPTIMIZATION_LEVEL="${OPTIMIZATION_LEVEL:-balanced}"  # minimal, balanced, aggressive, maximum
AUTO_OPTIMIZE="${AUTO_OPTIMIZE:-true}"

# 优化策略配置
declare -A OPTIMIZATION_STRATEGIES=(
    ["minimal"]="COMPACT_MODE=false; CACHE_TTL=60; MAX_PARALLEL=1"
    ["balanced"]="COMPACT_MODE=true; CACHE_TTL=300; MAX_PARALLEL=2"
    ["aggressive"]="COMPACT_MODE=true; CACHE_TTL=600; MAX_PARALLEL=4"
    ["maximum"]="COMPACT_MODE=true; CACHE_TTL=1800; MAX_PARALLEL=8"
)

# 初始化优化系统
init_optimizer() {
    smart_echo "初始化统一优化系统..." "processing"

    # 初始化各个子系统
    init_cache
    init_monitoring
    init_compression
    init_streaming
    init_incremental_updates
    init_predictive_preload
    auto_select_mode

    # 应用优化策略
    apply_optimization_strategy "$OPTIMIZATION_LEVEL"

    smart_echo "优化系统初始化完成" "success"
}

# 应用优化策略
apply_optimization_strategy() {
    local strategy="$1"

    if [ -z "${OPTIMIZATION_STRATEGIES[$strategy]}" ]; then
        smart_echo "未知优化策略: $strategy" "warning"
        return 1
    fi

    # 解析策略配置
    local config="${OPTIMIZATION_STRATEGIES[$strategy]}"
    while IFS=';' read -ra PAIR; do
        for pair in "${PAIR[@]}"; do
            if [[ $pair =~ ^([^=]+)=(.*)$ ]]; then
                local var="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                export "$var"="$value"
            fi
        done
    done <<< "$config"

    smart_echo "已应用优化策略: $strategy" "info"
}

# 智能执行（整合所有优化）
optimized_execute() {
    local user_input="$1"
    local start_time=$(date +%s)

    # 1. 快速意图分析（使用缓存）
    local intent_result=$(cached_intent_analysis "$user_input")
    local intent_type=$(echo "$intent_result" | jq -r '.quick_intent_analysis.intent_type // .intent_analysis.intent_type // "unknown"' 2>/dev/null)

    # 2. 环境感知（使用缓存）
    local env_result=$(cached_env_perception)

    # 3. 智能决策制定
    local decision_result=$(make_quick_decision "$intent_result" "$env_result")

    # 4. 显示精简分析结果
    show_compact_analysis "$intent_result" "$env_result" "$decision_result"

    # 5. 优化执行策略
    local should_execute=$(echo "$decision_result" | jq -r '.decision_making.should_execute')
    if [ "$should_execute" = "true" ]; then
        optimized_decision_execute "$decision_result"
    fi

    # 6. 高级token压缩和流式输出
    local response_data="{
        \"intent_analysis\": $intent_result,
        \"environment_analysis\": $env_result,
        \"decision_making\": $decision_result,
        \"execution_time_ms\": $(($(date +%s) - start_time))
    }"

    # 应用token压缩
    local compressed_response=$(execute_optimized "response_generation" "$response_data" "technical")
    end_streaming

    # 7. 记录性能指标
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local original_tokens=$(estimate_tokens "response" "${#response_data}")
    local compressed_tokens=$(estimate_tokens "compressed_response" "${#compressed_response}")
    local tokens_saved=$((original_tokens - compressed_tokens))

    log_performance_metric "optimized_execute" "$duration" "$(get_memory_usage)" "$(get_cpu_usage)" "success"
    log_token_usage "optimized_execute" "$compressed_tokens" "$original_tokens" "false"

    # 8. 更新监控指标
    update_metrics

    smart_echo "优化执行完成 (${duration}ms, ${compressed_tokens}/${original_tokens} tokens, 节省: ${tokens_saved})" "success"
}

# 快速决策制定（简化版）
make_quick_decision() {
    local intent_json="$1"
    local env_json="$2"

    local intent_type=$(echo "$intent_json" | jq -r '.quick_intent_analysis.intent_type // .intent_analysis.intent_type // "unknown"')
    local confidence=$(echo "$intent_json" | jq -r '.quick_intent_analysis.confidence // .intent_analysis.confidence // 0')

    local should_execute=true
    local execution_plan="[]"
    local explanation=""

    case "$intent_type" in
        "project_creation")
            execution_plan="[\"env_check\"]"
            explanation="快速环境检查"
            ;;
        "code_optimization")
            execution_plan="[\"quick_lint\"]"
            explanation="快速代码检查"
            ;;
        "git_operation")
            execution_plan="[\"git_status\"]"
            explanation="Git状态检查"
            ;;
        "unknown")
            should_execute=false
            explanation="无法识别意图"
            ;;
        *)
            execution_plan="[\"env_check\"]"
            explanation="通用环境检查"
            ;;
    esac

    cat << EOF
{
  "decision_making": {
    "should_execute": $should_execute,
    "execution_plan": $execution_plan,
    "explanation": "$explanation",
    "intent_type": "$intent_type",
    "confidence": $confidence
  }
}
EOF
}

# 批量优化执行
batch_optimize() {
    local operations="$1"

    smart_echo "开始批量优化执行..." "processing"

    # 解析操作列表
    echo "$operations" | jq -c '.[]' | while read -r op; do
        local op_type=$(echo "$op" | jq -r '.type')
        local op_params=$(echo "$op" | jq -r '.params // ""')

        batch_add "$op_type" "$op_params"
    done

    # 执行批量操作
    batch_execute
}

# 性能分析和报告
performance_analysis() {
    echo "🔍 性能深度分析"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 显示性能报告
    show_performance_report

    echo ""
    echo "💾 缓存状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ls -la $CURSOR_GROWTH/analytics/cache/ 2>/dev/null | wc -l | xargs echo "分析缓存文件数量:"

    echo ""
    echo "🎯 优化建议"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 基于当前指标提供建议
    local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent // 0' "$METRICS_FILE" 2>/dev/null)
    local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms // 0' "$METRICS_FILE" 2>/dev/null)

    if [ "$cache_hit_rate" -lt 50 ]; then
        echo "• 考虑增加缓存有效期或启用更激进的缓存策略"
    fi

    if [ "$avg_response_time" -gt 1500 ]; then
        echo "• 建议启用精简输出模式或增加并行处理"
    fi

    if [ "$COMPACT_MODE" = false ]; then
        echo "• 考虑切换到精简输出模式以减少token消耗"
    fi
}

# 一键系统优化
system_optimize() {
    smart_echo "开始系统优化..." "processing"

    # 1. 清理过期缓存
    clean_expired_cache
    smart_echo "缓存清理完成" "success"

    # 2. 更新性能指标
    update_metrics
    smart_echo "性能指标更新完成" "success"

    # 3. 健康检查
    if health_check >/dev/null 2>&1; then
        smart_echo "系统健康检查通过" "success"
    else
        smart_echo "发现系统问题，请检查" "warning"
    fi

    # 4. 自动调整优化策略
    if [ "$AUTO_OPTIMIZE" = true ]; then
        auto_adjust_strategy
    fi

    smart_echo "系统优化完成" "success"
}

# 自动调整优化策略
auto_adjust_strategy() {
    local current_strategy="$OPTIMIZATION_LEVEL"
    local new_strategy="$current_strategy"

    # 基于性能指标调整策略
    local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms // 1000' "$METRICS_FILE" 2>/dev/null)
    local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent // 50' "$METRICS_FILE" 2>/dev/null)
    local error_rate=$(jq -r '.performance_metrics.error_rate_percent // 5' "$METRICS_FILE" 2>/dev/null)

    # 性能较差时升级策略
    if [ "$avg_response_time" -gt 2000 ] && [ "$current_strategy" != "maximum" ]; then
        case "$current_strategy" in
            "minimal") new_strategy="balanced" ;;
            "balanced") new_strategy="aggressive" ;;
            "aggressive") new_strategy="maximum" ;;
        esac
    fi

    # 性能良好时降级策略（节省资源）
    if [ "$avg_response_time" -lt 500 ] && [ "$cache_hit_rate" -gt 80 ] && [ "$current_strategy" != "minimal" ]; then
        case "$current_strategy" in
            "maximum") new_strategy="aggressive" ;;
            "aggressive") new_strategy="balanced" ;;
            "balanced") new_strategy="minimal" ;;
        esac
    fi

    if [ "$new_strategy" != "$current_strategy" ]; then
        apply_optimization_strategy "$new_strategy"
        OPTIMIZATION_LEVEL="$new_strategy"
        smart_echo "自动调整优化策略: $current_strategy → $new_strategy" "info"
    fi
}

# 显示优化状态
show_optimization_status() {
    echo "🎛️  优化系统状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "📊 当前配置:"
    echo "  • 优化等级: $OPTIMIZATION_LEVEL"
    echo "  • 精简模式: $COMPACT_MODE"
    echo "  • 缓存TTL: ${CACHE_TTL:-300}秒"
    echo "  • 最大并行: ${MAX_PARALLEL:-2}"
    echo "  • 自动优化: $AUTO_OPTIMIZE"

    echo ""
    echo "💾 缓存状态:"
    local cache_files=$(find $CURSOR_GROWTH/cache -name "*.cache" 2>/dev/null | wc -l)
    local cache_size=$(du -sh $CURSOR_GROWTH/cache 2>/dev/null | cut -f1)
    echo "  • 缓存文件: $cache_files 个"
    echo "  • 缓存大小: ${cache_size:-0B}"

    echo ""
    echo "📈 性能概览:"
    if [ -f "$METRICS_FILE" ]; then
        local total_interactions=$(jq -r '.total_interactions // 0' "$METRICS_FILE")
        local avg_response_time=$(jq -r '.performance_metrics.average_response_time_ms // 0' "$METRICS_FILE")
        local cache_hit_rate=$(jq -r '.performance_metrics.cache_hit_rate_percent // 0' "$METRICS_FILE")

        echo "  • 总交互: $total_interactions 次"
        echo "  • 平均响应: ${avg_response_time}ms"
        echo "  • 缓存命中: ${cache_hit_rate}%"
    else
        echo "  • 性能数据暂不可用"
    fi
}

# 主函数
main() {
    case "${1:-}" in
        "init")
            init_optimizer
            ;;
        "execute")
            shift
            optimized_execute "$*"
            ;;
        "batch")
            shift
            batch_optimize "$*"
            ;;
        "analyze"|"report")
            performance_analysis
            ;;
        "optimize")
            system_optimize
            ;;
        "status")
            show_optimization_status
            ;;
        "strategy")
            shift
            apply_optimization_strategy "${1:-balanced}"
            ;;
        "cleanup")
            clean_expired_cache
            cleanup_old_data "${2:-30}"
            smart_echo "清理完成" "success"
            ;;
        "help"|"-h"|"--help")
            show_optimizer_help
            ;;
        *)
            smart_echo "使用方法: optimizer.sh [command] [args]" "info"
            echo "运行 'optimizer.sh help' 查看详细帮助"
            ;;
    esac
}

# 显示帮助信息
show_optimizer_help() {
    cat << EOF
🎯 Cursor AI Rules - 统一优化控制器

使用方法:
  optimizer.sh <command> [options]

可用命令:
  init                    初始化优化系统
  execute <input>         优化执行用户输入
  batch <operations>      批量执行操作
  analyze/report          性能分析报告
  optimize                一键系统优化
  status                  显示优化状态
  strategy <level>        设置优化策略 (minimal/balanced/aggressive/maximum)
  cleanup [days]          清理过期数据 (默认30天)

优化策略:
  minimal     最小优化 - 基础功能
  balanced    平衡优化 - 推荐使用 (默认)
  aggressive  激进优化 - 高性能
  maximum     最大优化 - 极致性能

示例:
  # 初始化系统
  optimizer.sh init

  # 优化执行
  optimizer.sh execute "帮我检查代码质量"

  # 批量操作
  optimizer.sh batch '[{"type":"file_check","params":"*.js"},{"type":"git_status"}]'

  # 性能分析
  optimizer.sh analyze

  # 设置激进优化
  optimizer.sh strategy aggressive

  # 系统优化
  optimizer.sh optimize

环境变量:
  OPTIMIZATION_LEVEL    优化等级 (minimal/balanced/aggressive/maximum)
  AUTO_OPTIMIZE         自动优化 (true/false)
  COMPACT_MODE          精简模式 (true/false)
  CACHE_TTL             缓存有效期(秒)
  MAX_PARALLEL          最大并行数

EOF
}

# 运行主函数
main "$@"