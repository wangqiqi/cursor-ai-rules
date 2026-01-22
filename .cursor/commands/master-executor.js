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

        // 初始化角色管理器
        this.roleManager = null;
        this.initializeRoleManager();
    }

    /**
     * 初始化角色管理器
     */
    async initializeRoleManager() {
        try {
            const RoleManager = require('./role-manager');
            this.roleManager = new RoleManager(this.cursorDir, this.projectRoot);
            await this.roleManager.initialize();
            console.log('🎭 执行器角色管理器初始化成功');
        } catch (error) {
            console.warn('⚠️ 执行器角色管理器初始化失败:', error.message);
            // 创建简化的备用系统
            this.roleManager = {
                getCurrentRole: () => ({ success: true, role: { id: 'professional_assistant', name: '专业助手' } })
            };
        }
    }

    /**
     * 确保项目角色配置正确
     */
    async ensureProjectRoleConfig() {
        try {
            if (!this.roleManager) {
                console.log('⚠️ 执行器角色管理器不可用');
                return;
            }

            // 检查项目角色配置
            const projectRoleConfig = this.roleManager.loadProjectRoleConfig();
            if (projectRoleConfig && this.roleManager.personalitySystem.roles[projectRoleConfig]) {
                // 检查当前角色是否已经是项目角色
                if (this.roleManager.currentRole !== projectRoleConfig) {
                    console.log(`🎭 执行器激活项目角色: ${projectRoleConfig}`);
                    const result = await this.roleManager.switchRole(projectRoleConfig, 'project_config_executor');
                    if (result.success) {
                        console.log(`✅ 执行器角色激活成功: ${this.roleManager.personalitySystem.roles[projectRoleConfig].name}`);
                    } else {
                        console.log(`⚠️ 执行器角色激活失败: ${result.message}`);
                    }
                } else {
                    console.log(`✅ 执行器角色已激活: ${this.roleManager.personalitySystem.roles[projectRoleConfig].name}`);
                }
            } else {
                // 如果没有项目配置，使用默认角色
                const defaultRole = this.roleManager.personalitySystem.default_role || 'professional_assistant';
                if (this.roleManager.currentRole !== defaultRole) {
                    console.log(`🎭 执行器激活默认角色: ${defaultRole}`);
                    const result = await this.roleManager.switchRole(defaultRole, 'default_role_executor');
                    if (result.success) {
                        console.log(`✅ 执行器默认角色激活成功: ${defaultRole}`);
                    }
                } else {
                    console.log(`✅ 执行器默认角色已激活: ${defaultRole}`);
                }
            }
        } catch (error) {
            console.log(`⚠️ 执行器项目角色配置出错: ${error.message}`);
        }
    }

    /**
     * 执行解析后的命令
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 执行结果
     */
    async execute(parseResult) {
        try {
            // 🎭 确保项目角色配置正确
            await this.ensureProjectRoleConfig();

            if (!parseResult || !parseResult.success) {
                return this.createErrorResult('无效的解析结果');
            }

            console.log(`🎯 执行命令类型: ${parseResult.type}`);

            switch (parseResult.type) {
                case 'direct_call':
                    return await this.executeDirectCall(parseResult);

                case 'role_switch':
                    return await this.executeRoleSwitch(parseResult);

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
     * 执行角色切换命令
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 执行结果
     */
    async executeRoleSwitch(parseResult) {
        const { roleName } = parseResult;

        console.log(`🎭 执行角色切换: ${roleName}`);

        try {
            if (!this.roleManager) {
                return this.createErrorResult('角色管理系统不可用');
            }

            // 先尝试按角色ID切换
            let result = await this.roleManager.switchRole(roleName, 'command_execution');

            // 如果按ID切换失败，尝试按角色名称查找
            if (!result.success) {
                const availableRoles = this.roleManager.getAvailableRoles();
                if (availableRoles.success) {
                    const matchedRole = availableRoles.roles.find(role =>
                        role.name.toLowerCase().includes(roleName.toLowerCase()) ||
                        roleName.toLowerCase().includes(role.name.toLowerCase())
                    );

                    if (matchedRole) {
                        console.log(`🔍 找到匹配角色: ${matchedRole.name} (${matchedRole.id})`);
                        result = await this.roleManager.switchRole(matchedRole.id, 'command_execution');
                    }
                }
            }

            if (result.success) {
                return {
                    success: true,
                    message: `角色切换成功！${result.message}`,
                    roleSwitched: result.newRole,
                    roleInfo: result.roleConfig,
                    type: 'role_switch'
                };
            } else {
                return this.createErrorResult(`角色切换失败: ${result.message}`);
            }

        } catch (error) {
            console.error('❌ 角色切换执行失败:', error);
            return this.createErrorResult(`角色切换异常: ${error.message}`);
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

        // 添加客气的包装
        return this.wrapResponseWithPoliteness(response);
    }

    /**
     * 为回复添加客气的包装
     * @param {string} content - 原始回复内容
     * @returns {string} 包装后的回复
     */
    wrapResponseWithPoliteness(content) {
        const politePrefix = `老板，收到，你有什么吩咐？基于你的问题， 我有如下建议！\n\n`;
        return politePrefix + content;
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

        // 提供学习资源数据
        const learningResources = this.generateLearningResources(technology);

        return this.createSuccessResult(`为您准备${technology}的学习资源，请查看相关文档`, {
            technology: technology,
            resources: learningResources,
            recommendedPath: this.getRecommendedLearningPath(technology),
            nextSteps: [
                '查看项目文档',
                '运行示例代码',
                '参与社区讨论',
                '实践项目开发'
            ]
        });
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
     * 生成学习资源
     * @param {string} technology - 技术名称
     * @returns {Object} 学习资源
     */
    generateLearningResources(technology) {
        const resources = {
            general: {
                documentation: [
                    { title: '项目README', path: 'README.md', type: 'markdown' },
                    { title: 'ROADMAP规划', path: 'ROADMAP.md', type: 'markdown' },
                    { title: '智能Master控制器指南', path: '.cursor/README.md', type: 'markdown' }
                ],
                scripts: [
                    { name: 'cursor-master.sh', description: '主控制器脚本', path: '.cursor/cursor-master.sh' },
                    { name: 'env-perception.sh', description: '环境感知脚本', path: '.cursor/core/env-perception.sh' },
                    { name: 'quality-manager.sh', description: '质量管理脚本', path: '.cursor/core/quality-manager.sh' }
                ],
                rules: [
                    { name: 'constitution', description: 'AI共生宪法', path: '.cursor/rules/constitution.md' },
                    { name: 'vibe-coding', description: 'VIBE开发原则', path: '.cursor/rules/vibe-coding.md' },
                    { name: 'javascript', description: 'JavaScript开发规则', path: '.cursor/rules/javascript.md' }
                ]
            },
            javascript: {
                documentation: [
                    { title: 'JavaScript开发规则', path: '.cursor/rules/javascript.md', type: 'markdown' },
                    { title: 'ESLint配置', path: '.eslintrc.json', type: 'json' }
                ],
                examples: [
                    { name: '智能Master处理器', path: '.cursor/commands/master-handler.js', type: 'javascript' },
                    { name: '路由器实现', path: '.cursor/commands/master-router.js', type: 'javascript' },
                    { name: '执行器逻辑', path: '.cursor/commands/master-executor.js', type: 'javascript' }
                ]
            },
            react: {
                documentation: [
                    { title: 'React学习资源', path: 'https://reactjs.org/docs/getting-started.html', type: 'external' },
                    { title: '现代React开发', path: 'https://beta.reactjs.org/', type: 'external' }
                ],
                examples: [
                    { name: '组件开发模式', description: '学习React组件开发的最佳实践' },
                    { name: '状态管理', description: '理解React状态管理和数据流' },
                    { name: '性能优化', description: 'React应用性能优化技巧' }
                ]
            },
            nodejs: {
                documentation: [
                    { title: 'Node.js官方文档', path: 'https://nodejs.org/docs/', type: 'external' },
                    { title: 'Express框架', path: 'https://expressjs.com/', type: 'external' }
                ],
                examples: [
                    { name: '服务器构建', path: '.cursor/commands/master-executor.js', type: 'javascript' },
                    { name: 'API开发', description: 'RESTful API开发模式' },
                    { name: '中间件使用', description: 'Express中间件开发' }
                ]
            }
        };

        return resources[technology] || resources.general;
    }

    /**
     * 获取推荐学习路径
     * @param {string} technology - 技术名称
     * @returns {Array} 学习路径步骤
     */
    getRecommendedLearningPath(technology) {
        const paths = {
            general: [
                '1. 阅读项目README.md了解项目概况',
                '2. 查看ROADMAP.md了解开发规划',
                '3. 运行.cursor/cursor-master.sh学习基本用法',
                '4. 探索.cursor目录结构和规则',
                '5. 尝试不同的智能命令',
                '6. 参与项目贡献和发展'
            ],
            javascript: [
                '1. 学习JavaScript基础语法和ES6+特性',
                '2. 了解Node.js运行时和模块系统',
                '3. 学习.cursor/rules/javascript.md规则',
                '4. 分析现有JavaScript代码结构',
                '5. 尝试修改和扩展功能',
                '6. 学习测试和代码质量保证'
            ],
            react: [
                '1. 学习React基础概念和组件',
                '2. 理解JSX语法和虚拟DOM',
                '3. 掌握状态管理和生命周期',
                '4. 学习现代Hook API',
                '5. 了解性能优化技巧',
                '6. 实践项目开发'
            ],
            nodejs: [
                '1. 了解Node.js事件循环和异步编程',
                '2. 学习Express框架和中间件',
                '3. 掌握RESTful API设计',
                '4. 理解包管理和依赖管理',
                '5. 学习数据库集成和部署',
                '6. 实践后端服务开发'
            ]
        };

        return paths[technology] || paths.general;
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
            // 🎭 在执行规则前激活角色
            console.log(`🎭 检查角色激活状态...`);
            if (this.roleManager) {
                const currentRoleInfo = this.roleManager.getCurrentRole();
                if (currentRoleInfo.success) {
                    console.log(`🎭 当前角色: ${currentRoleInfo.role.name} (${currentRoleInfo.role.id})`);
                } else {
                    console.log(`⚠️ 角色系统状态未知`);
                }
            }

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
            // 🎭 在执行脚本前激活角色
            console.log(`🎭 检查角色激活状态...`);
            if (this.roleManager) {
                const currentRoleInfo = this.roleManager.getCurrentRole();
                if (currentRoleInfo.success) {
                    console.log(`🎭 当前角色: ${currentRoleInfo.role.name} (${currentRoleInfo.role.id})`);
                } else {
                    console.log(`⚠️ 角色系统状态未知`);
                }
            }

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
            // 🎭 在执行技能前激活角色
            console.log(`🎭 检查角色激活状态...`);
            if (this.roleManager) {
                const currentRoleInfo = this.roleManager.getCurrentRole();
                if (currentRoleInfo.success) {
                    console.log(`🎭 当前角色: ${currentRoleInfo.role.name} (${currentRoleInfo.role.id})`);
                } else {
                    console.log(`⚠️ 角色系统状态未知`);
                }
            }

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
            const logDir = path.join(this.projectRoot, '.cursorGrowth', 'monitoring', 'logs');
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
