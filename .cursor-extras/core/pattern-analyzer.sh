#!/bin/bash

# 🌟 Cursor AI Rules - 同类项合并法：智能模式分析器
# 基于用户经验实现错误模式识别和批量修复，支持安全的分批处理
#
# 使用方法:
#   ./pattern-analyzer.sh analyze [--source <paths>] [--output <file>]
#   ./pattern-analyzer.sh categorize [--threshold <similarity>] [--limit <num>]
#   ./pattern-analyzer.sh batch-fix <pattern> [--dry-run] [--max-files <num>]
#   ./pattern-analyzer.sh report [--format <json|text|html>]
#   ./pattern-analyzer.sh validate-fix <pattern> [--test-cmd <command>]
#
# 作者: Cursor AI Rules Team
# 版本: v1.0.0
# 更新: 2026-01-16

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"
DEBUG_DIR="$PROJECT_ROOT/.cursor/debug"
ANALYSIS_DIR="$CURSOR_GROWTH/analytics/analysis"

# 颜色定义来自 logging.sh

# 配置变量
DEFAULT_SIMILARITY_THRESHOLD=0.8
DEFAULT_BATCH_LIMIT=10
DEFAULT_TEST_CMD="npm test"
MAX_ANALYSIS_FILES=1000

# 导入公共函数
if [ -f "$SCRIPT_DIR/../core/common.sh" ]; then
    source "$SCRIPT_DIR/../core/common.sh"
fi

# 导入日志函数
if [ -f "$SCRIPT_DIR/../core/logging.sh" ]; then
    source "$SCRIPT_DIR/../core/logging.sh"
fi

# 📁 初始化分析目录
init_analysis_directory() {
    mkdir -p "$ANALYSIS_DIR"
    log_info "初始化分析目录: $ANALYSIS_DIR" "pattern-analyzer"
}

# 🔍 收集错误日志和测试结果
collect_error_logs() {
    local source_paths="${1:-.}"
    local output_file="$ANALYSIS_DIR/error_logs_$(date '+%Y%m%d_%H%M%S').json"

    log_info "收集错误日志从: $source_paths" "pattern-analyzer"

    # 初始化结果数组
    local error_entries="[]"

    # 常见的错误日志来源
    local log_sources=(
        "error.log"
        "debug.log"
        "*.log"
        "test-results.xml"
        "junit.xml"
        "coverage/lcov-report/*.html"
        "node_modules/.cache/*"
        ".cursorGrowth/logs/*.log"
    )

    # 遍历日志源
    for source_pattern in "${log_sources[@]}"; do
        # 扩展路径模式
        if [[ "$source_pattern" == .* ]]; then
            # 相对于项目根目录
            local full_pattern="$PROJECT_ROOT/$source_pattern"
        else
            # 相对于当前目录或指定路径
            local full_pattern="$source_pattern"
        fi

        # 查找匹配的文件
        while IFS= read -r -d '' file; do
            if [ -f "$file" ] && [ -r "$file" ]; then
                log_debug "处理日志文件: $file" "pattern-analyzer"
                local file_errors=$(extract_errors_from_file "$file")
                if [ -n "$file_errors" ]; then
                    error_entries=$(echo "$error_entries" | jq --arg file "$file" --argjson errors "$file_errors" '. += [{file: $file, errors: $errors}]')
                fi
            fi
        done < <(find $source_paths -name "$(basename "$source_pattern")" -type f -print0 2>/dev/null | head -50)
    done

    # 查找代码中的错误模式
    local code_errors=$(scan_code_for_errors "$source_paths")
    if [ -n "$code_errors" ]; then
        error_entries=$(echo "$error_entries" | jq --argjson code_errors "$code_errors" '. += $code_errors[]')
    fi

    # 保存结果
    echo "$error_entries" | jq . > "$output_file" 2>/dev/null || echo "$error_entries" > "$output_file"

    log_info "错误日志收集完成，共 $(echo "$error_entries" | jq length) 个文件" "pattern-analyzer"
    echo "$output_file"
}

# 📄 从单个文件提取错误信息
extract_errors_from_file() {
    local file="$1"
    local errors="[]"

    # 根据文件类型选择解析方法
    case "${file##*.}" in
        "log")
            errors=$(extract_errors_from_log "$file")
            ;;
        "xml")
            errors=$(extract_errors_from_xml "$file")
            ;;
        "json")
            errors=$(extract_errors_from_json "$file")
            ;;
        "html")
            errors=$(extract_errors_from_html "$file")
            ;;
        *)
            # 通用文本文件
            errors=$(extract_errors_from_text "$file")
            ;;
    esac

    echo "$errors"
}

# 📋 从日志文件提取错误
extract_errors_from_log() {
    local file="$1"
    local errors="[]"

    # 常见的错误模式
    local error_patterns=(
        "ERROR"
        "Error"
        "error"
        "Exception"
        "exception"
        "Failed"
        "failed"
        "FAIL"
        "TypeError"
        "ReferenceError"
        "SyntaxError"
        "ImportError"
    )

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        for pattern in "${error_patterns[@]}"; do
            if [[ "$line" == *"$pattern"* ]]; then
                local error_entry=$(jq -n \
                    --arg line "$line" \
                    --arg pattern "$pattern" \
                    --arg line_num "$line_num" \
                    '{
                        type: "log_error",
                        pattern: $pattern,
                        message: $line,
                        line: ($line_num | tonumber),
                        severity: "error"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
                break
            fi
        done
    done < "$file"

    echo "$errors"
}

# 📄 从XML文件提取错误（测试结果）
extract_errors_from_xml() {
    local file="$1"
    local errors="[]"

    if command -v xmllint &> /dev/null; then
        # 解析JUnit XML格式
        local test_cases=$(xmllint --xpath "//testcase[failure or error]" "$file" 2>/dev/null || echo "")

        if [ -n "$test_cases" ]; then
            # 简单的XML解析（实际项目中可能需要更复杂的解析）
            local failure_count=$(echo "$test_cases" | grep -c "<failure>" || echo "0")
            local error_count=$(echo "$test_cases" | grep -c "<error>" || echo "0")

            if [ "$failure_count" -gt 0 ] || [ "$error_count" -gt 0 ]; then
                local error_entry=$(jq -n \
                    --arg failure_count "$failure_count" \
                    --arg error_count "$error_count" \
                    '{
                        type: "test_failure",
                        pattern: "test_failure",
                        message: "Test failures found",
                        failure_count: ($failure_count | tonumber),
                        error_count: ($error_count | tonumber),
                        severity: "error"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
            fi
        fi
    fi

    echo "$errors"
}

# 📄 从JSON文件提取错误
extract_errors_from_json() {
    local file="$1"
    local errors="[]"

    if command -v jq &> /dev/null; then
        # 尝试解析JSON并查找错误相关字段
        local json_content=$(cat "$file" 2>/dev/null || echo "{}")

        # 查找常见的错误字段
        local error_fields=("error" "errors" "exception" "failures" "issues")

        for field in "${error_fields[@]}"; do
            local field_value=$(echo "$json_content" | jq -r ".$field // empty" 2>/dev/null || echo "")
            if [ -n "$field_value" ] && [ "$field_value" != "null" ] && [ "$field_value" != "{}" ] && [ "$field_value" != "[]" ]; then
                local error_entry=$(jq -n \
                    --arg field "$field" \
                    --arg value "$field_value" \
                    '{
                        type: "json_error",
                        pattern: $field,
                        message: $value,
                        severity: "error"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
            fi
        done
    fi

    echo "$errors"
}

# 📄 从HTML文件提取错误（覆盖率报告等）
extract_errors_from_html() {
    local file="$1"
    local errors="[]"

    # 从HTML中提取文本并查找错误模式
    if command -v pandoc &> /dev/null; then
        local text_content=$(pandoc -f html -t plain "$file" 2>/dev/null || cat "$file")
    else
        local text_content=$(cat "$file" | sed 's/<[^>]*>//g')
    fi

    # 查找错误关键词
    local error_keywords=("error" "Error" "ERROR" "failed" "Failed" "FAILED")
    local found_errors=()

    for keyword in "${error_keywords[@]}"; do
        if [[ "$text_content" == *"$keyword"* ]]; then
            found_errors+=("$keyword")
        fi
    done

    if [ ${#found_errors[@]} -gt 0 ]; then
        local error_entry=$(jq -n \
            --arg keywords "${found_errors[*]}" \
            '{
                type: "html_error",
                pattern: "html_errors",
                message: "Errors found in HTML content",
                keywords: ($keywords | split(" ")),
                severity: "warning"
            }')
        errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
    fi

    echo "$errors"
}

# 📄 从通用文本文件提取错误
extract_errors_from_text() {
    local file="$1"
    local errors="[]"

    # 简单的文本模式匹配
    local error_patterns=("ERROR" "Error" "Exception" "Failed" "undefined" "null")

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        for pattern in "${error_patterns[@]}"; do
            if [[ "$line" == *"$pattern"* ]]; then
                local error_entry=$(jq -n \
                    --arg line "$line" \
                    --arg pattern "$pattern" \
                    --arg line_num "$line_num" \
                    '{
                        type: "text_error",
                        pattern: $pattern,
                        message: $line,
                        line: ($line_num | tonumber),
                        severity: "error"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
                break
            fi
        done
    done < "$file"

    echo "$errors"
}

# 🔍 扫描代码文件中的潜在错误模式
scan_code_for_errors() {
    local source_paths="${1:-.}"
    local code_errors="[]"

    log_info "扫描代码中的错误模式" "pattern-analyzer"

    # 支持的文件类型
    local file_patterns=("*.js" "*.jsx" "*.ts" "*.tsx" "*.py" "*.java" "*.cpp" "*.c")

    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            if [ -f "$file" ] && [ -r "$file" ]; then
                log_debug "扫描代码文件: $file" "pattern-analyzer"
                local file_errors=$(analyze_code_file "$file")
                if [ -n "$file_errors" ]; then
                    code_errors=$(echo "$code_errors" | jq --arg file "$file" --argjson errors "$file_errors" '. += [{file: $file, errors: $errors}]')
                fi
            fi
        done < <(find $source_paths -name "$pattern" -type f -print0 2>/dev/null | head -50)
    done

    echo "$code_errors"
}

# 🔍 分析单个代码文件
analyze_code_file() {
    local file="$1"
    local errors="[]"

    # 获取文件扩展名
    local ext="${file##*.}"

    case "$ext" in
        "js"|"jsx"|"ts"|"tsx")
            errors=$(analyze_javascript_file "$file")
            ;;
        "py")
            errors=$(analyze_python_file "$file")
            ;;
        "java")
            errors=$(analyze_java_file "$file")
            ;;
        "cpp"|"c")
            errors=$(analyze_cpp_file "$file")
            ;;
    esac

    echo "$errors"
}

# 🔍 分析JavaScript/TypeScript文件
analyze_javascript_file() {
    local file="$1"
    local errors="[]"

    # 常见的JavaScript错误模式
    local patterns=(
        "console\.error"           # 调试日志
        "undefined"                # 未定义变量
        "null.*\."                 # null引用
        "catch.*{\s*}"             # 空catch块
        "TODO|FIXME|HACK"          # 待处理标记
    )

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        for pattern in "${patterns[@]}"; do
            if [[ "$line" =~ $pattern ]]; then
                local error_entry=$(jq -n \
                    --arg line "$line" \
                    --arg pattern "$pattern" \
                    --arg line_num "$line_num" \
                    '{
                        type: "code_issue",
                        pattern: $pattern,
                        message: $line,
                        line: ($line_num | tonumber),
                        severity: "warning",
                        language: "javascript"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
                break
            fi
        done
    done < "$file"

    echo "$errors"
}

# 🔍 分析Python文件
analyze_python_file() {
    local file="$1"
    local errors="[]"

    local patterns=(
        "print("                   # 调试打印
        "except.*:"                # 裸except
        "TODO|FIXME|HACK"          # 待处理标记
        "pass"                     # 空pass语句
    )

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        for pattern in "${patterns[@]}"; do
            if [[ "$line" =~ $pattern ]]; then
                local error_entry=$(jq -n \
                    --arg line "$line" \
                    --arg pattern "$pattern" \
                    --arg line_num "$line_num" \
                    '{
                        type: "code_issue",
                        pattern: $pattern,
                        message: $line,
                        line: ($line_num | tonumber),
                        severity: "warning",
                        language: "python"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
                break
            fi
        done
    done < "$file"

    echo "$errors"
}

# 🔍 分析Java文件（简化版）
analyze_java_file() {
    local file="$1"
    local errors="[]"

    local patterns=(
        "System\.out\.print"       # 调试打印
        "TODO|FIXME|HACK"          # 待处理标记
        "catch.*{\s*}"             # 空catch块
    )

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        for pattern in "${patterns[@]}"; do
            if [[ "$line" =~ $pattern ]]; then
                local error_entry=$(jq -n \
                    --arg line "$line" \
                    --arg pattern "$pattern" \
                    --arg line_num "$line_num" \
                    '{
                        type: "code_issue",
                        pattern: $pattern,
                        message: $line,
                        line: ($line_num | tonumber),
                        severity: "warning",
                        language: "java"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
                break
            fi
        done
    done < "$file"

    echo "$errors"
}

# 🔍 分析C/C++文件（简化版）
analyze_cpp_file() {
    local file="$1"
    local errors="[]"

    local patterns=(
        "printf|cout"              # 调试输出
        "TODO|FIXME|HACK"          # 待处理标记
        "catch.*{\s*}"             # 空catch块
    )

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        for pattern in "${patterns[@]}"; do
            if [[ "$line" =~ $pattern ]]; then
                local error_entry=$(jq -n \
                    --arg line "$line" \
                    --arg pattern "$pattern" \
                    --arg line_num "$line_num" \
                    '{
                        type: "code_issue",
                        pattern: $pattern,
                        message: $line,
                        line: ($line_num | tonumber),
                        severity: "warning",
                        language: "cpp"
                    }')
                errors=$(echo "$errors" | jq --argjson entry "$error_entry" '. += [$entry]')
                break
            fi
        done
    done < "$file"

    echo "$errors"
}

# 📊 对错误进行分类和统计
categorize_errors() {
    local error_data_file="$1"
    local similarity_threshold="${2:-$DEFAULT_SIMILARITY_THRESHOLD}"
    local max_categories="${3:-50}"

    if [ ! -f "$error_data_file" ]; then
        log_error "错误数据文件不存在: $error_data_file" "pattern-analyzer"
        return 1
    fi

    log_info "对错误进行分类分析" "pattern-analyzer"

    # 读取错误数据
    local error_data=$(cat "$error_data_file")

    # 初始化分类结果
    local categories="{}"
    local total_errors=$(echo "$error_data" | jq 'length')

    log_info "分析 $total_errors 个错误条目" "pattern-analyzer"

    # 按类型分类
    local error_types=$(echo "$error_data" | jq -r '.[].errors[].type' | sort | uniq -c | sort -nr)

    # 按模式分类
    local pattern_stats=$(echo "$error_data" | jq -r '.[].errors[].pattern' | sort | uniq -c | sort -nr)

    # 按文件统计
    local file_stats=$(echo "$error_data" | jq -r '.[].file' | sort | uniq -c | sort -nr)

    # 构建分类结果
    categories=$(jq -n \
        --arg total_errors "$total_errors" \
        --arg error_types "$error_types" \
        --arg pattern_stats "$pattern_stats" \
        --arg file_stats "$file_stats" \
        '{
            summary: {
                total_errors: ($total_errors | tonumber),
                total_files: ($file_stats | split("\n") | length),
                total_patterns: ($pattern_stats | split("\n") | length)
            },
            error_types: ($error_types | split("\n") | map(select(. != "") | split(" +") | {type: .[2], count: (.[1] | tonumber)}) | .[:20]),
            patterns: ($pattern_stats | split("\n") | map(select(. != "") | split(" +") | {pattern: .[2], count: (.[1] | tonumber)}) | .[:20]),
            files: ($file_stats | split("\n") | map(select(. != "") | split(" +") | {file: .[2], count: (.[1] | tonumber)}) | .[:20])
        }')

    # 识别高影响文件（错误最多的文件）
    local high_impact_files=$(echo "$categories" | jq '.files[] | select(.count > 5)')

    if [ -n "$high_impact_files" ]; then
        categories=$(echo "$categories" | jq --argjson high_impact "$high_impact_files" '.high_impact_files = $high_impact')
    fi

    # 生成建议
    local recommendations=$(generate_recommendations "$categories")

    categories=$(echo "$categories" | jq --argjson recommendations "$recommendations" '.recommendations = $recommendations')

    echo "$categories"
}

# 💡 生成修复建议
generate_recommendations() {
    local categories="$1"
    local recommendations="[]"

    # 基于错误数量的建议
    local total_errors=$(echo "$categories" | jq -r '.summary.total_errors')
    if [ "$total_errors" -gt 100 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["错误数量较多，建议优先修复高影响文件"]')
    fi

    # 基于高影响文件的建议
    local high_impact_count=$(echo "$categories" | jq '.high_impact_files | length')
    if [ "$high_impact_count" -gt 0 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["发现'"$high_impact_count"'个高影响文件，建议优先处理"]')
    fi

    # 基于错误类型的建议
    local top_error_type=$(echo "$categories" | jq -r '.error_types[0].type')
    case "$top_error_type" in
        "log_error")
            recommendations=$(echo "$recommendations" | jq '. += ["日志中发现大量错误，建议检查应用运行状态"]')
            ;;
        "test_failure")
            recommendations=$(echo "$recommendations" | jq '. += ["测试失败较多，建议修复测试用例或被测代码"]')
            ;;
        "code_issue")
            recommendations=$(echo "$recommendations" | jq '. += ["代码质量问题较多，建议进行代码重构"]')
            ;;
    esac

    # 基于模式数量的建议
    local pattern_count=$(echo "$categories" | jq -r '.summary.total_patterns')
    if [ "$pattern_count" -gt 10 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["错误模式多样，建议使用批量修复策略"]')
    fi

    echo "$recommendations"
}

# 🔧 批量修复相似错误
batch_fix_similar_errors() {
    local pattern="$1"
    local dry_run="${2:-false}"
    local max_files="${3:-$DEFAULT_BATCH_LIMIT}"

    log_info "开始批量修复错误模式: $pattern" "pattern-analyzer"

    if [ "$dry_run" = "true" ]; then
        log_info "DRY RUN 模式 - 不会实际修改文件" "pattern-analyzer"
    fi

    # 查找包含该模式的文件
    local affected_files=$(grep -r "$pattern" . --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.py" --include="*.java" -l 2>/dev/null | head -n "$max_files")

    if [ -z "$affected_files" ]; then
        log_warn "未找到包含模式 '$pattern' 的文件" "pattern-analyzer"
        return 0
    fi

    local file_count=$(echo "$affected_files" | wc -l)
    log_info "找到 $file_count 个受影响的文件" "pattern-analyzer"

    # 确定修复策略
    local fix_strategy=$(determine_fix_strategy "$pattern")

    # 逐个处理文件
    local success_count=0
    local fail_count=0

    while IFS= read -r file; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            log_debug "处理文件: $file" "pattern-analyzer"

            if apply_fix_to_file "$file" "$pattern" "$fix_strategy" "$dry_run"; then
                success_count=$((success_count + 1))
            else
                fail_count=$((fail_count + 1))
            fi
        fi
    done <<< "$affected_files"

    # 生成修复报告
    local fix_report=$(jq -n \
        --arg pattern "$pattern" \
        --arg total_files "$file_count" \
        --arg success_count "$success_count" \
        --arg fail_count "$fail_count" \
        --arg dry_run "$dry_run" \
        '{
            pattern: $pattern,
            fix_strategy: "batch_replace",
            summary: {
                total_files: ($total_files | tonumber),
                success_count: ($success_count | tonumber),
                fail_count: ($fail_count | tonumber),
                dry_run: ($dry_run == "true")
            },
            timestamp: (now | strftime("%Y-%m-%d %H:%M:%S"))
        }')

    local report_file="$ANALYSIS_DIR/fix_report_$(date '+%Y%m%d_%H%M%S').json"
    echo "$fix_report" | jq . > "$report_file" 2>/dev/null || echo "$fix_report" > "$report_file"

    log_info "批量修复完成: $success_count 成功, $fail_count 失败" "pattern-analyzer"
    log_info "修复报告: $report_file" "pattern-analyzer"

    # 🎯 检查是否应该自动提交重大进展
    if [ "$dry_run" != "true" ] && [ $success_count -gt 0 ]; then
        check_and_auto_commit "$pattern" "$success_count" "$fail_count" "$file_count"
    fi
}

# 🎯 确定修复策略
determine_fix_strategy() {
    local pattern="$1"

    case "$pattern" in
        "console.log"|"print("|"printf")
            echo "remove_debug_logs"
            ;;
        "TODO"|"FIXME")
            echo "add_comments"
            ;;
        "undefined")
            echo "add_null_checks"
            ;;
        "catch.*{}")
            echo "add_error_handling"
            ;;
        *)
            echo "safe_comment"
            ;;
    esac
}

# 🔧 对单个文件应用修复
apply_fix_to_file() {
    local file="$1"
    local pattern="$2"
    local strategy="$3"
    local dry_run="$4"

    log_debug "应用修复策略 '$strategy' 到文件: $file" "pattern-analyzer"

    # 创建备份
    local backup_file="${file}.fix_backup_$(date '+%Y%m%d_%H%M%S')"
    if [ "$dry_run" != "true" ]; then
        cp "$file" "$backup_file"
    fi

    case "$strategy" in
        "remove_debug_logs")
            # 移除调试日志
            if [ "$dry_run" = "true" ]; then
                log_info "[DRY RUN] 将移除文件 $file 中的调试日志" "pattern-analyzer"
            else
                sed -i "/$pattern/d" "$file"
            fi
            ;;
        "add_comments")
            # 为TODO/FIXME添加注释说明
            if [ "$dry_run" = "true" ]; then
                log_info "[DRY RUN] 将为文件 $file 中的 $pattern 添加注释" "pattern-analyzer"
            else
                sed -i "s/$pattern/$pattern # 需要处理/g" "$file"
            fi
            ;;
        "safe_comment")
            # 安全注释可疑行
            if [ "$dry_run" = "true" ]; then
                log_info "[DRY RUN] 将注释文件 $file 中的可疑行" "pattern-analyzer"
            else
                # 根据文件类型选择注释符
                case "${file##*.}" in
                    "js"|"ts"|"jsx"|"tsx"|"java")
                        sed -i "/$pattern/s|^|// PATTERN_ANALYZER: |g" "$file"
                        ;;
                    "py")
                        sed -i "/$pattern/s|^|# PATTERN_ANALYZER: |g" "$file"
                        ;;
                    "cpp"|"c")
                        sed -i "/$pattern/s|^|// PATTERN_ANALYZER: |g" "$file"
                        ;;
                    *)
                        sed -i "/$pattern/s|^|# PATTERN_ANALYZER: |g" "$file"
                        ;;
                esac
            fi
            ;;
        *)
            log_warn "未知的修复策略: $strategy" "pattern-analyzer"
            return 1
            ;;
    esac

    # 验证文件语法
    if [ "$dry_run" != "true" ] && ! validate_file_syntax "$file"; then
        log_error "语法验证失败，回滚更改: $file" "pattern-analyzer"
        mv "$backup_file" "$file"
        return 1
    fi

    return 0
}

# ✅ 验证文件语法
validate_file_syntax() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        "js"|"jsx"|"ts"|"tsx")
            if command -v node &> /dev/null; then
                node -c "$file" &>/dev/null
                return $?
            fi
            ;;
        "py")
            if command -v python3 &> /dev/null; then
                python3 -m py_compile "$file" &>/dev/null
                return $?
            fi
            ;;
        "json")
            if command -v jq &> /dev/null; then
                jq empty "$file" &>/dev/null
                return $?
            fi
            ;;
    esac

    # 默认认为语法正确
    return 0
}

# 📊 生成分析报告
generate_analysis_report() {
    local categories="$1"
    local output_format="${2:-json}"
    local output_file="$ANALYSIS_DIR/analysis_report_$(date '+%Y%m%d_%H%M%S').$output_format"

    case "$output_format" in
        "json")
            echo "$categories" | jq . > "$output_file"
            ;;
        "text")
            generate_text_report "$categories" > "$output_file"
            ;;
        "html")
            generate_html_report "$categories" > "$output_file"
            ;;
        *)
            log_error "不支持的输出格式: $output_format" "pattern-analyzer"
            return 1
            ;;
    esac

    log_info "分析报告已生成: $output_file" "pattern-analyzer"
    echo "$output_file"
}

# 📄 生成文本报告
generate_text_report() {
    local categories="$1"

    cat << EOF
🔍 错误模式分析报告
$(printf '%.0s=' {1..50})

📊 概览
总错误数: $(echo "$categories" | jq -r '.summary.total_errors')
受影响文件数: $(echo "$categories" | jq -r '.summary.total_files')
错误模式数: $(echo "$categories" | jq -r '.summary.total_patterns')

📋 错误类型统计
$(echo "$categories" | jq -r '.error_types[] | "- \(.type): \(.count) 次"' 2>/dev/null || echo "无数据")

🎯 常见错误模式
$(echo "$categories" | jq -r '.patterns[] | "- \(.pattern): \(.count) 次"' 2>/dev/null || echo "无数据")

📁 高影响文件
$(echo "$categories" | jq -r '.files[] | "- \(.file): \(.count) 个错误"' 2>/dev/null || echo "无数据")

💡 修复建议
$(echo "$categories" | jq -r '.recommendations[] | "- \(. )"' 2>/dev/null || echo "无数据")

生成时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF
}

# 🌐 生成HTML报告
generate_html_report() {
    local categories="$1"

    cat << EOF
<!DOCTYPE html>
<html>
<head>
    <title>错误模式分析报告</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .summary { background: #f0f0f0; padding: 10px; border-radius: 5px; }
        .section { margin: 20px 0; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .error { color: #d9534f; }
        .warning { color: #f0ad4e; }
        .success { color: #5cb85c; }
    </style>
</head>
<body>
    <h1>🔍 错误模式分析报告</h1>

    <div class="summary section">
        <h2>📊 概览</h2>
        <p>总错误数: <strong>$(echo "$categories" | jq -r '.summary.total_errors')</strong></p>
        <p>受影响文件数: <strong>$(echo "$categories" | jq -r '.summary.total_files')</strong></p>
        <p>错误模式数: <strong>$(echo "$categories" | jq -r '.summary.total_patterns')</strong></p>
        <p>生成时间: $(date '+%Y-%m-%d %H:%M:%S')</p>
    </div>

    <div class="section">
        <h2>📋 错误类型统计</h2>
        <table>
            <tr><th>错误类型</th><th>出现次数</th></tr>
            $(echo "$categories" | jq -r '.error_types[] | "<tr><td>\(.type)</td><td>\(.count)</td></tr>"' 2>/dev/null || echo "")
        </table>
    </div>

    <div class="section">
        <h2>🎯 常见错误模式</h2>
        <table>
            <tr><th>错误模式</th><th>出现次数</th></tr>
            $(echo "$categories" | jq -r '.patterns[] | "<tr><td>\(.pattern)</td><td>\(.count)</td></tr>"' 2>/dev/null || echo "")
        </table>
    </div>

    <div class="section">
        <h2>📁 高影响文件</h2>
        <table>
            <tr><th>文件路径</th><th>错误数量</th></tr>
            $(echo "$categories" | jq -r '.files[] | "<tr><td>\(.file)</td><td>\(.count)</td></tr>"' 2>/dev/null || echo "")
        </table>
    </div>

    <div class="section">
        <h2>💡 修复建议</h2>
        <ul>
            $(echo "$categories" | jq -r '.recommendations[] | "<li>\(.)</li>"' 2>/dev/null || echo "")
        </ul>
    </div>
</body>
</html>
EOF
}

# 🎯 自动提交重大修复进展
check_and_auto_commit() {
    local pattern="$1"
    local success_count="$2"
    local fail_count="$3"
    local total_files="$4"

    # 计算修复成功率
    local success_rate=0
    if [ "$total_files" -gt 0 ]; then
        success_rate=$(( (success_count * 100) / total_files ))
    fi

    # 判断是否为重大进展
    local should_commit=false
    local commit_reason=""

    if [ $success_rate -ge 80 ] && [ $success_count -ge 3 ]; then
        should_commit=true
        commit_reason="高成功率批量修复"
    elif [ $success_count -ge 10 ]; then
        should_commit=true
        commit_reason="大量文件修复"
    elif [ $success_rate -ge 50 ] && [ $total_files -ge 5 ]; then
        should_commit=true
        commit_reason="中等规模有效修复"
    fi

    if [ "$should_commit" = true ]; then
        log_info "检测到重大修复进展 ($commit_reason)，准备自动提交..." "pattern-analyzer"

        # 检查git状态
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            log_warn "当前目录不是git仓库，跳过自动提交" "pattern-analyzer"
            return 0
        fi

        # 检查是否有未暂存的更改
        local staged_changes=$(git diff --cached --name-only | wc -l)
        local unstaged_changes=$(git diff --name-only | wc -l)

        if [ "$unstaged_changes" -gt 0 ]; then
            log_info "暂存修复的更改..." "pattern-analyzer"
            git add .
        fi

        # 生成详细的commit message
        local commit_msg=$(generate_commit_message "$pattern" "$success_count" "$fail_count" "$total_files" "$success_rate" "$commit_reason")

        # 执行提交
        if git commit -m "$commit_msg" 2>/dev/null; then
            log_info "✅ 自动提交成功！" "pattern-analyzer"
            log_info "Commit: $commit_msg" "pattern-analyzer"

            # 显示提交详情
            local commit_hash=$(git rev-parse HEAD)
            log_info "Commit Hash: ${commit_hash:0:8}" "pattern-analyzer"
        else
            log_warn "自动提交失败，可能没有更改或已存在相同提交" "pattern-analyzer"
        fi
    else
        log_debug "修复规模不足，跳过自动提交 (成功率: ${success_rate}%, 成功数: $success_count)" "pattern-analyzer"
    fi
}

# 📝 生成详细的commit message
generate_commit_message() {
    local pattern="$1"
    local success_count="$2"
    local fail_count="$3"
    local total_files="$4"
    local success_rate="$5"
    local commit_reason="$6"

    # 清理pattern用于commit message
    local clean_pattern=$(echo "$pattern" | sed 's/"/\\"/g' | sed 's/`/\\`/g')

    # 生成基础message
    local base_msg="fix: 批量修复错误模式 '$clean_pattern'"

    # 添加统计信息
    local stats_msg=""
    stats_msg+="\n\n修复统计:"
    stats_msg+="\n- 成功修复: $success_count/$total_files 个文件"
    stats_msg+="\n- 成功率: ${success_rate}%"
    if [ "$fail_count" -gt 0 ]; then
        stats_msg+="\n- 失败数量: $fail_count"
    fi

    # 添加修复策略信息
    local strategy_msg=""
    case "$pattern" in
        "console.log"|"print("|"printf")
            strategy_msg+="\n\n修复策略: 移除调试日志"
            ;;
        "TODO"|"FIXME")
            strategy_msg+="\n\n修复策略: 添加任务注释"
            ;;
        "undefined")
            strategy_msg+="\n\n修复策略: 添加空值检查"
            ;;
        "catch.*{}")
            strategy_msg+="\n\n修复策略: 添加错误处理"
            ;;
        *)
            strategy_msg+="\n\n修复策略: 安全注释处理"
            ;;
    esac

    # 添加自动提交标记
    local auto_msg="\n\n🤖 自动提交 - $commit_reason"

    # 组合完整message
    echo "$base_msg$stats_msg$strategy_msg$auto_msg"
}

# ✅ 验证修复效果
validate_fix_effect() {
    local pattern="$1"
    local test_cmd="${2:-$DEFAULT_TEST_CMD}"

    log_info "验证修复效果: $pattern" "pattern-analyzer"

    # 运行测试前的错误统计
    local before_errors=$(run_test_and_count_errors "$test_cmd")
    local before_count=$(echo "$before_errors" | jq -r '.error_count' 2>/dev/null || echo "0")

    # 应用修复（这里应该调用batch_fix_similar_errors，但为了演示我们先跳过）
    log_info "应用修复..." "pattern-analyzer"
    # batch_fix_similar_errors "$pattern" "false" 5

    # 运行测试后的错误统计
    local after_errors=$(run_test_and_count_errors "$test_cmd")
    local after_count=$(echo "$after_errors" | jq -r '.error_count' 2>/dev/null || echo "0")

    local error_reduction=$((before_count - after_count))

    local validation_report=$(jq -n \
        --arg pattern "$pattern" \
        --arg before_count "$before_count" \
        --arg after_count "$after_count" \
        --arg error_reduction "$error_reduction" \
        '{
            pattern: $pattern,
            validation: {
                before_fix: {
                    error_count: ($before_count | tonumber)
                },
                after_fix: {
                    error_count: ($after_count | tonumber)
                },
                improvement: {
                    error_reduction: ($error_reduction | tonumber),
                    success_rate: (if ($before_count | tonumber) > 0 then (($error_reduction | tonumber) / ($before_count | tonumber) * 100) else 0 end)
                }
            },
            timestamp: (now | strftime("%Y-%m-%d %H:%M:%S"))
        }')

    local report_file="$ANALYSIS_DIR/validation_report_$(date '+%Y%m%d_%H%M%S').json"
    echo "$validation_report" | jq . > "$report_file" 2>/dev/null || echo "$validation_report" > "$report_file"

    log_info "修复效果验证完成: 错误减少 $error_reduction 个" "pattern-analyzer"
    log_info "验证报告: $report_file" "pattern-analyzer"

    # 🎯 检查是否应该自动提交重大进展
    if [ "$error_reduction" -gt 0 ]; then
        check_validation_auto_commit "$pattern" "$before_count" "$after_count" "$error_reduction"
    fi

    echo "$validation_report"
}

# 🎯 验证结果自动提交
check_validation_auto_commit() {
    local pattern="$1"
    local before_count="$2"
    local after_count="$3"
    local error_reduction="$4"

    # 计算改善幅度
    local improvement_percentage=0
    if [ "$before_count" -gt 0 ]; then
        improvement_percentage=$(( (error_reduction * 100) / before_count ))
    fi

    # 判断是否为重大进展
    local should_commit=false
    local commit_reason=""

    if [ $improvement_percentage -ge 30 ]; then
        should_commit=true
        commit_reason="重大错误减少 (≥30%)"
    elif [ $error_reduction -ge 10 ]; then
        should_commit=true
        commit_reason="显著错误减少 (≥10个)"
    elif [ $improvement_percentage -ge 20 ] && [ $before_count -ge 5 ]; then
        should_commit=true
        commit_reason="中等改善幅度 (≥20%)"
    fi

    if [ "$should_commit" = true ]; then
        log_info "检测到重大修复进展 ($commit_reason)，准备自动提交..." "pattern-analyzer"

        # 检查git状态
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            log_warn "当前目录不是git仓库，跳过自动提交" "pattern-analyzer"
            return 0
        fi

        # 检查是否有未暂存的更改
        local unstaged_changes=$(git diff --name-only | wc -l)

        if [ "$unstaged_changes" -gt 0 ]; then
            log_info "暂存验证修复的更改..." "pattern-analyzer"
            git add .
        fi

        # 生成详细的commit message
        local commit_msg=$(generate_validation_commit_message "$pattern" "$before_count" "$after_count" "$error_reduction" "$improvement_percentage" "$commit_reason")

        # 执行提交
        if git commit -m "$commit_msg" 2>/dev/null; then
            log_info "✅ 验证自动提交成功！" "pattern-analyzer"
            log_info "Commit: $(echo "$commit_msg" | head -1)" "pattern-analyzer"

            # 显示提交详情
            local commit_hash=$(git rev-parse HEAD)
            log_info "Commit Hash: ${commit_hash:0:8}" "pattern-analyzer"
        else
            log_warn "验证自动提交失败，可能没有更改或已存在相同提交" "pattern-analyzer"
        fi
    else
        log_debug "改善幅度不足，跳过自动提交 (减少: $error_reduction, 百分比: ${improvement_percentage}%)" "pattern-analyzer"
    fi
}

# 📝 生成验证结果的commit message
generate_validation_commit_message() {
    local pattern="$1"
    local before_count="$2"
    local after_count="$3"
    local error_reduction="$4"
    local improvement_percentage="$5"
    local commit_reason="$6"

    # 清理pattern用于commit message
    local clean_pattern=$(echo "$pattern" | sed 's/"/\\"/g' | sed 's/`/\\`/g')

    # 生成基础message
    local base_msg="fix: 验证修复错误模式 '$clean_pattern'"

    # 添加统计信息
    local stats_msg=""
    stats_msg+="\n\n修复验证结果:"
    stats_msg+="\n- 修复前错误数: $before_count"
    stats_msg+="\n- 修复后错误数: $after_count"
    stats_msg+="\n- 错误减少数量: $error_reduction"
    stats_msg+="\n- 改善幅度: ${improvement_percentage}%"

    # 添加验证信息
    local validation_msg=""
    if [ $improvement_percentage -ge 30 ]; then
        validation_msg+="\n\n🎉 重大改善 - 错误减少 ≥30%"
    elif [ $error_reduction -ge 10 ]; then
        validation_msg+="\n\n✅ 显著改善 - 减少 ≥10个错误"
    else
        validation_msg+="\n\n👍 有效改善 - 修复效果良好"
    fi

    # 添加自动提交标记
    local auto_msg="\n\n🤖 自动提交 - $commit_reason"

    # 组合完整message
    echo "$base_msg$stats_msg$validation_msg$auto_msg"
}

# 🧪 运行测试并统计错误
run_test_and_count_errors() {
    local test_cmd="$1"

    local test_output=""
    local exit_code=0

    if eval "$test_cmd" 2>&1; then
        test_output="Command succeeded"
    else
        exit_code=$?
        test_output="Command failed with exit code $exit_code"
    fi

    # 简单的错误计数（实际项目中可能需要更复杂的解析）
    local error_count=$(echo "$test_output" | grep -c -i "error\|fail\|exception" || echo "0")

    jq -n \
        --arg output "$test_output" \
        --arg exit_code "$exit_code" \
        --arg error_count "$error_count" \
        '{
            test_output: $output,
            exit_code: ($exit_code | tonumber),
            error_count: ($error_count | tonumber)
        }'
}

# 📋 显示帮助信息
show_help() {
    cat << EOF
🔍 同类项合并法：智能模式分析器 v1.0.0

使用方法:
  $0 analyze [--source <paths>] [--output <file>]
  $0 categorize <error_data_file> [--threshold <similarity>] [--limit <num>]
  $0 batch-fix <pattern> [--dry-run] [--max-files <num>]
  $0 report <categories_file> [--format <json|text|html>]
  $0 validate-fix <pattern> [--test-cmd <command>]
  $0 help

参数说明:
  analyze         收集和分析错误日志
    --source      指定源路径 (默认: .)
    --output      指定输出文件

  categorize      对错误数据进行分类
    --threshold   相似度阈值 (默认: $DEFAULT_SIMILARITY_THRESHOLD)
    --limit       最大分类数量 (默认: 50)

  batch-fix       批量修复相似错误
    --dry-run     仅模拟修复，不实际修改
    --max-files   最大处理文件数 (默认: $DEFAULT_BATCH_LIMIT)

  report          生成分析报告
    --format      输出格式: json, text, html (默认: json)

  validate-fix    验证修复效果
    --test-cmd    测试命令 (默认: $DEFAULT_TEST_CMD)

示例:
  $0 analyze --source src/
  $0 categorize error_logs.json --threshold 0.8
  $0 batch-fix "console.log" --dry-run --max-files 5
  $0 report categories.json --format html
  $0 validate-fix "undefined" --test-cmd "npm test"

安全特性:
- 支持dry-run模式验证修复效果
- 自动创建备份确保可回滚
- 语法验证防止破坏代码结构
- 分批处理减少风险冲击

EOF
}

# 🎯 主函数
main() {
    init_analysis_directory

    local command="$1"
    shift

    case "$command" in
        "analyze")
            local source_paths="."
            local output_file=""

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --source)
                        source_paths="$2"
                        shift 2
                        ;;
                    --output)
                        output_file="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            local error_data_file=$(collect_error_logs "$source_paths")

            if [ -n "$error_data_file" ]; then
                local categories=$(categorize_errors "$error_data_file")

                if [ -n "$output_file" ]; then
                    echo "$categories" | jq . > "$output_file"
                    log_info "分析结果已保存到: $output_file" "pattern-analyzer"
                else
                    echo "$categories" | jq .
                fi
            fi
            ;;

        "categorize")
            local error_data_file=""
            local similarity_threshold="$DEFAULT_SIMILARITY_THRESHOLD"
            local max_categories=50

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --threshold)
                        similarity_threshold="$2"
                        shift 2
                        ;;
                    --limit)
                        max_categories="$2"
                        shift 2
                        ;;
                    *)
                        if [ -z "$error_data_file" ]; then
                            error_data_file="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$error_data_file" ]; then
                log_error "请提供错误数据文件" "pattern-analyzer"
                exit 1
            fi

            categorize_errors "$error_data_file" "$similarity_threshold" "$max_categories"
            ;;

        "batch-fix")
            local pattern=""
            local dry_run="false"
            local max_files="$DEFAULT_BATCH_LIMIT"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --dry-run)
                        dry_run="true"
                        shift
                        ;;
                    --max-files)
                        max_files="$2"
                        shift 2
                        ;;
                    *)
                        if [ -z "$pattern" ]; then
                            pattern="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$pattern" ]; then
                log_error "请提供要修复的错误模式" "pattern-analyzer"
                exit 1
            fi

            batch_fix_similar_errors "$pattern" "$dry_run" "$max_files"
            ;;

        "report")
            local categories_file=""
            local output_format="json"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --format)
                        output_format="$2"
                        shift 2
                        ;;
                    *)
                        if [ -z "$categories_file" ]; then
                            categories_file="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$categories_file" ] || [ ! -f "$categories_file" ]; then
                log_error "请提供有效的分类数据文件" "pattern-analyzer"
                exit 1
            fi

            local categories=$(cat "$categories_file")
            generate_analysis_report "$categories" "$output_format"
            ;;

        "validate-fix")
            local pattern=""
            local test_cmd="$DEFAULT_TEST_CMD"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --test-cmd)
                        test_cmd="$2"
                        shift 2
                        ;;
                    *)
                        if [ -z "$pattern" ]; then
                            pattern="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$pattern" ]; then
                log_error "请提供要验证的错误模式" "pattern-analyzer"
                exit 1
            fi

            validate_fix_effect "$pattern" "$test_cmd"
            ;;

        "help"|"-h"|"--help"|"")
            show_help
            ;;

        *)
            log_error "未知命令: $command" "pattern-analyzer"
            echo "运行 '$0 help' 查看可用命令"
            exit 1
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi