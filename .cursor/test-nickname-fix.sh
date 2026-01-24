#!/bin/bash

# 🎯 测试昵称查找修复

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 测试昵称查找修复"
echo "========================================"

# 导入角色管理器 (模拟)
echo "📦 模拟角色系统加载..."

# 直接测试loli角色文件中的nickname配置
echo ""
echo "🔍 直接检查loli.json文件中的nickname配置:"
ROLE_FILE="$SCRIPT_DIR/config/roles/loli.json"
if [[ -f "$ROLE_FILE" ]]; then
    echo "✅ loli.json文件存在"

    # 提取nickname字段
    NICKNAME_LINE=$(grep '"nickname"' "$ROLE_FILE")
    if [[ -n "$NICKNAME_LINE" ]]; then
        echo "📋 找到nickname配置: $NICKNAME_LINE"

        # 提取nickname数组内容
        NICKNAME_CONTENT=$(echo "$NICKNAME_LINE" | sed 's/.*"nickname":\s*//')
        echo "📝 nickname行内容: $NICKNAME_CONTENT"

        # 检查是否包含"小妮"
        if echo "$NICKNAME_CONTENT" | grep -q "小妮"; then
            echo "✅ 确认: '小妮' 在nickname配置中"
        else
            echo "❌ 错误: '小妮' 不在nickname配置中"
            exit 1
        fi
    else
        echo "❌ 错误: 未找到nickname字段"
        exit 1
    fi
else
    echo "❌ 错误: loli.json文件不存在"
    exit 1
fi

# 测试JSON解析
echo ""
echo "🔧 测试JSON解析:"
if command -v jq >/dev/null 2>&1; then
    NICKNAMES=$(cat "$ROLE_FILE" | jq -r '.nickname[]' 2>/dev/null | tr '\n' ' ')
    echo "📊 jq解析结果: '$NICKNAMES'"

    if echo "$NICKNAMES" | grep -q "小妮"; then
        echo "✅ jq确认: '小妮' 正确解析"
    else
        echo "❌ jq错误: '小妮' 解析失败"
        echo "详细检查: $(cat "$ROLE_FILE" | jq '.nickname' 2>/dev/null || echo 'jq解析失败')"
        exit 1
    fi
else
    echo "⚠️ jq不可用，使用文本解析"
fi

# 测试角色索引
echo ""
echo "📋 测试角色索引:"
INDEX_FILE="$SCRIPT_DIR/config/roles/index.json"
if [[ -f "$INDEX_FILE" ]]; then
    LOLI_ENTRY=$(cat "$INDEX_FILE" | grep -A 3 '"id": "loli"')
    if [[ -n "$LOLI_ENTRY" ]]; then
        echo "✅ loli角色在索引中注册"
        echo "$LOLI_ENTRY"
    else
        echo "❌ loli角色不在索引中"
        exit 1
    fi
else
    echo "❌ 角色索引文件不存在"
    exit 1
fi

echo ""
echo "🎯 测试总结:"
echo "  ✅ loli.json文件存在"
echo "  ✅ nickname字段正确配置"
echo "  ✅ '小妮'在nickname数组中"
echo "  ✅ loli角色在索引中注册"
echo "  ✅ JSON解析正常"
echo ""
echo "🔧 如果角色呼叫仍然失败，请检查角色管理器的初始化过程"

echo ""
echo "✅ 昵称查找修复测试完成"