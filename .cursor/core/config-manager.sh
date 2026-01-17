#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🌟 Cursor AI Rules - 统一配置管理器
# 管理配置层级、继承、合并和验证

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi