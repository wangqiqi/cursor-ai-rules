#!/usr/bin/env node

// 测试角色激活机制
const path = require('path');
const fs = require('fs');

async function testRoleActivation() {
    console.log('🧪 测试角色激活机制...\n');

    const projectRoot = '/home/saida/workspace/cursor-ai-rules';
    const cursorDir = path.join(projectRoot, '.cursor');

    try {
        // 1. 测试RoleManager初始化
        console.log('1️⃣ 测试RoleManager初始化...');
        const RoleManager = require('./.cursor/commands/role-manager');
        const roleManager = new RoleManager(cursorDir, projectRoot);
        await roleManager.initialize();

        console.log('✅ RoleManager初始化成功');

        // 2. 检查当前角色
        console.log('\n2️⃣ 检查当前角色...');
        const currentRoleInfo = roleManager.getCurrentRole();
        console.log('当前角色:', currentRoleInfo.role.name, `(${currentRoleInfo.role.id})`);

        // 3. 检查项目配置
        console.log('\n3️⃣ 检查项目配置...');
        const projectConfig = roleManager.loadProjectRoleConfig();
        console.log('项目配置角色:', projectConfig || '无配置');

        // 4. 强制激活测试
        console.log('\n4️⃣ 强制激活测试...');
        if (projectConfig) {
            const switchResult = await roleManager.switchRole(projectConfig, 'test_activation');
            console.log('切换结果:', switchResult.success ? '成功' : '失败');
            if (switchResult.message) {
                console.log('消息:', switchResult.message);
            }
        }

        // 5. 最终状态检查
        console.log('\n5️⃣ 最终状态检查...');
        const finalRoleInfo = roleManager.getCurrentRole();
        console.log('最终角色:', finalRoleInfo.role.name, `(${finalRoleInfo.role.id})`);

        console.log('\n🎉 所有测试完成！');

    } catch (error) {
        console.error('❌ 测试失败:', error.message);
        console.error(error.stack);
    }
}

if (require.main === module) {
    testRoleActivation().catch(console.error);
}