#!/bin/bash

# 🎯 Cursor AI Rules - 统一路径配置、目录管理和项目隔离
# 基于共享函数库的新6层级目录结构

# 加载共享函数库 (所有共同函数)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

# 注意: 项目上下文验证在脚本使用path-config.sh时由调用方负责
# 这里不进行强制验证，以保持向后兼容性
# 提供所有脚本使用的标准化路径配置、.cursorGrowth目录管理以及项目隔离功能
#
# 使用方法:
#   source "$(dirname "${BASH_SOURCE[0]}")/path-config.sh"
#
# 项目隔离特性:
#   - 自动生成项目唯一标识符
#   - 提供通用变量和项目隔离变量
#   - 验证项目上下文完整性
#
# 提供的变量:
#   项目信息:
#     PROJECT_IDENTIFIER     - 项目唯一标识符 (项目名_哈希)
#     PROJECT_DISPLAY_NAME   - 项目显示名称
#
#   基础路径:
#     PROJECT_ROOT           - 项目根目录
#     CURSOR_DIR             - .cursor目录
#     CURSOR_GROWTH          - .cursorGrowth目录
#     CONFIG_DIR             - 配置目录
#     CORE_DIR               - 核心脚本目录
#     DOCS_DIR               - 文档目录
#
#   通用功能路径 (当前项目):
#     AI_DIR                 - AI学习数据目录
#     ANALYTICS_DIR          - 分析数据目录
#     CACHE_DIR              - 缓存目录
#     DATA_DIR               - 核心数据目录
#     LEARNING_DIR           - 学习数据目录
#     LOGS_DIR               - 日志目录
#     MONITORING_DIR         - 监控数据目录
#     等...
#
#   项目隔离路径 (多项目安全):
#     {PROJECT_IDENTIFIER}_AI_DIR
#     {PROJECT_IDENTIFIER}_ANALYTICS_DIR
#     等...

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 🧠 智能路径查找和项目识别函数 (支持持久化缓存)
find_project_paths() {
    local current_dir="$(pwd)"

    # 🔍 首先尝试动态查找项目根目录和.cursor目录
    PROJECT_ROOT="$current_dir"
    while [[ "$PROJECT_ROOT" != "/" ]]; do
        if [[ -d "$PROJECT_ROOT/.git" ]]; then
            break
        fi
        PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
    done

    # 如果没找到 .git，使用当前目录作为fallback
    if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
        PROJECT_ROOT="$current_dir"
    fi

    # 从当前目录开始向上查找 .cursor 目录
    CURSOR_DIR="$current_dir"
    while [[ "$CURSOR_DIR" != "/" ]]; do
        if [[ -d "$CURSOR_DIR/.cursor" ]]; then
            CURSOR_DIR="$CURSOR_DIR/.cursor"
            break
        fi
        CURSOR_DIR="$(dirname "$CURSOR_DIR")"
    done

    # 如果没找到 .cursor，从SCRIPT_DIR开始查找（向后兼容）
    if [[ ! -d "$CURSOR_DIR" || "$CURSOR_DIR" == "/" ]]; then
        if [[ "$SCRIPT_DIR" == *"/.cursor/core" ]]; then
            CURSOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
            PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
        elif [[ "$SCRIPT_DIR" == *"/.cursor/features/hooks" ]]; then
            CURSOR_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
            PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
        elif [[ "$SCRIPT_DIR" == *"/.cursor/features/automation/scripts" ]]; then
            CURSOR_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)/.cursor"
            PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
        else
            CURSOR_DIR="$SCRIPT_DIR"
            PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
        fi
    fi

    # 确保路径是绝对路径
    PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
    CURSOR_DIR="$(cd "$CURSOR_DIR" && pwd)"

    # 🧹 清理可能存在的错误位置目录
    cleanup_misplaced_growth_dirs

    # 🎯 现在检查缓存文件是否与动态查找的结果一致
    local cache_file="$PROJECT_ROOT/.cursorGrowth/PROJECT_ROOT"
    if [[ -f "$cache_file" ]]; then
        local cached_root=$(cat "$cache_file" 2>/dev/null)
        if [[ "$cached_root" == "$PROJECT_ROOT" ]]; then
            if [[ "${DEBUG:-0}" == "1" ]]; then
                echo "📋 使用缓存的项目根目录: $PROJECT_ROOT"
            fi
        else
            if [[ "${DEBUG:-0}" == "1" ]]; then
                echo "🔄 缓存过期，更新项目根目录缓存"
                echo "  旧缓存: $cached_root"
                echo "  新路径: $PROJECT_ROOT"
            fi
            # 移除PROJECT_ROOT缓存文件创建
        fi
    else
        # 🛡️ 安全验证：确保PROJECT_ROOT不是.cursor目录
        if [[ "$PROJECT_ROOT" == *"/.cursor" || "$PROJECT_ROOT" == ".cursor" ]]; then
            echo "❌ 错误: PROJECT_ROOT 不能是.cursor目录: $PROJECT_ROOT"
            echo "🔧 请从项目根目录运行脚本，或检查脚本的执行上下文"
            return 1
        fi

        # 💾 确保.cursorGrowth目录存在
        if [[ ! -d "$PROJECT_ROOT/.cursorGrowth" ]]; then
            mkdir -p "$PROJECT_ROOT/.cursorGrowth"
        fi
        # 移除PROJECT_ROOT缓存文件创建
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo "💾 创建项目根目录缓存: $cache_file"
        fi
    fi
}

