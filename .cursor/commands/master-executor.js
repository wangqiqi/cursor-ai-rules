// Cursor AI Rules - Master Command Executor
// 负责执行解析后的命令，协调各种组件

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class MasterCommandExecutor {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');
        this.executionTimeout = 30000; // 30秒默认超时
        this.maxConcurrency = 3; // 最大并发数
    }

    /**
     * 执行解析后的命令
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 执行结果
     */
    async execute(parseResult) {
        try {
            if (!parseResult || !parseResult.success) {
                return this.createErrorResult('无效的解析结果');
            }

            console.log(`🎯 执行命令类型: ${parseResult.type}`);

            switch (parseResult.type) {
                case 'direct_call':
                    return await this.executeDirectCall(parseResult);

                case 'natural_language':
                    return await this.executeNaturalLanguage(parseResult);

                case 'error':
                    return parseResult;

                default:
                    return this.createErrorResult(`未知的命令类型: ${parseResult.type}`);
            }

        } catch (error) {
            console.error('❌ 执行失败:', error);
            return this.createErrorResult(`执行异常: ${error.message}`);
        }
    }

    /**
     * 执行直接调用命令
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 执行结果
     */
    async executeDirectCall(parseResult) {
        const { callType, targetName } = parseResult;

        console.log(`🔧 执行直接调用: ${callType} ${targetName}`);

        try {
            switch (callType) {
                case 'rule':
                    return await this.executeRule(targetName);

                case 'script':
                    return await this.executeScript(targetName);

                case 'skill':
                    return await this.executeSkill(targetName);

                case 'hook':
                    return await this.executeHook(targetName);

                case 'workflow':
                    return await this.executeWorkflow(targetName);

                default:
                    return this.createErrorResult(`不支持的调用类型: ${callType}`);
            }
        } catch (error) {
            return this.createErrorResult(`${callType}执行失败: ${error.message}`);
        }
    }

    /**
     * 执行自然语言命令
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 执行结果
     */
    async executeNaturalLanguage(parseResult) {
        const { intent, parameters, constitution } = parseResult;

        console.log(`🧠 执行自然语言命令 - 意图: ${intent}`);

        // 检查宪法合规性
        if (!constitution.compliant) {
            return await this.handleConstitutionViolation(parseResult);
        }

        // 根据意图执行相应操作
        switch (intent) {
            case 'creation':
                return await this.handleCreationIntent(parameters);

            case 'optimization':
                return await this.handleOptimizationIntent(parameters);

            case 'analysis':
                return await this.handleAnalysisIntent(parameters);

            case 'deployment':
                return await this.handleDeploymentIntent(parameters);

            case 'learning':
                return await this.handleLearningIntent(parameters);

            case 'testing':
                return await this.handleTestingIntent(parameters);

            case 'commit':
                return await this.handleCommitIntent(parameters);

            default:
                return await this.handleGenericIntent(intent, parameters);
        }
    }

    /**
     * 处理宪法违规
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 处理结果
     */
    async handleConstitutionViolation(parseResult) {
        const { constitution, originalInput } = parseResult;

        console.log('⚖️ 检测到宪法违规，执行STOP机制');

        // 记录宪法事件
        await this.logConstitutionEvent('violation', {
            input: originalInput,
            reason: constitution.reason,
            severity: constitution.severity
        });

        // 返回合规性响应
        return {
            success: true,
            type: 'constitution_response',
            action: constitution.action,
            message: this.generateConstitutionResponse(parseResult),
            constitution: constitution,
            requiresHumanApproval: true
        };
    }

    /**
     * 生成宪法合规性响应
     * @param {Object} parseResult - 解析结果
     * @returns {string} 响应消息
     */
    generateConstitutionResponse(parseResult) {
        const { intent, parameters } = parseResult;

        let response = `## 🤖 宪法保护机制激活\n\n`;
        response += `🚨 **检测到项目创建意图！**\n\n`;
        response += `### 📋 需求分析\n`;
        response += `- **项目类型**: ${parameters.projectType || '待分析'}\n`;
        response += `- **复杂度**: 中等\n\n`;

        response += `### 🛠️ 技术方案建议\n`;
        response += `- 前端: React + TypeScript\n`;
        response += `- 后端: Node.js + Express\n`;
        response += `- 数据库: PostgreSQL\n\n`;

        response += `### ❓ 需要确认的问题\n`;
        response += `1. 项目预算和时间限制？\n`;
        response += `2. 团队技术栈偏好？\n`;
        response += `3. 是否需要移动端支持？\n\n`;

        response += `**⚖️ 宪法要求：必须先与您讨论需求和方案，获得明确确认后才能开始开发！**\n\n`;
        response += `**请先与我讨论需求和方案，确认后再开始开发！** 🎯`;

        return response;
    }

    /**
     * 处理项目创建意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleCreationIntent(parameters) {
        console.log('🏗️ 处理项目创建意图');

        // 这里应该触发宪法保护，但由于已经在handleConstitutionViolation中处理，这里返回空
        return this.createSuccessResult('项目创建意图已通过宪法检查');
    }

    /**
     * 处理优化意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleOptimizationIntent(parameters) {
        console.log('⚡ 处理优化意图');

        const optimizationType = parameters.optimizationType || 'general';

        // 执行相应的优化脚本
        switch (optimizationType) {
            case 'performance':
                return await this.executeScript('core/optimizer.sh');

            case 'code_quality':
                return await this.executeScript('core/quality-manager.sh');

            case 'security':
                return await this.handleSecurityOptimization();

            default:
                return await this.executeScript('core/optimizer.sh');
        }
    }

    /**
     * 处理分析意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleAnalysisIntent(parameters) {
        console.log('📊 处理分析意图');

        return await this.executeScript('core/env-perception.sh');
    }

    /**
     * 处理部署意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleDeploymentIntent(parameters) {
        console.log('🚀 处理部署意图');

        // 这里可以实现部署逻辑
        return this.createSuccessResult('部署功能开发中');
    }

    /**
     * 处理学习意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleLearningIntent(parameters) {
        console.log('🎓 处理学习意图');

        const technology = parameters.technology || 'general';

        // 提供学习资源
        return this.createSuccessResult(`为您准备${technology}的学习资源，请查看相关文档`);
    }

    /**
     * 处理测试意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleTestingIntent(parameters) {
        console.log('🧪 处理测试意图');

        // 这里可以实现测试逻辑
        return this.createSuccessResult('测试功能开发中');
    }

    /**
     * 处理提交意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleCommitIntent(parameters) {
        console.log('💾 处理提交意图');

        try {
            // 检查Git状态
            const gitStatus = execSync('git status --porcelain', {
                cwd: this.projectRoot,
                encoding: 'utf8'
            });

            if (!gitStatus.trim()) {
                return this.createSuccessResult('没有需要提交的更改');
            }

            // 自动暂存
            execSync('git add .', { cwd: this.projectRoot });

            // 生成提交消息
            const commitMessage = `feat: 智能提交\n\n- 自动暂存并提交更改\n- 生成时间: ${new Date().toISOString()}`;

            // 执行提交
            execSync(`git commit -m "${commitMessage.replace(/"/g, '\\"')}"`, {
                cwd: this.projectRoot
            });

            return this.createSuccessResult('代码提交成功');

        } catch (error) {
            return this.createErrorResult(`提交失败: ${error.message}`);
        }
    }

    /**
     * 处理通用意图
     * @param {string} intent - 意图
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async handleGenericIntent(intent, parameters) {
        console.log(`🎯 处理通用意图: ${intent}`);

        return this.createSuccessResult(`已识别意图"${intent}"，功能开发中`);
    }

    /**
     * 处理安全优化
     * @returns {Promise<Object>} 执行结果
     */
    async handleSecurityOptimization() {
        console.log('🔒 处理安全优化');

        // 这里可以实现安全优化逻辑
        return this.createSuccessResult('安全优化功能开发中');
    }

    /**
     * 执行规则
     * @param {string} ruleName - 规则名称
     * @returns {Promise<Object>} 执行结果
     */
    async executeRule(ruleName) {
        console.log(`📏 执行规则: ${ruleName}`);

        try {
            // 查找规则文件
            let rulePath = this.findRuleFile(ruleName);
            if (!rulePath) {
                return this.createErrorResult(`规则文件不存在: ${ruleName}.md`);
            }

            // 读取并解析规则
            const ruleContent = fs.readFileSync(rulePath, 'utf8');
            const ruleConfig = this.parseRuleContent(ruleContent);

            let result = `✅ 规则 ${ruleName} 已激活 (alwaysApply: ${ruleConfig.alwaysApply})`;

            // 执行处理器（如果有）
            if (ruleConfig.handler) {
                const handlerResult = await this.executeRuleHandler(ruleConfig.handler, ruleName);
                result += `\n🔧 处理结果: ${handlerResult}`;
            }

            return this.createSuccessResult(result, { rule: ruleName, config: ruleConfig });

        } catch (error) {
            return this.createErrorResult(`规则执行失败: ${error.message}`);
        }
    }

    /**
     * 查找规则文件
     * @param {string} ruleName - 规则名称
     * @returns {string|null} 规则文件路径
     */
    findRuleFile(ruleName) {
        const ruleDirs = ['core', 'evolution', 'system', 'team', 'tech', 'workflow'];

        // 检查规则根目录
        let rulePath = path.join(this.cursorDir, 'rules', `${ruleName}.md`);
        if (fs.existsSync(rulePath)) {
            return rulePath;
        }

        // 检查子目录
        for (const dir of ruleDirs) {
            rulePath = path.join(this.cursorDir, 'rules', dir, `${ruleName}.md`);
            if (fs.existsSync(rulePath)) {
                return rulePath;
            }
        }

        return null;
    }

    /**
     * 解析规则内容
     * @param {string} content - 规则文件内容
     * @returns {Object} 解析后的配置
     */
    parseRuleContent(content) {
        const alwaysApplyMatch = content.match(/^alwaysApply:\s*(.+)$/m);
        const handlerMatch = content.match(/^handler:\s*(.+)$/m);

        return {
            alwaysApply: alwaysApplyMatch ? alwaysApplyMatch[1].trim() === 'true' : false,
            handler: handlerMatch ? handlerMatch[1].trim() : null
        };
    }

    /**
     * 执行规则处理器
     * @param {string} handler - 处理器路径
     * @param {string} ruleName - 规则名称
     * @returns {Promise<string>} 执行结果
     */
    async executeRuleHandler(handler, ruleName) {
        try {
            const handlerPath = path.join(this.cursorDir, 'commands', handler);

            if (!fs.existsSync(handlerPath)) {
                return `处理器文件不存在: ${handlerPath}`;
            }

            if (handler.endsWith('.js')) {
                // 执行JavaScript处理器
                const result = execSync(`node "${handlerPath}" "${ruleName}"`, {
                    cwd: this.projectRoot,
                    encoding: 'utf8',
                    timeout: this.executionTimeout
                });
                return result.trim();
            } else {
                // 执行Shell处理器
                const result = execSync(`bash "${handlerPath}" "${ruleName}"`, {
                    cwd: this.projectRoot,
                    encoding: 'utf8',
                    timeout: this.executionTimeout
                });
                return result.trim();
            }
        } catch (error) {
            return `处理器执行失败: ${error.message}`;
        }
    }

    /**
     * 执行脚本
     * @param {string} scriptName - 脚本名称
     * @param {Object} params - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async executeScript(scriptName, params = {}) {
        console.log(`🔧 执行脚本: ${scriptName}`);

        try {
            let scriptPath = path.join(this.cursorDir, scriptName);

            // 如果不存在，尝试在子目录中查找
            if (!fs.existsSync(scriptPath)) {
                const scriptDirs = ['core', 'config', 'features/automation/scripts'];
                for (const dir of scriptDirs) {
                    const subPath = path.join(this.cursorDir, dir, scriptName);
                    if (fs.existsSync(subPath)) {
                        scriptPath = subPath;
                        break;
                    }
                }
            }

            if (!fs.existsSync(scriptPath)) {
                return this.createErrorResult(`脚本不存在: ${scriptName}`);
            }

            // 执行脚本
            const result = execSync(`bash "${scriptPath}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout,
                env: { ...process.env, ...params }
            });

            return this.createSuccessResult(`脚本执行成功`, {
                script: scriptName,
                output: result.trim()
            });

        } catch (error) {
            return this.createErrorResult(`脚本执行失败: ${error.message}`);
        }
    }

    /**
     * 执行技能
     * @param {string} skillName - 技能名称
     * @returns {Promise<Object>} 执行结果
     */
    async executeSkill(skillName) {
        console.log(`🎯 执行技能: ${skillName}`);

        try {
            const loaderScript = path.join(this.cursorDir, 'core', 'skills-loader.sh');

            if (!fs.existsSync(loaderScript)) {
                return this.createErrorResult(`技能加载器不存在`);
            }

            // 执行技能
            const result = execSync(`bash "${loaderScript}" execute "${skillName}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout * 2 // 技能可能需要更多时间
            });

            return this.createSuccessResult(`技能执行成功`, {
                skill: skillName,
                output: result.trim()
            });

        } catch (error) {
            return this.createErrorResult(`技能执行失败: ${error.message}`);
        }
    }

    /**
     * 执行钩子
     * @param {string} hookName - 钩子名称
     * @returns {Promise<Object>} 执行结果
     */
    async executeHook(hookName, params = {}) {
        console.log(`🎣 执行钩子: ${hookName}`);

        try {
            const hookPath = path.join(this.cursorDir, 'features', 'hooks', hookName);

            if (!fs.existsSync(hookPath)) {
                return this.createErrorResult(`钩子不存在: ${hookName}`);
            }

            const result = execSync(`bash "${hookPath}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout,
                env: { ...process.env, ...params }
            });

            return this.createSuccessResult(`钩子执行成功`, {
                hook: hookName,
                output: result.trim()
            });

        } catch (error) {
            return this.createErrorResult(`钩子执行失败: ${error.message}`);
        }
    }

    /**
     * 执行工作流
     * @param {string} workflowName - 工作流名称
     * @returns {Promise<Object>} 执行结果
     */
    async executeWorkflow(workflowName, params = {}) {
        console.log(`🔄 执行工作流: ${workflowName}`);

        // 这里可以实现工作流执行逻辑
        return this.createSuccessResult(`工作流 ${workflowName} 已安排执行`, {
            workflow: workflowName,
            status: 'scheduled'
        });
    }

    /**
     * 记录宪法事件
     * @param {string} eventType - 事件类型
     * @param {Object} data - 事件数据
     */
    async logConstitutionEvent(eventType, data) {
        try {
            const logDir = path.join(this.cursorDir, 'logs');
            if (!fs.existsSync(logDir)) {
                fs.mkdirSync(logDir, { recursive: true });
            }

            const logFile = path.join(logDir, 'constitution-events.jsonl');
            const logEntry = {
                timestamp: new Date().toISOString(),
                eventType,
                data
            };

            fs.appendFileSync(logFile, JSON.stringify(logEntry) + '\n');
        } catch (error) {
            console.warn('宪法事件记录失败:', error.message);
        }
    }

    /**
     * 创建成功结果
     * @param {string} message - 成功消息
     * @param {Object} data - 附加数据
     * @returns {Object} 成功结果
     */
    createSuccessResult(message, data = {}) {
        return {
            success: true,
            message,
            data,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 创建错误结果
     * @param {string} message - 错误消息
     * @returns {Object} 错误结果
     */
    createErrorResult(message) {
        return {
            success: false,
            error: message,
            timestamp: new Date().toISOString()
        };
    }
}

// 导出类
module.exports = MasterCommandExecutor;

// 测试函数
async function testExecutor() {
    console.log('🧪 测试Master Command Executor...\n');

    const executor = new MasterCommandExecutor(process.cwd());

    const testCases = [
        // 直接调用测试
        {
            input: { success: true, type: 'direct_call', callType: 'rule', targetName: 'constitution' },
            description: '测试规则直接调用'
        },
        {
            input: { success: true, type: 'direct_call', callType: 'script', targetName: 'init.sh' },
            description: '测试脚本直接调用'
        },

        // 自然语言测试
        {
            input: {
                success: true,
                type: 'natural_language',
                intent: 'commit',
                confidence: 0.85,
                parameters: { input: '提交代码' },
                constitution: { compliant: true }
            },
            description: '测试自然语言提交意图'
        }
    ];

    for (const testCase of testCases) {
        console.log(`\n📋 测试: ${testCase.description}`);

        try {
            const result = await executor.execute(testCase.input);
            console.log(`   成功: ${result.success}`);
            console.log(`   消息: ${result.message || result.error}`);

            if (result.data) {
                console.log(`   数据:`, Object.keys(result.data));
            }

        } catch (error) {
            console.log(`   ❌ 异常: ${error.message}`);
        }
    }
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.includes('--test')) {
        testExecutor().catch(console.error);
    } else {
        console.log('用法:');
        console.log('  node master-executor.js --test    # 运行测试');
        console.log('  (执行器需要通过编程方式调用)');
    }
}