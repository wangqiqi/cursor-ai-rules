#!/bin/bash
# 最终集成测试：验证 /master 命令的完整功能

echo "🎯 最终集成测试：/master 命令功能验证"
echo "======================================"

# 1. 创建测试文件
echo "📝 创建测试文件..."
echo "test final integration" > final-integration-test.txt
git add final-integration-test.txt

echo "✅ 测试文件已创建并暂存"

# 2. 测试智能匹配器
echo ""
echo "🧠 测试智能匹配器..."
match_result=$(bash .cursor/core/smart-intent-matcher.sh "提交" "" json 2>/dev/null)
echo "匹配结果: $match_result"

# 3. 测试JavaScript处理器
echo ""
echo "🚀 测试JavaScript处理器..."
node_result=$(node .cursor/commands/master-handler.js "提交" 2>&1)
echo "处理器结果: $node_result"

# 4. 验证Git状态
echo ""
echo "📊 验证Git提交状态..."
git_status=$(git status --porcelain)
if [ -z "$git_status" ]; then
    echo "✅ Git状态正常：所有更改已提交"

    # 显示最新提交
    echo "📋 最新提交信息:"
    git log --oneline -1
else
    echo "⚠️ 还有未提交的更改:"
    echo "$git_status"
fi

echo ""
echo "🎉 集成测试完成！"

# 清理
rm final-integration-test.txt 2>/dev/null || true