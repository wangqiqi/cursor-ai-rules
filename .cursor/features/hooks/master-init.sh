#!/bin/bash
# 🎯 Master命令初始化Hook - 自动初始化$CURSOR_GROWTH目录
# 当用户使用/master命令时自动触发

# 读取输入参数
input=$(cat)
command_text=$(echo "$input" | jq -r '.command // empty' 2>/dev/null || echo "")
prompt_text=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null || echo "")

# 检查是否是master命令或包含/master关键词
if [[ "$command_text" =~ "/master" ]] || [[ "$prompt_text" =~ "/master" ]] || [[ "$command_text" =~ "master" ]] || [[ "$prompt_text" =~ "master" ]]; then

    # 获取项目根目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
    GROWTH_DIR="$CURSOR_GROWTH"

    # 检查$CURSOR_GROWTH目录是否存在
    if [ ! -d "$GROWTH_DIR" ]; then
        echo "🌱 检测到首次使用Master命令，正在初始化生长目录..." >&2

        # 调用生长目录初始化
        if [ -f "$SCRIPT_DIR/../automation/scripts/growth_init.sh" ]; then
            bash "$SCRIPT_DIR/../../automation/scripts/growth_init.sh" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "✅ 生长目录初始化完成" >&2
            else
                echo "⚠️ 生长目录初始化失败，使用备用方案" >&2
                mkdir -p "$GROWTH_DIR"/{learning,conversations,growth,personal,cache,monitoring,debug,logs,sync,mcps,compression}
                echo "{}" > "$GROWTH_DIR/.gitkeep"
            fi
        else
            echo "⚠️ 未找到生长初始化脚本，使用备用方案" >&2
            mkdir -p "$GROWTH_DIR"/{learning,conversations,growth,personal,cache,monitoring,debug,logs,sync,mcps,compression}
            echo "{}" > "$GROWTH_DIR/.gitkeep"
        fi

        # 创建基本的配置文件
        mkdir -p "$GROWTH_DIR/learning"
        mkdir -p "$GROWTH_DIR/monitoring"

        # 创建学习配置文件
        cat > "$GROWTH_DIR/learning/profile.json" << 'EOF'
{
  "version": "1.0.0",
  "created_at": "'$(date '+%Y-%m-%d %H:%M:%S')'",
  "user_profile": {
    "learning_style": "adaptive",
    "communication_preference": "natural_language",
    "expertise_level": "intermediate"
  },
  "project_profile": {
    "name": "'$(basename "$PROJECT_ROOT")'",
    "type": "unknown",
    "development_stage": "initialization"
  }
}
EOF

        # 创建监控配置文件
        cat > "$GROWTH_DIR/monitoring/metrics.json" << 'EOF'
{
  "monitoring_start": "'$(date '+%Y-%m-%d %H:%M:%S')'",
  "total_interactions": 0,
  "performance_metrics": {
    "average_response_time_ms": 0,
    "cache_hit_rate_percent": 0,
    "average_token_consumption": 0
  }
}
EOF

        echo "🎉 Master命令初始化完成！现在可以开始使用智能功能了。" >&2
    fi
fi

# 输出原始输入（保持钩子链正常工作）
echo "$input"