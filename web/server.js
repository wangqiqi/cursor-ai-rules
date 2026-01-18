// Cursor AI Rules - Web界面快速原型
// 提供图形化界面来替代纯命令行操作

const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// 中间件配置
app.use(express.json());

// CORS 中间件 - 允许跨域请求
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');

    if (req.method === 'OPTIONS') {
        res.sendStatus(200);
    } else {
        next();
    }
});

// 错误处理中间件
app.use((err, req, res, next) => {
    console.error('服务器错误:', err);
    res.status(500).json({
        success: false,
        error: '服务器内部错误',
        message: err.message
    });
});

// API路由：执行Master命令
app.post('/execute', (req, res) => {
    const command = req.body.command;

    // 从web目录向上查找项目根目录
    let projectRoot = __dirname;
    let found = false;

    // 向上查找最多10层目录
    for (let i = 0; i < 10 && !found; i++) {
        if (fs.existsSync(path.join(projectRoot, '.cursor'))) {
            found = true;
        } else {
            const parent = path.dirname(projectRoot);
            if (parent === projectRoot) break; // 到达根目录
            projectRoot = parent;
        }
    }

    const cwd = req.body.cwd || projectRoot;

    if (!command || command.trim() === '') {
        return res.status(400).json({
            success: false,
            error: '命令不能为空'
        });
    }

    console.log(`执行命令: ${command}`);

    // 执行master-handler.js命令
    const masterScript = path.join(projectRoot, '.cursor', 'commands', 'master-handler.js');

    console.log(`执行命令: ${command}`);
    console.log(`工作目录: ${cwd}`);
    console.log(`主脚本: ${masterScript}`);

    exec(`cd "${cwd}" && node "${masterScript}" "${command}"`, {
        timeout: 30000, // 30秒超时
        maxBuffer: 1024 * 1024 * 10, // 10MB缓冲区
        env: { ...process.env, FORCE_COLOR: '1' } // 保持颜色输出
    }, (error, stdout, stderr) => {
        let result;

        // 尝试解析stdout中的JSON结果
        let parsedResult = null;
        try {
            const stdoutTrimmed = stdout.trim();

            // 检查stdout是否以JSON结束
            const jsonStart = stdoutTrimmed.lastIndexOf('\n{');
            if (jsonStart === -1) {
                // 尝试查找整个字符串是否是JSON
                parsedResult = JSON.parse(stdoutTrimmed);
            } else {
                // 提取JSON部分
                const jsonStr = stdoutTrimmed.substring(jsonStart + 1);
                parsedResult = JSON.parse(jsonStr);
            }

            result = {
                ...parsedResult,
                command: command,
                timestamp: new Date().toISOString()
            };
        } catch (parseError) {
            console.log('JSON解析失败，使用传统模式:', parseError.message);
            // 如果解析失败，回退到传统处理方式
            result = {
                success: !error,
                command: command,
                timestamp: new Date().toISOString(),
                output: stdout
            };
        }

        if (error) {
            result.error = error.message;
            result.exitCode = error.code;

            // 解析stderr中的有用信息
            if (stderr) {
                result.stderr = stderr;
                // 尝试提取错误信息
                const errorLines = stderr.split('\n').filter(line =>
                    line.includes('❌') ||
                    line.includes('ERROR') ||
                    line.includes('error')
                );
                if (errorLines.length > 0) {
                    result.errorDetails = errorLines;
                }
            }
        }

        if (stdout) {
            result.output = stdout;
            // 解析输出中的状态信息
            const statusLines = stdout.split('\n').filter(line =>
                line.includes('✅') ||
                line.includes('⚠️') ||
                line.includes('❌') ||
                line.includes('🔄')
            );
            if (statusLines.length > 0) {
                result.statusUpdates = statusLines;
            }
        }

        res.json(result);
    });
});

// API路由：获取项目状态
app.get('/status', async (req, res) => {
    try {
        // 从web目录向上查找项目根目录
        let projectRoot = __dirname;
        let found = false;

        // 向上查找最多10层目录
        for (let i = 0; i < 10 && !found; i++) {
            if (fs.existsSync(path.join(projectRoot, '.cursor'))) {
                found = true;
            } else {
                const parent = path.dirname(projectRoot);
                if (parent === projectRoot) break; // 到达根目录
                projectRoot = parent;
            }
        }

        const status = {
            hasCursor: fs.existsSync(path.join(projectRoot, '.cursor')),
            hasGrowth: fs.existsSync(path.join(projectRoot, '.cursorGrowth')),
            projectRoot: projectRoot,
            nodeVersion: process.version,
            platform: process.platform,
            timestamp: new Date().toISOString()
        };

        // 检查最近的生长数据
        if (status.hasGrowth) {
            try {
                const growthDir = path.join(projectRoot, '.cursorGrowth');
                const stats = fs.statSync(growthDir);
                status.lastGrowthUpdate = stats.mtime.toISOString();

                // 检查是否有学习数据
                const learningDir = path.join(growthDir, 'user_data');
                if (fs.existsSync(learningDir)) {
                    const files = fs.readdirSync(learningDir);
                    status.learningFiles = files.length;
                }
            } catch (error) {
                // 忽略读取错误
            }
        }

        res.json(status);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: '获取状态失败',
            message: error.message
        });
    }
});

// API路由：获取命令历史
app.get('/history', async (req, res) => {
    try {
        // 这里可以从.cursorGrowth中读取历史记录
        // 暂时返回模拟数据
        const history = [
            {
                id: 1,
                command: '创建React项目',
                timestamp: new Date(Date.now() - 3600000).toISOString(),
                success: true,
                duration: 45000
            },
            {
                id: 2,
                command: '优化代码质量',
                timestamp: new Date(Date.now() - 1800000).toISOString(),
                success: true,
                duration: 12000
            }
        ];

        res.json({ history });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: '获取历史失败',
            message: error.message
        });
    }
});

// API路由：健康检查
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        uptime: process.uptime()
    });
});

// 静态文件服务
app.use(express.static('.'));

// 根路径路由（兜底路由）
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`🧠 Cursor AI Master Web界面已启动!`);
    console.log(`🌐 访问地址: http://localhost:${PORT}`);
    console.log(`📊 API文档: http://localhost:${PORT}/api`);
    console.log(`💡 提示: 在浏览器中打开上述地址开始使用`);
});

// 优雅关闭
process.on('SIGTERM', () => {
    console.log('收到SIGTERM信号，正在关闭服务器...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('\n收到SIGINT信号，正在关闭服务器...');
    process.exit(0);
});

module.exports = app;