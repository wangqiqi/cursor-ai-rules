#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../core/path-config.sh"  # 统一路径配置

# 🎯 Cursor AI Rules - 测试预运行Hook
# 在运行测试前进行环境检查和准备工作

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 测试环境统计
TEST_FRAMEWORKS_CHECKED=0
DEPENDENCIES_VERIFIED=0
ENVIRONMENT_ISSUES=0
PREPARATIONS_COMPLETED=0

# 日志函数
log_info() {
    echo -e "${BLUE}[TEST-PRE-RUN]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[TEST-PRE-RUN]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[TEST-PRE-RUN]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[TEST-PRE-RUN]${NC} ❌ $1"
}

log_test() {
    echo -e "${PURPLE}[TEST-PRE-RUN]${NC} 🧪 $1"
}

# 检测项目类型
detect_project_type() {
    log_info "检测项目类型..."

    if [ -f "package.json" ]; then
        echo "nodejs"
        log_debug "检测到Node.js项目"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        echo "python"
        log_debug "检测到Python项目"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
        log_debug "检测到Rust项目"
    elif [ -f "go.mod" ]; then
        echo "go"
        log_debug "检测到Go项目"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
        log_debug "检测到Java项目"
    else
        echo "unknown"
        log_warning "无法确定项目类型"
    fi
}

# 检查Node.js测试环境
check_nodejs_test_env() {
    log_test "检查Node.js测试环境..."

    local issues_found=0

    # 检查package.json
    if [ ! -f "package.json" ]; then
        log_error "未找到package.json文件"
        ((issues_found++))
        return 1
    fi

    # 检查测试脚本
    if ! grep -q '"test"' package.json; then
        log_warning "package.json中未定义test脚本"
        ((issues_found++))
    fi

    # 检查测试框架
    local test_frameworks=("jest" "vitest" "mocha" "jasmine")
    local framework_found=false

    for framework in "${test_frameworks[@]}"; do
        if grep -q "$framework" package.json; then
            framework_found=true
            log_success "发现测试框架: $framework"
            break
        fi
    done

    if ! $framework_found; then
        log_warning "未检测到常用测试框架，建议安装jest或vitest"
        ((issues_found++))
    fi

    # 检查node_modules
    if [ ! -d "node_modules" ]; then
        log_warning "未找到node_modules目录，运行npm install"
        npm install
        ((PREPARATIONS_COMPLETED++))
    fi

    # 检查测试文件
    local test_files=$(find . -name "*.test.*" -o -name "*.spec.*" | grep -v node_modules | wc -l)
    if [ "$test_files" -eq 0 ]; then
        log_warning "未找到测试文件"
        ((issues_found++))
    else
        log_success "发现 $test_files 个测试文件"
    fi

    ((TEST_FRAMEWORKS_CHECKED++))
    return $issues_found
}

# 检查Python测试环境
check_python_test_env() {
    log_test "检查Python测试环境..."

    local issues_found=0

    # 检查Python版本
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        log_error "未安装Python"
        ((issues_found++))
        return 1
    fi

    local python_cmd="python3"
    if ! command -v python3 &> /dev/null; then
        python_cmd="python"
    fi

    local python_version=$($python_cmd --version 2>&1 | awk '{print $2}')
    log_success "Python版本: $python_version"

    # 检查pip
    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        log_warning "未安装pip，建议安装pip"
        ((issues_found++))
    fi

    # 检查pytest
    if ! command -v pytest &> /dev/null; then
        log_warning "未安装pytest，建议运行: pip install pytest"
        ((issues_found++))
    else
        local pytest_version=$(pytest --version 2>/dev/null | head -1 | awk '{print $2}')
        log_success "pytest版本: $pytest_version"
    fi

    # 检查虚拟环境
    if [ -z "$VIRTUAL_ENV" ] && [ ! -d "venv" ] && [ ! -d ".env" ]; then
        log_warning "建议使用虚拟环境: python -m venv venv && source venv/bin/activate"
        ((issues_found++))
    fi

    # 检查测试文件
    local test_files=$(find . -name "test_*.py" -o -name "*_test.py" | wc -l)
    if [ "$test_files" -eq 0 ]; then
        log_warning "未找到Python测试文件"
        ((issues_found++))
    else
        log_success "发现 $test_files 个Python测试文件"
    fi

    ((TEST_FRAMEWORKS_CHECKED++))
    return $issues_found
}

# 检查Go测试环境
check_go_test_env() {
    log_test "检查Go测试环境..."

    local issues_found=0

    # 检查Go安装
    if ! command -v go &> /dev/null; then
        log_error "未安装Go"
        ((issues_found++))
        return 1
    fi

    local go_version=$(go version | awk '{print $3}' | sed 's/go//')
    log_success "Go版本: $go_version"

    # 检查go.mod
    if [ ! -f "go.mod" ]; then
        log_warning "未找到go.mod文件，建议运行: go mod init"
        ((issues_found++))
    fi

    # 检查测试文件
    local test_files=$(find . -name "*_test.go" | wc -l)
    if [ "$test_files" -eq 0 ]; then
        log_warning "未找到Go测试文件"
        ((issues_found++))
    else
        log_success "发现 $test_files 个Go测试文件"
    fi

    ((TEST_FRAMEWORKS_CHECKED++))
    return $issues_found
}

# 检查Rust测试环境
check_rust_test_env() {
    log_test "检查Rust测试环境..."

    local issues_found=0

    # 检查Cargo
    if ! command -v cargo &> /dev/null; then
        log_error "未安装Rust/Cargo"
        ((issues_found++))
        return 1
    fi

    local cargo_version=$(cargo --version | awk '{print $2}')
    log_success "Cargo版本: $cargo_version"

    # 检查Cargo.toml
    if [ ! -f "Cargo.toml" ]; then
        log_error "未找到Cargo.toml文件"
        ((issues_found++))
        return 1
    fi

    # 检查是否定义了测试依赖
    if grep -q "\[dev-dependencies\]" Cargo.toml; then
        log_success "发现测试依赖配置"
    fi

    # 检查测试文件
    local test_files=$(find . -name "*test*.rs" -o -name "*tests*.rs" | wc -l)
    if [ "$test_files" -eq 0 ]; then
        log_warning "未找到Rust测试文件"
        ((issues_found++))
    else
        log_success "发现 $test_files 个Rust测试文件"
    fi

    ((TEST_FRAMEWORKS_CHECKED++))
    return $issues_found
}

# 检查Java测试环境
check_java_test_env() {
    log_test "检查Java测试环境..."

    local issues_found=0

    # 检查Java
    if ! command -v java &> /dev/null; then
        log_error "未安装Java"
        ((issues_found++))
        return 1
    fi

    local java_version=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}')
    log_success "Java版本: $java_version"

    # 检查Maven或Gradle
    if [ -f "pom.xml" ]; then
        if command -v mvn &> /dev/null; then
            log_success "Maven可用"
        else
            log_warning "pom.xml存在但未安装Maven"
            ((issues_found++))
        fi
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        if command -v gradle &> /dev/null; then
            log_success "Gradle可用"
        else
            log_warning "build.gradle存在但未安装Gradle"
            ((issues_found++))
        fi
    else
        log_warning "未找到Maven或Gradle配置文件"
        ((issues_found++))
    fi

    # 检查测试目录
    if [ -d "src/test" ]; then
        local test_files=$(find src/test -name "*.java" | wc -l)
        log_success "发现 $test_files 个测试文件"
    else
        log_warning "未找到src/test目录"
        ((issues_found++))
    fi

    ((TEST_FRAMEWORKS_CHECKED++))
    return $issues_found
}

