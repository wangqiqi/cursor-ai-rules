// Cursor AI Rules - Master Command Executor
// 负责执行解析后的命令，协调各种组件

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

/**
 * 资源发现中心 - 统一管理所有资源类型的查找
 */
class ResourceDiscoveryCenter {
    constructor(projectRoot, cursorDir) {
        this.projectRoot = projectRoot;
        this.cursorDir = cursorDir;
        this.cache = new Map();
        this.cacheTTL = 300000; // 5分钟缓存
    }

    /**
     * 查找规则文件
     * @param {string} ruleName - 规则名称
     * @returns {string|null} 规则文件路径
     */
    findRule(ruleName) {
        const cacheKey = `rule_${ruleName}`;
        const cached = this.getCached(cacheKey);
        if (cached) return cached;

        if (path.isAbsolute(ruleName) && fs.existsSync(ruleName)) {
            this.setCached(cacheKey, ruleName);
            return ruleName;
        }

        const name = ruleName.endsWith('.md') ? ruleName.slice(0, -3) : ruleName;
        const ruleBaseDir = path.join(this.cursorDir, 'rules');

        // 1. 检查根目录
        const rootPath = path.join(ruleBaseDir, `${name}.md`);
        if (fs.existsSync(rootPath)) {
            this.setCached(cacheKey, rootPath);
            return rootPath;
        }

        // 2. 递归查找所有子目录
        const result = this.recursiveFind(ruleBaseDir, name, ['.md']);
        this.setCached(cacheKey, result);
        return result;
    }

    /**
     * 查找脚本文件
     * @param {string} scriptName - 脚本名称
     * @returns {string|null} 脚本文件路径
     */
    findScript(scriptName) {
        const cacheKey = `script_${scriptName}`;
        const cached = this.getCached(cacheKey);
        if (cached) return cached;

        let scriptPath = scriptName;

        // 如果不是绝对路径，尝试查找
        if (!path.isAbsolute(scriptName)) {
            // 1. 尝试直接拼接 .cursor 目录
            const directPath = path.join(this.cursorDir, scriptName);
            if (fs.existsSync(directPath)) {
                scriptPath = directPath;
            } else {
                // 2. 递归查找
                scriptPath = this.recursiveFind(this.cursorDir, scriptName, ['.sh', '.js']) || scriptName;
            }
        }

        this.setCached(cacheKey, scriptPath);
        return scriptPath;
    }

    /**
     * 查找钩子文件
     * @param {string} hookName - 钩子名称
     * @returns {string|null} 钩子文件路径
     */
    findHook(hookName) {
        const cacheKey = `hook_${hookName}`;
        const cached = this.getCached(cacheKey);
        if (cached) return cached;

        const result = this.recursiveFind(path.join(this.cursorDir, 'features', 'hooks'), hookName, ['.sh', '.js']);
        this.setCached(cacheKey, result);
        return result;
    }

    /**
     * 查找技能文件
     * @param {string} skillName - 技能名称
     * @returns {string|null} 技能文件路径
     */
    findSkill(skillName) {
        const cacheKey = `skill_${skillName}`;
        const cached = this.getCached(cacheKey);
        if (cached) return cached;

        const result = this.recursiveFind(path.join(this.cursorDir, 'features', 'skills'), skillName, ['.md', '.sh']);
        this.setCached(cacheKey, result);
        return result;
    }

    /**
     * 查找工作流文件
     * @param {string} workflowName - 工作流名称
     * @returns {string|null} 工作流文件路径
     */
    findWorkflow(workflowName) {
        const cacheKey = `workflow_${workflowName}`;
        const cached = this.getCached(cacheKey);
        if (cached) return cached;

        // 工作流可能在多个位置
        const locations = [
            path.join(this.cursorDir, 'rules', 'workflow'),
            path.join(this.cursorDir, 'features', 'automation'),
            path.join(this.cursorDir, 'features', 'automation', 'scripts')
        ];

        for (const location of locations) {
            const result = this.recursiveFind(location, workflowName, ['.md', '.sh', '.js']);
            if (result) {
                this.setCached(cacheKey, result);
                return result;
            }
        }

        this.setCached(cacheKey, null);
        return null;
    }

    /**
     * 通用递归查找方法
     * @param {string} baseDir - 基础目录
     * @param {string} resourceName - 资源名称
     * @param {string[]} extensions - 允许的后缀
     * @returns {string|null} 找到的绝对路径
     */
    recursiveFind(baseDir, resourceName, extensions = []) {
        if (!fs.existsSync(baseDir)) return null;

        // 规范化输入：移除可能的相对路径前缀，提取纯净名称
        const cleanName = resourceName.replace(/^\.\//, "").replace(/^\.cursor\//, "");
        const fileName = path.basename(cleanName);
        const nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");

        // 1. 尝试直接路径匹配
        const directPaths = [
            path.join(baseDir, cleanName),
            path.join(this.projectRoot, cleanName),
            path.join(this.cursorDir, cleanName)
        ];

        for (const p of directPaths) {
            if (fs.existsSync(p) && fs.statSync(p).isFile()) return p;
            for (const ext of extensions) {
                const pWithExt = p.endsWith(ext) ? p : `${p}${ext}`;
                if (fs.existsSync(pWithExt) && fs.statSync(pWithExt).isFile()) return pWithExt;
            }
        }

        // 2. 深度优先搜索
        const search = (currentDir) => {
            const entries = fs.readdirSync(currentDir, { withFileTypes: true });

            // 优先查找文件
            for (const entry of entries) {
                if (entry.isFile()) {
                    if (entry.name === fileName) return path.join(currentDir, entry.name);
                    for (const ext of extensions) {
                        if (entry.name === `${nameWithoutExt}${ext}`) return path.join(currentDir, entry.name);
                    }
                }
            }

            // 再递归目录
            for (const entry of entries) {
                if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
                    const found = search(path.join(currentDir, entry.name));
                    if (found) return found;
                }
            }
            return null;
        };

        return search(baseDir);
    }

    /**
     * 获取缓存
     * @param {string} key - 缓存键
     * @returns {any} 缓存值
     */
    getCached(key) {
        const cached = this.cache.get(key);
        if (cached && (Date.now() - cached.timestamp) < this.cacheTTL) {
            return cached.value;
        }
        return null;
    }

    /**
     * 设置缓存
     * @param {string} key - 缓存键
     * @param {any} value - 缓存值
     */
    setCached(key, value) {
        this.cache.set(key, {
            value: value,
            timestamp: Date.now()
        });
    }

    /**
     * 清理过期缓存
     */
    cleanupCache() {
        const now = Date.now();
        for (const [key, value] of this.cache.entries()) {
            if (now - value.timestamp > this.cacheTTL) {
                this.cache.delete(key);
            }
        }
    }

    /**
     * 获取统计信息
     * @returns {Object} 统计信息
     */
    getStats() {
        return {
            cacheSize: this.cache.size,
            cacheTTL: this.cacheTTL,
            timestamp: new Date().toISOString()
        };
    }
}

class MasterCommandExecutor {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');
        this.executionTimeout = 30000; // 30秒默认超时
        this.maxConcurrency = 3; // 最大并发数

        // 初始化标志
        this.initialized = false;
        this.roleManager = null;

        // 🚀 初始化资源发现中心
        this.resourceDiscovery = new ResourceDiscoveryCenter(projectRoot, this.cursorDir);
    }

    /**
     * 初始化执行器
     */
    async initialize() {
        if (this.initialized) return;
        await this.initializeRoleManager();

        // 🚀 加载钩子配置
        this.hooksConfig = this.loadHooksConfig();

        this.initialized = true;
        console.log('✅ Master执行器初始化完成');
    }

    /**
     * 加载钩子配置文件
     */
    loadHooksConfig() {
        try {
            const configPath = path.join(this.cursorDir, 'features', 'hooks', 'hooks.json');
            if (fs.existsSync(configPath)) {
                return JSON.parse(fs.readFileSync(configPath, 'utf8'));
            }
        } catch (error) {
            console.warn('⚠️ 无法加载 hooks.json:', error.message);
        }
        return { hooks: {} };
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
     * 🚀 优化：延迟检查项目角色配置 - 提升角色呼叫性能
     */
    scheduleProjectRoleCheck() {
        if (this.projectRoleCheckScheduled) return;

        this.projectRoleCheckScheduled = true;
        // 延迟500ms检查，避免阻塞角色呼叫响应
        setTimeout(async () => {
            try {
                await this.ensureProjectRoleConfig();
            } catch (error) {
                console.warn('⚠️ 延迟项目角色检查失败:', error.message);
            } finally {
                this.projectRoleCheckScheduled = false;
            }
        }, 500);
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
        if (!this.initialized) {
            await this.initialize();
        }

        try {
            // 🚀 优化：只在角色相关命令时检查项目角色配置
            if (parseResult.type === 'role_switch' || parseResult.type === 'direct_call') {
                const { callType } = parseResult;
                if (parseResult.type === 'direct_call' && (callType === 'call' || callType === 'nickname')) {
                    // 角色呼叫命令 - 延迟检查以提升性能
                    this.scheduleProjectRoleCheck();
                } else {
                    // 其他角色相关命令 - 正常检查
                    await this.ensureProjectRoleConfig();
                }
            }

            if (!parseResult || !parseResult.success) {
                return this.createErrorResult('无效的解析结果');
            }

            console.log(`🎯 执行命令类型: ${parseResult.type}`);

            switch (parseResult.type) {
                case 'direct_call':
                    return await this.executeDirectCall(parseResult);

                case 'role_switch':
                    return await this.executeRoleSwitch(parseResult);

                case 'compound_commands':
                    return await this.executeCompoundCommands(parseResult);

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

                case 'call':
                case 'nickname':
                    return await this.executeRoleCall(targetName);

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
        const { intent, parameters, constitution, analysis } = parseResult;

        console.log(`🧠 执行自然语言命令 - 意图: ${intent}`);

        // 检查宪法合规性
        if (!constitution.compliant) {
            return await this.handleConstitutionViolation(parseResult);
        }

        // 🚀 动态执行：如果分析结果中有能力定义，则按定义执行
        if (analysis && analysis.capabilities) {
            return await this.executeByCapabilityMapping(analysis, parameters);
        }

        // 回退到硬编码的意图处理 (保持兼容性)
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

            case 'learning_status':
                return await this.handleLearningStatusIntent(parameters);

            default:
                return await this.handleGenericIntent(intent, parameters);
        }
    }

    /**
     * 执行复合指令（顺序执行多个子指令）
     * @param {Object} parseResult - 解析结果
     * @returns {Promise<Object>} 执行结果
     */
    async executeCompoundCommands(parseResult) {
        const { subCommands } = parseResult;
        const results = [];
        let overallSuccess = true;

        console.log(`🔀 开始执行复合指令，共 ${subCommands.length} 个子指令`);

        for (let i = 0; i < subCommands.length; i++) {
            const subCmd = subCommands[i];
            console.log(`\n📋 执行子指令 ${i + 1}/${subCommands.length}: "${subCmd.input}"`);

            try {
                // 根据子指令的解析结果执行相应操作
                const subResult = await this.executeParsedCommand(subCmd.parsed);

                results.push({
                    index: i + 1,
                    input: subCmd.input,
                    parsed: subCmd.parsed,
                    result: subResult
                });

                if (!subResult.success) {
                    console.warn(`⚠️ 子指令 ${i + 1} 执行失败: ${subResult.error || subResult.message}`);
                    overallSuccess = false;
                    // 可以选择是否继续执行后续指令
                    // break; // 如果需要严格顺序，可以取消注释
                } else {
                    console.log(`✅ 子指令 ${i + 1} 执行成功`);
                }

            } catch (error) {
                console.error(`❌ 子指令 ${i + 1} 执行异常:`, error);
                results.push({
                    index: i + 1,
                    input: subCmd.input,
                    parsed: subCmd.parsed,
                    result: { success: false, error: error.message }
                });
                overallSuccess = false;
            }
        }

        return {
            success: overallSuccess,
            message: `复合指令执行完成: ${results.filter(r => r.result?.success).length}/${results.length} 个子指令成功`,
            type: 'compound_commands',
            details: results,
            originalInput: parseResult.originalInput,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 执行已解析的单个命令（用于复合指令的子指令执行）
     * @param {Object} parsedCommand - 已解析的命令
     * @returns {Promise<Object>} 执行结果
     */
    async executeParsedCommand(parsedCommand) {
        switch (parsedCommand.type) {
            case 'direct_call':
                return await this.executeDirectCall(parsedCommand);

            case 'role_switch':
                return await this.executeRoleSwitch(parsedCommand);

            case 'natural_language':
                return await this.executeNaturalLanguage(parsedCommand);

            case 'error':
                return parsedCommand;

            default:
                return this.createErrorResult(`未知的子命令类型: ${parsedCommand.type}`);
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
     * 生成宪法合规性响应 (增强版 - 与规则模板对齐)
     * @param {Object} parseResult - 解析结果
     * @returns {string} 响应消息
     */
    generateConstitutionResponse(parseResult) {
        const { intent, parameters, analysis } = parseResult;

        let response = `## 🤖 检测到项目创建意图\n\n`;
        response += `检测到你想要**创建新项目**！\n\n`;

        response += `### 📋 需求分析\n`;
        response += `- **项目类型**: ${parameters.projectType || '待分析'}\n`;
        response += `- **技术领域**: ${analysis?.category || '通用软件开发'}\n`;
        response += `- **复杂度评估**: 中等 (基于意图初步评估)\n\n`;

        response += `### 🛠️ 推荐技术方案\n`;
        if (parameters.projectType === 'react') {
            response += `- **前端**: React + TypeScript + Vite\n`;
            response += `- **状态管理**: Zustand 或 TanStack Query\n`;
            response += `- **样式**: Tailwind CSS\n\n`;
        } else if (parameters.projectType === 'node' || parameters.projectType === 'nodejs') {
            response += `- **后端**: Node.js + Express/NestJS\n`;
            response += `- **数据库**: PostgreSQL (Prisma ORM)\n`;
            response += `- **API规范**: RESTful 或 GraphQL\n\n`;
        } else {
            response += `根据您的描述，我将为您量身定制最合适的技术方案。建议从主流稳定的技术栈开始。\n\n`;
        }

        response += `### ❓ 需要澄清的问题\n`;
        response += `1. 这个项目的核心功能和目标用户是谁？\n`;
        response += `2. 您是否有偏好的技术栈或特殊的性能要求？\n`;
        response += `3. 项目的预计交付周期和当前所处的阶段？\n\n`;

        response += `**⚖️ 宪法要求：必须先与您讨论需求和方案，获得明确确认后才能开始开发！**\n\n`;
        response += `**请先与我讨论需求和方案，确认后再开始开发！** 🎯`;

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
     * 根据能力映射动态执行任务
     * @param {Object} mapping - 能力映射配置
     * @param {Object} parameters - 执行参数
     * @returns {Promise<Object>} 执行结果
     */
    async executeByCapabilityMapping(mapping, parameters) {
        const { capabilities, execution_order = ['rules', 'scripts', 'skills'] } = mapping;
        const results = [];
        let overallSuccess = true;

        console.log(`🚀 开始动态执行能力映射: ${mapping.description || mapping.intent}`);

        for (const type of execution_order) {
            const targets = capabilities[type];
            if (!targets || !Array.isArray(targets) || targets.length === 0) continue;

            console.log(`📦 执行阶段: ${type}`);
            for (const target of targets) {
                // 🚀 智能过滤：如果参数中指定了特定的资源名，且当前资源不是它，则跳过
                // 专门针对 skills_execution 意图进行优化
                if (mapping.intent === 'skills_execution' && type === 'skills') {
                    if (parameters.skill_name && parameters.skill_name !== 'auto') {
                        const normalizedTarget = target.toLowerCase();
                        const normalizedParam = parameters.skill_name.toLowerCase();
                        if (!normalizedTarget.includes(normalizedParam) && !normalizedParam.includes(normalizedTarget)) {
                            console.log(`⏭️ 跳过不匹配的技能: ${target}`);
                            continue;
                        }
                    }
                }

                let result;
                try {
                    switch (type) {
                        case 'rules':
                            result = await this.executeRule(target);
                            break;
                        case 'scripts':
                            result = await this.executeScript(target, parameters);
                            break;
                        case 'skills':
                            result = await this.executeSkill(target, parameters);
                            break;
                        case 'hooks':
                            result = await this.executeHook(target, parameters);
                            break;
                        case 'workflows':
                            result = await this.executeWorkflow(target, parameters);
                            break;
                        default:
                            console.warn(`⚠️ 未知的资源类型: ${type}`);
                            continue;
                    }
                    results.push({ type, target, result });
                    if (!result.success) {
                        console.warn(`⚠️ 资源执行失败: ${type} ${target} - ${result.error || result.message}`);
                        // 某些失败可能不影响整体，这里简单处理
                    }
                } catch (error) {
                    console.error(`❌ 执行异常: ${type} ${target}`, error);
                    results.push({ type, target, error: error.message, success: false });
                    overallSuccess = false;
                }
            }
        }

        return {
            success: overallSuccess,
            message: `能力映射执行完成: ${mapping.description || mapping.intent}`,
            details: results,
            timestamp: new Date().toISOString()
        };
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
            let rulePath = this.resourceDiscovery.findRule(ruleName);
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
     * 查找规则文件 (增强版)
     * @param {string} ruleName - 规则名称
     * @returns {string|null} 规则文件路径
     */
    findRuleFile(ruleName) {
        if (path.isAbsolute(ruleName) && fs.existsSync(ruleName)) return ruleName;
        return this.resourceDiscovery.findRule(ruleName);
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
     * 执行脚本 (增强版)
     * @param {string} scriptName - 脚本名称
     * @param {Object} params - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async executeScript(scriptName, params = {}) {
        console.log(`🔧 执行脚本: ${scriptName}`);

        try {
            // 🎭 在执行脚本前激活角色
            if (this.roleManager) {
                this.roleManager.getCurrentRole(); // 简单触发一下
            }

            let scriptPath = scriptName;

            // 如果不是绝对路径，尝试递归查找
            if (!path.isAbsolute(scriptName)) {
                scriptPath = this.resourceDiscovery.findScript(scriptName);
            }

            if (!scriptPath || !fs.existsSync(scriptPath)) {
                return this.createErrorResult(`脚本不存在: ${scriptName}`);
            }

            // 执行脚本
            const ext = path.extname(scriptPath);
            let command = ext === '.js' ? `node "${scriptPath}"` : `bash "${scriptPath}"`;

            const result = execSync(command, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout,
                env: { ...process.env, ...params }
            });

            return this.createSuccessResult(`脚本执行成功: ${path.basename(scriptPath)}`, {
                script: scriptName,
                path: scriptPath,
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
            // 查找技能文件 (可能在 features/skills/)
            const skillPath = this.resourceDiscovery.findSkill(skillName);

            const loaderScript = path.join(this.cursorDir, 'core', 'skills-loader.sh');
            if (!fs.existsSync(loaderScript)) {
                return this.createErrorResult(`技能加载器不存在`);
            }

            // 先尝试加载技能
            console.log(`📦 加载技能: ${skillName}`);
            const loadResult = execSync(`bash "${loaderScript}" load "${skillName}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout
            });
            console.log(`✅ 技能加载完成: ${skillName}`);

            // 然后执行技能
            console.log(`🚀 执行技能: ${skillName}`);
            const result = execSync(`bash "${loaderScript}" execute "${skillName}"`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout * 2
            });

            return this.createSuccessResult(`技能执行成功: ${skillName}`, {
                skill: skillName,
                path: skillPath,
                loadOutput: loadResult.trim(),
                executeOutput: result.trim()
            });

        } catch (error) {
            return this.createErrorResult(`技能执行失败: ${error.message}`);
        }
    }

    /**
     * 执行角色呼叫（通过昵称）- ⚡ 闪电级超高速优化版
     * @param {string} nickname - 角色昵称
     * @returns {Promise<Object>} 执行结果
     */
    async executeRoleCall(nickname) {
        const startTime = process.hrtime.bigint();
        console.log(`🎭 闪电角色呼叫: ${nickname}`);

        try {
            // 确保角色管理器已初始化
            if (!this.roleManager) {
                return this.createErrorResult('角色管理系统不可用');
            }

            // ⚡ 超高速昵称查找 (内存级)
            const lookupStart = process.hrtime.bigint();
            const roleResult = this.roleManager.findRoleByNickname(nickname);
            const lookupTime = Number(process.hrtime.bigint() - lookupStart) / 1000000; // ms

            if (!roleResult.success) {
                return this.createErrorResult(roleResult.message);
            }

            // ⚡ 快速角色切换 (异步优化)
            const switchStart = process.hrtime.bigint();
            const switchResult = await this.roleManager.switchRole(roleResult.roleId, 'nickname_call');
            const switchTime = Number(process.hrtime.bigint() - switchStart) / 1000000; // ms

            if (!switchResult.success) {
                return this.createErrorResult(`角色切换失败: ${switchResult.message}`);
            }

            // ⚡ 极致优化响应生成 - 预编译模板
            const generateStart = process.hrtime.bigint();
            const welcomeMessage = this.generateFastWelcomeMessage(roleResult.roleConfig, nickname);
            const generateTime = Number(process.hrtime.bigint() - generateStart) / 1000000; // ms

            const totalTime = Number(process.hrtime.bigint() - startTime) / 1000000; // ms

            // 添加性能统计到响应
            const perfStats = `\n\n📊 性能统计: 查找${lookupTime.toFixed(1)}ms | 切换${switchTime.toFixed(1)}ms | 生成${generateTime.toFixed(1)}ms | 总计${totalTime.toFixed(1)}ms`;
            const finalMessage = welcomeMessage + perfStats;

            return this.createSuccessResult(finalMessage, {
                role: roleResult.roleId,
                nickname: nickname,
                matchedBy: roleResult.matchedBy,
                fastMode: true,
                performance: {
                    lookupTime,
                    switchTime,
                    generateTime,
                    totalTime
                }
            });

        } catch (error) {
            const totalTime = Number(process.hrtime.bigint() - startTime) / 1000000;
            console.error(`❌ 角色呼叫失败 (${totalTime.toFixed(1)}ms):`, error);
            return this.createErrorResult(`角色呼叫失败: ${error.message}`);
        }
    }

    /**
     * 🚀 优化感官反应格式化 - 减少字符串操作
     */
    formatSensoryReactions(sensoryReactions) {
        if (!sensoryReactions) return '';

        const reactions = [];
        const senses = sensoryReactions;

        if (senses.vision) reactions.push(`👁️ ${senses.vision}`);
        if (senses.hearing) reactions.push(`👂 ${senses.hearing}`);
        if (senses.touch) reactions.push(`✋ ${senses.touch}`);
        if (senses.intuition) reactions.push(`🔮 ${senses.intuition}`);

        return reactions.length > 0 ? reactions.join('\n') : '';
    }

    /**
     * ⚡ 极致优化欢迎消息生成 - 预编译模板
     */
    generateFastWelcomeMessage(roleConfig, nickname) {
        // 预编译的核心信息
        const roleName = roleConfig.name;
        const description = roleConfig.description;
        const innerVoice = roleConfig.personality_traits?.inner_voice;
        const sensoryReactions = this.formatSensoryReactions(roleConfig.sensory_reactions);

        // 使用模板字符串优化，避免多次字符串拼接
        let message = `🎭 已切换到角色: **${roleName}**`;

        if (description) {
            message += `\n\n💫 ${description}`;
        }

        if (innerVoice) {
            message += `\n\n💭 *${innerVoice}*`;
        }

        if (sensoryReactions) {
            message += `\n\n${sensoryReactions}`;
        }

        message += `\n\n✨ 现在可以用这个角色的风格与你交流了！有什么需要帮助的吗？`;

        return message;
    }

    /**
     * 执行钩子 (增强版 - 支持钩子配置和链式调用)
     * @param {string} hookName - 钩子名称
     * @returns {Promise<Object>} 执行结果
     */
    async executeHook(hookName, params = {}) {
        console.log(`🎣 执行钩子: ${hookName}`);

        try {
            // 1. 尝试从 hooks.json 配置中查找
            const hookConfig = this.findHookInConfig(hookName);
            if (hookConfig) {
                return await this.executeHookByConfig(hookConfig, params);
            }

            // 2. 回退到文件查找模式
            const hookPath = this.resourceDiscovery.findHook(hookName);

            if (!hookPath || !fs.existsSync(hookPath)) {
                return this.createErrorResult(`钩子不存在: ${hookName}`);
            }

            const ext = path.extname(hookPath);
            const command = ext === '.js' ? `node "${hookPath}"` : `bash "${hookPath}"`;

            const result = execSync(command, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: this.executionTimeout,
                env: { ...process.env, ...params }
            });

            return this.createSuccessResult(`钩子执行成功: ${path.basename(hookPath)}`, {
                hook: hookName,
                path: hookPath,
                output: result.trim()
            });

        } catch (error) {
            return this.createErrorResult(`钩子执行失败: ${error.message}`);
        }
    }

    /**
     * 在钩子配置中查找钩子
     * @param {string} hookName - 钩子名称
     * @returns {Object|null} 钩子配置
     */
    findHookInConfig(hookName) {
        if (!this.hooksConfig?.hooks) return null;

        // 遍历所有钩子事件类型
        for (const [eventType, hooks] of Object.entries(this.hooksConfig.hooks)) {
            if (Array.isArray(hooks)) {
                const found = hooks.find(hook => hook.name === hookName);
                if (found) {
                    return { ...found, eventType };
                }
            }
        }
        return null;
    }

    /**
     * 根据配置执行钩子
     * @param {Object} hookConfig - 钩子配置
     * @param {Object} params - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async executeHookByConfig(hookConfig, params = {}) {
        try {
            const { name, command, args = [], timeout, async = true, enabled = true } = hookConfig;

            if (!enabled) {
                return this.createSuccessResult(`钩子已禁用: ${name}`, {
                    hook: name,
                    status: 'disabled'
                });
            }

            // 解析命令路径
            const hookPath = this.resolveHookCommandPath(command);
            if (!hookPath) {
                return this.createErrorResult(`钩子命令不存在: ${command}`);
            }

            // 构建完整命令
            const fullCommand = this.buildHookCommand(hookPath, args, params);

            // 执行命令
            const execOptions = {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: timeout || this.executionTimeout,
                env: { ...process.env, ...params }
            };

            const result = execSync(fullCommand, execOptions);

            return this.createSuccessResult(`钩子执行成功: ${name}`, {
                hook: name,
                path: hookPath,
                command: fullCommand,
                output: result.trim(),
                eventType: hookConfig.eventType
            });

        } catch (error) {
            return this.createErrorResult(`钩子配置执行失败: ${error.message}`, {
                hook: hookConfig.name,
                command: hookConfig.command
            });
        }
    }

    /**
     * 解析钩子命令路径
     * @param {string} command - 命令路径
     * @returns {string|null} 绝对路径
     */
    resolveHookCommandPath(command) {
        // 如果已经是绝对路径
        if (path.isAbsolute(command)) {
            return fs.existsSync(command) ? command : null;
        }

        // 尝试多种路径解析
        const possiblePaths = [
            path.join(this.cursorDir, command),
            path.join(this.cursorDir, 'features', 'hooks', command),
            path.join(this.cursorDir, 'core', command),
            path.join(this.projectRoot, command)
        ];

        for (const p of possiblePaths) {
            if (fs.existsSync(p)) return p;
        }

        // 使用递归查找作为最后手段
        return this.resourceDiscovery.recursiveFind(this.cursorDir, command, ['.sh', '.js']);
    }

    /**
     * 构建钩子命令
     * @param {string} hookPath - 钩子路径
     * @param {string[]} args - 参数数组
     * @param {Object} params - 额外参数
     * @returns {string} 完整命令
     */
    buildHookCommand(hookPath, args = [], params = {}) {
        const ext = path.extname(hookPath);

        let command;
        if (ext === '.js') {
            command = `node "${hookPath}"`;
        } else {
            command = `bash "${hookPath}"`;
        }

        // 添加参数
        if (args && args.length > 0) {
            command += ` ${args.join(' ')}`;
        }

        // 添加动态参数
        if (params.args && Array.isArray(params.args)) {
            command += ` ${params.args.join(' ')}`;
        }

        return command;
    }

    /**
     * 执行钩子链 (支持批量执行)
     * @param {string[]} hookNames - 钩子名称数组
     * @param {Object} params - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async executeHookChain(hookNames, params = {}) {
        console.log(`🔗 执行钩子链: ${hookNames.join(' → ')}`);

        const results = [];
        let overallSuccess = true;

        for (const hookName of hookNames) {
            const result = await this.executeHook(hookName, params);
            results.push(result);

            if (!result.success) {
                console.warn(`⚠️ 钩子链中断于: ${hookName}`);
                overallSuccess = false;
                // 可以选择是否继续执行后续钩子
                // break; // 如果需要严格顺序，可以取消注释
            }
        }

        return {
            success: overallSuccess,
            message: `钩子链执行完成 (${results.filter(r => r.success).length}/${results.length})`,
            details: results,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 执行工作流 (复合型资源执行)
     * @param {string} workflowName - 工作流名称
     * @param {Object} params - 参数
     * @returns {Promise<Object>} 执行结果
     */
    async executeWorkflow(workflowName, params = {}) {
        console.log(`🔄 执行工作流: ${workflowName}`);

        try {
            const results = [];
            let overallSuccess = true;

            // 1. 解析工作流配置
            const workflowConfig = await this.parseWorkflowConfig(workflowName);
            if (!workflowConfig) {
                return this.createErrorResult(`工作流配置不存在: ${workflowName}`);
            }

            // 2. 按顺序执行工作流步骤
            const steps = workflowConfig.steps || workflowConfig.execution_order || ['rules', 'scripts', 'skills', 'hooks'];

            for (const step of steps) {
                const stepResults = await this.executeWorkflowStep(step, workflowConfig, params);
                results.push(...stepResults);

                // 检查是否有失败的步骤
                const failedSteps = stepResults.filter(r => !r.result?.success);
                if (failedSteps.length > 0) {
                    console.warn(`⚠️ 工作流步骤失败: ${step} (${failedSteps.length} 个失败)`);
                    overallSuccess = false;
                }
            }

            return {
                success: overallSuccess,
                message: `工作流执行完成: ${workflowName} (${results.filter(r => r.result?.success).length}/${results.length} 成功)`,
                details: results,
                workflow: workflowName,
                config: workflowConfig,
                timestamp: new Date().toISOString()
            };

        } catch (error) {
            return this.createErrorResult(`工作流执行异常: ${error.message}`);
        }
    }

    /**
     * 解析工作流配置
     * @param {string} workflowName - 工作流名称
     * @returns {Promise<Object|null>} 工作流配置
     */
    async parseWorkflowConfig(workflowName) {
        // 1. 尝试从映射配置中查找
        const mappingsDir = path.join(this.cursorDir, 'commands', 'capability-maps');
        const workflowMappings = ['code.json', 'project.json', 'system.json', 'testing.json', 'deployment.json', 'learning.json'];

        for (const mappingFile of workflowMappings) {
            const mappingPath = path.join(mappingsDir, 'mappings', mappingFile);
            if (fs.existsSync(mappingPath)) {
                const mappingConfig = JSON.parse(fs.readFileSync(mappingPath, 'utf8'));
                if (mappingConfig[workflowName]) {
                    return mappingConfig[workflowName];
                }
            }
        }

        // 2. 尝试从规则目录查找
        const workflowRulePath = this.resourceDiscovery.findWorkflow(workflowName);
        if (workflowRulePath) {
            return {
                name: workflowName,
                type: 'rule_based',
                steps: ['rules'],
                targetRule: path.basename(workflowRulePath, '.md')
            };
        }

        // 3. 尝试从脚本目录查找
        const workflowScriptPath = this.resourceDiscovery.findWorkflow(workflowName);
        if (workflowScriptPath) {
            return {
                name: workflowName,
                type: 'script_based',
                steps: ['scripts'],
                targetScript: workflowScriptPath
            };
        }

        // 4. 如果都没有找到，创建默认的复合工作流配置
        return this.createDefaultWorkflowConfig(workflowName);
    }

    /**
     * 创建默认工作流配置
     * @param {string} workflowName - 工作流名称
     * @returns {Object} 默认配置
     */
    createDefaultWorkflowConfig(workflowName) {
        // 基于工作流名称推断步骤
        const workflowSteps = {
            'lint': ['rules', 'scripts', 'hooks'],
            'audit': ['rules', 'scripts', 'workflows'],
            'report': ['scripts', 'workflows'],
            'code-analysis': ['scripts', 'rules'],
            'dependency-analysis': ['scripts', 'rules'],
            'performance-analysis': ['scripts', 'rules'],
            'project-init': ['scripts', 'rules'],
            'dependency-install': ['scripts'],
            'config-setup': ['scripts', 'rules']
        };

        return {
            name: workflowName,
            type: 'composite',
            steps: workflowSteps[workflowName] || ['scripts', 'rules'],
            description: `复合工作流: ${workflowName}`,
            auto_generated: true
        };
    }

    /**
     * 执行工作流步骤
     * @param {string} step - 步骤名称
     * @param {Object} workflowConfig - 工作流配置
     * @param {Object} params - 参数
     * @returns {Promise<Array>} 步骤执行结果
     */
    async executeWorkflowStep(step, workflowConfig, params) {
        const results = [];

        try {
            switch (step) {
                case 'rules':
                    if (workflowConfig.targetRule) {
                        const result = await this.executeRule(workflowConfig.targetRule);
                        results.push({ step, type: 'rule', target: workflowConfig.targetRule, result });
                    } else {
                        // 执行默认规则
                        const result = await this.executeRule('conversation_intent_analyzer');
                        results.push({ step, type: 'rule', target: 'conversation_intent_analyzer', result });
                    }
                    break;

                case 'scripts':
                    if (workflowConfig.targetScript) {
                        const result = await this.executeScript(workflowConfig.targetScript, params);
                        results.push({ step, type: 'script', target: workflowConfig.targetScript, result });
                    } else if (workflowConfig.capabilities?.scripts) {
                        for (const script of workflowConfig.capabilities.scripts) {
                            const result = await this.executeScript(script, params);
                            results.push({ step, type: 'script', target: script, result });
                        }
                    } else {
                        // 执行默认脚本
                        const result = await this.executeScript('core/env-perception.sh', params);
                        results.push({ step, type: 'script', target: 'core/env-perception.sh', result });
                    }
                    break;

                case 'skills':
                    if (workflowConfig.capabilities?.skills) {
                        for (const skill of workflowConfig.capabilities.skills) {
                            const result = await this.executeSkill(skill, params);
                            results.push({ step, type: 'skill', target: skill, result });
                        }
                    }
                    break;

                case 'hooks':
                    if (workflowConfig.capabilities?.hooks) {
                        for (const hook of workflowConfig.capabilities.hooks) {
                            const result = await this.executeHook(hook, params);
                            results.push({ step, type: 'hook', target: hook, result });
                        }
                    } else {
                        // 执行相关钩子
                        const hookNames = this.inferWorkflowHooks(step);
                        for (const hookName of hookNames) {
                            const result = await this.executeHook(hookName, params);
                            results.push({ step, type: 'hook', target: hookName, result });
                        }
                    }
                    break;

                case 'workflows':
                    // 递归执行子工作流
                    if (workflowConfig.capabilities?.workflows) {
                        for (const subWorkflow of workflowConfig.capabilities.workflows) {
                            if (subWorkflow !== workflowConfig.name) { // 避免无限递归
                                const result = await this.executeWorkflow(subWorkflow, params);
                                results.push({ step, type: 'workflow', target: subWorkflow, result });
                            }
                        }
                    }
                    break;

                default:
                    console.log(`ℹ️ 跳过未知工作流步骤: ${step}`);
            }

        } catch (error) {
            console.error(`❌ 工作流步骤执行异常: ${step}`, error);
            results.push({
                step,
                type: 'error',
                target: step,
                result: { success: false, error: error.message }
            });
        }

        return results;
    }

    /**
     * 推断工作流相关的钩子
     * @param {string} workflowStep - 工作流步骤
     * @returns {string[]} 钩子名称数组
     */
    inferWorkflowHooks(workflowStep) {
        const hookMappings = {
            'lint': ['code-quality.sh', 'consistency-check.sh'],
            'audit': ['security-audit.sh', 'dependency-check.sh'],
            'report': ['performance-monitor.sh'],
            'code-analysis': ['architecture-check.sh'],
            'dependency-analysis': ['dependency-check.sh'],
            'performance-analysis': ['performance-monitor.sh'],
            'project-init': ['env-perception.sh', 'role-activation.sh'],
            'dependency-install': ['dependency-check.sh'],
            'config-setup': ['config-validator.sh']
        };

        return hookMappings[workflowStep] || [];
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

    /**
     * 处理学习系统状态查询意图
     * @param {Object} parameters - 参数对象
     * @returns {Promise<Object>} 处理结果
     */
    async handleLearningStatusIntent(parameters) {
        console.log('🎓 处理学习系统状态查询意图...');

        try {
            // 调用学习系统状态查询脚本
            const result = await this.executeScript('agent-orchestration-learning-system.sh', { args: ['get_learning_system_status'] });

            if (result.success) {
                const status = JSON.parse(result.output);
                return {
                    success: true,
                    message: '学习系统状态查询成功',
                    data: {
                        learning_status: status,
                        summary: this.formatLearningStatusSummary(status)
                    }
                };
            } else {
                return {
                    success: false,
                    message: `学习系统状态查询失败: ${result.message}`,
                    error: result.message
                };
            }
        } catch (error) {
            return {
                success: false,
                message: `学习系统状态查询异常: ${error.message}`,
                error: error.message
            };
        }
    }

    /**
     * 格式化学习系统状态摘要
     * @param {Object} status - 学习系统状态
     * @returns {string} 格式化的摘要
     */
    formatLearningStatusSummary(status) {
        let summary = '## 🎓 自适应学习系统状态\n\n';

        if (status.learning_system) {
            const system = status.learning_system;

            summary += `### 📊 系统概览\n`;
            summary += `- **状态**: ${system.status === 'active' ? '✅ 活跃' : '⚠️ 异常'}\n`;
            summary += `- **功能**: ${system.features ? system.features.length : 0} 个核心功能\n`;

            if (system.user_profiles) {
                summary += `\n### 👤 用户画像\n`;
                summary += `- **总交互次数**: ${system.user_profiles.total_interactions || 0}\n`;
                summary += `- **满意度评分**: ${(system.user_profiles.satisfaction_score * 100 || 0).toFixed(1)}%\n`;

                if (system.user_profiles.mode_usage) {
                    summary += `- **直接模式**: ${system.user_profiles.mode_usage.direct?.percentage || 0}%\n`;
                    summary += `- **智能模式**: ${system.user_profiles.mode_usage.intelligent?.percentage || 0}%\n`;
                }
            }

            if (system.recent_switches) {
                summary += `\n### 🔄 模式切换统计\n`;
                summary += `- **统计周期**: ${system.recent_switches.period_days || 7} 天\n`;
                summary += `- **总切换次数**: ${system.recent_switches.total_switches || 0}\n`;
                summary += `- **直接→智能**: ${system.recent_switches.switch_types?.direct_to_intelligent || 0}\n`;
                summary += `- **智能→直接**: ${system.recent_switches.switch_types?.intelligent_to_direct || 0}\n`;
            }
        }

        summary += `\n### 💡 学习成果\n`;
        summary += `- 系统根据您的使用习惯自动调整执行策略\n`;
        summary += `- 简单任务优先选择直接模式，提高效率\n`;
        summary += `- 复杂任务自动启用智能模式，确保质量\n`;

        return summary;
    }

    /**
     * 检查是否是token验证请求
     * @param {string} input - 输入文本
     * @returns {boolean} 是否是token验证请求
     */
    isTokenVerificationRequest(input) {
        const tokenKeywords = ['token', '令牌', '节省', '优化', '压缩', '验证', '测试', '检查'];
        const verificationIndicators = ['有用吗', '效果如何', '是否有效', 'verify', 'test', 'check'];

        const lowerInput = input.toLowerCase();
        const hasTokenKeyword = tokenKeywords.some(keyword => lowerInput.includes(keyword));
        const hasVerificationIndicator = verificationIndicators.some(indicator => lowerInput.includes(indicator));

        return hasTokenKeyword && hasVerificationIndicator;
    }

    /**
     * 处理token验证请求
     * @param {string} input - 输入文本
     * @param {Object} parameters - 参数
     * @returns {Promise<Object>} 处理结果
     */
    async handleTokenVerification(input, parameters) {
        console.log('🔍 开始token优化验证...');

        try {
            // 1. 获取token监控统计
            const tokenStats = await this.getTokenOptimizationStats();

            // 2. 进行实际的压缩测试
            const compressionTest = await this.performCompressionTest();

            // 3. 生成验证报告
            const verificationReport = this.generateTokenVerificationReport(tokenStats, compressionTest);

            // 4. 提供优化建议
            const optimizationSuggestions = this.generateTokenOptimizationSuggestions(tokenStats, compressionTest);

            return this.createSuccessResult('Token优化验证完成', {
                verificationReport,
                optimizationSuggestions,
                tokenStats,
                compressionTest
            });

        } catch (error) {
            console.error('❌ Token验证失败:', error);
            return this.createErrorResult(`Token验证过程出错: ${error.message}`);
        }
    }

    /**
     * 获取token优化统计
     * @returns {Promise<Object>} token统计数据
     */
    async getTokenOptimizationStats() {
        try {
            // 从响应拦截器获取token统计
            if (this.responseInterceptor && typeof this.responseInterceptor.getTokenUsageStats === 'function') {
                const stats = this.responseInterceptor.getTokenUsageStats();
                return stats || {
                    totalTokens: 0,
                    averageTokens: 0,
                    peakUsage: 0,
                    totalRequests: 0
                };
            }

            // 如果没有拦截器，返回默认统计
            return {
                totalTokens: 0,
                averageTokens: 0,
                peakUsage: 0,
                totalRequests: 0,
                note: 'Token监控系统未激活'
            };
        } catch (error) {
            console.warn('获取token统计失败:', error.message);
            return {
                totalTokens: 0,
                averageTokens: 0,
                peakUsage: 0,
                totalRequests: 0,
                error: error.message
            };
        }
    }

    /**
     * 执行压缩测试
     * @returns {Promise<Object>} 压缩测试结果
     */
    async performCompressionTest() {
        const testData = {
            // 模拟一个典型的响应数据
            response: {
                status: "success",
                message: "操作已完成",
                data: {
                    environment_analysis: {
                        project_type: "web_application",
                        tech_stack: ["React", "Node.js", "PostgreSQL"],
                        team_size: "small_team",
                        confidence: 0.85
                    },
                    intent_analysis: {
                        primary_intent: "code_optimization",
                        confidence_threshold: 0.8,
                        execution_plan: {
                            steps: ["analyze", "optimize", "test", "deploy"],
                            estimated_time: "2_hours"
                        }
                    },
                    recommendations: [
                        "使用React Hooks优化组件性能",
                        "实现代码分割减少初始加载时间",
                        "添加错误边界提升用户体验",
                        "配置CI/CD流水线自动化部署"
                    ]
                },
                timestamp: new Date().toISOString(),
                processing_time_ms: 1250
            }
        };

        const originalJson = JSON.stringify(testData, null, 2);
        const originalTokens = this.estimateTokens(originalJson);

        // 测试不同的压缩级别
        const compressionLevels = ['minimal', 'balanced', 'aggressive'];
        const compressionResults = {};

        for (const level of compressionLevels) {
            try {
                const compressed = await this.applyCompression(originalJson, level);
                const compressedTokens = this.estimateTokens(compressed);
                const savings = originalTokens - compressedTokens;
                const ratio = originalTokens > 0 ? (savings / originalTokens * 100).toFixed(2) : 0;

                compressionResults[level] = {
                    originalTokens,
                    compressedTokens,
                    tokenSavings: savings,
                    compressionRatio: ratio + '%',
                    effectiveness: this.evaluateCompressionEffectiveness(savings, originalTokens)
                };
            } catch (error) {
                compressionResults[level] = {
                    error: error.message,
                    originalTokens
                };
            }
        }

        return {
            originalData: originalJson,
            originalTokens,
            compressionResults
        };
    }

    /**
     * 应用压缩
     * @param {string} data - 要压缩的数据
     * @param {string} level - 压缩级别
     * @returns {Promise<string>} 压缩后的数据
     */
    async applyCompression(data, level) {
        // 这里调用实际的压缩逻辑
        try {
            // 模拟压缩过程 - 在实际系统中会调用token-compression.sh
            let compressed = data;

            switch (level) {
                case 'minimal':
                    // 移除emoji和装饰字符
                    compressed = compressed.replace(/[🎯✨🚀💡📚🎭🔧⚡🎨🏗️📁✅❌⚠️🔄📊🎉😊💕🎀🌟💎🧹]/g, '');
                    // 压缩换行符
                    compressed = compressed.replace(/\n\n\n+/g, '\n\n');
                    break;

                case 'balanced':
                    // minimal + 重复字符串压缩
                    compressed = compressed.replace(/[🎯✨🚀💡📚🎭🔧⚡🎨🏗️📁✅❌⚠️🔄📊🎉😊💕🎀🌟💎🧹]/g, '');
                    compressed = compressed.replace(/\n\n\n+/g, '\n\n');
                    // 简单的重复字符串检测和替换
                    compressed = compressed.replace(/"success"/g, '"OK"');
                    compressed = compressed.replace(/"error"/g, '"ERR"');
                    break;

                case 'aggressive':
                    // balanced + 语义压缩
                    compressed = compressed.replace(/[🎯✨🚀💡📚🎭🔧⚡🎨🏗️📁✅❌⚠️🔄📊🎉😊💕🎀🌟💎🧹]/g, '');
                    compressed = compressed.replace(/\n\n\n+/g, '\n\n');
                    compressed = compressed.replace(/"success"/g, '"OK"');
                    compressed = compressed.replace(/"error"/g, '"ERR"');
                    // 语义压缩
                    compressed = compressed.replace(/"React"/g, '"REACT"');
                    compressed = compressed.replace(/"Node\.js"/g, '"NODE"');
                    compressed = compressed.replace(/"PostgreSQL"/g, '"PGSQL"');
                    break;
            }

            return compressed;
        } catch (error) {
            console.warn(`压缩级别 ${level} 失败:`, error.message);
            return data; // 返回原始数据
        }
    }

    /**
     * 估算token数量
     * @param {string} text - 文本内容
     * @returns {number} 估算的token数量
     */
    estimateTokens(text) {
        if (!text) return 0;

        // 粗略估算：中文约1.5个字符=1个token，英文约4个字符=1个token
        const chineseChars = (text.match(/[\u4e00-\u9fff]/g) || []).length;
        const englishChars = text.length - chineseChars;

        // 中文字符按1.5个token计算，英文按4个字符=1个token计算
        return Math.round(chineseChars * 0.67 + englishChars * 0.25);
    }

    /**
     * 评估压缩效果
     * @param {number} savings - 节省的token数量
     * @param {number} original - 原始token数量
     * @returns {string} 效果评估
     */
    evaluateCompressionEffectiveness(savings, original) {
        if (original === 0) return 'neutral';

        const ratio = savings / original;
        if (ratio >= 0.7) return 'excellent';
        if (ratio >= 0.5) return 'good';
        if (ratio >= 0.3) return 'fair';
        if (ratio >= 0.1) return 'poor';
        return 'minimal';
    }

    /**
     * 生成token验证报告
     * @param {Object} stats - token统计
     * @param {Object} compressionTest - 压缩测试结果
     * @returns {Object} 验证报告
     */
    generateTokenVerificationReport(stats, compressionTest) {
        const report = {
            summary: {
                monitoringActive: stats.totalRequests > 0,
                totalTokensUsed: stats.totalTokens || 0,
                averageTokensPerRequest: stats.averageTokens || 0,
                totalRequests: stats.totalRequests || 0,
                compressionTestPerformed: !!compressionTest
            },
            compressionEffectiveness: {},
            recommendations: []
        };

        // 分析压缩测试结果
        if (compressionTest && compressionTest.compressionResults) {
            const results = compressionTest.compressionResults;

            report.compressionEffectiveness = {
                minimal: results.minimal?.compressionRatio || '0%',
                balanced: results.balanced?.compressionRatio || '0%',
                aggressive: results.aggressive?.compressionRatio || '0%'
            };

            // 生成推荐
            if (results.aggressive?.effectiveness === 'excellent' || results.aggressive?.effectiveness === 'good') {
                report.recommendations.push('建议启用激进压缩模式，可节省大量tokens');
            } else if (results.balanced?.effectiveness === 'excellent' || results.balanced?.effectiveness === 'good') {
                report.recommendations.push('建议启用平衡压缩模式，性价比最佳');
            } else if (results.minimal?.effectiveness === 'good' || results.minimal?.effectiveness === 'fair') {
                report.recommendations.push('建议至少启用最小压缩模式');
            }
        }

        // 基于使用统计的推荐
        if (stats.averageTokens > 800) {
            report.recommendations.push('检测到高token使用量，强烈建议启用压缩');
        } else if (stats.averageTokens > 600) {
            report.recommendations.push('token使用量中等，建议根据需要启用压缩');
        }

        return report;
    }

    /**
     * 生成优化建议
     * @param {Object} stats - token统计
     * @param {Object} compressionTest - 压缩测试结果
     * @returns {Array} 优化建议
     */
    generateTokenOptimizationSuggestions(stats, compressionTest) {
        const suggestions = [];

        // 基于统计数据的建议
        if (!stats.totalRequests || stats.totalRequests === 0) {
            suggestions.push({
                type: 'monitoring',
                priority: 'high',
                title: '启用Token监控',
                description: 'Token监控系统未激活，建议启用以跟踪使用情况',
                action: '在系统配置中启用token监控'
            });
        }

        if (stats.averageTokens > 600) {
            suggestions.push({
                type: 'compression',
                priority: 'high',
                title: '启用响应压缩',
                description: `当前平均每请求使用 ${stats.averageTokens} tokens，建议启用压缩`,
                action: '在response-interceptor中启用ultraFast模式'
            });
        }

        // 基于压缩测试的建议
        if (compressionTest && compressionTest.compressionResults) {
            const aggressiveResult = compressionTest.compressionResults.aggressive;
            if (aggressiveResult && aggressiveResult.effectiveness === 'excellent') {
                suggestions.push({
                    type: 'optimization',
                    priority: 'medium',
                    title: '使用激进压缩',
                    description: `激进压缩可节省 ${aggressiveResult.compressionRatio} 的tokens`,
                    action: '设置COMPRESSION_LEVEL=aggressive'
                });
            }
        }

        // 通用建议
        suggestions.push({
            type: 'best_practice',
            priority: 'low',
            title: '定期检查优化效果',
            description: '建议定期运行token验证来检查优化效果',
            action: '使用 "/master 验证token优化" 命令检查效果'
        });

        return suggestions;
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
        },
        {
            input: {
                success: true,
                type: 'natural_language',
                intent: 'creation',
                confidence: 0.9,
                parameters: { input: '创建一个React项目', projectType: 'react' },
                constitution: { compliant: true }
            },
            description: '测试项目创建意图（验证宪法干预已移除）'
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
