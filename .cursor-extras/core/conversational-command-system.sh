#!/bin/bash

# 🎯 Cursor AI Rules - 对话式命令系统
# 实现/vibe start/prd/code/test/deploy命令，支持快速原型开发

set -e

# 加载依赖
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 加载统一路径配置
source "$SCRIPT_DIR/../../.cursor/core/path-config.sh"  # 统一路径配置
source "$SCRIPT_DIR/agent-orchestration-engine.sh"
source "$SCRIPT_DIR/vibe-services-integration.sh"
source "$SCRIPT_DIR/performance-cache.sh"
source "$SCRIPT_DIR/compact-output.sh"

# VIBE命令配置
VIBE_COMMAND_DIR="$SERVICES_DIR"
VIBE_SESSIONS_DIR="$VIBE_COMMAND_DIR/sessions"
VIBE_PROJECTS_DIR="$VIBE_COMMAND_DIR/projects"

# VIBE阶段定义
declare -A VIBE_PHASES=(
    ["discovery"]="0_discovery - 需求发现与分析"
    ["design"]="1_design - 系统设计与规划"
    ["implementation"]="2_implementation - 代码实现"
    ["validation"]="3_validation - 测试与验证"
    ["deployment"]="4_deployment - 部署与发布"
)

# 初始化对话式命令系统
init_conversational_command_system() {
    smart_echo "初始化对话式命令系统..." "processing"

    # 创建目录结构
    mkdir -p "$VIBE_COMMAND_DIR"
    mkdir -p "$VIBE_SESSIONS_DIR"
    mkdir -p "$VIBE_PROJECTS_DIR"

    # 初始化会话管理
    init_vibe_sessions

    # 初始化项目管理
    init_vibe_projects

    # 注册VIBE命令
    register_vibe_commands

    smart_echo "对话式命令系统初始化完成" "success"
}

# 初始化VIBE会话管理
init_vibe_sessions() {
    local sessions_index="$VIBE_SESSIONS_DIR/index.json"

    if [[ ! -f "$sessions_index" ]]; then
        cat > "$sessions_index" <<EOF
{
  "sessions": {},
  "active_session": null,
  "total_sessions": 0
}
EOF
    fi
}

# 初始化VIBE项目管理
init_vibe_projects() {
    local projects_index="$VIBE_PROJECTS_DIR/index.json"

    if [[ ! -f "$projects_index" ]]; then
        cat > "$projects_index" <<EOF
{
  "projects": {},
  "active_project": null,
  "total_projects": 0
}
EOF
    fi
}

# 注册VIBE命令
register_vibe_commands() {
    # 创建命令映射文件
    local commands_file="$VIBE_COMMAND_DIR/commands.json"

    if [[ ! -f "$commands_file" ]]; then
        cat > "$commands_file" <<EOF
{
  "commands": {
    "start": {
      "description": "启动新的VIBE开发会话",
      "syntax": "/vibe start <project_name> [template]",
      "examples": [
        "/vibe start my-app",
        "/vibe start ecommerce-app react",
        "/vibe start api-server fastapi"
      ],
      "handler": "handle_vibe_start",
      "requires_session": false
    },
    "prd": {
      "description": "生成产品需求文档(PRD)",
      "syntax": "/vibe prd <requirements>",
      "examples": [
        "/vibe prd 开发一个任务管理应用",
        "/vibe prd 创建用户注册和登录功能"
      ],
      "handler": "handle_vibe_prd",
      "requires_session": true
    },
    "code": {
      "description": "生成代码实现",
      "syntax": "/vibe code [component|api|model|test]",
      "examples": [
        "/vibe code",
        "/vibe code UserComponent",
        "/vibe code /api/users"
      ],
      "handler": "handle_vibe_code",
      "requires_session": true
    },
    "test": {
      "description": "生成和运行测试",
      "syntax": "/vibe test [unit|integration|e2e]",
      "examples": [
        "/vibe test",
        "/vibe test unit",
        "/vibe test e2e login"
      ],
      "handler": "handle_vibe_test",
      "requires_session": true
    },
    "deploy": {
      "description": "部署应用",
      "syntax": "/vibe deploy [staging|production]",
      "examples": [
        "/vibe deploy",
        "/vibe deploy staging",
        "/vibe deploy production"
      ],
      "handler": "handle_vibe_deploy",
      "requires_session": true
    },
    "status": {
      "description": "查看VIBE项目状态",
      "syntax": "/vibe status",
      "examples": [
        "/vibe status"
      ],
      "handler": "handle_vibe_status",
      "requires_session": false
    },
    "switch": {
      "description": "切换VIBE项目或会话",
      "syntax": "/vibe switch <project_name|session_id>",
      "examples": [
        "/vibe switch my-app",
        "/vibe switch session_123"
      ],
      "handler": "handle_vibe_switch",
      "requires_session": false
    }
  },
  "version": "1.0",
  "last_updated": "$(date -Iseconds)"
}
EOF
    fi
}

# 🎯 VIBE命令处理器

# 处理/vibe命令
process_vibe_command() {
    local command_line="$1"

    smart_echo "处理VIBE命令: $command_line" "processing"

    # 解析命令
    local command_args=($command_line)
    local subcommand="${command_args[1]}"

    # 检查命令是否存在
    if ! is_vibe_command_valid "$subcommand"; then
        smart_echo "未知的VIBE命令: $subcommand" "error"
        show_vibe_help
        return 1
    fi

    # 获取命令处理器
    local handler=$(get_vibe_command_handler "$subcommand")
    local requires_session=$(get_vibe_command_requires_session "$subcommand")

    # 检查会话要求
    if [[ "$requires_session" == "true" ]]; then
        local active_session=$(get_active_vibe_session)
        if [[ -z "$active_session" ]]; then
            smart_echo "此命令需要激活的VIBE会话，请先运行 /vibe start" "warning"
            return 1
        fi
    fi

    # 执行命令处理器
    $handler "${command_args[@]:1}"

    smart_echo "VIBE命令处理完成" "success"
}

# 检查VIBE命令是否有效
is_vibe_command_valid() {
    local command="$1"

    jq -r ".commands.\"$command\" // empty" "$VIBE_COMMAND_DIR/commands.json" | grep -q "."
}

# 获取VIBE命令处理器
get_vibe_command_handler() {
    local command="$1"

    jq -r ".commands.\"$command\".handler // empty" "$VIBE_COMMAND_DIR/commands.json" 2>/dev/null || echo ""
}

# 获取VIBE命令是否需要会话
get_vibe_command_requires_session() {
    local command="$1"

    jq -r ".commands.\"$command\".requires_session // false" "$VIBE_COMMAND_DIR/commands.json" 2>/dev/null || echo "false"
}

# 🎯 VIBE子命令处理器

# /vibe start - 启动新会话
handle_vibe_start() {
    local args=("$@")
    local project_name="${args[1]}"
    local template="${args[2]:-auto}"

    if [[ -z "$project_name" ]]; then
        smart_echo "错误: 请提供项目名称" "error"
        smart_echo "用法: /vibe start <project_name> [template]" "info"
        return 1
    fi

    smart_echo "🚀 启动VIBE开发会话: $project_name" "info"

    # 创建新项目
    local project_id=$(create_vibe_project "$project_name" "$template")
    if [[ -z "$project_id" ]]; then
        smart_echo "创建项目失败" "error"
        return 1
    fi

    # 创建新会话
    local session_id=$(create_vibe_session "$project_id")
    if [[ -z "$session_id" ]]; then
        smart_echo "创建会话失败" "error"
        return 1
    fi

    # 设置为活动会话
    set_active_vibe_session "$session_id"

    # 初始化项目目录结构
    init_vibe_project_structure "$project_id"

    smart_echo "✅ VIBE会话已启动!" "success"
    smart_echo "📋 项目ID: $project_id" "info"
    smart_echo "🔄 会话ID: $session_id" "info"
    smart_echo "📁 项目目录: $CURSOR_GROWTH/vibe_commands/projects/$project_id" "info"
    smart_echo "" "info"
    smart_echo "💡 接下来你可以运行:" "info"
    smart_echo "   /vibe prd [需求描述]  - 生成产品需求文档" "info"
    smart_echo "   /vibe status           - 查看项目状态" "info"
}

# /vibe prd - 生成PRD
handle_vibe_prd() {
    local requirements="${*:1}"

    if [[ -z "$requirements" ]]; then
        smart_echo "错误: 请提供需求描述" "error"
        smart_echo "用法: /vibe prd <需求描述>" "info"
        return 1
    fi

    smart_echo "📋 生成产品需求文档..." "processing"

    local active_session=$(get_active_vibe_session)
    local project_id=$(get_session_project "$active_session")

    # 调用代理编排引擎生成PRD
    local prd_task_id=$(submit_task "生成产品需求文档: $requirements" "documentation" "high")
    local prd_result=$(wait_for_task_completion "$prd_task_id")

    # 保存PRD到项目
    save_project_artifact "$project_id" "prd" "$prd_result"

    # 移动到下一个阶段
    advance_vibe_phase "$project_id" "design"

    smart_echo "✅ PRD生成完成!" "success"
    smart_echo "📄 PRD已保存到项目文档中" "info"
}

# /vibe code - 生成代码
handle_vibe_code() {
    local component="${1:-}"

    smart_echo "💻 生成代码实现..." "processing"

    local active_session=$(get_active_vibe_session)
    local project_id=$(get_session_project "$active_session")

    # 获取PRD内容
    local prd_content=$(get_project_artifact "$project_id" "prd")

    if [[ -z "$prd_content" ]]; then
        smart_echo "警告: 未找到PRD，请先运行 /vibe prd" "warning"
    fi

    # 调用代码生成服务
    local code_result=$(call_vibe_service "code_generator" "generate_code" "{\"prd\": \"$prd_content\", \"component\": \"$component\"}")

    # 保存代码到项目
    save_project_artifact "$project_id" "code" "$code_result"

    # 移动到实现阶段
    advance_vibe_phase "$project_id" "implementation"

    smart_echo "✅ 代码生成完成!" "success"
    smart_echo "🔧 代码已添加到项目中" "info"
}

# /vibe test - 生成和运行测试
handle_vibe_test() {
    local test_type="${1:-all}"

    smart_echo "🧪 生成和运行测试..." "processing"

    local active_session=$(get_active_vibe_session)
    local project_id=$(get_session_project "$active_session")

    # 获取代码内容
    local code_content=$(get_project_artifact "$project_id" "code")

    # 调用测试验证服务
    local test_result=$(call_vibe_service "test_validator" "generate_and_run_tests" "{\"code\": \"$code_content\", \"type\": \"$test_type\"}")

    # 保存测试结果
    save_project_artifact "$project_id" "tests" "$test_result"

    # 移动到验证阶段
    advance_vibe_phase "$project_id" "validation"

    smart_echo "✅ 测试完成!" "success"
    smart_echo "📊 测试结果已保存" "info"
}

# /vibe deploy - 部署应用
handle_vibe_deploy() {
    local environment="${1:-staging}"

    smart_echo "🚀 部署应用到$environment环境..." "processing"

    local active_session=$(get_active_vibe_session)
    local project_id=$(get_session_project "$active_session")

    # 调用部署管理服务
    local deploy_result=$(call_vibe_service "deployment_manager" "deploy_application" "{\"environment\": \"$environment\", \"project_id\": \"$project_id\"}")

    # 保存部署结果
    save_project_artifact "$project_id" "deployment" "$deploy_result"

    # 移动到部署阶段
    advance_vibe_phase "$project_id" "deployment"

    smart_echo "✅ 部署完成!" "success"
    smart_echo "🌐 应用已部署到$environment环境" "info"
}

# /vibe status - 查看状态
handle_vibe_status() {
    smart_echo "📊 VIBE项目状态" "info"

    local active_session=$(get_active_vibe_session)
    local active_project=$(get_active_vibe_project)

    if [[ -n "$active_session" ]]; then
        smart_echo "🔄 活动会话: $active_session" "info"

        if [[ -n "$active_project" ]]; then
            local project_info=$(get_vibe_project_info "$active_project")
            echo "$project_info" | jq -r '"📁 项目: \(.name) (\(.phase))"' 2>/dev/null || smart_echo "📁 项目信息获取失败" "warning"

            # 显示阶段进度
            show_vibe_phase_progress "$active_project"
        fi
    else
        smart_echo "⚠️  没有活动的VIBE会话" "warning"
        smart_echo "💡 请运行 /vibe start <project_name> 开始新会话" "info"
    fi

    # 显示可用项目
    show_available_vibe_projects
}

# /vibe switch - 切换项目/会话
handle_vibe_switch() {
    local target="$1"

    if [[ -z "$target" ]]; then
        smart_echo "错误: 请指定要切换到的项目或会话" "error"
        return 1
    fi

    # 尝试切换到项目
    if switch_to_vibe_project "$target"; then
        smart_echo "✅ 已切换到项目: $target" "success"
        return 0
    fi

    # 尝试切换到会话
    if switch_to_vibe_session "$target"; then
        smart_echo "✅ 已切换到会话: $target" "success"
        return 0
    fi

    smart_echo "错误: 找不到项目或会话 '$target'" "error"
    return 1
}

# 🎯 VIBE项目管理函数

# 创建VIBE项目
create_vibe_project() {
    local project_name="$1"
    local template="$2"

    local project_id="project_$(date +%s%3N)_$(openssl rand -hex 4)"

    # 创建项目目录
    local project_dir="$VIBE_PROJECTS_DIR/$project_id"
    mkdir -p "$project_dir"

    # 初始化项目元数据
    cat > "$project_dir/metadata.json" <<EOF
{
  "project_id": "$project_id",
  "name": "$project_name",
  "template": "$template",
  "phase": "discovery",
  "created_at": "$(date -Iseconds)",
  "last_updated": "$(date -Iseconds)",
  "artifacts": {},
  "progress": {
    "discovery": 0,
    "design": 0,
    "implementation": 0,
    "validation": 0,
    "deployment": 0
  }
}
EOF

    # 更新项目索引
    local temp_index=$(mktemp)
    local current_time="$(date -Iseconds)"
    jq --arg id "$project_id" --arg name "$project_name" --arg template "$template" --arg timestamp "$current_time" '.projects[$id] = {"name": $name, "template": $template, "created_at": $timestamp} | .total_projects += 1' "$VIBE_PROJECTS_DIR/index.json" > "$temp_index"
    mv "$temp_index" "$VIBE_PROJECTS_DIR/index.json"

    echo "$project_id"
}

# 创建VIBE会话
create_vibe_session() {
    local project_id="$1"

    local session_id="session_$(date +%s%3N)_$(openssl rand -hex 4)"

    # 创建会话目录
    local session_dir="$VIBE_SESSIONS_DIR/$session_id"
    mkdir -p "$session_dir"

    # 初始化会话数据
    cat > "$session_dir/session.json" <<EOF
{
  "session_id": "$session_id",
  "project_id": "$project_id",
  "created_at": "$(date -Iseconds)",
  "last_active": "$(date -Iseconds)",
  "commands_executed": [],
  "status": "active"
}
EOF

    # 更新会话索引
    local temp_index=$(mktemp)
    local current_time="$(date -Iseconds)"
    jq --arg id "$session_id" --arg project "$project_id" --arg timestamp "$current_time" '.sessions[$id] = {"project_id": $project, "created_at": $timestamp, "status": "active"} | .total_sessions += 1' "$VIBE_SESSIONS_DIR/index.json" > "$temp_index"
    mv "$temp_index" "$VIBE_SESSIONS_DIR/index.json"

    echo "$session_id"
}

# 设置活动会话
set_active_vibe_session() {
    local session_id="$1"

    local temp_index=$(mktemp)
    jq --arg session "$session_id" '.active_session = $session' "$VIBE_SESSIONS_DIR/index.json" > "$temp_index"
    mv "$temp_index" "$VIBE_SESSIONS_DIR/index.json"
}

# 获取活动会话
get_active_vibe_session() {
    jq -r '.active_session // empty' "$VIBE_SESSIONS_DIR/index.json" 2>/dev/null || echo ""
}

# 获取活动项目
get_active_vibe_project() {
    local active_session=$(get_active_vibe_session)

    if [[ -n "$active_session" ]]; then
        get_session_project "$active_session"
    else
        echo ""
    fi
}

# 获取会话关联的项目
get_session_project() {
    local session_id="$1"

    jq -r ".sessions.\"$session_id\".project_id // empty" "$VIBE_SESSIONS_DIR/index.json" 2>/dev/null || echo ""
}

# 初始化项目目录结构
init_vibe_project_structure() {
    local project_id="$1"
    local project_dir="$VIBE_PROJECTS_DIR/$project_id"

    # 创建阶段目录
    for phase in "${!VIBE_PHASES[@]}"; do
        local phase_dir="$project_dir/${phase}"
        mkdir -p "$phase_dir"

        # 创建阶段说明文件
        local phase_info="${VIBE_PHASES[$phase]}"
        cat > "$phase_dir/README.md" <<EOF
# ${phase_info#* - }

项目: $(jq -r '.name' "$project_dir/metadata.json")
阶段: $phase
创建时间: $(date -Iseconds)

## 任务清单
- [ ] 阶段目标待定

## 输出物
- 待定

## 验收标准
- 待定
EOF
    done
}

# 保存项目产物
save_project_artifact() {
    local project_id="$1"
    local artifact_type="$2"
    local content="$3"

    local project_dir="$VIBE_PROJECTS_DIR/$project_id"
    local artifact_file="$project_dir/artifacts/${artifact_type}.json"

    mkdir -p "$project_dir/artifacts"

    echo "$content" > "$artifact_file"

    # 更新项目元数据
    local temp_meta=$(mktemp)
    jq --arg type "$artifact_type" --arg timestamp "$(date -Iseconds)" '.artifacts[$type] = $timestamp | .last_updated = $timestamp' "$project_dir/metadata.json" > "$temp_meta"
    mv "$temp_meta" "$project_dir/metadata.json"
}

# 获取项目产物
get_project_artifact() {
    local project_id="$1"
    local artifact_type="$2"

    local artifact_file="$VIBE_PROJECTS_DIR/$project_id/artifacts/${artifact_type}.json"

    if [[ -f "$artifact_file" ]]; then
        cat "$artifact_file"
    else
        echo ""
    fi
}

# 前进到下一个阶段
advance_vibe_phase() {
    local project_id="$1"
    local target_phase="$2"

    local project_dir="$VIBE_PROJECTS_DIR/$project_id"
    local temp_meta=$(mktemp)

    jq --arg phase "$target_phase" --arg timestamp "$(date -Iseconds)" '.phase = $phase | .last_updated = $timestamp | .progress[$phase] = 100' "$project_dir/metadata.json" > "$temp_meta"
    mv "$temp_meta" "$project_dir/metadata.json"

    smart_echo "项目已前进到阶段: $target_phase" "info"
}

# 显示阶段进度
show_vibe_phase_progress() {
    local project_id="$1"

    local project_info=$(get_vibe_project_info "$project_id")
    local current_phase=$(echo "$project_info" | jq -r '.phase // "discovery"')

    smart_echo "📈 阶段进度:" "info"

    for phase in "${!VIBE_PHASES[@]}"; do
        local phase_name="${VIBE_PHASES[$phase]#* - }"
        local progress=$(echo "$project_info" | jq -r ".progress.\"$phase\" // 0")

        local status="⏳"
        if [[ "$phase" == "$current_phase" ]]; then
            status="🔄"
        elif (( progress >= 100 )); then
            status="✅"
        fi

        smart_echo "  $status $phase_name: ${progress}%" "info"
    done
}

# 获取项目信息
get_vibe_project_info() {
    local project_id="$1"
    cat "$VIBE_PROJECTS_DIR/$project_id/metadata.json" 2>/dev/null || echo "{}"
}

# 显示可用项目
show_available_vibe_projects() {
    smart_echo "📂 可用项目:" "info"

    local projects=$(jq -r '.projects | to_entries[] | "\(.key): \(.value.name)"' "$VIBE_PROJECTS_DIR/index.json" 2>/dev/null)

    if [[ -n "$projects" ]]; then
        echo "$projects" | while read -r line; do
            smart_echo "  • $line" "info"
        done
    else
        smart_echo "  暂无项目" "info"
    fi
}

# 切换到项目
switch_to_vibe_project() {
    local project_name="$1"

    # 查找项目ID
    local project_id=$(jq -r ".projects | to_entries[] | select(.value.name == \"$project_name\") | .key" "$VIBE_PROJECTS_DIR/index.json" 2>/dev/null | head -1)

    if [[ -n "$project_id" ]]; then
        # 查找或创建会话
        local session_id=$(jq -r ".sessions | to_entries[] | select(.value.project_id == \"$project_id\" and .value.status == \"active\") | .key" "$VIBE_SESSIONS_DIR/index.json" 2>/dev/null | head -1)

        if [[ -z "$session_id" ]]; then
            session_id=$(create_vibe_session "$project_id")
        fi

        set_active_vibe_session "$session_id"
        return 0
    fi

    return 1
}

# 切换到会话
switch_to_vibe_session() {
    local session_id="$1"

    # 检查会话是否存在
    local session_exists=$(jq -r ".sessions.\"$session_id\" // empty" "$VIBE_SESSIONS_DIR/index.json")

    if [[ -n "$session_exists" ]]; then
        set_active_vibe_session "$session_id"
        return 0
    fi

    return 1
}

# 等待任务完成
wait_for_task_completion() {
    local task_id="$1"
    local timeout=60  # 60秒超时

    local elapsed=0
    while (( elapsed < timeout )); do
        local status=$(get_task_status "$task_id")

        case "$status" in
            "completed")
                # 返回任务结果（这里简化处理）
                echo "任务 $task_id 已完成"
                return 0
                ;;
            "failed")
                echo "任务 $task_id 执行失败"
                return 1
                ;;
            "pending"|"assigned"|"executing")
                sleep 2
                ((elapsed += 2))
                ;;
            *)
                sleep 2
                ((elapsed += 2))
                ;;
        esac
    done

    echo "任务 $task_id 等待超时"
    return 1
}

# 显示VIBE帮助
show_vibe_help() {
    smart_echo "=== 🎯 VIBE对话式开发系统 ===" "info"
    smart_echo "" "info"
    smart_echo "📋 可用命令:" "info"
    smart_echo "  /vibe start <项目名> [模板]  - 启动新项目" "info"
    smart_echo "  /vibe prd <需求描述>        - 生成PRD" "info"
    smart_echo "  /vibe code [组件]           - 生成代码" "info"
    smart_echo "  /vibe test [类型]           - 生成测试" "info"
    smart_echo "  /vibe deploy [环境]         - 部署应用" "info"
    smart_echo "  /vibe status                - 查看状态" "info"
    smart_echo "  /vibe switch <项目>         - 切换项目" "info"
    smart_echo "" "info"
    smart_echo "💡 示例:" "info"
    smart_echo "  /vibe start my-app react" "info"
    smart_echo "  /vibe prd 开发任务管理应用" "info"
    smart_echo "  /vibe code UserComponent" "info"
    smart_echo "  /vibe test unit" "info"
    smart_echo "  /vibe deploy production" "info"
}

# 导出函数
export -f init_conversational_command_system
export -f process_vibe_command
export -f show_vibe_help

# 初始化
init_conversational_command_system