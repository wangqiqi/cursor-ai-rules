#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 📊 Cursor AI Rules - 质量报告生成器
# 生成详细的质量检查报告和可视化图表

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 📊 生成质量趋势图表
generate_quality_chart() {
    local report_file="$QUALITY_DIR/quality-report.json"
    local chart_file="$QUALITY_DIR/quality-trend.md"

    if [ ! -f "$report_file" ]; then
        echo "❌ 未找到质量报告文件: $report_file"
        return 1
    fi

    echo "📊 生成质量趋势图表..."
    echo ""

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

## 🎯 质量总览

| 指标 | 值 | 状态 |
|------|-----|------|
| 质量分数 | ${quality_score}/100 | ${quality_grade} |
| 检查通过率 | ${checks_passed}/${checks_total} | $([ $issues_found -eq 0 ] && echo "✅" || echo "❌") |
| 发现问题 | ${issues_found} | $([ $issues_found -eq 0 ] && echo "✅" || echo "⚠️") |
| 质量警告 | ${warnings_found} | $([ $warnings_found -eq 0 ] && echo "✅" || echo "💡") |

## 📈 质量评分图表

\`\`\`
质量等级分布:
A (90-100): $([ $quality_score -ge 90 ] && echo "███████████████ 优秀" || echo "░░░░░░░░░░░░░░░ 未达到")
B (80-89):  $([ $quality_score -ge 80 ] && [ $quality_score -lt 90 ] && echo "███████████████ 良好" || echo "░░░░░░░░░░░░░░░ 未达到")
C (70-79):  $([ $quality_score -ge 70 ] && [ $quality_score -lt 80 ] && echo "███████████████ 一般" || echo "░░░░░░░░░░░░░░░ 未达到")
D (60-69):  $([ $quality_score -ge 60 ] && [ $quality_score -lt 70 ] && echo "███████████████ 需要改进" || echo "░░░░░░░░░░░░░░░ 未达到")
F (<60):    $([ $quality_score -lt 60 ] && echo "███████████████ 需要重构" || echo "░░░░░░░░░░░░░░░ 未达到")
\`\`\`

## 🔍 详细检查结果

EOF

    # 添加详细结果
    jq -r '.results | to_entries[] | "- **\(.key)**: \(.value)"' "$report_file" 2>/dev/null >> "$chart_file" || echo "- 无详细结果" >> "$chart_file"

    # 添加建议
    cat >> "$chart_file" << EOF

## 💡 改进建议

EOF

    # 从报告中提取建议
    jq -r '.recommendations[]' "$report_file" 2>/dev/null | while read -r recommendation; do
        echo "- $recommendation" >> "$chart_file"
    done || echo "- 保持良好的代码质量实践" >> "$chart_file"

    # 添加质量历史趋势（如果有历史数据）
    cat >> "$chart_file" << EOF

## 📉 质量趋势

*质量趋势图表需要多个检查周期的数据才能生成*

## 🎯 质量门禁标准

| 检查类型 | 标准 | 当前状态 |
|----------|------|----------|
| ESLint | 0个错误 | $(jq -r '.results."lint_ESLint"' "$report_file" 2>/dev/null || echo "未检查") |
| Prettier | 格式正确 | $(jq -r '.results."format_Prettier"' "$report_file" 2>/dev/null || echo "未检查") |
| 安全审计 | 无高危漏洞 | $([ $issues_found -eq 0 ] && echo "✅ 通过" || echo "❌ 未通过") |
| 类型检查 | 无类型错误 | $(jq -r '.results."type_TypeScript"' "$report_file" 2>/dev/null || echo "未检查") |

---

*报告生成工具*: Cursor AI Rules 质量管理系统
*项目地址*: https://github.com/wangqiqi/cursor-ai-rules
EOF

    echo "   ✅ 质量图表已生成: $chart_file"
}

# 📋 生成HTML质量报告
generate_html_report() {
    local report_file="$QUALITY_DIR/quality-report.json"
    local html_file="$QUALITY_DIR/quality-report.html"

    if [ ! -f "$report_file" ]; then
        echo "❌ 未找到质量报告文件: $report_file"
        return 1
    fi

    echo "🌐 生成HTML质量报告..."

    # 读取数据
    local quality_score=$(jq -r '.quality_score' "$report_file" 2>/dev/null || echo "0")
    local quality_grade=$(jq -r '.quality_grade' "$report_file" 2>/dev/null || echo "F")
    local timestamp=$(jq -r '.timestamp' "$report_file" 2>/dev/null || echo "未知")

    # 计算通过率
    local checks_total=$(jq -r '.statistics.checks_total' "$report_file" 2>/dev/null || echo "0")
    local checks_passed=$(jq -r '.statistics.checks_passed' "$report_file" 2>/dev/null || echo "0")
    local pass_rate=0
    if [ $checks_total -gt 0 ]; then
        pass_rate=$(( (checks_passed * 100) / checks_total ))
    fi

    # 生成HTML
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>代码质量报告 - $(basename "$PROJECT_ROOT")</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; }
        .score-card { text-align: center; margin: 30px; padding: 20px; border-radius: 8px; background: #f8f9fa; }
        .score-number { font-size: 48px; font-weight: bold; color: ${quality_score} -ge 80 && echo '#28a745' || echo '#dc3545'}; }
        .grade-badge { display: inline-block; padding: 8px 16px; border-radius: 20px; font-weight: bold; background: ${quality_score} -ge 90 && echo '#28a745' || quality_score -ge 80 && echo '#ffc107' || echo '#dc3545'}; color: white; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px; }
        .stat-card { padding: 20px; border-radius: 8px; text-align: center; background: #f8f9fa; }
        .stat-value { font-size: 24px; font-weight: bold; color: #495057; }
        .stat-label { color: #6c757d; margin-top: 5px; }
        .recommendations { margin: 30px; }
        .rec-item { padding: 15px; margin: 10px 0; border-left: 4px solid #007bff; background: #f8f9fa; border-radius: 0 8px 8px 0; }
        .footer { text-align: center; padding: 20px; color: #6c757d; border-top: 1px solid #dee2e6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔍 代码质量报告</h1>
            <p>项目: $(basename "$PROJECT_ROOT")</p>
            <p>生成时间: $timestamp</p>
        </div>

        <div class="score-card">
            <div class="score-number">$quality_score</div>
            <div class="grade-badge">等级 $quality_grade</div>
            <p>质量分数 (满分 100)</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value">$checks_passed/$checks_total</div>
                <div class="stat-label">检查通过率</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$(jq -r '.statistics.issues_found' "$report_file" 2>/dev/null || echo "0")</div>
                <div class="stat-label">发现问题</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$(jq -r '.statistics.warnings_found' "$report_file" 2>/dev/null || echo "0")</div>
                <div class="stat-label">质量警告</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$pass_rate%</div>
                <div class="stat-label">通过率</div>
            </div>
        </div>

        <div class="recommendations">
            <h3>💡 改进建议</h3>
EOF

    # 添加建议
    jq -r '.recommendations[]' "$report_file" 2>/dev/null | while read -r recommendation; do
        echo "            <div class=\"rec-item\">$recommendation</div>" >> "$html_file"
    done || echo "            <div class=\"rec-item\">保持良好的代码质量实践</div>" >> "$html_file"

    # 完成HTML
    cat >> "$html_file" << EOF
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

# 🎯 主函数
main() {
    local command="${1:-chart}"

    case "$command" in
        "chart")
            generate_quality_chart
            ;;
        "html")
            generate_html_report
            ;;
        "all")
            generate_quality_chart
            generate_html_report
            ;;
        "help"|*)
            echo "📊 Cursor AI Rules 质量报告生成器"
            echo ""
            echo "用法: $0 <command>"
            echo ""
            echo "命令:"
            echo "  chart    生成Markdown图表报告"
            echo "  html     生成HTML可视化报告"
            echo "  all      生成所有格式的报告"
            echo "  help     显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 chart"
            echo "  $0 html"
            echo "  $0 all"
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi