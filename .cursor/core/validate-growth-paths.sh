#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置


# 🎯 Cursor AI Rules - 生长目录路径验证脚本
# 确保所有脚本都正确使用 $CURSOR_GROWTH 目录

set -e

echo "🔍 验证优化脚本是否正确使用 $CURSOR_GROWTH 目录"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 需要检查的脚本列表
SCRIPTS_TO_CHECK=(
    ".cursor/core/performance-cache.sh"
    ".cursor/core/performance-monitor.sh"
    ".cursor/core/optimizer.sh"
    ".cursor/core/batch-executor.sh"
    ".cursor/core/compact-output.sh"
)

# 检查结果
PASSED=0
FAILED=0

check_script() {
    local script="$1"
    local script_name=$(basename "$script")

    if [ ! -f "$script" ]; then
        echo "❌ $script_name: 文件不存在"
        return 1
    fi

    echo "📋 检查 $script_name..."

    # 检查是否包含错误的 .cursor/ 路径
    local wrong_paths=$(grep -n "\.cursor/cache\|\.cursor/monitoring" "$script" || true)

    if [ -n "$wrong_paths" ]; then
        echo "❌ $script_name: 发现错误的路径引用"
        echo "$wrong_paths" | while read -r line; do
            echo "   $line"
        done
        return 1
    fi

    # 检查是否正确使用了 $CURSOR_GROWTH/ 路径
    local growth_paths=$(grep -c "\$CURSOR_GROWTH/" "$script" || true)

    if [ "$growth_paths" -gt 0 ]; then
        echo "✅ $script_name: 正确使用 $CURSOR_GROWTH/ 路径 ($growth_paths 处)"
        return 0
    else
        # 如果没有 $CURSOR_GROWTH/ 路径，检查是否需要
        local needs_growth=$(grep -c "CACHE_DIR\|MONITOR_DIR\|cache\|monitoring" "$script" || true)
        if [ "$needs_growth" -gt 0 ]; then
            echo "⚠️  $script_name: 可能需要检查路径配置"
            return 1
        else
            echo "✅ $script_name: 无需 $CURSOR_GROWTH/ 路径"
            return 0
        fi
    fi
}

# 检查每个脚本
for script in "${SCRIPTS_TO_CHECK[@]}"; do
    if check_script "$script"; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
    echo ""
done

# 检查 $CURSOR_GROWTH 目录结构
echo "🏗️  检查 $CURSOR_GROWTH 目录结构..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REQUIRED_DIRS=(
    "$AI_DIR"
    "$SERVICES_DIR"
    "$ANALYTICS_DIR"
    "$RESEARCH_DIR"
    "$INTEGRATIONS_DIR"
    "$CONFIG_DATA_DIR"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir: 目录存在"
        ((PASSED++))
    else
        echo "❌ $dir: 目录不存在"
        ((FAILED++))
    fi
done

echo ""
echo "📊 验证结果统计"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 通过: $PASSED"
echo "❌ 失败: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "🎉 所有检查通过！优化系统已正确配置使用 $CURSOR_GROWTH 目录"
    exit 0
else
    echo ""
    echo "⚠️  发现 $FAILED 个问题，请检查上述错误信息"
    exit 1
fi