#!/bin/bash

# 脚本目录需求分析工具
# 用于分析所有脚本需要创建哪些目录和文件

echo "🔍 开始分析脚本目录需求..."
echo "================================="

# 统计信息
total_scripts=0
scripts_with_mkdir=0
scripts_with_file_ops=0

# 创建分析结果文件
echo "# 脚本目录需求分析结果" > script_analysis.md
echo "" >> script_analysis.md
echo "生成时间: $(date)" >> script_analysis.md
echo "" >> script_analysis.md

# 查找所有脚本文件
echo "## 📋 发现的脚本文件" >> script_analysis.md
echo "" >> script_analysis.md

find .cursor/ -name "*.sh" -type f | sort | while read script; do
    echo "- \`$script\`" >> script_analysis.md
    ((total_scripts++))
done

echo "" >> script_analysis.md
echo "## 📁 目录创建分析" >> script_analysis.md
echo "" >> script_analysis.md

# 分析目录创建
echo "### mkdir 命令使用情况:" >> script_analysis.md
echo "" >> script_analysis.md

mkdir_scripts=$(grep -r "mkdir" .cursor/ --include="*.sh" | grep -v "^\s*#" | wc -l)
echo "- 包含 mkdir 命令的脚本数量: $mkdir_scripts" >> script_analysis.md
echo "" >> script_analysis.md

echo "### 详细的 mkdir 使用:" >> script_analysis.md
echo "" >> script_analysis.md

grep -r "mkdir" .cursor/ --include="*.sh" | grep -v "^\s*#" | while read line; do
    script=$(echo "$line" | cut -d: -f1)
    command=$(echo "$line" | cut -d: -f2-)
    echo "- **$script**: \`$command\`" >> script_analysis.md
done

echo "" >> script_analysis.md
echo "## 📄 文件操作分析" >> script_analysis.md
echo "" >> script_analysis.md

# 分析文件写入操作
echo "### 文件写入操作 (echo >, cat >):" >> script_analysis.md
echo "" >> script_analysis.md

write_ops=$(grep -r "echo.*>" .cursor/ --include="*.sh" | grep -v "^\s*#" | wc -l)
echo "- 文件写入操作数量: $write_ops" >> script_analysis.md
echo "" >> script_analysis.md

grep -r "echo.*>" .cursor/ --include="*.sh" | grep -v "^\s*#" | head -20 | while read line; do
    script=$(echo "$line" | cut -d: -f1)
    command=$(echo "$line" | cut -d: -f2- | cut -c1-100)
    echo "- **$script**: \`$command...\`" >> script_analysis.md
done

# 分析文件读取操作
echo "" >> script_analysis.md
echo "### 文件读取操作 (cat, source, <):" >> script_analysis.md
echo "" >> script_analysis.md

read_ops=$(grep -r "cat\|source\|<" .cursor/ --include="*.sh" | grep -v "^\s*#\|source.*shared-functions\|source.*path-config" | wc -l)
echo "- 文件读取操作数量: $read_ops" >> script_analysis.md
echo "" >> script_analysis.md

grep -r "cat\|source\|<" .cursor/ --include="*.sh" | grep -v "^\s*#\|source.*shared-functions\|source.*path-config" | head -15 | while read line; do
    script=$(echo "$line" | cut -d: -f1)
    command=$(echo "$line" | cut -d: -f2- | cut -c1-100)
    echo "- **$script**: \`$command...\`" >> script_analysis.md
done

echo "" >> script_analysis.md
echo "## 🎯 路径使用模式分析" >> script_analysis.md
echo "" >> script_analysis.md

# 分析硬编码路径
echo "### 硬编码路径使用:" >> script_analysis.md
echo "" >> script_analysis.md

hardcoded_paths=$(grep -r "\.cursorGrowth\|\$CURSOR_GROWTH" .cursor/ --include="*.sh" | grep -v "^\s*#\|GROWTH_DIR\|AI_DIR\|ANALYTICS_DIR\|CACHE_DIR\|LOGS_DIR" | wc -l)
echo "- 硬编码路径引用数量: $hardcoded_paths" >> script_analysis.md
echo "" >> script_analysis.md

echo "### 旧变量使用情况:" >> script_analysis.md
echo "" >> script_analysis.md

old_vars=$(grep -r "GROWTH_DIR\|AI_DIR\|ANALYTICS_DIR\|CACHE_DIR\|LOGS_DIR" .cursor/ --include="*.sh" | wc -l)
echo "- 旧路径变量引用数量: $old_vars" >> script_analysis.md
echo "" >> script_analysis.md

# 分析具体的变量使用
for var in "GROWTH_DIR" "AI_DIR" "ANALYTICS_DIR" "CACHE_DIR" "LOGS_DIR"; do
    count=$(grep -r "$var" .cursor/ --include="*.sh" | wc -l)
    echo "- $var: $count 处使用" >> script_analysis.md
done

echo "" >> script_analysis.md
echo "## 📊 统计摘要" >> script_analysis.md
echo "" >> script_analysis.md
echo "- **总脚本数量**: $total_scripts" >> script_analysis.md
echo "- **使用 mkdir 的脚本**: $mkdir_scripts" >> script_analysis.md
echo "- **硬编码路径引用**: $hardcoded_paths" >> script_analysis.md
echo "- **旧变量引用**: $old_vars" >> script_analysis.md
echo "" >> script_analysis.md

echo "✅ 脚本分析完成，结果已保存到 script_analysis.md"
echo ""
echo "📊 快速统计:"
echo "- 总脚本数量: $total_scripts"
echo "- 使用mkdir的脚本: $mkdir_scripts"
echo "- 硬编码路径: $hardcoded_paths"
echo "- 旧变量引用: $old_vars"