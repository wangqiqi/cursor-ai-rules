#!/bin/bash
# 🔍 Cursor AI Rules - 环境检测器
# 详细检测项目环境和系统状态

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "🔍 Cursor AI Rules - 环境检测器"
echo "================================="
echo ""

# 检测结果存储
declare -A DETECTION_RESULTS

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. 系统信息检测
detect_system_info() {
    echo "🖥️  系统信息检测"
    echo "---------------"

    # 操作系统
    local os_type=$(uname -s 2>/dev/null || echo "Unknown")
    local os_version=$(uname -r 2>/dev/null || echo "Unknown")
    local os_arch=$(uname -m 2>/dev/null || echo "Unknown")

    echo "  操作系统: $os_type $os_version ($os_arch)"
    DETECTION_RESULTS["os_type"]="$os_type"
    DETECTION_RESULTS["os_version"]="$os_version"
    DETECTION_RESULTS["os_arch"]="$os_arch"

    # CPU和内存
    local cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
    local total_memory=$(free -h 2>/dev/null | grep '^Mem:' | awk '{print $2}' 2>/dev/null || echo "Unknown")

    echo "  CPU核心数: $cpu_cores"
    echo "  总内存: $total_memory"
    DETECTION_RESULTS["cpu_cores"]="$cpu_cores"
    DETECTION_RESULTS["total_memory"]="$total_memory"

    echo ""
}

# 2. 编程环境检测
detect_programming_environment() {
    echo "💻 编程环境检测"
    echo "---------------"

    local languages=("node" "python3" "python" "go" "rustc" "java" "javac" "dotnet" "php" "ruby" "perl")

    for lang in "${languages[@]}"; do
        if command -v "$lang" >/dev/null 2>&1; then
            local version=$($lang --version 2>&1 | head -1 | awk '{print $2,$3,$4}' | tr -d '\n' || echo "检测失败")
            echo "  ✅ $lang: $version"
            DETECTION_RESULTS["${lang}_installed"]=true
            DETECTION_RESULTS["${lang}_version"]="$version"
        else
            echo "  ❌ $lang: 未安装"
            DETECTION_RESULTS["${lang}_installed"]=false
        fi
    done

    echo ""
}

# 3. 项目结构检测
detect_project_structure() {
    echo "📁 项目结构检测"
    echo "---------------"

    local project_files=("README.md" "README.rst" "package.json" "requirements.txt" "pyproject.toml" "go.mod" "Cargo.toml" "pom.xml" "build.gradle")
    local detected_files=()

    for file in "${project_files[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file"
            detected_files+=("$file")
            DETECTION_RESULTS["file_$file"]=true
        fi
    done

    if [ ${#detected_files[@]} -eq 0 ]; then
        echo "  ⚠️  未检测到常见项目文件"
    fi

    # 目录统计
    local total_files=$(find . -maxdepth 3 -type f 2>/dev/null | wc -l 2>/dev/null || echo "0")
    local total_dirs=$(find . -maxdepth 3 -type d 2>/dev/null | wc -l 2>/dev/null || echo "0")

    echo "  📊 文件总数: $total_files"
    echo "  📂 目录总数: $total_dirs"
    DETECTION_RESULTS["total_files"]="$total_files"
    DETECTION_RESULTS["total_dirs"]="$total_dirs"

    echo ""
}

# 4. Git仓库检测
detect_git_repository() {
    echo "📚 Git仓库检测"
    echo "-------------"

    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        echo "  ✅ Git仓库: 已启用"

        # Git用户信息
        local user_name=$(git config --get user.name 2>/dev/null || echo "未设置")
        local user_email=$(git config --get user.email 2>/dev/null || echo "未设置")
        echo "  👤 用户: $user_name <$user_email>"

        # 仓库统计
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local commits=$(git log --oneline 2>/dev/null | wc -l 2>/dev/null || echo "0")
        local contributors=$(git shortlog -sn --no-merges 2>/dev/null | wc -l 2>/dev/null || echo "0")

        echo "  🌿 当前分支: $branch"
        echo "  📝 提交次数: $commits"
        echo "  👥 贡献者数: $contributors"

        DETECTION_RESULTS["git_enabled"]=true
        DETECTION_RESULTS["git_user_name"]="$user_name"
        DETECTION_RESULTS["git_user_email"]="$user_email"
        DETECTION_RESULTS["git_branch"]="$branch"
        DETECTION_RESULTS["git_commits"]="$commits"
        DETECTION_RESULTS["git_contributors"]="$contributors"

        # 远程仓库
        local remote_url=$(git remote get-url origin 2>/dev/null || echo "none")
        if [ "$remote_url" != "none" ]; then
            echo "  🔗 远程仓库: ${remote_url:0:50}..."
            DETECTION_RESULTS["git_remote_url"]="$remote_url"
        fi
    else
        echo "  ❌ Git仓库: 未启用或不在仓库中"
        DETECTION_RESULTS["git_enabled"]=false
    fi

    echo ""
}

# 5. 容器化检测
detect_containerization() {
    echo "🐳 容器化检测"
    echo "------------"

    local container_files=("Dockerfile" "docker-compose.yml" "docker-compose.yaml" ".dockerignore" "Dockerfile.*")

    local has_containerization=false
    for file in "${container_files[@]}"; do
        if [ -f "$file" ] || [ -f "$file"* ]; then
            echo "  ✅ $file"
            has_containerization=true
            DETECTION_RESULTS["container_$file"]=true
        fi
    done

    if [ "$has_containerization" = false ]; then
        echo "  ❌ 未检测到容器化配置"
    fi

    DETECTION_RESULTS["has_containerization"]="$has_containerization"

    echo ""
}

# 6. CI/CD检测
detect_ci_cd() {
    echo "🔄 CI/CD检测"
    echo "-----------"

    local ci_files=(".github/workflows/*.yml" ".github/workflows/*.yaml" ".travis.yml" "Jenkinsfile" ".gitlab-ci.yml" "azure-pipelines.yml")
    local has_ci=false

    for pattern in "${ci_files[@]}"; do
        if compgen -G "$pattern" >/dev/null 2>&1; then
            echo "  ✅ ${pattern}"
            has_ci=true
            DETECTION_RESULTS["ci_$pattern"]=true
        fi
    done

    if [ "$has_ci" = false ]; then
        echo "  ❌ 未检测到CI/CD配置"
    fi

    DETECTION_RESULTS["has_ci_cd"]="$has_ci"

    echo ""
}

# 7. 代码质量检测
detect_code_quality() {
    echo "🔍 代码质量检测"
    echo "--------------"

    local quality_files=(".eslintrc*" ".prettierrc*" ".stylelintrc*" "tsconfig.json" ".editorconfig" ".pre-commit-config.yaml")
    local has_quality_tools=false

    for pattern in "${quality_files[@]}"; do
        if compgen -G "$pattern" >/dev/null 2>&1; then
            echo "  ✅ ${pattern}"
            has_quality_tools=true
            DETECTION_RESULTS["quality_$pattern"]=true
        fi
    done

    # 测试目录
    if [ -d "tests" ] || [ -d "__tests__" ] || [ -d "spec" ] || find . -name "*test*" -type d 2>/dev/null | grep -q .; then
        echo "  ✅ 测试目录"
        has_quality_tools=true
        DETECTION_RESULTS["has_tests"]=true
    fi

    if [ "$has_quality_tools" = false ]; then
        echo "  ⚠️  未检测到代码质量工具"
    fi

    DETECTION_RESULTS["has_quality_tools"]="$has_quality_tools"

    echo ""
}

# 8. 安全检测
detect_security() {
    echo "🔒 安全检测"
    echo "---------"

    local security_files=(".secrets" ".env" ".env.*" "secrets/" ".gitignore")
    local has_security=false

    for file in "${security_files[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            echo "  ✅ $file"
            has_security=true
            DETECTION_RESULTS["security_$file"]=true
        fi
    done

    # 检查敏感文件是否被忽略
    if [ -f ".gitignore" ]; then
        local sensitive_ignored=true
        for pattern in ".env" "*.key" "*.pem" "secrets/"; do
            if ! grep -q "^$pattern" .gitignore 2>/dev/null; then
                sensitive_ignored=false
                break
            fi
        done

        if [ "$sensitive_ignored" = true ]; then
            echo "  ✅ 敏感文件已正确忽略"
            DETECTION_RESULTS["sensitive_files_ignored"]=true
        else
            echo "  ⚠️  建议在.gitignore中忽略敏感文件"
            DETECTION_RESULTS["sensitive_files_ignored"]=false
        fi
    fi

    DETECTION_RESULTS["has_security_setup"]="$has_security"

    echo ""
}

# 9. 网络和API检测
detect_networking() {
    echo "🌐 网络和API检测"
    echo "---------------"

    # 检查网络连接
    if curl -s --connect-timeout 5 https://api.github.com >/dev/null 2>&1; then
        echo "  ✅ 网络连接: 正常"
        DETECTION_RESULTS["network_connected"]=true
    else
        echo "  ⚠️  网络连接: 受限或无连接"
        DETECTION_RESULTS["network_connected"]=false
    fi

    # 检查包管理器
    local package_managers=("npm" "yarn" "pnpm" "pip" "pip3" "gem" "composer" "cargo" "go mod")
    local available_managers=()

    for manager in "${package_managers[@]}"; do
        case $manager in
            "npm"|"yarn"|"pnpm")
                if command -v "$manager" >/dev/null 2>&1; then
                    available_managers+=("$manager")
                fi
                ;;
            "pip"|"pip3")
                if command -v "$manager" >/dev/null 2>&1; then
                    available_managers+=("$manager")
                fi
                ;;
            "gem")
                if command -v "$manager" >/dev/null 2>&1; then
                    available_managers+=("$manager")
                fi
                ;;
            "composer")
                if command -v "$manager" >/dev/null 2>&1; then
                    available_managers+=("$manager")
                fi
                ;;
            "cargo")
                if command -v "$manager" >/dev/null 2>&1; then
                    available_managers+=("$manager")
                fi
                ;;
            "go mod")
                if command -v "go" >/dev/null 2>&1; then
                    available_managers+=("go mod")
                fi
                ;;
        esac
    done

    if [ ${#available_managers[@]} -gt 0 ]; then
        echo "  📦 包管理器: ${available_managers[*]}"
        DETECTION_RESULTS["package_managers"]="${available_managers[*]}"
    fi

    echo ""
}

# 10. 生成检测报告
generate_report() {
    echo "📋 检测报告"
    echo "=========="

    local report_file="$SCRIPT_DIR/../detection-report.json"

    # 转换为JSON格式
    local json_result="{"
    for key in "${!DETECTION_RESULTS[@]}"; do
        json_result="$json_result\"$key\":\"${DETECTION_RESULTS[$key]}\","
    done
    json_result="${json_result%,}}"

    echo "$json_result" | jq . > "$report_file" 2>/dev/null || echo "$json_result" > "$report_file"

    echo "✅ 检测报告已保存: ${GREEN}$report_file${NC}"
    echo ""

    # 显示关键发现
    echo "🔑 关键发现:"
    echo "  🛠️  技术栈: ${TECH_STACK:-'未检测'}"
    echo "  👥 团队规模: $TEAM_SIZE"
    echo "  📊 项目成熟度: $PROJECT_MATURITY"
    echo "  📁 文件总数: ${DETECTION_RESULTS["total_files"]}"
    echo "  🔧 编程环境: ${DETECTION_RESULTS["node_installed"]:+Node.js }${DETECTION_RESULTS["python3_installed"]:+Python }${DETECTION_RESULTS["go_installed"]:+Go }"

    if [ "${DETECTION_RESULTS["has_containerization"]}" = "true" ]; then
        echo "  🐳 容器化: 已配置"
    fi

    if [ "${DETECTION_RESULTS["has_ci_cd"]}" = "true" ]; then
        echo "  🔄 CI/CD: 已配置"
    fi

    if [ "${DETECTION_RESULTS["has_quality_tools"]}" = "true" ]; then
        echo "  🔍 代码质量: 已配置"
    fi
}

# 主函数
main() {
    cd "$PROJECT_ROOT" 2>/dev/null || true

    detect_system_info
    detect_programming_environment
    detect_project_structure
    detect_git_repository
    detect_containerization
    detect_ci_cd
    detect_code_quality
    detect_security
    detect_networking
    generate_report
}

# 检查是否直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi