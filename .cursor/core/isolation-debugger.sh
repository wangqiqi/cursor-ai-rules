#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🌟 Cursor AI Rules - 注释大法：智能隔离调试器
# 基于用户经验实现模块隔离调试，支持安全备份和渐进式测试
#
# 使用方法:
#   ./isolation-debugger.sh isolate <target_file> [--depth <level>] [--test-cmd <command>]
#   ./isolation-debugger.sh restore <target_file> [--backup <timestamp>]
#   ./isolation-debugger.sh analyze <target_file> [--report-only]
#   ./isolation-debugger.sh batch-isolate <pattern> [--max-files <num>]
#
# 作者: Cursor AI Rules Team
# 版本: v1.0.0
# 更新: 2026-01-16

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEBUG_DIR="$PROJECT_ROOT/.cursor/debug"
BACKUP_DIR="$DEBUG_DIR/backups"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置变量
DEFAULT_TEST_CMD="npm test"
DEFAULT_ISOLATION_DEPTH=3
MAX_BACKUP_FILES=50
BACKUP_RETENTION_DAYS=7

# 导入公共函数
if [ -f "$SCRIPT_DIR/../core/common.sh" ]; then
    source "$SCRIPT_DIR/../core/common.sh"
fi

# 导入日志函数
if [ -f "$SCRIPT_DIR/../core/logging.sh" ]; then
    source "$SCRIPT_DIR/../core/logging.sh"
fi

# 📁 初始化备份目录
init_backup_directory() {
    mkdir -p "$BACKUP_DIR"
    log_info "初始化备份目录: $BACKUP_DIR" "isolation-debugger"
}

# 🔍 分析文件结构，识别可隔离的代码块
analyze_file_structure() {
    local target_file="$1"

    if [ ! -f "$target_file" ]; then
        log_error "目标文件不存在: $target_file" "isolation-debugger"
        return 1
    fi

    log_info "分析文件结构: $target_file" "isolation-debugger"

    # 获取文件类型
    local file_ext="${target_file##*.}"
    local file_type="unknown"

    case "$file_ext" in
        "js"|"jsx"|"ts"|"tsx")
            file_type="javascript"
            ;;
        "py")
            file_type="python"
            ;;
        "java")
            file_type="java"
            ;;
        "cpp"|"cc"|"cxx")
            file_type="cpp"
            ;;
        "json")
            file_type="json"
            ;;
        "yaml"|"yml")
            file_type="yaml"
            ;;
        *)
            file_type="text"
            ;;
    esac

    # 识别代码块
    case "$file_type" in
        "javascript")
            identify_js_blocks "$target_file"
            ;;
        "python")
            identify_python_blocks "$target_file"
            ;;
        "json")
            identify_json_blocks "$target_file"
            ;;
        *)
            identify_generic_blocks "$target_file"
            ;;
    esac
}

# 🔍 识别JavaScript/TypeScript代码块
identify_js_blocks() {
    local file="$1"
    local blocks="[]"

    log_debug "识别JavaScript代码块: $file" "isolation-debugger"

    # 识别函数定义
    local functions=$(grep -n "^[[:space:]]*function\|^[[:space:]]*const.*=>|^[[:space:]]*class\|^[[:space:]]*export.*function" "$file" | head -20)

    # 识别重要的配置对象
    local configs=$(grep -n "^[[:space:]]*const.*=\s*{\|^[[:space:]]*let.*=\s*{\|^[[:space:]]*var.*=\s*{" "$file" | head -10)

    # 识别导入语句块
    local imports=$(grep -n "^[[:space:]]*import\|^[[:space:]]*const.*require" "$file" | head -10)

    # 构建代码块信息
    blocks=$(jq -n \
        --arg functions "$functions" \
        --arg configs "$configs" \
        --arg imports "$imports" \
        '{
            functions: ($functions | split("\n") | map(select(. != ""))),
            configs: ($configs | split("\n") | map(select(. != ""))),
            imports: ($imports | split("\n") | map(select(. != ""))),
            file_type: "javascript"
        }')

    echo "$blocks"
}

# 🔍 识别Python代码块
identify_python_blocks() {
    local file="$1"
    local blocks="[]"

    log_debug "识别Python代码块: $file" "isolation-debugger"

    # 识别函数定义
    local functions=$(grep -n "^[[:space:]]*def\|^[[:space:]]*class" "$file" | head -20)

    # 识别重要的配置
    local configs=$(grep -n "^[[:space:]]*CONFIG\|^[[:space:]]*[A-Z_]*\s*=" "$file" | head -10)

    # 识别导入语句
    local imports=$(grep -n "^[[:space:]]*import\|^[[:space:]]*from.*import" "$file" | head -10)

    blocks=$(jq -n \
        --arg functions "$functions" \
        --arg configs "$configs" \
        --arg imports "$imports" \
        '{
            functions: ($functions | split("\n") | map(select(. != ""))),
            configs: ($configs | split("\n") | map(select(. != ""))),
            imports: ($imports | split("\n") | map(select(. != ""))),
            file_type: "python"
        }')

    echo "$blocks"
}

# 🔍 识别JSON配置块
identify_json_blocks() {
    local file="$1"
    local blocks="[]"

    log_debug "识别JSON配置块: $file" "isolation-debugger"

    # 对于JSON文件，识别顶级键
    if command -v jq &> /dev/null; then
        local keys=$(jq -r 'keys[]' "$file" 2>/dev/null | head -20)
        blocks=$(jq -n \
            --arg keys "$keys" \
            '{
                top_level_keys: ($keys | split("\n") | map(select(. != ""))),
                file_type: "json"
            }')
    fi

    echo "$blocks"
}

# 🔍 识别通用代码块
identify_generic_blocks() {
    local file="$1"
    local blocks="[]"

    log_debug "识别通用代码块: $file" "isolation-debugger"

    # 按空行分割的段落
    local paragraphs=$(awk 'BEGIN{RS=""; ORS="\n\n"} {print NR ": " $0}' "$file" | head -10)

    blocks=$(jq -n \
        --arg paragraphs "$paragraphs" \
        '{
            paragraphs: ($paragraphs | split("\n\n") | map(select(. != ""))),
            file_type: "generic"
        }')

    echo "$blocks"
}

# 🛡️ 创建带时间戳的备份
create_timestamped_backup() {
    local target_file="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/$(basename "$target_file").$timestamp.backup"

    init_backup_directory

    if [ -f "$target_file" ]; then
        cp "$target_file" "$backup_file"
        log_info "创建备份: $backup_file" "isolation-debugger"
        echo "$backup_file"
    else
        log_error "无法备份不存在的文件: $target_file" "isolation-debugger"
        return 1
    fi
}

# 🧠 智能隔离代码块
isolate_code_blocks() {
    local target_file="$1"
    local isolation_type="${2:-comment}"
    local max_blocks="${3:-5}"

    log_info "开始隔离代码块: $target_file" "isolation-debugger"

    # 创建备份
    local backup_file=$(create_timestamped_backup "$target_file")
    if [ $? -ne 0 ]; then
        return 1
    fi

    # 分析文件结构
    local blocks_info=$(analyze_file_structure "$target_file")

    case "$isolation_type" in
        "comment")
            isolate_by_commenting "$target_file" "$blocks_info" "$max_blocks"
            ;;
        "conditional")
            isolate_by_conditionals "$target_file" "$blocks_info" "$max_blocks"
            ;;
        "remove")
            isolate_by_removing "$target_file" "$blocks_info" "$max_blocks"
            ;;
        *)
            log_error "未知的隔离类型: $isolation_type" "isolation-debugger"
            return 1
            ;;
    esac

    # 生成隔离报告
    generate_isolation_report "$target_file" "$backup_file" "$isolation_type"
}

# 💬 通过注释隔离代码
isolate_by_commenting() {
    local file="$1"
    local blocks_info="$2"
    local max_blocks="$3"

    log_info "通过注释进行隔离调试" "isolation-debugger"

    # 解析文件类型
    local file_type=$(echo "$blocks_info" | jq -r '.file_type')

    case "$file_type" in
        "javascript")
            isolate_js_by_commenting "$file" "$blocks_info" "$max_blocks"
            ;;
        "python")
            isolate_python_by_commenting "$file" "$blocks_info" "$max_blocks"
            ;;
        *)
            isolate_generic_by_commenting "$file" "$blocks_info" "$max_blocks"
            ;;
    esac
}

# 💬 JavaScript注释隔离
isolate_js_by_commenting() {
    local file="$1"
    local blocks_info="$2"
    local max_blocks="$3"

    # 获取函数定义
    local functions=$(echo "$blocks_info" | jq -r '.functions[]' 2>/dev/null | head -n "$max_blocks")

    if [ -n "$functions" ]; then
        log_info "注释JavaScript函数定义" "isolation-debugger"

        # 为每个函数添加注释标记
        local temp_file="${file}.tmp"
        cp "$file" "$temp_file"

        while IFS= read -r func_line; do
            if [ -n "$func_line" ]; then
                local line_num=$(echo "$func_line" | cut -d: -f1)
                local func_name=$(echo "$func_line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]].*//')

                # 在函数前添加隔离注释
                sed -i "${line_num}i// 🔍 ISOLATION DEBUG: Function $func_name commented out for testing" "$temp_file"
                sed -i "${line_num}s/^/\/\/ /" "$temp_file"
            fi
        done <<< "$functions"

        mv "$temp_file" "$file"
    fi
}

# 💬 Python注释隔离
isolate_python_by_commenting() {
    local file="$1"
    local blocks_info="$2"
    local max_blocks="$3"

    local functions=$(echo "$blocks_info" | jq -r '.functions[]' 2>/dev/null | head -n "$max_blocks")

    if [ -n "$functions" ]; then
        log_info "注释Python函数定义" "isolation-debugger"

        local temp_file="${file}.tmp"
        cp "$file" "$temp_file"

        while IFS= read -r func_line; do
            if [ -n "$func_line" ]; then
                local line_num=$(echo "$func_line" | cut -d: -f1)

                # 在函数前添加隔离注释
                sed -i "${line_num}i# 🔍 ISOLATION DEBUG: Function commented out for testing" "$temp_file"
                sed -i "${line_num}s/^/# /" "$temp_file"
            fi
        done <<< "$functions"

        mv "$temp_file" "$file"
    fi
}

# 💬 通用注释隔离
isolate_generic_by_commenting() {
    local file="$1"
    local blocks_info="$2"
    local max_blocks="$3"

    log_info "通用注释隔离" "isolation-debugger"

    # 对于通用文件，在文件开头添加隔离标记
    local temp_file="${file}.tmp"
    cp "$file" "$temp_file"

    echo "# 🔍 ISOLATION DEBUG: File content commented out for testing" > "$file"
    echo "# Original file backed up automatically" >> "$file"
    echo "" >> "$file"
    cat "$temp_file" >> "$file"

    rm "$temp_file"
}

# 🔄 条件编译隔离
isolate_by_conditionals() {
    local file="$1"
    local blocks_info="$2"
    local max_blocks="$3"

    log_info "通过条件编译进行隔离" "isolation-debugger"

    # 在文件开头添加调试标志
    local file_type=$(echo "$blocks_info" | jq -r '.file_type')

    case "$file_type" in
        "javascript")
            sed -i '1i// 🔍 ISOLATION DEBUG MODE\nconst ISOLATION_DEBUG = true;' "$file"
            ;;
        "python")
            sed -i '1i# 🔍 ISOLATION DEBUG MODE\nISOLATION_DEBUG = True' "$file"
            ;;
    esac

    log_info "添加了条件编译调试标志" "isolation-debugger"
}

# ❌ 通过移除隔离（高风险）
isolate_by_removing() {
    local file="$1"
    local blocks_info="$2"
    local max_blocks="$3"

    log_warn "使用高风险的移除隔离模式 - 仅用于测试环境" "isolation-debugger"

    # 创建空的占位文件
    echo "# 🔍 ISOLATION DEBUG: Original content removed for testing" > "$file"
    echo "# Use 'restore' command to recover original file" >> "$file"
}

# 🔄 恢复隔离的文件
restore_isolated_file() {
    local target_file="$1"
    local backup_timestamp="${2:-latest}"

    log_info "恢复隔离文件: $target_file" "isolation-debugger"

    local backup_pattern="$BACKUP_DIR/$(basename "$target_file").*.backup"

    if [ "$backup_timestamp" = "latest" ]; then
        # 找到最新的备份
        local latest_backup=$(ls -t $backup_pattern 2>/dev/null | head -1)
        if [ -z "$latest_backup" ]; then
            log_error "未找到备份文件: $backup_pattern" "isolation-debugger"
            return 1
        fi
        backup_file="$latest_backup"
    else
        backup_file="$BACKUP_DIR/$(basename "$target_file").${backup_timestamp}.backup"
    fi

    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$target_file"
        log_info "成功恢复文件: $target_file (从 $backup_file)" "isolation-debugger"
    else
        log_error "备份文件不存在: $backup_file" "isolation-debugger"
        return 1
    fi
}

# 📊 生成隔离调试报告
generate_isolation_report() {
    local target_file="$1"
    local backup_file="$2"
    local isolation_type="$3"

    local report_file="$DEBUG_DIR/isolation_report_$(date '+%Y%m%d_%H%M%S').json"

    local report_data=$(cat << EOF
{
  "isolation_report": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "target_file": "$target_file",
    "backup_file": "$backup_file",
    "isolation_type": "$isolation_type",
    "file_info": {
      "size_before": $(stat -f%z "$backup_file" 2>/dev/null || echo "0"),
      "size_after": $(stat -f%z "$target_file" 2>/dev/null || echo "0")
    },
    "recommendations": [
      "运行测试验证隔离效果",
      "观察错误数量的变化",
      "根据测试结果决定下一步调试策略"
    ]
  }
}
EOF
)

    echo "$report_data" | jq . > "$report_file" 2>/dev/null || echo "$report_data" > "$report_file"

    log_info "隔离报告已生成: $report_file" "isolation-debugger"
}

# 🧪 运行测试验证隔离效果
run_isolation_test() {
    local test_command="${1:-$DEFAULT_TEST_CMD}"

    log_info "运行隔离测试: $test_command" "isolation-debugger"

    local test_start=$(date +%s)
    local test_output=""

    if eval "$test_command" 2>&1; then
        local test_result="passed"
        local exit_code=0
    else
        local test_result="failed"
        local exit_code=$?
    fi

    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))

    # 解析测试结果
    local error_count=$(echo "$test_output" | grep -c "error\|Error\|ERROR" || echo "0")
    local warning_count=$(echo "$test_output" | grep -c "warning\|Warning\|WARN" || echo "0")

    local test_report=$(cat << EOF
{
  "test_report": {
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "command": "$test_command",
    "result": "$test_result",
    "exit_code": $exit_code,
    "duration_seconds": $test_duration,
    "error_count": $error_count,
    "warning_count": $warning_count
  }
}
EOF
)

    echo "$test_report"
}

# 🎯 隔离测试自动提交
check_isolation_auto_commit() {
    local target_file="$1"
    local isolation_type="$2"
    local test_result="$3"

    # 解析测试结果
    local test_result_status=$(echo "$test_result" | jq -r '.test_report.result' 2>/dev/null || echo "unknown")
    local error_count=$(echo "$test_result" | jq -r '.test_report.error_count' 2>/dev/null || echo "0")

    # 简单的隔离效果判断
    local should_commit=false
    local commit_reason=""

    # 如果隔离后测试通过或错误明显减少，认为是有效隔离
    if [ "$test_result_status" = "passed" ]; then
        should_commit=true
        commit_reason="隔离测试成功"
    elif [ "$isolation_type" = "comment" ] && [ "$error_count" -le 5 ]; then
        should_commit=true
        commit_reason="注释隔离有效"
    fi

    if [ "$should_commit" = true ]; then
        log_info "检测到有效的隔离测试 ($commit_reason)，准备自动提交..." "isolation-debugger"

        # 检查git状态
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            log_warn "当前目录不是git仓库，跳过自动提交" "isolation-debugger"
            return 0
        fi

        # 检查是否有未暂存的更改
        local unstaged_changes=$(git diff --name-only | wc -l)

        if [ "$unstaged_changes" -gt 0 ]; then
            log_info "暂存隔离测试的更改..." "isolation-debugger"
            git add .
        fi

        # 生成详细的commit message
        local commit_msg=$(generate_isolation_commit_message "$target_file" "$isolation_type" "$test_result" "$commit_reason")

        # 执行提交
        if git commit -m "$commit_msg" 2>/dev/null; then
            log_info "✅ 隔离自动提交成功！" "isolation-debugger"
            log_info "Commit: $(echo "$commit_msg" | head -1)" "isolation-debugger"

            # 显示提交详情
            local commit_hash=$(git rev-parse HEAD)
            log_info "Commit Hash: ${commit_hash:0:8}" "isolation-debugger"
        else
            log_warn "隔离自动提交失败，可能没有更改或已存在相同提交" "isolation-debugger"
        fi
    else
        log_debug "隔离测试结果不显著，跳过自动提交" "isolation-debugger"
    fi
}

# 📝 生成隔离测试的commit message
generate_isolation_commit_message() {
    local target_file="$1"
    local isolation_type="$2"
    local test_result="$3"
    local commit_reason="$4"

    # 解析测试结果
    local test_result_status=$(echo "$test_result" | jq -r '.test_report.result' 2>/dev/null || echo "unknown")
    local error_count=$(echo "$test_result" | jq -r '.test_report.error_count' 2>/dev/null || echo "0")
    local test_duration=$(echo "$test_result" | jq -r '.test_report.duration_seconds' 2>/dev/null || echo "0")

    # 生成基础message
    local base_msg="debug: 隔离测试 '$target_file'"

    # 添加隔离信息
    local isolation_msg=""
    case "$isolation_type" in
        "comment")
            isolation_msg+="\n\n隔离方法: 注释代码块"
            ;;
        "conditional")
            isolation_msg+="\n\n隔离方法: 条件编译"
            ;;
        "remove")
            isolation_msg+="\n\n隔离方法: 移除代码块"
            ;;
        *)
            isolation_msg+="\n\n隔离方法: $isolation_type"
            ;;
    esac

    # 添加测试结果
    local test_msg=""
    test_msg+="\n\n测试结果:"
    test_msg+="\n- 测试状态: $test_result_status"
    test_msg+="\n- 错误数量: $error_count"
    test_msg+="\n- 测试耗时: ${test_duration}秒"

    # 添加自动提交标记
    local auto_msg="\n\n🔍 自动提交 - $commit_reason"

    # 组合完整message
    echo "$base_msg$isolation_msg$test_msg$auto_msg"
}

# 🧹 清理过期备份
cleanup_old_backups() {
    local retention_days="${1:-$BACKUP_RETENTION_DAYS}"

    log_info "清理${retention_days}天前的备份文件" "isolation-debugger"

    find "$BACKUP_DIR" -name "*.backup" -type f -mtime +$retention_days -delete 2>/dev/null || true

    # 限制备份文件数量
    local backup_count=$(ls "$BACKUP_DIR"/*.backup 2>/dev/null | wc -l)
    if [ "$backup_count" -gt "$MAX_BACKUP_FILES" ]; then
        log_info "备份文件过多($backup_count)，删除最旧的文件" "isolation-debugger"
        ls -t "$BACKUP_DIR"/*.backup 2>/dev/null | tail -n +$((MAX_BACKUP_FILES + 1)) | xargs rm -f 2>/dev/null || true
    fi
}

# 📋 显示帮助信息
show_help() {
    cat << EOF
🔍 注释大法：智能隔离调试器 v1.0.0

使用方法:
  $0 isolate <target_file> [--depth <level>] [--test-cmd <command>] [--type <isolation_type>]
  $0 restore <target_file> [--backup <timestamp>]
  $0 analyze <target_file> [--report-only]
  $0 test [--cmd <command>]
  $0 cleanup [--retention <days>]
  $0 help

参数说明:
  isolate       隔离调试指定的文件
    --depth     隔离深度 (默认: $DEFAULT_ISOLATION_DEPTH)
    --test-cmd  测试命令 (默认: $DEFAULT_TEST_CMD)
    --type      隔离类型: comment, conditional, remove (默认: comment)

  restore       恢复隔离的文件
    --backup    指定备份时间戳 (默认: latest)

  analyze       分析文件结构，不进行实际隔离
    --report-only 只生成分析报告

  test          运行测试验证当前状态
    --cmd       自定义测试命令

  cleanup       清理过期备份文件
    --retention 保留天数 (默认: $BACKUP_RETENTION_DAYS)

示例:
  $0 isolate src/utils.js
  $0 isolate config.json --type conditional
  $0 restore src/utils.js --backup 20260116_143000
  $0 analyze problematic_file.py --report-only
  $0 test --cmd "jest --watch"
  $0 cleanup --retention 3

安全特性:
- 自动创建时间戳备份
- 支持一键恢复原始文件
- 渐进式隔离，避免大面积修改
- 详细的操作日志记录

EOF
}

# 🎯 主函数
main() {
    local command="$1"
    shift

    case "$command" in
        "isolate")
            local target_file=""
            local isolation_depth="$DEFAULT_ISOLATION_DEPTH"
            local test_cmd="$DEFAULT_TEST_CMD"
            local isolation_type="comment"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --depth)
                        isolation_depth="$2"
                        shift 2
                        ;;
                    --test-cmd)
                        test_cmd="$2"
                        shift 2
                        ;;
                    --type)
                        isolation_type="$2"
                        shift 2
                        ;;
                    *)
                        if [ -z "$target_file" ]; then
                            target_file="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$target_file" ]; then
                log_error "请指定要隔离的目标文件" "isolation-debugger"
                exit 1
            fi

            isolate_code_blocks "$target_file" "$isolation_type" "$isolation_depth"

            # 运行测试验证
            if [ -n "$test_cmd" ]; then
                log_info "运行测试验证隔离效果..." "isolation-debugger"
                local test_result=$(run_isolation_test "$test_cmd")

                # 🎯 检查是否应该自动提交隔离进展
                check_isolation_auto_commit "$target_file" "$isolation_type" "$test_result"
            fi
            ;;

        "restore")
            local target_file=""
            local backup_timestamp="latest"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --backup)
                        backup_timestamp="$2"
                        shift 2
                        ;;
                    *)
                        if [ -z "$target_file" ]; then
                            target_file="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$target_file" ]; then
                log_error "请指定要恢复的目标文件" "isolation-debugger"
                exit 1
            fi

            restore_isolated_file "$target_file" "$backup_timestamp"
            ;;

        "analyze")
            local target_file=""
            local report_only=false

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --report-only)
                        report_only=true
                        shift
                        ;;
                    *)
                        if [ -z "$target_file" ]; then
                            target_file="$1"
                        fi
                        shift
                        ;;
                esac
            done

            if [ -z "$target_file" ]; then
                log_error "请指定要分析的目标文件" "isolation-debugger"
                exit 1
            fi

            local blocks_info=$(analyze_file_structure "$target_file")
            echo "文件结构分析结果:"
            echo "$blocks_info" | jq . 2>/dev/null || echo "$blocks_info"
            ;;

        "test")
            local test_cmd="$DEFAULT_TEST_CMD"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --cmd)
                        test_cmd="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            run_isolation_test "$test_cmd"
            ;;

        "cleanup")
            local retention_days="$BACKUP_RETENTION_DAYS"

            while [[ $# -gt 0 ]]; do
                case $1 in
                    --retention)
                        retention_days="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            cleanup_old_backups "$retention_days"
            ;;

        "help"|"-h"|"--help"|"")
            show_help
            ;;

        *)
            log_error "未知命令: $command" "isolation-debugger"
            echo "运行 '$0 help' 查看可用命令"
            exit 1
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi