#!/bin/bash
# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/cli-framework.sh"
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"

# 初始化CLI框架
cli_init "Test Runner"

# ========================================
# Cursor AI Rules - 测试运行器
# 统一测试执行，支持多种测试框架和测试类型
# ========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR"

source "$SCRIPT_DIR/colors.sh"

# 测试统计
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
COVERAGE_PERCENTAGE=0

# 测试结果存储
declare -A TEST_RESULTS

# 支持的测试框架
declare -A TEST_FRAMEWORKS=(
    ["jest"]="JavaScript/TypeScript"
    ["vitest"]="JavaScript/TypeScript (更快)"
    ["mocha"]="JavaScript/Node.js"
    ["jasmine"]="JavaScript"
    ["karma"]="JavaScript (浏览器测试)"
    ["pytest"]="Python"
    ["unittest"]="Python (内置)"
    ["nose"]="Python"
    ["junit"]="Java"
    ["testng"]="Java"
    ["phpunit"]="PHP"
    ["rspec"]="Ruby"
    ["go-test"]="Go (内置)"
    ["cargo-test"]="Rust (内置)"
)

# 日志函数
log_info() {
    echo -e "${BLUE}[TEST-RUNNER]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[TEST-RUNNER]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[TEST-RUNNER]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[TEST-RUNNER]${NC} ❌ $1"
}

log_debug() {
    echo -e "${CYAN}[TEST-RUNNER]${NC} 🔍 $1"
}

# 检测可用的测试框架
detect_test_frameworks() {
    log_info "检测可用的测试框架..."

    for framework in "${!TEST_FRAMEWORKS[@]}"; do
        case "$framework" in
            "jest")
                if command -v jest &> /dev/null || [ -f "node_modules/.bin/jest" ]; then
                    local version=$(jest --version 2>/dev/null | head -1 || echo "未知版本")
                    log_success "Jest 可用: $version"
                fi
                ;;
            "vitest")
                if command -v vitest &> /dev/null || [ -f "node_modules/.bin/vitest" ]; then
                    local version=$(vitest --version 2>/dev/null | head -1 || echo "未知版本")
                    log_success "Vitest 可用: $version"
                fi
                ;;
            "pytest")
                if command -v pytest &> /dev/null; then
                    local version=$(pytest --version 2>/dev/null | head -1 || echo "未知版本")
                    log_success "pytest 可用: $version"
                fi
                ;;
            "go-test")
                if command -v go &> /dev/null; then
                    local version=$(go version | awk '{print $3}')
                    log_success "Go test 可用: $version"
                fi
                ;;
            "cargo-test")
                if command -v cargo &> /dev/null; then
                    local version=$(cargo --version | awk '{print $2}')
                    log_success "Cargo test 可用: $version"
                fi
                ;;
            *)
                if command -v "$framework" &> /dev/null; then
                    local version=$($framework --version 2>/dev/null | head -1 || echo "未知版本")
                    log_success "$framework 可用: $version"
                    log_debug "支持: ${TEST_FRAMEWORKS[$framework]}"
                fi
                ;;
        esac
    done
}

# 自动检测项目类型和测试框架
auto_detect_framework() {
    log_info "自动检测项目类型和测试框架..."

    # 检查package.json (Node.js项目)
    if [ -f "package.json" ]; then
        log_debug "检测到Node.js项目"

        # 检查package.json中的测试脚本
        if grep -q '"test"' package.json && grep -q "jest\|vitest\|mocha" package.json; then
            if grep -q "vitest" package.json; then
                echo "vitest"
            elif grep -q "jest" package.json; then
                echo "jest"
            elif grep -q "mocha" package.json; then
                echo "mocha"
            fi
        fi
        return
    fi

    # 检查requirements.txt或setup.py (Python项目)
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        log_debug "检测到Python项目"

        if command -v pytest &> /dev/null; then
            echo "pytest"
        elif [ -d "tests" ] || find . -name "*test*.py" | grep -q .; then
            echo "unittest"
        fi
        return
    fi

    # 检查go.mod (Go项目)
    if [ -f "go.mod" ]; then
        log_debug "检测到Go项目"
        echo "go-test"
        return
    fi

    # 检查Cargo.toml (Rust项目)
    if [ -f "Cargo.toml" ]; then
        log_debug "检测到Rust项目"
        echo "cargo-test"
        return
    fi

    # 检查pom.xml或build.gradle (Java项目)
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        log_debug "检测到Java项目"
        echo "junit"
        return
    fi

    log_warning "无法自动检测测试框架"
    echo ""
}

# 运行Jest测试
run_jest_tests() {
    local test_pattern="${1:-**/*.test.{js,jsx,ts,tsx}}"
    local coverage="${2:-false}"

    log_info "运行Jest测试..."

    local jest_cmd="jest"
    if [ -f "node_modules/.bin/jest" ]; then
        jest_cmd="node_modules/.bin/jest"
    elif ! command -v jest &> /dev/null; then
        log_error "Jest未找到，请确保已安装"
        return 1
    fi

    local cmd="$jest_cmd --testPathPattern=\"$test_pattern\""
    if [ "$coverage" = "true" ]; then
        cmd="$cmd --coverage"
    fi

    log_debug "执行命令: $cmd"

    if eval "$cmd"; then
        log_success "Jest测试通过"
        return 0
    else
        log_error "Jest测试失败"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 运行Vitest测试
run_vitest_tests() {
    local test_pattern="${1:-**/*.test.{js,jsx,ts,tsx}}"
    local coverage="${2:-false}"

    log_info "运行Vitest测试..."

    local vitest_cmd="vitest"
    if [ -f "node_modules/.bin/vitest" ]; then
        vitest_cmd="node_modules/.bin/vitest"
    elif ! command -v vitest &> /dev/null; then
        log_error "Vitest未找到，请确保已安装"
        return 1
    fi

    local cmd="$vitest_cmd run"
    if [ "$coverage" = "true" ]; then
        cmd="$cmd --coverage"
    fi

    log_debug "执行命令: $cmd"

    if eval "$cmd"; then
        log_success "Vitest测试通过"
        return 0
    else
        log_error "Vitest测试失败"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 运行pytest测试
run_pytest_tests() {
    local test_pattern="${1:-test_*.py}"
    local coverage="${2:-false}"

    log_info "运行pytest测试..."

    if ! command -v pytest &> /dev/null; then
        log_error "pytest未安装"
        return 1
    fi

    local cmd="pytest -v"
    if [ "$coverage" = "true" ]; then
        cmd="$cmd --cov=. --cov-report=term-missing"
    fi

    log_debug "执行命令: $cmd"

    if eval "$cmd"; then
        log_success "pytest测试通过"
        return 0
    else
        log_error "pytest测试失败"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 运行Go测试
run_go_tests() {
    local test_pattern="${1:-./...}"
    local coverage="${2:-false}"

    log_info "运行Go测试..."

    if ! command -v go &> /dev/null; then
        log_error "Go未安装"
        return 1
    fi

    local cmd="go test $test_pattern"
    if [ "$coverage" = "true" ]; then
        cmd="$cmd -cover"
    fi

    log_debug "执行命令: $cmd"

    if eval "$cmd"; then
        log_success "Go测试通过"
        return 0
    else
        log_error "Go测试失败"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 运行Rust测试
run_cargo_tests() {
    log_info "运行Cargo测试..."

    if ! command -v cargo &> /dev/null; then
        log_error "Cargo未安装"
        return 1
    fi

    if cargo test; then
        log_success "Cargo测试通过"
        return 0
    else
        log_error "Cargo测试失败"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 运行通用测试
run_generic_tests() {
    local framework="$1"
    local test_pattern="${2:-}"
    local coverage="${3:-false}"

    log_info "运行$framework测试..."

    case "$framework" in
        "jest")
            run_jest_tests "$test_pattern" "$coverage"
            ;;
        "vitest")
            run_vitest_tests "$test_pattern" "$coverage"
            ;;
        "pytest")
            run_pytest_tests "$test_pattern" "$coverage"
            ;;
        "go-test")
            run_go_tests "$test_pattern" "$coverage"
            ;;
        "cargo-test")
            run_cargo_tests
            ;;
        *)
            log_error "不支持的测试框架: $framework"
            return 1
            ;;
    esac
}

# 分析测试覆盖率
analyze_coverage() {
    local coverage_dir="${1:-coverage}"

    log_info "分析测试覆盖率..."

    if [ -d "$coverage_dir" ]; then
        # 查找覆盖率报告文件
        local coverage_file=""
        if [ -f "$coverage_dir/coverage-summary.json" ]; then
            coverage_file="$coverage_dir/coverage-summary.json"
        elif [ -f "$coverage_dir/lcov-report/index.html" ]; then
            log_info "覆盖率报告: $coverage_dir/lcov-report/index.html"
        fi

        if [ -n "$coverage_file" ] && [ -f "$coverage_file" ]; then
            # 解析JSON覆盖率报告
            if command -v jq &> /dev/null; then
                local total_coverage=$(jq '.total.lines.pct' "$coverage_file" 2>/dev/null)
                if [ -n "$total_coverage" ]; then
                    COVERAGE_PERCENTAGE=$total_coverage
                    log_success "总覆盖率: ${total_coverage}%"

                    if (( $(echo "$total_coverage >= 80" | bc -l) )); then
                        log_success "覆盖率达标 (≥80%)"
                    else
                        log_warning "覆盖率不足 (期望≥80%)"
                    fi
                fi
            else
                log_debug "安装jq可获得更详细的覆盖率分析"
            fi
        fi
    else
        log_debug "未找到覆盖率报告目录"
    fi
}

# 生成测试报告
generate_test_report() {
    log_info "生成测试报告..."

    cat << EOF
📊 测试执行报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧪 测试统计:
  📊 总测试数: $TESTS_TOTAL
  ✅ 通过数: $TESTS_PASSED
  ❌ 失败数: $TESTS_FAILED
  ⏭️  跳过数: $TESTS_SKIPPED

📈 覆盖率: ${COVERAGE_PERCENTAGE}%

🔧 支持的测试框架:
$(for framework in "${!TEST_FRAMEWORKS[@]}"; do
    case "$framework" in
        "jest")
            if command -v jest &> /dev/null || [ -f "node_modules/.bin/jest" ]; then
                echo "  ✅ $framework - ${TEST_FRAMEWORKS[$framework]}"
            fi
            ;;
        "vitest")
            if command -v vitest &> /dev/null || [ -f "node_modules/.bin/vitest" ]; then
                echo "  ✅ $framework - ${TEST_FRAMEWORKS[$framework]}"
            fi
            ;;
        "pytest")
            if command -v pytest &> /dev/null; then
                echo "  ✅ $framework - ${TEST_FRAMEWORKS[$framework]}"
            fi
            ;;
        "go-test")
            if command -v go &> /dev/null; then
                echo "  ✅ $framework - ${TEST_FRAMEWORKS[$framework]}"
            fi
            ;;
        "cargo-test")
            if command -v cargo &> /dev/null; then
                echo "  ✅ $framework - ${TEST_FRAMEWORKS[$framework]}"
            fi
            ;;
    esac
done)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# 执行完整测试流程
run_full_test_suite() {
    local framework="$1"
    local coverage="${2:-false}"

    log_info "执行完整测试流程..."

    if [ -z "$framework" ]; then
        framework=$(auto_detect_framework)
        if [ -z "$framework" ]; then
            log_error "无法确定测试框架，请手动指定"
            return 1
        fi
    fi

    log_info "使用测试框架: $framework"

    # 运行测试
    if run_generic_tests "$framework" "" "$coverage"; then
        log_success "测试执行完成"
    else
        log_error "测试执行失败"
        return 1
    fi

    # 分析覆盖率
    if [ "$coverage" = "true" ]; then
        analyze_coverage
    fi

    # 生成报告
    generate_test_report

    return 0
}

# 主函数
# 主函数 - 使用CLI框架
main() {
    # 解析CLI参数
    parse_cli_args "$@" || return 1

    # 处理全局标志
    for flag in "${CLI_FLAGS[@]}"; do
        case "$flag" in
            "help")
                cli_show_help "Test Runner" "统一测试执行，支持多种测试框架和测试类型" \
                    "run" "运行指定框架的测试" \
                    "auto" "自动检测并运行测试" \
                    "coverage" "运行测试并生成覆盖率报告" \
                    "detect" "检测可用的测试框架" \
                    "report" "生成测试报告"
                return 0
                ;;
            "version")
                cli_show_version "Test Runner"
                return 0
                ;;
        esac
    done

    # 验证命令
    cli_validate_command "run" "auto" "coverage" "detect" "report" || return 1

    # 执行命令
    case "$CLI_COMMAND" in
        "run")
            local framework="${CLI_ARGS[0]}"
            local coverage="${CLI_ARGS[1]:-false}"
            if [[ -z "$framework" ]]; then
                cli_error "请指定测试框架 (jest, vitest, pytest, go-test, cargo-test)"
                return 1
            fi
            if run_full_test_suite "$framework" "$coverage"; then
                cli_success "测试运行完成"
            else
                cli_error "测试运行失败"
                return 1
            fi
            ;;
        "detect")
            detect_test_frameworks
            ;;
        "auto")
            local framework
            framework=$(auto_detect_framework)
            if [[ -n "$framework" ]]; then
                cli_info "推荐测试框架: $framework"
                if run_full_test_suite "$framework"; then
                    cli_success "自动测试完成"
                else
                    cli_error "自动测试失败"
                    return 1
                fi
            else
                cli_error "无法自动检测测试框架"
                return 1
            fi
            ;;
        "coverage")
            if run_full_test_suite "" "true"; then
                cli_success "覆盖率测试完成"
            else
                cli_error "覆盖率测试失败"
                return 1
            fi
            ;;
        "report")
            generate_test_report
            ;;
    esac

    return 0
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi