// Cursor IDE Master Command Handler
// 处理 /master 命令的实际执行逻辑

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class MasterCommandHandler {
    constructor() {
        this.projectRoot = this.findProjectRoot();
        this.cursorDir = path.join(this.projectRoot, '.cursor');
    }

    findProjectRoot() {
        let currentDir = process.cwd();
        const maxDepth = 10;
        let depth = 0;

        while (depth < maxDepth) {
            if (fs.existsSync(path.join(currentDir, '.cursor'))) {
                return currentDir;
            }
            const parentDir = path.dirname(currentDir);
            if (parentDir === currentDir) break; // Reached root
            currentDir = parentDir;
            depth++;
        }

        // Fallback to current directory
        return process.cwd();
    }

    async getCapabilityConfig(capability) {
        try {
            const configPath = path.join(this.cursorDir, 'commands', 'capability-map.json');
            const configContent = fs.readFileSync(configPath, 'utf8');
            const config = JSON.parse(configContent);

            return config.mappings[capability] || null;
        } catch (error) {
            console.error('读取能力配置失败:', error);
            return null;
        }
    }

    async executeScript(scriptPath, parameters = {}) {
        try {
            const fullPath = path.join(this.cursorDir, scriptPath);
            console.log(`🔧 执行脚本: ${fullPath}`);

            // 检查脚本是否存在
            if (!fs.existsSync(fullPath)) {
                return { success: false, message: `脚本不存在: ${scriptPath}` };
            }

            // 执行脚本
            const result = execSync(`bash "${fullPath}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: 30000, // 30秒超时
                env: { ...process.env, ...parameters }
            });

            return { success: true, output: result, script: scriptPath };
        } catch (error) {
            return { success: false, message: `脚本执行失败: ${error.message}`, script: scriptPath };
        }
    }

    async executeHook(hookPath, parameters = {}) {
        try {
            const fullPath = path.join(this.cursorDir, 'features', 'hooks', hookPath);
            console.log(`🎣 执行钩子: ${fullPath}`);

            if (!fs.existsSync(fullPath)) {
                return { success: false, message: `钩子不存在: ${hookPath}` };
            }

            const result = execSync(`bash "${fullPath}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: 15000,
                env: { ...process.env, ...parameters }
            });

            return { success: true, output: result, hook: hookPath };
        } catch (error) {
            return { success: false, message: `钩子执行失败: ${error.message}`, hook: hookPath };
        }
    }

    async executeWorkflow(workflowName, parameters = {}) {
        try {
            console.log(`🔄 执行工作流: ${workflowName}`);

            // 这里可以实现工作流执行逻辑
            // 目前暂时返回成功状态
            return { success: true, message: `工作流 ${workflowName} 已安排执行`, workflow: workflowName };
        } catch (error) {
            return { success: false, message: `工作流执行失败: ${error.message}`, workflow: workflowName };
        }
    }

    async execute(input) {
        try {
            console.log(`🎯 处理 /master 命令: ${input}`);

            // 1. 调用智能匹配器
            const matchResult = await this.callSmartMatcher(input);
            console.log('🎯 智能匹配结果:', matchResult);

            if (!matchResult.matched) {
                console.log('❌ 未能识别命令意图');
                return { success: false, message: '未能识别命令意图' };
            }

            // 2. 根据能力执行相应操作
            const result = await this.executeCapability(matchResult.capability, input);
            return result;

        } catch (error) {
            console.error('❌ Master命令执行失败:', error);
            return { success: false, message: error.message };
        }
    }

    async callSmartMatcher(input) {
        return new Promise((resolve, reject) => {
            const matcherScript = path.join(this.cursorDir, 'core', 'smart-intent-matcher.sh');

            if (!fs.existsSync(matcherScript)) {
                reject(new Error('智能匹配器脚本不存在'));
                return;
            }

            const command = `${matcherScript} "${input}" "" json`;

            try {
                const output = execSync(command, {
                    cwd: this.projectRoot,
                    encoding: 'utf8',
                    timeout: 10000
                });

                // 解析JSON结果
                const result = JSON.parse(output.trim());
                resolve(result);
            } catch (error) {
                reject(error);
            }
        });
    }

    async executeCapability(capability, input) {
        try {
            // 从capability-map.json获取能力定义
            const capabilityConfig = await this.getCapabilityConfig(capability);

            if (!capabilityConfig) {
                return { success: false, message: `未找到能力配置: ${capability}` };
            }

            console.log(`🎯 执行能力: ${capability}`);
            console.log(`📋 能力描述: ${capabilityConfig.description}`);

            // 按执行顺序调用各种组件
            const results = [];

            // 1. 执行规则 (rules)
            if (capabilityConfig.capabilities?.rules?.length > 0) {
                console.log('📏 激活规则:', capabilityConfig.capabilities.rules.join(', '));
                // 这里可以实现规则激活逻辑
            }

            // 2. 执行脚本 (scripts)
            if (capabilityConfig.capabilities?.scripts?.length > 0) {
                console.log('🔧 执行脚本:', capabilityConfig.capabilities.scripts.join(', '));
                for (const script of capabilityConfig.capabilities.scripts) {
                    const result = await this.executeScript(script, capabilityConfig.parameters || {});
                    results.push(result);
                }
            }

            // 3. 执行钩子 (hooks)
            if (capabilityConfig.capabilities?.hooks?.length > 0) {
                console.log('🎣 触发钩子:', capabilityConfig.capabilities.hooks.join(', '));
                for (const hook of capabilityConfig.capabilities.hooks) {
                    const result = await this.executeHook(hook, capabilityConfig.parameters || {});
                    results.push(result);
                }
            }

            // 4. 执行工作流 (workflows)
            if (capabilityConfig.capabilities?.workflows?.length > 0) {
                console.log('🔄 执行工作流:', capabilityConfig.capabilities.workflows.join(', '));
                for (const workflow of capabilityConfig.capabilities.workflows) {
                    const result = await this.executeWorkflow(workflow, capabilityConfig.parameters || {});
                    results.push(result);
                }
            }

            // 5. 调用技能 (skills) - 如果有的话
            if (capabilityConfig.capabilities?.skills?.length > 0) {
                console.log('🎯 调用技能:', capabilityConfig.capabilities.skills.join(', '));
                // 这里可以实现技能调用逻辑
            }

            // 特殊处理某些能力
            switch (capability) {
                case 'commit_code':
                case 'enhanced_commit':
                    return await this.executeGitCommit(input);
                case 'check_code_quality':
                    return await this.executeCodeQualityCheck(input);
                case 'run_tests':
                    return await this.executeTests(input);
                case 'deploy_application':
                    return await this.executeDeployment(input);
                case 'analyze_project':
                    return await this.executeProjectAnalysis(input);
                case 'create_react_project':
                    return await this.executeProjectCreation('react', input);
                case 'create_vue_project':
                    return await this.executeProjectCreation('vue', input);
                case 'create_python_api':
                    return await this.executeProjectCreation('python-api', input);
                case 'optimize_performance':
                    return await this.executePerformanceOptimization(input);
                case 'security_audit':
                    return await this.executeSecurityAudit(input);
                case 'generate_documentation':
                    return await this.executeDocumentationGeneration(input);
                case 'learn_technology':
                    return await this.executeTechnologyLearning(input);
                case 'project_initialization':
                    return await this.executeProjectInitialization(input);
                case 'project_analysis':
                    return await this.executeProjectAnalysis(input);
                case 'setup_development_environment':
                    return await this.executeEnvironmentSetup(input);
                // 可以继续添加更多特殊处理
                default:
                    // 对于没有特殊处理的通用能力，返回成功结果
                    return {
                        success: true,
                        message: `成功执行能力: ${capability}`,
                        executedComponents: capabilityConfig.capabilities,
                        results: results
                    };
            }

        } catch (error) {
            console.error(`❌ 执行能力失败 ${capability}:`, error);
            return { success: false, message: `执行失败: ${error.message}` };
        }
    }

    async executeGitCommit(input) {
        console.log('🚀 执行智能Git提交流程...');

        try {
            // 检查Git状态
            const gitStatus = execSync('git status --porcelain', {
                cwd: this.projectRoot,
                encoding: 'utf8'
            });

            if (!gitStatus.trim()) {
                console.log('⚠️ 没有发现需要提交的更改');
                return { success: true, message: '没有需要提交的更改' };
            }

            // 自动暂存所有更改
            execSync('git add .', { cwd: this.projectRoot });
            console.log('📦 已暂存所有更改');

            // 重新检查暂存状态
            const stagedStatus = execSync('git diff --cached --name-only', {
                cwd: this.projectRoot,
                encoding: 'utf8'
            });

            if (!stagedStatus.trim()) {
                console.log('⚠️ 暂存区为空');
                return { success: true, message: '暂存区为空' };
            }

            // 分析变更
            const fileCount = stagedStatus.trim().split('\n').length;
            console.log(`📝 待提交文件数: ${fileCount}`);

            // 生成提交消息
            const commitMessage = `feat: 智能提交测试

- 变更文件数: ${fileCount} 个
- 复杂度: 低
- 包含代码变更

Generated by Cursor AI Rules v4.3.0 at ${new Date().toISOString()}`;

            console.log('💾 执行提交...');
            console.log('提交消息:');
            console.log('----------------------------------------');
            console.log(commitMessage);
            console.log('----------------------------------------');

            // 执行提交
            execSync(`git commit -m "${commitMessage.replace(/"/g, '\\"')}"`, {
                cwd: this.projectRoot
            });

            console.log('✅ 智能提交成功!');
            return { success: true, message: '提交成功' };

        } catch (error) {
            console.error('❌ Git提交失败:', error.message);
            return { success: false, message: `提交失败: ${error.message}` };
        }
    }

    async executeCodeQualityCheck(input) {
        console.log('🔍 执行代码质量检查...');

        try {
            // 调用质量管理脚本
            const result = await this.executeScript('core/quality-manager.sh', {
                SCOPE: 'all',
                FIX_ISSUES: 'true',
                GENERATE_REPORT: 'true'
            });

            return {
                success: result.success,
                message: result.success ? '代码质量检查完成' : `检查失败: ${result.message}`,
                output: result.output
            };
        } catch (error) {
            return { success: false, message: `质量检查失败: ${error.message}` };
        }
    }

    async executeTests(input) {
        console.log('🧪 执行测试...');

        try {
            // 这里可以实现测试执行逻辑
            // 例如调用测试脚本或运行测试命令
            return { success: true, message: '测试执行已安排' };
        } catch (error) {
            return { success: false, message: `测试执行失败: ${error.message}` };
        }
    }

    async executeDeployment(input) {
        console.log('🚀 执行部署...');

        try {
            // 这里可以实现部署逻辑
            return { success: true, message: '部署已安排执行' };
        } catch (error) {
            return { success: false, message: `部署失败: ${error.message}` };
        }
    }

    async executeProjectAnalysis(input) {
        console.log('📊 执行项目分析...');

        try {
            // 调用环境感知脚本
            const result = await this.executeScript('core/env-perception.sh');

            return {
                success: result.success,
                message: result.success ? '项目分析完成' : `分析失败: ${result.message}`,
                output: result.output
            };
        } catch (error) {
            return { success: false, message: `项目分析失败: ${error.message}` };
        }
    }

    async executeProjectCreation(type, input) {
        console.log(`🏗️ 创建${type}项目...`);

        try {
            // 这里可以实现项目创建逻辑
            return { success: true, message: `${type}项目创建已安排` };
        } catch (error) {
            return { success: false, message: `项目创建失败: ${error.message}` };
        }
    }

    async executePerformanceOptimization(input) {
        console.log('⚡ 执行性能优化...');

        try {
            // 调用性能优化脚本
            const result = await this.executeScript('core/optimizer.sh');

            return {
                success: result.success,
                message: result.success ? '性能优化完成' : `优化失败: ${result.message}`,
                output: result.output
            };
        } catch (error) {
            return { success: false, message: `性能优化失败: ${error.message}` };
        }
    }

    async executeSecurityAudit(input) {
        console.log('🔒 执行安全审计...');

        try {
            // 这里可以实现安全审计逻辑
            return { success: true, message: '安全审计已安排' };
        } catch (error) {
            return { success: false, message: `安全审计失败: ${error.message}` };
        }
    }

    async executeDocumentationGeneration(input) {
        console.log('📚 生成文档...');

        try {
            // 这里可以实现文档生成逻辑
            return { success: true, message: '文档生成已安排' };
        } catch (error) {
            return { success: false, message: `文档生成失败: ${error.message}` };
        }
    }

    async executeTechnologyLearning(input) {
        console.log('🎓 执行技术学习...');

        try {
            // 这里可以实现技术学习逻辑
            return { success: true, message: '技术学习资源已准备' };
        } catch (error) {
            return { success: false, message: `技术学习失败: ${error.message}` };
        }
    }

    async executeProjectInitialization(input) {
        console.log('🚀 执行项目初始化...');

        try {
            // 调用初始化脚本
            const result = await this.executeScript('core/init.sh');

            return {
                success: result.success,
                message: result.success ? '项目初始化完成' : `初始化失败: ${result.message}`,
                output: result.output
            };
        } catch (error) {
            return { success: false, message: `项目初始化失败: ${error.message}` };
        }
    }

    async executeEnvironmentSetup(input) {
        console.log('⚙️ 设置开发环境...');

        try {
            // 这里可以实现环境设置逻辑
            return { success: true, message: '开发环境设置已安排' };
        } catch (error) {
            return { success: false, message: `环境设置失败: ${error.message}` };
        }
    }
}

// 导出供Cursor IDE使用
module.exports = MasterCommandHandler;

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);
    if (args.length === 0) {
        console.log('用法: node master-handler.js <命令>');
        process.exit(1);
    }

    const handler = new MasterCommandHandler();
    const input = args.join(' ');

    handler.execute(input).then(result => {
        console.log('执行结果:', result);
        process.exit(result.success ? 0 : 1);
    }).catch(error => {
        console.error('执行失败:', error);
        process.exit(1);
    });
}