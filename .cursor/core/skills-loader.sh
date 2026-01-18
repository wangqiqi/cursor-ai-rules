#!/bin/bash
# 🎯 Cursor AI Rules 技能加载器
# 基于 registry.json 动态加载和使用技能
# 支持条件加载、依赖检查、技能执行等功能

set -euo pipefail

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[SKILLS-LOADER]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SKILLS-LOADER]${NC} ✅ $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[SKILLS-LOADER]${NC} ⚠️  $1" >&2
}

log_error() {
    echo -e "${RED}[SKILLS-LOADER]${NC} ❌ $1" >&2
}

# 全局变量
SKILLS_REGISTRY="$PROJECT_ROOT/.cursor/features/skills/registry.json"
SKILLS_DIR="$PROJECT_ROOT/.cursor/features/skills"
LOADED_SKILLS_DIR="$PROJECT_ROOT/.cursorGrowth/ai/skills"
CACHE_DIR="$PROJECT_ROOT/.cursorGrowth/ai/cache"
LOG_DIR="$PROJECT_ROOT/.cursorGrowth/monitoring/logs"

# 初始化目录
init_directories() {
    mkdir -p "$LOADED_SKILLS_DIR" "$CACHE_DIR" "$LOG_DIR"
}

# 检查 jq 依赖
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log_error "jq 命令未找到，请安装 jq 以使用技能系统"
        return 1
    fi
    return 0
}

# 加载技能注册表
load_skills_registry() {
    if [ ! -f "$SKILLS_REGISTRY" ]; then
        log_error "技能注册表不存在: $SKILLS_REGISTRY"
        return 1
    fi

    # 验证 JSON 格式
    if ! jq empty "$SKILLS_REGISTRY" 2>/dev/null; then
        log_error "技能注册表 JSON 格式错误"
        return 1
    fi

    echo "$SKILLS_REGISTRY"
}

# 获取所有技能列表
get_all_skills() {
    local registry_file="$1"
    jq -r '.skills.legacy | keys[]' "$registry_file" 2>/dev/null || true
}

# 获取技能配置
get_skill_config() {
    local skill_name="$1"
    local registry_file="$2"

    jq -r ".skills.legacy.\"$skill_name\" // empty" "$registry_file" 2>/dev/null || true
}

# 检查技能依赖
check_skill_dependencies() {
    local skill_config="$1"
    local project_context="${2:-}"

    # 检查依赖条件
    local dependencies=$(echo "$skill_config" | jq -r '.dependencies[]?' 2>/dev/null || true)
    local conditions=$(echo "$skill_config" | jq -r '.conditions // empty' 2>/dev/null || true)

    # 检查技术栈依赖
    if [ -n "$dependencies" ]; then
        for dep in $dependencies; do
            case "$dep" in
                javascript|node)
                    if [ ! -f "package.json" ]; then
                        log_warning "技能需要 $dep 但未检测到 package.json"
                        return 1
                    fi
                    ;;
                python)
                    if [ ! -f "requirements.txt" ] && [ ! -f "pyproject.toml" ] && [ ! -f "setup.py" ]; then
                        log_warning "技能需要 $dep 但未检测到 Python 项目文件"
                        return 1
                    fi
                    ;;
                react)
                    if [ -f "package.json" ] && ! grep -q '"react"' package.json; then
                        log_warning "技能需要 $dep 但 package.json 中未找到 react 依赖"
                        return 1
                    fi
                    ;;
                html|css)
                    # 这些通常总是可用的
                    ;;
                *)
                    log_info "未知依赖类型: $dep，跳过检查"
                    ;;
            esac
        done
    fi

    # 检查条件
    if [ -n "$conditions" ] && [ "$conditions" != "null" ]; then
        local always=$(echo "$conditions" | jq -r '.always // false' 2>/dev/null || echo "false")
        if [ "$always" = "true" ]; then
            return 0
        fi
    fi

    return 0
}

# 加载技能文件
load_skill_file() {
    local skill_name="$1"
    local skill_config="$2"

    local skill_path=$(echo "$skill_config" | jq -r '.path // empty' 2>/dev/null || true)
    local skill_file="$SKILLS_DIR/$skill_path"

    if [ -z "$skill_path" ] || [ ! -f "$skill_file" ]; then
        log_error "技能文件不存在: $skill_file"
        return 1
    fi

    # 检查文件类型
    local file_ext="${skill_file##*.}"
    case "$file_ext" in
        md)
            # Markdown 技能文件 - 复制到加载目录
            local loaded_file="$LOADED_SKILLS_DIR/${skill_name}.md"
            cp "$skill_file" "$loaded_file"
            log_success "已加载 Markdown 技能: $skill_name -> $loaded_file"
            ;;
        sh)
            # Shell 脚本技能 - 检查权限并复制
            if [ ! -x "$skill_file" ]; then
                log_warning "技能脚本没有执行权限，正在修复: $skill_file"
                chmod +x "$skill_file"
            fi
            local loaded_file="$LOADED_SKILLS_DIR/${skill_name}.sh"
            cp "$skill_file" "$loaded_file"
            log_success "已加载 Shell 技能: $skill_name -> $loaded_file"
            ;;
        *)
            log_warning "不支持的技能文件类型: $file_ext ($skill_file)"
            return 1
            ;;
    esac

    # 创建技能元数据
    local metadata_file="$LOADED_SKILLS_DIR/${skill_name}.metadata.json"
    echo "$skill_config" | jq ". + {loaded_at: \"$(date -Iseconds)\", loaded_by: \"skills-loader\"}" > "$metadata_file"

    return 0
}

# 缓存技能配置
cache_skill_config() {
    local skill_name="$1"
    local skill_config="$2"

    local cache_file="$CACHE_DIR/${skill_name}.json"
    echo "$skill_config" | jq ". + {cached_at: \"$(date -Iseconds)\"}" > "$cache_file"
}

# 从缓存加载技能配置
load_skill_from_cache() {
    local skill_name="$1"

    local cache_file="$CACHE_DIR/${skill_name}.json"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi
    return 1
}

# 执行技能
execute_skill() {
    local skill_name="$1"
    local args="${2:-}"

    # 首先尝试查找可执行的脚本文件
    local skill_file="$LOADED_SKILLS_DIR/${skill_name}.sh"

    # 如果没有脚本文件，检查是否有markdown文档
    if [ ! -f "$skill_file" ]; then
        local markdown_file="$LOADED_SKILLS_DIR/${skill_name}.md"
        if [ -f "$markdown_file" ]; then
            log_info "技能 $skill_name 是文档型技能，显示内容..."
            cat "$markdown_file"
            log_success "技能文档显示完成: $skill_name"
            return 0
        else
            log_error "技能未加载或不存在: $skill_name"
            return 1
        fi
    fi

    if [ ! -x "$skill_file" ]; then
        log_error "技能文件没有执行权限: $skill_file"
        return 1
    fi

    log_info "执行技能: $skill_name"

    local log_file="$LOG_DIR/${skill_name}_$(date +%s).log"
    local start_time=$(date +%s%3N)

    # 执行技能并记录日志
    {
        bash "$skill_file" $args 2>&1
        local exit_code=$?
        local end_time=$(date +%s%3N)
        local duration=$((end_time - start_time))

        if [ $exit_code -eq 0 ]; then
            log_success "技能执行成功: $skill_name (${duration}ms)"
            echo "{\"status\": \"success\", \"skill\": \"$skill_name\", \"duration\": $duration, \"exit_code\": $exit_code, \"timestamp\": \"$(date -Iseconds)\"}" >> "$log_file"
        else
            log_error "技能执行失败: $skill_name (${duration}ms, 退出码: $exit_code)"
            echo "{\"status\": \"error\", \"skill\": \"$skill_name\", \"duration\": $duration, \"exit_code\": $exit_code, \"timestamp\": \"$(date -Iseconds)\"}" >> "$log_file"
        fi

        echo "$output" >> "$log_file"
    } | tee "$log_file"

    return $exit_code
}

# 加载单个技能
load_skill() {
    local skill_name="$1"
    local registry_file="$2"
    local force_reload="${3:-false}"

    log_info "加载技能: $skill_name"

    # 检查是否已加载（除非强制重新加载）
    local loaded_file="$LOADED_SKILLS_DIR/${skill_name}.md"
    local loaded_script="$LOADED_SKILLS_DIR/${skill_name}.sh"

    if [ "$force_reload" != "true" ] && { [ -f "$loaded_file" ] || [ -f "$loaded_script" ]; }; then
        log_info "技能已加载，跳过: $skill_name"
        return 0
    fi

    # 获取技能配置
    local skill_config=$(get_skill_config "$skill_name" "$registry_file")
    if [ -z "$skill_config" ] || [ "$skill_config" = "null" ]; then
        log_error "技能未在注册表中找到: $skill_name"
        return 1
    fi

    # 检查依赖
    if ! check_skill_dependencies "$skill_config"; then
        log_warning "技能依赖检查失败，跳过加载: $skill_name"
        return 1
    fi

    # 加载技能文件
    if load_skill_file "$skill_name" "$skill_config"; then
        # 缓存配置
        cache_skill_config "$skill_name" "$skill_config"
        log_success "技能加载完成: $skill_name"
        return 0
    else
        log_error "技能文件加载失败: $skill_name"
        return 1
    fi
}

# 批量加载技能
load_skills() {
    local skill_pattern="${1:-}"
    local registry_file="$2"

    log_info "批量加载技能 (模式: ${skill_pattern:-全部})"

    local loaded_count=0
    local failed_count=0

    # 获取所有技能并逐个处理
    local skills_list=$(get_all_skills "$registry_file")

    # 将技能列表转换为数组
    local -a skills_array=()
    while IFS= read -r skill; do
        skills_array+=("$skill")
    done <<< "$skills_list"

    # 处理每个技能
    log_info "将处理 ${#skills_array[@]} 个技能"
    for skill_name in "${skills_array[@]}"; do
        # 如果指定了模式，检查是否匹配
        if [ -n "$skill_pattern" ]; then
            case "$skill_pattern" in
                category=*)
                    local category="${skill_pattern#category=}"
                    local skill_category=$(get_skill_config "$skill_name" "$registry_file" | jq -r '.category // empty' 2>/dev/null || true)
                    if [ "$skill_category" != "$category" ]; then
                        continue
                    fi
                    ;;
                source=*)
                    local source="${skill_pattern#source=}"
                    local skill_source=$(get_skill_config "$skill_name" "$registry_file" | jq -r '.source // empty' 2>/dev/null || true)
                    if [ "$skill_source" != "$source" ]; then
                        continue
                    fi
                    ;;
                *)
                    if [[ ! "$skill_name" =~ $skill_pattern ]]; then
                        continue
                    fi
                    ;;
            esac
        fi

        if load_skill "$skill_name" "$registry_file"; then
            ((loaded_count++))
        else
            ((failed_count++))
        fi
    done

    log_success "批量加载完成: 成功 $loaded_count 个，失败 $failed_count 个"
}

# 获取已加载的技能列表
list_loaded_skills() {
    log_info "已加载的技能:"

    local loaded_skills=$(find "$LOADED_SKILLS_DIR" -name "*.metadata.json" 2>/dev/null | wc -l)
    if [ $loaded_skills -eq 0 ]; then
        log_info "  暂无已加载的技能"
        return 0
    fi

    find "$LOADED_SKILLS_DIR" -name "*.metadata.json" -exec basename {} \; 2>/dev/null | sed 's/.metadata.json$//' | while read -r skill_name; do
        local metadata_file="$LOADED_SKILLS_DIR/${skill_name}.metadata.json"
        local description=$(jq -r '.description // "无描述"' "$metadata_file" 2>/dev/null || echo "无描述")
        local category=$(jq -r '.category // "未分类"' "$metadata_file" 2>/dev/null || echo "未分类")
        echo -e "  ${CYAN}$skill_name${NC} - $description (${category})"
    done
}

# 显示技能信息
show_skill_info() {
    local skill_name="$1"
    local registry_file="$2"

    local skill_config=$(get_skill_config "$skill_name" "$registry_file")
    if [ -z "$skill_config" ] || [ "$skill_config" = "null" ]; then
        log_error "技能未找到: $skill_name"
        return 1
    fi

    echo "🎯 技能信息: $skill_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$skill_config" | jq -r '
        "名称: \(.name // "未命名")",
        "描述: \(.description // "无描述")",
        "分类: \(.category // "未分类")",
        "来源: \(.source // "未知")",
        "路径: \(.path // "未设置")",
        "自动安装: \(.auto_install // false)",
        ("依赖: " + (if .dependencies then (.dependencies | join(", ")) else "无" end)),
        ("条件: " + (if .conditions then (.conditions | tostring) else "无" end))
    ' 2>/dev/null || echo "$skill_config"
}

# 显示帮助信息
show_help() {
    cat << EOF
🎯 Cursor AI Rules 技能加载器

用法:
    $0 <command> [options]

命令:
    load <skill_name>          加载指定技能
    load-all [pattern]         批量加载技能 (可选: category=xx, source=xx, 或正则表达式)
    execute <skill_name> [args] 执行已加载的技能
    list                      列出已加载的技能
    info <skill_name>         显示技能详细信息
    reload <skill_name>       重新加载技能
    clean                     清理已加载的技能和缓存

示例:
    $0 load docx                     # 加载 Word 文档处理技能
    $0 load-all category=document    # 加载所有文档类技能
    $0 execute webapp-testing        # 执行 Web 应用测试技能
    $0 list                          # 查看已加载技能
    $0 info mcp-builder             # 查看 MCP 构建器技能信息
    $0 reload docx                  # 重新加载 Word 技能

技能分类:
    creative     - 创意类技能 (算法艺术、GIF创建等)
    design       - 设计类技能 (UI设计、主题工厂等)
    enterprise   - 企业级技能 (品牌指南、内部通讯等)
    ai_integration - AI集成技能 (MCP构建器、技能创建器等)
    development  - 开发技能 (Web构件构建器等)
    productivity - 生产力技能 (文档协作等)
    document     - 文档处理技能 (Word、PDF、PPT、Excel等)
    testing      - 测试技能 (Web应用测试、评估框架等)
    documentation - 文档技能 (MCP规范、SDK说明等)

EOF
}

# 主函数
main() {
    local command="${1:-}"

    case "$command" in
        load)
            local skill_name="${2:-}"
            if [ -z "$skill_name" ]; then
                log_error "请指定要加载的技能名称"
                exit 1
            fi
            init_directories
            check_dependencies || exit 1
            local registry_file=$(load_skills_registry) || exit 1
            load_skill "$skill_name" "$registry_file"
            ;;
        load-all)
            local pattern="${2:-}"
            init_directories
            check_dependencies || exit 1
            local registry_file=$(load_skills_registry) || exit 1
            load_skills "$pattern" "$registry_file"
            ;;
        execute)
            local skill_name="${2:-}"
            if [ -z "$skill_name" ]; then
                log_error "请指定要执行的技能名称"
                exit 1
            fi
            shift 2
            execute_skill "$skill_name" "$*"
            ;;
        list)
            list_loaded_skills
            ;;
        info)
            local skill_name="${2:-}"
            if [ -z "$skill_name" ]; then
                log_error "请指定技能名称"
                exit 1
            fi
            local registry_file=$(load_skills_registry) || exit 1
            show_skill_info "$skill_name" "$registry_file"
            ;;
        reload)
            local skill_name="${2:-}"
            if [ -z "$skill_name" ]; then
                log_error "请指定要重新加载的技能名称"
                exit 1
            fi
            init_directories
            check_dependencies || exit 1
            local registry_file=$(load_skills_registry) || exit 1
            load_skill "$skill_name" "$registry_file" "true"
            ;;
        clean)
            log_info "清理已加载的技能和缓存..."
            rm -rf "$LOADED_SKILLS_DIR"/* "$CACHE_DIR"/*
            log_success "清理完成"
            ;;
        --help|-h|"")
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            log_info "运行 '$0 --help' 查看可用命令"
            exit 1
            ;;
    esac
}

# 如果脚本被直接调用，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi