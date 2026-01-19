#!/usr/bin/env node

// 测试maid角色响应
const MasterCommandHandler = require('./.cursor/commands/master-handler');

async function testMaidResponse() {
    console.log('🧪 测试maid角色响应...\n');

    const handler = new MasterCommandHandler();

    try {
        // 测试不同的响应类型
        const testResults = [
            { success: true, message: '代码优化完成', type: 'code' },
            { success: true, message: '项目创建成功', type: 'project' },
            { success: false, message: '执行失败', type: 'error' },
            { success: true, message: '任务完成', type: 'general' }
        ];

        for (const result of testResults) {
            console.log(`测试: ${result.type} - ${result.message}`);

            const wrapped = handler.wrapWithWelcome(result, {});
            console.log('包装后:', wrapped.message.substring(0, 50) + '...');
            console.log('角色:', wrapped.role?.name || '未知');
            console.log('---');
        }

        console.log('🎉 测试完成！');

    } catch (error) {
        console.error('❌ 测试失败:', error.message);
    }
}

if (require.main === module) {
    testMaidResponse().catch(console.error);
}