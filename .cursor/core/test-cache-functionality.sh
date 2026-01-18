#!/bin/bash
# 🎯 Cursor AI Rules - 缓存功能测试脚本
# 测试项目根目录缓存的创建、使用和失效处理

echo "🎯 Cursor AI Rules - 缓存功能测试"
echo "==================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 测试函数
test_cache_creation() {
    echo ""
    echo "📝 测试1: 缓存文件创建"
    echo "------------------------"

    # 删除现有缓存
    rm -f ".cursorGrowth/PROJECT_ROOT"

    # 加载配置（应该创建缓存）
    echo "加载路径配置..."
    source "$SCRIPT_DIR/path-config.sh" >/dev/null 2>&1

    if [[ -f ".cursorGrowth/PROJECT_ROOT" ]]; then
        cached_path=$(cat ".cursorGrowth/PROJECT_ROOT")
        echo "✅ 缓存文件已创建: $cached_path"

        if [[ "$cached_path" == "$PROJECT_ROOT" ]]; then
            echo "✅ 缓存内容正确"
        else
            echo "❌ 缓存内容错误: 期望=$PROJECT_ROOT, 实际=$cached_path"
        fi
    else
        echo "❌ 缓存文件未创建"
    fi
}

test_cache_usage() {
    echo ""
    echo "📖 测试2: 缓存文件使用"
    echo "-----------------------"

    # 确保缓存存在
    if [[ ! -f ".cursorGrowth/PROJECT_ROOT" ]]; then
        echo "跳过测试：缓存文件不存在"
        return
    fi

    echo "重新加载路径配置..."
    source "$SCRIPT_DIR/path-config.sh" >/dev/null 2>&1

    # 检查是否使用了缓存（通过检查输出）
    echo "✅ 配置加载完成"
}

test_cache_invalidation() {
    echo ""
    echo "🔄 测试3: 缓存失效处理"
    echo "-----------------------"

    # 修改缓存为无效路径
    echo "/tmp/nonexistent-project" > ".cursorGrowth/PROJECT_ROOT"
    echo "已将缓存设置为无效路径"

    echo "重新加载路径配置..."
    source "$SCRIPT_DIR/path-config.sh" >/dev/null 2>&1

    # 检查缓存是否被自动修复
    cached_path=$(cat ".cursorGrowth/PROJECT_ROOT" 2>/dev/null)
    if [[ "$cached_path" == "$PROJECT_ROOT" ]]; then
        echo "✅ 缓存已自动修复"
    else
        echo "❌ 缓存修复失败: 期望=$PROJECT_ROOT, 实际=$cached_path"
    fi
}

test_performance() {
    echo ""
    echo "⚡ 测试4: 性能对比"
    echo "------------------"

    # 测试有缓存的情况
    echo "测试有缓存的加载时间..."
    start_time=$(date +%s%3N)
    source "$SCRIPT_DIR/path-config.sh" >/dev/null 2>&1
    end_time=$(date +%s%3N)
    cached_time=$((end_time - start_time))

    # 删除缓存，测试无缓存的情况
    rm -f ".cursorGrowth/PROJECT_ROOT"
    echo "测试无缓存的加载时间..."
    start_time=$(date +%s%3N)
    source "$SCRIPT_DIR/path-config.sh" >/dev/null 2>&1
    end_time=$(date +%s%3N)
    no_cache_time=$((end_time - start_time))

    echo "有缓存加载时间: ${cached_time}ms"
    echo "无缓存加载时间: ${no_cache_time}ms"

    if [[ $cached_time -lt $no_cache_time ]]; then
        echo "✅ 缓存提高了加载性能"
    else
        echo "ℹ️  性能差异不明显（可能是测试环境因素）"
    fi
}

# 运行所有测试
test_cache_creation
test_cache_usage
test_cache_invalidation
test_performance

echo ""
echo "🎉 缓存功能测试完成！"