#!/bin/bash
# verify-system 基础测试（任务 20：测试覆盖）
# 验证 verify-system.sh 能正常执行并输出预期统计

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CURSOR_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🧪 运行 verify-system 测试..."
output=$("$CURSOR_DIR/verify-system.sh" --quick 2>&1)
exit_code=$?

# 检查退出码
if [ $exit_code -ne 0 ]; then
    echo "❌ verify-system 退出码非 0: $exit_code"
    exit 1
fi

# 检查关键输出
if ! echo "$output" | grep -q "Rules:"; then
    echo "❌ 输出缺少 Rules 统计"
    exit 1
fi

if ! echo "$output" | grep -qE "globs/alwaysApply|apply_when"; then
    echo "⚠️ 输出可能缺少 frontmatter 统计（检查 unified-check 输出格式）"
fi

# 超长规则应为 0（"文件过长(>500行): 0" 中冒号后的数字）
too_long_line=$(echo "$output" | grep "文件过长" || true)
if [ -n "$too_long_line" ]; then
    # 提取最后一个数字（避免匹配到 500）
    count=$(echo "$too_long_line" | sed 's/.*:\s*\([0-9]*\).*/\1/' | grep -oE '[0-9]+' | tail -1)
    if [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
        echo "❌ 存在超长规则: $count 个"
        exit 1
    fi
fi

echo "✅ verify-system 测试通过"
exit 0
