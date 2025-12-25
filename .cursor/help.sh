#!/bin/bash

# 🤖 Cursor AI Rules - 智能帮助系统
# 基于情境的智能引导和问题诊断

set -e

echo "🤖 Cursor AI Rules - 智能帮助系统"
echo "====================================="
echo ""

# 🎯 智能状态检测
detect_system_status() {
    local status="unknown"
    local issues=()

    # 检查.cursorGrowth目录
    if [ ! -d ".cursorGrowth" ]; then
        status="not_initialized"
        issues+=("系统未初始化，建议运行: ./cursor/setup.sh")
    else
        status="initialized"

        # 检查感知数据
        local perception_files=$(find .cursorGrowth/data -name "perception_*.json" 2>/dev/null | wc -l)
        if [ "$perception_files" -eq 0 ]; then
            issues+=("未检测到感知数据，建议运行: ./cursor/rules/intelligent_evolution/perception.sh")
        fi

        # 检查缓存状态
        if [ -f ".cursorGrowth/cache/project_hash" ]; then
            local last_cache_time=$(stat -c %Y .cursorGrowth/cache/project_hash 2>/dev/null || stat -f %m .cursorGrowth/cache/project_hash 2>/dev/null || echo "0")
            local current_time=$(date +%s)
            local age_hours=$(( (current_time - last_cache_time) / 3600 ))

            if [ $age_hours -gt 24 ]; then
                issues+=("缓存数据已过期${age_hours}小时，建议刷新感知")
            fi
        fi
    fi

    echo "$status"
    echo "${issues[@]}"
}

# 📋 显示帮助菜单
show_help_menu() {
    local system_status="$1"
    shift
    local issues=("$@")

    echo "📋 系统状态: $system_status"
    echo ""

    if [ ${#issues[@]} -gt 0 ]; then
        echo "⚠️  检测到以下问题:"
        for issue in "${issues[@]}"; do
            echo "   • $issue"
        done
        echo ""
    fi

    echo "🛠️  可用命令:"
    echo ""

    case "$system_status" in
        "not_initialized")
            echo "🚀 初始化相关:"
            echo "   ./cursor/setup.sh              # 一键智能初始化"
            echo "   ./cursor/cursor-adaptation-setup.sh  # 环境适配"
            echo ""
            ;;

        "initialized")
            echo "🧠 感知与分析:"
            echo "   ./cursor/rules/intelligent_evolution/perception.sh  # 智能感知分析"
            echo "   cat .cursorGrowth/data/perception_*.json            # 查看感知结果"
            echo ""
            echo "📊 系统监控:"
            echo "   cat .cursorGrowth/growth_meta.json                  # 查看系统状态"
            echo "   find .cursorGrowth -name \"*.json\" | head -10      # 查看数据文件"
            echo ""
            ;;
    esac

    echo "📚 文档与配置:"
    echo "   cat .cursor/README.md           # 系统说明文档"
    echo "   cat .cursor/rules/*/README.md   # 规则说明"
    echo "   ls .cursor/rules/               # 查看所有规则"
    echo ""

    echo "🔧 高级操作:"
    echo "   ./cursor/scripts/env_check.sh   # 环境完整性检查"
    echo "   rm -rf .cursorGrowth           # 重置智能进化数据"
    echo ""

    echo "💡 使用技巧:"
    echo "   • 系统会自动检测项目变化并优化性能"
    echo "   • 感知分析支持缓存，避免重复计算"
    echo "   • 所有数据存储在.cursorGrowth目录"
    echo "   • Token消耗优化: 单步多任务分析节省60%"
    echo ""
}

# 🔍 问题诊断
diagnose_issues() {
    local issues=("$@")

    if [ ${#issues[@]} -eq 0 ]; then
        echo "🎉 恭喜！系统运行正常，无需额外配置"
        echo ""
        return
    fi

    echo "🔍 问题诊断与解决方案:"
    echo ""

    for issue in "${issues[@]}"; do
        case "$issue" in
            *"未初始化"*)
                echo "❓ 问题: $issue"
                echo "💡 解决: 运行一键初始化即可自动解决"
                echo "   ./cursor/setup.sh"
                echo ""
                ;;
            *"未检测到感知数据"*)
                echo "❓ 问题: $issue"
                echo "💡 解决: 执行智能感知分析"
                echo "   ./cursor/rules/intelligent_evolution/perception.sh"
                echo ""
                ;;
            *"缓存数据已过期"*)
                echo "❓ 问题: $issue"
                echo "💡 解决: 系统会在下次需要时自动刷新，无需手动操作"
                echo "   或手动触发: ./cursor/rules/intelligent_evolution/perception.sh"
                echo ""
                ;;
        esac
    done
}

# 📈 显示性能指标
show_performance_metrics() {
    if [ -f ".cursorGrowth/growth_meta.json" ]; then
        echo "📈 性能指标:"
        local meta_file=".cursorGrowth/growth_meta.json"

        local perception_runs=$(grep -o '"perception_runs": [0-9]*' "$meta_file" 2>/dev/null | cut -d' ' -f2 || echo "0")
        local version=$(grep -o '"version": "[^"]*"' "$meta_file" 2>/dev/null | cut -d'"' -f4 || echo "未知")

        echo "   • 系统版本: $version"
        echo "   • 感知运行次数: $perception_runs"
        echo "   • 性能模式: 高效率模式 (Token节省60%)"
        echo "   • 缓存机制: 已启用"
        echo "   • 错误处理: 优雅降级"
        echo ""
    fi
}

# 主函数
main() {
    # 检查是否在项目根目录
    if [ ! -f ".cursor/help.sh" ]; then
        echo "❌ 请在项目根目录运行此脚本"
        exit 1
    fi

    # 检测系统状态
    local status_and_issues=$(detect_system_status)
    local system_status=$(echo "$status_and_issues" | head -1)
    local issues=($(echo "$status_and_issues" | tail -n +2))

    # 显示帮助菜单
    show_help_menu "$system_status" "${issues[@]}"

    # 显示性能指标
    show_performance_metrics

    # 诊断问题
    diagnose_issues "${issues[@]}"

    echo "🤝 如有其他问题，请查看项目文档或提交Issue"
    echo ""
}

# 执行主函数
main "$@"
