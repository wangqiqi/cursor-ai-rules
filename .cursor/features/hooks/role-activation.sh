#!/bin/bash

# 🎭 角色激活钩子
# 在.cursor规则执行前自动激活当前项目角色
# 支持项目特定角色配置和全局角色回退

HOOK_EVENT="$1"
HOOK_DATA="$2"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

# 再次向上查找项目根目录
if [[ ! -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
fi

# 日志函数
log() {
    echo "[HOOK:role-activation] $(date '+%H:%M:%S') $*" >&2
}

# 错误处理函数
error_exit() {
    log "❌ 错误: $1"
    exit 1
}

# 检查Node.js环境
check_nodejs() {
    if ! command -v node &> /dev/null; then
        log "⚠️ Node.js未找到，跳过角色激活"
        return 1
    fi
    return 0
}

# 获取项目角色配置
get_project_role() {
    local project_config="$PROJECT_ROOT/.cursor-project.json"
    log "🔍 查找配置文件: $project_config"

    if [[ ! -f "$project_config" ]]; then
        # 创建默认的项目配置文件
        local default_config="{
  \"currentRole\": \"professional_assistant\",
  \"lastUpdated\": \"$(date -Iseconds)\",
  \"projectPath\": \"$PROJECT_ROOT\"
}"
        echo "$default_config" > "$project_config"
        log "✅ 创建默认项目角色配置: professional_assistant"
        echo "professional_assistant"
        return 0
    fi

    # 使用简单的文本解析提取角色
    local role
    role=$(grep -o '"currentRole"\s*:\s*"[^"]*"' "$project_config" 2>/dev/null | sed 's/.*"currentRole"\s*:\s*"\([^"]*\)".*/\1/' 2>/dev/null)
    log "📋 解析结果: '$role'"

    if [[ -n "$role" ]]; then
        log "✅ 读取项目角色配置: $role"
        echo "$role"
        return 0
    else
        log "⚠️ 无法解析角色配置，使用默认角色"
        echo "professional_assistant"
        return 0
    fi
}

# 激活角色
activate_role() {
    local target_role="$1"

    if [[ -z "$target_role" ]]; then
        log "⚠️ 角色为空，跳过激活"
        return 1
    fi

    log "🎭 激活角色: $target_role"

    # 检查角色管理器脚本是否存在
    local role_manager="$CURSOR_DIR/../commands/role-manager.js"
    if [[ ! -f "$role_manager" ]]; then
        error_exit "角色管理器不存在: $role_manager"
    fi

    # 使用Node.js执行角色切换
    local result
    result=$(cd "$PROJECT_ROOT" && node "$role_manager" switch "$target_role" "auto_activation" 2>&1)

    if [[ $? -eq 0 ]]; then
        log "✅ 角色激活成功: $target_role"
        echo "$result" | grep -E "(成功|success|activated)" | head -1
        return 0
    else
        log "❌ 角色激活失败: $result"
        return 1
    fi
}

# 显示当前角色状态
show_current_role() {
    log "🔍 检查当前角色状态..."

    local role_manager="$CURSOR_DIR/commands/role-manager.js"
    if [[ ! -f "$role_manager" ]]; then
        log "⚠️ 角色管理器不存在"
        return 1
    fi

    # 获取当前角色信息
    local current_info
    current_info=$(cd "$PROJECT_ROOT" && node -e "
        const RoleManager = require('./commands/role-manager');
        const rm = new RoleManager('$CURSOR_DIR', '$PROJECT_ROOT');
        rm.initialize().then(() => {
            const info = rm.getCurrentRole();
            if (info.success) {
                console.log(info.role.name + ' (' + info.role.id + ')');
            } else {
                console.log('未知角色');
            }
        }).catch(err => {
            console.log('获取失败: ' + err.message);
        });
    " 2>/dev/null)

    if [[ -n "$current_info" && "$current_info" != "获取失败"* ]]; then
        log "🎭 当前角色: $current_info"
    else
        log "⚠️ 无法获取当前角色状态"
    fi
}

# 主处理逻辑
main() {
    log "🚀 开始角色激活检查..."

    # 检查是否是相关的钩子事件
    case "$HOOK_EVENT" in
        "beforeSubmitPrompt")
            log "📝 检测到提示提交，执行角色激活检查..."

            # 检查Node.js环境
            if ! check_nodejs; then
                return 1
            fi

            # 检查输入是否包含.cursor规则调用
            if [[ "$HOOK_DATA" == *rule* ]] || [[ "$HOOK_DATA" == *script* ]] || [[ "$HOOK_DATA" == *skill* ]] || [[ "$HOOK_DATA" == *hook* ]] || [[ "$HOOK_DATA" == *master* ]]; then
                log "🎯 检测到.cursor规则调用，执行角色激活"

                # 显示当前角色状态
                show_current_role

                # 获取项目角色配置
                local project_role
                if project_role=$(get_project_role); then
                    # 激活项目角色
                    if activate_role "$project_role"; then
                        log "✅ 项目角色激活完成: $project_role"
                    else
                        log "⚠️ 项目角色激活失败，使用默认角色"
                    fi
                else
                    log "ℹ️ 无项目角色配置，使用当前角色"
                fi
            else
                log "🔄 普通提示，确保角色激活"

                # 即使不是.cursor调用，也要确保角色是激活的
                local project_role
                if project_role=$(get_project_role); then
                    # 强制激活角色，确保状态最新
                    if activate_role "$project_role"; then
                        log "✅ 角色激活确认: $project_role"
                    else
                        log "⚠️ 角色激活失败，请检查配置"
                    fi
                else
                    log "ℹ️ 无项目角色配置"
                fi
            fi
            ;;

        "onSessionStart")
            log "🎪 会话开始，初始化角色系统"

            # 检查Node.js环境
            if ! check_nodejs; then
                return 1
            fi

            # 显示当前角色状态
            show_current_role

            # 尝试激活项目角色
            local project_role
            if project_role=$(get_project_role); then
                activate_role "$project_role" || log "⚠️ 会话开始角色激活失败"
            fi
            ;;

        "onConversationStart")
            log "💬 新对话框开始，自动激活角色"

            # 检查Node.js环境
            if ! check_nodejs; then
                return 1
            fi

            # 直接激活项目角色，不需要显示状态
            local project_role
            if project_role=$(get_project_role); then
                if activate_role "$project_role"; then
                    log "✅ 对话框角色激活成功: $project_role"
                else
                    log "⚠️ 对话框角色激活失败"
                fi
            else
                log "ℹ️ 对话框中无项目角色配置"
            fi
            ;;

        *)
            log "ℹ️ 非目标钩子事件: $HOOK_EVENT，跳过角色激活"
            ;;
    esac

    log "🏁 角色激活检查完成"
    return 0
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi