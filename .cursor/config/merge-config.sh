#!/bin/bash
# 配置合并器 - 合并全局、项目和用户覆盖配置

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}") && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
OUTPUT_FILE="$CONFIG_DIR/merged.json"

echo "🔄 合并配置..."

# 检查必要的配置文件
check_file() {
    local file="$1"
    local name="$2"
    if [ ! -f "$file" ]; then
        echo "⚠️  $name 配置文件不存在: $file"
        return 1
    fi
    return 0
}

# 检查配置文件
GLOBAL_CONFIG="$CONFIG_DIR/global.json"
PROJECT_CONFIG="$CONFIG_DIR/project.json"
OVERRIDES_CONFIG="$CONFIG_DIR/overrides.json"

check_file "$GLOBAL_CONFIG" "全局配置" || exit 1
check_file "$PROJECT_CONFIG" "项目配置" || echo "⚠️  项目配置不存在，将使用默认值"
check_file "$OVERRIDES_CONFIG" "覆盖配置" || echo "ℹ️  用户覆盖配置不存在，将使用默认值"

# 使用jq合并配置（如果可用）
if command -v jq >/dev/null 2>&1; then
    echo "📦 使用jq进行深度合并..."

    # 创建基础配置
    jq -n '{}' > "$OUTPUT_FILE"

    # 合并全局配置
    if [ -f "$GLOBAL_CONFIG" ]; then
        jq '.global = input' "$OUTPUT_FILE" "$GLOBAL_CONFIG" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    fi

    # 合并项目配置
    if [ -f "$PROJECT_CONFIG" ]; then
        jq '.project = input' "$OUTPUT_FILE" "$PROJECT_CONFIG" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    fi

    # 合并覆盖配置
    if [ -f "$OVERRIDES_CONFIG" ]; then
        jq '.overrides = input' "$OUTPUT_FILE" "$OVERRIDES_CONFIG" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    fi

    # 应用覆盖配置
    jq '
        # 深度合并函数
        def deep_merge(a; b):
            if (a|type) == "object" and (b|type) == "object" then
                a + b | with_entries(
                    if .value | type == "object" and a[.key] | type == "object" then
                        .value = deep_merge(a[.key]; .value)
                    else
                        .
                    end
                )
            else
                b
            end;

        # 合并配置层级
        if .project then
            .merged = deep_merge(.global; .project)
        else
            .merged = .global
        end |

        if .overrides then
            .merged = deep_merge(.merged; .overrides.overrides)
        end |

        # 添加元数据
        .metadata = {
            "merged_at": now | strftime("%Y-%m-%dT%H:%M:%SZ"),
            "version": "1.0.0",
            "layers": [
                ("global" | select(.global)),
                ("project" | select(.project)),
                ("overrides" | select(.overrides))
            ]
        }
    ' "$OUTPUT_FILE" > "${OUTPUT_FILE}.final"

    mv "${OUTPUT_FILE}.final" "$OUTPUT_FILE"

else
    echo "📝 使用简单合并（未安装jq）..."

    # 简单合并：只复制最新的配置
    cat > "$OUTPUT_FILE" << EOF
{
  "warning": "jq not installed - using simple merge",
  "merged_at": "$(date -Iseconds)",
  "configs": {
EOF

    if [ -f "$GLOBAL_CONFIG" ]; then
        echo '    "global": ' >> "$OUTPUT_FILE"
        cat "$GLOBAL_CONFIG" >> "$OUTPUT_FILE"
        echo ',' >> "$OUTPUT_FILE"
    fi

    if [ -f "$PROJECT_CONFIG" ]; then
        echo '    "project": ' >> "$OUTPUT_FILE"
        cat "$PROJECT_CONFIG" >> "$OUTPUT_FILE"
        echo ',' >> "$OUTPUT_FILE"
    fi

    if [ -f "$OVERRIDES_CONFIG" ]; then
        echo '    "overrides": ' >> "$OUTPUT_FILE"
        cat "$OVERRIDES_CONFIG" >> "$OUTPUT_FILE"
    fi

    echo "  }" >> "$OUTPUT_FILE"
    echo "}" >> "$OUTPUT_FILE"
fi

echo "✅ 配置合并完成: ${OUTPUT_FILE}"
echo "📊 合并后的配置大小: $(wc -c < "$OUTPUT_FILE") bytes"

# 验证JSON格式
if command -v jq >/dev/null 2>&1; then
    if jq . "$OUTPUT_FILE" >/dev/null 2>&1; then
        echo "✅ JSON格式验证通过"
    else
        echo "❌ JSON格式验证失败"
        exit 1
    fi
fi