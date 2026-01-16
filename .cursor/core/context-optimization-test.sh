#!/bin/bash

# 🎯 Cursor AI Rules - 上下文优化系统集成测试
# 验证分层加载、相关性评分、预测预加载、智能压缩等功能的集成效果

set -e

# 加载所有相关模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/context-manager.sh"
source "$SCRIPT_DIR/token-compression.sh"
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/compact-output.sh"

# 测试数据
TEST_DATA_DIR="$SCRIPT_DIR/test-data"
mkdir -p "$TEST_DATA_DIR"

# 🎯 主要测试函数

run_context_optimization_tests() {
    smart_echo "开始上下文优化系统集成测试..." "processing"

    local total_tests=0
    local passed_tests=0

    # 测试1: 上下文分层加载
    ((total_tests++))
    if test_hierarchical_context_loading; then
        ((passed_tests++))
        smart_echo "✅ 上下文分层加载测试通过" "success"
    else
        smart_echo "❌ 上下文分层加载测试失败" "error"
    fi

    # 测试2: 上下文相关性评分
    ((total_tests++))
    if test_context_relevance_scoring; then
        ((passed_tests++))
        smart_echo "✅ 上下文相关性评分测试通过" "success"
    else
        smart_echo "❌ 上下文相关性评分测试失败" "error"
    fi

    # 测试3: 预测性上下文预加载
    ((total_tests++))
    if test_predictive_context_preloading; then
        ((passed_tests++))
        smart_echo "✅ 预测性上下文预加载测试通过" "success"
    else
        smart_echo "❌ 预测性上下文预加载测试失败" "error"
    fi

    # 测试4: 智能压缩分析器
    ((total_tests++))
    if test_intelligent_compression; then
        ((passed_tests++))
        smart_echo "✅ 智能压缩分析器测试通过" "success"
    else
        smart_echo "❌ 智能压缩分析器测试失败" "error"
    fi

    # 测试5: 上下文依赖图
    ((total_tests++))
    if test_context_dependency_graph; then
        ((passed_tests++))
        smart_echo "✅ 上下文依赖图测试通过" "success"
    else
        smart_echo "❌ 上下文依赖图测试失败" "error"
    fi

    # 测试6: 上下文完整性验证
    ((total_tests++))
    if test_context_integrity_validation; then
        ((passed_tests++))
        smart_echo "✅ 上下文完整性验证测试通过" "success"
    else
        smart_echo "❌ 上下文完整性验证测试失败" "error"
    fi

    # 测试结果汇总
    smart_echo "测试完成: $passed_tests/$total_tests 通过" "$(test_pass_color $passed_tests $total_tests)"

    return $((total_tests - passed_tests))
}

# 🧪 单个测试函数

test_hierarchical_context_loading() {
    smart_echo "测试上下文分层加载..." "info"

    # 测试数据
    local operation="检查代码"
    local max_tokens=2048

    # 执行分层加载
    local result=$(load_context_hierarchically "$operation" "$max_tokens")

    # 验证结果
    if [[ -n "$result" ]] && echo "$result" | jq empty 2>/dev/null; then
        smart_echo "分层加载返回有效JSON结果" "info"
        return 0
    else
        smart_echo "分层加载返回无效结果" "error"
        return 1
    fi
}

test_context_relevance_scoring() {
    smart_echo "测试上下文相关性评分..." "info"

    # 测试数据
    local context_key="test_context"
    local operation="检查代码"
    local current_time=$(date +%s)

    # 计算相关性评分
    local score=$(calculate_context_relevance "$context_key" "$operation" "$current_time")

    # 验证评分在合理范围内
    if (( $(echo "$score >= 0.0 && $score <= 1.0" | bc -l 2>/dev/null || echo "0") )); then
        smart_echo "相关性评分在有效范围内: $score" "info"
        return 0
    else
        smart_echo "相关性评分超出范围: $score" "error"
        return 1
    fi
}

test_predictive_context_preloading() {
    smart_echo "测试预测性上下文预加载..." "info"

    # 测试数据
    local current_operation="检查代码"
    local max_tokens=1024

    # 执行预测预加载
    predictive_context_preload "$current_operation" "$max_tokens"

    smart_echo "预测预加载执行完成" "info"
    return 0
}

test_intelligent_compression() {
    smart_echo "测试智能压缩分析器..." "info"

    # 测试数据
    local test_data='{"operation": "test", "data": {"field1": "value1", "field2": "value2", "field3": "value3"}}'
    local operation="code_review"

    # 执行智能压缩
    local result=$(intelligent_compression_analyzer "$test_data" "$operation")

    # 验证结果结构
    if echo "$result" | jq -e '.compressed_data and .compression_stats' 2>/dev/null; then
        smart_echo "智能压缩返回完整结果" "info"
        return 0
    else
        smart_echo "智能压缩返回结构不完整" "error"
        return 1
    fi
}

test_context_dependency_graph() {
    smart_echo "测试上下文依赖图..." "info"

    # 构建依赖图
    build_context_dependency_graph

    # 检查依赖图文件是否存在
    if [[ -f "$CONTEXT_DEPENDENCY_FILE" ]]; then
        smart_echo "依赖图文件已创建" "info"
        return 0
    else
        smart_echo "依赖图文件未创建" "error"
        return 1
    fi
}

test_context_integrity_validation() {
    smart_echo "测试上下文完整性验证..." "info"

    # 测试数据
    local test_context='{"project_info": {"name": "test"}, "code_files": ["test.js"]}'
    local operation="检查代码"

    # 执行完整性验证
    local result=$(validate_context_integrity "$test_context" "$operation")

    # 验证结果
    if echo "$result" | jq -e '.integrity_score' 2>/dev/null; then
        smart_echo "完整性验证返回有效评分" "info"
        return 0
    else
        smart_echo "完整性验证失败" "error"
        return 1
    fi
}

# 🛠️ 辅助函数

test_pass_color() {
    local passed="$1"
    local total="$2"

    if (( passed == total )); then
        echo "success"
    elif (( passed >= total / 2 )); then
        echo "warning"
    else
        echo "error"
    fi
}

# 📊 性能基准测试

run_performance_benchmarks() {
    smart_echo "运行性能基准测试..." "processing"

    # 测试数据
    local large_context_data=$(generate_large_test_data 10000)

    # 传统压缩测试
    local start_time=$(date +%s%3N)
    local traditional_result=$(compress_tokens "balanced" <<< "$large_context_data")
    local traditional_time=$(( $(date +%s%3N) - start_time ))

    # 智能压缩测试
    start_time=$(date +%s%3N)
    local intelligent_result=$(intelligent_compression_analyzer "$large_context_data" "general")
    local intelligent_time=$(( $(date +%s%3N) - start_time ))

    # 提取智能压缩的token节省
    local intelligent_savings=$(echo "$intelligent_result" | jq -r '.compression_stats.token_savings // 0' 2>/dev/null || echo "0")

    smart_echo "性能基准测试结果:" "info"
    smart_echo "  传统压缩时间: ${traditional_time}ms" "info"
    smart_echo "  智能压缩时间: ${intelligent_time}ms" "info"
    smart_echo "  Token节省: $intelligent_savings" "info"
}

# 生成大测试数据
generate_large_test_data() {
    local size="$1"
    local data=""

    for ((i=1; i<=size/100; i++)); do
        data="${data}{\"operation\": \"test_operation_$i\", \"data\": {\"field1\": \"value1_$i\", \"field2\": \"value2_$i\", \"field3\": \"value3_$i\", \"description\": \"This is a test operation with some repeated text that should be compressed effectively by the intelligent compression system.\"}},"
    done

    echo "[${data%,}]"
}

# 🎯 端到端集成测试

run_end_to_end_test() {
    smart_echo "运行端到端集成测试..." "processing"

    # 模拟完整的工作流程
    local operation="检查代码"
    local max_tokens=4096

    # 1. 智能上下文调度器
    smart_echo "步骤1: 智能上下文调度器" "info"
    local context=$(intelligent_context_scheduler "$operation" "$max_tokens")

    # 2. 智能压缩
    smart_echo "步骤2: 智能压缩" "info"
    local compressed_result=$(intelligent_compression_analyzer "$context" "$operation")

    # 3. 上下文完整性验证
    smart_echo "步骤3: 上下文完整性验证" "info"
    local compressed_data=$(echo "$compressed_result" | jq -r '.compressed_data' 2>/dev/null)
    local integrity_result=$(validate_context_integrity "$compressed_data" "$operation")

    # 4. 验证最终结果
    smart_echo "步骤4: 结果验证" "info"
    local integrity_score=$(echo "$integrity_result" | jq -r '.integrity_score // 0' 2>/dev/null)
    local compression_savings=$(echo "$compressed_result" | jq -r '.compression_stats.token_savings // 0' 2>/dev/null)

    smart_echo "端到端测试结果:" "info"
    smart_echo "  上下文完整性评分: $integrity_score" "info"
    smart_echo "  压缩节省Token: $compression_savings" "info"

    # 验证阈值
    if (( $(echo "$integrity_score >= 0.5" | bc -l 2>/dev/null || echo "0") )) && (( compression_savings > 0 )); then
        smart_echo "✅ 端到端测试通过" "success"
        return 0
    else
        smart_echo "❌ 端到端测试失败" "error"
        return 1
    fi
}

# 🎯 主函数

main() {
    local test_type="${1:-all}"

    case "$test_type" in
        "unit")
            run_context_optimization_tests
            ;;
        "performance")
            run_performance_benchmarks
            ;;
        "e2e")
            run_end_to_end_test
            ;;
        "all")
            run_context_optimization_tests
            echo ""
            run_performance_benchmarks
            echo ""
            run_end_to_end_test
            ;;
        *)
            smart_echo "用法: $0 [unit|performance|e2e|all]" "warning"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"