# 项目标识符生成现在使用共享函数库中的实现

# 🧹 清理错误位置的.cursorGrowth目录
cleanup_misplaced_growth_dirs() {
    local current_dir="$(pwd)"
    local misplaced_dirs=()

    # 检查.cursor目录中的.cursorGrowth
    if [[ -d "$CURSOR_DIR/.cursorGrowth" ]]; then
        misplaced_dirs+=("$CURSOR_DIR/.cursorGrowth")
    fi

    # 检查其他可能的错误位置
    local possible_misplaced=(
        "$current_dir/.cursorGrowth"
        "/tmp/.cursorGrowth"
        "$HOME/.cursorGrowth"
    )

    for dir in "${possible_misplaced[@]}"; do
        if [[ -d "$dir" && "$dir" != "$PROJECT_ROOT/.cursorGrowth" ]]; then
            # 检查是否真的是错误位置（不包含项目特定的标识符）
            if [[ ! -f "$dir/growth_meta.json" || "$(cat "$dir/growth_meta.json" 2>/dev/null | grep -o '"project_id":"[^"]*"' | cut -d'"' -f4)" != "$PROJECT_ID" ]]; then
                misplaced_dirs+=("$dir")
            fi
        fi
    done

    # 清理错误位置的目录
    if [[ ${#misplaced_dirs[@]} -gt 0 ]]; then
        echo "🧹 发现错误位置的.cursorGrowth目录，正在清理..."
        for dir in "${misplaced_dirs[@]}"; do
            echo "  删除: $dir"
            rm -rf "$dir" 2>/dev/null || true
        done
        echo "✅ 清理完成"
    fi
}

# 🔍 项目上下文验证函数
validate_project_structure() {
    local validation_errors=()

    # 检查项目根目录
    if [ ! -d "$PROJECT_ROOT" ]; then
        validation_errors+=("项目根目录不存在: $PROJECT_ROOT")
    fi

    # 检查 .git 目录
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        validation_errors+=("不是有效的Git仓库: $PROJECT_ROOT")
    fi

    # 检查 .cursor 目录
    if [ ! -d "$CURSOR_DIR" ]; then
        validation_errors+=(".cursor目录不存在: $CURSOR_DIR")
    fi

    # 检查 .cursorGrowth 目录
    if [ ! -d "$CURSOR_GROWTH" ]; then
        mkdir -p "$CURSOR_GROWTH"
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo "📁 创建.cursorGrowth目录: $CURSOR_GROWTH"
        fi
    fi

    # 如果有验证错误，输出警告
    if [ ${#validation_errors[@]} -gt 0 ]; then
        echo "⚠️  项目上下文验证警告:" >&2
        for error in "${validation_errors[@]}"; do
            echo "   - $error" >&2
        done
        if [[ "${STRICT_MODE:-0}" == "1" ]]; then
            echo "❌ 严格模式下退出" >&2
            exit 1
        fi
    else
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo "✅ 项目上下文验证通过"
        fi
    fi
}

# 执行智能路径查找
find_project_paths

# 生成项目标识符
generate_project_identifier

# 导出项目信息变量
export PROJECT_IDENTIFIER
export PROJECT_DISPLAY_NAME

# 导出标准化路径变量 (包含项目标识符前缀)
export PROJECT_ROOT
export CURSOR_DIR="$PROJECT_ROOT/.cursor"
export CURSOR_GROWTH="$PROJECT_ROOT/.cursorGrowth"
export CONFIG_DIR="$CURSOR_DIR/config"
export CORE_DIR="$CURSOR_DIR/core"
export DOCS_DIR="$CURSOR_DIR/docs"

# 默认不使用严格模式 (允许脚本在验证失败时继续运行)
# 只有在明确设置 STRICT_MODE=1 时才严格验证
export STRICT_MODE="${STRICT_MODE:-0}"

# ============================================================================
# 🎯 .cursorGrowth 目录结构管理 (项目隔离)
# ============================================================================

# 标准目录结构定义 (优化版 - 消除概念重叠，逻辑清晰)
declare -a STANDARD_DIRS=(
    # ============================================================================
    # 🎯 严格按照迁移指南的7个核心顶级目录
    # ============================================================================
    "perception"           # 环境感知数据
    "user_data"            # 用户相关数据
    "project_data"         # 项目相关数据
    "ai"                   # AI相关数据
    "analytics"            # 分析数据
    "monitoring"           # 系统监控
    "integrations"         # 第三方集成
)

# ============================================================================
# 🎯 新6层级目录结构路径变量定义
# ============================================================================

# 已迁移到新的7个核心目录结构

# 顶级目录变量 (按迁移指南重新组织)
export PERCEPTION_DIR="$CURSOR_GROWTH/perception"
export USER_DATA_DIR="$CURSOR_GROWTH/user_data"
export PROJECT_DATA_DIR="$CURSOR_GROWTH/project_data"

# AI相关目录 (顶级ai目录下的子目录)
export AI_DIR="$CURSOR_GROWTH/ai"
export AI_MODELS_DIR="$AI_DIR/models"
export AI_TRAINING_DATA_DIR="$AI_DIR/training_data"
export AI_METRICS_DIR="$AI_DIR/metrics"
export AI_RESULTS_DIR="$AI_DIR/results"

# Analytics相关目录 (顶级analytics目录下的子目录)
export ANALYTICS_DIR="$CURSOR_GROWTH/analytics"
export ANALYTICS_DATA_DIR="$ANALYTICS_DIR/data"
export ANALYTICS_CACHE_DIR="$ANALYTICS_DIR/cache"

# Monitoring目录 (独立顶级目录)
export MONITORING_DIR="$CURSOR_GROWTH/monitoring"

# 日志整合到监控目录中
export SYSTEM_LOGS_DIR="$MONITORING_DIR/logs"
export INTEGRATIONS_DIR="$CURSOR_GROWTH/integrations"

# 注意: 这是完整重构，移除所有向后兼容性变量
# .cursorGrowth 随时可删除重建，不需要兼容性

# 为growth-manager.sh等目录管理脚本保留GROWTH_DIR变量
export GROWTH_DIR="$CURSOR_GROWTH"

# ============================================================================
# 📁 目录管理函数
# ============================================================================

# 初始化标准目录结构
init_growth_directories() {
    local created_count=0
    local existing_count=0

    for dir_path in "${STANDARD_DIRS[@]}"; do
        local full_path="$CURSOR_GROWTH/$dir_path"
        if [ ! -d "$full_path" ]; then
            mkdir -p "$full_path"
            ((created_count++))
        else
            ((existing_count++))
        fi
    done

    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "📁 目录初始化完成: 创建 $created_count 个, 已存在 $existing_count 个"
    fi
}

# 验证目录结构完整性
verify_growth_structure() {
    local missing_dirs=()
    local total_dirs=${#STANDARD_DIRS[@]}
    local existing_dirs=0

    for dir_path in "${STANDARD_DIRS[@]}"; do
        if [ -d "$CURSOR_GROWTH/$dir_path" ]; then
            ((existing_dirs++))
        else
            missing_dirs+=("$dir_path")
        fi
    done

    if [ ${#missing_dirs[@]} -gt 0 ]; then
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo "❌ 缺失标准目录:"
            for missing in "${missing_dirs[@]}"; do
                echo "   - $missing"
            done
        fi
        return 1
    else
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo "✅ 目录结构完整: $existing_dirs/$total_dirs"
        fi
        return 0
    fi
}

# 清理非常规目录
cleanup_non_standard_dirs() {
    # 定义需要保留的标准目录（基于STANDARD_DIRS）
    local keep_dirs=(
        "ai"
        "analytics"
        "backups"
        "cache"
        "config"
        "conversations"
        "data"
        "debug"
        "growth"
        "learning"
        "logs"
        "mcps"
        "monitoring"
        "personal"
    )

    local removed_count=0

    # 扫描并清理非常规目录
    if [ -d "$CURSOR_GROWTH" ]; then
        for dir in "$CURSOR_GROWTH"/*/; do
            if [ -d "$dir" ]; then
                local dirname=$(basename "$dir")
                local is_standard=false

                for keep_dir in "${keep_dirs[@]}"; do
                    if [ "$dirname" = "$keep_dir" ]; then
                        is_standard=true
                        break
                    fi
                done

                if [ "$is_standard" = false ]; then
                    rm -rf "$dir"
                    ((removed_count++))
                    if [[ "${DEBUG:-0}" == "1" ]]; then
                        echo "🗑️ 移除非常规目录: $dirname"
                    fi
                fi
            fi
        done
    fi

    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "🧹 清理完成: 移除 $removed_count 个非常规目录"
    fi
}

# ============================================================================
# 🎯 项目上下文验证和目录初始化
# ============================================================================

# 验证项目结构
validate_project_structure

# ============================================================================
# 💾 项目根目录缓存管理
# ============================================================================

# 更新项目根目录缓存
update_project_root_cache() {
    # 移除PROJECT_ROOT缓存文件创建
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "💾 项目根目录缓存已禁用"
    fi
}

# 验证项目根目录缓存
validate_project_root_cache() {
    local cache_file="$CURSOR_GROWTH/PROJECT_ROOT"
    if [[ -f "$cache_file" ]]; then
        local cached_root=$(cat "$cache_file" 2>/dev/null)
        if [[ "$cached_root" != "$PROJECT_ROOT" ]]; then
            if [[ "${DEBUG:-0}" == "1" ]]; then
                echo "🔄 项目根目录已变更，更新缓存"
                echo "  旧路径: $cached_root"
                echo "  新路径: $PROJECT_ROOT"
            fi
            # 移除缓存更新
        fi
    else
        update_project_root_cache
    fi
}

# 初始化和验证目录结构（自动执行）
if [ ! -d "$CURSOR_GROWTH" ]; then
    mkdir -p "$CURSOR_GROWTH"
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "📁 创建项目.cursorGrowth目录: $CURSOR_GROWTH"
    fi
fi

init_growth_directories || true  # 允许失败，不影响脚本执行
validate_project_root_cache  # 确保缓存文件正确

if [[ "${VERIFY_DIRS:-0}" == "1" ]]; then
    if ! verify_growth_structure; then
        echo "⚠️  项目[$PROJECT_DISPLAY_NAME]目录结构不完整，正在修复..."
        cleanup_non_standard_dirs
        init_growth_directories
        verify_growth_structure
    fi
fi

# 调试信息 (仅在DEBUG=1时显示)
if [[ "${DEBUG:-0}" == "1" ]]; then
    echo "🔍 Path Config Debug:"
    echo "  项目标识符: $PROJECT_IDENTIFIER"
    echo "  项目显示名: $PROJECT_DISPLAY_NAME"
    echo "  SCRIPT_DIR: $SCRIPT_DIR"
    echo "  PROJECT_ROOT: $PROJECT_ROOT"
    echo "  CURSOR_DIR: $CURSOR_DIR"
    echo "  CURSOR_GROWTH: $CURSOR_GROWTH"
    echo "  CONFIG_DIR: $CONFIG_DIR"
    echo "  CORE_DIR: $CORE_DIR"
    echo "  DOCS_DIR: $DOCS_DIR"
    echo ""
    echo "  🎯 项目隔离路径变量:"
    echo "    PERCEPTION_DIR: $PERCEPTION_DIR (${PROJECT_IDENTIFIER}_PERCEPTION_DIR)"
    echo "    USER_DATA_DIR: $USER_DATA_DIR (${PROJECT_IDENTIFIER}_USER_DATA_DIR)"
    echo "    PROJECT_DATA_DIR: $PROJECT_DATA_DIR (${PROJECT_IDENTIFIER}_PROJECT_DATA_DIR)"
    echo "    AI_DIR: $AI_DIR (${PROJECT_IDENTIFIER}_AI_DIR)"
    echo "    ANALYTICS_DIR: $ANALYTICS_DIR (${PROJECT_IDENTIFIER}_ANALYTICS_DIR)"
    echo "    INTEGRATIONS_DIR: $INTEGRATIONS_DIR (${PROJECT_IDENTIFIER}_INTEGRATIONS_DIR)"
    echo "    SYSTEM_LOGS_DIR: $SYSTEM_LOGS_DIR (${PROJECT_IDENTIFIER}_SYSTEM_LOGS_DIR)"
    echo ""
fi