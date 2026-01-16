#!/bin/bash

# 🌟 Cursor AI Rules - 感知增强器
# 集成MCP工具检测，实现智能优先级路由

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 导入MCP检测器
source "$SCRIPT_DIR/mcp-detector.sh"

# 增强的感知分析
enhanced_perception() {
    local user_input="$1"

    echo -e "${BLUE}🧠 执行增强感知分析...${NC}"

    # 1. 基础意图分析
    local basic_intent=$(analyze_basic_intent "$user_input")

    # 2. MCP工具可用性检测
    local mcp_tools=$(detect_mcp_tools_for_intent "$basic_intent")

    # 3. 生成增强的感知结果
    generate_enhanced_perception_result "$basic_intent" "$mcp_tools"
}

# 基础意图分析 (简化版)
analyze_basic_intent() {
    local user_input="$1"

    # 简单的关键词匹配，实际应该使用更复杂的NLP
    if echo "$user_input" | grep -qi "提交\|commit\|git"; then
        echo "git_commit"
    elif echo "$user_input" | grep -qi "测试\|test"; then
        echo "run_tests"
    elif echo "$user_input" | grep -qi "浏览器\|browser\|网页"; then
        echo "browser_navigate"
    elif echo "$user_input" | grep -qi "pdf\|文档"; then
        echo "read_pdf"
    else
        echo "general_assistance"
    fi
}

# 检测意图对应的MCP工具
detect_mcp_tools_for_intent() {
    local intent="$1"

    echo -e "${YELLOW}🔍 检测MCP工具可用性: $intent${NC}"

    local mcp_result=$(get_mcp_tool_priority "$intent")

    # 解析JSON结果
    local available=$(echo "$mcp_result" | sed 's/.*"available": *\([^,}]*\).*/\1/' | tr -d '"')
    local tool=$(echo "$mcp_result" | sed 's/.*"tool": *"\([^"]*\)".*/\1/')
    local server=$(echo "$mcp_result" | sed 's/.*"server": *"\([^"]*\)".*/\1/')
    local priority=$(echo "$mcp_result" | sed 's/.*"priority": *"\([^"]*\)".*/\1/')

    if [ "$available" = "true" ]; then
        echo -e "${GREEN}✅ 发现可用MCP工具: $tool (服务器: $server, 优先级: $priority)${NC}"
        echo "{\"tool\": \"$tool\", \"server\": \"$server\", \"priority\": \"$priority\", \"available\": true}"
    else
        echo -e "${YELLOW}⚠️  未发现可用MCP工具，使用传统能力${NC}"
        echo "{\"available\": false, \"fallback\": \"traditional\"}"
    fi
}

# 生成增强的感知结果
generate_enhanced_perception_result() {
    local intent="$1"
    local mcp_tools="$2"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local session_id=$(generate_session_id)

    cat << EOF
{
  "version": "2.0.0",
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "perception_type": "enhanced_with_mcp",
  "user_input": "$user_input",
  "analysis": {
    "primary_intent": "$intent",
    "confidence_score": 0.85,
    "mcp_tools_available": $(echo "$mcp_tools" | jq '.available'),
    "mcp_tools": $mcp_tools,
    "execution_strategy": "$(determine_execution_strategy "$mcp_tools")",
    "fallback_options": $(generate_fallback_options "$intent")
  },
  "metadata": {
    "enhancer_version": "1.0.0",
    "mcp_detection_enabled": true,
    "priority_routing_enabled": true
  }
}
EOF
}

# 确定执行策略
determine_execution_strategy() {
    local mcp_tools="$1"

    local available=$(echo "$mcp_tools" | jq -r '.available // false')
    local priority=$(echo "$mcp_tools" | jq -r '.priority // "low"')

    if [ "$available" = "true" ] && [ "$priority" = "high" ]; then
        echo "mcp_priority_execution"
    elif [ "$available" = "true" ] && [ "$priority" = "medium" ]; then
        echo "mcp_balanced_execution"
    else
        echo "traditional_capability_execution"
    fi
}

# 生成回退选项
generate_fallback_options() {
    local intent="$1"

    case "$intent" in
        "git_commit")
            echo '["traditional_git_flow", "manual_commit", "skip_commit"]'
            ;;
        "run_tests")
            echo '["script_execution", "manual_testing", "skip_tests"]'
            ;;
        "browser_navigate")
            echo '["manual_browser", "curl_request", "skip_navigation"]'
            ;;
        *)
            echo '["general_assistance", "manual_execution"]'
            ;;
    esac
}

# 生成会话ID
generate_session_id() {
    echo "$(date +%s%N | cut -b1-13)-$(openssl rand -hex 4)"
}

# 路由决策
route_with_mcp_priority() {
    local perception_result="$1"

    echo -e "${BLUE}🎯 执行MCP优先级路由...${NC}"

    local strategy=$(echo "$perception_result" | jq -r '.analysis.execution_strategy')
    local intent=$(echo "$perception_result" | jq -r '.analysis.primary_intent')

    case "$strategy" in
        "mcp_priority_execution")
            echo -e "${GREEN}🚀 使用MCP优先级执行${NC}"
            execute_mcp_priority "$perception_result"
            ;;
        "mcp_balanced_execution")
            echo -e "${YELLOW}⚖️  使用MCP平衡执行${NC}"
            execute_mcp_balanced "$perception_result"
            ;;
        "traditional_capability_execution")
            echo -e "${BLUE}🔄 使用传统能力执行${NC}"
            execute_traditional "$intent"
            ;;
        *)
            echo -e "${RED}❌ 未知执行策略: $strategy${NC}"
            exit 1
            ;;
    esac
}

# MCP优先级执行
execute_mcp_priority() {
    local perception_result="$1"

    local mcp_tool=$(echo "$perception_result" | jq -r '.analysis.mcp_tools.tool')
    local server=$(echo "$perception_result" | jq -r '.analysis.mcp_tools.server')
    local intent=$(echo "$perception_result" | jq -r '.analysis.primary_intent')

    echo -e "${GREEN}🔧 执行MCP工具: $mcp_tool${NC}"

    # 这里应该调用实际的MCP工具
    # 目前先输出调用信息
    case "$intent" in
        "git_commit")
            echo "调用: $mcp_tool (参数: repo_path, message)"
            ;;
        "run_tests")
            echo "调用: $mcp_tool (参数: framework, args)"
            ;;
        "browser_navigate")
            echo "调用: $mcp_tool (参数: url)"
            ;;
        *)
            echo "调用: $mcp_tool"
            ;;
    esac
}

# MCP平衡执行
execute_mcp_balanced() {
    local perception_result="$1"

    echo "平衡执行MCP工具和传统能力..."
    # 实现平衡执行逻辑
}

# 传统能力执行
execute_traditional() {
    local intent="$1"

    echo -e "${BLUE}🔧 执行传统能力流程${NC}"

    case "$intent" in
        "git_commit")
            echo "调用: 传统Git提交流程 (git-commit.sh)"
            ;;
        "run_tests")
            echo "调用: 传统测试执行脚本"
            ;;
        "browser_navigate")
            echo "调用: 传统浏览器操作"
            ;;
        *)
            echo "调用: 通用助手能力"
            ;;
    esac
}

# 主函数
main() {
    local command="$1"
    local user_input="$2"

    case "$command" in
        "analyze")
            if [ -z "$user_input" ]; then
                echo -e "${RED}❌ 请提供用户输入${NC}"
                exit 1
            fi
            enhanced_perception "$user_input"
            ;;
        "route")
            if [ -z "$user_input" ]; then
                echo -e "${RED}❌ 请提供感知结果${NC}"
                exit 1
            fi
            route_with_mcp_priority "$user_input"
            ;;
        "demo")
            echo -e "${BLUE}🚀 MCP感知增强器演示${NC}"
            echo ""

            local demo_inputs=("提交代码" "运行测试" "打开浏览器" "读取PDF文档")

            for input in "${demo_inputs[@]}"; do
                echo -e "${YELLOW}输入: $input${NC}"
                local result=$(enhanced_perception "$input")
                echo "$result" | jq '.analysis'
                echo ""
            done
            ;;
        *)
            echo -e "${BLUE}🧠 感知增强器 - MCP优先级感知系统${NC}"
            echo ""
            echo -e "${YELLOW}使用方法:${NC}"
            echo "  ./perception-enhancer.sh analyze \"用户输入\"    # 分析用户输入"
            echo "  ./perception-enhancer.sh route <感知结果>       # 执行路由决策"
            echo "  ./perception-enhancer.sh demo                   # 运行演示"
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi