#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"


# 🌟 Cursor AI Rules - MCP Tools 检测器
# 自动检测可用的 MCP servers 和 tools，实现优先调用机制

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/colors.sh"

# 已知MCP服务器列表
KNOWN_MCP_SERVERS=(
    "cursor-ide-browser"
    "mcp-git"
    "mcp-testing"
    "mcp-memory"
    "mcp-puppeteer"
    "mcp-sequential-thinking"
    "mcp-pdf-reader"
)

# MCP工具映射表 (意图 -> MCP工具)
declare -A MCP_TOOLS_MAPPING=(
    # Git相关
    ["git_status"]="mcp_git_git_status"
    ["git_add"]="mcp_git_git_add"
    ["git_commit"]="mcp_git_git_commit"
    ["git_push"]="mcp_git_git_push"
    ["git_diff"]="mcp_git_git_diff"
    ["git_log"]="mcp_git_git_log"
    ["git_branch"]="mcp_git_git_branch"
    ["git_pull"]="mcp_git_git_pull"
    ["git_clone"]="mcp_git_git_clone"
    ["git_remote"]="mcp_git_git_remote"

    # 浏览器相关
    ["browser_navigate"]="mcp_cursor-ide-browser_browser_navigate"
    ["browser_snapshot"]="mcp_cursor-ide-browser_browser_snapshot"
    ["browser_click"]="mcp_cursor-ide-browser_browser_click"
    ["browser_type"]="mcp_cursor-ide-browser_browser_type"
    ["browser_hover"]="mcp_cursor-ide-browser_browser_hover"
    ["browser_select"]="mcp_cursor-ide-browser_browser_select_option"
    ["browser_press_key"]="mcp_cursor-ide-browser_browser_press_key"
    ["browser_wait"]="mcp_cursor-ide-browser_browser_wait_for"
    ["browser_back"]="mcp_cursor-ide-browser_browser_navigate_back"
    ["browser_resize"]="mcp_cursor-ide-browser_browser_resize"
    ["browser_console"]="mcp_cursor-ide-browser_browser_console_messages"
    ["browser_network"]="mcp_cursor-ide-browser_browser_network_requests"
    ["browser_tabs"]="mcp_cursor-ide-browser_browser_tabs"
    ["browser_screenshot"]="mcp_cursor-ide-browser_browser_take_screenshot"

    # 测试相关
    ["run_tests"]="mcp_testing_run_tests"
    ["run_all_tests"]="mcp_testing_run_all_tests"
    ["list_test_frameworks"]="mcp_testing_list_test_frameworks"
    ["get_test_result"]="mcp_testing_get_test_result"

    # 内存相关
    ["store_memory"]="mcp_memory_store_memory"
    ["retrieve_memory"]="mcp_memory_retrieve_memory"
    ["list_memory_keys"]="mcp_memory_list_memory_keys"
    ["delete_memory"]="mcp_memory_delete_memory"
    ["clear_memory"]="mcp_memory_clear_memory"

    # Puppeteer相关
    ["puppeteer_navigate"]="mcp_puppeteer_navigate_to_page"
    ["puppeteer_screenshot"]="mcp_puppeteer_take_screenshot"
    ["puppeteer_text"]="mcp_puppeteer_extract_text"
    ["puppeteer_html"]="mcp_puppeteer_extract_html"
    ["puppeteer_javascript"]="mcp_puppeteer_execute_javascript"
    ["puppeteer_click"]="mcp_puppeteer_click_element"
    ["puppeteer_type"]="mcp_puppeteer_type_text"
    ["puppeteer_pdf"]="mcp_puppeteer_generate_pdf"

    # 顺序思维
    ["sequential_thinking"]="mcp_sequential-thinking_sequential_thinking"

    # PDF阅读
    ["read_pdf"]="mcp_pdf-reader_read_pdf"
    ["search_pdf"]="mcp_pdf-reader_search_pdf"
    ["pdf_info"]="mcp_pdf-reader_get_pdf_info"
)

# 检测MCP服务器可用性
detect_mcp_servers() {
    echo -e "${BLUE}🔍 检测可用的MCP服务器...${NC}"

    local available_servers=()

    for server in "${KNOWN_MCP_SERVERS[@]}"; do
        # 检查服务器是否可用 (这里可以根据实际实现调整检测逻辑)
        if check_server_available "$server"; then
            echo -e "${GREEN}✅ MCP服务器可用: ${server}${NC}"
            available_servers+=("$server")
        else
            echo -e "${YELLOW}⚠️  MCP服务器不可用: ${server}${NC}"
        fi
    done

    echo "${available_servers[@]}"
}

# 检查特定服务器是否可用
check_server_available() {
    local server="$1"

    # 这里应该实现实际的服务器可用性检测逻辑
    # 目前先返回true作为占位符，实际实现需要根据MCP协议检查
    case "$server" in
        "mcp-git"|"mcp-testing"|"mcp-memory"|"mcp-puppeteer"|"mcp-sequential-thinking"|"mcp-pdf-reader"|"cursor-ide-browser")
            # 检查命令是否存在
            if command -v "$server" >/dev/null 2>&1; then
                return 0
            fi
            ;;
    esac

    return 1
}

# 获取MCP工具优先级
get_mcp_tool_priority() {
    local intent="$1"

    # 检查是否有对应的MCP工具
    local mcp_tool="${MCP_TOOLS_MAPPING[$intent]}"

    if [ -n "$mcp_tool" ]; then
        # 检查该MCP工具是否可用
        local server_name=$(echo "$mcp_tool" | cut -d'_' -f2)

        # 临时放宽检查条件，实际应该检查MCP服务器是否真的可用
        if [ "$server_name" = "git" ] || [ "$server_name" = "testing" ] || [ "$server_name" = "memory" ] || [ "$server_name" = "puppeteer" ] || [ "$server_name" = "sequential-thinking" ] || [ "$server_name" = "pdf-reader" ] || [ "$server_name" = "cursor-ide-browser" ]; then
            echo "{\"available\": true, \"tool\": \"$mcp_tool\", \"server\": \"$server_name\", \"priority\": \"high\"}"
            return 0
        fi
    fi

    echo "{\"available\": false, \"priority\": \"low\"}"
}

# 导出MCP工具映射到JSON格式
export_mcp_mapping() {
    echo "{"
    echo "  \"version\": \"1.0.0\","
    echo "  \"description\": \"MCP Tools 优先级映射表\","
    echo "  \"mappings\": {"

    local first=true
    for intent in "${!MCP_TOOLS_MAPPING[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        local mcp_tool="${MCP_TOOLS_MAPPING[$intent]}"
        local server_name=$(echo "$mcp_tool" | cut -d'_' -f2)

        echo -n "    \"$intent\": {"
        echo -n "\"tool\": \"$mcp_tool\","
        echo -n "\"server\": \"$server_name\","
        echo -n "\"category\": \"$(get_tool_category "$intent")\""
        echo -n "}"
    done
    echo ""
    echo "  }"
    echo "}"
}

# 获取工具分类
get_tool_category() {
    local intent="$1"

    case "$intent" in
        git_*)
            echo "version_control"
            ;;
        browser_*)
            echo "web_automation"
            ;;
        test_*)
            echo "testing"
            ;;
        memory_*)
            echo "data_management"
            ;;
        puppeteer_*)
            echo "web_scraping"
            ;;
        pdf_*)
            echo "document_processing"
            ;;
        sequential_*)
            echo "ai_assistance"
            ;;
        *)
            echo "utility"
            ;;
    esac
}

# 主函数
main() {
    local command="$1"

    case "$command" in
        "detect")
            detect_mcp_servers
            ;;
        "check")
            local intent="$2"
            if [ -z "$intent" ]; then
                echo -e "${RED}❌ 请指定意图${NC}"
                exit 1
            fi
            get_mcp_tool_priority "$intent"
            ;;
        "export")
            export_mcp_mapping
            ;;
        "list")
            echo -e "${BLUE}📋 可用的MCP工具映射:${NC}"
            for intent in "${!MCP_TOOLS_MAPPING[@]}"; do
                local mcp_tool="${MCP_TOOLS_MAPPING[$intent]}"
                echo "  $intent -> $mcp_tool"
            done
            ;;
        *)
            echo -e "${BLUE}🚀 MCP Tools 检测器${NC}"
            echo ""
            echo -e "${YELLOW}使用方法:${NC}"
            echo "  ./mcp-detector.sh detect          # 检测可用MCP服务器"
            echo "  ./mcp-detector.sh check <intent>  # 检查特定意图的MCP工具优先级"
            echo "  ./mcp-detector.sh export          # 导出MCP工具映射到JSON"
            echo "  ./mcp-detector.sh list            # 列出所有MCP工具映射"
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi