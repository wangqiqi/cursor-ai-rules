#!/bin/bash
# 🎯 预提交分析器钩子
# 深度分析变更内容，为智能提交提供数据支持
# 集成到增强版Git提交流程中

set -e

# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../core" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
source "$SCRIPT_DIR/path-config.sh"

# 项目上下文验证
validate_project_context || exit 1

source "$SCRIPT_DIR/colors.sh"

# 记录钩子执行
log() {
    echo "[HOOK:pre-commit-analyzer] $(date '+%H:%M:%S') $*" >&2
}

# 分析变更影响范围
analyze_impact_scope() {
    log "开始分析变更影响范围..."

    local changed_files=$(git diff --cached --name-only)
    local total_files=$(echo "$changed_files" | wc -l)
    local total_lines=$(git diff --cached --stat | tail -1 | awk '{print $4+$6}')

    # 文件类型统计
    local code_files=$(echo "$changed_files" | grep -E '\.(js|ts|jsx|tsx|py|java|cpp|c|go|rs|php|rb|swift|kt|scala)$' | wc -l)
    local config_files=$(echo "$changed_files" | grep -E '\.(json|yaml|yml|toml|ini|cfg|conf|properties|env)$' | wc -l)
    local doc_files=$(echo "$changed_files" | grep -E '\.(md|txt|rst|adoc|pdf|doc|docx)$' | wc -l)
    local test_files=$(echo "$changed_files" | grep -E '(test|spec)\.' | wc -l)

    echo "变更影响分析:" >&2
    echo "  总文件数: $total_files" >&2
    echo "  总行数: $total_lines" >&2
    echo "  代码文件: $code_files" >&2
    echo "  配置文件: $config_files" >&2
    echo "  文档文件: $doc_files" >&2
    echo "  测试文件: $test_files" >&2

    # 输出JSON格式的分析结果
    echo "{\"total_files\":$total_files,\"total_lines\":$total_lines,\"code_files\":$code_files,\"config_files\":$config_files,\"doc_files\":$doc_files,\"test_files\":$test_files}"
}

# 分析变更风险等级
analyze_risk_level() {
    log "开始分析变更风险等级..."

    local risk_score=0
    local risk_factors=""

    # 风险因子分析
    if git diff --cached --name-only | grep -q "package.json\|requirements.txt\|Cargo.toml\|go.mod"; then
        risk_score=$((risk_score + 30))
        risk_factors="${risk_factors}依赖变更 "
    fi

    if git diff --cached --name-only | grep -q "config\|settings"; then
        risk_score=$((risk_score + 20))
        risk_factors="${risk_factors}配置变更 "
    fi

    if git diff --cached --name-only | grep -q "database\|migration"; then
        risk_score=$((risk_score + 25))
        risk_factors="${risk_factors}数据库变更 "
    fi

    if git diff --cached --name-only | grep -q "security\|auth\|login"; then
        risk_score=$((risk_score + 20))
        risk_factors="${risk_factors}安全相关 "
    fi

    # 文件数量风险
    local file_count=$(git diff --cached --name-only | wc -l)
    if [ "$file_count" -gt 50 ]; then
        risk_score=$((risk_score + 15))
        risk_factors="${risk_factors}大量文件变更 "
    elif [ "$file_count" -gt 20 ]; then
        risk_score=$((risk_score + 10))
        risk_factors="${risk_factors}较多文件变更 "
    fi

    # 确定风险等级
    local risk_level="低"
    if [ $risk_score -gt 50 ]; then
        risk_level="高"
    elif [ $risk_score -gt 25 ]; then
        risk_level="中"
    fi

    echo "风险分析结果:" >&2
    echo "  风险分数: $risk_score" >&2
    echo "  风险等级: $risk_level" >&2
    echo "  风险因子: $risk_factors" >&2

    echo "{\"risk_score\":$risk_score,\"risk_level\":\"$risk_level\",\"risk_factors\":\"$risk_factors\"}"
}

# 生成改进建议
generate_improvement_suggestions() {
    log "开始生成改进建议..."

    local suggestions=""

    # 检查是否有测试文件变更
    if git diff --cached --name-only | grep -q "\.js\|\.ts\|\.py\|\.java\|\.go\|\.rs" && \
       ! git diff --cached --name-only | grep -q "test\|spec"; then
        suggestions="${suggestions}建议添加相应测试文件; "
    fi

    # 检查文档是否更新
    if git diff --cached --name-only | grep -q "function\|class\|interface" && \
       ! git diff --cached --name-only | grep -q "\.md$"; then
        suggestions="${suggestions}建议更新相关文档; "
    fi

    # 检查配置文件变更
    if git diff --cached --name-only | grep -q "config\|settings"; then
        suggestions="${suggestions}配置文件变更，建议仔细检查影响范围; "
    fi

    # 检查新功能是否需要迁移文档
    if git diff --cached --name-status | grep -q "^A" && \
       git diff --cached --name-only | grep -q "\.js\|\.ts\|\.py\|\.java\|\.go"; then
        suggestions="${suggestions}检测到新功能代码，建议考虑数据库迁移; "
    fi

    if [ -n "$suggestions" ]; then
        echo "改进建议:" >&2
        echo "  $suggestions" >&2
    else
        echo "✅ 未发现需要改进的地方" >&2
        suggestions="无改进建议"
    fi

    echo "{\"suggestions\":\"$suggestions\"}"
}

# 检查代码质量指标
check_code_quality_metrics() {
    log "开始检查代码质量指标..."

    local metrics="{}"

    # 检查代码行长度
    local long_lines=$(git diff --cached | grep '^+' | sed 's/^+.//' | awk 'length > 100 {count++} END {print count+0}')
    if [ "$long_lines" -gt 0 ]; then
        echo "质量检查: 发现 $long_lines 行代码超过100字符" >&2
        metrics=$(echo "$metrics" | jq ".long_lines = $long_lines")
    fi

    # 检查是否有TODO注释
    local todo_count=$(git diff --cached | grep -i '^+.*todo' | wc -l)
    if [ "$todo_count" -gt 0 ]; then
        echo "质量检查: 发现 $todo_count 个TODO注释" >&2
        metrics=$(echo "$metrics" | jq ".todo_count = $todo_count")
    fi

    # 检查是否有调试代码
    local debug_count=$(git diff --cached | grep -i '^+.*console\.log\|^+.*print(' | wc -l)
    if [ "$debug_count" -gt 0 ]; then
        echo "质量检查: 发现 $debug_count 行可能的调试代码" >&2
        metrics=$(echo "$metrics" | jq ".debug_count = $debug_count")
    fi

    echo "$metrics"
}

# 主处理函数
main() {
    local hook_event="$1"
    local hook_data="$2"

    log "执行预提交分析钩子: $hook_event"

    case "$hook_event" in
        "pre-commit-analysis")
            # 执行完整的分析流程
            local impact_info=$(analyze_impact_scope)
            local risk_info=$(analyze_risk_level)
            local suggestions=$(generate_improvement_suggestions)
            local quality_info=$(check_code_quality_metrics)

            # 合并所有分析结果
            local analysis_result=$(echo "{}" | \
                jq ".impact = $impact_info" | \
                jq ".risk = $risk_info" | \
                jq ".suggestions = $suggestions" | \
                jq ".quality = $quality_info")

            # 保存分析结果到临时文件，供后续钩子使用
            local temp_file="/tmp/cursor-pre-commit-analysis-$(date +%s).json"
            echo "$analysis_result" > "$temp_file"
            echo "分析结果已保存到: $temp_file" >&2

            log "预提交分析完成"
            ;;

        "pre-commit")
            # 简化的提交前检查
            local changed_files=$(git diff --cached --name-only | wc -l)
            if [ "$changed_files" -gt 100 ]; then
                echo -e "${YELLOW}⚠️  警告: 大规模变更 ($changed_files 个文件)${NC}" >&2
                echo -e "${YELLOW}💡 建议考虑分批提交${NC}" >&2
            fi

            log "预提交快速检查完成"
            ;;

        *)
            log "未知钩子事件: $hook_event"
            exit 1
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi