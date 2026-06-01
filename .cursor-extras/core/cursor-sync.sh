#!/bin/bash

# 🎯 Cursor AI Rules - Cursor对话记录同步器
# 将Cursor IDE的对话记录同步到 $CURSOR_GROWTH 目录
#
# 使用方法:
#   ./cursor-sync.sh sync              # 同步最新对话记录
#   ./cursor-sync.sh sync-all          # 同步所有对话记录
#   ./cursor-sync.sh status            # 查看同步状态
#   ./cursor-sync.sh auto              # 自动同步模式

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/path-config.sh"  # 统一路径配置
GROWTH_DIR="$CURSOR_GROWTH"

source "$SCRIPT_DIR/colors.sh"

# 检测Cursor项目缓存目录
detect_cursor_cache_dir() {
    # 基于当前项目路径生成Cursor缓存目录名
    local project_hash
    project_hash=$(echo "$PROJECT_ROOT" | sed 's/\//-/g' | sed 's/^-//' | sed 's/^-*//')
    echo "$HOME/.cursor/projects/home-saida-workspace-$project_hash"
}

# 查找Cursor对话记录目录
find_cursor_transcripts_dir() {
    local cache_base="$HOME/.cursor/projects"
    local project_name

    # 尝试多种方式找到项目目录
    if [ -d "$cache_base" ]; then
        # 方法1: 基于项目路径哈希
        project_name=$(basename "$PROJECT_ROOT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
        local possible_dir="$cache_base/home-saida-workspace-$project_name"

        if [ -d "$possible_dir/agent-transcripts" ]; then
            echo "$possible_dir/agent-transcripts"
            return 0
        fi

        # 方法2: 查找所有包含agent-transcripts的目录
        local found_dir
        found_dir=$(find "$cache_base" -name "agent-transcripts" -type d 2>/dev/null | head -1)
        if [ -n "$found_dir" ]; then
            echo "$found_dir"
            return 0
        fi
    fi

    echo ""
    return 1
}

# 初始化同步状态跟踪
init_sync_tracking() {
    mkdir -p "$INTEGRATIONS_SYNC_DIR"
    local sync_status_file="$INTEGRATIONS_SYNC_DIR/cursor_sync_status.json"

    if [ ! -f "$sync_status_file" ]; then
        cat > "$sync_status_file" << EOF
{
  "sync_status": {
    "last_sync": null,
    "total_synced": 0,
    "cursor_transcripts_dir": null,
    "auto_sync_enabled": false,
    "sync_interval_minutes": 30
  },
  "synced_files": {}
}
EOF
    fi

    echo "$sync_status_file"
}

# 同步单个对话记录文件
sync_transcript_file() {
    local transcript_file="$1"
    local transcripts_dir="$2"
    local filename
    filename=$(basename "$transcript_file" .txt)
    local growth_conversation_file="$CONVERSATIONS_DIR/cursor_${filename}.json"

    # 检查是否已经同步过
    local sync_status_file
    sync_status_file=$(init_sync_tracking)
    local file_mtime
    file_mtime=$(stat -c %Y "$transcript_file" 2>/dev/null || stat -f %m "$transcript_file" 2>/dev/null || echo "0")
    local synced_mtime
    synced_mtime=$(jq -r ".synced_files.\"$filename\" // 0" "$sync_status_file" 2>/dev/null || echo "0")

    # 确保mtime是数字
    if ! [[ "$synced_mtime" =~ ^[0-9]+$ ]]; then
        synced_mtime=0
    fi

    if [ "$file_mtime" -le "$synced_mtime" ] 2>/dev/null && [ -f "$growth_conversation_file" ]; then
        echo -e "${BLUE}⏭️  跳过已同步文件: ${YELLOW}$filename${NC}"
        return 0
    fi

    echo -e "${CYAN}🔄 同步对话记录: ${YELLOW}$filename${NC}"

    # 读取和解析对话记录
    local content
    content=$(cat "$transcript_file")

    # 提取对话信息
    local conversation_data
    conversation_data=$(extract_conversation_data "$content" "$filename")

    if [ -n "$conversation_data" ]; then
        echo "$conversation_data" > "$growth_conversation_file"
        echo -e "${GREEN}✅ 已同步: ${YELLOW}$growth_conversation_file${NC}"

        # 更新同步状态
        local temp_file
        temp_file=$(mktemp)
        local current_time
        current_time=$(date '+%Y-%m-%d %H:%M:%S')
        jq --arg filename "$filename" --arg mtime "$file_mtime" --arg current_time "$current_time" '
            .synced_files[$filename] = $mtime |
            .sync_status.total_synced = (.sync_status.total_synced // 0) + 1 |
            .sync_status.last_sync = $current_time
        ' "$sync_status_file" > "$temp_file"
        mv "$temp_file" "$sync_status_file"

        return 0
    else
        echo -e "${YELLOW}⚠️  无法解析对话记录: ${RED}$filename${NC}"
        return 1
    fi
}

# 提取对话数据
extract_conversation_data() {
    local content="$1"
    local session_id="$2"

    # 解析对话内容
    local messages="[]"
    local user_messages=()
    local assistant_messages=()

    # 简单解析 (可以根据需要增强)
    while IFS= read -r line; do
        case "$line" in
            "user:")
                # 开始读取用户消息
                local user_msg=""
                while IFS= read -r next_line && [ "$next_line" != "assistant:" ] && [ -n "$next_line" ]; do
                    if [[ "$next_line" =~ ^\<.*\>$ ]]; then
                        user_msg="$user_msg$next_line\n"
                    fi
                done
                if [ -n "$user_msg" ]; then
                    user_messages+=("$user_msg")
                fi
                ;;
            "assistant:")
                # 开始读取助手消息
                local assistant_msg=""
                while IFS= read -r next_line && [ "$next_line" != "user:" ] && [ -n "$next_line" ]; do
                    assistant_msg="$assistant_msg$next_line\n"
                done
                if [ -n "$assistant_msg" ]; then
                    assistant_messages+=("$assistant_msg")
                fi
                ;;
        esac
    done <<< "$content"

    # 构建JSON格式
    local json_messages="[]"

    # 添加用户消息
    for i in "${!user_messages[@]}"; do
        json_messages=$(echo "$json_messages" | jq --arg msg "${user_messages[$i]}" --arg time "$(date -d "now - $i minutes" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')" '
            . + [{"role": "user", "content": $msg, "timestamp": $time}]
        ')
    done

    # 添加助手消息
    for i in "${!assistant_messages[@]}"; do
        json_messages=$(echo "$json_messages" | jq --arg msg "${assistant_messages[$i]}" --arg time "$(date -d "now - $i minutes" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')" '
            . + [{"role": "assistant", "content": $msg, "timestamp": $time}]
        ')
    done

    # 生成完整的对话记录
    cat << EOF
{
  "conversation_id": "cursor_$session_id",
  "source": "cursor_ide",
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "type": "cursor_agent_transcript",
  "messages": $json_messages,
  "metadata": {
    "project_root": "$PROJECT_ROOT",
    "cursor_version": "5.0.0",
    "sync_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "transcript_file": "$session_id.txt"
  }
}
EOF
}

# 同步所有对话记录
sync_all_transcripts() {
    local transcripts_dir
    transcripts_dir=$(find_cursor_transcripts_dir)

    if [ -z "$transcripts_dir" ]; then
        echo -e "${RED}❌ 未找到Cursor对话记录目录${NC}"
        echo -e "${YELLOW}💡 请确保项目已在Cursor中打开过${NC}"
        return 1
    fi

    echo -e "${CYAN}🔍 发现Cursor对话记录目录: ${YELLOW}$transcripts_dir${NC}"

    local sync_count=0
    local total_files
    total_files=$(find "$transcripts_dir" -name "*.txt" -type f | wc -l)

    echo -e "${BLUE}📊 开始同步 ${YELLOW}$total_files${BLUE} 个对话记录文件...${NC}"

    while IFS= read -r transcript_file; do
        if [ -n "$transcript_file" ] && [ -f "$transcript_file" ]; then
            if sync_transcript_file "$transcript_file" "$transcripts_dir"; then
                ((sync_count++))
            fi
        fi
    done < <(find "$transcripts_dir" -name "*.txt" -type f)

    echo -e "${GREEN}✅ 同步完成! 成功同步 ${YELLOW}$sync_count${GREEN} 个文件${NC}"
}

# 同步完整Cursor数据目录
sync_full_cursor_data() {
    local cursor_project_dir
    cursor_project_dir=$(find_cursor_project_dir)

    if [ -z "$cursor_project_dir" ]; then
        echo -e "${RED}❌ 未找到Cursor项目目录${NC}"
        return 1
    fi

    echo -e "${CYAN}🔄 开始完整Cursor数据同步...${NC}"
    echo -e "${CYAN}📁 源目录: ${YELLOW}$cursor_project_dir${NC}"

    local total_synced=0

    # 同步agent-transcripts目录
    if [ -d "$cursor_project_dir/agent-transcripts" ]; then
        echo -e "${BLUE}📝 同步对话记录...${NC}"
        local transcripts_synced
        transcripts_synced=$(sync_directory "$cursor_project_dir/agent-transcripts" "conversations" "cursor_" "transcript")
        echo -e "${GREEN}  ✅ 对话记录: $transcripts_synced 个文件${NC}"
        ((total_synced += transcripts_synced))
    fi

    # 同步其他相关目录 (如果存在)
    local dirs_to_sync=("agent-tools" "tools" "workspace-data" "project-data")
    for dir_name in "${dirs_to_sync[@]}"; do
        if [ -d "$cursor_project_dir/$dir_name" ]; then
            echo -e "${BLUE}🔧 同步${dir_name}数据...${NC}"
            local synced_count
            synced_count=$(sync_directory "$cursor_project_dir/$dir_name" "cursor_$dir_name" "cursor_" "$dir_name")
            echo -e "${GREEN}  ✅ $dir_name: $synced_count 个文件${NC}"
            ((total_synced += synced_count))
        fi
    done

    # 同步mcps目录 (MCP配置和数据)
    if [ -d "$cursor_project_dir/mcps" ]; then
        echo -e "${BLUE}🔌 同步MCP配置数据...${NC}"
        local mcps_synced
        mcps_synced=$(sync_mcps_directory "$cursor_project_dir/mcps")
        echo -e "${GREEN}  ✅ MCP数据: $mcps_synced 个配置${NC}"
        ((total_synced += mcps_synced))
    fi

    echo -e "${GREEN}🎉 完整同步完成! 总共同步 ${YELLOW}$total_synced${GREEN} 个项目数据文件${NC}"
}

# 同步单个目录
sync_directory() {
    local source_dir="$1"
    local target_subdir="$2"
    local file_prefix="$3"
    local data_type="$4"

    local target_dir="$GROWTH_DIR/$target_subdir"
    mkdir -p "$target_dir"

    local synced_count=0
    local total_files
    total_files=$(find "$source_dir" -type f | wc -l)

    echo -e "${CYAN}    📊 处理 $total_files 个文件...${NC}"

    while IFS= read -r source_file; do
        if [ -n "$source_file" ] && [ -f "$source_file" ]; then
            local filename
            filename=$(basename "$source_file")
            local target_file="$target_dir/${file_prefix}${filename%.*}.json"

            # 检查是否需要同步
            local source_mtime
            source_mtime=$(stat -c %Y "$source_file" 2>/dev/null || stat -f %m "$source_file" 2>/dev/null || echo "0")
            local target_mtime=0
            if [ -f "$target_file" ]; then
                target_mtime=$(stat -c %Y "$target_file" 2>/dev/null || stat -f %m "$target_file" 2>/dev/null || echo "0")
            fi

            if [ "$source_mtime" -gt "$target_mtime" ]; then
                # 转换为JSON格式并保存
                if convert_file_to_json "$source_file" "$target_file" "$data_type"; then
                    ((synced_count++))
                fi
            fi
        fi
    done < <(find "$source_dir" -type f)

    echo "$synced_count"
}

# 同步MCP目录
sync_mcps_directory() {
    local mcps_dir="$1"
    local target_dir="$GROWTH_DIR/mcps"
    mkdir -p "$target_dir"

    local synced_count=0

    # 同步每个MCP的配置和资源
    for mcp_dir in "$mcps_dir"/*/; do
        if [ -d "$mcp_dir" ]; then
            local mcp_name
            mcp_name=$(basename "$mcp_dir")

            # 同步config.json（如果存在）
            local config_file="$mcp_dir/config.json"
            if [ -f "$config_file" ]; then
                local target_config="$target_dir/${mcp_name}_config.json"
                cp "$config_file" "$target_config"
                ((synced_count++))
            fi

            # 同步resources目录中的JSON文件
            local resources_dir="$mcp_dir/resources"
            if [ -d "$resources_dir" ]; then
                local target_resources="$target_dir/${mcp_name}_resources"
                mkdir -p "$target_resources"

                # 复制所有JSON资源文件
                local json_files
                json_files=$(find "$resources_dir" -name "*.json" -type f)
                if [ -n "$json_files" ]; then
                    echo "$json_files" | while read -r json_file; do
                        local filename
                        filename=$(basename "$json_file")
                        cp "$json_file" "$target_resources/"
                        ((synced_count++))
                    done
                fi
            fi
        fi
    done

    echo "$synced_count"
}

# 通用文件转换函数
convert_file_to_json() {
    local source_file="$1"
    local target_file="$2"
    local data_type="$3"

    case "$data_type" in
        "transcript")
            # 对话记录转换 (复用现有逻辑)
            local filename
            filename=$(basename "$source_file" .txt)
            local transcripts_dir
            transcripts_dir=$(dirname "$source_file")
            sync_transcript_file "$source_file" "$transcripts_dir" > /dev/null 2>&1
            ;;
        "tool"|"config"|"data")
            # 通用文件复制并添加元数据
            cat > "$target_file" << EOF
{
  "file_info": {
    "original_name": "$(basename "$source_file")",
    "source_path": "$source_file",
    "data_type": "$data_type",
    "sync_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "project_root": "$PROJECT_ROOT"
  },
  "content": $(jq -Rs . "$source_file" 2>/dev/null || echo "\"$(cat "$source_file" | sed 's/"/\\"/g' | sed 's/$/\\n/' | tr -d '\n')\"")
}
EOF
            ;;
        *)
            # 默认复制
            cp "$source_file" "$target_file"
            ;;
    esac
}

# 查找Cursor项目目录
find_cursor_project_dir() {
    local cache_base="$HOME/.cursor/projects"
    local project_name

    # 基于当前项目路径生成Cursor缓存目录名
    if [ -d "$cache_base" ]; then
        project_name=$(basename "$PROJECT_ROOT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
        local possible_dir="$cache_base/home-saida-workspace-$project_name"

        if [ -d "$possible_dir" ]; then
            echo "$possible_dir"
            return 0
        fi

        # 查找包含相关文件的目录
        local found_dir
        found_dir=$(find "$cache_base" -name "agent-transcripts" -type d -exec dirname {} \; 2>/dev/null | head -1)
        if [ -n "$found_dir" ]; then
            echo "$found_dir"
            return 0
        fi
    fi

    echo ""
    return 1
}

# 同步最新对话记录 (保留原有功能)
sync_latest_transcripts() {
    local transcripts_dir
    transcripts_dir=$(find_cursor_transcripts_dir)

    if [ -z "$transcripts_dir" ]; then
        echo -e "${RED}❌ 未找到Cursor对话记录目录${NC}"
        return 1
    fi

    # 获取最新的几个文件 (默认3个)
    local latest_count="${LATEST_COUNT:-3}"
    local latest_files
    latest_files=$(find "$transcripts_dir" -name "*.txt" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -"$latest_count" | cut -d' ' -f2-)

    if [ -z "$latest_files" ]; then
        echo -e "${YELLOW}⚠️  未找到对话记录文件${NC}"
        return 1
    fi

    echo -e "${CYAN}🔄 同步最新 ${latest_count} 个对话记录...${NC}"

    local sync_count=0
    while IFS= read -r transcript_file; do
        if [ -n "$transcript_file" ]; then
            if sync_transcript_file "$transcript_file" "$transcripts_dir"; then
                ((sync_count++))
            fi
        fi
    done <<< "$latest_files"

    echo -e "${GREEN}✅ 最新同步完成! 处理了 ${YELLOW}$sync_count${GREEN} 个文件${NC}"
}

# 显示同步状态
show_sync_status() {
    local sync_status_file
    sync_status_file=$(init_sync_tracking)

    echo -e "${CYAN}📊 Cursor对话同步状态${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f "$sync_status_file" ]; then
        local last_sync
        last_sync=$(jq -r '.sync_status.last_sync // "从未同步"' "$sync_status_file")
        local total_synced
        total_synced=$(jq -r '.sync_status.total_synced // 0' "$sync_status_file")
        local transcripts_dir
        transcripts_dir=$(find_cursor_transcripts_dir)

        echo -e "${BLUE}🕒 最后同步: ${NC}$last_sync"
        echo -e "${BLUE}📄 已同步文件数: ${NC}$total_synced"
        echo -e "${BLUE}📁 Cursor对话目录: ${NC}${transcripts_dir:-"未找到"}"
    fi

    # 显示本地同步的对话文件
    local conversation_count
    conversation_count=$(find "$CONVERSATIONS_DIR" -name "cursor_*.json" -type f 2>/dev/null | wc -l)
    echo -e "${BLUE}💬 本地Cursor对话数: ${NC}$conversation_count"

    echo -e "${GREEN}🌱 生长目录位置: ${NC}$GROWTH_DIR"
}

# 主函数
main() {
    case "${1:-}" in
        "sync")
            echo -e "${CYAN}🔄 同步最新Cursor对话记录...${NC}"
            sync_latest_transcripts
            ;;
        "sync-all")
            echo -e "${CYAN}🔄 同步所有Cursor对话记录...${NC}"
            sync_all_transcripts
            ;;
        "full-sync")
            echo -e "${CYAN}🔄 执行完整Cursor数据同步...${NC}"
            sync_full_cursor_data
            ;;
        "sync-file")
            shift
            local file_path="$1"
            if [ -n "$file_path" ] && [ -f "$file_path" ]; then
                echo -e "${CYAN}🔄 同步指定文件: ${YELLOW}$(basename "$file_path")${NC}"
                local transcripts_dir
                transcripts_dir=$(find_cursor_transcripts_dir)
                if sync_transcript_file "$file_path" "$transcripts_dir"; then
                    echo -e "${GREEN}✅ 文件同步成功${NC}"
                else
                    echo -e "${RED}❌ 文件同步失败${NC}"
                fi
            else
                echo -e "${RED}❌ 请指定有效的文件路径${NC}"
            fi
            ;;
        "status")
            show_sync_status
            ;;
        "auto")
            echo -e "${CYAN}🤖 启用自动同步模式...${NC}"
            enable_auto_sync
            ;;
        "help"|"-h"|"--help")
            echo "🎯 Cursor AI Rules - Cursor对话记录同步器"
            echo ""
            echo "将Cursor IDE的对话记录同步到 $CURSOR_GROWTH 目录"
            echo ""
            echo "使用方法:"
            echo "  $0 sync              # 同步最新对话记录"
            echo "  $0 sync-all          # 同步所有对话记录"
            echo "  $0 full-sync         # 同步完整Cursor项目数据"
            echo "  $0 status            # 查看同步状态"
            echo "  $0 auto              # 启用自动同步"
            echo "  $0 help              # 显示帮助"
            ;;
        *)
            echo -e "${YELLOW}💡 使用 '$0 help' 查看帮助信息${NC}"
            show_sync_status
            ;;
    esac
}

# 执行主函数
main "$@"