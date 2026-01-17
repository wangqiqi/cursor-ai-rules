#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🔍 Cursor AI Rules - 配置验证器
# 验证配置文件的语法和语义正确性

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$PROJECT_ROOT/.cursor/config"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 验证统计
VALIDATION_CHECKS_TOTAL=0
VALIDATION_CHECKS_PASSED=0
VALIDATION_ISSUES_FOUND=0
VALIDATION_WARNINGS_FOUND=0

# 记录验证结果
declare -A VALIDATION_RESULTS

# 📋 JSON语法验证
validate_json_syntax() {
    local file="$1"
    local name="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $name JSON语法..."

    if [ ! -f "$file" ]; then
        echo " ${RED}失败${NC} - 文件不存在"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${name}_syntax"]="file_not_found"
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        if jq empty "$file" 2>/dev/null; then
            echo " ${GREEN}通过${NC}"
            VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
            VALIDATION_RESULTS["${name}_syntax"]="valid"
            return 0
        else
            echo " ${RED}失败${NC} - JSON格式错误"
            VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
            VALIDATION_RESULTS["${name}_syntax"]="invalid_json"
            return 1
        fi
    else
        echo " ${YELLOW}跳过${NC} - jq未安装"
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${name}_syntax"]="jq_not_available"
        return 0
    fi
}

# 🏗️ 必需字段验证
validate_required_fields() {
    local file="$1"
    local config_type="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $config_type 必需字段..."

    if ! command -v jq >/dev/null 2>&1; then
        echo " ${YELLOW}跳过${NC} - jq未安装"
        return 0
    fi

    local missing_fields=()

    case "$config_type" in
        "global")
            local required=("version" "system" "features" "performance" "security")
            for field in "${required[@]}"; do
                if ! jq -e ".$field" "$file" >/dev/null 2>&1; then
                    missing_fields+=("$field")
                fi
            done
            ;;

        "project")
            local required=("project.name" "project.tech_stack")
            for field in "${required[@]}"; do
                if ! jq -e ".$field" "$file" >/dev/null 2>&1; then
                    missing_fields+=("$field")
                fi
            done
            ;;

        "system-defaults")
            local required=("version" "system" "features")
            for field in "${required[@]}"; do
                if ! jq -e ".$field" "$file" >/dev/null 2>&1; then
                    missing_fields+=("$field")
                fi
            done
            ;;
    esac

    if [ ${#missing_fields[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${config_type}_fields"]="valid"
        return 0
    else
        echo " ${RED}失败${NC} - 缺少字段: ${missing_fields[*]}"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${config_type}_fields"]="missing_fields:${missing_fields[*]}"
        return 1
    fi
}

# 🔗 字段类型验证
validate_field_types() {
    local file="$1"
    local config_type="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $config_type 字段类型..."

    if ! command -v jq >/dev/null 2>&1; then
        echo " ${YELLOW}跳过${NC} - jq未安装"
        return 0
    fi

    local type_issues=()

    case "$config_type" in
        "global")
            # 验证布尔值字段
            local bool_fields=(".system.backup_enabled" ".features.automation.enabled")
            for field in "${bool_fields[@]}"; do
                local value=$(jq -r "$field" "$file" 2>/dev/null)
                if [[ ! "$value" =~ ^(true|false)$ ]]; then
                    type_issues+=("$field: 期望布尔值，实际: $value")
                fi
            done

            # 验证数值字段
            local number_fields=(".system.max_memory_mb" ".performance.cache_size_mb")
            for field in "${number_fields[@]}"; do
                local value=$(jq -r "$field" "$file" 2>/dev/null)
                if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                    type_issues+=("$field: 期望数值，实际: $value")
                fi
            done
            ;;
    esac

    if [ ${#type_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${config_type}_types"]="valid"
        return 0
    else
        echo " ${RED}失败${NC}"
        for issue in "${type_issues[@]}"; do
            echo "      - $issue"
        done
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${config_type}_types"]="type_issues:${#type_issues[@]}"
        return 1
    fi
}

# ⚖️ 配置一致性验证
validate_config_consistency() {
    local file="$1"
    local config_type="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $config_type 配置一致性..."

    if ! command -v jq >/dev/null 2>&1; then
        echo " ${YELLOW}跳过${NC} - jq未安装"
        return 0
    fi

    local consistency_issues=()

    case "$config_type" in
        "global")
            # 检查自动化相关配置的一致性
            local automation_enabled=$(jq -r '.features.automation.enabled' "$file" 2>/dev/null)
            local hooks_enabled=$(jq -r '.features.automation.hooks' "$file" 2>/dev/null)

            if [ "$automation_enabled" = "true" ] && [ "$hooks_enabled" = "false" ]; then
                consistency_issues+=("自动化启用但钩子被禁用")
            fi

            # 检查性能配置的一致性
            local cache_enabled=$(jq -r '.performance.cache_enabled' "$file" 2>/dev/null)
            local cache_size=$(jq -r '.performance.cache_size_mb' "$file" 2>/dev/null)

            if [ "$cache_enabled" = "true" ] && [ "$cache_size" -lt 10 ]; then
                consistency_issues+=("缓存启用但缓存大小过小: ${cache_size}MB")
            fi
            ;;
    esac

    if [ ${#consistency_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${config_type}_consistency"]="valid"
        return 0
    else
        echo " ${YELLOW}警告${NC}"
        for issue in "${consistency_issues[@]}"; do
            echo "      - $issue"
        done
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${config_type}_consistency"]="consistency_warnings:${#consistency_issues[@]}"
        return 0
    fi
}

# 🔍 安全配置验证
validate_security_config() {
    local file="$1"
    local config_type="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $config_type 安全配置..."

    if ! command -v jq >/dev/null 2>&1; then
        echo " ${YELLOW}跳过${NC} - jq未安装"
        return 0
    fi

    local security_issues=()

    # 检查安全配置
    local audit_logging=$(jq -r '.security.audit_logging' "$file" 2>/dev/null)
    local telemetry_enabled=$(jq -r '.telemetry.enabled' "$file" 2>/dev/null)

    if [ "$audit_logging" = "false" ] && [ "$config_type" = "global" ]; then
        security_issues+=("全局配置未启用审计日志")
    fi

    if [ "$telemetry_enabled" = "true" ]; then
        local anonymized=$(jq -r '.telemetry.anonymized' "$file" 2>/dev/null)
        if [ "$anonymized" = "false" ]; then
            security_issues+=("遥测数据未匿名化")
        fi
    fi

    if [ ${#security_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${config_type}_security"]="valid"
        return 0
    else
        echo " ${YELLOW}警告${NC}"
        for issue in "${security_issues[@]}"; do
            echo "      - $issue"
        done
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${config_type}_security"]="security_warnings:${#security_issues[@]}"
        return 0
    fi
}

# 📊 生成验证报告
generate_validation_report() {
    local report_file="$CONFIG_DIR/validation-report.json"

    echo "📊 生成验证报告..."

    local report_data=$(cat << EOF
{
  "generated_at": "$(date '+%Y-%m-%d %H:%M:%S')",
  "validation_results": $(declare -p VALIDATION_RESULTS | sed 's/declare -A VALIDATION_RESULTS=//' | jq -R -s 'fromjson? // {}'),
  "statistics": {
    "checks_total": $VALIDATION_CHECKS_TOTAL,
    "checks_passed": $VALIDATION_CHECKS_PASSED,
    "issues_found": $VALIDATION_ISSUES_FOUND,
    "warnings_found": $VALIDATION_WARNINGS_FOUND
  },
  "recommendations": $(generate_validation_recommendations)
}
EOF
)

    echo "$report_data" | jq . > "$report_file" 2>/dev/null || echo "$report_data" > "$report_file"

    echo "   ✅ 验证报告已生成: $report_file"
}

# 💡 生成验证建议
generate_validation_recommendations() {
    local recommendations="[]"

    if [ $VALIDATION_ISSUES_FOUND -gt 0 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["修复发现的配置问题以确保系统稳定运行"]')
        recommendations=$(echo "$recommendations" | jq '. += ["检查Frontmatter格式是否符合规范"]')
        recommendations=$(echo "$recommendations" | jq '. += ["验证组件依赖关系是否完整"]')
    fi

    if [ $VALIDATION_WARNINGS_FOUND -gt 0 ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["考虑解决配置警告以优化系统性能"]')
        recommendations=$(echo "$recommendations" | jq '. += ["检查命名规范是否符合指南"]')
        recommendations=$(echo "$recommendations" | jq '. += ["评估组件数量是否足够"]')
    fi

    if ! command -v jq >/dev/null 2>&1; then
        recommendations=$(echo "$recommendations" | jq '. += ["安装jq工具以获得更完整的配置验证功能"]')
    fi

    # 组件特定建议
    if [[ "${VALIDATION_RESULTS[rules_dependencies]}" == *"dependency_warnings"* ]]; then
        recommendations=$(echo "$recommendations" | jq '. += ["完善Rules组件间的依赖关系"]')
    fi

    if [[ "${VALIDATION_RESULTS[skills_dependencies]}" == *"dependency_warnings"* ]]; then
        recommendations=$(echo "$recommendations" | jq '. += ["确保Skills组件有对应的脚本实现"]')
    fi

    if [[ "${VALIDATION_RESULTS[hooks_dependencies]}" == *"dependency_warnings"* ]]; then
        recommendations=$(echo "$recommendations" | jq '. += ["为Hooks脚本添加标准化的标题注释"]')
    fi

    echo "$recommendations"
}

# 🎯 验证单个配置文件
validate_single_config() {
    local config_type="$1"
    local config_file=""

    case "$config_type" in
        "global")
            config_file="$CONFIG_DIR/global.json"
            ;;
        "project")
            config_file="$CONFIG_DIR/project.json"
            ;;
        "system-defaults")
            config_file="$CONFIG_DIR/system-defaults.json"
            ;;
        *)
            echo "❌ 未知的配置类型: $config_type"
            return 1
            ;;
    esac

    echo "🔍 验证 $config_type 配置文件..."
    echo "   文件: $config_file"

    # 执行各项验证
    validate_json_syntax "$config_file" "$config_type"
    validate_required_fields "$config_file" "$config_type"
    validate_field_types "$config_file" "$config_type"
    validate_config_consistency "$config_file" "$config_type"
    validate_security_config "$config_file" "$config_type"

    echo ""
}

# 🎯 验证所有配置文件
validate_all_configs() {
    echo "🔍 验证所有配置文件..."
    echo ""

    validate_single_config "system-defaults"
    validate_single_config "global"
    validate_single_config "project"

    # 生成综合报告
    generate_validation_report

    # 显示总结
    echo ""
    echo "📊 验证总结:"
    echo "   🔍 总检查数: $VALIDATION_CHECKS_TOTAL"
    echo "   ✅ 通过检查: $VALIDATION_CHECKS_PASSED"
    echo "   ❌ 发现问题: $VALIDATION_ISSUES_FOUND"
    echo "   ⚠️  发现警告: $VALIDATION_WARNINGS_FOUND"

    if [ $VALIDATION_ISSUES_FOUND -eq 0 ]; then
        echo ""
        echo "🎉 所有配置文件验证通过！"
    else
        echo ""
        echo "⚠️  发现配置问题，请查看验证报告进行修复。"
    fi
}

# 📋 Frontmatter验证 (Rules & Skills)
validate_frontmatter() {
    local file="$1"
    local component_type="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $component_type Frontmatter..."

    if [ ! -f "$file" ]; then
        echo " ${RED}失败${NC} - 文件不存在"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${component_type}_frontmatter"]="file_not_found"
        return 1
    fi

    # 检查Frontmatter格式
    local has_frontmatter=false
    local in_frontmatter=false
    local frontmatter_content=""
    local line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        if [[ "$line" == "---" ]]; then
            if [[ $line_num -eq 1 ]]; then
                in_frontmatter=true
                has_frontmatter=true
            elif $in_frontmatter; then
                in_frontmatter=false
                break
            fi
        elif $in_frontmatter; then
            frontmatter_content+="$line"$'\n'
        fi
    done < "$file"

    if ! $has_frontmatter; then
        echo " ${RED}失败${NC} - 缺少Frontmatter"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${component_type}_frontmatter"]="missing_frontmatter"
        return 1
    fi

    # 验证必需字段
    local missing_fields=()

    case "$component_type" in
        "rule")
            # 检查必需的rule字段
            [[ ! "$frontmatter_content" =~ command: ]] && missing_fields+=("command")
            [[ ! "$frontmatter_content" =~ description: ]] && missing_fields+=("description")
            ;;
        "skill")
            # 检查必需的skill字段
            [[ ! "$frontmatter_content" =~ command:.*skill: ]] && missing_fields+=("command (skill:)")
            [[ ! "$frontmatter_content" =~ description: ]] && missing_fields+=("description")
            ;;
    esac

    if [ ${#missing_fields[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${component_type}_frontmatter"]="valid"
        return 0
    else
        echo " ${RED}失败${NC} - 缺少字段: ${missing_fields[*]}"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${component_type}_frontmatter"]="missing_fields:${missing_fields[*]}"
        return 1
    fi
}

# 🔗 组件依赖验证
validate_component_dependencies() {
    local component_type="$1"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $component_type 组件依赖..."

    local dependency_issues=()

    case "$component_type" in
        "rules")
            # 检查rules间的依赖关系
            if [ -f "$PROJECT_ROOT/.cursor/rules/workflow/eslint.md" ]; then
                # 检查ESLint规则是否引用了质量配置
                if ! grep -q "config/config/config/" "$PROJECT_ROOT/.cursor/rules/workflow/eslint.md" 2>/dev/null; then
                    dependency_issues+=("ESLint规则未引用质量配置")
                fi
            fi
            ;;
        "skills")
            # 检查skills是否引用了对应的脚本
            local skill_files=$(find "$PROJECT_ROOT/.cursor/features/skills" -name "*.md" 2>/dev/null)
            for skill_file in $skill_files; do
                local skill_name=$(basename "$skill_file" .md)
                local script_file="$PROJECT_ROOT/.cursor/core/${skill_name}.sh"

                if [[ "$skill_name" == "debug-assistant" ]]; then
                    # debug-assistant是特殊情况，在debug目录
                    script_file="$PROJECT_ROOT/.cursor/core/isolation-debugger.sh"
                fi

                if [ ! -f "$script_file" ]; then
                    dependency_issues+=("$skill_name skill缺少对应的脚本实现")
                fi
            done
            ;;
        "hooks")
            # 检查hooks是否引用了正确的脚本
            local hook_files=$(find "$PROJECT_ROOT/.cursor/features/hooks" -name "*.sh" 2>/dev/null)
            for hook_file in $hook_files; do
                local hook_name=$(basename "$hook_file" .sh)
                if ! grep -q "# $hook_name" "$hook_file" 2>/dev/null; then
                    dependency_issues+=("$hook_name hook缺少标题注释")
                fi
            done
            ;;
    esac

    if [ ${#dependency_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${component_type}_dependencies"]="valid"
        return 0
    else
        echo " ${YELLOW}警告${NC}"
        for issue in "${dependency_issues[@]}"; do
            echo "      - $issue"
        done
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${component_type}_dependencies"]="dependency_warnings:${#dependency_issues[@]}"
        return 0
    fi
}

# 🏷️ 命名规范验证
validate_naming_conventions() {
    local component_type="$1"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $component_type 命名规范..."

    local naming_issues=()

    case "$component_type" in
        "rules")
            local rule_files=$(find "$PROJECT_ROOT/.cursor/rules" -name "*.md" 2>/dev/null)
            for rule_file in $rule_files; do
                local filename=$(basename "$rule_file" .md)
                # 检查是否使用kebab-case
                if [[ ! "$filename" =~ ^[a-z]+(-[a-z]+)*$ ]]; then
                    naming_issues+=("$filename 应使用kebab-case命名")
                fi
            done
            ;;
        "skills")
            local skill_files=$(find "$PROJECT_ROOT/.cursor/features/skills" -name "*.md" 2>/dev/null)
            for skill_file in $skill_files; do
                local filename=$(basename "$skill_file" .md)
                # 检查是否使用kebab-case
                if [[ ! "$filename" =~ ^[a-z]+(-[a-z]+)*$ ]]; then
                    naming_issues+=("$filename 应使用kebab-case命名")
                fi
            done
            ;;
        "hooks")
            local hook_files=$(find "$PROJECT_ROOT/.cursor/features/hooks" -name "*.sh" 2>/dev/null)
            for hook_file in $hook_files; do
                local filename=$(basename "$hook_file" .sh)
                # 检查是否使用{event}-{action}格式
                if [[ ! "$filename" =~ ^[a-z]+-[a-z-]+$ ]]; then
                    naming_issues+=("$filename 应使用{event}-{action}格式")
                fi
            done
            ;;
    esac

    if [ ${#naming_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${component_type}_naming"]="valid"
        return 0
    else
        echo " ${YELLOW}警告${NC}"
        for issue in "${naming_issues[@]}"; do
            echo "      - $issue"
        done
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${component_type}_naming"]="naming_warnings:${#naming_issues[@]}"
        return 0
    fi
}

# 📊 组件统计验证
validate_component_statistics() {
    local component_type="$1"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证 $component_type 组件统计..."

    local stats_issues=()

    case "$component_type" in
        "rules")
            local rule_count=$(find "$PROJECT_ROOT/.cursor/rules" -name "*.md" 2>/dev/null | wc -l)
            if [ "$rule_count" -lt 20 ]; then
                stats_issues+=("规则数量过少: $rule_count (建议 >= 20)")
            fi
            ;;
        "skills")
            local skill_count=$(find "$PROJECT_ROOT/.cursor/features/skills" -name "*.md" 2>/dev/null | wc -l)
            if [ "$skill_count" -lt 20 ]; then
                stats_issues+=("技能数量过少: $skill_count (建议 >= 20)")
            fi
            ;;
        "hooks")
            local hook_count=$(find "$PROJECT_ROOT/.cursor/features/hooks" -name "*.sh" 2>/dev/null | wc -l)
            if [ "$hook_count" -lt 15 ]; then
                stats_issues+=("钩子数量过少: $hook_count (建议 >= 15)")
            fi
            ;;
        "capability_mappings")
            local mapping_count=$(grep -c '"[^"]*": {' "$PROJECT_ROOT/.cursor/commands/capability-map.json" 2>/dev/null || echo "0")
            if [ "$mapping_count" -lt 100 ]; then
                stats_issues+=("能力映射数量过少: $mapping_count (建议 >= 100)")
            fi
            ;;
    esac

    if [ ${#stats_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["${component_type}_stats"]="valid"
        return 0
    else
        echo " ${YELLOW}警告${NC}"
        for issue in "${stats_issues[@]}"; do
            echo "      - $issue"
        done
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${component_type}_stats"]="stats_warnings:${#stats_issues[@]}"
        return 0
    fi
}

# 🎯 验证Rules组件
validate_rules() {
    echo "📋 验证 Rules 组件..."
    echo "   位置: .cursor/rules/"

    validate_component_statistics "rules"
    validate_component_dependencies "rules"
    validate_naming_conventions "rules"

    # 验证单个rule文件
    local rule_files=$(find "$PROJECT_ROOT/.cursor/rules" -name "*.md" 2>/dev/null | head -5)
    for rule_file in $rule_files; do
        local rule_name=$(basename "$rule_file" .md)
        validate_frontmatter "$rule_file" "rule_$rule_name"
    done

    echo ""
}

# 🎯 验证Skills组件
validate_skills() {
    echo "🎯 验证 Skills 组件..."
    echo "   位置: .cursor/features/skills/"

    validate_component_statistics "skills"
    validate_component_dependencies "skills"
    validate_naming_conventions "skills"

    # 验证单个skill文件
    local skill_files=$(find "$PROJECT_ROOT/.cursor/features/skills" -name "*.md" 2>/dev/null | head -5)
    for skill_file in $skill_files; do
        local skill_name=$(basename "$skill_file" .md)
        validate_frontmatter "$skill_file" "skill_$skill_name"
    done

    echo ""
}

# 🪝 验证Hooks组件
validate_hooks() {
    echo "🪝 验证 Hooks 组件..."
    echo "   位置: .cursor/features/hooks/"

    validate_component_statistics "hooks"
    validate_component_dependencies "hooks"
    validate_naming_conventions "hooks"

    echo ""
}

# 🎯 验证Capability Mappings
validate_capability_mappings() {
    echo "🎯 验证 Capability Mappings..."
    echo "   位置: .cursor/commands/capability-map.json"

    validate_component_statistics "capability_mappings"
    validate_json_syntax "$PROJECT_ROOT/.cursor/commands/capability-map.json" "capability_mappings"

    echo ""
}

# 🎯 主函数
main() {
    local command="${1:-all}"

    case "$command" in
        "all")
            validate_all_configs
            validate_rules
            validate_skills
            validate_hooks
            validate_capability_mappings
            ;;
        "configs")
            validate_all_configs
            ;;
        "rules")
            validate_rules
            ;;
        "skills")
            validate_skills
            ;;
        "hooks")
            validate_hooks
            ;;
        "mappings")
            validate_capability_mappings
            ;;
        "global")
            validate_single_config "global"
            ;;
        "project")
            validate_single_config "project"
            ;;
        "system")
            validate_single_config "system-defaults"
            ;;
        "help"|*)
            echo "🔍 Cursor AI Rules 配置验证器"
            echo ""
            echo "用法: $0 <command>"
            echo ""
            echo "命令:"
            echo "  all        验证所有组件和配置"
            echo "  configs    验证所有配置文件"
            echo "  rules      验证Rules组件"
            echo "  skills     验证Skills组件"
            echo "  hooks      验证Hooks组件"
            echo "  mappings   验证Capability Mappings"
            echo "  global     验证全局配置文件"
            echo "  project    验证项目配置文件"
            echo "  system     验证系统默认配置文件"
            echo "  help       显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 all"
            echo "  $0 rules"
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi