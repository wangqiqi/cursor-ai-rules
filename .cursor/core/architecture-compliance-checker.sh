#!/bin/bash
# 🏗️ 双目录架构合规性检查器
# 验证代码是否正确遵循双目录架构设计原则

set -euo pipefail

# 导入通用函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/common.sh"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 脚本版本
SCRIPT_VERSION="1.0.0"

# 检查结果统计
total_files=0
compliant_files=0
violations_found=0

# 违规类型统计
cursor_write_violations=0
mixed_path_violations=0
missing_growth_dir_violations=0

log_violation() {
    local file="$1"
    local line="$2"
    local violation_type="$3"
    local description="$4"

    echo -e "${RED}❌ 违规发现${NC}: $file:$line"
    echo -e "   ${YELLOW}类型${NC}: $violation_type"
    echo -e "   ${YELLOW}描述${NC}: $description"
    echo ""

    ((violations_found++))
}

log_compliant() {
    local file="$1"
    echo -e "${GREEN}✅ 合规${NC}: $file"
    ((compliant_files++))
}

# 检查脚本是否在 .cursor/ 目录中写入数据
check_cursor_write_violations() {
    local file="$1"

    # 查找向 .cursor/ 目录写入数据的操作
    if grep -q ">\s*\.cursor/\|echo.*>.*\.cursor/\|cat.*>.*\.cursor/\|mkdir.*\.cursor/" "$file" 2>/dev/null; then
        log_violation "$file" "N/A" "CURSOR_WRITE" "向 .cursor/ 目录写入数据违反双目录架构"
        return 1
    fi

    return 0
}

# 检查是否正确使用了 GROWTH_DIR
check_growth_dir_usage() {
    local file="$1"

    # 检查是否定义了 GROWTH_DIR 变量
    if ! grep -q "GROWTH_DIR" "$file"; then
        log_violation "$file" "N/A" "MISSING_GROWTH_DIR" "未定义 GROWTH_DIR 变量，可能未遵循双目录架构"
        ((missing_growth_dir_violations++))
        return 1
    fi

    return 0
}

# 检查是否存在混合路径使用
check_mixed_paths() {
    local file="$1"

    # 检查是否同时使用了 .cursor/ 和 $CURSOR_GROWTH/
    if grep -q "\.cursor/" "$file" && grep -q "\$CURSOR_GROWTH/" "$file"; then
        log_violation "$file" "N/A" "MIXED_PATHS" "同时使用 .cursor/ 和 $CURSOR_GROWTH/ 路径，可能存在配置混乱"
        ((mixed_path_violations++))
        return 1
    fi

    return 0
}

# 检查单个脚本文件
check_script_file() {
    local file="$1"

    echo -e "${BLUE}🔍 检查脚本${NC}: $file"
    ((total_files++))

    # 简化检查：只检查是否向 .cursor/ 写入数据
    if grep -q ">\s*\.cursor/\|echo.*>.*\.cursor/\|cat.*>.*\.cursor/\|mkdir.*\.cursor/" "$file" 2>/dev/null; then
        log_violation "$file" "N/A" "CURSOR_WRITE" "向 .cursor/ 目录写入数据违反双目录架构"
    else
        log_compliant "$file"
    fi

    echo ""
}

# 检查规则文件
check_rule_file() {
    local file="$1"

    echo -e "${BLUE}📋 检查规则${NC}: $file"
    ((total_files++))

    local has_violations=false

    # 规则文件通常不应该生成运行时数据，但要检查是否有硬编码路径
    if grep -n "\.cursor/.*>\|\$CURSOR_GROWTH/.*>" "$file" 2>/dev/null; then
        while IFS=: read -r line content; do
            log_violation "$file" "$line" "RULE_DATA_WRITE" "规则文件中包含数据写入操作，可能不合适"
        done < <(grep -n "\.cursor/.*>\|\$CURSOR_GROWTH/.*>" "$file")
        has_violations=true
    fi

    if [ "$has_violations" = false ]; then
        log_compliant "$file"
    fi

    echo ""
}

# 扫描整个项目
scan_project() {
    echo -e "${BLUE}🏗️ 开始双目录架构合规性扫描...${NC}"
    echo "项目根目录: $PROJECT_ROOT"
    echo "---"

    # 扫描脚本文件
    echo -e "${YELLOW}📜 扫描脚本文件...${NC}"
    find ".cursor" -name "*.sh" -type f | while read -r file; do
        if [[ "$file" != ".cursor/core/architecture-compliance-checker.sh" ]]; then
            check_script_file "$file"
        fi
    done

    # 扫描规则文件
    echo -e "${YELLOW}📋 扫描规则文件...${NC}"
    find ".cursor/rules" -name "*.md" -type f | while read -r file; do
        check_rule_file "$file"
    done
}

# 生成报告
generate_report() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local report_file="$CURSOR_GROWTH/compliance_reports/architecture_check_$timestamp.json"

    mkdir -p "$ANALYTICS_DIR"

    cat > "$report_file" << EOF
{
  "compliance_check": {
    "timestamp": "$timestamp",
    "version": "$SCRIPT_VERSION",
    "project_root": "$PROJECT_ROOT",
    "summary": {
      "total_files_checked": $total_files,
      "compliant_files": $compliant_files,
      "violations_found": $violations_found,
      "compliance_rate": $(awk "BEGIN {printf \"%.1f\", $compliant_files * 100 / ($total_files > 0 ? $total_files : 1)}")
    },
    "violations_by_type": {
      "cursor_write_violations": $cursor_write_violations,
      "mixed_path_violations": $mixed_path_violations,
      "missing_growth_dir_violations": $missing_growth_dir_violations
    },
    "recommendations": [
      $(if [ $violations_found -gt 0 ]; then
        echo '"发现架构违规，请立即修复以确保系统合规性"'
      else
        echo '"所有文件都符合双目录架构要求"'
      fi)
    ]
  }
}
EOF

    echo -e "${GREEN}📄 合规性报告已生成: $report_file${NC}"
}

# 显示摘要
show_summary() {
    echo -e "${BLUE}📊 扫描摘要${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "总检查文件数: ${YELLOW}$total_files${NC}"
    echo -e "合规文件数: ${GREEN}$compliant_files${NC}"
    echo -e "发现违规数: ${RED}$violations_found${NC}"

    if [ $total_files -gt 0 ]; then
        local compliance_rate=$(awk "BEGIN {printf \"%.1f\", $compliant_files * 100 / $total_files}")
        echo -e "合规率: ${YELLOW}$compliance_rate%${NC}"
    fi

    if [ $violations_found -gt 0 ]; then
        echo ""
        echo -e "${RED}🚨 违规类型统计:${NC}"
        echo -e "  • 向 .cursor/ 写入数据: ${YELLOW}$cursor_write_violations${NC} 处"
        echo -e "  • 混合使用路径: ${YELLOW}$mixed_path_violations${NC} 处"
        echo -e "  • 缺少 GROWTH_DIR: ${YELLOW}$missing_growth_dir_violations${NC} 处"
        echo ""
        echo -e "${YELLOW}💡 建议: 请立即修复所有违规问题${NC}"
        return 1
    else
        echo ""
        echo -e "${GREEN}🎉 恭喜！所有文件都符合双目录架构要求${NC}"
        return 0
    fi
}

# 主函数
main() {
    local check_type="${1:-full}"

    echo "🏗️ 双目录架构合规性检查器 v$SCRIPT_VERSION"
    echo "检查时间: $(date)"
    echo "---"

    case "$check_type" in
        "full"|"all")
            scan_project
            ;;
        "scripts")
            echo -e "${YELLOW}📜 仅扫描脚本文件...${NC}"
            find ".cursor" -name "*.sh" -type f | while read -r file; do
                if [[ "$file" != "./cursor/core/architecture-compliance-checker.sh" ]]; then
                    check_script_file "$file"
                fi
            done
            ;;
        "rules")
            echo -e "${YELLOW}📋 仅扫描规则文件...${NC}"
            find ".cursor/rules" -name "*.md" -type f | while read -r file; do
                check_rule_file "$file"
            done
            ;;
        *)
            echo -e "${RED}❌ 无效的检查类型: $check_type${NC}"
            echo -e "${YELLOW}支持的类型: full, scripts, rules${NC}"
            exit 1
            ;;
    esac

    generate_report
    echo ""
    show_summary
}

# 参数处理
if [[ $# -eq 0 ]]; then
    main "full"
else
    main "$@"
fi