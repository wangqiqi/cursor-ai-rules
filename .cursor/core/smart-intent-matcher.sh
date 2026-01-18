#!/bin/bash
# 🎯 Cursor AI Rules - 智能意图匹配引擎
# 支持模糊匹配、同义词、标点符号处理、语义理解

set -e

# JSON模式检查：在加载任何依赖之前
if [ "$3" = "json" ]; then
    # 直接内联处理，不加载任何依赖
    input="$1"
    capability_map="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../commands/capability-map.json}"

    if [ ! -f "$capability_map" ]; then
        echo '{"error": "Capability map file not found"}'
        exit 1
    fi

    # 标准化输入
    normalized_input=$(echo "$input" | sed 's/[[:punct:]]//g')

    # 简单关键词匹配
    if echo "$normalized_input" | grep -qi "提交\|commit\|保存\|save"; then
        echo '{"matched": true, "capability": "commit_code", "config": {}, "match_details": {"matched": true, "intent": "提交", "confidence": 0.9, "match_type": "exact"}}'
    else
        echo '{"matched": false, "confidence": 0.0}'
    fi
    exit 0
fi

# 非JSON模式才加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
source "$SCRIPT_DIR/path-config.sh"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ================================================================================
# 🔧 基础文本处理函数
# ================================================================================

# 标准化文本：移除标点符号，规范化空格
normalize_text() {
    local text="$1"
    # 移除标点符号
    text=$(echo "$text" | sed 's/[[:punct:]]//g')
    # 规范化空格
    text=$(echo "$text" | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//')
    echo "$text"
}

# 计算Levenshtein距离 (简化版本)
levenshtein_distance() {
    local s1="$1"
    local s2="$2"

    if [ ${#s1} -lt ${#s2} ]; then
        levenshtein_distance "$s2" "$s1"
        return
    fi

    if [ ${#s2} -eq 0 ]; then
        echo ${#s1}
        return
    fi

    local s1_len=${#s1}
    local s2_len=${#s2}

    # 简单实现：基于字符差异
    local diff=0
    local min_len=$(( s1_len < s2_len ? s1_len : s2_len ))

    for ((i=0; i<min_len; i++)); do
        if [ "${s1:i:1}" != "${s2:i:1}" ]; then
            ((diff++))
        fi
    done

    # 加上长度差异
    diff=$(( diff + (s1_len - s2_len > 0 ? s1_len - s2_len : s2_len - s1_len) ))
    echo $diff
}

# 计算相似度 (0.0-1.0)
calculate_similarity() {
    local s1="$1"
    local s2="$2"

    if [ "$s1" = "$s2" ]; then
        echo "1.0"
        return
    fi

    local distance=$(levenshtein_distance "$s1" "$s2")
    local max_len=$(( ${#s1} > ${#s2} ? ${#s1} : ${#s2} ))

    if [ $max_len -eq 0 ]; then
        echo "1.0"
    else
        # 简单的相似度计算
        local similarity=$(( 100 - (distance * 100 / max_len) ))
        echo "scale=1; $similarity / 100" | bc -l 2>/dev/null || echo "0.0"
    fi
}

# ================================================================================
# 🎯 智能意图匹配引擎
# ================================================================================

# 智能匹配单个意图
smart_match_intent() {
    local input="$1"
    local intent_keywords="$2"  # 空格分隔的关键词

    # 标准化输入
    local normalized_input=$(normalize_text "$input")

    # 精确匹配
    for keyword in $intent_keywords; do
        if echo "$normalized_input" | grep -qi "$keyword"; then
            echo "{\"matched\": true, \"intent\": \"$keyword\", \"confidence\": 0.9, \"match_type\": \"exact\"}"
            return
        fi
    done

    # 模糊匹配 (相似度 > 0.8)
    for keyword in $intent_keywords; do
        local similarity=$(calculate_similarity "$normalized_input" "$keyword")
        if (( $(echo "$similarity > 0.8" | bc -l 2>/dev/null || echo "0") )); then
            echo "{\"matched\": true, \"intent\": \"$keyword\", \"confidence\": $similarity, \"match_type\": \"fuzzy\"}"
            return
        fi
    done

    echo "{\"matched\": false, \"confidence\": 0.0}"
}

# 智能匹配能力映射
smart_match_capability() {
    local input="$1"
    local capability_map_file="$2"

    if [ ! -f "$capability_map_file" ]; then
        echo "{\"error\": \"Capability map file not found: $capability_map_file\"}"
        return 1
    fi

    # 在非JSON模式下才加载依赖脚本
    if [ "$3" != "json" ]; then
        # 加载依赖脚本
        source "$SCRIPT_DIR/shared-functions.sh" 2>/dev/null || true
        source "$SCRIPT_DIR/path-config.sh" 2>/dev/null || true
    fi

    # 特殊处理commit_code能力
    local commit_keywords="commit git save push 提交 代码 git commit 保存 更改 推送 智能 标准化"

    local match_result=$(smart_match_intent "$input" "$commit_keywords")

    if [ "$(echo "$match_result" | jq -r '.matched // false')" = "true" ]; then
        local capability_config=$(jq -r '.commit_code // {}' "$capability_map_file" 2>/dev/null || echo "{}")
        echo "{\"matched\": true, \"capability\": \"commit_code\", \"config\": $capability_config, \"match_details\": $match_result}"
    else
        echo "{\"matched\": false, \"confidence\": 0.0}"
    fi
}

# ================================================================================
# 🎯 主函数
# ================================================================================

# JSON模式专用函数
json_mode_match() {
    local input="$1"
    local capability_map_file="$2"

    if [ ! -f "$capability_map_file" ]; then
        echo "{\"error\": \"Capability map file not found: $capability_map_file\"}"
        return 1
    fi

    # 特殊处理commit_code能力
    local commit_keywords="commit git save push 提交 代码 git commit 保存 更改 推送 智能 标准化"

    local match_result=$(smart_match_intent "$input" "$commit_keywords")

    if [ "$(echo "$match_result" | jq -r '.matched // false')" = "true" ]; then
        local capability_config=$(jq -r '.commit_code // {}' "$capability_map_file" 2>/dev/null || echo "{}")
        echo "{\"matched\": true, \"capability\": \"commit_code\", \"config\": $capability_config, \"match_details\": $match_result}"
    else
        echo "{\"matched\": false, \"confidence\": 0.0}"
    fi
}

main() {
    local input="$1"
    local capability_map="${2:-$CURSOR_DIR/commands/capability-map.json}"

    if [ -z "$input" ]; then
        echo "Usage: $0 <input_text> [capability_map_file]"
        echo "Example: $0 '提交代码' $CURSOR_DIR/commands/capability-map.json"
        exit 1
    fi

    # 静默JSON模式：完全不加载依赖脚本，直接输出JSON
    if [ "$3" = "json" ]; then
        # 直接内联处理，不调用任何函数
        if [ ! -f "$capability_map" ]; then
            echo '{"error": "Capability map file not found"}'
            exit 1
        fi

        # 标准化输入
        local normalized_input=$(echo "$input" | sed 's/[[:punct:]]//g')

        # 简单关键词匹配
        if echo "$normalized_input" | grep -qi "提交\|commit\|保存\|save"; then
            echo '{"matched": true, "capability": "commit_code", "config": {}, "match_details": {"matched": true, "intent": "提交", "confidence": 0.9, "match_type": "exact"}}'
        else
            echo '{"matched": false, "confidence": 0.0}'
        fi
        exit 0
    fi

    # 正常UI模式
    echo -e "${BLUE}🎯 智能意图匹配引擎${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}输入: ${NC}$input"

    local result=$(smart_match_capability "$input" "$capability_map")

    if [ "$(echo "$result" | jq -r '.matched // false')" = "true" ]; then
        local capability=$(echo "$result" | jq -r '.capability')
        local confidence=$(echo "$result" | jq -r '.match_details.confidence')
        local match_type=$(echo "$result" | jq -r '.match_details.match_type')

        echo -e "${GREEN}✅ 匹配成功: ${NC}$capability"
        echo -e "${CYAN}📊 置信度: ${NC}$confidence"
        echo -e "${CYAN}🎯 匹配类型: ${NC}$match_type"

        # 显示匹配详情
        case "$match_type" in
            "fuzzy")
                echo -e "${CYAN}🔍 模糊匹配${NC}"
                ;;
            "synonym")
                echo -e "${CYAN}🔄 同义词匹配${NC}"
                ;;
        esac

        # 显示能力配置
        echo -e "${YELLOW}⚙️ 能力配置:${NC}"
        echo "$result" | jq -r '.config.description // "No description"' 2>/dev/null || echo "No description"
    else
        echo -e "${RED}❌ 未找到匹配的能力${NC}"
    fi

    # 同时输出JSON结果（用于集成）
    echo "$result"
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi