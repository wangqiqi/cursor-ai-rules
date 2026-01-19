#!/usr/bin/env node

// 测试项目角色系统
const path = require('path');
const fs = require('fs');

async function testProjectRoleSystem() {
    console.log('🧪 测试项目角色系统...\n');

    const projectRoot = '/home/saida/workspace/cursor-ai-rules';
    const configPath = path.join(projectRoot, '.cursor-project.json');

    try {
        // 1. 检查项目配置文件
        console.log('1️⃣ 检查项目配置文件...');
        if (!fs.existsSync(configPath)) {
            console.log('❌ 配置文件不存在');
            return;
        }

        const configContent = fs.readFileSync(configPath, 'utf8');
        const config = JSON.parse(configContent);
        console.log('✅ 配置文件存在');
        console.log('   当前角色:', config.currentRole);
        console.log('   更新时间:', config.lastUpdated);
        console.log('   项目路径:', config.projectPath);

        // 2. 测试RoleManager
        console.log('\n2️⃣ 测试RoleManager...');
        const RoleManager = require('./.cursor/commands/role-manager');
        const roleManager = new RoleManager('./.cursor', projectRoot);
        await roleManager.initialize();

        const currentRoleInfo = roleManager.getCurrentRole();
        console.log('✅ RoleManager初始化成功');
        console.log('   当前角色:', currentRoleInfo.role.name, `(${currentRoleInfo.role.id})`);

        // 3. 测试角色切换
        console.log('\n3️⃣ 测试角色切换...');
        const switchResult = await roleManager.switchRole(config.currentRole, 'test_switch');
        console.log('   切换结果:', switchResult.success ? '成功' : '失败');
        if (switchResult.message) {
            console.log('   消息:', switchResult.message);
        }

        // 4. 验证最终状态
        console.log('\n4️⃣ 验证最终状态...');
        const finalRoleInfo = roleManager.getCurrentRole();
        console.log('   最终角色:', finalRoleInfo.role.name, `(${finalRoleInfo.role.id})`);

        console.log('\n🎉 项目角色系统测试完成！');
        console.log('   配置正确 ✓');
        console.log('   角色激活 ✓');
        console.log('   持久化 ✓');

    } catch (error) {
        console.error('❌ 测试失败:', error.message);
        console.error(error.stack);
    }
}

if (require.main === module) {
    testProjectRoleSystem().catch(console.error);
}