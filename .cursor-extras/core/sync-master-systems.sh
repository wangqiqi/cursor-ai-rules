#!/bin/bash
# 🎯 Master系统同步脚本
# 统一维护 CLI/JavaScript Master 命令系统的能力映射配置
# 支持简化和平衡模式、向后兼容层与执行报告

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CURSOR_DIR="$PROJECT_ROOT/.cursor"
REPORT_FILE="$PROJECT_ROOT/master-sync-report.md"
CAPABILITY_MAP_FILE="$CURSOR_DIR/commands/capability-map.json"
MODULAR_INDEX="$CURSOR_DIR/commands/capability-maps/_index.json"
OPERATIONS=()
MODE="advanced"

print_usage() {
    cat <<EOF
Usage: $0 [--mode simple|advanced]
--mode   切换同步策略: simple 模式只更新兼容层，advanced 模式同时校验引用并运行自测
EOF
    exit 1
}

add_operation() {
    OPERATIONS+=("$1")
}

ensure_compatibility_layer() {
    if [[ -f "$CAPABILITY_MAP_FILE" ]] && grep -q '"compatibility_layer"' "$CAPABILITY_MAP_FILE"; then
        add_operation "兼容性层已存在（保留旧文件）"
        return
    fi

    if [[ -f "$CAPABILITY_MAP_FILE" ]]; then
        cp "$CAPABILITY_MAP_FILE" "$CAPABILITY_MAP_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        add_operation "备份现有 capability-map.json"
    fi

    mkdir -p "$(dirname "$CAPABILITY_MAP_FILE")"

    cat > "$CAPABILITY_MAP_FILE" <<'EOF'
{
  "version": "1.0.0",
  "description": "向后兼容层 - 自动路由至模块化能力映射系统",
  "compatibility_layer": {
    "enabled": true,
    "new_system": "capability-maps/",
    "index_file": "_index.json",
    "compatibility_mode": true
  },
  "mappings": {
    "analyze_project": {
      "description": "分析项目现状",
      "intents": ["analyze", "assess", "review", "status"],
      "confidence_threshold": 0.75,
      "capabilities": {
        "rules": ["intelligent_evolution"],
        "scripts": ["core/env-perception.sh"],
        "workflows": ["code-analysis", "dependency-analysis"]
      }
    },
    "check_system_info": {
      "description": "检查系统信息",
      "intents": ["system", "info", "status", "health"],
      "confidence_threshold": 0.8,
      "capabilities": {
        "scripts": ["core/env-perception.sh"],
        "rules": ["constitution"]
      }
    }
  },
  "deprecated": true,
  "migration_guide": "请迁移至 capability-maps/ 模块化能力映射系统"
}
EOF

    add_operation "创建新的兼容性层 capability-map.json"
}

verify_modular_references() {
    local files=(
        "$CURSOR_DIR/commands/master-router.js"
        "$CURSOR_DIR/commands/master-handler.js"
    )

    for target in "${files[@]}"; do
        if [[ ! -f "$target" ]]; then
            add_operation "跳过缺失文件：$(basename "$target")"
            continue
        fi

        if grep -q "capability-map\.json" "$target"; then
            add_operation "⚠️ $(basename "$target") 仍引用 capability-map.json，请手动审查"
        else
            add_operation "🎉 $(basename "$target") 已指向 capability-maps/_index.json"
        fi
    done
}

run_tests() {
    if [[ -f "$CURSOR_DIR/cursor-master.sh" ]]; then
        if bash "$CURSOR_DIR/cursor-master.sh" --help >/dev/null 2>&1; then
            add_operation "✅ cursor-master.sh --help 运行正常"
        else
            add_operation "⚠️ cursor-master.sh --help 自测异常"
        fi
    else
        add_operation "⚠️ 缺失 cursor-master.sh，无法自测"
    fi

    if [[ -f "$CURSOR_DIR/commands/master-router.js" ]]; then
        if node "$CURSOR_DIR/commands/master-router.js" --help >/dev/null 2>&1; then
            add_operation "✅ master-router.js --help 运行正常"
        else
            add_operation "⚠️ master-router.js --help 自测异常"
        fi
    else
        add_operation "⚠️ 缺失 master-router.js，无法自测"
    fi
}

generate_report() {
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    cat > "$REPORT_FILE" <<EOF
# 🎯 Master系统同步报告

## 📋 模式
- 同步模式：$MODE
- 报告生成时间：$timestamp

## 🔧 操作纪要
$(for op in "${OPERATIONS[@]}"; do printf '- %s
' "$op"; done)

## 📝 建议
- 每次改动能力映射前先运行 advanced 模式
- 保持 capability-maps 及其 includes 的同步更新
- 若报告出现带 ⚠️ 的条目，请根据提示手动修复

EOF

    echo "📝 同步报告已更新：$REPORT_FILE"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode|-m)
            shift
            if [[ $# -eq 0 ]]; then
                echo "❌ 需要指定模式"
                print_usage
            fi
            MODE="$1"
            shift
            ;;
        --help|-h)
            print_usage
            ;;
        *)
            echo "❌ 未知参数：$1"
            print_usage
            ;;
    esac
done

if [[ "$MODE" != "advanced" && "$MODE" != "simple" ]]; then
    echo "❌ 不支持的模式：$MODE"
    print_usage
fi

echo "🎯 Master 同步脚本运行在 [$MODE] 模式"

ensure_compatibility_layer

if [[ "$MODE" == "advanced" ]]; then
    verify_modular_references
    run_tests
else
    run_tests
fi

generate_report
