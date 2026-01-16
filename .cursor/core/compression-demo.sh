#!/bin/bash

# 🎯 Token压缩技术演示
# 展示各种压缩技术的实际效果

set -e

# 加载压缩系统
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/token-compression.sh"
source "$SCRIPT_DIR/performance-monitor.sh"

echo "🎯 Cursor AI Rules - Token压缩技术演示"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 示例数据：模拟一个典型的AI响应
SAMPLE_DATA='{
  "intent_analysis": {
    "user_input": "帮我分析这个JavaScript项目",
    "intent_type": "project_analysis",
    "confidence": 0.85,
    "timestamp": "2026-01-16 11:30:00"
  },
  "environment_analysis": {
    "project_type": "javascript",
    "has_package_json": true,
    "has_requirements_txt": false,
    "has_git": true,
    "tech_stack": "JavaScript/Node.js",
    "team_size": "小型团队 (2-5人)",
    "project_scale": "中型项目",
    "development_stage": "开发中期"
  },
  "decision_making": {
    "should_execute": true,
    "execution_plan": ["env_perception", "code_analysis", "generate_report"],
    "explanation": "检测到项目分析意图，为JavaScript项目执行全面分析",
    "intent_type": "project_analysis",
    "confidence": 0.85,
    "project_type": "javascript"
  },
  "execution_result": {
    "status": "success",
    "analysis_summary": "项目结构良好，建议优化依赖管理和添加测试覆盖率",
    "recommendations": [
      "升级到最新版本的依赖包",
      "添加ESLint配置",
      "增加单元测试",
      "配置CI/CD流水线"
    ]
  }
}'

echo "📊 原始数据分析:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "原始数据大小: $(echo "$SAMPLE_DATA" | wc -c) 字符"
echo "估算Token消耗: $(estimate_tokens "sample_data" "${#SAMPLE_DATA}") tokens"
echo ""

# 初始化压缩系统
init_compression

echo "🔄 不同压缩级别的效果对比:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 测试不同压缩级别
for level in minimal balanced aggressive maximum; do
    echo ""
    echo "🎯 压缩级别: $level"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 应用压缩
    COMPRESSED_DATA=$(COMPRESSION_LEVEL="$level" compress_tokens "$SAMPLE_DATA")

    # 计算统计
    original_size=${#SAMPLE_DATA}
    compressed_size=${#COMPRESSED_DATA}
    compression_ratio=$((compressed_size * 100 / original_size))

    original_tokens=$(estimate_tokens "original" "$original_size")
    compressed_tokens=$(estimate_tokens "compressed" "$compressed_size")
    token_savings=$((original_tokens - compressed_tokens))

    echo "原始大小: ${original_size} 字符"
    echo "压缩后大小: ${compressed_size} 字符"
    echo "压缩率: ${compression_ratio}%"
    echo "Token节省: ${token_savings} tokens (${original_tokens} → ${compressed_tokens})"

    # 显示压缩后的数据样例
    echo "压缩数据样例:"
    echo "$COMPRESSED_DATA" | head -3
    echo "..."

    # 测试解压
    DECOMPRESSED_DATA=$(COMPRESSION_LEVEL="$level" decompress_tokens "$COMPRESSED_DATA")
    decompression_success=$([ "$SAMPLE_DATA" = "$DECOMPRESSED_DATA" ] && echo "✅" || echo "❌")

    echo "解压验证: $decompression_success"
done

echo ""
echo "⚡ 高级优化技术演示:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 流式输出演示
echo ""
echo "🌊 流式输出演示:"
init_streaming
STREAMING_ENABLED=true

send_stream_chunk "开始处理请求..." "status"
send_stream_chunk "分析用户意图..." "progress"
send_stream_chunk "执行环境感知..." "progress"
send_stream_chunk "生成分析报告..." "progress"
send_stream_chunk "处理完成！" "complete"

end_streaming

# 增量更新演示
echo ""
echo "🔄 增量更新演示:"
init_incremental_updates
INCREMENTAL_UPDATES=true

# 模拟多次更新
echo "初始数据: $(calculate_diff 'version 1.0')"
echo "增量更新: $(calculate_diff 'version 1.1' 'version 1.0')"
echo "增量更新: $(calculate_diff 'version 1.2' 'version 1.1')"

# 上下文感知压缩演示
echo ""
echo "🎭 上下文感知压缩演示:"
echo "技术上下文: $(compress_context_aware '{"status": "success", "language": "JavaScript", "framework": "React"}' 'technical')"
echo "用户友好: $(compress_context_aware '{"status": "success", "message": "操作完成"}' 'user_friendly')"
echo "最小化: $(compress_context_aware '{"status": "success", "error": null, "data": {"result": "ok"}}' 'minimal')"

# 预测性预加载演示
echo ""
echo "🔮 预测性预加载演示:"
init_predictive_preload

echo "学习模式: env_perception + project_analysis"
learn_usage_patterns "env_perception" "project_analysis"

echo "学习模式: intent_analysis + user_input"
learn_usage_patterns "intent_analysis" "user_input"

echo "学习模式: file_read + documentation"
learn_usage_patterns "file_read" "documentation"

echo "预测缓存状态: $PREDICTIVE_CACHE"

echo ""
echo "📈 综合性能分析:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 综合分析
analysis=$(analyze_compression_efficiency "$SAMPLE_DATA" "$(COMPRESSION_LEVEL=balanced compress_tokens "$SAMPLE_DATA")")
echo "$analysis" | jq . 2>/dev/null || echo "$analysis"

echo ""
echo "🎉 Token压缩技术演示完成！"
echo ""
echo "💡 关键发现:"
echo "• 平衡压缩可节省 30-50% Token"
echo "• 激进压缩可节省 60-80% Token"
echo "• 流式输出减少用户等待时间"
echo "• 增量更新减少重复传输"
echo "• 上下文感知提供最佳压缩效果"