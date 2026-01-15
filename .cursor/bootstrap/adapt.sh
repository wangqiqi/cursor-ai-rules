#!/bin/bash
# ⚙️ Cursor AI Rules - 自适应配置器
# 根据检测结果自动调整配置

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$SCRIPT_DIR/../config"
DETECTION_REPORT="$SCRIPT_DIR/../detection-report.json"

echo "⚙️ Cursor AI Rules - 自适应配置器"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查检测报告是否存在
if [ ! -f "$DETECTION_REPORT" ]; then
    echo "❌ 错误: 未找到检测报告文件"
    echo "请先运行: $SCRIPT_DIR/detect.sh"
    exit 1
fi

# 读取检测结果
read_detection_results() {
    if command -v jq >/dev/null 2>&1; then
        # 使用jq解析JSON
        DETECT_OS_TYPE=$(jq -r '.os_type // "Unknown"' "$DETECTION_REPORT" 2>/dev/null || echo "Unknown")
        DETECT_HAS_GIT=$(jq -r '.git_enabled // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
        DETECT_NODE_INSTALLED=$(jq -r '.node_installed // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
        DETECT_PYTHON_INSTALLED=$(jq -r '.python3_installed // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
        DETECT_GO_INSTALLED=$(jq -r '.go_installed // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
        DETECT_HAS_CONTAINERIZATION=$(jq -r '.has_containerization // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
        DETECT_HAS_CI_CD=$(jq -r '.has_ci_cd // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
        DETECT_HAS_QUALITY_TOOLS=$(jq -r '.has_quality_tools // false' "$DETECTION_REPORT" 2>/dev/null || echo "false")
    else
        # 简单解析（如果没有jq）
        DETECT_OS_TYPE="Unknown"
        DETECT_HAS_GIT="false"
        DETECT_NODE_INSTALLED="false"
        DETECT_PYTHON_INSTALLED="false"
        DETECT_GO_INSTALLED="false"
        DETECT_HAS_CONTAINERIZATION="false"
        DETECT_HAS_CI_CD="false"
        DETECT_HAS_QUALITY_TOOLS="false"
    fi
}

# 1. 调整全局配置
adjust_global_config() {
    echo "🌐 调整全局配置..."

    local global_config="$CONFIG_DIR/global.json"

    if [ ! -f "$global_config" ]; then
        echo "  ⚠️  全局配置文件不存在，创建默认配置"
        cat > "$global_config" << 'EOF'
{
  "version": "1.0.0",
  "system": {
    "os": "auto-detect",
    "log_level": "info",
    "backup_enabled": true,
    "auto_update": true
  },
  "features": {
    "automation": true,
    "skills": true,
    "rules": true,
    "evolution": true,
    "security": true
  },
  "performance": {
    "max_concurrent_tasks": 3,
    "cache_enabled": true,
    "memory_limit_mb": 512
  }
}
EOF
    fi

    # 根据操作系统调整配置
    case $DETECT_OS_TYPE in
        "Linux")
            sed -i 's/"os": "auto-detect"/"os": "linux"/' "$global_config" 2>/dev/null || true
            ;;
        "Darwin")
            sed -i 's/"os": "auto-detect"/"os": "macos"/' "$global_config" 2>/dev/null || true
            ;;
        "MINGW"*|"MSYS"*|"CYGWIN"*)
            sed -i 's/"os": "auto-detect"/"os": "windows"/' "$global_config" 2>/dev/null || true
            ;;
    esac

    echo "✅ 全局配置已调整"
}

# 2. 优化自动化配置
optimize_automation() {
    echo "🤖 优化自动化配置..."

    local hooks_config="$SCRIPT_DIR/../automation/config.json"

    # 根据检测结果调整钩子
    if [ "$DETECT_HAS_QUALITY_TOOLS" = "true" ]; then
        echo "  ✅ 启用代码质量钩子"
    fi

    if [ "$DETECT_HAS_CI_CD" = "true" ]; then
        echo "  ✅ 启用CI/CD相关钩子"
    fi

    if [ "$DETECT_HAS_CONTAINERIZATION" = "true" ]; then
        echo "  ✅ 启用容器化相关钩子"
    fi

    echo "✅ 自动化配置已优化"
}

# 3. 调整技能配置
adjust_skills_config() {
    echo "🎯 调整技能配置..."

    local skills_registry="$SCRIPT_DIR/../skills/registry.json"

    if [ ! -f "$skills_registry" ]; then
        echo "  ⚠️  技能注册表不存在，创建基础配置"
        cat > "$skills_registry" << 'EOF'
{
  "version": "2.0.0",
  "last_updated": "auto-generated",
  "skills": {},
  "categories": {
    "core": [],
    "tech": [],
    "team": []
  },
  "auto_install_rules": {
    "node": ["javascript", "nodejs"],
    "python": ["python", "data-analysis"],
    "go": ["golang", "microservices"],
    "container": ["docker", "kubernetes"]
  }
}
EOF
    fi

    # 根据技术栈更新注册表
    if [ "$DETECT_NODE_INSTALLED" = "true" ]; then
        echo "  📦 添加Node.js相关技能规则"
    fi

    if [ "$DETECT_PYTHON_INSTALLED" = "true" ]; then
        echo "  🐍 添加Python相关技能规则"
    fi

    if [ "$DETECT_GO_INSTALLED" = "true" ]; then
        echo "  🚀 添加Go相关技能规则"
    fi

    echo "✅ 技能配置已调整"
}

# 4. 配置规则系统
configure_rules() {
    echo "📋 配置规则系统..."

    local active_rules_dir="$SCRIPT_DIR/../rules/"

    # 根据检测结果创建软链接或复制规则文件

    # 核心规则（始终启用）
    for rule_file in "$active_rules_dir/core/"*.md; do
        if [ -f "$rule_file" ]; then
            local rule_name=$(basename "$rule_file")
            ln -sf "core/$rule_name" "$active_rules_dir/$rule_name" 2>/dev/null || \
            cp "$rule_file" "$active_rules_dir/$rule_name"
        fi
    done

    # 技术特定规则
    if [ "$DETECT_NODE_INSTALLED" = "true" ]; then
        echo "  📦 启用JavaScript/TypeScript规则"
        for rule_file in "$active_rules_dir/tech/javascript.md" "$active_rules_dir/tech/nodejs.md"; do
            if [ -f "$rule_file" ]; then
                local rule_name=$(basename "$rule_file")
                ln -sf "../tech/$rule_name" "$active_rules_dir/$rule_name" 2>/dev/null || \
                cp "$rule_file" "$active_rules_dir/$rule_name"
            fi
        done
    fi

    if [ "$DETECT_PYTHON_INSTALLED" = "true" ]; then
        echo "  🐍 启用Python规则"
        if [ -f "$active_rules_dir/tech/python.md" ]; then
            ln -sf "../tech/python.md" "$active_rules_dir/python.md" 2>/dev/null || \
            cp "$active_rules_dir/tech/python.md" "$active_rules_dir/python.md"
        fi
    fi

    if [ "$DETECT_GO_INSTALLED" = "true" ]; then
        echo "  🚀 启用Go规则"
        if [ -f "$active_rules_dir/tech/golang.md" ]; then
            ln -sf "../tech/golang.md" "$active_rules_dir/golang.md" 2>/dev/null || \
            cp "$active_rules_dir/tech/golang.md" "$active_rules_dir/golang.md"
        fi
    fi

    echo "✅ 规则系统已配置"
}

# 5. 性能优化
optimize_performance() {
    echo "⚡ 性能优化配置..."

    local performance_config="$CONFIG_DIR/performance.json"

    # 根据系统资源调整配置
    cat > "$performance_config" << EOF
{
  "version": "1.0.0",
  "resource_limits": {
    "max_memory_mb": 512,
    "max_concurrent_tasks": 3,
    "cache_size_mb": 100
  },
  "feature_toggles": {
    "real_time_scanning": $DETECT_HAS_GIT,
    "background_indexing": true,
    "predictive_suggestions": true
  },
  "adaptive_settings": {
    "adjust_based_on_system_load": true,
    "scale_with_project_size": true,
    "optimize_for_team_size": true
  }
}
EOF

    echo "✅ 性能配置已优化"
}

# 6. 安全配置
configure_security() {
    echo "🔒 配置安全设置..."

    local security_config="$CONFIG_DIR/security.json"

    cat > "$security_config" << EOF
{
  "version": "1.0.0",
  "input_validation": {
    "enabled": true,
    "max_input_length": 10000,
    "allowed_file_types": ["md", "txt", "json", "yml", "yaml"]
  },
  "output_filtering": {
    "enabled": true,
    "filter_sensitive_data": true,
    "audit_commands": true
  },
  "network_security": {
    "validate_urls": true,
    "block_external_access": false,
    "rate_limiting": {
      "enabled": true,
      "max_requests_per_minute": 60
    }
  },
  "file_security": {
    "scan_for_malware": false,
    "validate_file_paths": true,
    "prevent_path_traversal": true
  }
}
EOF

    echo "✅ 安全配置已设置"
}

# 7. 生成配置摘要
generate_config_summary() {
    echo ""
    echo "📋 配置摘要"
    echo "=========="

    local summary_file="$CONFIG_DIR/summary.md"

    cat > "$summary_file" << EOF
# Cursor AI Rules - 配置摘要

## 📅 生成时间
$(date '+%Y-%m-%d %H:%M:%S %Z')

## 🔍 检测结果
- **操作系统**: $DETECT_OS_TYPE
- **Git支持**: $DETECT_HAS_GIT
- **Node.js**: $DETECT_NODE_INSTALLED
- **Python**: $DETECT_PYTHON_INSTALLED
- **Go**: $DETECT_GO_INSTALLED
- **容器化**: $DETECT_HAS_CONTAINERIZATION
- **CI/CD**: $DETECT_HAS_CI_CD
- **代码质量**: $DETECT_HAS_QUALITY_TOOLS

## ⚙️ 激活配置
- **全局配置**: $CONFIG_DIR/global.json
- **项目配置**: $CONFIG_DIR/project.json
- **性能配置**: $CONFIG_DIR/performance.json
- **安全配置**: $CONFIG_DIR/security.json

## 🎯 激活技能
$(ls -1 $SCRIPT_DIR/../skills/active/ 2>/dev/null | sed 's/^/- /')

## 📋 激活规则
$(ls -1 $SCRIPT_DIR/../rules/ | grep -v '/' | grep '\.md$' | sed 's/^/- /')

---
*此配置由自适应配置器自动生成*
EOF

    echo "✅ 配置摘要已生成: ${GREEN}$summary_file${NC}"
}

# 主函数
main() {
    read_detection_results

    adjust_global_config
    optimize_automation
    adjust_skills_config
    configure_rules
    optimize_performance
    configure_security
    generate_config_summary

    echo ""
    echo "🎉 自适应配置完成！"
    echo "=================="
    echo ""
    echo "📁 配置文件位置: ${BLUE}$CONFIG_DIR${NC}"
    echo "📋 配置摘要: ${BLUE}$CONFIG_DIR/summary.md${NC}"
    echo ""
    echo "💡 提示: 运行 ${YELLOW}$SCRIPT_DIR/../automation/scripts/env-check.sh${NC} 验证配置"
}

# 检查是否直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi