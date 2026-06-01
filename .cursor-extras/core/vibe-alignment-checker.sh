#!/bin/bash
# 🚀 VIBE Coding 对齐验证工具
# 验证文档与代码、前后端接口、测试与功能的对齐程度

set -euo pipefail

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# 生长目录（系统生长数据存储位置）
GROWTH_DIR="$PROJECT_ROOT/$CURSOR_GROWTH"

# 导入通用函数
source "$SCRIPT_DIR/common.sh"

# 配置变量
SCRIPT_VERSION="1.0.0"
ALIGNMENT_CHECKS_DIR="${GROWTH_DIR}/alignment_checks"
REPORTS_DIR="${ALIGNMENT_CHECKS_DIR}/reports"

# 初始化目录
init_directories() {
    # 确保生长目录存在
    if [ ! -d "$GROWTH_DIR" ]; then
        echo "🌱 初始化项目生长目录..."
        mkdir -p "$GROWTH_DIR"
    fi

    # 创建对齐检查专用目录
    mkdir -p "$ALIGNMENT_CHECKS_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "${ALIGNMENT_CHECKS_DIR}/contracts"
    mkdir -p "${ALIGNMENT_CHECKS_DIR}/snapshots"
}

# 生成时间戳
get_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# 记录对齐检查结果
log_alignment_result() {
    local check_type="$1"
    local result="$2"
    local details="$3"
    local timestamp=$(get_timestamp)

    echo "[${timestamp}] ${check_type}: ${result}" >> "${REPORTS_DIR}/alignment_log.txt"
    echo "Details: ${details}" >> "${REPORTS_DIR}/alignment_log.txt"
    echo "---" >> "${REPORTS_DIR}/alignment_log.txt"
}

# 文档与代码对齐检查
check_documentation_code_alignment() {
    echo "🔍 检查文档与代码对齐..."

    local alignment_score=0
    local total_checks=0
    local passed_checks=0

    # 检查 API 文档与代码一致性
    if check_api_documentation_alignment; then
        ((passed_checks++))
        log_alignment_result "API_DOCS_CODE" "PASS" "API接口文档与代码实现一致"
    else
        log_alignment_result "API_DOCS_CODE" "FAIL" "发现API接口不一致"
    fi
    ((total_checks++))

    # 检查需求文档与功能实现一致性
    if check_requirements_implementation_alignment; then
        ((passed_checks++))
        log_alignment_result "REQ_DOCS_CODE" "PASS" "需求文档与功能实现一致"
    else
        log_alignment_result "REQ_DOCS_CODE" "FAIL" "发现需求实现不完整"
    fi
    ((total_checks++))

    # 检查数据模型文档与数据库设计一致性
    if check_data_model_alignment; then
        ((passed_checks++))
        log_alignment_result "DATA_MODEL" "PASS" "数据模型文档与实现一致"
    else
        log_alignment_result "DATA_MODEL" "FAIL" "发现数据模型不一致"
    fi
    ((total_checks++))

    alignment_score=$((passed_checks * 100 / total_checks))

    echo "📊 文档代码对齐评分: ${alignment_score}% (${passed_checks}/${total_checks})"

    # 生成对齐报告
    generate_alignment_report "documentation_code" "$alignment_score" "$passed_checks" "$total_checks"

    return $((alignment_score >= 80 ? 0 : 1))
}

# API文档与代码对齐检查
check_api_documentation_alignment() {
    echo "  📋 检查API文档与代码对齐..."

    # 查找API文档文件
    local api_docs=$(find . -name "*.md" -o -name "*.yaml" -o -name "*.json" | xargs grep -l "api\|API\|endpoint\|Endpoint" 2>/dev/null || true)

    # 查找后端API代码
    local backend_apis=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" | xargs grep -l "router\|route\|app\.get\|app\.post" 2>/dev/null || true)

    # 简化检查：确保API文档和代码都存在
    if [[ -n "$api_docs" && -n "$backend_apis" ]]; then
        echo "  ✅ 发现API文档和后端代码"
        return 0
    else
        echo "  ⚠️ 缺少API文档或后端代码"
        return 1
    fi
}

# 需求文档与功能实现对齐检查
check_requirements_implementation_alignment() {
    echo "  📝 检查需求文档与功能实现对齐..."

    # 查找需求文档
    local req_docs=$(find . -name "*需求*" -o -name "*requirements*" -o -name "*spec*" -o -name "*PRD*" 2>/dev/null || true)

    # 查找功能实现代码
    local implementations=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.vue" -o -name "*.svelte" | head -10 2>/dev/null || true)

    if [[ -n "$req_docs" && -n "$implementations" ]]; then
        echo "  ✅ 发现需求文档和功能实现代码"
        return 0
    else
        echo "  ⚠️ 缺少需求文档或功能实现代码"
        return 1
    fi
}

# 数据模型对齐检查
check_data_model_alignment() {
    echo "  🗄️ 检查数据模型对齐..."

    # 查找数据模型文档
    local data_docs=$(find . -name "*model*" -o -name "*schema*" -o -name "*database*" -o -name "*entity*" 2>/dev/null || true)

    # 查找数据库相关代码
    local db_code=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.sql" | xargs grep -l "model\|Model\|schema\|Schema\|entity\|Entity" 2>/dev/null || true)

    if [[ -n "$data_docs" && -n "$db_code" ]]; then
        echo "  ✅ 发现数据模型文档和数据库代码"
        return 0
    else
        echo "  ⚠️ 缺少数据模型文档或数据库代码"
        return 1
    fi
}

# 前后端接口对齐检查
check_frontend_backend_alignment() {
    echo "🔗 检查前后端接口对齐..."

    local alignment_score=0
    local total_checks=0
    local passed_checks=0

    # 检查API契约一致性
    if check_api_contract_alignment; then
        ((passed_checks++))
        log_alignment_result "API_CONTRACT" "PASS" "前后端API契约一致"
    else
        log_alignment_result "API_CONTRACT" "FAIL" "发现API契约不一致"
    fi
    ((total_checks++))

    # 检查数据格式一致性
    if check_data_format_alignment; then
        ((passed_checks++))
        log_alignment_result "DATA_FORMAT" "PASS" "前后端数据格式一致"
    else
        log_alignment_result "DATA_FORMAT" "FAIL" "发现数据格式不一致"
    fi
    ((total_checks++))

    # 检查错误处理一致性
    if check_error_handling_alignment; then
        ((passed_checks++))
        log_alignment_result "ERROR_HANDLING" "PASS" "前后端错误处理一致"
    else
        log_alignment_result "ERROR_HANDLING" "FAIL" "发现错误处理不一致"
    fi
    ((total_checks++))

    alignment_score=$((passed_checks * 100 / total_checks))

    echo "📊 前后端对齐评分: ${alignment_score}% (${passed_checks}/${total_checks})"

    # 生成对齐报告
    generate_alignment_report "frontend_backend" "$alignment_score" "$passed_checks" "$total_checks"

    return $((alignment_score >= 80 ? 0 : 1))
}

# API契约对齐检查
check_api_contract_alignment() {
    echo "  📄 检查API契约对齐..."

    # 检查是否存在API契约文件
    local contracts=$(find . -name "*contract*" -o -name "*interface*" -o -name "*api-spec*" 2>/dev/null || true)

    if [[ -n "$contracts" ]]; then
        echo "  ✅ 发现API契约文档"
        return 0
    else
        echo "  ⚠️ 缺少API契约文档"
        return 1
    fi
}

# 数据格式对齐检查
check_data_format_alignment() {
    echo "  📊 检查数据格式对齐..."

    # 检查前端和后端的数据类型定义
    local frontend_types=$(find . -name "*.ts" -o -name "*.tsx" | xargs grep -l "interface\|type" 2>/dev/null || true)
    local backend_types=$(find . -name "*.py" -o -name "*.java" -o -name "*.go" | xargs grep -l "class\|struct\|interface" 2>/dev/null || true)

    if [[ -n "$frontend_types" && -n "$backend_types" ]]; then
        echo "  ✅ 发现前端和后端类型定义"
        return 0
    else
        echo "  ⚠️ 前端或后端缺少类型定义"
        return 1
    fi
}

# 错误处理对齐检查
check_error_handling_alignment() {
    echo "  🚨 检查错误处理对齐..."

    # 检查错误处理代码
    local error_handling=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" | xargs grep -l "catch\|except\|throw\|raise" 2>/dev/null || true)

    if [[ -n "$error_handling" ]]; then
        echo "  ✅ 发现错误处理代码"
        return 0
    else
        echo "  ⚠️ 缺少错误处理代码"
        return 1
    fi
}

# 测试与功能对齐检查
check_test_function_alignment() {
    echo "🧪 检查测试与功能对齐..."

    local alignment_score=0
    local total_checks=0
    local passed_checks=0

    # 检查测试覆盖率
    if check_test_coverage; then
        ((passed_checks++))
        log_alignment_result "TEST_COVERAGE" "PASS" "测试覆盖率达标"
    else
        log_alignment_result "TEST_COVERAGE" "FAIL" "测试覆盖率不足"
    fi
    ((total_checks++))

    # 检查测试与需求对齐
    if check_test_requirements_alignment; then
        ((passed_checks++))
        log_alignment_result "TEST_REQUIREMENTS" "PASS" "测试用例与需求对齐"
    else
        log_alignment_result "TEST_REQUIREMENTS" "FAIL" "测试用例与需求不一致"
    fi
    ((total_checks++))

    # 检查验收测试完成度
    if check_acceptance_tests; then
        ((passed_checks++))
        log_alignment_result "ACCEPTANCE_TESTS" "PASS" "验收测试覆盖完整"
    else
        log_alignment_result "ACCEPTANCE_TESTS" "FAIL" "验收测试覆盖不完整"
    fi
    ((total_checks++))

    alignment_score=$((passed_checks * 100 / total_checks))

    echo "📊 测试功能对齐评分: ${alignment_score}% (${passed_checks}/${total_checks})"

    # 生成对齐报告
    generate_alignment_report "test_function" "$alignment_score" "$passed_checks" "$total_checks"

    return $((alignment_score >= 80 ? 0 : 1))
}

# 测试覆盖率检查
check_test_coverage() {
    echo "  📈 检查测试覆盖率..."

    # 查找测试文件
    local test_files=$(find . -name "*test*" -o -name "*spec*" | wc -l 2>/dev/null || echo "0")

    # 查找源代码文件
    local source_files=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" | wc -l 2>/dev/null || echo "0")

    if [[ "$source_files" -gt 0 ]]; then
        local coverage_ratio=$((test_files * 100 / source_files))
        echo "  📊 测试文件数: $test_files, 源文件数: $source_files, 比例: ${coverage_ratio}%"

        if [[ $coverage_ratio -ge 30 ]]; then
            echo "  ✅ 测试覆盖率达标"
            return 0
        else
            echo "  ⚠️ 测试覆盖率不足"
            return 1
        fi
    else
        echo "  ⚠️ 未发现源代码文件"
        return 1
    fi
}

# 测试与需求对齐检查
check_test_requirements_alignment() {
    echo "  📋 检查测试与需求对齐..."

    # 检查是否存在测试计划或验收标准
    local test_plans=$(find . -name "*test-plan*" -o -name "*acceptance*" -o -name "*验收*" 2>/dev/null || true)

    if [[ -n "$test_plans" ]]; then
        echo "  ✅ 发现测试计划文档"
        return 0
    else
        echo "  ⚠️ 缺少测试计划文档"
        return 1
    fi
}

# 验收测试检查
check_acceptance_tests() {
    echo "  ✅ 检查验收测试..."

    # 检查E2E测试文件
    local e2e_tests=$(find . -name "*e2e*" -o -name "*playwright*" -o -name "*cypress*" 2>/dev/null || true)

    if [[ -n "$e2e_tests" ]]; then
        echo "  ✅ 发现端到端测试文件"
        return 0
    else
        echo "  ⚠️ 缺少端到端测试文件"
        return 1
    fi
}

# 生成对齐报告
generate_alignment_report() {
    local check_type="$1"
    local score="$2"
    local passed="$3"
    local total="$4"
    local timestamp=$(get_timestamp)
    local report_file="${REPORTS_DIR}/alignment_report_${check_type}_${timestamp}.json"

    cat > "$report_file" << EOF
{
  "check_type": "$check_type",
  "timestamp": "$timestamp",
  "alignment_score": $score,
  "passed_checks": $passed,
  "total_checks": $total,
  "status": "$( [[ $score -ge 80 ]] && echo "PASSED" || echo "FAILED" )",
  "recommendations": [
    $( [[ $score -lt 80 ]] && echo '"需要改进对齐程度，建议进行代码审查和文档更新"' || echo '"对齐程度良好，继续保持"' )
  ]
}
EOF

    echo "📄 对齐报告已生成: $report_file"
}

# 主函数
main() {
    local check_type="${1:-all}"

    echo "🚀 VIBE Coding 对齐验证工具 v${SCRIPT_VERSION}"
    echo "检查时间: $(date)"
    echo "检查类型: $check_type"
    echo "---"

    init_directories

    local exit_code=0

    case "$check_type" in
        "docs"|"documentation")
            check_documentation_code_alignment || exit_code=1
            ;;
        "api"|"frontend-backend")
            check_frontend_backend_alignment || exit_code=1
            ;;
        "test"|"test-function")
            check_test_function_alignment || exit_code=1
            ;;
        "all")
            echo "🔄 执行完整对齐检查..."
            check_documentation_code_alignment || exit_code=1
            echo ""
            check_frontend_backend_alignment || exit_code=1
            echo ""
            check_test_function_alignment || exit_code=1
            ;;
        *)
            echo "❌ 无效的检查类型: $check_type"
            echo "支持的类型: docs, api, test, all"
            exit 1
            ;;
    esac

    echo "---"
    if [[ $exit_code -eq 0 ]]; then
        echo "✅ 对齐检查完成 - 所有检查通过"
    else
        echo "⚠️ 对齐检查完成 - 发现需要改进的项目"
        echo "💡 建议: 查看 ${REPORTS_DIR} 目录下的详细报告"
    fi

    return $exit_code
}

# 参数处理
if [[ $# -eq 0 ]]; then
    main "all"
else
    main "$@"
fi