#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置

# 🧪 Hooks系统测试脚本
# 用于验证所有hooks是否正常工作

echo "🧪 开始测试Cursor AI Rules Hooks系统..."
echo

# 测试1: 检查配置文件
echo "📋 测试1: 检查hooks配置文件..."
if [[ -f ".cursor/hooks.json" ]]; then
    echo "✅ hooks.json 存在"
    hooks_count=$(jq '.hooks | length' .cursor/hooks.json 2>/dev/null || echo "0")
    echo "   配置的hooks数量: $hooks_count"
else
    echo "❌ hooks.json 不存在"
fi
echo

# 测试2: 检查脚本文件
echo "📄 测试2: 检查hook脚本文件..."
hook_scripts=(
    "security-audit.sh"
    "command-log.sh"
    "code-quality.sh"
    "prompt-security.sh"
    "rule-usage-tracker.sh"
    "session-summary.sh"
)

for script in "${hook_scripts[@]}"; do
    if [[ -x ".cursor/hooks/$script" ]]; then
        echo "✅ $script 可执行"
    else
        echo "❌ $script 不可执行或不存在"
    fi
done
echo

# 测试3: 检查日志目录
echo "📊 测试3: 检查日志目录..."
if [[ -d "$CURSOR_GROWTH/logs" ]]; then
    echo "✅ 日志目录存在"
    log_files=$(ls $CURSOR_GROWTH/logs/*.log 2>/dev/null | wc -l)
    echo "   现有日志文件: $log_files"
else
    echo "⚠️  日志目录不存在（将在首次使用时自动创建）"
fi
echo

# 测试4: 验证JSON语法
echo "🔍 测试4: 验证配置文件语法..."
if command -v jq &> /dev/null; then
    if jq empty .cursor/hooks.json 2>/dev/null; then
        echo "✅ hooks.json JSON语法正确"
    else
        echo "❌ hooks.json JSON语法错误"
    fi
else
    echo "⚠️  jq未安装，跳过JSON验证"
fi
echo

echo "🎉 Hooks系统测试完成！"
echo
echo "💡 使用提示:"
echo "   - 重启Cursor以使hooks生效"
echo "   - 查看 $CURSOR_GROWTH/logs/ 目录了解hooks活动"
echo "   - 如有问题，请检查脚本执行权限"