#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置

# 🔍 代码质量检查Hook - AI编辑后自动检查和格式化代码
# 基于Cursor AI Rules的代码质量保障

# 读取JSON输入
input=$(cat)
file_path=$(echo "$input" | jq -r '.file_path // empty')

# 如果没有文件路径，退出
if [[ -z "$file_path" ]]; then
    exit 0
fi

# 获取文件扩展名
filename=$(basename "$file_path")
extension="${filename##*.}"

# 创建日志目录（如果不存在）
mkdir -p "$ANALYTICS_DIR"

# 记录处理开始
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$timestamp] CODE_QUALITY_CHECK: $file_path" >> $CURSOR_GROWTH/logs/code-quality.log

# JavaScript/TypeScript文件处理
if [[ "$extension" =~ ^(js|ts|jsx|tsx|mjs)$ ]]; then
    echo "🔍 检查JavaScript/TypeScript文件: $filename"

    # ESLint检查和修复
    if [[ -f "package.json" ]] && command -v eslint &> /dev/null; then
        echo "  📏 运行ESLint..."
        eslint_output=$(npx eslint "$file_path" --fix --quiet 2>&1)
        eslint_exit_code=$?

        if [[ $eslint_exit_code -eq 0 ]]; then
            echo "  ✅ ESLint检查通过" >> $CURSOR_GROWTH/logs/code-quality.log
        else
            echo "  ⚠️  ESLint发现问题: $eslint_output" >> $CURSOR_GROWTH/logs/code-quality.log
        fi
    fi

    # Prettier格式化
    if [[ -f "package.json" ]] && command -v prettier &> /dev/null; then
        echo "  🎨 运行Prettier格式化..."
        prettier_output=$(npx prettier --write "$file_path" 2>&1)
        prettier_exit_code=$?

        if [[ $prettier_exit_code -eq 0 ]]; then
            echo "  ✅ 代码格式化完成" >> $CURSOR_GROWTH/logs/code-quality.log
        else
            echo "  ⚠️  Prettier格式化失败: $prettier_output" >> $CURSOR_GROWTH/logs/code-quality.log
        fi
    fi

# Python文件处理
elif [[ "$extension" == "py" ]]; then
    echo "🐍 检查Python文件: $filename"

    # Black格式化
    if command -v black &> /dev/null; then
        echo "  🎨 运行Black格式化..."
        black_output=$(black "$file_path" 2>&1)
        black_exit_code=$?

        if [[ $black_exit_code -eq 0 ]]; then
            echo "  ✅ Python代码格式化完成" >> $CURSOR_GROWTH/logs/code-quality.log
        else
            echo "  ⚠️  Black格式化失败: $black_output" >> $CURSOR_GROWTH/logs/code-quality.log
        fi
    fi

    # Flake8检查
    if command -v flake8 &> /dev/null; then
        echo "  🔍 运行Flake8检查..."
        flake8_output=$(flake8 "$file_path" --max-line-length=88 --extend-ignore=E203,W503 2>&1)
        flake8_exit_code=$?

        if [[ $flake8_exit_code -eq 0 ]]; then
            echo "  ✅ Flake8检查通过" >> $CURSOR_GROWTH/logs/code-quality.log
        else
            echo "  ⚠️  Flake8发现问题: $flake8_output" >> $CURSOR_GROWTH/logs/code-quality.log
        fi
    fi

# Go文件处理
elif [[ "$extension" == "go" ]]; then
    echo "🔵 检查Go文件: $filename"

    # gofmt格式化
    if command -v gofmt &> /dev/null; then
        echo "  🎨 运行gofmt格式化..."
        gofmt -w "$file_path"
        echo "  ✅ Go代码格式化完成" >> $CURSOR_GROWTH/logs/code-quality.log
    fi

    # go vet检查
    if command -v go &> /dev/null; then
        echo "  🔍 运行go vet检查..."
        go_vet_output=$(go vet "$file_path" 2>&1)
        go_vet_exit_code=$?

        if [[ $go_vet_exit_code -eq 0 ]]; then
            echo "  ✅ go vet检查通过" >> $CURSOR_GROWTH/logs/code-quality.log
        else
            echo "  ⚠️  go vet发现问题: $go_vet_output" >> $CURSOR_GROWTH/logs/code-quality.log
        fi
    fi

# Rust文件处理
elif [[ "$extension" == "rs" ]]; then
    echo "🦀 检查Rust文件: $filename"

    # rustfmt格式化
    if command -v rustfmt &> /dev/null; then
        echo "  🎨 运行rustfmt格式化..."
        rustfmt "$file_path"
        echo "  ✅ Rust代码格式化完成" >> $CURSOR_GROWTH/logs/code-quality.log
    fi

# C/C++文件处理
elif [[ "$extension" =~ ^(c|cpp|cxx|cc|c\+\+|h|hpp)$ ]]; then
    echo "⚡ 检查C/C++文件: $filename"

    # clang-format格式化（如果可用）
    if command -v clang-format &> /dev/null; then
        echo "  🎨 运行clang-format格式化..."
        clang-format -i "$file_path"
        echo "  ✅ C/C++代码格式化完成" >> $CURSOR_GROWTH/logs/code-quality.log
    fi

# 其他文件类型
else
    echo "📄 文件类型: $extension - 跳过自动处理" >> "$CURSOR_GROWTH/logs/code-quality.log"
fi

# 记录处理完成
echo "[$timestamp] CODE_QUALITY_CHECK_COMPLETED: $file_path" >> $CURSOR_GROWTH/logs/code-quality.log

exit 0