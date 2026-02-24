#!/bin/bash

# 🌱 Cursor AI Rules - 生长目录自动管理器
# 自动管理 $CURSOR_GROWTH 目录的所有操作，与项目和用户无关
#
# 使用方法:
#   ./growth-manager.sh init          # 初始化生长目录
#   ./growth-manager.sh cleanup       # 清理过期数据
#   ./growth-manager.sh optimize      # 优化目录结构
#   ./growth-manager.sh stats         # 显示目录统计
#   ./growth-manager.sh verify        # 验证目录完整性

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保脚本在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"

# 加载统一路径配置（设置非严格模式）
export STRICT_MODE=0
export DEBUG=0
if ! source "$SCRIPT_DIR/path-config.sh" 2>/dev/null; then
    handle_error 1 "路径配置加载失败"
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 标准目录结构定义 (与 path-config 一致)
declare -a STANDARD_DIRS=(
    "perception"
    "user"
    "ai"
    "analytics"
    "logs"
    "integrations"
    "conversations"
)

# 初始化生长目录
init_growth_directory() {
    echo -e "${CYAN}🌱 初始化生长目录管理系统...${NC}"

    # 创建标准目录结构 (使用共享函数)
    ensure_directory_structure

    # 创建README文件
    create_readme_file "$CURSOR_GROWTH"

    # 创建初始配置文件
    create_initial_configs

    # 确保gitignore保护
    ensure_gitignore_protection

    echo -e "${GREEN}✅ 生长目录初始化完成${NC}"
}

# 显示目录说明 (不创建静态文件)
show_directory_info() {
    echo "# 🌱 项目生长目录 ($CURSOR_GROWTH)"
    echo ""
    echo "此目录包含项目的AI学习数据和生长信息。"
    echo "这些数据不会被提交到版本控制，是项目私有的。"
    echo ""
    echo "## 📂 目录结构 (按数据类型组织)"
    echo ""
    echo "### 🎯 核心生长数据"
    echo "- **learning/** - AI学习数据"
    echo "  - \`profile.json\` - 用户学习档案"
    echo "  - \`master_interactions.json\` - @master交互历史"
    echo "  - \`patterns.json\` - 意图识别模式"
    echo "- **conversations/** - 对话记录"
    echo "  - \`cursor_*.json\` - Cursor IDE对话同步"
    echo "  - \`initial_conversation.json\` - 初始化对话"
    echo ""
    echo "### 📊 分析与统计"
    echo "- **growth/** - 生长指标"
    echo "  - \`metrics.json\` - 生长统计数据"
    echo "- **logs/** - 统一日志"
    echo "  - \`metrics.json\` - 性能指标"
    echo "  - \`performance.log\` - 性能日志"
    echo "  - \`token_usage.log\` - Token使用统计"
    echo ""
    echo "### 🔧 系统数据"
    echo "- **cache/** - 缓存优化"
    echo "  - \`env_perception:*.cache\` - 环境感知缓存"
    echo "  - \`intent_analysis:*.cache\` - 意图分析缓存"
    echo "- **logs/** - 系统日志"
    echo "  - 各种系统操作日志"
    echo "- **sync/** - 同步管理"
    echo "  - \`cursor_sync_status.json\` - Cursor数据同步状态"
    echo ""
    echo "### 🌐 外部集成"
    echo "- **mcps/** - MCP生态系统"
    echo "  - \`user-pdf-reader/\` - PDF阅读器MCP资源"
    echo "  - 其他MCP服务的配置和资源"
    echo "- **compression/** - Token压缩数据 *(由optimizer.sh自动管理)*"
    echo "  - 压缩字典、缓存、性能数据"
    echo "- **personal/** - 个性化数据 *(按需生成)*"
    echo "- **debug/** - 调试信息 *(按需生成)*"
    echo ""
    echo "---"
    echo ""
    echo "*此目录由 .cursor/core/growth-manager.sh 自动管理*"
    echo "*不包含任何静态文档文件，保持项目私有性*"
}

# 创建README文件
create_readme_file() {
    local growth_dir="$1"
    local readme_file="$growth_dir/README.md"

    # 如果README已存在，跳过创建
    if [ -f "$readme_file" ]; then
        return 0
    fi

    cat > "$readme_file" << 'EOF'
# 🌱 项目生长目录 ($CURSOR_GROWTH)

此目录包含项目的AI学习数据和生长信息。
这些数据不会被提交到版本控制，是项目私有的。

## 📂 目录结构 (按数据类型组织)

### 🎯 核心生长数据
- **learning/** - AI学习数据
  - `profile.json` - 用户学习档案
  - `master_interactions.json` - @master交互历史
  - `patterns.json` - 意图识别模式
- **conversations/** - 对话记录
  - `cursor_*.json` - Cursor IDE对话同步
  - `initial_conversation.json` - 初始化对话

### 📊 分析与统计
- **growth/** - 生长指标
  - `metrics.json` - 生长统计数据
- **logs/** - 统一日志
  - `metrics.json` - 性能指标
  - `performance.log` - 性能日志
  - `token_usage.log` - Token使用统计

### 🔧 系统数据
- **cache/** - 缓存优化
  - `env_perception:*.cache` - 环境感知缓存
  - `intent_analysis:*.cache` - 意图分析缓存
- **logs/** - 系统日志
  - 各种系统操作日志
- **sync/** - 同步管理
  - `cursor_sync_status.json` - Cursor数据同步状态

### 🌐 外部集成
- **mcps/** - MCP生态系统
  - `user-pdf-reader/` - PDF阅读器MCP资源
  - 其他MCP服务的配置和资源
- **compression/** - Token压缩数据 *(由optimizer.sh自动管理)*
  - 压缩字典、缓存、性能数据
- **personal/** - 个性化数据 *(按需生成)*
- **debug/** - 调试信息 *(按需生成)*

---

*🌱 项目生长目录 - AI学习数据的安全存储空间*
EOF
}

# 创建初始配置文件
create_initial_configs() {
    # 创建初始学习档案（如果不存在）
    if [ ! -f "$AI_METRICS_DIR/ai-profile.json" ]; then
        mkdir -p "$AI_METRICS_DIR" && cat > "$AI_METRICS_DIR/ai-profile.json" << EOF
{
  "profile": {
    "created_at": "$(date '+%Y-%m-%d %H:%M:%S')",
    "project_root": "$PROJECT_ROOT",
    "cursor_version": "5.0.0",
    "total_interactions": 0,
    "successful_interactions": 0,
    "learning_enabled": true,
    "preferred_language": "zh-CN",
    "common_intents": {},
    "skill_usage": {},
    "rule_activation": {}
  }
}
EOF
    fi

    # 创建初始生长指标（如果不存在）
    if [ ! -f "$GROWTH_METRICS_DIR/metrics.json" ]; then
        cat > "$GROWTH_METRICS_DIR/metrics.json" << EOF
{
  "metrics": {
    "start_date": "$(date '+%Y-%m-%d')",
    "total_interactions": 0,
    "successful_interactions": 0,
    "failed_interactions": 0,
    "average_response_time_ms": 0,
    "learning_progress": 0,
    "skill_adoption_rate": 0,
    "rule_activation_rate": 0
  }
}
EOF
    fi
}

# 确保gitignore保护
ensure_gitignore_protection() {
    local gitignore_file="$PROJECT_ROOT/.gitignore"

    if [ ! -f "$gitignore_file" ]; then
        # 如果.gitignore不存在，只创建必要的Cursor AI相关规则
        cat > "$gitignore_file" << 'EOF'
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
$CURSOR_GROWTH/

# Cursor AI Rules - 通用规则保持跟踪
!.cursor/
!.cursor/**# 保留生长文件夹的占位符
!$CURSOR_GROWTH/.gitkeep
EOF
    elif ! grep -q -E "(^\.cursorGrowth/|\$CURSOR_GROWTH/)" "$gitignore_file" 2>/dev/null; then
        # 在文件开头添加保护规则（只有在不存在任何cursorGrowth相关条目时）
        local temp_file=$(mktemp)
        cat > "$temp_file" << 'EOF'
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/

EOF
        cat "$gitignore_file" >> "$temp_file"
        mv "$temp_file" "$gitignore_file"
    fi
}

# 清理过期数据
cleanup_expired_data() {
    echo -e "${CYAN}🧹 清理过期生长数据...${NC}"

    local cleaned_files=0

    # 清理分析缓存文件 (如果存在)
    local analytics_cache_files
    analytics_cache_files=$(find "$GROWTH_DIR/analytics/cache" -name "*.cache" -type f -mtime +7 2>/dev/null | wc -l)
    find "$GROWTH_DIR/analytics/cache" -name "*.cache" -type f -mtime +7 -delete 2>/dev/null
    cleaned_files=$((cleaned_files + analytics_cache_files))

    # 清理30天前的旧日志
    local old_logs
    old_logs=$(find "$GROWTH_DIR" -name "*.log" -type f -mtime +30 2>/dev/null | wc -l)
    find "$GROWTH_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null
    cleaned_files=$((cleaned_files + old_logs))

    # 清理空的调试文件
    find "$GROWTH_DIR/debug" -name "*.json" -type f -empty -delete 2>/dev/null

    echo -e "${GREEN}✅ 清理完成，共删除 ${cleaned_files} 个过期文件${NC}"
}

# 优化目录结构
optimize_directory_structure() {
    echo -e "${CYAN}🔧 优化生长目录结构...${NC}"

    # 确保所有标准目录存在
    for dir in "${STANDARD_DIRS[@]}"; do
        if [ ! -d "$GROWTH_DIR/$dir" ]; then
            mkdir -p "$GROWTH_DIR/$dir"
            echo -e "${BLUE}  📁 创建目录: $dir/${NC}"
        fi
    done

    # 重新组织遗留文件到integrations目录（如果需要）
    if [ -d "$GROWTH_DIR/mcps" ] && [ "$(find "$GROWTH_DIR/mcps" -maxdepth 1 -name "*.json" | wc -l)" -gt 0 ]; then
        echo -e "${BLUE}  🔄 迁移遗留MCP文件到integrations目录...${NC}"
        mkdir -p "$INTEGRATIONS_MCP_CONFIGS_DIR"
        find "$GROWTH_DIR/mcps" -maxdepth 1 -name "*.json" -exec mv {} "$INTEGRATIONS_MCP_CONFIGS_DIR/" \; 2>/dev/null
        rmdir "$GROWTH_DIR/mcps" 2>/dev/null
    fi

    # 压缩大文件（如果需要）
    local large_files
    large_files=$(find "$GROWTH_DIR" -name "*.json" -type f -size +1M 2>/dev/null | wc -l)
    if [ "$large_files" -gt 0 ]; then
        echo -e "${BLUE}  📦 发现大文件，建议启用压缩...${NC}"
    fi

    echo -e "${GREEN}✅ 目录结构优化完成${NC}"
}

# 显示目录统计
show_directory_stats() {
    echo -e "${CYAN}📊 生长目录统计报告${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 显示目录说明
    show_directory_info
    echo ""
    echo -e "${CYAN}📈 当前数据统计${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local total_files=0
    local total_size=0

    echo ""
    echo -e "${BLUE}📁 目录结构和文件统计:${NC}"
    printf "%-25s %-8s %-8s\n" "目录" "文件数" "状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for dir in $(find "$GROWTH_DIR" -type d | sort); do
        local dir_name
        dir_name=$(echo "$dir" | sed "s|$GROWTH_DIR/||")
        [ "$dir_name" = "$GROWTH_DIR" ] && dir_name="."

        local file_count
        file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
        total_files=$((total_files + file_count))

        local status="✅ 活跃"
        if [ "$file_count" -eq 0 ]; then
            if [[ "$dir_name" == *"personal"* ]] || [[ "$dir_name" == *"debug"* ]]; then
                status="⏳ 待用"
            else
                status="⚠️  空闲"
            fi
        fi

        printf "%-25s %-8s %s\n" "$dir_name/" "$file_count" "$status"
    done

    echo ""
    echo -e "${GREEN}📈 总体统计:${NC}"
    echo -e "  总文件数: ${total_files} 个"
    echo -e "  总目录数: $(find "$GROWTH_DIR" -type d | wc -l) 个"
    echo -e "  磁盘占用: $(du -sh "$GROWTH_DIR" 2>/dev/null | cut -f1)B"

    # 显示最近活动
    echo ""
    echo -e "${PURPLE}🕒 最近活动:${NC}"
    find "$GROWTH_DIR" -name "*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -3 | while read mtime file; do
        local time_str
        time_str=$(date -d "@${mtime%.*}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "未知时间")
        echo "  $time_str - $(basename "$file")"
    done
}

# 验证目录完整性
verify_directory_integrity() {
    echo -e "${CYAN}🔍 验证生长目录完整性...${NC}"

    local issues_found=0

    # 检查标准目录
    for dir in "${STANDARD_DIRS[@]}"; do
        if [ ! -d "$GROWTH_DIR/$dir" ]; then
            echo -e "${YELLOW}⚠️  缺少目录: $dir/${NC}"
            ((issues_found++))
        fi
    done

    # 检查关键文件
    local critical_files=(
        "README.md"
        "ai-profile.json"
        "growth/metrics.json"
    )

    for file in "${critical_files[@]}"; do
        if [ ! -f "$GROWTH_DIR/$file" ]; then
            echo -e "${RED}❌ 缺少关键文件: $file${NC}"
            ((issues_found++))
        fi
    done

    # 检查文件权限
    local bad_permissions
    bad_permissions=$(find "$GROWTH_DIR" -type f ! -perm 644 2>/dev/null | wc -l)
    if [ "$bad_permissions" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  发现 $bad_permissions 个文件权限异常${NC}"
    fi

    if [ "$issues_found" -eq 0 ]; then
        echo -e "${GREEN}✅ 目录完整性验证通过${NC}"
    else
        echo -e "${RED}❌ 发现 $issues_found 个完整性问题${NC}"
        return 1
    fi
}

# 主函数
main() {
    case "${1:-}" in
        "init")
            init_growth_directory
            ;;
        "cleanup")
            cleanup_expired_data
            ;;
        "optimize")
            optimize_directory_structure
            ;;
        "stats")
            show_directory_stats
            ;;
        "verify")
            verify_directory_integrity
            ;;
        "info")
            show_directory_info
            ;;
        "auto")
            # 自动维护：清理 + 优化 + 验证
            echo -e "${CYAN}🤖 执行自动维护...${NC}"
            cleanup_expired_data
            optimize_directory_structure
            verify_directory_integrity
            echo -e "${GREEN}✅ 自动维护完成${NC}"
            ;;
        "help"|"-h"|"--help")
            echo "🌱 Cursor AI Rules - 生长目录管理器"
            echo ""
            echo "自动管理 $CURSOR_GROWTH 目录的所有操作"
            echo ""
            echo "使用方法:"
            echo "  $0 init          # 初始化生长目录"
            echo "  $0 cleanup       # 清理过期数据"
            echo "  $0 optimize      # 优化目录结构"
            echo "  $0 stats         # 显示目录统计"
            echo "  $0 verify        # 验证目录完整性"
            echo "  $0 info          # 显示目录结构说明"
            echo "  $0 auto          # 自动维护 (清理+优化+验证)"
            echo "  $0 help          # 显示帮助"
            ;;
        *)
            echo -e "${YELLOW}💡 使用 '$0 help' 查看帮助信息${NC}"
            show_directory_stats
            ;;
    esac
}

# 执行主函数
main "$@"