#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🌟 Cursor AI Rules - 统一配置管理器
# 管理配置层级、继承、合并和验证

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="${CURSOR_DIR}/config"

source "$SCRIPT_DIR/colors.sh"

# 配置层级定义
CONFIG_HIERARCHY=(
    "system_defaults"    # 系统默认配置 (最低优先级)
    "global"            # 全局配置
    "project"           # 项目配置
    "user"              # 用户配置 (最高优先级)
    "runtime"           # 运行时配置 (动态)
)

# 配置状态跟踪
declare -A CONFIG_STATUS
declare -A CONFIG_CACHE

# 📊 配置验证函数
validate_config() {
    local config_file="$1"
    local config_type="$2"

    echo "🔍 验证$config_type配置文件: $config_file"

    # 检查文件是否存在
    if [ ! -f "$config_file" ]; then
        echo "   ⚠️  $config_type配置文件不存在: $config_file"
        return 1
    fi

    # 检查JSON格式
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$config_file" 2>/dev/null; then
            echo "   ❌ $config_type配置文件JSON格式错误"
            return 1
        fi
    else
        echo "   ⚠️  jq未安装，跳过JSON格式验证"
    fi

    # 验证必需字段
    validate_required_fields "$config_file" "$config_type"

    echo "   ✅ $config_type配置验证通过"
    return 0
}

# 验证必需字段
validate_required_fields() {
    local config_file="$1"
    local config_type="$2"

    case "$config_type" in
        "global")
            # 检查全局配置必需字段
            local required_fields=("version" "system" "features")
            for field in "${required_fields[@]}"; do
                if ! jq -e ".$field" "$config_file" >/dev/null 2>&1; then
                    echo "   ❌ 全局配置缺少必需字段: $field"
                    return 1
                fi
            done
            ;;

        "project")
            # 检查项目配置必需字段
            local required_fields=("project.name" "project.tech_stack")
            for field in "${required_fields[@]}"; do
                if ! jq -e ".$field" "$config_file" >/dev/null 2>&1; then
                    echo "   ❌ 项目配置缺少必需字段: $field"
                    return 1
                fi
            done
            ;;
    esac

    return 0
}

# 📁 获取配置文件路径
get_config_path() {
    local config_level="$1"

    case "$config_level" in
        "system_defaults")
            echo "$CONFIG_DIR/system-defaults.json"
            ;;
        "global")
            echo "$CONFIG_DIR/global.json"
            ;;
        "project")
            echo "$CONFIG_DIR/project.json.template"
            ;;
        "user")
            echo "$HOME/.cursor/config/user.json"
            ;;
        "runtime")
            echo "$CONFIG_DIR/runtime.json"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 🔧 创建系统默认配置
create_system_defaults() {
    local config_file="$CONFIG_DIR/system-defaults.json"

    if [ ! -f "$config_file" ]; then
        echo "📝 创建系统默认配置..."

        cat > "$config_file" << EOF
{
  "version": "1.0.0",
  "metadata": {
    "created_at": "$(date '+%Y-%m-%d %H:%M:%S')",
    "description": "Cursor AI Rules 系统默认配置",
    "author": "System"
  },
  "system": {
    "os": "auto-detect",
    "log_level": "info",
    "backup_enabled": false,
    "auto_update": false,
    "max_memory_mb": 256,
    "max_concurrent_tasks": 2
  },
  "features": {
    "automation": {
      "enabled": false,
      "hooks": false,
      "scripts": false,
      "scheduling": false
    },
    "skills": {
      "enabled": false,
      "auto_install": false,
      "marketplace": false,
      "custom_skills": false
    },
    "rules": {
      "enabled": true,
      "auto_activation": false,
      "custom_rules": false,
      "evolution": false
    },
    "intelligence": {
      "enabled": false,
      "learning": false,
      "adaptation": false,
      "prediction": false
    }
  },
  "performance": {
    "cache_enabled": false,
    "cache_size_mb": 50,
    "compression": false,
    "lazy_loading": true,
    "resource_limits": {
      "cpu_percent": 25,
      "memory_mb": 128,
      "disk_mb": 50
    }
  },
  "security": {
    "input_validation": true,
    "output_filtering": true,
    "audit_logging": false,
    "rate_limiting": {
      "enabled": false,
      "max_requests_per_minute": 30
    },
    "data_encryption": false,
    "secure_defaults": true
  },
  "network": {
    "connectivity_check": false,
    "proxy_support": false,
    "timeout_seconds": 15,
    "retry_attempts": 1,
    "trusted_domains": []
  },
  "ui": {
    "theme": "auto",
    "language": "auto",
    "notifications": false,
    "tooltips": false,
    "shortcuts": false
  },
  "telemetry": {
    "enabled": false,
    "anonymized": true,
    "error_reporting": false,
    "usage_stats": false
  }
}
EOF

        echo "   ✅ 系统默认配置已创建: $config_file"
    fi
}

# 🔄 合并配置层级
merge_config_hierarchy() {
    echo "🔄 合并配置层级..."

    local merged_config="{}"

    # 按优先级从低到高合并配置
    for level in "${CONFIG_HIERARCHY[@]}"; do
        local config_path=$(get_config_path "$level")

        if [ -f "$config_path" ]; then
            echo "   📄 合并${level}配置: $config_path"

            if command -v jq >/dev/null 2>&1; then
                # 使用jq进行深层合并
                merged_config=$(jq -s '.[0] * .[1]' <(echo "$merged_config") "$config_path" 2>/dev/null || echo "$merged_config")
            else
                echo "   ⚠️  jq未安装，使用简单覆盖合并"
                # 简单覆盖合并（如果没有jq）
                merged_config=$(cat "$config_path")
            fi

            CONFIG_STATUS["${level}_merged"]="true"
        else
            echo "   ⚠️  ${level}配置不存在，跳过"
            CONFIG_STATUS["${level}_missing"]="true"
        fi
    done

    # 缓存合并后的配置
    CONFIG_CACHE["merged_config"]="$merged_config"
    CONFIG_STATUS["merge_completed"]="true"

    echo "   ✅ 配置合并完成"
}

# 📝 获取配置值
get_config_value() {
    local key="$1"
    local default_value="${2:-}"

    # 检查缓存
    if [ -n "${CONFIG_CACHE["merged_config"]}" ]; then
        if command -v jq >/dev/null 2>&1; then
            local value=$(echo "${CONFIG_CACHE["merged_config"]}" | jq -r "$key // \"$default_value\"" 2>/dev/null)
            echo "$value"
            return 0
        fi
    fi

    # 如果没有缓存或jq，尝试从各层级查找
    for level in "${CONFIG_HIERARCHY[@]}"; do
        local config_path=$(get_config_path "$level")

        if [ -f "$config_path" ] && command -v jq >/dev/null 2>&1; then
            local value=$(jq -r "$key // empty" "$config_path" 2>/dev/null)
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                echo "$value"
                return 0
            fi
        fi
    done

    # 返回默认值
    echo "$default_value"
}

# ✏️ 设置配置值
set_config_value() {
    local key="$1"
    local value="$2"
    local target_level="${3:-user}"  # 默认保存到用户配置

    local config_path=$(get_config_path "$target_level")

    # 确保目录存在
    mkdir -p "$(dirname "$config_path")"

    # 读取现有配置
    local current_config="{}"
    if [ -f "$config_path" ]; then
        current_config=$(cat "$config_path")
    fi

    # 更新配置
    if command -v jq >/dev/null 2>&1; then
        local updated_config=$(echo "$current_config" | jq "$key = $value" 2>/dev/null || echo "$current_config")
        echo "$updated_config" > "$config_path"
    else
        echo "   ⚠️  jq未安装，无法更新配置"
        return 1
    fi

    # 清除缓存
    unset CONFIG_CACHE["merged_config"]

    echo "   ✅ 配置已更新: $key = $value ($target_level)"
    CONFIG_STATUS["${target_level}_updated"]="true"
}

# 🔍 验证配置一致性
validate_config_consistency() {
    echo "🔍 验证配置一致性..."

    local issues_found=0

    # 检查必需的配置项
    local required_settings=(
        ".system.log_level"
        ".features.rules.enabled"
        ".performance.cache_enabled"
        ".security.input_validation"
    )

    for setting in "${required_settings[@]}"; do
        local value=$(get_config_value "$setting")
        if [ -z "$value" ] || [ "$value" = "null" ]; then
            echo "   ❌ 缺少必需配置: $setting"
            issues_found=$((issues_found + 1))
        fi
    done

    # 检查配置冲突
    local automation_enabled=$(get_config_value ".features.automation.enabled")
    local hooks_enabled=$(get_config_value ".features.automation.hooks")

    if [ "$automation_enabled" = "true" ] && [ "$hooks_enabled" = "false" ]; then
        echo "   ⚠️  配置冲突: 自动化启用但钩子禁用"
        CONFIG_STATUS["config_warning"]="automation_hooks_mismatch"
    fi

    if [ $issues_found -eq 0 ]; then
        echo "   ✅ 配置一致性验证通过"
        CONFIG_STATUS["config_validation"]="passed"
    else
        echo "   ❌ 发现 $issues_found 个配置问题"
        CONFIG_STATUS["config_validation"]="failed"
    fi
}

# 📊 生成配置报告
generate_config_report() {
    local report_file="$CONFIG_DIR/config-report.json"

    echo "📊 生成配置报告..."

    local report_data=$(cat << EOF
{
  "generated_at": "$(date '+%Y-%m-%d %H:%M:%S')",
  "config_status": $(declare -p CONFIG_STATUS | sed 's/declare -A CONFIG_STATUS=//' | jq -R -s 'fromjson? // {}'),
  "config_hierarchy": $(printf '%s\n' "${CONFIG_HIERARCHY[@]}" | jq -R -s -c 'split("\n")[:-1]'),
  "active_config": $(echo "${CONFIG_CACHE["merged_config"]}" | jq '. // {}'),
  "validation_results": {
    "passed": $([ "${CONFIG_STATUS["config_validation"]}" = "passed" ] && echo "true" || echo "false"),
    "issues_found": $(echo "${CONFIG_STATUS["config_validation"]}" | grep -o '[0-9]\+' || echo "0")
  },
  "recommendations": $(generate_config_recommendations)
}
EOF
)

    echo "$report_data" | jq . > "$report_file" 2>/dev/null || echo "$report_data" > "$report_file"

    echo "   ✅ 配置报告已生成: $report_file"
}

# 💡 生成配置建议
generate_config_recommendations() {
    local recommendations="[]"

    # 基于项目特征生成建议
    local tech_stack=$(get_config_value ".project.tech_stack")
    local team_size=$(get_config_value ".project.team_size")

    if [[ "$tech_stack" == *"JavaScript"* ]]; then
        recommendations=$(echo "$recommendations" | jq '. += ["启用ESLint规则以提升代码质量"]')
    fi

    if [ "$team_size" != "personal" ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["启用协作模式以支持团队开发"]')
    fi

    local automation_enabled=$(get_config_value ".features.automation.enabled")
    if [ "$automation_enabled" = "false" ]; then
        recommendations=$(echo "$recommendations" | jq '. += ["考虑启用自动化功能以提升效率"]')
    fi

    echo "$recommendations"
}

# 🎯 主函数
main() {
    local command="${1:-status}"
    # 兼容 hooks 传入的 validate_enhanced
    [[ "$command" == "validate_enhanced" ]] && command="validate"

    case "$command" in
        "init")
            echo "🚀 初始化配置管理系统..."
            create_system_defaults
            validate_config_consistency
            generate_config_report
            echo "✅ 配置系统初始化完成"
            ;;

        "validate")
            echo "🔍 验证配置..."
            merge_config_hierarchy
            validate_config_consistency
            echo "✅ 配置验证完成"
            ;;

        "merge")
            echo "🔄 合并配置..."
            merge_config_hierarchy
            echo "✅ 配置合并完成"
            ;;

        "get")
            local key="$2"
            if [ -z "$key" ]; then
                echo "❌ 请指定配置键"
                exit 1
            fi
            merge_config_hierarchy
            local value=$(get_config_value "$key")
            echo "🔑 $key = $value"
            ;;

        "set")
            local key="$2"
            local value="$3"
            if [ -z "$key" ] || [ -z "$value" ]; then
                echo "❌ 请指定配置键和值"
                echo "用法: $0 set <key> <value>"
                exit 1
            fi
            set_config_value "$key" "$value"
            ;;

        "report")
            echo "📊 生成配置报告..."
            merge_config_hierarchy
            validate_config_consistency
            generate_config_report
            echo "✅ 配置报告生成完成"
            ;;

        "status")
            echo "📋 配置系统状态:"
            echo ""

            # 显示配置层级状态
            echo "🔧 配置层级状态:"
            for level in "${CONFIG_HIERARCHY[@]}"; do
                local config_path=$(get_config_path "$level")
                if [ -f "$config_path" ]; then
                    echo "   ✅ $level: $(basename "$config_path")"
                else
                    echo "   ⚠️  $level: 未配置"
                fi
            done

            echo ""
            echo "📊 配置统计:"
            echo "   合并状态: ${CONFIG_STATUS["merge_completed"]:-未合并}"
            echo "   验证状态: ${CONFIG_STATUS["config_validation"]:-未验证}"

            if [ -f "$CONFIG_DIR/config-report.json" ]; then
                echo "   📄 最新报告: $(stat -c %y "$CONFIG_DIR/config-report.json" 2>/dev/null || echo "未知")"
            fi
            ;;

        "help"|*)
            echo "🎯 Cursor AI Rules 配置管理器"
            echo ""
            echo "用法: $0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  init          初始化配置系统"
            echo "  validate      验证配置一致性"
            echo "  merge         合并配置层级"
            echo "  get <key>     获取配置值"
            echo "  set <key> <value> 设置配置值"
            echo "  report        生成配置报告"
            echo "  status        显示配置状态"
            echo "  help          显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 init"
            echo "  $0 get .system.log_level"
            echo "  $0 set .features.automation.enabled true"
            echo "  $0 report"
            ;;
    esac
}

# =============================================================================
# 集成验证功能 (从config-validator.sh合并)
# =============================================================================

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
            echo " ${RED}失败${NC} - JSON语法错误"
            VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
            VALIDATION_RESULTS["${name}_syntax"]="json_syntax_error"
            return 1
        fi
    else
        echo " ${YELLOW}跳过${NC} - jq未安装"
        VALIDATION_WARNINGS_FOUND=$((VALIDATION_WARNINGS_FOUND + 1))
        VALIDATION_RESULTS["${name}_syntax"]="jq_not_available"
        return 0
    fi
}

# 🔑 必需字段验证
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
        echo " ${RED}失败${NC} - 类型问题: ${type_issues[*]}"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["${config_type}_types"]="type_issues:${type_issues[*]}"
        return 1
    fi
}

# 🔄 跨配置一致性验证
validate_cross_config_consistency() {
    local global_config="$1"
    local project_config="$2"

    VALIDATION_CHECKS_TOTAL=$((VALIDATION_CHECKS_TOTAL + 1))

    echo -n "   验证跨配置一致性..."

    if ! command -v jq >/dev/null 2>&1; then
        echo " ${YELLOW}跳过${NC} - jq未安装"
        return 0
    fi

    local consistency_issues=()

    # 检查项目技术栈是否在全局支持列表中
    if [ -f "$global_config" ] && [ -f "$project_config" ]; then
        local global_tech_stack=$(jq -r '.system.supported_tech_stack[]' "$global_config" 2>/dev/null | tr '\n' ' ')
        local project_tech_stack=$(jq -r '.project.tech_stack[]' "$project_config" 2>/dev/null | tr '\n' ' ')

        for tech in $project_tech_stack; do
            if [[ "$tech" != "null" ]] && [[ ! "$global_tech_stack" =~ $tech ]]; then
                consistency_issues+=("项目使用不支持的技术栈: $tech")
            fi
        done
    fi

    if [ ${#consistency_issues[@]} -eq 0 ]; then
        echo " ${GREEN}通过${NC}"
        VALIDATION_CHECKS_PASSED=$((VALIDATION_CHECKS_PASSED + 1))
        VALIDATION_RESULTS["cross_config_consistency"]="valid"
        return 0
    else
        echo " ${RED}失败${NC} - 一致性问题: ${consistency_issues[*]}"
        VALIDATION_ISSUES_FOUND=$((VALIDATION_ISSUES_FOUND + 1))
        VALIDATION_RESULTS["cross_config_consistency"]="consistency_issues:${consistency_issues[*]}"
        return 1
    fi
}

# 📊 生成验证报告
generate_validation_report() {
    echo ""
    echo "🔍 配置验证报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "📊 验证统计:"
    echo "   总检查数: $VALIDATION_CHECKS_TOTAL"
    echo "   通过数: $VALIDATION_CHECKS_PASSED"
    echo "   问题数: $VALIDATION_ISSUES_FOUND"
    echo "   警告数: $VALIDATION_WARNINGS_FOUND"
    echo ""

    if [ $VALIDATION_ISSUES_FOUND -gt 0 ] || [ $VALIDATION_WARNINGS_FOUND -gt 0 ]; then
        echo "⚠️  发现问题:"
        for key in "${!VALIDATION_RESULTS[@]}"; do
            if [[ "${VALIDATION_RESULTS[$key]}" != "valid" ]] && [[ "${VALIDATION_RESULTS[$key]}" != *"jq_not_available"* ]]; then
                echo "   • $key: ${VALIDATION_RESULTS[$key]}"
            fi
        done
        echo ""
    fi

    echo "💡 验证建议:"
    echo "   • 确保所有JSON配置文件语法正确"
    echo "   • 检查必需字段是否完整"
    echo "   • 验证字段类型是否匹配"
    echo "   • 保持跨配置的一致性"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 增强的配置验证函数
validate_config_enhanced() {
    local config_file="$1"
    local config_type="$2"

    echo "🔍 增强验证$config_type配置文件: $config_file"

    # 基础验证 (原有功能)
    if ! validate_config "$config_file" "$config_type"; then
        return 1
    fi

    # 增强验证 (新增功能)
    echo "🔧 执行增强验证..."

    # JSON语法验证
    if ! validate_json_syntax "$config_file" "$config_type"; then
        return 1
    fi

    # 必需字段验证
    if ! validate_required_fields "$config_file" "$config_type"; then
        return 1
    fi

    # 字段类型验证
    if ! validate_field_types "$config_file" "$config_type"; then
        return 1
    fi

    # 跨配置一致性验证 (如果是项目配置)
    if [ "$config_type" = "project" ]; then
        local global_config=$(get_config_path "global")
        if [ -f "$global_config" ]; then
            if ! validate_cross_config_consistency "$global_config" "$config_file"; then
                return 1
            fi
        fi
    fi

    echo "✅ $config_type配置验证完成"
    return 0
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi