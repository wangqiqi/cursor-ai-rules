// 测试角色初始化和持久化
const path = require('path');
const RoleManager = require('./.cursor/commands/role-manager');

async function testRoleInitialization() {
    console.log('🧪 测试角色初始化和项目持久化...\n');

    const projectDir = __dirname;
    const cursorDir = path.join(projectDir, '.cursor');

    console.log(`📁 项目目录: ${projectDir}`);
    console.log(`⚙️ Cursor目录: ${cursorDir}`);

    // 创建角色管理器实例
    const roleManager = new RoleManager(cursorDir, projectDir);

    try {
        // 初始化
        console.log('🔄 初始化角色管理器...');
        await roleManager.initialize();

        // 获取当前角色信息
        const currentRoleInfo = roleManager.getCurrentRole();
        const roleName = currentRoleInfo.success ? currentRoleInfo.role.name : '未知';
        const roleId = currentRoleInfo.success ? currentRoleInfo.role.id : 'unknown';

        console.log(`🎭 当前角色: ${roleName} (${roleId})`);

        // 检查项目配置文件
        const projectConfigPath = roleManager.projectRoleConfigPath;
        const fs = require('fs');
        if (fs.existsSync(projectConfigPath)) {
            const config = JSON.parse(fs.readFileSync(projectConfigPath, 'utf8'));
            console.log(`📄 项目配置: ${JSON.stringify(config, null, 2)}`);
        } else {
            console.log('📄 项目配置文件不存在');
        }

        console.log('\n✅ 角色初始化测试完成！');

    } catch (error) {
        console.error('❌ 测试失败:', error.message);
        console.error(error.stack);
    }
}

testRoleInitialization();