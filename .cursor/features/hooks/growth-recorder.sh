#!/bin/bash
# 🌱 生长记录钩子 - AI响应后自动记录学习数据
# 基于 growth-recorder.sh 改造，适配钩子系统

# 读取输入参数（JSON格式）
input=$(cat)
event_type=$(echo "$input" | jq -r '.event // empty' 2>/dev/null || echo "")
response_text=$(echo "$input" | jq -r '.response // empty' 2>/dev/null || echo "")
prompt_text=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null || echo "")

# 只在AI响应后事件中执行
if [[ "$event_type" == "afterAgentResponse" ]] && [[ -n "$response_text" ]]; then
    echo "🌱 检测到AI响应事件，开始生长记录..." >&2

    # 获取脚本目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CORE_SCRIPT="$SCRIPT_DIR/../../core/growth-recorder.sh"

    # 检查核心脚本是否存在
    if [ ! -f "$CORE_SCRIPT" ]; then
        echo "⚠️  生长记录脚本不存在: $CORE_SCRIPT" >&2
        echo "$input"
        exit 0
    fi

    # 异步执行生长记录
    (
        echo "📈 记录AI学习数据..." >&2
        # 构造模拟的记录参数
        user_input="AI交互: ${prompt_text:0:50}..."
        decision_result="{\"response_generated\": true, \"response_length\": ${#response_text}}"
        intent_result="{\"intent_analysis\": {\"intent_type\": \"ai_interaction\", \"confidence\": 0.95}}"

        # 调用生长记录脚本
        if echo "$user_input|$decision_result|$intent_result" | bash "$CORE_SCRIPT" record > /dev/null 2>&1; then
            echo "✅ 生长记录完成" >&2
        else
            echo "⚠️  生长记录失败，但不影响AI响应" >&2
        fi
    ) &

    # 立即返回，不等待记录完成
    echo "🔄 生长记录已在后台启动" >&2
fi

# 返回原始输入，保持钩子链正常工作
echo "$input"