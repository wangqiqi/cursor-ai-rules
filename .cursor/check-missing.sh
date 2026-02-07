#!/bin/bash
# 检查并输出缺少代码示例或命令式语言的文件

RULES_DIR="/home/jwzhou/workspace/cursor-ai-rules/.cursor/rules"
total=0
with_examples=0
with_command=0

echo "=== 缺少代码示例的文件 ==="
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        total=$((total + 1))
        if ! grep -q '```' "$file" 2>/dev/null; then
            echo "$file"
        else
            with_examples=$((with_examples + 1))
        fi
    fi
done < <(find "$RULES_DIR" -type f -name "*.md" -print0)

echo -e "\n总计: $total 个文件"
echo "包含代码示例: $with_examples 个"
echo "缺少代码示例: $((total - with_examples)) 个"

echo -e "\n=== 缺少命令式语言的文件 ==="
with_command=0
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        if ! grep -qiE 'MUST|NEVER|ALWAYS|DO NOT|REQUIRED|STOP|禁止|必须|务必' "$file" 2>/dev/null; then
            echo "$file"
        else
            with_command=$((with_command + 1))
        fi
    fi
done < <(find "$RULES_DIR" -type f -name "*.md" -print0)

echo -e "\n总计: $total 个文件"
echo "包含命令式语言: $with_command 个"
echo "缺少命令式语言: $((total - with_command)) 个"