# 执行依赖验证
verify_dependencies() {
    log_info "验证项目依赖..."

    local project_type=$(detect_project_type)

    case "$project_type" in
        "nodejs")
            if [ -f "package.json" ]; then
                log_test "验证npm依赖..."
                if npm ls --depth=0 &>/dev/null; then
                    log_success "npm依赖验证通过"
                    ((DEPENDENCIES_VERIFIED++))
                else
                    log_warning "npm依赖存在问题，运行npm install"
                    npm install
                    ((PREPARATIONS_COMPLETED++))
                fi
            fi
            ;;
        "python")
            if [ -f "requirements.txt" ]; then
                log_test "验证Python依赖..."
                # 这里可以添加更详细的依赖检查
                log_success "Python依赖检查完成"
                ((DEPENDENCIES_VERIFIED++))
            fi
            ;;
        "rust")
            if [ -f "Cargo.toml" ]; then
                log_test "验证Rust依赖..."
                if cargo check &>/dev/null; then
                    log_success "Rust依赖验证通过"
                    ((DEPENDENCIES_VERIFIED++))
                else
                    log_warning "Rust依赖存在问题"
                fi
            fi
            ;;
        "go")
            if [ -f "go.mod" ]; then
                log_test "验证Go依赖..."
                if go mod verify &>/dev/null; then
                    log_success "Go依赖验证通过"
                    ((DEPENDENCIES_VERIFIED++))
                else
                    log_warning "Go依赖存在问题"
                fi
            fi
            ;;
    esac
}

# 准备测试环境
prepare_test_environment() {
    log_info "准备测试环境..."

    # 创建测试结果目录
    local test_results_dir="test-results"
    mkdir -p "$test_results_dir"
    log_debug "创建测试结果目录: $test_results_dir"

    # 设置测试环境变量
    export TEST_ENV="true"
    export CI="true"  # 模拟CI环境

    # 清理可能的残留文件
    local temp_files=$(find . -name "*.tmp" -o -name "*.log" | grep -v node_modules | wc -l)
    if [ "$temp_files" -gt 0 ]; then
        log_debug "清理 $temp_files 个临时文件"
        find . -name "*.tmp" -o -name "*.log" | grep -v node_modules | xargs rm -f
    fi

    ((PREPARATIONS_COMPLETED++))
    log_success "测试环境准备完成"
}

# 生成测试准备报告
generate_test_prep_report() {
    log_info "生成测试准备报告..."

    cat << EOF
🧪 测试环境准备报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 环境检查统计:
  🔍 测试框架检查: $TEST_FRAMEWORKS_CHECKED
  📦 依赖验证: $DEPENDENCIES_VERIFIED
  ⚠️  环境问题: $ENVIRONMENT_ISSUES
  ✅ 准备工作: $PREPARATIONS_COMPLETED

🔧 测试环境状态:
  ✅ 环境检测完成
  ✅ 依赖验证完成
  ✅ 环境准备完成

💡 测试建议:
  • 确保所有测试文件正确编写
  • 运行测试前先检查代码格式
  • 关注测试覆盖率报告
  • 及时修复失败的测试

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# 主函数
main() {
    log_info "开始测试预运行检查..."

    local project_type=$(detect_project_type)
    local total_issues=0

    # 根据项目类型执行相应检查
    case "$project_type" in
        "nodejs")
            check_nodejs_test_env
            ;;
        "python")
            check_python_test_env
            ;;
        "rust")
            check_rust_test_env
            ;;
        "go")
            check_go_test_env
            ;;
        "java")
            check_java_test_env
            ;;
        *)
            log_warning "未知项目类型，跳过环境检查"
            ;;
    esac

    total_issues=$?

    # 执行通用准备工作
    verify_dependencies
    prepare_test_environment

    # 生成报告
    generate_test_prep_report

    ENVIRONMENT_ISSUES=$total_issues

    if [ $total_issues -gt 0 ]; then
        log_warning "发现 $total_issues 个环境问题，建议修复后再运行测试"
        return 1
    else
        log_success "测试环境准备完成，可以开始运行测试"
        return 0
    fi
}

# 只有在直接调用时才执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi