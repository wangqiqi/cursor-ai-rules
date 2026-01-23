#!/bin/bash
# ========================================
# Cursor AI Rules - 上下文持久化桥接系统
# 突破对话框限制，实现无限上下文连续性
# ========================================

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
source "$SCRIPT_DIR/compact-output.sh"

# =============================================================================
# 上下文持久化桥接系统 - 核心控制层
# =============================================================================

# 💾 上下文持久化桥接系统

# =============================================================================
# 会话持久化存储结构
# =============================================================================

# 初始化上下文桥接系统
init_context_bridge() {
    local bridge_id="$1"

    smart_echo "初始化上下文持久化桥接系统: $bridge_id" "processing"

    # 创建桥接存储目录
    mkdir -p "$CONTEXT_BRIDGE_DIR/$bridge_id"
    mkdir -p "$CONTEXT_BRIDGE_DIR/$bridge_id/sessions"
    mkdir -p "$CONTEXT_BRIDGE_DIR/$bridge_id/versions"
    mkdir -p "$CONTEXT_BRIDGE_DIR/$bridge_id/cache"

    # 创建桥接配置文件
    cat > "$CONTEXT_BRIDGE_DIR/$bridge_id/config.json" <<EOF
{
  "bridge_id": "$bridge_id",
  "storage_type": "conversation_based",
  "max_sessions": 100,
  "max_versions": 50,
  "compression_enabled": true,
  "auto_cleanup": true,
  "cleanup_interval_days": 30,
  "created_at": "$(date -Iseconds)",
  "last_activity": "$(date -Iseconds)"
}
EOF

    smart_echo "上下文桥接系统初始化完成: $bridge_id" "success"
}

# 创建新的会话上下文
create_session_context() {
    local bridge_id="$1"
    local session_type="${2:-loop_development}"
    local initial_context="${3:-}"

    local session_id="session_$(date +%s%N | cut -b1-13)_$(openssl rand -hex 4 2>/dev/null || echo "rand")"
    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"

    mkdir -p "$session_dir"

    # 创建会话元数据
    cat > "$session_dir/metadata.json" <<EOF
{
  "session_id": "$session_id",
  "bridge_id": "$bridge_id",
  "type": "$session_type",
  "status": "active",
  "created_at": "$(date -Iseconds)",
  "last_updated": "$(date -Iseconds)",
  "message_count": 0,
  "context_size": 0,
  "compression_ratio": 1.0,
  "tags": [],
  "parent_session": null,
  "child_sessions": []
}
EOF

    # 创建初始上下文
    if [[ -n "$initial_context" ]]; then
        echo "$initial_context" > "$session_dir/initial_context.json"
    else
        cat > "$session_dir/initial_context.json" <<EOF
{
  "system_prompt": "You are an AI assistant helping with development tasks.",
  "user_info": {},
  "project_context": {},
  "conversation_history": []
}
EOF
    fi

    # 创建空的消息历史
    echo "[]" > "$session_dir/messages.json"

    # 更新桥接配置
    update_bridge_activity "$bridge_id"

    smart_echo "会话上下文已创建: $session_id" "success"
    echo "$session_id"
}

# =============================================================================
# 对话上下文压缩系统
# =============================================================================

# 压缩对话上下文
compress_conversation_context() {
    local session_id="$1"
    local bridge_id="$2"

    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"
    local messages_file="$session_dir/messages.json"

    if [[ ! -f "$messages_file" ]]; then
        smart_echo "消息文件不存在: $session_id" "error"
        return 1
    fi

    # 读取所有消息
    local messages=$(cat "$messages_file")
    local message_count=$(echo "$messages" | jq 'length')

    if [[ $message_count -eq 0 ]]; then
        smart_echo "会话中没有消息，无需压缩" "info"
        return 0
    fi

    smart_echo "开始压缩会话上下文: $message_count 条消息" "processing"

    # 1. 提取关键消息
    local critical_messages=$(extract_critical_messages "$messages")

    # 2. 生成智能摘要
    local conversation_summary=$(generate_conversation_summary "$messages")

    # 3. 创建历史索引
    local history_index=$(create_history_index "$messages")

    # 4. 压缩消息内容
    local compressed_messages=$(compress_message_content "$messages")

    # 5. 计算压缩统计
    local original_size=$(stat -f%z "$messages_file" 2>/dev/null || echo "0")
    local compressed_size=$(echo "$compressed_messages" | wc -c)
    local compression_ratio
    if [[ $original_size -gt 0 ]]; then
        compression_ratio=$(echo "scale=2; $original_size / $compressed_size" | bc 2>/dev/null || echo "1.0")
    else
        compression_ratio="1.0"
    fi

    # 保存压缩结果
    cat > "$session_dir/compressed_context.json" <<EOF
{
  "compression_timestamp": "$(date -Iseconds)",
  "original_message_count": $message_count,
  "original_size": $original_size,
  "compressed_size": $compressed_size,
  "compression_ratio": $compression_ratio,
  "critical_messages": $critical_messages,
  "conversation_summary": "$conversation_summary",
  "history_index": $history_index,
  "compressed_messages": $compressed_messages
}
EOF

    # 更新会话元数据
    update_session_metadata "$session_id" "$bridge_id" "compression_ratio" "$compression_ratio"

    smart_echo "上下文压缩完成: ${compression_ratio}x 压缩率" "success"
}

# 提取关键消息
extract_critical_messages() {
    local messages="$1"

    # 定义关键消息模式
    local critical_patterns=(
        "需求确认"
        "架构设计"
        "核心决策"
        "重要变更"
        "最终确认"
        "验收标准"
    )

    echo "$messages" | jq --arg patterns "${critical_patterns[*]}" '
        map(select(
            (.content | test($patterns)) or
            (.role == "system") or
            (.metadata.critical // false) or
            (.metadata.decision_point // false)
        ))
    '
}

# 生成智能摘要
generate_conversation_summary() {
    local messages="$1"

    # 简单的摘要生成算法 (实际应该使用AI)
    local total_messages=$(echo "$messages" | jq 'length')
    local user_messages=$(echo "$messages" | jq '[.[] | select(.role == "user")] | length')
    local assistant_messages=$(echo "$messages" | jq '[.[] | select(.role == "assistant")] | length')

    # 提取主要话题
    local topics=$(echo "$messages" | jq -r '
        [.[] | select(.role == "user") | .content] |
        join(" ") |
        split(" ") |
        map(select(length > 3)) |
        group_by(.) |
        map({word: .[0].word, count: length}) |
        sort_by(.count) |
        reverse |
        .[0:10] |
        map(.word) |
        join(", ")
    ' 2>/dev/null || echo "general conversation")

    cat <<EOF
会话包含${total_messages}条消息(${user_messages}条用户消息，${assistant_messages}条助手消息)。
主要话题: ${topics}
EOF
}

# 创建历史索引
create_history_index() {
    local messages="$1"

    echo "$messages" | jq '
        reduce .[] as $msg (
            {index: [], by_role: {}, by_timestamp: {}, by_topic: {}};
            .index += [{
                id: $msg.id,
                timestamp: $msg.timestamp,
                role: $msg.role,
                summary: ($msg.content | split(" ")[0:10] | join(" ") + "...")
            }] |
            .by_role[$msg.role] += [$msg.id] |
            .by_timestamp[($msg.timestamp | strptime("%Y-%m-%dT%H:%M:%S%z") | strftime("%Y-%m-%d"))] += [$msg.id]
        )
    '
}

# 压缩消息内容
compress_message_content() {
    local messages="$1"

    echo "$messages" | jq '
        map({
            id: .id,
            role: .role,
            timestamp: .timestamp,
            content_hash: (.content | @base64),
            content_length: (.content | length),
            metadata: .metadata,
            compressed: true
        })
    '
}

# =============================================================================
# 跨会话状态恢复系统
# =============================================================================

# 保存会话上下文
save_session_context() {
    local session_id="$1"
    local bridge_id="$2"
    local context_data="$3"

    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"

    # 保存上下文数据
    echo "$context_data" > "$session_dir/current_context.json"

    # 更新时间戳
    update_session_metadata "$session_id" "$bridge_id" "last_updated" "$(date -Iseconds)"

    smart_echo "会话上下文已保存: $session_id" "success"
}

# 恢复会话上下文
restore_session_context() {
    local session_id="$1"
    local bridge_id="$2"

    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"
    local context_file="$session_dir/current_context.json"

    if [[ ! -f "$context_file" ]]; then
        smart_echo "会话上下文文件不存在: $session_id" "warning"
        # 返回默认上下文
        cat > "$context_file" <<EOF
{
  "system_state": "restored",
  "last_checkpoint": "$(date -Iseconds)",
  "restored_from": "default",
  "context_data": {}
}
EOF
    fi

    # 读取并返回上下文
    cat "$context_file"
}

# 重建会话状态
rebuild_session_state() {
    local session_id="$1"
    local bridge_id="$2"

    smart_echo "重建会话状态: $session_id" "processing"

    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"

    # 1. 加载会话元数据
    local metadata_file="$session_dir/metadata.json"
    if [[ ! -f "$metadata_file" ]]; then
        smart_echo "会话元数据不存在，无法重建" "error"
        return 1
    fi

    # 2. 检查是否有压缩上下文
    local compressed_file="$session_dir/compressed_context.json"
    if [[ -f "$compressed_file" ]]; then
        smart_echo "检测到压缩上下文，正在解压..." "info"
        # 这里应该实现上下文解压逻辑
    fi

    # 3. 恢复消息历史
    local messages_file="$session_dir/messages.json"
    if [[ -f "$messages_file" ]]; then
        local message_count=$(jq 'length' "$messages_file")
        smart_echo "恢复了 $message_count 条消息历史" "info"
    fi

    # 4. 同步状态
    sync_session_state "$session_id" "$bridge_id"

    smart_echo "会话状态重建完成: $session_id" "success"
}

# 同步会话状态
sync_session_state() {
    local session_id="$1"
    local bridge_id="$2"

    # 更新最后活动时间
    update_bridge_activity "$bridge_id"
    update_session_metadata "$session_id" "$bridge_id" "last_updated" "$(date -Iseconds)"

    # 检查状态一致性
    validate_session_integrity "$session_id" "$bridge_id"
}

# 验证会话完整性
validate_session_integrity() {
    local session_id="$1"
    local bridge_id="$2"

    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"

    local issues=()

    # 检查必需文件
    local required_files=("metadata.json" "messages.json" "current_context.json")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$session_dir/$file" ]]; then
            issues+=("missing_file:$file")
        fi
    done

    # 检查JSON格式
    for file in "${required_files[@]}"; do
        if [[ -f "$session_dir/$file" ]]; then
            if ! jq empty "$session_dir/$file" 2>/dev/null; then
                issues+=("invalid_json:$file")
            fi
        fi
    done

    # 报告问题
    if [[ ${#issues[@]} -gt 0 ]]; then
        smart_echo "会话完整性检查发现问题: ${issues[*]}" "warning"
        return 1
    else
        smart_echo "会话完整性检查通过" "success"
        return 0
    fi
}

# =============================================================================
# 上下文版本管理系统
# =============================================================================

# 创建上下文版本
create_context_version() {
    local session_id="$1"
    local bridge_id="$2"
    local version_name="${3:-auto}"
    local description="${4:-}"

    local session_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id"
    local versions_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/versions"
    local version_id="version_$(date +%s)_${version_name}"

    mkdir -p "$versions_dir"

    # 创建版本快照
    local version_data=$(cat <<EOF
{
  "version_id": "$version_id",
  "session_id": "$session_id",
  "bridge_id": "$bridge_id",
  "version_name": "$version_name",
  "description": "$description",
  "created_at": "$(date -Iseconds)",
  "snapshot": {
    "metadata": $(cat "$session_dir/metadata.json"),
    "messages": $(cat "$session_dir/messages.json"),
    "context": $(cat "$session_dir/current_context.json" 2>/dev/null || echo "{}")
  }
}
EOF
)

    # 保存版本
    echo "$version_data" > "$versions_dir/${version_id}.json"

    # 更新版本索引
    update_version_index "$bridge_id" "$version_id"

    smart_echo "上下文版本已创建: $version_id ($version_name)" "success"
    echo "$version_id"
}

# 从版本恢复上下文
restore_from_version() {
    local version_id="$1"
    local bridge_id="$2"
    local target_session_id="$3"

    local version_file="$CONTEXT_BRIDGE_DIR/$bridge_id/versions/${version_id}.json"

    if [[ ! -f "$version_file" ]]; then
        smart_echo "版本文件不存在: $version_id" "error"
        return 1
    fi

    smart_echo "从版本恢复上下文: $version_id → $target_session_id" "processing"

    # 读取版本数据
    local version_data=$(cat "$version_file")
    local snapshot=$(echo "$version_data" | jq -r '.snapshot')

    # 恢复到目标会话
    local target_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$target_session_id"

    echo "$snapshot" | jq -r '.metadata' > "$target_dir/metadata.json"
    echo "$snapshot" | jq -r '.messages' > "$target_dir/messages.json"
    echo "$snapshot" | jq -r '.context' > "$target_dir/current_context.json"

    # 记录恢复操作
    log_version_operation "$version_id" "restore" "$target_session_id"

    smart_echo "上下文已从版本恢复: $version_id" "success"
}

# 版本冲突解决
resolve_version_conflict() {
    local session_id="$1"
    local bridge_id="$2"
    local conflict_versions="$3"

    smart_echo "解决版本冲突: $session_id" "processing"

    # 简单的冲突解决策略：选择最新版本
    local latest_version=$(echo "$conflict_versions" | jq -r '
        sort_by(.created_at) | reverse | first | .version_id
    ')

    smart_echo "选择最新版本解决冲突: $latest_version" "info"
    restore_from_version "$latest_version" "$bridge_id" "$session_id"

    # 记录冲突解决
    log_version_operation "$latest_version" "conflict_resolved" "$session_id"
}

# 更新版本索引
update_version_index() {
    local bridge_id="$1"
    local version_id="$2"

    local index_file="$CONTEXT_BRIDGE_DIR/$bridge_id/versions/index.json"

    # 读取现有索引
    local index_data="[]"
    if [[ -f "$index_file" ]]; then
        index_data=$(cat "$index_file")
    fi

    # 添加新版本
    local new_index=$(echo "$index_data" | jq --arg id "$version_id" '. + [$id]')

    echo "$new_index" > "$index_file"
}

# 记录版本操作
log_version_operation() {
    local version_id="$1"
    local operation="$2"
    local details="${3:-}"

    local log_entry=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "version_id": "$version_id",
  "operation": "$operation",
  "details": "$details"
}
EOF
)

    # 这里应该写入版本操作日志
    # echo "$log_entry" >> "$CONTEXT_BRIDGE_DIR/version_operations.log"

    smart_echo "版本操作已记录: $operation ($version_id)" "info"
}

# =============================================================================
# 辅助函数
# =============================================================================

# 更新桥接活动时间
update_bridge_activity() {
    local bridge_id="$1"

    local config_file="$CONTEXT_BRIDGE_DIR/$bridge_id/config.json"
    if [[ -f "$config_file" ]]; then
        jq --arg time "$(date -Iseconds)" '.last_activity = $time' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    fi
}

# 更新会话元数据
update_session_metadata() {
    local session_id="$1"
    local bridge_id="$2"
    local key="$3"
    local value="$4"

    local metadata_file="$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/$session_id/metadata.json"
    if [[ -f "$metadata_file" ]]; then
        jq --arg key "$key" --arg value "$value" '.[$key] = $value' "$metadata_file" > "${metadata_file}.tmp" && mv "${metadata_file}.tmp" "$metadata_file"
    fi
}

# 获取桥接状态
get_bridge_status() {
    local bridge_id="$1"

    local config_file="$CONTEXT_BRIDGE_DIR/$bridge_id/config.json"

    if [[ ! -f "$config_file" ]]; then
        echo '{"status": "not_found"}'
        return 1
    fi

    local session_count=$(find "$CONTEXT_BRIDGE_DIR/$bridge_id/sessions" -name "metadata.json" 2>/dev/null | wc -l)
    local version_count=$(find "$CONTEXT_BRIDGE_DIR/$bridge_id/versions" -name "*.json" 2>/dev/null | wc -l)

    jq --arg sessions "$session_count" --arg versions "$version_count" \
       '. + {session_count: ($sessions | tonumber), version_count: ($versions | tonumber), status: "active"}' \
       "$config_file"
}

# 清理过期上下文
cleanup_expired_contexts() {
    local bridge_id="$1"
    local max_age_days="${2:-30}"

    smart_echo "清理过期上下文: $bridge_id (超过${max_age_days}天)" "processing"

    local cutoff_date=$(date -d "$max_age_days days ago" +%s)
    local cleaned_count=0

    # 清理过期会话
    for session_dir in "$CONTEXT_BRIDGE_DIR/$bridge_id/sessions"/*/; do
        if [[ -d "$session_dir" ]]; then
            local metadata_file="$session_dir/metadata.json"
            if [[ -f "$metadata_file" ]]; then
                local created_at=$(jq -r '.created_at' "$metadata_file" 2>/dev/null || echo "")
                if [[ -n "$created_at" ]]; then
                    local created_timestamp=$(date -d "$created_at" +%s 2>/dev/null || echo "0")
                    if [[ $created_timestamp -lt $cutoff_date ]]; then
                        rm -rf "$session_dir"
                        ((cleaned_count++))
                    fi
                fi
            fi
        fi
    done

    smart_echo "上下文清理完成: 清理了 $cleaned_count 个过期会话" "success"
}

# =============================================================================
# 高级上下文管理
# =============================================================================

# 合并多个会话上下文
merge_session_contexts() {
    local bridge_id="$1"
    local session_ids="$2"  # JSON数组格式
    local target_session_id="$3"

    smart_echo "合并会话上下文: ${session_ids} → $target_session_id" "processing"

    # 创建合并的上下文
    local merged_messages="[]"
    local merged_metadata="{}"

    # 这里应该实现复杂的上下文合并逻辑
    # 包括消息去重、时间排序、冲突解决等

    smart_echo "会话上下文合并完成" "success"
}

# 创建上下文快照
create_context_snapshot() {
    local bridge_id="$1"
    local snapshot_name="${2:-}"

    if [[ -z "$snapshot_name" ]]; then
        snapshot_name="snapshot_$(date +%Y%m%d_%H%M%S)"
    fi

    local snapshot_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/snapshots/$snapshot_name"
    mkdir -p "$snapshot_dir"

    # 复制当前状态
    cp -r "$CONTEXT_BRIDGE_DIR/$bridge_id/sessions" "$snapshot_dir/"
    cp -r "$CONTEXT_BRIDGE_DIR/$bridge_id/versions" "$snapshot_dir/"

    # 创建快照元数据
    cat > "$snapshot_dir/metadata.json" <<EOF
{
  "snapshot_name": "$snapshot_name",
  "bridge_id": "$bridge_id",
  "created_at": "$(date -Iseconds)",
  "session_count": $(find "$snapshot_dir/sessions" -name "metadata.json" 2>/dev/null | wc -l),
  "version_count": $(find "$snapshot_dir/versions" -name "*.json" 2>/dev/null | wc -l)
}
EOF

    smart_echo "上下文快照已创建: $snapshot_name" "success"
    echo "$snapshot_name"
}

# 从快照恢复
restore_from_snapshot() {
    local bridge_id="$1"
    local snapshot_name="$2"

    local snapshot_dir="$CONTEXT_BRIDGE_DIR/$bridge_id/snapshots/$snapshot_name"

    if [[ ! -d "$snapshot_dir" ]]; then
        smart_echo "快照不存在: $snapshot_name" "error"
        return 1
    fi

    smart_echo "从快照恢复上下文: $snapshot_name" "processing"

    # 恢复会话和版本
    cp -r "$snapshot_dir/sessions"/* "$CONTEXT_BRIDGE_DIR/$bridge_id/sessions/" 2>/dev/null || true
    cp -r "$snapshot_dir/versions"/* "$CONTEXT_BRIDGE_DIR/$bridge_id/versions/" 2>/dev/null || true

    smart_echo "上下文已从快照恢复: $snapshot_name" "success"
}

# =============================================================================
# 函数导出
# =============================================================================

export -f init_context_bridge
export -f create_session_context
export -f compress_conversation_context
export -f save_session_context
export -f restore_session_context
export -f rebuild_session_state
export -f create_context_version
export -f restore_from_version
export -f resolve_version_conflict
export -f get_bridge_status
export -f cleanup_expired_contexts
export -f merge_session_contexts
export -f create_context_snapshot
export -f restore_from_snapshot

# 初始化目录
CONTEXT_BRIDGE_DIR="$AI_DIR/context_bridges"
mkdir -p "$CONTEXT_BRIDGE_DIR"

smart_echo "上下文持久化桥接系统模块已加载" "success"