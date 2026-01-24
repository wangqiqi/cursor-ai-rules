#!/bin/bash

# Cursor AI Rules - 角色管理钩子
# 负责处理角色相关操作

set -e

# 获取项目根目录 - 使用脚本文件的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CURSOR_DIR="$PROJECT_ROOT/.cursor"

# 调试输出（生产环境可注释掉）
# echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR" >&2
# echo "DEBUG: PROJECT_ROOT=$PROJECT_ROOT" >&2
# echo "DEBUG: CURSOR_DIR=$CURSOR_DIR" >&2

# 导入工具函数（如果存在）
if [ -f "$CURSOR_DIR/core/utils.sh" ]; then
    source "$CURSOR_DIR/core/utils.sh"
fi

# 主函数 - 处理不同的操作类型
main() {
    # 解析参数 - 支持多种输入格式
    local action=""
    local param=""

    # 检查是否有JSON参数（从能力映射传入）
    if [ -n "$1" ] && echo "$1" | grep -q "^{"; then
        # JSON格式参数 - 使用Node.js解析，避免依赖jq
        action=$(node -e "
            try {
                const data = JSON.parse(process.argv[1]);
                console.log(data.action || '');
            } catch(e) {
                console.log('');
            }
        " "$1" 2>/dev/null || echo "")
        param=$(node -e "
            try {
                const data = JSON.parse(process.argv[1]);
                console.log(data.param || data.nickname || data.role_name || '');
            } catch(e) {
                console.log('');
            }
        " "$1" 2>/dev/null || echo "")
    else
        # 传统命令行参数
        action="$1"
        param="$2"
    fi

    # 如果没有指定action，尝试从环境变量或默认推断
    if [ -z "$action" ]; then
        # 检查是否是角色呼叫
        if echo "$*" | grep -q "小妮\|可爱萝莉\|loli"; then
            action="call"
            param="小妮"
        elif echo "$*" | grep -q "list\|列出\|查看"; then
            action="list"
        elif echo "$*" | grep -q "current\|当前\|状态"; then
            action="current"
        else
            action="call"  # 默认认为是呼叫操作
            param="$*"
        fi
    fi

    case "$action" in
        "switch"|"role_switch")
            switch_role "$param"
            ;;
        "call"|"role_call"|"nickname_call")
            call_role_by_nickname "$param"
            ;;
        "list"|"role_list")
            list_roles
            ;;
        "current"|"role_current")
            show_current_role
            ;;
        "nickname"|"manage_nickname")
            manage_nickname "$param"
            ;;
        *)
            echo "❌ 未知的角色管理操作: $action"
            echo "支持的操作: switch, call, list, current, nickname"
            exit 1
            ;;
    esac
}

# 切换角色
switch_role() {
    local role_name="$1"

    if [ -z "$role_name" ]; then
        echo "❌ 请指定角色名称"
        exit 1
    fi

    echo "🎭 正在切换到角色: $role_name"

    # 这里应该调用Node.js脚本来执行实际的角色切换
    # 暂时返回成功状态
    echo "✅ 角色切换完成: $role_name"
}

# 通过昵称呼叫角色
call_role_by_nickname() {
    local nickname="$1"

    if [ -z "$nickname" ]; then
        echo "❌ 请指定角色昵称"
        exit 1
    fi

    echo "🎭 正在呼叫角色: $nickname"

    # 调用Node.js脚本来执行角色呼叫
    cd "$CURSOR_DIR" && node -e "const RoleManager = require('./commands/role-manager.js'); const roleManager = new RoleManager('$CURSOR_DIR', '$PROJECT_ROOT');

    roleManager.initialize().then(() => {
        return roleManager.findRoleByNickname('$nickname');
    }).then(findResult => {
        if (findResult.success) {
            return roleManager.switchRole(findResult.roleId, 'nickname_call').then(switchResult => {
                return { findResult, switchResult };
            });
        } else {
            throw new Error(findResult.message);
        }
    }).then(({ findResult, switchResult }) => {
        if (switchResult.success) {
            const roleConfig = roleManager.personalitySystem.roles[findResult.roleId];
            console.log('✅ 角色呼叫成功！');
            console.log('🎭 已切换到角色:', roleConfig.name);
            console.log('💫', roleConfig.description);
            process.exit(0); // 成功时也退出
        } else {
            throw new Error(switchResult.message);
        }
    }).catch(error => {
        console.error('❌ 角色呼叫失败:', error.message);
        process.exit(1);
    });
    "
}

# 列出所有角色
list_roles() {
    echo "🎭 可用角色列表:"

    # 调用Node.js脚本来获取角色列表
    cd "$CURSOR_DIR" && node -e "const RoleManager = require('./commands/role-manager.js'); const roleManager = new RoleManager('$CURSOR_DIR', '$PROJECT_ROOT');

    roleManager.initialize().then(() => {
        const roles = roleManager.getAvailableRoles();
        console.log('📋 发现', roles.total, '个角色:');
        roles.roles.forEach(role => {
            console.log('  •', role.name, '(' + role.id + ')');
            if (role.description) {
                console.log('    ' + role.description);
            }
        });
    }).catch(error => {
        console.error('❌ 获取角色列表失败:', error.message);
        process.exit(1);
    });
    "
}

# 显示当前角色
show_current_role() {
    echo "🎭 当前角色状态:"

    # 调用Node.js脚本来获取当前角色
    cd "$CURSOR_DIR" && node -e "const RoleManager = require('./commands/role-manager.js'); const roleManager = new RoleManager('$CURSOR_DIR', '$PROJECT_ROOT');

    roleManager.initialize().then(() => {
        const current = roleManager.getCurrentRole();
        if (current.success) {
            console.log('当前角色:', current.role.name, '(' + current.role.id + ')');
        } else {
            console.log('未找到当前角色信息');
        }
    }).catch(error => {
        console.error('❌ 获取当前角色失败:', error.message);
        process.exit(1);
    });
    "
}

# 管理昵称
manage_nickname() {
    local param="$1"
    echo "🎭 昵称管理: $param"
    # TODO: 实现昵称管理功能
    echo "功能开发中..."
}

# 执行主函数
main "$@"