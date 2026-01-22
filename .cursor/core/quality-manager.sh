#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🌟 Cursor AI Rules - 统一质量管理体系
# 整合代码检查、格式化、安全审计和质量报告

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# 📊 显示质量总结
show_quality_summary() {
    echo "📊 质量检查总结"
    echo "==============="

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

    echo "🎯 质量评分: $quality_score/100 (等级: $quality_grade)"
    echo "📅 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "📁 项目: $(basename "$PROJECT_ROOT")"
    echo ""

    # 显示统计信息
    echo "📈 检查统计:"
    echo "   🔍 总检查数: $QUALITY_CHECKS_TOTAL"
    echo "   ✅ 通过检查: $QUALITY_CHECKS_PASSED"
    echo "   ❌ 发现问题: $QUALITY_ISSUES_FOUND"
    echo "   ⚠️  发现警告: $QUALITY_WARNINGS_FOUND"
    echo ""

    # 显示详细结果
    if [ ${#QUALITY_RESULTS[@]} -gt 0 ]; then
        echo "🔍 详细检查结果:"
        for key in "${!QUALITY_RESULTS[@]}"; do
            local status="${QUALITY_RESULTS[$key]}"
            local icon="✅"
            if [ "$status" = "failed" ]; then
                icon="❌"
            elif [ "$status" = "warning" ]; then
                icon="⚠️"
            fi
            echo "   $icon $key: $status"
        done
        echo ""
    fi

    # 生成并显示建议
    echo "💡 改进建议:"
    local recommendations=$(generate_quality_recommendations "$quality_score")
    echo "$recommendations" | jq -r '.[]' 2>/dev/null || echo "保持良好的代码质量实践"
    echo ""

    # 显示质量概览
    if [ $QUALITY_ISSUES_FOUND -eq 0 ] && [ $QUALITY_WARNINGS_FOUND -eq 0 ]; then
        echo "🎉 恭喜！代码质量检查全部通过，所有指标都符合标准。"
    elif [ $QUALITY_ISSUES_FOUND -eq 0 ]; then
        echo "✅ 代码质量良好！没有发现严重问题，但有 $QUALITY_WARNINGS_FOUND 个警告需要注意。"
    else
        echo "⚠️  发现 $QUALITY_ISSUES_FOUND 个质量问题需要修复，建议优先处理。"
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
            show_quality_summary
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

# =============================================================================
# 集成报告功能 (从quality-reporter.sh合并)
# =============================================================================

# 📊 生成质量趋势图表
generate_quality_chart() {
    local report_file="$QUALITY_DIR/quality-report.json"
    local chart_file="$QUALITY_DIR/quality-trend.md"

    if [ ! -f "$report_file" ]; then
        echo "❌ 未找到质量报告文件: $report_file"
        return 1
    fi

    echo "📊 生成质量趋势图表..."

    # 读取报告数据
    local quality_score=$(jq -r '.quality_score' "$report_file" 2>/dev/null || echo "0")
    local quality_grade=$(jq -r '.quality_grade' "$report_file" 2>/dev/null || echo "F")
    local checks_total=$(jq -r '.statistics.checks_total' "$report_file" 2>/dev/null || echo "0")
    local checks_passed=$(jq -r '.statistics.checks_passed' "$report_file" 2>/dev/null || echo "0")
    local issues_found=$(jq -r '.statistics.issues_found' "$report_file" 2>/dev/null || echo "0")
    local warnings_found=$(jq -r '.statistics.warnings_found' "$report_file" 2>/dev/null || echo "0")

    # 生成图表
    cat > "$chart_file" << EOF
# 📊 代码质量报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
**项目**: $(basename "$PROJECT_ROOT")

## 🎯 质量评分
**总分**: $quality_score/100
**等级**: $quality_grade

## 📈 统计数据
| 项目 | 数值 |
|-----|-----|
| 🔍 总检查数 | $checks_total |
| ✅ 通过检查 | $checks_passed |
| ❌ 发现问题 | $issues_found |
| ⚠️  发现警告 | $warnings_found |

## 📊 质量分布

### 检查通过率
\`\`\`
$(create_progress_bar $checks_passed $checks_total "✅")
\`\`\`

### 问题分布
\`\`\`
关键问题: $(create_bar $issues_found 20 "🔴")
警告信息: $(create_bar $warnings_found 20 "🟡")
\`\`\`

## 💡 质量建议

EOF

    # 添加建议
    jq -r '.recommendations[]' "$report_file" 2>/dev/null | while read -r recommendation; do
        echo "- $recommendation" >> "$chart_file"
    done || echo "- 保持良好的代码质量实践" >> "$chart_file"

    echo "" >> "$chart_file"
    echo "---" >> "$chart_file"
    echo "*Generated by Cursor AI Rules Quality Management System*" >> "$chart_file"

    echo "   ✅ Markdown质量报告已生成: $chart_file"
}

# 创建进度条
create_progress_bar() {
    local current=$1
    local total=$2
    local symbol=$3

    if [ "$total" -eq 0 ]; then
        echo "░░░░░░░░░░░░░░░░░░░░░░░░ 0%"
        return
    fi

    local percentage=$((current * 100 / total))
    local filled=$((percentage / 5))
    local empty=$((20 - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}█"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}░"
    done

    echo "${bar} ${percentage}%"
}

# 创建条形图
create_bar() {
    local value=$1
    local max=$2
    local symbol=$3

    if [ "$max" -eq 0 ]; then
        echo "░░░░░░░░░░░░░░░░░░░░░░░░"
        return
    fi

    local scaled=$((value * 20 / max))
    if [ "$scaled" -gt 20 ]; then
        scaled=20
    fi

    local bar=""
    for ((i=0; i<scaled; i++)); do
        bar="${bar}█"
    done
    for ((i=scaled; i<20; i++)); do
        bar="${bar}░"
    done

    echo "$bar"
}

# 🎨 生成HTML可视化报告
generate_html_report() {
    local report_file="$QUALITY_DIR/quality-report.json"
    local html_file="$QUALITY_DIR/quality-report.html"

    if [ ! -f "$report_file" ]; then
        echo "❌ 未找到质量报告文件: $report_file"
        return 1
    fi

    echo "🎨 生成HTML质量报告..."

    # 读取报告数据
    local quality_score=$(jq -r '.quality_score' "$report_file" 2>/dev/null || echo "0")
    local quality_grade=$(jq -r '.quality_grade' "$report_file" 2>/dev/null || echo "F")
    local checks_total=$(jq -r '.statistics.checks_total' "$report_file" 2>/dev/null || echo "0")
    local checks_passed=$(jq -r '.statistics.checks_passed' "$report_file" 2>/dev/null || echo "0")
    local issues_found=$(jq -r '.statistics.issues_found' "$report_file" 2>/dev/null || echo "0")
    local warnings_found=$(jq -r '.statistics.warnings_found' "$report_file" 2>/dev/null || echo "0")

    # 生成HTML报告
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>代码质量报告 - Cursor AI Rules</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { padding: 30px; }
        .score-card { display: inline-block; background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 10px; text-align: center; }
        .score-large { font-size: 48px; font-weight: bold; color: #28a745; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #007bff; }
        .progress-bar { background: #e9ecef; border-radius: 10px; height: 20px; margin: 10px 0; }
        .progress-fill { background: linear-gradient(90deg, #28a745 0%, #20c997 100%); height: 100%; border-radius: 10px; }
        .recommendations { background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 20px; margin: 20px 0; }
        .rec-item { margin: 5px 0; padding: 5px 0; border-bottom: 1px solid #ffeaa7; }
        .rec-item:last-child { border-bottom: none; }
        .footer { background: #f8f9fa; padding: 20px; text-align: center; border-radius: 0 0 8px 8px; border-top: 1px solid #dee2e6; }
        .footer a { color: #007bff; text-decoration: none; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 代码质量报告</h1>
            <p>Generated by Cursor AI Rules Quality Management System</p>
            <p><strong>项目:</strong> $(basename "$PROJECT_ROOT") | <strong>时间:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
        </div>

        <div class="content">
            <div class="score-card">
                <h2>质量评分</h2>
                <div class="score-large">$quality_score</div>
                <p>等级: <strong>$quality_grade</strong></p>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <h3>🔍 检查统计</h3>
                    <p><strong>$checks_total</strong> 总检查数</p>
                    <p><strong>$checks_passed</strong> 通过检查</p>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: $((checks_passed * 100 / (checks_total > 0 ? checks_total : 1)))%"></div>
                    </div>
                </div>

                <div class="stat-card">
                    <h3>⚠️ 问题统计</h3>
                    <p><strong>$issues_found</strong> 关键问题</p>
                    <p><strong>$warnings_found</strong> 警告信息</p>
                </div>
            </div>

            <div class="recommendations">
                <h3>💡 质量改进建议</h3>
EOF

    # 添加建议
    jq -r '.recommendations[]' "$report_file" 2>/dev/null | while read -r recommendation; do
        echo "                <div class=\"rec-item\">$recommendation</div>" >> "$html_file"
    done || echo "                <div class=\"rec-item\">保持良好的代码质量实践</div>" >> "$html_file"

    # 完成HTML
    cat >> "$html_file" << EOF
            </div>
        </div>

        <div class="footer">
            <p>Generated by Cursor AI Rules Quality Management System</p>
            <p><a href="https://github.com/wangqiqi/cursor-ai-rules">View on GitHub</a></p>
        </div>
    </div>
</body>
</html>
EOF

    echo "   ✅ HTML质量报告已生成: $html_file"
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi