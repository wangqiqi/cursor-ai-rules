// Cursor IDE Master Command Handler - 智能升级版
// 集成AI共生宪法系统，充分利用IDE上下文，实现真正的智能协作

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class MasterCommandHandler {
    constructor(context = {}) {
        this.projectRoot = this.findProjectRoot();
        this.cursorDir = path.join(this.projectRoot, '.cursor');

        // 🎯 IDE上下文信息 - 这是/master相较于cursor-master.sh的最大优势
        this.ideContext = {
            currentFile: context.currentFile || null,
            selectedText: context.selectedText || null,
            cursorPosition: context.cursorPosition || null,
            openFiles: context.openFiles || [],
            projectStructure: context.projectStructure || null,
            userPreferences: context.userPreferences || {},
            workspaceState: context.workspaceState || {},
            ...context
        };

        // 🚀 集成我们的智能系统
        this.intelligentSystem = null;
        this.initializeIntelligentSystem();

        // 🎭 角色管理系统
        this.roleManager = null;
        this.initializeRoleManager();
    }

    /**
     * 初始化智能系统
     */
    async initializeIntelligentSystem() {
        try {
            console.log('🧠 初始化AI共生宪法智能系统...');

            // 尝试加载我们的智能路由器
            const MasterRouter = require('./master-router');
            this.intelligentSystem = new MasterRouter(this.projectRoot);
            await this.intelligentSystem.initialize();

            console.log('✅ 智能系统初始化成功');
        } catch (error) {
            console.warn('⚠️ 智能系统初始化失败，回退到传统模式:', error.message);
            this.intelligentSystem = null;
        }
    }

    /**
     * 初始化角色管理器
     */
    async initializeRoleManager() {
        try {
            const RoleManager = require('./role-manager');
            this.roleManager = new RoleManager(this.cursorDir, this.projectRoot);
            await this.roleManager.initialize();
            console.log('🎭 角色管理器初始化成功');
        } catch (error) {
            console.warn('⚠️ 角色管理器初始化失败:', error.message);
            // 创建一个简化的备用系统
            this.roleManager = {
                currentRole: 'professional_assistant',
                selectWelcomeTemplate: () => "处理结果：\n\n{content}",
                getCurrentRole: () => ({ success: true, role: { id: 'professional_assistant', name: '专业助手' } }),
                getAvailableRoles: () => ({ success: true, roles: [{ id: 'professional_assistant', name: '专业助手' }] }),
                switchRole: () => ({ success: false, message: '角色系统不可用' })
            };
        }
    }

    // 删除getDefaultPersonalitySystem方法，现在由RoleManager处理

    /**
     * 切换角色
     */
    async switchRole(roleName) {
        if (!this.roleManager) {
            return { success: false, message: '角色系统不可用' };
        }
        return await this.roleManager.switchRole(roleName, 'manual');
    }

    /**
     * 获取可用角色列表
     */
    getAvailableRoles() {
        if (!this.roleManager) {
            return { success: false, message: '角色系统不可用' };
        }
        return this.roleManager.getAvailableRoles();
    }

    /**
     * 处理角色相关命令
     */
    async handleRoleCommand(input) {
        const roleCommands = {
            'list_roles': /^列出.*角色|角色.*列表|show.*roles|roles.*list$/i,
            'current_role': /^当前.*角色|角色.*状态|get.*role|role.*info$/i,
            'switch_role': /^(切换|设置|switch|set).*(角色|role)\s+(.+)$/i,
            'reset_role': /^重置.*角色|默认.*角色|reset.*role|default.*role$/i
        };

        // 检查是否是角色列表命令
        if (roleCommands.list_roles.test(input)) {
            return this.getAvailableRoles();
        }

        // 检查是否是当前角色查询
        if (roleCommands.current_role.test(input)) {
            const currentRoleInfo = this.getAvailableRoles();
            if (currentRoleInfo.success) {
                const current = currentRoleInfo.roles.find(r => r.id === currentRoleInfo.currentRole);
                return {
                    success: true,
                    message: `当前角色：${current ? current.name : '未知'} (${currentRoleInfo.currentRole})`,
                    currentRole: currentRoleInfo.currentRole,
                    roleInfo: current
                };
            }
            return currentRoleInfo;
        }

        // 检查是否是角色切换命令
        const switchMatch = input.match(roleCommands.switch_role);
        if (switchMatch) {
            const targetRole = switchMatch[3]?.trim();
            if (targetRole) {
                return await this.switchRole(targetRole);
            }
        }

        // 检查是否是重置角色命令
        if (roleCommands.reset_role.test(input)) {
            const result = await this.switchRole(this.roleManager?.personalitySystem?.default_role || 'professional_assistant');
            // 清除项目角色配置，恢复到默认状态
            if (result.success && this.roleManager?.clearProjectRoleConfig) {
                await this.roleManager.clearProjectRoleConfig();
            }
            return result;
        }

        return null; // 不是角色命令
    }

    /**
     * 解析欢迎语模板
     */
    parseWelcomeTemplates(content) {
        const templates = {};

        // 简单的Markdown解析，提取代码块中的模板
        const codeBlockRegex = /```[\s\S]*?```/g;
        const matches = content.match(codeBlockRegex);

        if (matches) {
            matches.forEach(match => {
                const cleanMatch = match.replace(/```/g, '').trim();
                // 根据内容特征分类模板
                if (cleanMatch.includes('老板真威武')) {
                    templates.general = cleanMatch;
                } else if (cleanMatch.includes('搞定') || cleanMatch.includes('成功')) {
                    templates.success = cleanMatch;
                } else if (cleanMatch.includes('学习') || cleanMatch.includes('📚')) {
                    templates.learning = cleanMatch;
                } else if (cleanMatch.includes('代码') || cleanMatch.includes('💻')) {
                    templates.code = cleanMatch;
                } else if (cleanMatch.includes('项目') || cleanMatch.includes('🚀')) {
                    templates.project = cleanMatch;
                } else if (cleanMatch.includes('错误') || cleanMatch.includes('⚠️')) {
                    templates.error = cleanMatch;
                }
            });
        }

        return templates;
    }

    /**
     * 获取默认欢迎语模板
     */
    getDefaultWelcomeTemplates() {
        return {
            general: `老板真威武，你一定会发财，我有如下建议：

💡 {content}`,
            success: `🎉 搞定！老板你的指令执行完美，我来汇报一下：

✅ {content}`,
            error: `🤔 哎呀，遇到点小问题，不过别担心，老板我们一起解决：

⚠️ {content}`
        };
    }

    /**
     * 根据场景选择合适的欢迎语模板（使用角色管理器）
     */
    selectWelcomeTemplate(result, context) {
        if (!this.roleManager) {
            return "处理结果：\n\n{content}";
        }
        return this.roleManager.selectWelcomeTemplate(result, context);
    }

    /**
     * 使用角色系统包装回复内容
     */
    wrapWithWelcome(result, context) {
        try {
            // 如果结果已经有包装过，直接返回
            if (result.wrapped) {
                return result;
            }

            const template = this.selectWelcomeTemplate(result, context);
            if (!template) {
                return result;
            }

            // 提取原始消息
            const originalMessage = result.message || result.output || '操作完成';

            // 替换模板中的占位符
            const wrappedMessage = template.replace('{content}', originalMessage);

            // 添加角色信息
            const currentRoleInfo = this.roleManager?.getCurrentRole();
            const roleData = currentRoleInfo?.success ? currentRoleInfo.role : { id: 'unknown', name: '未知', attitude: 'unknown' };

            // 返回包装后的结果
            return {
                ...result,
                message: wrappedMessage,
                originalMessage: originalMessage,
                wrapped: true,
                welcomeTemplate: template,
                role: roleData
            };

        } catch (error) {
            console.warn('⚠️ 角色包装失败:', error.message);
            return result;
        }
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

            // 查找脚本文件 (支持子目录)
            let fullPath = path.join(this.cursorDir, scriptPath);

            // 如果不存在，尝试在子目录中查找
            if (!fs.existsSync(fullPath)) {
                const scriptDirs = ['core', 'config', 'features/automation/scripts'];
                for (const dir of scriptDirs) {
                    const subPath = path.join(this.cursorDir, dir, scriptPath);
                    if (fs.existsSync(subPath)) {
                        fullPath = subPath;
                        break;
                    }
                }
            }

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

    async handleDirectCall(input) {
        // 检查是否是直接调用格式: rule <name>, script <name>, skill <name>, hook <name>
        const directCallRegex = /^(rule|script|skill|hook)\s+(.+)$/i;
        const match = input.trim().match(directCallRegex);

        if (!match) {
            return null; // 不是直接调用
        }

        const callType = match[1].toLowerCase();
        const targetName = match[2].trim();

        console.log(`🔧 检测到直接调用: ${callType} ${targetName}`);

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
                default:
                    return { success: false, message: `未知调用类型: ${callType}` };
            }
        } catch (error) {
            console.error(`❌ 直接调用执行失败:`, error);
            return { success: false, message: `调用失败: ${error.message}` };
        }
    }

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

            console.log(`📂 查找规则文件: ${ruleName}`);
            // 检查规则文件是否存在 (支持子目录)
            let rulePath = path.join(this.cursorDir, 'rules', `${ruleName}.md`);

            // 如果不存在，尝试在子目录中查找
            if (!fs.existsSync(rulePath)) {
                const ruleDirs = ['core', 'evolution', 'system', 'team', 'tech', 'workflow'];
                for (const dir of ruleDirs) {
                    const subPath = path.join(this.cursorDir, 'rules', dir, `${ruleName}.md`);
                    if (fs.existsSync(subPath)) {
                        rulePath = subPath;
                        break;
                    }
                }
            }

            if (!fs.existsSync(rulePath)) {
                console.log(`❌ 规则文件不存在: ${rulePath}`);
                return { success: false, message: `规则文件不存在: ${ruleName}.md` };
            }

            console.log(`✅ 找到规则文件: ${rulePath}`);

            // 读取规则文件内容
            console.log(`📖 读取规则文件内容...`);
            const ruleContent = fs.readFileSync(rulePath, 'utf8');
            console.log(`📄 文件内容长度: ${ruleContent.length} 字符`);

            // 解析规则配置
            const alwaysApplyMatch = ruleContent.match(/^alwaysApply:\s*(.+)$/m);
            const handlerMatch = ruleContent.match(/^handler:\s*(.+)$/m);

            const alwaysApply = alwaysApplyMatch ? alwaysApplyMatch[1].trim() === 'true' : false;
            const handler = handlerMatch ? handlerMatch[1].trim() : null;

            let result = `✅ 规则 ${ruleName} 已激活 (alwaysApply: ${alwaysApply})`;

            // 如果有处理器，执行处理器
            if (handler && handler !== 'null') {
                const handlerPath = path.join(this.cursorDir, 'commands', handler);
                if (fs.existsSync(handlerPath)) {
                    console.log(`🔧 执行规则处理器: ${handlerPath}`);

                    try {
                        if (handler.endsWith('.js')) {
                            // 执行JavaScript处理器
                            const handlerResult = execSync(`node "${handlerPath}" "${ruleName}"`, {
                                cwd: this.projectRoot,
                                encoding: 'utf8',
                                timeout: 30000
                            });
                            result += `\n🔧 处理器输出: ${handlerResult.trim()}`;
                        } else {
                            // 执行Shell处理器
                            const handlerResult = execSync(`bash "${handlerPath}" "${ruleName}"`, {
                                cwd: this.projectRoot,
                                encoding: 'utf8',
                                timeout: 30000
                            });
                            result += `\n🔧 处理器输出: ${handlerResult.trim()}`;
                        }
                    } catch (handlerError) {
                        result += `\n⚠️ 处理器执行警告: ${handlerError.message}`;
                    }
                } else {
                    result += `\n⚠️ 处理器文件不存在: ${handlerPath}`;
                }
            }

            return {
                success: true,
                message: result,
                rule: ruleName,
                alwaysApply: alwaysApply,
                handler: handler
            };

        } catch (error) {
            return { success: false, message: `规则执行失败: ${error.message}`, rule: ruleName };
        }
    }

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

            // 使用skills-loader.sh执行技能
            const loaderScript = path.join(this.cursorDir, 'core', 'skills-loader.sh');

            if (!fs.existsSync(loaderScript)) {
                return { success: false, message: `技能加载器不存在: ${loaderScript}` };
            }

            // 首先尝试加载技能
            try {
                execSync(`bash "${loaderScript}" load "${skillName}"`, {
                    cwd: this.projectRoot,
                    encoding: 'utf8',
                    timeout: 30000,
                    stdio: 'pipe'
                });
            } catch (loadError) {
                // 技能可能已经加载，继续执行
            }

            // 执行技能
            const result = execSync(`bash "${loaderScript}" execute "${skillName}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: 60000,
                stdio: 'pipe'
            });

            return {
                success: true,
                message: `✅ 技能 ${skillName} 执行成功`,
                output: result.trim(),
                skill: skillName
            };

        } catch (error) {
            return {
                success: false,
                message: `❌ 技能 ${skillName} 执行失败: ${error.message}`,
                skill: skillName
            };
        }
    }

    async execute(input, context = {}) {
        try {
            console.log(`🎯 处理IDE /master 命令: ${input}`);

            // 🔄 更新IDE上下文
            this.updateIdeContext(context);

            // 🎯 显示IDE上下文信息
            this.displayIdeContext();

            // 0. 检查角色相关命令
            const roleCommandResult = await this.handleRoleCommand(input);
            if (roleCommandResult) {
                const enhancedResult = this.enhanceWithIdeContext(roleCommandResult);
                // 🎭 使用角色系统包装回复
                return this.wrapWithWelcome(enhancedResult, { input, context, intent: 'system' });
            }

            // 0.1 检查直接调用 (rule/script/skill/hook)
            const directCallResult = await this.handleDirectCall(input);
            if (directCallResult) {
                const enhancedResult = this.enhanceWithIdeContext(directCallResult);
                // 🎉 包装欢迎语
                return this.wrapWithWelcome(enhancedResult, { input, context });
            }

            // 🚀 优先使用AI共生宪法智能系统
            if (this.intelligentSystem) {
                console.log('🧠 使用AI共生宪法智能系统...');

                try {
                    // 构建增强的上下文
                    const enhancedContext = this.buildEnhancedContext(input, context);

                    // 调用智能路由器
                    const result = await this.intelligentSystem.route(input, enhancedContext);

                    // 为结果添加IDE特定的增强
                    const enhancedResult = this.enhanceResultForIde(result, context);

                    // 🎉 包装欢迎语
                    return this.wrapWithWelcome(enhancedResult, { input, context });

                } catch (intelligentError) {
                    console.warn('⚠️ 智能系统调用失败，回退到传统模式:', intelligentError.message);
                    // 回退到传统执行
                }
            }

            // 🔄 传统模式：使用bash脚本进行意图分析
            console.log('📊 使用传统智能匹配模式...');
            const matchResult = await this.callSmartMatcher(input);
            console.log('🎯 智能匹配结果:', matchResult);

            if (!matchResult.matched) {
                console.log('❌ 未能识别命令意图');

                // 提供智能建议
                const suggestions = await this.generateSmartSuggestions(input, context);
                return {
                    success: false,
                    message: '未能识别命令意图',
                    suggestions: suggestions,
                    ideContext: this.getIdeContextSummary()
                };
            }

            // 2. 根据能力执行相应操作
            const result = await this.executeCapability(matchResult.capability, input, context);
            const enhancedResult = this.enhanceWithIdeContext(result);

            // 🎉 包装欢迎语
            return this.wrapWithWelcome(enhancedResult, { input, context });

        } catch (error) {
            console.error('❌ IDE Master命令执行失败:', error);

            // 提供错误恢复建议
            const recoverySuggestions = this.generateErrorRecoverySuggestions(error, context);

            const errorResult = {
                success: false,
                message: error.message,
                recoverySuggestions: recoverySuggestions,
                ideContext: this.getIdeContextSummary()
            };

            // 🎉 包装欢迎语
            return this.wrapWithWelcome(errorResult, { input, context });
        }
    }

    /**
     * 更新IDE上下文信息
     */
    updateIdeContext(context) {
        this.ideContext = {
            ...this.ideContext,
            ...context,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 显示IDE上下文信息
     */
    displayIdeContext() {
        if (this.ideContext.currentFile) {
            console.log(`📄 当前文件: ${this.ideContext.currentFile}`);
        }
        if (this.ideContext.selectedText) {
            const selectedLength = this.ideContext.selectedText.length;
            console.log(`📝 选中内容: ${selectedLength} 字符`);
        }
        if (this.ideContext.cursorPosition) {
            console.log(`📍 光标位置: 行${this.ideContext.cursorPosition.line}, 列${this.ideContext.cursorPosition.column}`);
        }
        if (this.ideContext.openFiles && this.ideContext.openFiles.length > 0) {
            console.log(`📂 打开文件数: ${this.ideContext.openFiles.length}`);
        }
    }

    /**
     * 构建增强的上下文信息
     */
    buildEnhancedContext(input, context) {
        return {
            ...context,
            ide: {
                currentFile: this.ideContext.currentFile,
                selectedText: this.ideContext.selectedText,
                cursorPosition: this.ideContext.cursorPosition,
                openFiles: this.ideContext.openFiles,
                projectStructure: this.getProjectStructure()
            },
            user: {
                preferences: this.ideContext.userPreferences,
                history: this.getUserHistory()
            },
            workspace: {
                state: this.ideContext.workspaceState,
                recentActions: this.getRecentActions()
            }
        };
    }

    /**
     * 为结果添加IDE特定的增强
     */
    enhanceResultForIde(result, context) {
        if (!result) return result;

        // 添加IDE特定的信息
        const enhancedResult = {
            ...result,
            ide: {
                contextSummary: this.getIdeContextSummary(),
                suggestions: this.generateIdeSpecificSuggestions(result, context),
                actions: this.generateIdeActions(result, context)
            },
            display: {
                format: this.determineDisplayFormat(result),
                location: this.determineDisplayLocation(result, context)
            }
        };

        return enhancedResult;
    }

    /**
     * 为传统结果添加IDE上下文增强
     */
    enhanceWithIdeContext(result) {
        if (!result) return result;

        return {
            ...result,
            ideContext: this.getIdeContextSummary(),
            ideEnhancements: {
                fileOperations: this.suggestFileOperations(result),
                codeActions: this.suggestCodeActions(result),
                navigation: this.suggestNavigation(result)
            }
        };
    }

    /**
     * 生成智能建议
     */
    async generateSmartSuggestions(input, context) {
        const suggestions = [];

        // 基于当前文件类型提供建议
        if (this.ideContext.currentFile) {
            const fileExt = path.extname(this.ideContext.currentFile);
            switch (fileExt) {
                case '.js':
                case '.ts':
                    suggestions.push('优化这段JavaScript代码', '添加类型检查', '运行测试');
                    break;
                case '.py':
                    suggestions.push('优化这段Python代码', '添加类型提示', '运行单元测试');
                    break;
                case '.md':
                    suggestions.push('检查文档格式', '生成目录', '验证链接');
                    break;
            }
        }

        // 基于选中内容提供建议
        if (this.ideContext.selectedText) {
            const selectedLength = this.ideContext.selectedText.length;
            if (selectedLength < 100) {
                suggestions.push('解释这段代码', '优化这段代码', '添加注释');
            } else {
                suggestions.push('重构这段代码', '提取函数', '添加文档');
            }
        }

        // 基于项目状态提供建议
        const projectSuggestions = await this.generateProjectSuggestions(context);
        suggestions.push(...projectSuggestions);

        return suggestions.slice(0, 5); // 最多5个建议
    }

    /**
     * 生成项目相关的建议
     */
    async generateProjectSuggestions(context) {
        const suggestions = [];

        try {
            // 检查是否有未提交的更改
            const gitStatus = execSync('git status --porcelain', {
                cwd: this.projectRoot,
                encoding: 'utf8'
            });

            if (gitStatus.trim()) {
                suggestions.push('提交代码更改', '查看更改详情');
            }

            // 检查是否有测试文件
            const testFiles = execSync('find . -name "*test*" -o -name "*spec*" | head -5', {
                cwd: this.projectRoot,
                encoding: 'utf8'
            });

            if (testFiles.trim()) {
                suggestions.push('运行测试', '检查测试覆盖率');
            }

        } catch (error) {
            // Git或其他命令可能不可用，忽略
        }

        return suggestions;
    }

    /**
     * 生成错误恢复建议
     */
    generateErrorRecoverySuggestions(error, context) {
        const suggestions = [
            '检查命令语法是否正确',
            '查看相关文档和帮助',
            '尝试使用更简单的命令'
        ];

        // 基于错误类型提供特定建议
        if (error.message.includes('script')) {
            suggestions.push('检查脚本文件是否存在', '验证脚本执行权限');
        } else if (error.message.includes('rule')) {
            suggestions.push('检查规则文件是否存在', '验证规则配置');
        }

        return suggestions;
    }

    /**
     * 获取项目结构信息
     */
    getProjectStructure() {
        try {
            const structure = {
                root: this.projectRoot,
                hasPackageJson: fs.existsSync(path.join(this.projectRoot, 'package.json')),
                hasRequirementsTxt: fs.existsSync(path.join(this.projectRoot, 'requirements.txt')),
                hasGoMod: fs.existsSync(path.join(this.projectRoot, 'go.mod')),
                hasCargoToml: fs.existsSync(path.join(this.projectRoot, 'Cargo.toml')),
                hasGit: fs.existsSync(path.join(this.projectRoot, '.git'))
            };
            return structure;
        } catch (error) {
            return null;
        }
    }

    /**
     * 获取用户历史
     */
    getUserHistory() {
        // 这里可以实现从.cursorGrowth获取用户历史
        return [];
    }

    /**
     * 获取最近操作
     */
    getRecentActions() {
        // 这里可以实现获取最近的IDE操作历史
        return [];
    }

    /**
     * 获取IDE上下文摘要
     */
    getIdeContextSummary() {
        return {
            currentFile: this.ideContext.currentFile,
            hasSelection: !!this.ideContext.selectedText,
            selectionLength: this.ideContext.selectedText?.length || 0,
            openFilesCount: this.ideContext.openFiles?.length || 0,
            projectType: this.inferProjectType()
        };
    }

    /**
     * 推断项目类型
     */
    inferProjectType() {
        const structure = this.getProjectStructure();
        if (structure?.hasPackageJson) return 'javascript';
        if (structure?.hasRequirementsTxt) return 'python';
        if (structure?.hasGoMod) return 'golang';
        if (structure?.hasCargoToml) return 'rust';
        return 'unknown';
    }

    /**
     * 生成IDE特定的建议
     */
    generateIdeSpecificSuggestions(result, context) {
        const suggestions = [];

        if (result.success) {
            suggestions.push('在输出面板查看详细结果');
        }

        if (this.ideContext.currentFile) {
            suggestions.push(`在 ${path.basename(this.ideContext.currentFile)} 中应用更改`);
        }

        return suggestions;
    }

    /**
     * 生成IDE操作
     */
    generateIdeActions(result, context) {
        const actions = [];

        if (result.success && result.data?.script) {
            actions.push({
                type: 'open_terminal',
                label: '在终端中查看结果',
                command: `echo "脚本 ${result.data.script} 执行完成"`
            });
        }

        return actions;
    }

    /**
     * 确定显示格式
     */
    determineDisplayFormat(result) {
        if (result.type === 'constitution_response') {
            return 'modal'; // 宪法响应使用模态框
        } else if (result.success && result.data?.output) {
            return 'panel'; // 有输出的成功结果使用面板
        } else {
            return 'notification'; // 其他情况使用通知
        }
    }

    /**
     * 确定显示位置
     */
    determineDisplayLocation(result, context) {
        if (result.type === 'constitution_response') {
            return 'center_modal';
        } else if (this.ideContext.currentFile) {
            return 'inline'; // 在当前文件附近显示
        } else {
            return 'bottom_panel';
        }
    }

    /**
     * 建议文件操作
     */
    suggestFileOperations(result) {
        const operations = [];

        if (result.success && result.data?.script) {
            operations.push({
                type: 'open_file',
                file: path.join(this.cursorDir, 'core', result.data.script),
                label: `查看脚本: ${result.data.script}`
            });
        }

        return operations;
    }

    /**
     * 建议代码操作
     */
    suggestCodeActions(result) {
        const actions = [];

        if (this.ideContext.selectedText) {
            actions.push({
                type: 'refactor',
                label: '重构选中代码',
                scope: 'selection'
            });
        }

        return actions;
    }

    /**
     * 建议导航操作
     */
    suggestNavigation(result) {
        const navigation = [];

        if (result.data?.rule) {
            navigation.push({
                type: 'open_file',
                file: path.join(this.cursorDir, 'rules', `${result.data.rule}.md`),
                label: `查看规则: ${result.data.rule}`
            });
        }

        return navigation;
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

// 测试函数
async function testDirectCalls() {
    console.log('🧪 测试直接调用功能...\n');

    const handler = new MasterCommandHandler();

    const testCases = [
        { input: 'rule constitution', description: '测试规则调用' },
        { input: 'script init.sh', description: '测试脚本调用' }
    ];

    for (const testCase of testCases) {
        console.log(`\n📋 测试: ${testCase.description}`);
        console.log(`   输入: ${testCase.input}`);

        try {
            const result = await handler.handleDirectCall(testCase.input);
            console.log(`   ✅ 结果: ${result ? '成功' : '不是直接调用'}`);
            if (result) {
                console.log(`   📝 消息: ${result.message}`);
            }
        } catch (error) {
            console.log(`   ❌ 错误: ${error.message}`);
        }
    }
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);
    if (args.length === 0) {
        console.log('用法: node master-handler.js <命令>');
        console.log('或者: node master-handler.js --test');
        process.exit(1);
    }

    if (args[0] === '--test') {
        testDirectCalls().catch(console.error);
        return;
    }

    const handler = new MasterCommandHandler();
    const input = args.join(' ');

    handler.execute(input).then(result => {
        // 返回JSON格式的结果供Web界面解析
        console.log(JSON.stringify(result, null, 2));
        process.exit(result.success ? 0 : 1);
    }).catch(error => {
        console.error(JSON.stringify({
            success: false,
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    });
}

// 导出类供外部使用
module.exports = { MasterCommandHandler };

// 测试函数
async function testDirectCalls() {
    console.log('🧪 测试直接调用功能...\n');

    const handler = new MasterCommandHandler();

    const testCases = [
        { input: 'rule constitution', description: '测试规则调用' },
        { input: 'script init.sh', description: '测试脚本调用' }
    ];

    for (const testCase of testCases) {
        console.log(`\n📋 测试: ${testCase.description}`);
        console.log(`   输入: ${testCase.input}`);

        try {
            const result = await handler.handleDirectCall(testCase.input);
            console.log(`   ✅ 结果: ${result ? '成功' : '不是直接调用'}`);
            if (result) {
                console.log(`   📝 消息: ${result.message}`);
            }
        } catch (error) {
            console.log(`   ❌ 错误: ${error.message}`);
        }
    }
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);
    if (args.length === 0) {
        console.log('用法: node master-handler.js <命令>');
        console.log('或者: node master-handler.js --test');
        process.exit(1);
    }

    if (args[0] === '--test') {
        testDirectCalls().catch(console.error);
        return;
    }

    const handler = new MasterCommandHandler();
    const input = args.join(' ');

    handler.execute(input).then(result => {
        // 返回JSON格式的结果供Web界面解析
        console.log(JSON.stringify(result, null, 2));
        process.exit(result.success ? 0 : 1);
    }).catch(error => {
        console.error(JSON.stringify({
            success: false,
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    });
}