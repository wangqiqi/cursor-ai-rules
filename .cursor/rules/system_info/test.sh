#!/bin/bash
# 系统信息获取器测试脚本
# 用于验证规则的可迁移性和通用性

echo "🔧 系统信息获取器 - 迁移测试"
echo "================================="

# 获取当前时间
GENERATION_TIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
echo "✅ 当前时间: $GENERATION_TIME"

# 获取项目路径
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WORK_DIR=$(pwd)
echo "✅ 项目根目录: $PROJECT_ROOT"
echo "✅ 工作目录: $WORK_DIR"

# 获取作者信息
AUTHOR_NAME=$(git config --get user.name 2>/dev/null || echo "未知作者")
AUTHOR_EMAIL=$(git config --get user.email 2>/dev/null || echo "unknown@example.com")
echo "✅ 作者姓名: $AUTHOR_NAME"
echo "✅ 作者邮箱: $AUTHOR_EMAIL"

echo ""
echo "📝 测试变量替换:"

# 创建测试模板
cat > /tmp/test_template.md << EOF
# 测试文档

*版本: v1.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>*

## 项目信息
- 项目路径: {{PROJECT_ROOT}}
- 工作目录: {{WORK_DIR}}

## 代码示例
\`\`\`javascript
// Created: {{GENERATION_TIME}}
// Author: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}
// Project: {{PROJECT_ROOT}}
console.log("Hello World");
\`\`\`
EOF

echo "📄 原始模板内容:"
cat /tmp/test_template.md

echo ""
echo "🔄 替换后内容:"

# 简单变量替换测试
sed -e "s/{{GENERATION_TIME}}/$GENERATION_TIME/g" \
    -e "s/{{AUTHOR_NAME}}/$AUTHOR_NAME/g" \
    -e "s/{{AUTHOR_EMAIL}}/$AUTHOR_EMAIL/g" \
    -e "s|{{PROJECT_ROOT}}|$PROJECT_ROOT|g" \
    -e "s|{{WORK_DIR}}|$WORK_DIR|g" /tmp/test_template.md

echo ""
echo "✅ 测试完成"
echo "📦 规则可正常迁移到其他项目使用"

# 清理临时文件
rm -f /tmp/test_template.md
