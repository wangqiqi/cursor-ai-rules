#!/bin/bash
# 🎯 Cursor AI Rules 项目清理脚本
# 安全清理临时文件、备份文件、测试文件和无用文件

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🧹 开始项目清理..."
echo "📁 项目根目录: $PROJECT_ROOT"
echo "📁 Cursor目录: $SCRIPT_DIR"

# 统计清理前的文件数量
echo "📊 清理前统计..."
TOTAL_FILES_BEFORE=$(find "$PROJECT_ROOT" -type f | wc -l)
echo "   总文件数: $TOTAL_FILES_BEFORE"

# 创建清理日志
CLEANUP_LOG="$PROJECT_ROOT/cleanup-$(date +%Y%m%d_%H%M%S).log"
echo "🧹 项目清理日志 - $(date)" > "$CLEANUP_LOG"
echo "=======================================" >> "$CLEANUP_LOG"

# 初始化清理计数器
CLEANED_FILES=0
CLEANED_SIZE=0

# 安全清理函数
safe_remove() {
    local file="$1"
    local reason="$2"

    if [ -f "$file" ] || [ -d "$file" ]; then
        local size=$(du -b "$file" 2>/dev/null | cut -f1 || echo "0")
        echo "🗑️  删除: $file ($reason)" | tee -a "$CLEANUP_LOG"
        rm -rf "$file"
        CLEANED_FILES=$((CLEANED_FILES + 1))
        CLEANED_SIZE=$((CLEANED_SIZE + size))
    else
        echo "⚠️  文件不存在: $file" >> "$CLEANUP_LOG"
    fi
}

# 1. 清理备份文件
echo "🔄 步骤1: 清理备份文件..."
find "$PROJECT_ROOT" -name "*.backup.*" -type f | while read -r file; do
    safe_remove "$file" "备份文件"
done

# 2. 清理临时文件
echo "🔄 步骤2: 清理临时文件..."
find "$PROJECT_ROOT" -name "*.tmp" -type f | while read -r file; do
    safe_remove "$file" "临时文件"
done

# 3. 清理测试文件
echo "🔄 步骤3: 清理测试文件..."

# 清理空的感知测试文件
if [ -f "$PROJECT_ROOT/perception_test_20260122_155249.json" ] && [ ! -s "$PROJECT_ROOT/perception_test_20260122_155249.json" ]; then
    safe_remove "$PROJECT_ROOT/perception_test_20260122_155249.json" "空测试文件"
fi

# 清理测试脚本
if [ -f "$PROJECT_ROOT/test_perception.sh" ]; then
    safe_remove "$PROJECT_ROOT/test_perception.sh" "测试脚本"
fi

# 4. 清理奇怪命名的文件
echo "🔄 步骤4: 清理可疑文件..."

# 检查docs-.md是否是临时文件
if [ -f "$PROJECT_ROOT/docs-.md" ]; then
    # 检查文件内容是否看起来像临时文档
    if head -5 "$PROJECT_ROOT/docs-.md" | grep -q "重构规划\|规划\|临时"; then
        safe_remove "$PROJECT_ROOT/docs-.md" "临时文档文件"
    else
        echo "ℹ️  保留 docs-.md (看起来是正式文档)" | tee -a "$CLEANUP_LOG"
    fi
fi

# 5. 清理未使用的旧配置文件
echo "🔄 步骤5: 清理旧配置文件..."

# 检查personality-system-old.json是否被使用
if [ -f "$SCRIPT_DIR/config/personality-system-old.json" ]; then
    if ! grep -r "personality-system-old" "$PROJECT_ROOT" --exclude-dir=.git --exclude-dir=.cursorGrowth >/dev/null 2>&1; then
        safe_remove "$SCRIPT_DIR/config/personality-system-old.json" "未使用的旧配置文件"
    else
        echo "ℹ️  保留 personality-system-old.json (仍在使用)" | tee -a "$CLEANUP_LOG"
    fi
fi

# 6. 清理空的目录
echo "🔄 步骤6: 清理空目录..."
find "$PROJECT_ROOT" -type d -empty -not -path "*/.git/*" -not -path "*/.cursorGrowth/*" | while read -r dir; do
    # 检查是否是重要的空目录（如.gitkeep所在目录）
    if [ ! -f "$dir/.gitkeep" ] && [ ! -f "$dir/README.md" ]; then
        echo "🗂️  删除空目录: $dir" | tee -a "$CLEANUP_LOG"
        rmdir "$dir" 2>/dev/null || true
    fi
done

# 7. 清理日志文件（如果有的话）
echo "🔄 步骤7: 清理日志文件..."
find "$PROJECT_ROOT" -name "*.log" -type f -mtime +7 | while read -r file; do
    # 只清理超过7天的日志文件
    safe_remove "$file" "过期日志文件"
done

# 统计清理结果
echo ""
echo "📊 清理结果统计..."
TOTAL_FILES_AFTER=$(find "$PROJECT_ROOT" -type f | wc -l)
echo "   清理前文件数: $TOTAL_FILES_BEFORE" | tee -a "$CLEANUP_LOG"
echo "   清理后文件数: $TOTAL_FILES_AFTER" | tee -a "$CLEANUP_LOG"
echo "   清理文件数: $CLEANED_FILES" | tee -a "$CLEANUP_LOG"
echo "   释放空间: $((CLEANED_SIZE / 1024)) KB" | tee -a "$CLEANUP_LOG"

# 生成清理报告
echo "" | tee -a "$CLEANUP_LOG"
echo "📋 清理报告" | tee -a "$CLEANUP_LOG"
echo "============" | tee -a "$CLEANUP_LOG"
echo "清理时间: $(date)" | tee -a "$CLEANUP_LOG"
echo "清理脚本: $0" | tee -a "$CLEANUP_LOG"
echo "清理日志: $CLEANUP_LOG" | tee -a "$CLEANUP_LOG"

if [ $CLEANED_FILES -gt 0 ]; then
    echo ""
    echo "✅ 项目清理完成！"
    echo "📊 清理了 $CLEANED_FILES 个文件，释放了 $((CLEANED_SIZE / 1024)) KB 空间"
    echo "📝 详细日志: $CLEANUP_LOG"
else
    echo ""
    echo "ℹ️  没有发现需要清理的文件"
fi