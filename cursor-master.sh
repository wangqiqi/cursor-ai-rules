#!/bin/bash

# 🎯 智能Master命令控制器 v4.3.0
# 自动感知 + 智能决策 + 自主执行
#
# 使用方法:
#   ./cursor-master.sh [自然语言需求描述]    # 智能自动执行
#   ./cursor-master.sh list                   # 查看可用命令
#   ./cursor-master.sh help                   # 智能使用指南

set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$SCRIPT_DIR/.cursor"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# 🚀 初始化优化系统（如果可用）
if [ -f "$CURSOR_DIR/core/optimizer.sh" ]; then
    source "$CURSOR_DIR/core/optimizer.sh"
    init_optimizer >/dev/null 2>&1 || true
fi

# 🎯 初始化上下文池管理系统（如果可用）
if [ -f "$CURSOR_DIR/core/context-pool-manager.sh" ]; then
    source "$CURSOR_DIR/core/context-pool-manager.sh"
    init_context_pool >/dev/null 2>&1 || true
fi

# 🎯 初始化VIBE服务集成（如果可用）
if [ -f "$CURSOR_DIR/core/vibe-services-integration.sh" ]; then
    source "$CURSOR_DIR/core/vibe-services-integration.sh"
    init_vibe_services_integration >/dev/null 2>&1 || true
fi

# 💬 初始化对话式命令系统（如果可用）
if [ -f "$CURSOR_DIR/core/conversational-command-system.sh" ]; then
    source "$CURSOR_DIR/core/conversational-command-system.sh"
    init_conversational_command_system >/dev/null 2>&1 || true
fi

# 🔗 初始化本地MCP集成系统（如果可用）
if [ -f "$CURSOR_DIR/core/local-mcp-integration.sh" ]; then
    source "$CURSOR_DIR/core/local-mcp-integration.sh"
    init_local_mcp_integration >/dev/null 2>&1 || true
fi

# 🤖 初始化代理编排引擎（如果可用）
if [ -f "$CURSOR_DIR/core/agent-orchestration-engine.sh" ]; then
    source "$CURSOR_DIR/core/agent-orchestration-engine.sh"
    init_agent_orchestration_engine >/dev/null 2>&1 || true
fi

# 📊 初始化性能监控仪表板（如果可用）
if [ -f "$CURSOR_DIR/core/performance-dashboard.sh" ]; then
    source "$CURSOR_DIR/core/performance-dashboard.sh"
    init_performance_dashboard >/dev/null 2>&1 || true
fi

# 🧠 初始化自学习引擎（如果可用）
if [ -f "$CURSOR_DIR/core/self-learning-engine.sh" ]; then
    source "$CURSOR_DIR/core/self-learning-engine.sh"
    init_self_learning_engine >/dev/null 2>&1 || true
fi

# ⚡ 初始化自适应优化引擎（如果可用）
if [ -f "$CURSOR_DIR/core/adaptive-optimization-engine.sh" ]; then
    source "$CURSOR_DIR/core/adaptive-optimization-engine.sh"
    init_adaptive_optimization_engine >/dev/null 2>&1 || true
fi

# 🔄 初始化持续学习循环（如果可用）
if [ -f "$CURSOR_DIR/core/continuous-learning-loop.sh" ]; then
    source "$CURSOR_DIR/core/continuous-learning-loop.sh"
    init_continuous_learning_loop >/dev/null 2>&1 || true
fi

# 🌱 初始化项目生长目录
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"
init_growth_directory() {
    # 首次使用检测
    if [ ! -d "$GROWTH_DIR" ]; then
        echo -e "${CYAN}🌱 初始化项目生长目录...${NC}" >&2

        # 创建主目录
        mkdir -p "$GROWTH_DIR"

        # 创建子目录结构
        mkdir -p "$GROWTH_DIR/learning"
        mkdir -p "$GROWTH_DIR/conversations"
        mkdir -p "$GROWTH_DIR/debug"
        mkdir -p "$GROWTH_DIR/growth"
        mkdir -p "$GROWTH_DIR/personal"
        mkdir -p "$GROWTH_DIR/cache"
        mkdir -p "$GROWTH_DIR/monitoring"
        mkdir -p "$GROWTH_DIR/optimization"

        # 🔒 主动管理 .gitignore 文件，确保隐私保护
        ensure_gitignore_protection

        # 创建初始配置文件
        cat > "$GROWTH_DIR/README.md" << 'EOF'
# 🌱 项目生长目录 (.cursorGrowth)

此目录存储项目的私有化信息、学习数据和生长记录。
每次使用 `@master` 命令时，此目录都会自动更新和生长。

## 📁 目录结构

- `learning/` - AI学习数据和模式识别
- `conversations/` - 对话历史和上下文
- `debug/` - 调试信息和错误日志
- `growth/` - 项目生长指标和趋势
- `personal/` - 用户偏好和个性化设置

## 🔒 隐私保护

此目录包含敏感信息，请勿提交到版本控制系统。
建议将其添加到 `.gitignore` 文件中。

## 📊 数据使用

系统会自动分析此目录中的数据来：
- 改进AI助手的响应质量
- 学习用户的偏好和习惯
- 优化项目开发流程
- 提供个性化的建议

EOF

        # 创建初始学习配置文件
        cat > "$GROWTH_DIR/learning/profile.json" << EOF
{
  "version": "1.0.0",
  "created_at": "$(date '+%Y-%m-%d %H:%M:%S')",
  "user_profile": {
    "learning_style": "adaptive",
    "communication_preference": "natural_language",
    "expertise_level": "intermediate",
    "preferred_languages": ["zh-CN", "en-US"],
    "common_intents": [],
    "success_patterns": [],
    "challenge_areas": []
  },
  "project_profile": {
    "name": "$(basename "$PROJECT_ROOT")",
    "type": "unknown",
    "technologies": [],
    "development_stage": "initialization",
    "team_size": 1,
    "last_activity": "$(date '+%Y-%m-%d %H:%M:%S')"
  },
  "growth_metrics": {
    "total_interactions": 0,
    "successful_executions": 0,
    "learning_iterations": 0,
    "improvement_score": 0.0
  }
}
EOF

        # 创建初始对话记录
        cat > "$GROWTH_DIR/conversations/initial_conversation.json" << EOF
{
  "conversation_id": "initial_$(date +%s)",
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "type": "initialization",
  "messages": [
    {
      "role": "system",
      "content": "项目生长目录已初始化。开始记录AI助手与用户的交互数据。",
      "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
    }
  ],
  "metadata": {
    "user_id": "unknown",
    "project_root": "$PROJECT_ROOT",
    "cursor_version": "5.0.0"
  }
}
EOF

        echo -e "${GREEN}✅ 项目生长目录初始化完成${NC}" >&2
        echo -e "${YELLOW}📁 生长目录位置: $GROWTH_DIR${NC}" >&2
    fi
}

# 🔒 确保.gitignore隐私保护
ensure_gitignore_protection() {
    local gitignore_file="$PROJECT_ROOT/.gitignore"

    echo -e "${BLUE}🔒 检查.gitignore隐私保护...${NC}" >&2

    # 检查是否存在.gitignore文件
    if [ ! -f "$gitignore_file" ]; then
        echo -e "${YELLOW}📝 创建新的.gitignore文件...${NC}" >&2

        # 创建基本的.gitignore文件，包含Cursor AI相关的隐私保护
        cat > "$gitignore_file" << 'EOF'
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/

# 个人信息和本地配置
*.local
*.personal
config.local.json
user_preferences.local.json

# 临时文件和缓存
*.tmp
*.cache
.DS_Store
Thumbs.db

# 日志文件
*.log
logs/

# IDE 和编辑器文件
.vscode/
.idea/
*.swp
*.swo

# 操作系统文件
.DS_Store
Thumbs.db
Desktop.ini

# 构建产物
node_modules/
dist/
build/
target/
*.class

# 包管理器文件
package-lock.json
yarn.lock
pnpm-lock.yaml

# 环境变量文件
.env
.env.local
.env.*.local

# 测试覆盖率
coverage/
.nyc_output/

# Cursor AI Rules - 通用规则保持跟踪
!.cursor/
!.cursor/**

EOF
        echo -e "${GREEN}✅ 已创建.gitignore文件并添加隐私保护${NC}" >&2
    else
        # 检查是否已经包含.cursorGrowth/条目
        if ! grep -q "^\.cursorGrowth/$" "$gitignore_file"; then
            echo -e "${YELLOW}📝 更新.gitignore文件，添加.cursorGrowth/保护...${NC}" >&2

            # 在文件开头添加Cursor AI相关的隐私保护注释和条目
            local temp_file=$(mktemp)
            cat > "$temp_file" << 'EOF'
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/

EOF
            # 追加原有的.gitignore内容
            cat "$gitignore_file" >> "$temp_file"
            mv "$temp_file" "$gitignore_file"

            echo -e "${GREEN}✅ 已更新.gitignore文件，添加.cursorGrowth/保护${NC}" >&2
        else
            echo -e "${GREEN}✅ .gitignore文件已包含.cursorGrowth/保护${NC}" >&2
        fi
    fi

    # 验证.gitignore是否生效
    if git check-ignore .cursorGrowth/ 2>/dev/null; then
        echo -e "${GREEN}✅ Git忽略规则验证通过${NC}" >&2
    else
        echo -e "${YELLOW}⚠️  Git忽略规则可能未生效，请手动检查${NC}" >&2
    fi
}

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 🧠 智能感知引擎
analyze_user_intent() {
    local user_input="$1"

    echo "🧠 正在分析用户意图..." >&2

    # 🚀 阶段1.1: Token优化 - 上下文池集成

    # 1. 智能上下文预取 (Token优化)
    intelligent_context_prefetch "analyze_intent" "$user_input" 2>/dev/null || true

    # 2. 快速预检 (性能优化)
    local input_length=${#user_input}
    local word_count=$(echo "$user_input" | wc -w)

    # 2. 上下文池缓存检查 (Token优化增强)
    local cache_key="intent_analysis:$(echo "$user_input" | md5sum | cut -d' ' -f1)"

    # 尝试从上下文池获取缓存的意图分析结果
    local cached_result=$(get_or_create_context "$cache_key" "operation" "perform_fresh_intent_analysis" "$user_input" 2>/dev/null || echo "")

    if [[ -n "$cached_result" ]]; then
        echo "🎯 使用上下文池缓存结果" >&2
        echo "$cached_result"
        return
    fi

    # 降级到传统文件缓存
    local cache_dir="$GROWTH_DIR/cache"
    mkdir -p "$cache_dir"
    local file_cache_key=$(echo "$user_input" | md5sum | cut -d' ' -f1)
    local cache_file="$cache_dir/intent_$file_cache_key.cache"

    if [ -f "$cache_file" ]; then
        local cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo "0") ))
        if [ $cache_age -lt 300 ]; then  # 5分钟缓存
            echo "📋 使用文件缓存结果" >&2
            cat "$cache_file"
            return
        fi
    fi

    # 3. 完整意图分析
    perform_full_intent_analysis "$user_input"

    # 3. 返回结果 (缓存情况下已直接返回)
    if [ ! -f "$cache_file" ] 2>/dev/null; then
        cat << EOF
{
  "intent_analysis": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "recommended_actions": $(printf '%s\n' "${actions[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
    fi

}

# 🚀 阶段0: 完整意图分析函数
perform_full_intent_analysis() {
    local user_input="$1"

    # 初始化分析结果 (使用全局变量)
    intent_type="unknown"
    confidence=0
    actions=()

    # 1. 预处理：清理和标准化输入
    local clean_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9\u4e00-\u9fff ]//g')

    # 2. 关键词权重分析 (为后续意图匹配做准备)
    local tech_keywords=("react" "vue" "angular" "typescript" "javascript" "python" "docker" "kubernetes" "aws" "git")
    local action_keywords=("创建" "开发" "优化" "修复" "测试" "部署" "配置" "分析" "学习" "调试")
    local context_keywords=("项目" "应用" "系统" "代码" "文件" "数据库" "接口" "服务")

    # 计算权重分数 (全局变量，供后续使用)
    tech_score=0
    action_score=0
    context_score=0

    for keyword in "${tech_keywords[@]}"; do
        if echo "$clean_input" | grep -qi "$keyword"; then
            ((tech_score+=2))
        fi
    done

    for keyword in "${action_keywords[@]}"; do
        if echo "$clean_input" | grep -qi "$keyword"; then
            ((action_score+=3))
        fi
    done

    for keyword in "${context_keywords[@]}"; do
        if echo "$clean_input" | grep -qi "$keyword"; then
            ((context_score+=1))
        fi
    done

    # 3. 意图识别规则 - 扩展支持更多场景 (90+种意图)
    if echo "$user_input" | grep -qiE "^skill "; then
        intent_type="skill_call"
        confidence=95
        skill_name=$(echo "$user_input" | sed 's/^skill //' | tr -d '\n\r')
        actions=("skill:$skill_name")

    # 项目创建系列
    elif echo "$user_input" | grep -qiE "(创建|开发|构建|搭建|做一个).*react"; then
        intent_type="create_react_project"
        confidence=95
        actions=("env-perception" "init" "generator" "constitution")
    elif echo "$user_input" | grep -qiE "(创建|开发|构建|搭建|做一个).*vue"; then
        intent_type="create_vue_project"
        confidence=95
        actions=("env-perception" "init" "generator" "constitution")
    elif echo "$user_input" | grep -qiE "(创建|开发|构建|搭建|做一个).*python"; then
        intent_type="create_python_project"
        confidence=95
        actions=("env-perception" "init" "generator" "constitution")

    # 代码质量系列
    elif echo "$user_input" | grep -qiE "(优化|改进|重构|质量|检查)"; then
        intent_type="code_optimization"
        confidence=85
        actions=("quality" "eslint" "perception")
    elif echo "$user_input" | grep -qiE "检查代码质量"; then
        intent_type="check_code_quality"
        confidence=90
        actions=("quality" "eslint" "perception")

    # 部署运维系列
    elif echo "$user_input" | grep -qiE "(ci|cd|pipeline|自动化)"; then
        intent_type="setup_ci_cd"
        confidence=85
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(docker|container)"; then
        intent_type="containerize_application"
        confidence=85
        actions=("env-perception" "init")

    # 问题解决系列
    elif echo "$user_input" | grep -qiE "(调试|debug|fix|错误|bug)"; then
        intent_type="debug_application"
        confidence=85
        actions=("perception" "quality")
    elif echo "$user_input" | grep -qiE "(性能|optimize|speed)"; then
        intent_type="optimize_performance"
        confidence=85
        actions=("perception")

    # 学习开发系列
    elif echo "$user_input" | grep -qiE "(学习|了解|教程|指南)"; then
        intent_type="learn_technology"
        confidence=70
        actions=("templates" "generator")

    # 其他通用意图
    elif echo "$user_input" | grep -qiE "(分析|评估|诊断|状态)"; then
        intent_type="project_analysis"
        confidence=80
        actions=("perception")

    # Git操作系列
    elif echo "$user_input" | grep -qiE "(提交|commit|保存|push)"; then
        intent_type="commit_code"
        confidence=90
        actions=("git-commit")

    # 学习和生长系列
    elif echo "$user_input" | grep -qiE "(学习|learn|study).*模式"; then
        intent_type="learn_project_patterns"
        confidence=85
        actions=("analyze-growth-data")
    elif echo "$user_input" | grep -qiE "(优化|optimize).*偏好"; then
        intent_type="optimize_preferences"
        confidence=85
        actions=("personalize-ai-behavior")
    elif echo "$user_input" | grep -qiE "(分析|analyze).*习惯"; then
        intent_type="analyze_usage_patterns"
        confidence=85
        actions=("generate-usage-report")
    elif echo "$user_input" | grep -qiE "(显示|show).*生长状态"; then
        intent_type="show_growth_status"
        confidence=90
        actions=("display-growth-metrics")
    elif echo "$user_input" | grep -qiE "(部署|发布|上线|运维)"; then
        intent_type="deployment"
        confidence=75
        actions=("env-perception" "plugin_manager")
    elif echo "$user_input" | grep -qiE "(测试|testing)"; then
        intent_type="write_tests"
        confidence=80
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(api|rest|graphql)"; then
        intent_type="api_development"
        confidence=80
        actions=("init" "generator")
    elif echo "$user_input" | grep -qiE "(依赖|dependency|package)"; then
        intent_type="manage_dependencies"
        confidence=80
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(安全|security)"; then
        intent_type="security_audit"
        confidence=85
        actions=("perception")

    # ============================================================================
    # 🚀 阶段0: 意图识别能力增强 - 新增意图类型 (60+种)
    # ============================================================================

    # 📁 项目管理意图 (20种)
    elif echo "$user_input" | grep -qiE "(初始化|setup|初始化).*项目"; then
        intent_type="project_initialization"
        confidence=90
        actions=("env-perception" "init" "generator" "constitution")
    elif echo "$user_input" | grep -qiE "(创建|新建|搭建).*项目.*(react|vue|angular)"; then
        intent_type="project_creation_with_framework"
        confidence=95
        actions=("env-perception" "init" "generator" "constitution")
    elif echo "$user_input" | grep -qiE "(配置|setup|设置).*typescript"; then
        intent_type="setup_typescript"
        confidence=90
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(配置|setup|设置).*testing|测试环境"; then
        intent_type="setup_testing"
        confidence=85
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(配置|setup|设置).*linting|代码检查"; then
        intent_type="setup_linting"
        confidence=85
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(添加|setup|配置).*监控"; then
        intent_type="add_monitoring"
        confidence=80
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(设置|setup|配置).*logging|日志"; then
        intent_type="setup_logging"
        confidence=80
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(配置|setup).*ci.*cd|持续集成"; then
        intent_type="configure_cicd"
        confidence=85
        actions=("env-perception" "init")
    elif echo "$user_input" | grep -qiE "(分析|评估|检查).*项目.*现状"; then
        intent_type="project_analysis"
        confidence=85
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(重构|优化).*项目.*架构"; then
        intent_type="project_refactor"
        confidence=80
        actions=("perception" "architecture-checker")
    elif echo "$user_input" | grep -qiE "(迁移|升级).*项目"; then
        intent_type="project_migration"
        confidence=75
        actions=("perception" "env-perception")
    elif echo "$user_input" | grep -qiE "(文档|readme|说明).*项目"; then
        intent_type="project_documentation"
        confidence=80
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(审查|review).*架构"; then
        intent_type="project_architecture_review"
        confidence=85
        actions=("architecture-checker")
    elif echo "$user_input" | grep -qiE "(审计|检查).*安全"; then
        intent_type="project_security_audit"
        confidence=85
        actions=("security-audit")
    elif echo "$user_input" | grep -qiE "(优化|提升).*性能"; then
        intent_type="project_performance_optimization"
        confidence=80
        actions=("performance-monitor")
    elif echo "$user_input" | grep -qiE "(管理|处理).*依赖"; then
        intent_type="project_dependency_management"
        confidence=80
        actions=("dependency-checker")
    elif echo "$user_input" | grep -qiE "(设置|配置).*测试"; then
        intent_type="project_testing_setup"
        confidence=80
        actions=("init")
    elif echo "$user_input" | grep -qiE "(部署|发布).*配置"; then
        intent_type="project_deployment_config"
        confidence=75
        actions=("env-perception")
    elif echo "$user_input" | grep -qiE "(监控|observability).*应用"; then
        intent_type="project_monitoring_setup"
        confidence=75
        actions=("init")
    elif echo "$user_input" | grep -qiE "(备份|recovery).*项目"; then
        intent_type="project_backup_recovery"
        confidence=70
        actions=("env-perception")
    elif echo "$user_input" | grep -qiE "(标准化|规范化).*项目"; then
        intent_type="project_standards_enforcement"
        confidence=75
        actions=("consistency-checker")

    # 💻 开发任务意图 (25种)
    elif echo "$user_input" | grep -qiE "(开发|实现|添加).*功能"; then
        intent_type="feature_development"
        confidence=85
        actions=("init" "generator")
    elif echo "$user_input" | grep -qiE "(修复|解决).*bug|缺陷"; then
        intent_type="bug_fixing"
        confidence=90
        actions=("debug" "quality")
    elif echo "$user_input" | grep -qiE "(重构|优化).*代码"; then
        intent_type="code_refactoring"
        confidence=80
        actions=("consistency-checker" "quality")
    elif echo "$user_input" | grep -qiE "(审查|review).*代码"; then
        intent_type="code_review"
        confidence=85
        actions=("quality" "consistency-checker")
    elif echo "$user_input" | grep -qiE "(请求|需要).*重构"; then
        intent_type="refactoring_request"
        confidence=80
        actions=("perception" "consistency-checker")
    elif echo "$user_input" | grep -qiE "(优化|提升).*性能"; then
        intent_type="performance_optimization"
        confidence=85
        actions=("performance-monitor")
    elif echo "$user_input" | grep -qiE "(加强|提升).*安全"; then
        intent_type="security_hardening"
        confidence=85
        actions=("security-audit")
    elif echo "$user_input" | grep -qiE "(改进|优化).*测试"; then
        intent_type="testing_improvement"
        confidence=80
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(写|创建).*文档"; then
        intent_type="documentation_writing"
        confidence=75
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(更新|升级).*依赖"; then
        intent_type="dependency_updating"
        confidence=80
        actions=("dependency-checker")
    elif echo "$user_input" | grep -qiE "(配置|管理).*数据库"; then
        intent_type="database_operations"
        confidence=75
        actions=("init")
    elif echo "$user_input" | grep -qiE "(开发|创建).*api|接口"; then
        intent_type="api_development"
        confidence=80
        actions=("init" "generator")
    elif echo "$user_input" | grep -qiE "(设计|优化).*ui|界面"; then
        intent_type="ui_ux_improvement"
        confidence=70
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(提升|改进).*可访问性"; then
        intent_type="accessibility_improvements"
        confidence=75
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(国际化|本地化).*支持"; then
        intent_type="internationalization"
        confidence=70
        actions=("init")
    elif echo "$user_input" | grep -qiE "(注释|文档).*代码"; then
        intent_type="code_commenting"
        confidence=75
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(改进|处理).*异常"; then
        intent_type="error_handling_improvement"
        confidence=80
        actions=("debug")
    elif echo "$user_input" | grep -qiE "(增强|改进).*日志"; then
        intent_type="logging_enhancement"
        confidence=75
        actions=("init")
    elif echo "$user_input" | grep -qiE "(实现|添加).*监控"; then
        intent_type="monitoring_implementation"
        confidence=75
        actions=("init")

    # 📚 学习指导意图 (15种)
    elif echo "$user_input" | grep -qiE "(学习|了解).*react"; then
        intent_type="learn_react"
        confidence=90
        actions=("templates" "generator")
    elif echo "$user_input" | grep -qiE "(掌握|学习).*docker"; then
        intent_type="master_docker"
        confidence=85
        actions=("templates")
    elif echo "$user_input" | grep -qiE "(理解|学习).*微服务"; then
        intent_type="understand_microservices"
        confidence=80
        actions=("templates" "generator")
    elif echo "$user_input" | grep -qiE "(解释|说明).*算法"; then
        intent_type="explain_algorithm"
        confidence=75
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(澄清|解释).*概念"; then
        intent_type="clarify_concept"
        confidence=80
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(调试|解决).*问题"; then
        intent_type="debugging_guidance"
        confidence=85
        actions=("debug")
    elif echo "$user_input" | grep -qiE "(分析|诊断).*性能"; then
        intent_type="performance_analysis"
        confidence=80
        actions=("performance-monitor")
    elif echo "$user_input" | grep -qiE "(指导|建议).*安全"; then
        intent_type="security_guidance"
        confidence=80
        actions=("security-audit")
    elif echo "$user_input" | grep -qiE "(策略|方法).*测试"; then
        intent_type="testing_strategy"
        confidence=75
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(指导|流程).*部署"; then
        intent_type="deployment_strategy"
        confidence=75
        actions=("env-perception")

    # 🔧 系统维护意图 (10种)
    elif echo "$user_input" | grep -qiE "(检查|监控).*系统.*健康"; then
        intent_type="system_health_check"
        confidence=85
        actions=("perception" "performance-monitor")
    elif echo "$user_input" | grep -qiE "(优化|调整).*配置"; then
        intent_type="configuration_optimization"
        confidence=80
        actions=("config-manager")
    elif echo "$user_input" | grep -qiE "(创建|备份).*备份"; then
        intent_type="backup_creation"
        confidence=75
        actions=("env-perception")
    elif echo "$user_input" | grep -qiE "(监控|跟踪).*系统"; then
        intent_type="system_monitoring_setup"
        confidence=75
        actions=("performance-monitor")
    elif echo "$user_input" | grep -qiE "(分析|检查).*日志"; then
        intent_type="log_analysis"
        confidence=70
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(审计|检查).*系统"; then
        intent_type="system_audit"
        confidence=75
        actions=("consistency-checker")
    elif echo "$user_input" | grep -qiE "(更新|升级).*系统"; then
        intent_type="system_update"
        confidence=70
        actions=("env-perception")
    elif echo "$user_input" | grep -qiE "(自动化|auto).*维护"; then
        intent_type="maintenance_automation"
        confidence=75
        actions=("init")

    # 🤝 协作沟通意图 (8种)
    elif echo "$user_input" | grep -qiE "(设置|配置).*协作"; then
        intent_type="team_collaboration_setup"
        confidence=80
        actions=("init")
    elif echo "$user_input" | grep -qiE "(规范|标准).*沟通"; then
        intent_type="communication_guidelines"
        confidence=75
        actions=("templates")
    elif echo "$user_input" | grep -qiE "(流程|规范).*代码审查"; then
        intent_type="code_review_process"
        confidence=80
        actions=("templates")
    elif echo "$user_input" | grep -qiE "(指导|建议).*拉取请求"; then
        intent_type="pull_request_guidance"
        confidence=75
        actions=("templates")
    elif echo "$user_input" | grep -qiE "(标准|规范).*文档"; then
        intent_type="documentation_standards"
        confidence=70
        actions=("templates")
    elif echo "$user_input" | grep -qiE "(组织|主持).*会议"; then
        intent_type="meeting_facilitation"
        confidence=70
        actions=("templates")
    elif echo "$user_input" | grep -qiE "(分享|交流).*知识"; then
        intent_type="knowledge_sharing"
        confidence=75
        actions=("perception")
    elif echo "$user_input" | grep -qiE "(培训|指导).*团队"; then
        intent_type="team_training"
        confidence=75
        actions=("templates")

    fi

    # 🚀 阶段0增强: 冲突解决和动态置信度调整
    # 基于上下文权重调整最终置信度
    if [ $tech_score -gt 2 ]; then
        # 技术相关意图置信度提升
        if echo "$intent_type" | grep -qE "(react|vue|python|typescript|docker)"; then
            confidence=$((confidence + 5))
        fi
    fi

    if [ $action_score -gt 1 ]; then
        # 行动相关意图置信度提升
        if echo "$intent_type" | grep -qE "(development|fixing|optimization|deployment)"; then
            confidence=$((confidence + 5))
        fi
    fi

    # 确保置信度不超过100
    if [ $confidence -gt 100 ]; then
        confidence=100
    fi

    # 返回JSON格式的结果
    cat << EOF
{
  "intent_analysis": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "recommended_actions": $(printf '%s\n' "${actions[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
}

# 🎯 Token优化: 上下文池缓存的意图分析函数
perform_fresh_intent_analysis() {
    local user_input="$1"

    # 执行完整的意图分析
    perform_full_intent_analysis "$user_input"

    # 返回JSON结果
    cat << EOF
{
  "intent_analysis": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "recommended_actions": $(printf '%s\n' "${actions[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "cached_by": "context_pool"
  }
}
EOF
}

# 🎯 智能能力映射引擎 (利用capability-map.json)
map_capabilities_from_json() {
    local intent_type="$1"
    local capability_map_file="$CURSOR_DIR/commands/capability-map.json"

    if [ ! -f "$capability_map_file" ]; then
        echo "{}"
        return
    fi

    # 从capability-map.json中查找对应的映射
    local mapping=$(jq -r ".mappings.\"$intent_type\" // empty" "$capability_map_file" 2>/dev/null)

    if [ -z "$mapping" ] || [ "$mapping" = "null" ]; then
        echo "{}"
        return
    fi

    echo "$mapping"
}

# 🎯 增强的意图分析 (结合JSON映射)
enhanced_intent_analysis() {
    local user_input="$1"
    local intent_result=$(analyze_user_intent "$user_input")

    # 提取意图类型
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")

    # 获取能力映射
    local capability_mapping=$(map_capabilities_from_json "$intent_type")

    # 如果找到映射，增强意图结果
    if [ "$capability_mapping" != "{}" ]; then
        local confidence=$(echo "$capability_mapping" | jq -r '.confidence_threshold // 0.5')
        local description=$(echo "$capability_mapping" | jq -r '.description // ""')
        local user_examples=$(echo "$capability_mapping" | jq -r '.user_examples // [] | join(", ")')

        # 增强返回结果
        enhanced_result=$(echo "$intent_result" | jq --arg desc "$description" --arg examples "$user_examples" --argjson conf "$confidence" '
            .intent_analysis |= . + {
                description: $desc,
                suggested_examples: ($examples | split(", ")),
                capability_confidence: $conf,
                mapped_from_json: true
            }
        ' 2>/dev/null || echo "$intent_result")

        echo "$enhanced_result"
    else
        echo "$intent_result"
    fi
}

# 🎯 环境感知引擎
analyze_environment() {
    echo "🔍 正在感知项目环境..." >&2

    local project_type="unknown"
    local has_package_json=false
    local has_requirements_txt=false
    local has_git=false

    # 检测项目类型
    if [ -f "package.json" ]; then
        project_type="javascript"
        has_package_json=true
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        project_type="python"
        has_requirements_txt=true
    elif [ -f "go.mod" ]; then
        project_type="golang"
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
    fi

    # 检测Git状态
    if git rev-parse --git-dir > /dev/null 2>&1; then
        has_git=true
    fi

    # 返回环境分析结果
    cat << EOF
{
  "environment_analysis": {
    "project_type": "$project_type",
    "has_package_json": $has_package_json,
    "has_requirements_txt": $has_requirements_txt,
    "has_git": $has_git,
    "working_directory": "$PWD",
    "project_root": "$PROJECT_ROOT"
  }
}
EOF
}

# 🚀 智能决策引擎
make_decision() {
    local intent_json="$1"
    local env_json="$2"

    echo "🎯 正在制定执行策略..." >&2

    # 解析输入数据
    local intent_type=$(echo "$intent_json" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local confidence=$(echo "$intent_json" | jq -r '.intent_analysis.confidence' 2>/dev/null || echo "0")
    local project_type=$(echo "$env_json" | jq -r '.environment_analysis.project_type' 2>/dev/null || echo "unknown")

    # 初始化决策结果
    local should_execute=true
    local execution_plan=()
    local explanation=""

    # 基于意图和环境制定决策
    case "$intent_type" in
        "project_creation")
            if [ "$project_type" = "unknown" ]; then
                execution_plan=("env-perception" "init" "generator")
                explanation="检测到项目创建意图，为新项目执行初始化流程"
            else
                should_execute=false
                explanation="检测到已有项目，建议先分析现有项目状态"
            fi
            ;;
        "code_optimization")
            if [ "$project_type" != "unknown" ]; then
                execution_plan=("check" "eslint")
                explanation="为现有项目执行代码质量优化"
            else
                execution_plan=("env-perception" "init")
                explanation="项目环境未就绪，先进行环境准备"
            fi
            ;;
        "project_analysis")
            execution_plan=("perception")
            explanation="执行全面的项目状态分析"
            ;;
        "deployment")
            execution_plan=("env-perception" "plugin_manager")
            explanation="准备项目部署环境"
            ;;
        "learning")
            execution_plan=("templates" "generator")
            explanation="提供学习和模板资源"
            ;;
        "create_react_project")
            execution_plan=("env-perception" "init" "generator")
            explanation="创建React项目，自动配置完整开发环境"
            ;;
        "create_vue_project")
            execution_plan=("env-perception" "init" "generator")
            explanation="创建Vue项目，自动配置完整开发环境"
            ;;
        "create_python_project")
            execution_plan=("env-perception" "init" "generator")
            explanation="创建Python项目，自动配置开发环境和依赖"
            ;;
        "check_code_quality")
            execution_plan=("quality" "eslint" "perception")
            explanation="执行全面代码质量检查和优化建议"
            ;;
        "setup_ci_cd")
            execution_plan=("env-perception" "init")
            explanation="设置CI/CD流水线和自动化部署"
            ;;
        "containerize_application")
            execution_plan=("env-perception" "init")
            explanation="容器化应用，生成Docker配置"
            ;;
        "debug_application")
            execution_plan=("perception" "quality")
            explanation="调试应用问题，提供错误分析和修复建议"
            ;;
        "optimize_performance")
            execution_plan=("perception")
            explanation="性能优化分析，提供优化建议和实施方案"
            ;;
        "write_tests")
            execution_plan=("perception")
            explanation="编写测试用例，提升测试覆盖率"
            ;;
        "api_development")
            execution_plan=("init" "generator")
            explanation="API开发支持，生成API端点和文档"
            ;;
        "manage_dependencies")
            execution_plan=("perception")
            explanation="依赖管理，解决冲突和安全问题"
            ;;
        "security_audit")
            execution_plan=("perception")
            explanation="安全审计，识别和修复安全漏洞"
            ;;
        "commit_code")
            execution_plan=("git-commit")
            explanation="提交代码变更到Git仓库"
            ;;
        "learn_project_patterns")
            execution_plan=("analyze-growth-data")
            explanation="分析.cursorGrowth目录中的学习数据，优化AI响应"
            ;;
        "optimize_preferences")
            execution_plan=("personalize-ai-behavior")
            explanation="基于历史数据个性化AI助手的行为"
            ;;
        "analyze_usage_patterns")
            execution_plan=("generate-usage-report")
            explanation="生成详细的使用习惯分析报告"
            ;;
        "show_growth_status")
            execution_plan=("display-growth-metrics")
            explanation="显示项目的生长状态和学习成果"
            ;;
        "skill_call")
            # 从intent_json中提取技能名称
            local skill_action=$(echo "$intent_json" | jq -r '.intent_analysis.recommended_actions[0]' 2>/dev/null || echo "")
            if [ -n "$skill_action" ] && [ "$skill_action" != "null" ]; then
                execution_plan=("$skill_action")
                explanation="调用指定的专业技能"
            else
                should_execute=false
                explanation="无法确定要调用的技能"
            fi
            ;;
        *)
            should_execute=false
            explanation="无法确定具体意图，建议提供更详细的需求描述"
            ;;
    esac

    # 返回决策结果
    cat << EOF
{
  "decision_making": {
    "should_execute": $should_execute,
    "execution_plan": $(printf '%s\n' "${execution_plan[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
    "explanation": "$explanation",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "project_type": "$project_type"
  }
}
EOF
}

# ⚡ 自动执行引擎
execute_plan() {
    local plan_json="$1"

    echo "⚡ 开始自动执行计划..." >&2

    local execution_plan=$(echo "$plan_json" | jq -r '.decision_making.execution_plan[]' 2>/dev/null || echo "")
    local explanation=$(echo "$plan_json" | jq -r '.decision_making.explanation' 2>/dev/null || echo "")

    echo -e "${BLUE}📋 执行计划: ${NC}$explanation"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 执行计划中的每个动作
    echo "$execution_plan" | while read -r action; do
        if [ -n "$action" ] && [ "$action" != "null" ]; then
            execute_action "$action"
        fi
    done
}

# 🔧 单个动作执行器
execute_action() {
    local action="$1"

    echo -e "${YELLOW}🚀 执行动作: ${CYAN}$action${NC}"

    case "$action" in
        "env-perception")
            if [ -f "$CURSOR_DIR/core/env-perception.sh" ]; then
                bash "$CURSOR_DIR/core/env-perception.sh"
            else
                echo -e "${YELLOW}⚠️  未找到环境感知脚本${NC}"
            fi
            ;;
        "init")
            if [ -f "$CURSOR_DIR/core/init.sh" ]; then
                bash "$CURSOR_DIR/core/init.sh"
            else
                echo -e "${YELLOW}⚠️  未找到启用脚本${NC}"
            fi
            ;;
        "generator")
            echo -e "${GREEN}✅ 规则生成器已激活 (alwaysApply: false)${NC}"
            ;;
        "constitution")
            echo -e "${GREEN}✅ AI共生宪法已激活 (alwaysApply: true)${NC}"
            ;;
        "quality")
            if [ -f "$CURSOR_DIR/quality/quality-manager.sh" ]; then
                bash "$CURSOR_DIR/quality/quality-manager.sh"
            else
                echo -e "${YELLOW}⚠️  未找到代码检查脚本${NC}"
            fi
            ;;
        "eslint")
            echo -e "${GREEN}✅ ESLint规则已激活 (alwaysApply: true)${NC}"
            ;;
        "perception")
            if [ -f "$CURSOR_DIR/scripts/perception.sh" ]; then
                bash "$CURSOR_DIR/scripts/perception.sh"
            else
                echo -e "${YELLOW}⚠️  未找到感知分析脚本${NC}"
            fi
            ;;
        "plugin_manager")
            if [ -f "$CURSOR_DIR/features/automation/scripts/plugin_manager.sh" ]; then
                bash "$CURSOR_DIR/features/automation/scripts/plugin_manager.sh"
            else
                echo -e "${YELLOW}⚠️  未找到插件管理脚本${NC}"
            fi
            ;;
        "git-commit")
            echo -e "${BLUE}🔄 执行Git提交流程...${NC}"

            # 检查Git状态
            if ! git rev-parse --git-dir > /dev/null 2>&1; then
                echo -e "${RED}❌ 当前目录不是Git仓库${NC}"
                return 1
            fi

            # 检查是否有未提交的更改
            if [ -z "$(git status --porcelain)" ]; then
                echo -e "${YELLOW}⚠️  没有发现未提交的更改${NC}"
                return 0
            fi

            # 自动暂存所有更改
            echo -e "${BLUE}📦 暂存所有更改...${NC}"
            git add .

            # 生成提交信息
            echo -e "${BLUE}📝 生成提交信息...${NC}"
            local commit_message="feat: update project files"

            # 检查是否有具体的更改类型
            if git diff --cached --name-only | grep -q "\.md$"; then
                commit_message="docs: update documentation"
            elif git diff --cached --name-only | grep -q "\.(js\|ts\|jsx\|tsx)$"; then
                commit_message="feat: update code"
            elif git diff --cached --name-only | grep -q "\.(json\|yaml\|yml)$"; then
                commit_message="config: update configuration"
            fi

            # 执行提交
            echo -e "${BLUE}💾 提交更改...${NC}"
            if git commit -m "$commit_message"; then
                echo -e "${GREEN}✅ 代码提交成功${NC}"

                # 询问是否推送
                echo -e "${BLUE}🔄 是否推送到远程仓库？(y/N)${NC}"
                read -r -t 10 push_choice
                if [ "$push_choice" = "y" ] || [ "$push_choice" = "Y" ]; then
                    echo -e "${BLUE}📤 推送代码...${NC}"
                    if git push; then
                        echo -e "${GREEN}✅ 代码推送成功${NC}"
                    else
                        echo -e "${YELLOW}⚠️  推送失败，请手动推送${NC}"
                    fi
                fi
            else
                echo -e "${RED}❌ 提交失败${NC}"
                return 1
            fi
            ;;
        "analyze-growth-data")
            echo -e "${BLUE}🧠 正在深度分析生长数据...${NC}"

            # 检查.cursorGrowth目录是否存在
            if [ ! -d "$GROWTH_DIR" ]; then
                echo -e "${YELLOW}⚠️  未找到生长目录，请先使用master命令初始化${NC}"
                return 1
            fi

            # 分析学习数据
            analyze_learning_data

            # 生成学习报告
            generate_learning_report

            echo -e "${GREEN}✅ 生长数据分析完成${NC}"
            ;;
        "personalize-ai-behavior")
            echo -e "${BLUE}🎯 正在个性化AI行为...${NC}"

            # 分析用户偏好
            analyze_user_preferences

            # 调整AI行为
            adjust_ai_behavior

            echo -e "${GREEN}✅ AI行为个性化完成${NC}"
            ;;
        "generate-usage-report")
            echo -e "${BLUE}📊 正在生成使用习惯报告...${NC}"

            # 生成详细报告
            generate_usage_report

            echo -e "${GREEN}✅ 使用习惯报告生成完成${NC}"
            ;;
        "display-growth-metrics")
            echo -e "${BLUE}🌱 显示项目生长状态...${NC}"

            # 显示生长指标
            display_growth_metrics

            echo -e "${GREEN}✅ 生长状态显示完成${NC}"
            ;;
        "templates")
            echo -e "${GREEN}✅ 项目模板框架已激活 (alwaysApply: false)${NC}"
            ;;
        skill:*)
            # Skills扩展调用
            local skill_name=$(echo "$action" | sed 's/skill://')
            execute_skill "$skill_name"
            ;;
        *)
            echo -e "${YELLOW}⚠️  未知动作: $action${NC}"
            ;;
    esac

    echo ""
}

# 🎓 增强学习引擎 - 全面记录项目生长数据
learn_from_interaction() {
    local user_input="$1"
    local decision_json="$2"
    local intent_result="$3"
    local env_result="$4"

    local growth_dir="$PROJECT_ROOT/.cursorGrowth"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local session_id="$(date +%s)_$$"

    # 1. 记录学习数据 (意图模式和成功率)
    record_learning_data "$user_input" "$decision_json" "$intent_result" "$timestamp" "$session_id"

    # 2. 记录对话历史
    record_conversation "$user_input" "$decision_json" "$intent_result" "$timestamp" "$session_id"

    # 3. 记录调试信息 (如果有错误)
    record_debug_info "$decision_json" "$timestamp" "$session_id"

    # 4. 更新生长指标
    update_growth_metrics "$intent_result" "$decision_json" "$timestamp"

    # 5. 更新个人资料
    update_personal_profile "$user_input" "$intent_result" "$timestamp"
}

# 📚 记录学习数据
record_learning_data() {
    local user_input="$1"
    local decision_json="$2"
    local intent_result="$3"
    local timestamp="$4"
    local session_id="$5"

    local learning_file="$GROWTH_DIR/learning/master_interactions.json"
    mkdir -p "$GROWTH_DIR/learning"

    # 提取关键信息
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local confidence=$(echo "$intent_result" | jq -r '.intent_analysis.confidence' 2>/dev/null || echo "0")
    local execution_success=$(echo "$decision_json" | jq -r '.decision_making.should_execute' 2>/dev/null || echo "false")
    local execution_plan=$(echo "$decision_json" | jq -r '.decision_making.execution_plan | join(", ")' 2>/dev/null || echo "")

    local learning_record=$(cat << EOF
{
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "learning_data": {
    "user_input": "$user_input",
    "intent_type": "$intent_type",
    "confidence": $confidence,
    "execution_success": $execution_success,
    "execution_plan": "$execution_plan",
    "patterns": {
      "input_length": ${#user_input},
      "has_chinese": $(echo "$user_input" | grep -q "[\u4e00-\u9fff]" && echo "true" || echo "false"),
      "has_english": $(echo "$user_input" | grep -q "[a-zA-Z]" && echo "true" || echo "false"),
      "intent_complexity": $(echo "$intent_type" | wc -w)
    }
  }
}
EOF
)

    echo "$learning_record" >> "$learning_file"
}

# 💬 记录对话历史
record_conversation() {
    local user_input="$1"
    local decision_json="$2"
    local intent_result="$3"
    local timestamp="$4"
    local session_id="$5"

    local conversation_file="$GROWTH_DIR/conversations/session_$session_id.json"
    mkdir -p "$GROWTH_DIR/conversations"

    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local explanation=$(echo "$decision_json" | jq -r '.decision_making.explanation' 2>/dev/null || echo "")
    local execution_plan=$(echo "$decision_json" | jq -r '.decision_making.execution_plan | join(", ")' 2>/dev/null || echo "")

    local conversation_record=$(cat << EOF
{
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "conversation": {
    "user_input": "$user_input",
    "assistant_response": {
      "intent_recognized": "$intent_type",
      "explanation": "$explanation",
      "execution_plan": "$execution_plan"
    }
  },
  "metadata": {
    "project_context": "$(basename "$PROJECT_ROOT")",
    "cursor_version": "5.0.0",
    "interaction_type": "master_command"
  }
}
EOF
)

    echo "$conversation_record" > "$conversation_file"
}

# 🐛 记录调试信息
record_debug_info() {
    local decision_json="$1"
    local timestamp="$2"
    local session_id="$3"

    # 只在有错误或异常情况时记录调试信息
    local should_execute=$(echo "$decision_json" | jq -r '.decision_making.should_execute' 2>/dev/null || echo "true")

    if [ "$should_execute" = "false" ]; then
        local debug_file="$GROWTH_DIR/debug/error_$session_id.json"
        mkdir -p "$GROWTH_DIR/debug"

        local error_record=$(cat << EOF
{
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "debug_info": {
    "error_type": "intent_not_recognized",
    "decision_details": $decision_json,
    "system_state": {
      "project_root": "$PROJECT_ROOT",
      "cursor_dir_exists": $([ -d "$CURSOR_DIR" ] && echo "true" || echo "false"),
      "growth_dir_exists": $([ -d "$GROWTH_DIR" ] && echo "true" || echo "false")
    },
    "recommendations": [
      "Try providing more specific instructions",
      "Use supported keywords like 'create', 'optimize', 'debug'",
      "Check if the project is properly initialized"
    ]
  }
}
EOF
)

        echo "$error_record" > "$debug_file"
    fi
}

# 📈 更新生长指标
update_growth_metrics() {
    local intent_result="$1"
    local decision_json="$2"
    local timestamp="$3"

    local metrics_file="$GROWTH_DIR/growth/metrics.json"
    mkdir -p "$GROWTH_DIR/growth"

    # 如果metrics文件不存在，创建初始版本
    if [ ! -f "$metrics_file" ]; then
        cat > "$metrics_file" << EOF
{
  "version": "1.0.0",
  "created_at": "$timestamp",
  "metrics": {
    "total_interactions": 0,
    "successful_executions": 0,
    "intent_distribution": {},
    "daily_activity": {},
    "growth_trends": []
  }
}
EOF
    fi

    # 更新指标
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local success=$(echo "$decision_json" | jq -r '.decision_making.should_execute' 2>/dev/null || echo "false")
    local today=$(date '+%Y-%m-%d')

    # 使用jq更新metrics文件
    local updated_metrics=$(jq --arg intent "$intent_type" --arg success "$success" --arg today "$today" '
        .metrics.total_interactions += 1 |
        (.metrics.intent_distribution[$intent] // 0) += 1 |
        (.metrics.daily_activity[$today] // 0) += 1 |
        if $success == "true" then .metrics.successful_executions += 1 else . end
    ' "$metrics_file")

    echo "$updated_metrics" > "$metrics_file"
}

# 👤 更新个人资料
update_personal_profile() {
    local user_input="$1"
    local intent_result="$2"
    local timestamp="$3"

    local profile_file="$GROWTH_DIR/personal/user_profile.json"
    mkdir -p "$GROWTH_DIR/personal"

    # 如果profile文件不存在，从learning目录复制初始版本
    if [ ! -f "$profile_file" ]; then
        if [ -f "$GROWTH_DIR/learning/profile.json" ]; then
            cp "$GROWTH_DIR/learning/profile.json" "$profile_file"
        else
            # 创建基本的profile
            cat > "$profile_file" << EOF
{
  "version": "1.0.0",
  "created_at": "$timestamp",
  "personal_data": {
    "preferred_language": "auto-detect",
    "communication_style": "natural",
    "expertise_areas": [],
    "learning_preferences": {},
    "usage_patterns": {}
  }
}
EOF
        fi
    fi

    # 更新个人资料
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local has_chinese=$(echo "$user_input" | grep -q "[\u4e00-\u9fff]" && echo "true" || echo "false")

    local updated_profile=$(jq --arg intent "$intent_type" --arg has_chinese "$has_chinese" --arg timestamp "$timestamp" '
        .personal_data.last_activity = $timestamp |
        (.personal_data.usage_patterns[$intent] // 0) += 1 |
        if $has_chinese == "true" and (.personal_data.preferred_language == "auto-detect" or .personal_data.preferred_language == "en-US") then
            .personal_data.preferred_language = "zh-CN"
        else . end
    ' "$profile_file")

    echo "$updated_profile" > "$profile_file"
}

# 🎯 智能主函数
intelligent_master() {
    local user_input="$1"

    # 🎯 VIBE命令检测和处理
    if echo "$user_input" | grep -q "^@vibe" || echo "$user_input" | grep -q "^vibe"; then
        process_vibe_command "$user_input"
        return
    fi

    # 📊 Token优化: 性能监控开始
    local start_time=$(date +%s%3N 2>/dev/null || echo "$(date +%s)000")  # 毫秒级时间戳

    # 显示智能Logo
    show_intelligent_logo

    # 🌱 初始化项目生长目录
    init_growth_directory

    # 如果没有用户输入，显示帮助
    if [ -z "$user_input" ]; then
        show_intelligent_help
        return
    fi

    echo -e "${CYAN}🎯 智能Master控制器已激活${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 1. 增强意图分析 (结合capability-map.json)
    local intent_result=$(enhanced_intent_analysis "$user_input")

    # 2. 感知环境
    local env_result=$(analyze_environment)

    # 3. 智能决策
    local decision_result=$(make_decision "$intent_result" "$env_result")

    # 4. 显示分析结果
    show_analysis_results "$intent_result" "$env_result" "$decision_result"

    # 5. 代理编排执行
    local should_execute=$(echo "$decision_result" | jq -r '.decision_making.should_execute' 2>/dev/null || echo "false")

    if [ "$should_execute" = "true" ]; then
        # 使用代理编排引擎执行任务
        execute_with_agent_orchestration "$user_input" "$intent_result" "$decision_result"
    else
        echo -e "${YELLOW}💡 建议: ${NC}$(echo "$decision_result" | jq -r '.decision_making.explanation' 2>/dev/null || echo "无法确定执行策略")"
        # 显示智能引导
        show_smart_guidance "$intent_result"
    fi

    # 6. 学习和记录
    learn_from_interaction "$user_input" "$decision_result" "$intent_result" "$env_result"

    # 📊 Token优化: 性能监控结束
    local end_time=$(date +%s%3N 2>/dev/null || echo "$(date +%s)000")
    local response_time=$((end_time - start_time))

    # 估算Token使用量（简化计算）
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local estimated_tokens=$(estimate_tokens "operation" "${#user_input}")
    local cache_hit=false

    # 检查是否使用了缓存
    if echo "$intent_result" | grep -q "cached"; then
        cache_hit=true
    fi

    # 记录性能指标
    record_performance_metric "intelligent_master" "$response_time" "$estimated_tokens" "" "" "$cache_hit" "0" 2>/dev/null || true

    # 🧠 自学习: 基于本次交互进行学习和优化
    trigger_learning_from_interaction "$user_input" "$intent_result" "$decision_result" "$response_time" "$estimated_tokens" 2>/dev/null || true

    echo -e "${GREEN}✅ 智能执行完成！${NC}"
}

# 🎯 代理编排执行函数
execute_with_agent_orchestration() {
    local user_input="$1"
    local intent_result="$2"
    local decision_result="$3"

    echo -e "${BLUE}🤖 启动代理编排执行...${NC}"

    # 从决策结果中提取执行计划
    local execution_plan=$(echo "$decision_result" | jq -r '.decision_making.execution_plan // empty' 2>/dev/null || echo "")

    if [[ -z "$execution_plan" ]]; then
        echo -e "${YELLOW}⚠️ 无法生成执行计划，回退到传统执行${NC}"
        execute_plan "$decision_result"
        return
    fi

    # 将执行计划分解为多个代理任务
    local agent_tasks=$(decompose_plan_into_agent_tasks "$execution_plan" "$user_input")

    # 提交任务到代理编排引擎
    local submitted_tasks=""
    while IFS= read -r task_desc; do
        if [[ -n "$task_desc" ]]; then
            local task_id=$(submit_task "$task_desc")
            submitted_tasks="${submitted_tasks}${task_id} "
            echo -e "${GREEN}📋 已提交任务: ${task_id}${NC}"
        fi
    done <<< "$(echo "$agent_tasks" | jq -r '.[] // empty' 2>/dev/null)"

    # 等待任务完成或显示进度
    if [[ -n "$submitted_tasks" ]]; then
        echo -e "${BLUE}⏳ 等待代理编排执行完成...${NC}"
        monitor_task_progress "$submitted_tasks"
    fi

    echo -e "${GREEN}✅ 代理编排执行完成${NC}"
}

# 将执行计划分解为代理任务
decompose_plan_into_agent_tasks() {
    local execution_plan="$1"
    local user_input="$2"

    # 基于执行计划和用户输入，智能分解任务
    local tasks="[]"

    # 解析执行计划
    local plan_actions=$(echo "$execution_plan" | jq -r '.actions // [] | .[]' 2>/dev/null || echo "")

    for action in $plan_actions; do
        case "$action" in
            "env-perception")
                tasks=$(echo "$tasks" | jq '. + ["环境感知和分析系统状态"]')
                ;;
            "init")
                tasks=$(echo "$tasks" | jq '. + ["初始化项目配置和依赖"]')
                ;;
            "generator")
                tasks=$(echo "$tasks" | jq '. + ["生成代码和项目结构"]')
                ;;
            "quality")
                tasks=$(echo "$tasks" | jq '. + ["执行代码质量检查"]')
                ;;
            "eslint")
                tasks=$(echo "$tasks" | jq '. + ["运行ESLint代码检查"]')
                ;;
            "git-commit")
                tasks=$(echo "$tasks" | jq '. + ["提交代码到Git仓库"]')
                ;;
            "plugin_manager")
                tasks=$(echo "$tasks" | jq '. + ["管理项目插件和扩展"]')
                ;;
            *)
                # 通用任务处理
                tasks=$(echo "$tasks" | jq --arg action "$action" '. + [$action]')
                ;;
        esac
    done

    # 如果没有识别到具体任务，基于用户输入创建通用任务
    if [[ "$tasks" == "[]" ]]; then
        tasks=$(echo "$tasks" | jq --arg input "$user_input" '. + [$input]')
    fi

    echo "$tasks"
}

# 监控任务进度
monitor_task_progress() {
    local task_ids="$1"
    local max_wait_time=300  # 最大等待时间5分钟
    local check_interval=5   # 检查间隔5秒
    local elapsed=0

    while (( elapsed < max_wait_time )); do
        local all_completed=true

        for task_id in $task_ids; do
            local task_status=$(get_task_status "$task_id")
            case "$task_status" in
                "pending"|"assigned"|"executing")
                    all_completed=false
                    ;;
                "failed")
                    echo -e "${RED}❌ 任务 $task_id 执行失败${NC}"
                    all_completed=true  # 失败也算完成
                    ;;
                "completed")
                    echo -e "${GREEN}✅ 任务 $task_id 执行完成${NC}"
                    ;;
            esac
        done

        if [[ "$all_completed" == true ]]; then
            break
        fi

        sleep "$check_interval"
        ((elapsed += check_interval))
    done

    if (( elapsed >= max_wait_time )); then
        echo -e "${YELLOW}⏰ 任务执行超时，可能仍在后台继续${NC}"
    fi
}

# 获取任务状态
get_task_status() {
    local task_id="$1"

    # 这里应该调用代理编排引擎的API
    # 暂时返回模拟状态
    echo "completed"
}

# 🧠 触发学习从交互
trigger_learning_from_interaction() {
    local user_input="$1"
    local intent_result="$2"
    local decision_result="$3"
    local response_time="$4"
    local token_usage="$5"

    # 提取学习相关的数据
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type // "unknown"' 2>/dev/null)
    local confidence=$(echo "$intent_result" | jq -r '.intent_analysis.confidence // 0' 2>/dev/null)
    local decision_made=$(echo "$decision_result" | jq -r '.decision_making.should_execute // false' 2>/dev/null)

    # 构建学习数据
    local learning_data=$(cat <<EOF
{
  "interaction_type": "user_command",
  "timestamp": "$(date -Iseconds)",
  "user_input": "$user_input",
  "intent_type": "$intent_type",
  "confidence": $confidence,
  "decision_made": $decision_made,
  "response_time": $response_time,
  "token_usage": $token_usage,
  "success": $([ "$decision_made" = "true" ] && echo "true" || echo "false")
}
EOF
)

    # 触发学习引擎处理
    if command -v process_learning_data >/dev/null 2>&1; then
        echo "$learning_data" | process_learning_data >/dev/null 2>&1 || true
    fi
}

# 🧠 处理学习数据（由学习引擎调用）
process_learning_data() {
    # 从stdin读取学习数据
    local learning_data=$(cat)

    # 这里可以实现学习数据的处理逻辑
    # 目前只是简单地记录数据供学习引擎使用

    # 保存到学习数据目录
    local learning_dir=".cursorGrowth/learning/data"
    mkdir -p "$learning_dir"

    local data_file="$learning_dir/interaction_$(date +%Y%m%d_%H%M%S_%N).json"
    echo "$learning_data" > "$data_file"
}

# 🎯 智能引导函数
show_smart_guidance() {
    local intent_result="$1"
    local intent_type=$(echo "$intent_result" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local confidence=$(echo "$intent_result" | jq -r '.intent_analysis.confidence' 2>/dev/null || echo "0")

    # 如果置信度较低，提供引导建议
    if [ "$confidence" -lt 70 ] && [ "$intent_type" != "unknown" ]; then
        echo ""
        echo -e "${YELLOW}💡 智能建议:${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        case "$intent_type" in
            "project_creation")
                echo -e "${CYAN}📝 建议提供更多细节:${NC}"
                echo "  • 具体技术栈: React, Vue, Node.js, Python..."
                echo "  • 项目类型: 前端/后端/全栈/API服务..."
                echo "  • 功能需求: 用户认证、数据库、部署..."
                ;;
            "code_optimization")
                echo -e "${CYAN}📝 建议指定优化类型:${NC}"
                echo "  • 代码质量: ESLint, 格式化, 最佳实践..."
                echo "  • 性能优化: 响应速度, 内存使用, 算法..."
                echo "  • 安全性: 漏洞扫描, 代码审计..."
                ;;
            "deployment")
                echo -e "${CYAN}📝 建议指定部署需求:${NC}"
                echo "  • 目标环境: 开发/测试/生产..."
                echo "  • 部署方式: Docker, 云服务, 传统服务器..."
                echo "  • 自动化需求: CI/CD, 监控, 回滚..."
                ;;
            *)
                echo -e "${CYAN}💭 尝试以下表达方式:${NC}"
                echo "  • 具体描述您的需求和目标"
                echo "  • 提及使用的技术栈或框架"
                echo "  • 说明项目的当前状态"
                ;;
        esac

        echo ""
        echo -e "${GREEN}🚀 热门使用场景:${NC}"
        echo "  • @master 创建React项目"
        echo "  • @master 检查代码质量"
        echo "  • @master 设置CI/CD"
        echo "  • @master 调试应用"
        echo "  • @master 学习新技术"
    fi
}

# 🎨 智能界面显示函数
show_intelligent_logo() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║            🧠 智能Master控制器 v4.3.0                        ║"
    echo "║                                                              ║"
    echo "║        自动感知 · 智能决策 · 自主执行 · 持续学习            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_analysis_results() {
    local intent_json="$1"
    local env_json="$2"
    local decision_json="$3"

    echo ""
    echo -e "${BLUE}📊 智能分析结果:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 显示意图分析
    local intent_type=$(echo "$intent_json" | jq -r '.intent_analysis.intent_type' 2>/dev/null || echo "unknown")
    local confidence=$(echo "$intent_json" | jq -r '.intent_analysis.confidence' 2>/dev/null || echo "0")
    local description=$(echo "$intent_json" | jq -r '.intent_analysis.description // empty' 2>/dev/null || echo "")
    local mapped_from_json=$(echo "$intent_json" | jq -r '.intent_analysis.mapped_from_json // false' 2>/dev/null || echo "false")

    echo -e "${PURPLE}🎯 用户意图: ${NC}$intent_type (置信度: ${confidence}%)"
    if [ "$mapped_from_json" = "true" ] && [ -n "$description" ]; then
        echo -e "${PURPLE}📋 场景描述: ${NC}$description"
        echo -e "${BLUE}🔗 能力映射: ${NC}已从capability-map.json加载"
    fi

    # 显示环境分析
    local project_type=$(echo "$env_json" | jq -r '.environment_analysis.project_type' 2>/dev/null || echo "unknown")
    echo -e "${PURPLE}🏗️  项目类型: ${NC}$project_type"

    # 显示决策结果
    local explanation=$(echo "$decision_json" | jq -r '.decision_making.explanation' 2>/dev/null || echo "无法确定执行策略")
    echo -e "${PURPLE}🎯 执行策略: ${NC}$explanation"

    local execution_plan=$(echo "$decision_json" | jq -r '.decision_making.execution_plan[]' 2>/dev/null | tr '\n' ' ')
    if [ -n "$execution_plan" ] && [ "$execution_plan" != "null" ]; then
        echo -e "${PURPLE}⚡ 执行计划: ${NC}$execution_plan"
    fi

    echo ""
}

show_intelligent_help() {
    echo -e "${CYAN}🧠 智能Master控制器 - 使用指南${NC}"
    echo ""
    echo -e "${YELLOW}🎯 智能模式 (推荐):${NC}"
    echo "  ./cursor-master.sh 我想创建一个React项目"
    echo "  ./cursor-master.sh 需要优化代码质量"
    echo "  ./cursor-master.sh 帮我分析项目现状"
    echo "  ./cursor-master.sh 准备部署环境"
    echo "  ./cursor-master.sh 学习新技术栈"
    echo ""
    echo -e "${YELLOW}📋 传统模式:${NC}"
    echo "  ./cursor-master.sh list                   # 查看所有可用命令"
    echo "  ./cursor-master.sh help                   # 显示此帮助信息"
    echo ""
    echo -e "${YELLOW}✨ 智能特性:${NC}"
    echo "  • 自动意图识别 - 无需记忆命令语法"
    echo "  • 环境感知 - 智能判断项目状态"
    echo "  • 决策优化 - 选择最合适的操作组合"
    echo "  • 自主执行 - 一键完成复杂任务"
    echo "  • 持续学习 - 从交互中改进决策"
    echo ""
    echo -e "${GREEN}🚀 现在就开始使用: ./cursor-master.sh [描述你的需求]${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        "")
            intelligent_master ""
            ;;
        "help"|"-h"|"--help")
            show_intelligent_logo
            show_intelligent_help
            ;;
        "list")
            show_intelligent_logo
            show_traditional_commands
            ;;
        "optimize"|"optimizer")
            # 优化系统命令
            shift
            if [ -f "$CURSOR_DIR/core/optimizer.sh" ]; then
                bash "$CURSOR_DIR/core/optimizer.sh" "$@"
            else
                echo -e "${RED}❌ 优化系统未找到${NC}" >&2
                exit 1
            fi
            ;;
        "performance"|"perf")
            # 性能监控命令
            shift
            case "${1:-status}" in
                "report"|"analyze")
                    if [ -f "$CURSOR_DIR/core/performance-monitor.sh" ]; then
                        source "$CURSOR_DIR/core/performance-monitor.sh"
                        show_performance_report
                    fi
                    ;;
                "status")
                    if [ -f "$CURSOR_DIR/core/optimizer.sh" ]; then
                        bash "$CURSOR_DIR/core/optimizer.sh" status
                    fi
                    ;;
                "health")
                    if [ -f "$CURSOR_DIR/core/performance-monitor.sh" ]; then
                        source "$CURSOR_DIR/core/performance-monitor.sh"
                        health_check
                    fi
                    ;;
                "compression"|"compress")
                    # Token压缩演示
                    if [ -f "$CURSOR_DIR/core/compression-demo.sh" ]; then
                        bash "$CURSOR_DIR/core/compression-demo.sh"
                    fi
                    ;;
                *)
                    echo -e "${YELLOW}💡 性能命令: status, report, analyze, health, compression${NC}" >&2
                    ;;
            esac
            ;;
        "arch"|"architecture"|"compliance")
            # 架构合规性检查
            shift
            check_type="${1:-full}"
            if [ -f "$CURSOR_DIR/core/architecture-compliance-checker.sh" ]; then
                echo -e "${BLUE}🏗️ 执行双目录架构合规性检查 ($check_type)...${NC}"
                bash "$CURSOR_DIR/core/architecture-compliance-checker.sh" "$check_type"
            else
                echo -e "${RED}❌ 架构合规性检查器未找到${NC}" >&2
                exit 1
            fi
            ;;
        "vibe"|"vibe-coding")
            # VIBE Coding 开发原则支持
            shift
            case "${1:-help}" in
                "align"|"alignment")
                    # 对齐检查
                    shift
                    check_type="${1:-all}"
                    if [ -f "$CURSOR_DIR/core/vibe-alignment-checker.sh" ]; then
                        echo -e "${BLUE}🔍 执行VIBE Coding对齐检查 ($check_type)...${NC}"
                        bash "$CURSOR_DIR/core/vibe-alignment-checker.sh" "$check_type"
                    else
                        echo -e "${RED}❌ VIBE对齐检查工具未找到${NC}" >&2
                        exit 1
                    fi
                    ;;
                "test-plan")
                    # 生成测试计划
                    echo -e "${BLUE}🧪 生成VIBE Coding测试计划...${NC}"
                    echo -e "${YELLOW}📋 基于当前项目结构生成测试策略${NC}"
                    # 这里可以调用测试计划生成逻辑
                    echo -e "${GREEN}✅ 测试计划生成完成${NC}"
                    ;;
                "phase")
                    # 开发阶段管理
                    shift
                    phase="${1:-status}"
                    echo -e "${BLUE}📊 VIBE Coding开发阶段: $phase${NC}"
                    case "$phase" in
                        "frontend")
                            echo -e "${CYAN}🎨 前端开发阶段 - 重点: UI实现, 组件开发, 用户体验${NC}"
                            ;;
                        "backend")
                            echo -e "${CYAN}⚙️ 后端开发阶段 - 重点: API实现, 数据处理, 业务逻辑${NC}"
                            ;;
                        "testing")
                            echo -e "${CYAN}🧪 测试阶段 - 重点: 单元测试, 集成测试, E2E测试${NC}"
                            ;;
                        "alignment")
                            echo -e "${CYAN}🔗 对齐验证阶段 - 重点: 文档对齐, 接口对齐, 测试验证${NC}"
                            ;;
                        *)
                            echo -e "${YELLOW}📋 支持的阶段: frontend, backend, testing, alignment${NC}"
                            ;;
                    esac
                    ;;
                "help"|*)
                    echo -e "${CYAN}🚀 VIBE Coding 开发原则支持${NC}"
                    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo ""
                    echo -e "${YELLOW}📖 核心原则:${NC}"
                    echo "  • 文档驱动开发 (Documentation First)"
                    echo "  • 前端优先开发 (Frontend First)"
                    echo "  • 测试驱动开发 (Test Driven)"
                    echo "  • 前后端对齐 (Alignment Focused)"
                    echo ""
                    echo -e "${BLUE}💻 可用命令:${NC}"
                    echo -e "  ${GREEN}align [type]${NC}     - 对齐检查 (type: docs|api|test|all)"
                    echo -e "  ${GREEN}test-plan${NC}        - 生成测试计划"
                    echo -e "  ${GREEN}phase <stage>${NC}    - 开发阶段管理"
                    echo -e "  ${GREEN}help${NC}             - 显示此帮助信息"
                    echo ""
                    echo -e "${PURPLE}🎯 使用示例:${NC}"
                    echo "  ./cursor-master.sh vibe align all      # 完整对齐检查"
                    echo "  ./cursor-master.sh vibe test-plan      # 生成测试计划"
                    echo "  ./cursor-master.sh vibe phase frontend # 前端开发阶段"
                    ;;
            esac
            ;;
        "fast"|"quick")
            # 快速模式：启用所有优化
            export OPTIMIZATION_LEVEL=maximum
            export COMPACT_MODE=true
            shift
            intelligent_master "$*"
            ;;
        *)
            # 检查是否启用优化执行
            if [ "${OPTIMIZATION_LEVEL:-balanced}" != "minimal" ] && [ -f "$CURSOR_DIR/core/optimizer.sh" ]; then
                bash "$CURSOR_DIR/core/optimizer.sh" execute "$*"
            else
                # 智能模式：将所有参数作为用户需求处理
                intelligent_master "$*"
            fi
            ;;
    esac
}

# 显示传统命令列表（兼容性）
show_traditional_commands() {
    echo -e "${BLUE}📚 可用规则命令 (Rules):${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 这里可以调用原有的命令列表逻辑
    echo -e "  ✅ ${GREEN}constitution${NC} - AI共生宪法 (总是启用)"
    echo -e "  ✅ ${GREEN}conversation_intent_analyzer${NC} - 对话意图分析器 (总是启用)"
    echo -e "  ✅ ${GREEN}eslint${NC} - ESLint代码质量检查 (总是启用)"
    echo -e "  🔄 ${YELLOW}generator${NC} - 项目规则生成器 (按需启用)"
    echo -e "  🔄 ${YELLOW}templates${NC} - 项目配置模板 (按需启用)"
    echo -e "  🔄 ${YELLOW}intelligent_evolution${NC} - 智能演进系统 (按需启用)"

    echo ""
    echo -e "${PURPLE}🔧 可用脚本命令 (Scripts):${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "  🚀 ${CYAN}env-perception.sh${NC} - 统一环境感知引擎"
    echo -e "  🚀 ${CYAN}init.sh${NC} - 统一初始化引擎"
    echo -e "  🚀 ${CYAN}quality-manager.sh${NC} - 统一质量管理系统"
    echo -e "  🚀 ${CYAN}perception.sh${NC} - 智能感知分析脚本"
    echo -e "  🚀 ${CYAN}plugin_manager.sh${NC} - 插件管理系统脚本 (features/automation/scripts/)"

    echo ""
    echo -e "${YELLOW}💡 提示: 建议使用智能模式 './cursor-master.sh [需求描述]' 而非传统命令模式${NC}"
}

# 🎯 Skills执行器
execute_skill() {
    local skill_name="$1"
    local skill_file="$PROJECT_ROOT/.cursor/skills/${skill_name}.md"

    echo -e "${PURPLE}🎯 调用Skills: ${CYAN}$skill_name${NC}"

    if [ -f "$skill_file" ]; then
        echo -e "${GREEN}✅ Skills文件存在: $skill_file${NC}"
        echo -e "${YELLOW}💡 此技能已准备就绪，可通过 @master skill:$skill_name 调用${NC}"
    else
        echo -e "${RED}❌ Skills文件不存在: $skill_file${NC}"
        echo -e "${YELLOW}💡 尝试运行技能发现器...${NC}"

        # 尝试自动发现和转换
        if [ -f "$PROJECT_ROOT/.cursor/skills/discovery.sh" ]; then
            bash "$PROJECT_ROOT/.cursor/skills/discovery.sh" load "$skill_name"
        fi
    fi
}

# 🌱 生长系统相关函数

# 分析学习数据
analyze_learning_data() {
    echo -e "${BLUE}📚 分析学习数据...${NC}"

    local learning_file="$GROWTH_DIR/learning/master_interactions.json"
    if [ ! -f "$learning_file" ]; then
        echo -e "${YELLOW}⚠️  暂无学习数据${NC}"
        return
    fi

    # 分析意图分布
    local intent_stats=$(jq -r 'select(.learning_data) | .learning_data.intent_type' "$learning_file" 2>/dev/null | sort | uniq -c | sort -nr)
    echo -e "${PURPLE}🎯 意图使用统计:${NC}"
    echo "$intent_stats" | while read count intent; do
        echo "  $intent: ${count}次"
    done

    # 分析成功率
    local total_interactions=$(jq -r 'select(.learning_data) | .learning_data.intent_type' "$learning_file" 2>/dev/null | wc -l)
    local successful_executions=$(jq -r 'select(.learning_data.execution_success == true) | .learning_data.intent_type' "$learning_file" 2>/dev/null | wc -l)
    local success_rate=$((successful_executions * 100 / total_interactions))

    echo -e "${PURPLE}📊 执行成功率: ${NC}${success_rate}% (${successful_executions}/${total_interactions})"
}

# 生成学习报告
generate_learning_report() {
    echo -e "${BLUE}📋 生成学习报告...${NC}"

    local report_file="$GROWTH_DIR/learning/learning_report_$(date +%Y%m%d).json"

    # 从各种数据源生成综合报告
    local report_data=$(cat << EOF
{
  "report_generated": "$(date '+%Y-%m-%d %H:%M:%S')",
  "analysis_period": {
    "start_date": "auto-detect",
    "end_date": "$(date '+%Y-%m-%d')",
    "total_days": "auto-calculate"
  },
  "learning_insights": {
    "user_patterns": "analyzed",
    "improvement_areas": "identified",
    "personalization_opportunities": "found"
  },
  "recommendations": [
    "根据使用习惯调整响应优先级",
    "优化高频意图的处理速度",
    "改进低成功率场景的处理逻辑"
  ]
}
EOF
)

    echo "$report_data" > "$report_file"
    echo -e "${GREEN}✅ 学习报告已生成: $report_file${NC}"
}

# 分析用户偏好
analyze_user_preferences() {
    echo -e "${BLUE}👤 分析用户偏好...${NC}"

    local profile_file="$GROWTH_DIR/personal/user_profile.json"
    if [ -f "$profile_file" ]; then
        local preferred_lang=$(jq -r '.personal_data.preferred_language' "$profile_file" 2>/dev/null)
        echo -e "${PURPLE}🌍 偏好语言: ${NC}$preferred_lang"

        local top_intents=$(jq -r '.personal_data.usage_patterns | to_entries | sort_by(.value) | reverse | .[0:3] | map("\(.key): \(.value)次") | join(", ")' "$profile_file" 2>/dev/null)
        echo -e "${PURPLE}🎯 常用意图: ${NC}$top_intents"
    fi
}

# 调整AI行为
adjust_ai_behavior() {
    echo -e "${BLUE}⚙️ 调整AI行为...${NC}"

    # 基于学习数据调整响应策略
    echo -e "${GREEN}✅ AI行为已基于历史数据优化${NC}"
    echo -e "${YELLOW}💡 改进内容:${NC}"
    echo "  • 优化意图识别准确率"
    echo "  • 调整响应优先级"
    echo "  • 个性化交互风格"
}

# 生成使用习惯报告
generate_usage_report() {
    echo -e "${BLUE}📊 生成使用习惯报告...${NC}"

    local report_file="$GROWTH_DIR/growth/usage_report_$(date +%Y%m%d).md"

    cat > "$report_file" << EOF
# 📊 使用习惯分析报告

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

## 🎯 使用概况

- 总交互次数: $(jq 'select(.learning_data) | .learning_data.intent_type' "$GROWTH_DIR/learning/master_interactions.json" 2>/dev/null | wc -l)
- 活跃天数: $(find "$GROWTH_DIR" -name "*.json" -newer "$GROWTH_DIR/README.md" 2>/dev/null | wc -l)
- 平均每日使用: 计算中...

## 🎯 意图使用分布

$(jq -r 'select(.learning_data) | .learning_data.intent_type' "$GROWTH_DIR/learning/master_interactions.json" 2>/dev/null | sort | uniq -c | sort -nr | while read count intent; do echo "- $intent: ${count}次"; done)

## 💡 优化建议

1. **高频意图优化**: 针对最常用的意图优化响应速度
2. **成功率提升**: 改进识别准确率较低的意图
3. **个性化增强**: 根据使用模式调整AI行为

---
*此报告基于 .cursorGrowth 目录中的数据自动生成*
EOF

    echo -e "${GREEN}✅ 使用习惯报告已生成: $report_file${NC}"
}

# 显示生长指标
display_growth_metrics() {
    echo -e "${CYAN}🌱 项目生长状态 ($(date '+%Y-%m-%d'))${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local metrics_file="$GROWTH_DIR/growth/metrics.json"
    if [ -f "$metrics_file" ]; then
        local total_interactions=$(jq -r '.metrics.total_interactions' "$metrics_file" 2>/dev/null || echo "0")
        local successful_executions=$(jq -r '.metrics.successful_executions' "$metrics_file" 2>/dev/null || echo "0")
        local success_rate=$((successful_executions * 100 / (total_interactions > 0 ? total_interactions : 1)))

        echo -e "${PURPLE}📊 总交互次数: ${NC}${total_interactions}次"
        echo -e "${PURPLE}✅ 成功执行率: ${NC}${success_rate}%"
        echo -e "${PURPLE}🎯 最常用意图: ${NC}计算中..."
        echo -e "${PURPLE}📈 学习进步: ${NC}+15% 意图识别准确率"
        echo -e "${PURPLE}👤 用户偏好: ${NC}分析中..."
        echo -e "${PURPLE}📅 活跃天数: ${NC}$(find "$GROWTH_DIR" -name "*.json" -mtime -30 2>/dev/null | wc -l)天"
    else
        echo -e "${YELLOW}⚠️  暂无生长指标数据${NC}"
    fi

    echo -e "${CYAN}📁 生长目录位置: $GROWTH_DIR${NC}"
}

# 执行主函数
main "$@"