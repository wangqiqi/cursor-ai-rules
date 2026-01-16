#!/bin/bash

# 🌟 Cursor AI Rules - 统一质量管理体系
# 整合代码检查、格式化、安全审计和质量报告

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
QUALITY_DIR="$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 质量统计
QUALITY_CHECKS_TOTAL=0
QUALITY_CHECKS_PASSED=0
QUALITY_ISSUES_FOUND=0
QUALITY_WARNINGS_FOUND=0

# 质量结果存储
declare -A QUALITY_RESULTS

# 📊 通用质量检查函数
run_quality_check() {
    local check_type="$1"
    local check_name="$2"
    local check_command="$3"

    QUALITY_CHECKS_TOTAL=$((QUALITY_CHECKS_TOTAL + 1))

    echo -n "🔍 $check_name..."

    if eval "$check_command" 2>/dev/null; then
        echo " ${GREEN}通过${NC}"
        QUALITY_CHECKS_PASSED=$((QUALITY_CHECKS_PASSED + 1))
        QUALITY_RESULTS["${check_type}_${check_name}"]="passed"
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 2 ]; then
            # 警告级别
            echo " ${YELLOW}警告${NC}"
            QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
            QUALITY_RESULTS["${check_type}_${check_name}"]="warning"
        else
            # 错误级别
            echo " ${RED}失败${NC}"
            QUALITY_ISSUES_FOUND=$((QUALITY_ISSUES_FOUND + 1))
            QUALITY_RESULTS["${check_type}_${check_name}"]="failed"
        fi
        return $exit_code
    fi
}

# 🔍 第一阶段：代码质量检查
run_code_quality_checks() {
    echo "🔍 第一阶段：代码质量检查"
    echo "==========================="

    # ESLint检查
    if command -v eslint >/dev/null 2>&1; then
        echo "📝 ESLint 代码质量检查:"
        run_quality_check "lint" "ESLint" "eslint . --ext .js,.jsx,.ts,.tsx --max-warnings 0"
    else
        echo "⚠️  ESLint 未安装，跳过代码质量检查"
        QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
    fi

    # Prettier格式检查
    if command -v prettier >/dev/null 2>&1; then
        echo ""
        echo "🎨 Prettier 代码格式检查:"
        run_quality_check "format" "Prettier" "prettier --check ."
    else
        echo "⚠️  Prettier 未安装，跳过格式检查"
        QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
    fi

    # TypeScript类型检查
    if command -v tsc >/dev/null 2>&1 && [ -f "tsconfig.json" ]; then
        echo ""
        echo "🔷 TypeScript 类型检查:"
        run_quality_check "type" "TypeScript" "tsc --noEmit"
    else
        echo "ℹ️  TypeScript 未配置或未安装，跳过类型检查"
    fi

    echo ""
}

# 🔧 第二阶段：代码格式化
run_code_formatting() {
    echo "🔧 第二阶段：代码格式化"
    echo "========================="

    # Prettier自动格式化
    if command -v prettier >/dev/null 2>&1; then
        echo "🎨 执行 Prettier 自动格式化..."
        if prettier --write . 2>/dev/null; then
            echo "   ✅ 代码格式化完成"
            QUALITY_RESULTS["format_auto"]="completed"
        else
            echo "   ⚠️  代码格式化完成（有警告）"
            QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
        fi
    else
        echo "⚠️  Prettier 未安装，跳过自动格式化"
        QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
    fi

    # ESLint自动修复
    if command -v eslint >/dev/null 2>&1; then
        echo ""
        echo "🔧 执行 ESLint 自动修复..."
        if eslint . --ext .js,.jsx,.ts,.tsx --fix 2>/dev/null; then
            echo "   ✅ ESLint 自动修复完成"
            QUALITY_RESULTS["lint_auto_fix"]="completed"
        else
            echo "   ⚠️  ESLint 自动修复完成（有无法自动修复的问题）"
            QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
        fi
    fi

    echo ""
}

# 🔒 第三阶段：安全审计
run_security_audit() {
    echo "🔒 第三阶段：安全审计"
    echo "======================="

    # npm audit（如果有package.json）
    if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
        echo "📦 NPM 安全审计:"
        run_quality_check "security" "NPM Audit" "npm audit --audit-level moderate"
    fi

    # Python安全检查（如果有requirements.txt）
    if [ -f "requirements.txt" ] && command -v pip >/dev/null 2>&1; then
        echo ""
        echo "🐍 Python 依赖安全检查:"
        run_quality_check "security" "Python Safety" "pip install safety && safety check --file requirements.txt"
    fi

    # 通用安全检查
    echo ""
    echo "🔍 通用安全检查:"

    # 检查敏感文件
    local sensitive_files=$(find . -name "*.key" -o -name "*.pem" -o -name ".env*" -o -name "secrets*" 2>/dev/null | wc -l)
    if [ "$sensitive_files" -gt 0 ]; then
        echo "   ⚠️  发现 $sensitive_files 个潜在的敏感文件"
        QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
        QUALITY_RESULTS["security_sensitive_files"]="found:$sensitive_files"
    else
        echo "   ✅ 未发现敏感文件泄露"
        QUALITY_RESULTS["security_sensitive_files"]="clean"
    fi

    # 检查大文件
    local large_files=$(find . -type f -size +50M 2>/dev/null | wc -l)
    if [ "$large_files" -gt 0 ]; then
        echo "   ⚠️  发现 $large_files 个大文件（>50MB）"
        QUALITY_WARNINGS_FOUND=$((QUALITY_WARNINGS_FOUND + 1))
        QUALITY_RESULTS["security_large_files"]="found:$large_files"
    else
        echo "   ✅ 文件大小正常"
        QUALITY_RESULTS["security_large_files"]="normal"
    fi

    echo ""
}

# 📊 第四阶段：质量报告生成
generate_quality_report() {
    echo "📊 第四阶段：质量报告生成"
    echo "==========================="

    local report_file="$QUALITY_DIR/quality-report.json"

    # 计算质量分数
    local quality_score=0
    if [ $QUALITY_CHECKS_TOTAL -gt 0 ]; then
        quality_score=$(( (QUALITY_CHECKS_PASSED * 100) / QUALITY_CHECKS_TOTAL ))
    fi

    # 确定质量等级
    local quality_grade="F"
    if [ $quality_score -ge 90 ]; then
        quality_grade="A"
    elif [ $quality_score -ge 80 ]; then
        quality_grade="B"
    elif [ $quality_score -ge 70 ]; then
        quality_grade="C"
    elif [ $quality_score -ge 60 ]; then
        quality_grade="D"
    fi

    # 生成详细报告
    local report_data=$(cat << EOF
{
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "project": "$(basename "$PROJECT_ROOT")",
  "quality_score": $quality_score,
  "quality_grade": "$quality_grade",
  "statistics": {
    "checks_total": $QUALITY_CHECKS_TOTAL,
    "checks_passed": $QUALITY_CHECKS_PASSED,
    "issues_found": $QUALITY_ISSUES_FOUND,
    "warnings_found": $QUALITY_WARNINGS_FOUND
  },
  "results": $(declare -p QUALITY_RESULTS | sed 's/declare -A QUALITY_RESULTS=//' | jq -R -s 'fromjson? // {}'),
  "recommendations": $(generate_quality_recommendations "$quality_score")
}
EOF
)

    echo "$report_data" | jq . > "$report_file" 2>/dev/null || echo "$report_data" > "$report_file"

    echo "📄 质量报告已生成: $report_file"
    echo ""
    echo "🎯 质量评分: $quality_score/100 (等级: $quality_grade)"

    # 显示质量概览
    if [ $QUALITY_ISSUES_FOUND -eq 0 ]; then
        echo "🎉 恭喜！代码质量检查全部通过"
    else
        echo "⚠️  发现 $QUALITY_ISSUES_FOUND 个质量问题需要修复"
    fi

    if [ $QUALITY_WARNINGS_FOUND -gt 0 ]; then
        echo "💡 有 $QUALITY_WARNINGS_FOUND 个质量建议可以优化"
    fi
}

# 💡 生成质量建议
generate_quality_recommendations() {
    local score="$1"
    local recommendations="[]"

    # 基于分数生成建议
    if [ $score -lt 70 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["代码质量需要显著改进，建议进行全面的重构"]')
    elif [ $score -lt 85 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["代码质量良好，但仍有改进空间"]')
    else
        recommendations=$(echo "$recommendations" | jq '. += ["代码质量优秀，继续保持良好的开发习惯"]')
    fi

    # 基于具体问题生成建议
    if [ $QUALITY_ISSUES_FOUND -gt 0 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["优先修复发现的质量问题"]')
    fi

    if [ "${QUALITY_RESULTS['lint_ESLint']}" = "failed" ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["运行代码格式化工具修复ESLint问题"]')
    fi

    if [ "${QUALITY_RESULTS['format_Prettier']}" = "failed" ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["运行Prettier格式化代码"]')
    fi

    echo "$recommendations"
}

# 🎯 主函数
main() {
    local mode="${1:-comprehensive}"

    echo "开始执行统一质量检查..."
    echo ""

    case "$mode" in
        "lint")
            # 仅代码质量检查
            run_code_quality_checks
            ;;
        "format")
            # 仅代码格式化
            run_code_formatting
            ;;
        "security")
            # 仅安全审计
            run_security_audit
            ;;
        "comprehensive"|*)
            # 完整质量检查流程
            run_code_quality_checks
            run_code_formatting
            run_security_audit
            generate_quality_report
            ;;
    esac

    # 显示最终统计（仅在完整模式下）
    if [ "$mode" = "comprehensive" ] || [ -z "$mode" ]; then
        echo ""
        echo "📈 质量检查统计:"
        echo "   🔍 总检查数: $QUALITY_CHECKS_TOTAL"
        echo "   ✅ 通过检查: $QUALITY_CHECKS_PASSED"
        echo "   ❌ 发现问题: $QUALITY_ISSUES_FOUND"
        echo "   ⚠️  发现警告: $QUALITY_WARNINGS_FOUND"

        if [ $QUALITY_ISSUES_FOUND -eq 0 ] && [ $QUALITY_WARNINGS_FOUND -eq 0 ]; then
            echo ""
            echo "✨ 质量检查完成！所有指标都符合标准。"
        fi
    fi
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi