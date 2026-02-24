#!/bin/bash
# 🎯 Cursor AI Rules - 迁移额外目录到7目录规范
# 将 cache/skills, skills/loaded, logs, pids 等目录的内容迁移到规范位置

set -euo pipefail

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[MIGRATE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[MIGRATE]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[MIGRATE]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[MIGRATE]${NC} ❌ $1"
}

# 迁移目录映射 (扁平化结构)
declare -A MIGRATION_MAP=(
    [".cursorGrowth/cache/skills"]="ai/cache"
    [".cursorGrowth/skills/loaded"]="ai/skills"
    [".cursorGrowth/pids"]="logs"
    [".cursorGrowth/monitoring/logs"]="logs"
    [".cursorGrowth/monitoring/pids"]="logs"
    [".cursorGrowth/user_data"]="user"
    [".cursorGrowth/ai/agent-data"]="ai/agents"
    [".cursorGrowth/ai/task-states"]="ai/tasks"
    [".cursorGrowth/ai/command_logs"]="ai/commands"
    [".cursorGrowth/ai/training_data"]="ai/training"
    [".cursorGrowth/ai-conversations"]="conversations"
)

# 检查目录是否存在并迁移内容
migrate_directory() {
    local source_dir="$1"
    local target_subpath="$2"

    local source_path="$PROJECT_ROOT/$source_dir"
    local target_path="$PROJECT_ROOT/.cursorGrowth/$target_subpath"

    if [ ! -d "$source_path" ]; then
        log_info "源目录不存在，跳过: $source_dir"
        return 0
    fi

    log_info "迁移目录: $source_dir → $target_subpath"

    # 确保目标目录存在
    mkdir -p "$target_path"

    # 迁移文件
    local migrated_count=0
    if [ -d "$source_path" ] && [ "$(ls -A "$source_path" 2>/dev/null | wc -l)" -gt 0 ]; then
        # 移动所有文件和子目录
        mv "$source_path"/* "$target_path/" 2>/dev/null || true
        migrated_count=$(find "$target_path" -type f | wc -l)
    fi

    # 删除空的源目录
    rmdir "$source_path" 2>/dev/null || true

    log_success "迁移完成: $migrated_count 个文件从 $source_dir 迁移到 $target_subpath"
}

# 清理空的父目录
cleanup_empty_directories() {
    log_info "清理空的父目录..."

    local empty_dirs=(
        ".cursorGrowth/cache"
        ".cursorGrowth/skills"
        ".cursorGrowth/logs"
    )

    for dir in "${empty_dirs[@]}"; do
        local full_path="$PROJECT_ROOT/$dir"
        if [ -d "$full_path" ] && [ ! "$(ls -A "$full_path" 2>/dev/null)" ]; then
            rmdir "$full_path" 2>/dev/null && log_success "删除空目录: $dir" || true
        fi
    done
}

# 主迁移函数
main() {
    log_info "开始迁移额外目录到7目录规范..."
    echo

    # 显示迁移计划
    echo "📋 迁移计划:"
    for source in "${!MIGRATION_MAP[@]}"; do
        echo "  $source → .cursorGrowth/${MIGRATION_MAP[$source]}"
    done
    echo

    # 执行迁移
    for source_dir in "${!MIGRATION_MAP[@]}"; do
        migrate_directory "$source_dir" "${MIGRATION_MAP[$source_dir]}"
    done

    echo
    cleanup_empty_directories

    echo
    log_success "目录迁移完成！"
    echo
    echo "🎯 新的扁平化目录结构:"
    echo "  .cursorGrowth/"
    echo "  ├── perception/    # 环境感知"
    echo "  ├── user/          # 用户数据"
    echo "  ├── ai/            # AI核心"
    echo "  │   ├── agents/    # Agent配置"
    echo "  │   ├── tasks/     # 任务状态"
    echo "  │   ├── commands/  # 命令日志"
    echo "  │   ├── training/  # 学习数据"
    echo "  │   ├── cache/     # 缓存"
    echo "  │   └── metrics/   # 指标"
    echo "  ├── analytics/    # 分析"
    echo "  ├── logs/          # 统一日志"
    echo "  ├── integrations/ # 集成"
    echo "  └── conversations/ # 对话"
    echo
    echo "📚 相关文档已更新以反映新的目录结构。"
}

# 如果脚本被直接调用，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi