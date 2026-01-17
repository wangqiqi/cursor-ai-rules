#!/bin/bash
# 🎯 集成示例：如何在其他脚本中使用 master-init 钩子
#
# 这个示例展示了如何在任何脚本中集成 master-init 钩子
# 来确保 .cursorGrowth 目录在需要时自动初始化

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../features/hooks/master-init.sh"

# 🔧 核心集成函数
ensure_growth_directory() {
    local user_input="$1"

    echo "🔍 检查生长目录状态..." >&2

    # 检查.cursorGrowth目录是否已存在
    if [ -d ".cursorGrowth" ]; then
        echo "✅ 生长目录已存在" >&2
        return 0
    fi

    # 模拟用户输入，调用钩子进行初始化检查
    echo "{\"prompt\": \"/master $user_input\"}" | bash "$HOOK_SCRIPT" >/dev/null 2>&1

    # 验证初始化结果
    if [ -d ".cursorGrowth" ]; then
        echo "✅ 生长目录初始化成功" >&2
        return 0
    else
        echo "❌ 生长目录初始化失败" >&2
        return 1
    fi
}

# 📊 示例函数：需要生长目录的分析功能
perform_analysis() {
    local analysis_type="$1"

    echo "📊 开始执行 $analysis_type 分析..."

    # 确保生长目录存在
    if ! ensure_growth_directory "分析$type"; then
        echo "❌ 无法初始化生长目录，分析取消"
        return 1
    fi

    # 执行实际分析逻辑
    echo "🔄 执行分析逻辑..."
    echo "📈 分析结果已保存到 .cursorGrowth/analysis/"

    # 记录到生长目录
    mkdir -p ".cursorGrowth/analysis"
    echo "{\"analysis_type\": \"$analysis_type\", \"timestamp\": \"$(date)\"}" > ".cursorGrowth/analysis/${analysis_type}_result.json"

    echo "✅ $analysis_type 分析完成"
}

# 🎯 示例函数：需要生长目录的学习功能
perform_learning() {
    local learning_topic="$1"

    echo "🎓 开始学习 $learning_topic..."

    # 确保生长目录存在
    if ! ensure_growth_directory "学习$learning_topic"; then
        echo "❌ 无法初始化生长目录，学习取消"
        return 1
    fi

    # 执行学习逻辑
    echo "🧠 执行学习算法..."
    echo "📚 学习结果已保存到 .cursorGrowth/learning/"

    # 记录学习数据
    mkdir -p ".cursorGrowth/learning"
    echo "{\"topic\": \"$learning_topic\", \"learned_at\": \"$(date)\"}" >> ".cursorGrowth/learning/progress.json"

    echo "✅ $learning_topic 学习完成"
}

# 🚀 主函数
main() {
    echo "🎯 Cursor AI Rules - 集成示例"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    case "${1:-}" in
        "analyze")
            perform_analysis "${2:-代码质量}"
            ;;
        "learn")
            perform_learning "${2:-React技术栈}"
            ;;
        "test")
            echo "🧪 运行集成测试..."
            ensure_growth_directory "测试集成"
            echo "✅ 集成测试完成"
            ;;
        *)
            echo "📖 使用方法:"
            echo "  $0 analyze [类型]    # 执行分析功能"
            echo "  $0 learn [主题]      # 执行学习功能"
            echo "  $0 test              # 运行集成测试"
            echo ""
            echo "示例:"
            echo "  $0 analyze 性能"
            echo "  $0 learn TypeScript"
            echo "  $0 test"
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi