#!/bin/bash
# 📊 性能监控钩子 - 命令执行后自动记录性能指标
# 基于 performance-monitor.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
command_text=$(echo "$input" | jq -r '.command // empty' 2>/dev/null || echo "")
duration=$(echo "$input" | jq -r '.duration // 0' 2>/dev/null || echo "0")

# 只在命令执行后事件中执行
if [[ "$event_type" == "afterShellExecution" ]] && [[ -n "$command_text" ]]; then
    echo "📊 检测到命令执行事件，开始性能监控..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../../core/performance-monitor.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  性能监控脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 执行性能监控（异步，不阻塞）
    (
        echo "📈 记录性能指标..." >&2
        # 这里可以传递命令执行信息给性能监控脚本
        # 目前只是触发基础的性能监控
        if bash "$CORE_SCRIPT" > /dev/null 2>&1; then
            echo "✅ 性能监控完成" >&2
        else
            echo "⚠️  性能监控失败，但不影响后续操作" >&2
        fi
    ) &

    # 立即返回，不等待监控完成
    echo "🔄 性能监控已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"