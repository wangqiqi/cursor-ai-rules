// Cursor IDE Master Command Handler - 智能升级版
// 集成AI共生宪法系统，充分利用IDE上下文，实现真正的智能协作

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class MasterCommandHandler {
    constructor(projectRoot, context = {}) {
        this.projectRoot = projectRoot || this.findProjectRoot();
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

        // 🚀 性能优化 - 初始化缓存系统
        this.cache = {
            roleConfig: new Map(),
            capabilityMap: new Map(),
            fileContents: new Map(),
            lastCleanup: Date.now(),
            // 🚀 新增：角色快速缓存
            roleNicknames: new Map(),
            roleSwitchCache: new Map()
        };
        this.cacheTTL = 300000; // 5分钟缓存过期时间
        this.maxCacheSize = 100; // 最大缓存条目数

        // 🚀 集成我们的智能系统 - 延迟初始化
        this.intelligentSystem = null;

        // 🎭 角色管理系统 - 延迟初始化
        this.roleManager = null;

        // 🛡️ 响应输出拦截器 - 延迟初始化
        this.responseInterceptor = null;

        // 🚀 异步初始化标志
        this.initialized = false;

        // 🏗️ 组件管理器 - 实现架构解耦
        this.componentManager = null;

        // 🚀 新增：快速模式标志 - 用于角色呼召
        this.fastMode = false;
        this.fastModeRoleManager = null;
    }

    /**
     * 🚀 异步初始化所有组件 - 提升响应速度
     */
    async initialize() {
        if (this.initialized) {
            return; // 已经初始化过了
        }

        console.log('🚀 开始异步初始化Master Command Handler...');

        try {
            // 🚀 延迟初始化策略 - 只在需要时初始化
            this.lazyInitComponents = new Map();

            // 🏗️ 快速初始化组件管理器（同步）
            this.initializeComponentManagerSync();

            // 🚀 标记为初始化完成，但实际组件延迟加载
            this.initialized = true;
            console.log('✅ Master Command Handler快速初始化完成');

        } catch (error) {
            console.warn('⚠️ 初始化过程中出现错误，但系统将继续运行:', error.message);
            // 不设置initialized标志，让系统在下次调用时重试初始化
        }
    }

    /**
     * 🚀 同步初始化组件管理器 - 提升启动速度
     */
    initializeComponentManagerSync() {
        try {
            const ComponentManager = require('./component-manager');
            this.componentManager = new ComponentManager(this.projectRoot);

            // 设置组件管理器的事件监听
            this.componentManager.on('healthChanged', (data) => {
                console.log(`🏥 组件健康状态变更: ${data.name} -> ${data.state}`);
                if (data.error) {
                    console.warn(`   错误: ${data.error}`);
                }
            });

            console.log('✅ 组件管理器同步初始化成功');
        } catch (error) {
            console.error('❌ 组件管理器同步初始化失败:', error.message);
            throw error;
        }
    }

    /**
     * 🚀 延迟初始化核心组件 - 只在首次需要时加载
     */
    async lazyInitializeCoreComponents() {
        if (this.coreComponentsInitialized) {
            return;
        }

        console.log('🏗️ 延迟初始化核心组件...');

        try {
            // 获取核心组件实例（延迟加载）
            this.intelligentSystem = await this.componentManager.getComponent('router');
            this.roleManager = await this.componentManager.getComponent('roleManager');
            this.responseInterceptor = await this.componentManager.getComponent('responseInterceptor');

            // 初始化服务发现
            await this.initializeServiceDiscovery();

            this.coreComponentsInitialized = true;
            console.log('✅ 核心组件延迟初始化完成');

        } catch (error) {
            console.error('❌ 核心组件延迟初始化失败:', error.message);
            // 尝试降级模式
            await this.createFallbackComponents();
        }
    }

    /**
     * 🚀 快速初始化角色管理器 - 专门用于角色呼召
     */
    async fastInitializeRoleManager() {
        if (this.fastModeRoleManager) {
            return this.fastModeRoleManager;
        }

        try {
            console.log('🚀 快速初始化角色管理器...');

            const RoleManager = require('./role-manager');
            this.fastModeRoleManager = new RoleManager(this.cursorDir);
            await this.fastModeRoleManager.initialize();

            // 预构建昵称索引
            this.buildFastNicknameCache();

            console.log('✅ 快速角色管理器初始化完成');
            return this.fastModeRoleManager;
        } catch (error) {
            console.error('❌ 快速角色管理器初始化失败:', error.message);
            throw error;
        }
    }

    /**
     * 🚀 构建快速昵称缓存
     */
    buildFastNicknameCache() {
        if (!this.fastModeRoleManager) return;

        const roles = this.fastModeRoleManager.getAvailableRoles();
        if (!roles.success) return;

        this.cache.roleNicknames.clear();

        for (const role of roles.roles) {
            try {
                const roleConfig = this.fastModeRoleManager.personalitySystem.roles[role.id];

                // 收集昵称
                const nicknames = new Set();

                // 检查personality_traits中的nickname字段
                if (roleConfig.personality_traits?.nickname) {
                    if (Array.isArray(roleConfig.personality_traits.nickname)) {
                        roleConfig.personality_traits.nickname.forEach(nick => nicknames.add(nick));
                    } else if (typeof roleConfig.personality_traits.nickname === 'string') {
                        nicknames.add(roleConfig.personality_traits.nickname);
                    }
                }

                // 缓存昵称到角色ID的映射
                nicknames.forEach(nickname => {
                    this.cache.roleNicknames.set(nickname.toLowerCase(), role.id);
                });

                // 同时缓存角色名
                this.cache.roleNicknames.set(role.name.toLowerCase(), role.id);

            } catch (error) {
                console.warn(`⚠️ 构建昵称缓存失败 ${role.id}:`, error.message);
            }
        }

        console.log(`✅ 快速昵称缓存构建完成: ${this.cache.roleNicknames.size} 个条目`);
    }

    /**
     * 🏗️ 初始化组件管理器
     */
    async initializeComponentManager() {
        try {
            const ComponentManager = require('./component-manager');
            this.componentManager = new ComponentManager(this.projectRoot);

            // 设置组件管理器的事件监听
            this.componentManager.on('healthChanged', (data) => {
                console.log(`🏥 组件健康状态变更: ${data.name} -> ${data.state}`);
                if (data.error) {
                    console.warn(`   错误: ${data.error}`);
                }
            });

            console.log('✅ 组件管理器初始化成功');
        } catch (error) {
            console.error('❌ 组件管理器初始化失败:', error.message);
            throw error;
        }
    }

    /**
     * 🏗️ 初始化核心组件（通过组件管理器）
     */
    async initializeCoreComponents() {
        if (!this.componentManager) {
            throw new Error('组件管理器未初始化');
        }

        try {
            // 获取核心组件实例
            this.intelligentSystem = await this.componentManager.getComponent('router');
            this.roleManager = await this.componentManager.getComponent('roleManager');
            this.responseInterceptor = await this.componentManager.getComponent('responseInterceptor');

            console.log('✅ 核心组件初始化完成');

            // 🔗 初始化服务发现
            await this.initializeServiceDiscovery();
        } catch (error) {
            console.error('❌ 核心组件初始化失败:', error.message);
            // 尝试降级模式
            await this.createFallbackComponents();
        }
    }

    /**
     * 🔗 初始化服务发现
     */
    async initializeServiceDiscovery() {
        console.log('🔗 初始化服务发现...');

        try {
            // 逐个获取服务，允许部分失败
            const services = {};

            // 尝试获取各个服务，如果失败则使用降级值
            try {
                services.parser = await this.componentManager.getService('intent-parser');
            } catch (e) {
                console.warn('⚠️ intent-parser 服务不可用，使用降级模式');
                services.parser = this.intelligentSystem || null;
            }

            try {
                services.router = await this.componentManager.getService('command-router');
            } catch (e) {
                console.warn('⚠️ command-router 服务不可用，使用降级模式');
                services.router = this.intelligentSystem || null;
            }

            try {
                services.executor = await this.componentManager.getService('command-executor');
            } catch (e) {
                console.warn('⚠️ command-executor 服务不可用，使用降级模式');
                services.executor = null;
            }

            try {
                services.roleManager = await this.componentManager.getService('role-management');
            } catch (e) {
                console.warn('⚠️ role-management 服务不可用，使用直接访问');
                services.roleManager = this.roleManager;
            }

            try {
                services.responseInterceptor = await this.componentManager.getService('response-filter');
            } catch (e) {
                console.warn('⚠️ response-filter 服务不可用，使用直接访问');
                services.responseInterceptor = this.responseInterceptor;
            }

            this.services = services;
            console.log('✅ 服务发现初始化成功');
        } catch (error) {
            console.error('❌ 服务发现初始化完全失败:', error.message);
            // 完全降级到直接组件访问
            this.services = {
                parser: this.intelligentSystem,
                router: this.intelligentSystem,
                executor: null,
                roleManager: this.roleManager,
                responseInterceptor: this.responseInterceptor
            };
        }
    }

    /**
     * 🛡️ 创建降级组件（当组件管理器失败时）
     */
    async createFallbackComponents() {
        console.log('🛡️ 启用组件降级模式...');

        // 降级初始化原有组件
        await this.initializeIntelligentSystem();
        await this.initializeRoleManager();
        await this.initializeResponseInterceptor();
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
            // 检查缓存中是否有角色配置
            const cacheKey = 'role_manager_config';
            const cached = this.cache.roleConfig.get(cacheKey);

            if (cached && (Date.now() - cached.timestamp) < this.cacheTTL) {
                console.log('🎭 使用缓存的角色配置');
                this.roleManager = cached.roleManager;
                return;
            }

            const RoleManager = require('./role-manager');
            this.roleManager = new RoleManager(this.cursorDir, this.projectRoot);
            await this.roleManager.initialize();

            // 缓存角色管理器
            this.cache.roleConfig.set(cacheKey, {
                roleManager: this.roleManager,
                timestamp: Date.now()
            });

            console.log('🎭 角色管理器初始化成功');
        } catch (error) {
            console.warn('⚠️ 角色管理器初始化失败，启用降级模式:', error.message);

            // 🛠️ 使用统一错误处理记录问题
            this.handleError(error, 'role_initialization', { component: 'role_manager' });

            // 🛡️ 创建健壮的降级系统
            await this.createFallbackRoleManager();
        }
    }

    /**
     * 🛡️ 创建降级角色管理器 - 当主系统失败时的备用方案
     */
    async createFallbackRoleManager() {
        try {
            // 尝试读取项目配置
            const projectRole = this.loadProjectRoleConfig();

            // 默认角色配置
            const fallbackConfig = {
                professional_assistant: {
                    name: "专业助手",
                    description: "标准专业AI助手（降级模式）",
                    attitude: "professional",
                    tone: "formal",
                    language_style: "concise"
                },
                maid: {
                    name: "完美女仆",
                    description: "忠诚的女仆助手（降级模式）",
                    attitude: "submissive",
                    tone: "gentle",
                    language_style: "polite"
                }
            };

            const roleId = projectRole || 'professional_assistant';
            const roleConfig = fallbackConfig[roleId] || fallbackConfig.professional_assistant;

            this.roleManager = {
                currentRole: roleId,
                fallbackMode: true, // 标记为降级模式

                selectWelcomeTemplate: (result, context) => this.generateFallbackWelcomeTemplate(result, context, roleConfig),

                getCurrentRole: () => ({
                    success: true,
                    role: {
                        id: roleId,
                        name: roleConfig.name,
                        fallback: true
                    },
                    message: '当前使用降级角色系统'
                }),

                getAvailableRoles: () => ({
                    success: true,
                    roles: Object.entries(fallbackConfig).map(([id, config]) => ({
                        id: id,
                        name: config.name,
                        description: config.description + '（降级模式）'
                    })),
                    currentRole: roleId,
                    fallback: true
                }),

                switchRole: async (newRoleId) => {
                    if (fallbackConfig[newRoleId]) {
                        this.roleManager.currentRole = newRoleId;
                        return {
                            success: true,
                            message: `降级模式下切换到角色: ${fallbackConfig[newRoleId].name}`,
                            newRole: newRoleId
                        };
                    }
                    return {
                        success: false,
                        message: '降级模式不支持此角色切换'
                    };
                }
            };

            console.log(`🛡️ 降级角色系统已激活: ${roleConfig.name}`);

        } catch (fallbackError) {
            console.error('❌ 降级角色系统创建失败:', fallbackError.message);

            // 最后的最后手段 - 创建最基本的备用系统
            this.roleManager = {
                currentRole: 'basic_assistant',
                fallbackMode: true,
                emergencyMode: true,

                selectWelcomeTemplate: () => "系统运行在紧急模式下，功能受限：\n\n{content}",

                getCurrentRole: () => ({
                    success: true,
                    role: { id: 'basic_assistant', name: '基础助手', emergency: true }
                }),

                getAvailableRoles: () => ({
                    success: true,
                    roles: [{ id: 'basic_assistant', name: '基础助手（紧急模式）' }],
                    currentRole: 'basic_assistant'
                }),

                switchRole: () => ({ success: false, message: '紧急模式不支持角色切换' })
            };

            console.log('🚨 紧急降级系统已激活，功能严重受限');
        }
    }

    /**
     * 🛡️ 生成降级模式的欢迎模板
     */
    generateFallbackWelcomeTemplate(result, context, roleConfig) {
        const templates = {
            general: `${roleConfig.name}（降级模式）为您服务：\n\n{content}`,
            success: `✅ 任务完成！${roleConfig.name}（降级模式）\n\n{content}`,
            error: `⚠️ 遇到问题，${roleConfig.name}（降级模式）正在处理：\n\n{content}`,
            learning: `📚 ${roleConfig.name}（降级模式）为您讲解：\n\n{content}`,
            code: `💻 ${roleConfig.name}（降级模式）为您优化代码：\n\n{content}`,
            project: `🏗️ ${roleConfig.name}（降级模式）协助项目开发：\n\n{content}`
        };

        // 根据上下文选择模板
        if (result.success === false) {
            return templates.error;
        }

        if (context && context.intent) {
            switch (context.intent) {
                case 'learning':
                    return templates.learning;
                case 'code':
                    return templates.code;
                case 'project':
                case 'creation':
                    return templates.project;
                default:
                    return templates.success;
            }
        }

        return templates.general;
    }

    /**
     * 初始化响应拦截器
     */
    async initializeResponseInterceptor() {
        try {
            // 等待角色管理器初始化完成
            if (this.roleManager && typeof this.roleManager.initialize === 'function') {
                await this.roleManager.initialize();
            }

            const ResponseInterceptor = require('../core/response-interceptor');
            this.responseInterceptor = new ResponseInterceptor(this.roleManager, {
                ultraFast: true, // 启用超快速模式，完全跳过处理
                strictMode: false, // 降低严格模式以提高速度
                autoCorrect: false, // 关闭自动修正
                logViolations: false, // 关闭日志记录以提高性能
                fastMode: false, // 快速模式已由ultraFast替代
                cacheEnabled: true // 启用缓存
            });

            console.log('🛡️ 响应拦截器初始化成功');
        } catch (error) {
            console.warn('⚠️ 响应拦截器初始化失败:', error.message);
            this.responseInterceptor = null;
        }
    }

    // 删除getDefaultPersonalitySystem方法，现在由RoleManager处理

    /**
     * 加载项目角色配置
     */
    loadProjectRoleConfig() {
        try {
            const configPath = path.join(this.projectRoot, '.cursor-project.json');
            if (fs.existsSync(configPath)) {
                const content = fs.readFileSync(configPath, 'utf8');
                const config = JSON.parse(content);

                if (config.currentRole) {
                    console.log(`✅ 读取项目角色配置: ${config.currentRole}`);
                    return config.currentRole;
                }
            }
        } catch (error) {
            console.warn('⚠️ 读取项目角色配置失败:', error.message);
        }
        return null;
    }

    /**
     * 根据能力确定意图类型
     */
    determineIntentFromCapability(capability, input) {
        // 根据能力映射到意图
        switch (capability) {
            case 'learning':
            case 'study':
            case 'teach':
                return 'learning';
            case 'code':
            case 'programming':
            case 'debug':
            case 'optimize':
                return 'code';
            case 'project':
            case 'create':
            case 'scaffold':
            case 'initialize':
                return 'project';
            case 'git':
            case 'deploy':
            case 'build':
                return 'system';
            default:
                // 从输入内容分析意图
                const inputLower = input.toLowerCase();
                if (inputLower.includes('学习') || inputLower.includes('学习') ||
                    inputLower.includes('教') || inputLower.includes('study') ||
                    inputLower.includes('learn')) {
                    return 'learning';
                }
                if (inputLower.includes('代码') || inputLower.includes('编程') ||
                    inputLower.includes('debug') || inputLower.includes('修复') ||
                    inputLower.includes('优化')) {
                    return 'code';
                }
                if (inputLower.includes('项目') || inputLower.includes('创建') ||
                    inputLower.includes('初始化') || inputLower.includes('搭建')) {
                    return 'project';
                }
                return 'general';
        }
    }

    /**
     * 确保项目角色配置存在并激活
     */
    async ensureProjectRoleConfig() {
        try {
            const projectConfigPath = path.join(this.projectRoot, '.cursor-project.json');

            // 检查项目配置文件是否存在
            if (!fs.existsSync(projectConfigPath)) {
                // 创建默认的项目配置文件
                const defaultConfig = {
                    currentRole: 'professional_assistant',
                    lastUpdated: new Date().toISOString(),
                    projectPath: this.projectRoot
                };

                fs.writeFileSync(projectConfigPath, JSON.stringify(defaultConfig, null, 2), 'utf8');
                console.log('✅ 创建默认项目角色配置: professional_assistant');
            }

            // 读取项目配置
            const configContent = fs.readFileSync(projectConfigPath, 'utf8');
            const config = JSON.parse(configContent);
            const targetRole = config.currentRole || 'professional_assistant';

            console.log(`🎭 项目角色配置: ${targetRole}`);

            // 激活项目角色
            if (this.roleManager && this.roleManager.currentRole !== targetRole) {
                const result = await this.roleManager.switchRole(targetRole, 'project_config');
                if (result.success) {
                    console.log(`✅ 项目角色激活成功: ${targetRole}`);
                } else {
                    console.log(`⚠️ 项目角色激活失败: ${result.message}`);
                }
            } else if (this.roleManager) {
                console.log(`✅ 项目角色已激活: ${targetRole}`);
            }

        } catch (error) {
            console.log(`⚠️ 项目角色配置处理出错: ${error.message}`);
        }
    }

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
     * 强制执行系统命令 - 防止AI助手绕过系统功能
     */
    async forceSystemCommandExecution(input) {
        // 强制执行命令映射 - 这些命令的意图识别必须是100%确定的，不能被AI助手覆盖
        // 确定性指令：意图明确，执行确定，不需要AI判断
        const forceCommands = {
            // 🎭 角色管理系统 - 确定性指令
            '列出角色': async () => await this.getAvailableRoles(),
            '当前角色': async () => {
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
            },
            '切换角色': async (roleId) => {
                if (roleId) {
                    return await this.switchRole(roleId);
                }
                return { success: false, message: '请指定要切换的角色ID' };
            },
            '设置角色': async (roleId) => {
                if (roleId) {
                    return await this.switchRole(roleId);
                }
                return { success: false, message: '请指定要设置的角色ID' };
            },
            '呼叫角色': async (roleId) => {
                if (roleId) {
                    const result = await this.switchRole(roleId);
                    // 为呼叫命令添加特殊的欢迎消息
                    if (result.success) {
                        const enhancedMessage = `角色前来应答！\n\n${result.message}`;
                        return {
                            ...result,
                            message: enhancedMessage
                        };
                    }
                    return result;
                }
                return { success: false, message: '请指定要呼叫的角色ID' };
            },
            '设置昵称': async (params) => {
                const match = params.match(/^(.+)设置昵称\s+(.+)$/);
                if (match) {
                    return await this.setRoleNickname(match[1].trim(), match[2].trim(), 'set');
                }
                return { success: false, message: '请使用格式: 设置昵称 [角色名] [昵称]' };
            },
            '添加昵称': async (params) => {
                const match = params.match(/^(.+)添加昵称\s+(.+)$/);
                if (match) {
                    return await this.setRoleNickname(match[1].trim(), match[2].trim(), 'add');
                }
                return { success: false, message: '请使用格式: 添加昵称 [角色名] [昵称]' };
            },
            '查看昵称': async () => {
                return this.viewAllNicknames();
            },
            '重置昵称': async (roleName) => {
                if (roleName) {
                    return await this.resetRoleNickname(roleName);
                }
                return { success: false, message: '请指定要重置昵称的角色' };
            },
            '重置角色': async () => {
                const result = await this.switchRole('professional_assistant', 'forced_reset');
                if (result.success && this.roleManager?.clearProjectRoleConfig) {
                    await this.roleManager.clearProjectRoleConfig();
                }
                return result;
            },

            // 🔧 直接系统调用 - 确定性指令
            'rule': async (ruleName) => {
                if (ruleName) {
                    return await this.executeRule(ruleName);
                }
                return { success: false, message: '请指定规则名称' };
            },
            'script': async (scriptName) => {
                if (scriptName) {
                    return await this.executeScript(scriptName);
                }
                return { success: false, message: '请指定脚本名称' };
            },
            'skill': async (skillName) => {
                if (skillName) {
                    return await this.executeSkill(skillName);
                }
                return { success: false, message: '请指定技能名称' };
            },
            'hook': async (hookName) => {
                if (hookName) {
                    return await this.executeHook(hookName);
                }
                return { success: false, message: '请指定钩子名称' };
            }
        };

        // 检查是否是强制执行命令 (精确匹配和参数提取)
        for (const [command, handler] of Object.entries(forceCommands)) {
            // 检查直接命令匹配
            if (input.includes(command) && !input.includes(' ')) {
                console.log(`🔧 强制执行系统命令: ${command}`);
                return await handler();
            }

            // 检查带参数的命令 (如 "rule constitution", "script init.sh")
            const commandRegex = new RegExp(`^${command}\\s+(.+)$`, 'i');
            const paramMatch = input.match(commandRegex);
            if (paramMatch) {
                const param = paramMatch[1].trim();
                console.log(`🔧 强制执行系统命令: ${command} ${param}`);
                return await handler(param);
            }
        }

        // 检查角色切换命令 (支持多种格式)
        const switchMatch = input.match(/(?:切换|设置|switch|set).*\s+(\w+)/i);
        if (switchMatch) {
            const roleId = switchMatch[1].trim();
            console.log(`🔧 强制执行角色切换: ${roleId}`);
            return await forceCommands['切换角色'](roleId);
        }

        return null; // 不是强制执行命令
    }

    /**
     * 创建角色状态快照 - 用于跨对话框同步
     */
    createRoleStateSnapshot() {
        try {
            if (!this.roleManager) return null;

            // 读取项目配置
            const projectConfigPath = path.join(this.projectRoot, '.cursor-project.json');
            let projectRole = 'professional_assistant'; // 默认值
            if (fs.existsSync(projectConfigPath)) {
                const configContent = fs.readFileSync(projectConfigPath, 'utf8');
                const config = JSON.parse(configContent);
                projectRole = config.currentRole || projectRole;
            }

            const snapshot = {
                projectRole: projectRole,
                activeRole: this.roleManager.currentRole,
                timestamp: new Date().toISOString(),
                sessionId: this.generateSessionId(),
                checksum: null
            };

            // 生成校验和 (只基于角色状态，不包含时间戳和会话ID)
            const checksumData = {
                projectRole: snapshot.projectRole,
                activeRole: snapshot.activeRole
            };
            snapshot.checksum = this.generateChecksum(JSON.stringify(checksumData));

            return snapshot;
        } catch (error) {
            console.warn('⚠️ 创建角色状态快照失败:', error.message);
            return null;
        }
    }

    /**
     * 验证角色状态一致性 - 检测跨对话框状态同步
     */
    validateRoleStateConsistency(snapshot) {
        try {
            if (!snapshot || !this.roleManager) return false;

            const currentRole = this.roleManager.currentRole;
            const projectRole = snapshot.projectRole;

            // 检查角色一致性
            const isConsistent = currentRole === projectRole;

            if (!isConsistent) {
                console.warn(`⚠️ 检测到角色状态不一致: 当前=${currentRole}, 项目=${projectRole}`);
                return false;
            }

            // 验证校验和 (只验证角色状态)
            const currentChecksumData = {
                projectRole: projectRole,
                activeRole: currentRole
            };
            const currentChecksum = this.generateChecksum(JSON.stringify(currentChecksumData));

            if (currentChecksum !== snapshot.checksum) {
                console.warn('⚠️ 角色状态校验和不匹配，可能存在状态污染');
                return false;
            }

            return true;
        } catch (error) {
            console.warn('⚠️ 验证角色状态一致性失败:', error.message);
            return false;
        }
    }

    /**
     * 生成会话ID - 用于跟踪跨对话框状态
     */
    generateSessionId() {
        const timestamp = Date.now().toString(36);
        const random = Math.random().toString(36).substr(2, 9);
        return `session_${timestamp}_${random}`;
    }

    /**
     * 生成校验和 - 用于状态完整性验证
     */
    generateChecksum(data) {
        let hash = 0;
        for (let i = 0; i < data.length; i++) {
            const char = data.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // 转换为32位整数
        }
        return hash.toString(36);
    }

    /**
     * 强制激活项目角色 - 增强角色持续性
     */
    async forceActivateProjectRole() {
        try {
            console.log('🎭 强制激活项目角色配置...');

            // 1. 读取项目配置
            const projectConfigPath = path.join(this.projectRoot, '.cursor-project.json');
            let targetRole = 'professional_assistant'; // 默认角色

            if (fs.existsSync(projectConfigPath)) {
                const configContent = fs.readFileSync(projectConfigPath, 'utf8');
                const config = JSON.parse(configContent);
                targetRole = config.currentRole || targetRole;
                console.log(`✅ 读取项目角色配置: ${targetRole}`);
            } else {
                console.log('⚠️ 项目配置文件不存在，创建默认配置');
                const defaultConfig = {
                    currentRole: targetRole,
                    lastUpdated: new Date().toISOString(),
                    projectPath: this.projectRoot
                };
                fs.writeFileSync(projectConfigPath, JSON.stringify(defaultConfig, null, 2), 'utf8');
            }

            // 2. 确保角色管理器已初始化
            if (!this.roleManager) {
                console.log('⚠️ 角色管理器未初始化，重新初始化...');
                await this.initializeRoleManager();
            }

            // 3. 强制切换到项目角色
            if (this.roleManager.currentRole !== targetRole) {
                console.log(`🔄 强制切换角色: ${this.roleManager.currentRole} → ${targetRole}`);
                const result = await this.roleManager.switchRole(targetRole, 'force_activation');
                if (result.success) {
                    console.log(`✅ 角色强制激活成功: ${targetRole}`);
                } else {
                    console.warn(`⚠️ 角色强制激活失败: ${result.message}`);
                }
            } else {
                console.log(`✅ 项目角色已激活: ${targetRole}`);
            }

            // 4. 验证角色状态
            const currentRoleInfo = this.roleManager.getCurrentRole();
            if (currentRoleInfo.success) {
                console.log(`🎭 当前活跃角色: ${currentRoleInfo.role.name} (${currentRoleInfo.role.id})`);
            }

        } catch (error) {
            console.error('❌ 强制激活项目角色失败:', error.message);
            // 回退到默认角色
            if (this.roleManager) {
                await this.roleManager.switchRole('professional_assistant', 'fallback');
            }
        }
    }

    /**
     * 初始化角色管理器 - 同步版本 (用于wrapWithWelcome)
     */
    initializeRoleManagerSync() {
        try {
            console.log('🎭 同步初始化角色管理器...');

            const RoleManager = require('./role-manager');
            this.roleManager = new RoleManager(this.cursorDir, this.projectRoot);

            // 简化同步初始化（实际项目中可能需要更完整的初始化逻辑）
            this.roleManager.personalitySystem = this.roleManager.getDefaultPersonalitySystem();
            this.roleManager.currentRole = this.roleManager.personalitySystem.default_role;

            console.log('✅ 角色管理器同步初始化完成');

        } catch (error) {
            console.error('❌ 同步初始化角色管理器失败:', error.message);
            this.roleManager = null;
        }
    }

    /**
     * 强制激活项目角色 - 同步版本 (用于wrapWithWelcome)
     */
    forceActivateProjectRoleSync() {
        try {
            console.log('🎭 同步激活项目角色...');

            // 读取项目配置
            const projectConfigPath = path.join(this.projectRoot, '.cursor-project.json');
            let targetRole = 'professional_assistant';

            if (fs.existsSync(projectConfigPath)) {
                const configContent = fs.readFileSync(projectConfigPath, 'utf8');
                const config = JSON.parse(configContent);
                targetRole = config.currentRole || targetRole;
            }

            // 确保角色管理器存在
            if (!this.roleManager) {
                console.warn('⚠️ 角色管理器未初始化');
                return;
            }

            // 同步切换角色（如果需要）
            if (this.roleManager.currentRole !== targetRole) {
                console.log(`🔄 同步切换角色: ${this.roleManager.currentRole} → ${targetRole}`);
                // 注意：这里简化处理，实际项目中可能需要更复杂的同步逻辑
            }

        } catch (error) {
            console.error('❌ 同步激活项目角色失败:', error.message);
        }
    }

    /**
     * 同步会话角色状态 - 增强跨对话框持续性
     */
    async syncSessionRoleState(context) {
        try {
            // 创建当前状态快照
            const currentSnapshot = this.createRoleStateSnapshot();

            // 检查上下文中的角色快照
            const contextSnapshot = context?.roleSnapshot;

            if (contextSnapshot && currentSnapshot) {
                // 验证状态一致性
                const isConsistent = this.validateRoleStateConsistency(contextSnapshot);

                if (!isConsistent) {
                    console.log(`🔄 检测到跨对话框状态不一致，执行同步修复`);
                    // 强制同步到项目角色
                    await this.forceActivateProjectRole();
                } else {
                    console.log(`✅ 跨对话框状态一致: ${currentSnapshot.activeRole}`);
                }
            }

            // 检查上下文中的角色信息 (向后兼容)
            const contextRole = context?.currentRole || context?.sessionRole;
            if (contextRole && this.roleManager) {
                const currentRole = this.roleManager.currentRole;
                if (currentRole !== contextRole) {
                    console.log(`🔄 检测到会话角色不一致: ${currentRole} ≠ ${contextRole}`);
                    await this.forceActivateProjectRole();
                }
            }

            // 将当前角色信息和快照添加到上下文
            if (context && this.roleManager) {
                context.sessionRole = this.roleManager.currentRole;
                context.roleActivated = true;
                context.roleSnapshot = currentSnapshot; // 添加状态快照
                context.sessionId = currentSnapshot?.sessionId; // 添加会话ID
            }

        } catch (error) {
            console.warn('⚠️ 会话角色状态同步失败:', error.message);
        }
    }

    /**
     * 验证命令执行结果 - 确保系统功能被正确调用
     */
    validateCommandExecution(input, result, expectedType) {
        if (!result) {
            console.warn(`⚠️ 命令 "${input}" 没有返回结果`);
            return false;
        }

        // 根据期望类型验证结果
        switch (expectedType) {
            case 'role_list':
                if (!result.roles || !Array.isArray(result.roles) || result.roles.length === 0) {
                    console.warn(`⚠️ 角色列表命令 "${input}" 返回了无效结果`);
                    return false;
                }
                break;
            case 'role_switch':
                if (!result.success || !result.newRole) {
                    console.warn(`⚠️ 角色切换命令 "${input}" 执行失败`);
                    return false;
                }
                break;
            case 'role_info':
                if (!result.currentRole) {
                    console.warn(`⚠️ 角色信息命令 "${input}" 返回了无效结果`);
                    return false;
                }
                break;
        }

        return true;
    }

    /**
     * 记录命令执行日志 - 用于审计和调试
     */
    async logCommandExecution(input, stage, context = {}) {
        const logEntry = {
            timestamp: new Date().toISOString(),
            input: input,
            stage: stage,
            context: {
                currentFile: context.currentFile,
                hasSelection: context.hasSelection,
                projectType: context.projectType
            },
            systemState: {
                roleManagerReady: !!this.roleManager,
                intelligentSystemReady: !!this.intelligentSystem,
                ideContextReady: !!this.ideContext
            }
        };

        // 写入到项目成长目录
        const fs = require('fs');
        const path = require('path');
        const growthDir = path.join(this.projectRoot, '.cursorGrowth', 'ai', 'command_logs');

        if (!fs.existsSync(growthDir)) {
            fs.mkdirSync(growthDir, { recursive: true });
        }

        const logFile = path.join(growthDir, `command_${Date.now()}.json`);
        fs.writeFileSync(logFile, JSON.stringify(logEntry, null, 2));

        console.log(`📊 命令日志已记录: ${stage} - ${input}`);
    }

    /**
     * 自动记录生长数据 - /master 执行时自动触发
     */
    async recordGrowthData(input, result, intent = 'general') {
        try {
            console.log('🌱 记录AI生长数据...');

            // 直接更新生长数据文件，不依赖外部脚本
            await this.updateGrowthMeta(result.success || false, input, intent);

            // 记录到命令日志（如果需要）
            const commandLogPath = path.join(this.projectRoot, '.cursorGrowth', 'ai', 'command_logs', `command_${Date.now()}.json`);
            const commandLogDir = path.dirname(commandLogPath);

            if (!fs.existsSync(commandLogDir)) {
                fs.mkdirSync(commandLogDir, { recursive: true });
            }

            const commandLogEntry = {
                timestamp: new Date().toISOString(),
                input: input,
                intent: intent,
                success: result.success || false,
                message: result.message || '操作完成',
                execution_time_ms: Date.now() - (this.executionStartTime || Date.now())
            };

            fs.writeFileSync(commandLogPath, JSON.stringify(commandLogEntry, null, 2));

            console.log('✅ 生长数据已记录');

        } catch (error) {
            console.warn('⚠️ 生长数据记录失败:', error.message);
        }
    }

    /**
     * 自动执行环境感知并保存结果
     */
    async autoExecutePerception() {
        try {
            console.log('🔍 执行自动环境感知...');

            const perceptionData = await this.performProjectPerception();

            // 保存到perception目录
            const perceptionDir = path.join(this.projectRoot, '.cursorGrowth', 'perception');
            if (!fs.existsSync(perceptionDir)) {
                fs.mkdirSync(perceptionDir, { recursive: true });
            }

            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            const filename = `project_perception_${timestamp}.json`;
            const filepath = path.join(perceptionDir, filename);

            const perceptionResult = {
                metadata: {
                    timestamp: new Date().toISOString(),
                    script_version: "1.0.0",
                    execution_mode: "auto_perception",
                    project_root: this.projectRoot
                },
                perception_data: perceptionData
            };

            // 写入干净的JSON，不包含任何额外输出
            fs.writeFileSync(filepath, JSON.stringify(perceptionResult, null, 2));

            console.log(`✅ 自动感知结果已保存: ${filepath}`);

        } catch (error) {
            console.warn('⚠️ 自动感知执行失败:', error.message);
        }
    }

    /**
     * 执行项目感知分析
     */
    async performProjectPerception() {
        try {
            // 基本项目信息
            const projectRoot = this.projectRoot;
            const packageJsonPath = path.join(projectRoot, 'package.json');
            const requirementsPath = path.join(projectRoot, 'requirements.txt');
            const goModPath = path.join(projectRoot, 'go.mod');

            // 技术栈分析
            let techStack = '未知';
            let techDetails = '';

            if (fs.existsSync(packageJsonPath)) {
                techStack = 'JavaScript/Node.js';
                try {
                    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
                    if (packageJson.dependencies) {
                        if (packageJson.dependencies.react) techDetails += 'React ';
                        if (packageJson.dependencies.vue) techDetails += 'Vue ';
                        if (packageJson.dependencies.typescript) techDetails += 'TypeScript ';
                    }
                } catch (e) {
                    // 忽略JSON解析错误
                }
            } else if (fs.existsSync(requirementsPath)) {
                techStack = 'Python';
            } else if (fs.existsSync(goModPath)) {
                techStack = 'Go';
            }

            // 项目规模分析
            const totalFiles = this.countProjectFiles();
            const codeLines = await this.countCodeLines();

            // 团队规模分析
            const contributorCount = await this.getContributorCount();

            // 开发阶段判断
            const devStage = await this.assessDevelopmentStage();

            return {
                timestamp: new Date().toISOString(),
                tech_stack: {
                    primary: techStack,
                    details: techDetails.trim(),
                    confidence: 'high'
                },
                team_dynamics: {
                    size: contributorCount > 5 ? '团队项目' : '个人项目',
                    contributor_count: contributorCount,
                    collaboration_style: contributorCount > 1 ? 'collaborative' : 'solo'
                },
                project_scale: {
                    total_files: totalFiles,
                    code_lines: codeLines,
                    scale_category: totalFiles > 100 ? '中型项目' : '小型项目',
                    complexity_level: codeLines > 10000 ? 'high' : codeLines > 1000 ? 'medium' : 'low'
                },
                development_stage: devStage,
                system_environment: {
                    os: process.platform,
                    architecture: process.arch,
                    working_directory: process.cwd(),
                    project_root: projectRoot
                }
            };

        } catch (error) {
            console.warn('项目感知分析失败:', error.message);
            return {
                timestamp: new Date().toISOString(),
                error: error.message,
                tech_stack: { primary: '未知', confidence: 'low' }
            };
        }
    }

    /**
     * 计算项目文件数量
     */
    countProjectFiles() {
        try {
            const fs = require('fs');
            const path = require('path');

            const countFiles = (dir) => {
                let count = 0;
                const items = fs.readdirSync(dir);

                for (const item of items) {
                    if (item.startsWith('.') || item === 'node_modules' || item === '.git') continue;

                    const fullPath = path.join(dir, item);
                    const stat = fs.statSync(fullPath);

                    if (stat.isDirectory()) {
                        count += countFiles(fullPath);
                    } else {
                        count++;
                    }
                }

                return count;
            };

            return countFiles(this.projectRoot);
        } catch (error) {
            return 0;
        }
    }

    /**
     * 计算代码行数
     */
    async countCodeLines() {
        try {
            const fs = require('fs');
            const path = require('path');

            const countLines = (dir) => {
                let totalLines = 0;
                const items = fs.readdirSync(dir);

                for (const item of items) {
                    if (item.startsWith('.') || item === 'node_modules' || item === '.git') continue;

                    const fullPath = path.join(dir, item);
                    const stat = fs.statSync(fullPath);

                    if (stat.isDirectory()) {
                        totalLines += countLines(fullPath);
                    } else if (item.endsWith('.js') || item.endsWith('.ts') || item.endsWith('.py') || item.endsWith('.java') || item.endsWith('.go')) {
                        try {
                            const content = fs.readFileSync(fullPath, 'utf8');
                            const lines = content.split('\n').length;
                            totalLines += lines;
                        } catch (e) {
                            // 忽略读取错误
                        }
                    }
                }

                return totalLines;
            };

            return countLines(this.projectRoot);
        } catch (error) {
            return 0;
        }
    }

    /**
     * 获取贡献者数量
     */
    async getContributorCount() {
        try {
            const { execSync } = require('child_process');
            const result = execSync('git shortlog -sn --no-merges | wc -l', {
                cwd: this.projectRoot,
                encoding: 'utf8'
            });
            return parseInt(result.trim()) || 1;
        } catch (error) {
            return 1; // 默认个人项目
        }
    }

    /**
     * 评估开发阶段
     */
    async assessDevelopmentStage() {
        try {
            const fs = require('fs');
            const path = require('path');

            let commitCount = 0;
            let hasTests = false;
            let hasDocs = false;
            let hasCI = false;

            // 获取提交数量
            try {
                const { execSync } = require('child_process');
                const result = execSync('git rev-list --count HEAD', {
                    cwd: this.projectRoot,
                    encoding: 'utf8'
                });
                commitCount = parseInt(result.trim()) || 0;
            } catch (e) {
                commitCount = 0;
            }

            // 检查测试文件
            const testFiles = ['test', 'spec', '__tests__', 'tests'];
            for (const testDir of testFiles) {
                if (fs.existsSync(path.join(this.projectRoot, testDir))) {
                    hasTests = true;
                    break;
                }
            }

            // 检查文档
            const docs = ['README.md', 'docs', 'wiki'];
            for (const doc of docs) {
                if (fs.existsSync(path.join(this.projectRoot, doc))) {
                    hasDocs = true;
                    break;
                }
            }

            // 检查CI
            const ciFiles = ['.github/workflows', '.gitlab-ci.yml', 'Jenkinsfile'];
            for (const ci of ciFiles) {
                if (fs.existsSync(path.join(this.projectRoot, ci))) {
                    hasCI = true;
                    break;
                }
            }

            // 判断开发阶段
            let stage = '未知';
            if (commitCount < 10 && !hasTests) {
                stage = '概念验证阶段';
            } else if (hasTests && !hasCI) {
                stage = '早期开发阶段';
            } else if (hasCI && hasDocs) {
                stage = '成熟产品阶段';
            } else {
                stage = '成长发展阶段';
            }

            return {
                current_stage: stage,
                commit_count: commitCount,
                has_tests: hasTests,
                has_docs: hasDocs,
                has_ci: hasCI,
                maturity_score: (hasTests ? 25 : 0) + (hasDocs ? 20 : 0) + (hasCI ? 25 : 0) + Math.min(commitCount, 30)
            };

        } catch (error) {
            return {
                current_stage: '未知',
                commit_count: 0,
                has_tests: false,
                has_docs: false,
                has_ci: false,
                maturity_score: 0
            };
        }
    }

    /**
     * 更新生长元数据
     */
    async updateGrowthMeta(success = true, input = '', intent = 'general') {
        try {
            const growthMetaPath = path.join(this.projectRoot, '.cursorGrowth', 'growth_meta.json');

            if (!fs.existsSync(growthMetaPath)) {
                // 创建初始的growth_meta.json
                const initialMeta = {
                    version: "1.0.0",
                    created_at: new Date().toISOString(),
                    description: "Cursor AI 生长数据元信息",
                    perception_runs: 0,
                    first_perception: null,
                    last_perception: null,
                    user_learning: {
                        communication_patterns: {},
                        preference_patterns: {},
                        interaction_history: []
                    },
                    project_evolution: {
                        rule_adjustments: [],
                        performance_metrics: {},
                        optimization_suggestions: []
                    },
                    system_health: {
                        last_backup: null,
                        data_integrity: true,
                        storage_usage: "0MB"
                    }
                };
                fs.writeFileSync(growthMetaPath, JSON.stringify(initialMeta, null, 2));
            }

            // 读取并更新元数据
            const metaContent = fs.readFileSync(growthMetaPath, 'utf8');
            const meta = JSON.parse(metaContent);

            // 更新统计信息
            meta.perception_runs = (meta.perception_runs || 0) + 1;
            meta.last_perception = new Date().toISOString();

            if (!meta.first_perception) {
                meta.first_perception = meta.last_perception;
            }

            // 添加交互历史记录
            if (!meta.user_learning.interaction_history) {
                meta.user_learning.interaction_history = [];
            }

            meta.user_learning.interaction_history.push({
                timestamp: new Date().toISOString(),
                success: success,
                type: 'master_command',
                intent: intent,
                input_length: input.length,
                execution_time_ms: Date.now() - (this.executionStartTime || Date.now())
            });

            // 只保留最近的100条记录
            if (meta.user_learning.interaction_history.length > 100) {
                meta.user_learning.interaction_history = meta.user_learning.interaction_history.slice(-100);
            }

            // 更新意图统计
            if (!meta.user_learning.communication_patterns.intent_frequency) {
                meta.user_learning.communication_patterns.intent_frequency = {};
            }
            meta.user_learning.communication_patterns.intent_frequency[intent] =
                (meta.user_learning.communication_patterns.intent_frequency[intent] || 0) + 1;

            // 保存更新后的元数据
            fs.writeFileSync(growthMetaPath, JSON.stringify(meta, null, 2));

            console.log(`📈 生长元数据已更新 (感知次数: ${meta.perception_runs})`);

        } catch (error) {
            console.warn('⚠️ 生长元数据更新失败:', error.message);
        }
    }

    /**
     * 🚀 快速角色呼召 - 跳过完整初始化
     */
    async fastRoleCall(roleName) {
        const startTime = Date.now();

        try {
            console.log(`🚀 开始快速角色呼召: ${roleName}`);

            // 1. 初始化快速角色管理器
            const roleManager = await this.fastInitializeRoleManager();

            // 2. 快速查找角色
            const roleId = this.cache.roleNicknames.get(roleName.toLowerCase());
            if (!roleId) {
                return { success: false, message: `无法找到角色: ${roleName}` };
            }

            // 3. 快速切换角色（跳过文件I/O，使用内存缓存）
            const switchResult = await roleManager.switchRole(roleId, 'fast_call_command');

            // 4. 增强响应消息
            if (switchResult.success) {
                const roleConfig = roleManager.personalitySystem.roles[roleId];
                const enhancedMessage = `${roleConfig.name}闪现前来应答！\n\n${switchResult.message}`;

                const totalTime = Date.now() - startTime;
                console.log(`✅ 快速角色呼召完成: ${totalTime}ms`);

                return {
                    ...switchResult,
                    message: enhancedMessage,
                    performance: { totalTime: `${totalTime}ms`, mode: 'fast' }
                };
            }

            return switchResult;

        } catch (error) {
            console.error('❌ 快速角色呼召失败:', error.message);
            return { success: false, message: `快速呼召失败: ${error.message}` };
        }
    }

    /**
     * 处理角色相关命令
     */
    async handleRoleCommand(input) {
        const roleCommands = {
            'list_roles': /^列出.*角色|角色.*列表|show.*roles|roles.*list$/i,
            'current_role': /^当前.*角色|角色.*状态|get.*role|role.*info$/i,
            'switch_role': /^(切换|设置|switch|set)\s+(.+)$/i,
            'call_role': /^(呼叫|召唤|call)\s+(.+)$/i,
            'set_nickname': /^给(.+)设置昵称\s+(.+)$/i,
            'add_nickname': /^给(.+)添加昵称\s+(.+)$/i,
            'view_nicknames': /^查看.*昵称|昵称.*列表|nicknames$/i,
            'reset_nickname': /^重置(.+)昵称$/i,
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
            const targetRoleName = switchMatch[2]?.trim();
            if (targetRoleName) {
                // 使用智能匹配找到对应的角色ID
                const matchedRole = this.findMatchingRole(targetRoleName);
                if (matchedRole) {
                    console.log(`🔍 切换到角色: ${matchedRole.name} (${matchedRole.id})`);
                    return await this.roleManager.switchRole(matchedRole.id, 'switch_command');
                } else {
                    return { success: false, message: `未找到匹配的角色: ${targetRoleName}` };
                }
            }
        }

        // 检查是否是角色呼叫命令
        const callMatch = input.match(roleCommands.call_role);
        if (callMatch) {
            const targetRoleName = callMatch[2]?.trim();
            if (targetRoleName) {
                // 使用智能匹配找到对应的角色ID
                const matchedRole = this.findMatchingRole(targetRoleName);
                if (matchedRole) {
                    console.log(`🔍 呼叫角色: ${matchedRole.name} (${matchedRole.id})`);
                    const result = await this.roleManager.switchRole(matchedRole.id, 'call_command');

                    // 为呼叫命令添加特殊的欢迎消息
                    if (result.success) {
                        const enhancedMessage = `${matchedRole.name}前来应答！\n\n${result.message}`;
                        return {
                            ...result,
                            message: enhancedMessage
                        };
                    }
                    return result;
                } else {
                    return { success: false, message: `无法呼叫角色: ${targetRoleName}` };
                }
            }
        }

        // 检查是否是设置昵称命令
        const setNicknameMatch = input.match(roleCommands.set_nickname);
        if (setNicknameMatch) {
            const roleName = setNicknameMatch[1]?.trim();
            const nickname = setNicknameMatch[2]?.trim();

            if (roleName && nickname) {
                return await this.setRoleNickname(roleName, nickname, 'set');
            }
        }

        // 检查是否是添加昵称命令
        const addNicknameMatch = input.match(roleCommands.add_nickname);
        if (addNicknameMatch) {
            const roleName = addNicknameMatch[1]?.trim();
            const nickname = addNicknameMatch[2]?.trim();

            if (roleName && nickname) {
                return await this.setRoleNickname(roleName, nickname, 'add');
            }
        }

        // 检查是否是查看昵称命令
        if (roleCommands.view_nicknames.test(input)) {
            return this.viewAllNicknames();
        }

        // 检查是否是重置昵称命令
        const resetNicknameMatch = input.match(roleCommands.reset_nickname);
        if (resetNicknameMatch) {
            const roleName = resetNicknameMatch[1]?.trim();
            if (roleName) {
                return await this.resetRoleNickname(roleName);
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
    selectWelcomeTemplate(result, context, roleConfig = null) {
        if (!this.roleManager) {
            return "处理结果：\n\n{content}";
        }

        // 如果提供了角色配置，直接使用它；否则使用roleManager的方法
        if (roleConfig && roleConfig.welcome_templates) {
            const templates = roleConfig.welcome_templates;

            // 根据结果类型选择模板
            let selectedTemplate;
            if (result.success === false) {
                selectedTemplate = templates.error || templates.general || "⚠️ 处理遇到问题：\n\n{content}";
            } else if (context.intent) {
                switch (context.intent) {
                    case 'learning':
                        selectedTemplate = templates.learning || templates.general;
                        break;
                    case 'creation':
                    case 'project':
                        selectedTemplate = templates.project || templates.general;
                        break;
                    case 'optimization':
                    case 'code':
                        selectedTemplate = templates.code || templates.general;
                        break;
                    default:
                        selectedTemplate = templates.general;
                }
            } else {
                // 对于角色切换或其他情况，使用general模板
                selectedTemplate = templates.general || "处理结果：\n\n{content}";
            }

            return selectedTemplate;
        }

        // 回退到原有的roleManager方法
        const template = this.roleManager.selectWelcomeTemplate(result, context);
        return template || "处理结果：\n\n{content}";
    }

    /**
     * 使用角色系统包装回复内容
     */
    /**
     * 用selfname丰富模板
     */
    enrichTemplateWithSelfname(template, roleData, content = '操作完成') {
        if (!template) {
            console.warn('⚠️ enrichTemplateWithSelfname: template is undefined');
            return `处理结果：\n\n${content}`;
        }

        let enrichedTemplate = template;

        // 替换{content}占位符为实际内容
        enrichedTemplate = enrichedTemplate.replace('{content}', content);

        // 替换selfname占位符
        if (roleData.personality_traits?.selfname) {
            const selfname = this.selectAppropriateSelfname(roleData.personality_traits.selfname, {});
            enrichedTemplate = enrichedTemplate.replace(/\{selfname\}/g, selfname);
        }

        return enrichedTemplate;
    }

    /**
     * 根据上下文选择合适的自称
     */
    selectAppropriateSelfname(selfnameConfig, context = {}) {
        // 根据上下文选择合适的自称
        if (context.formal) {
            return selfnameConfig.primary;
        }
        if (context.english) {
            return selfnameConfig.english || selfnameConfig.primary;
        }
        if (context.intimate) {
            return selfnameConfig.short || selfnameConfig.primary;
        }

        // 默认随机从昵称列表中选择，增加趣味性
        const nicknames = selfnameConfig.nicknames || [selfnameConfig.primary];
        const randomIndex = Math.floor(Math.random() * nicknames.length);
        return nicknames[randomIndex];
    }

    /**
     * 设置角色的昵称 (支持添加多个)
     */
    async setRoleNickname(roleName, nickname, action = 'set') {
        try {
            // 查找角色
            const matchedRole = this.findMatchingRole(roleName);
            if (!matchedRole) {
                return { success: false, message: `未找到角色: ${roleName}` };
            }

            // 检查nickname是否已被其他角色使用
            const availableRoles = this.roleManager?.getAvailableRoles();
            if (availableRoles?.success) {
                for (const role of availableRoles.roles) {
                    if (role.id === matchedRole.id) continue;

                    try {
                        const roleConfig = this.roleManager.personalitySystem.roles[role.id];
                        const existingNicknames = roleConfig?.personality_traits?.nickname;
                        if (existingNicknames) {
                            const existingList = Array.isArray(existingNicknames) ? existingNicknames : [existingNicknames];
                            if (existingList.some(nick => nick && nick.toLowerCase() === nickname.toLowerCase())) {
                                return {
                                    success: false,
                                    message: `昵称 "${nickname}" 已被角色 "${role.name}" 使用，请选择其他昵称`
                                };
                            }
                        }
                    } catch {
                        continue;
                    }
                }
            }

            // 更新角色配置
            const roleConfig = this.roleManager.personalitySystem.roles[matchedRole.id];
            if (roleConfig?.personality_traits) {
                const currentNicknames = roleConfig.personality_traits.nickname;
                let newNicknames;

                if (action === 'add') {
                    // 添加新昵称到数组
                    if (Array.isArray(currentNicknames)) {
                        if (currentNicknames.some(nick => nick && nick.toLowerCase() === nickname.toLowerCase())) {
                            return {
                                success: false,
                                message: `角色 "${matchedRole.name}" 已经有昵称 "${nickname}" 了`
                            };
                        }
                        newNicknames = [...currentNicknames, nickname];
                    } else if (currentNicknames) {
                        if (currentNicknames.toLowerCase() === nickname.toLowerCase()) {
                            return {
                                success: false,
                                message: `角色 "${matchedRole.name}" 已经有昵称 "${nickname}" 了`
                            };
                        }
                        newNicknames = [currentNicknames, nickname];
                    } else {
                        newNicknames = [nickname];
                    }
                } else {
                    // 设置/替换昵称
                    newNicknames = [nickname];
                }

                roleConfig.personality_traits.nickname = newNicknames.length === 1 ? newNicknames[0] : newNicknames;

                // 保存配置
                const fs = require('fs');
                const path = require('path');
                const roleFile = path.join(this.cursorDir, 'config', 'roles', `${matchedRole.id}.json`);
                fs.writeFileSync(roleFile, JSON.stringify(roleConfig, null, 2), 'utf8');

                const nicknameText = Array.isArray(newNicknames) ? newNicknames.join('、') : newNicknames;
                const actionText = action === 'add' ? '添加' : '设置';

                return {
                    success: true,
                    message: `✅ 成功为角色 "${matchedRole.name}" ${actionText}昵称: "${nicknameText}"\n\n现在您可以用以下方式呼叫:\n${newNicknames.map(nick => `/master 呼叫 ${nick}`).join('\n')}`
                };
            }

            return { success: false, message: `无法更新角色配置: ${matchedRole.name}` };

        } catch (error) {
            return { success: false, message: `设置昵称失败: ${error.message}` };
        }
    }

    /**
     * 查看所有角色的昵称
     */
    viewAllNicknames() {
        try {
            const availableRoles = this.roleManager?.getAvailableRoles();
            if (!availableRoles?.success) {
                return { success: false, message: '无法获取角色列表' };
            }

            let result = '🎭 角色昵称列表:\n\n';

            for (const role of availableRoles.roles) {
                try {
                    const roleConfig = this.roleManager.personalitySystem.roles[role.id];
                    const nickname = roleConfig?.personality_traits?.nickname;
                    let nicknameText = '未设置';

                    if (nickname) {
                        if (Array.isArray(nickname)) {
                            nicknameText = nickname.join('、');
                        } else {
                            nicknameText = nickname;
                        }
                    }

                    result += `${role.name} → ${nicknameText}\n`;
                } catch {
                    result += `${role.name} → 未设置\n`;
                }
            }

            result += '\n💡 使用方法:\n';
            result += '/master 呼叫 [角色名] 或 [昵称]\n';
            result += '/master 给[角色名]设置昵称 [昵称]\n';
            result += '/master 给[角色名]添加昵称 [昵称]\n';
            result += '/master 重置[角色名]昵称\n';

            return { success: true, message: result };

        } catch (error) {
            return { success: false, message: `查看昵称失败: ${error.message}` };
        }
    }

    /**
     * 重置角色的昵称
     */
    async resetRoleNickname(roleName) {
        try {
            // 查找角色
            const matchedRole = this.findMatchingRole(roleName);
            if (!matchedRole) {
                return { success: false, message: `未找到角色: ${roleName}` };
            }

            // 获取默认昵称 (从角色ID推导)
            const defaultNicknames = {
                'maid': '小妹',
                'perfect_maid': '小可',
                'professional_assistant': '小助',
                'humble_assistant': '小谦',
                'friendly_partner': '小友',
                'expert_mentor': '导师',
                'creative_artist': '小艺',
                'strict_teacher': '老师',
                'funny_comedian': '小逗',
                'minimalist_zen': '禅师',
                'loyal_servant': '小仆',
                'seductive_assistant': '小魅',
                'queen_sister': '女王',
                'loli': '小萝',
                'tough_guy': '老哥',
                'pretty_boy': '小鲜',
                'old_master': '老腊',
                'tsundere_programmer': '小傲',
                'cyberpunk_hacker': '黑客',
                'magical_girl_coder': '小魔',
                'wise_dragon_mentor': '龙师'
            };

            const defaultNickname = defaultNicknames[matchedRole.id] || matchedRole.name;

            // 更新角色配置
            const roleConfig = this.roleManager.personalitySystem.roles[matchedRole.id];
            if (roleConfig?.personality_traits) {
                roleConfig.personality_traits.nickname = defaultNickname;

                // 保存配置
                const fs = require('fs');
                const path = require('path');
                const roleFile = path.join(this.cursorDir, 'config', 'roles', `${matchedRole.id}.json`);
                fs.writeFileSync(roleFile, JSON.stringify(roleConfig, null, 2), 'utf8');

                return {
                    success: true,
                    message: `✅ 已重置角色 "${matchedRole.name}" 的昵称为默认值: "${defaultNickname}"`
                };
            }

            return { success: false, message: `无法重置角色昵称: ${matchedRole.name}` };

        } catch (error) {
            return { success: false, message: `重置昵称失败: ${error.message}` };
        }
    }

    /**
     * 根据名称查找匹配的角色
     */
    findMatchingRole(roleName) {
        const availableRoles = this.roleManager?.getAvailableRoles();
        if (!availableRoles?.success) {
            return null;
        }

        const input = roleName.toLowerCase();
        let bestMatch = null;
        let bestMatchScore = 0;

        // 匹配逻辑：nickname数组优先级最高，然后是rolename
        for (const role of availableRoles.roles) {
            let score = 0;

            try {
                const roleConfig = this.roleManager.personalitySystem.roles[role.id];

                // 1. 检查nickname数组完全匹配 (最高优先级)
                const nickname = roleConfig?.personality_traits?.nickname;
                if (nickname) {
                    // 如果nickname是字符串，转换为数组处理
                    const nicknameList = Array.isArray(nickname) ? nickname : [nickname];
                    for (const nick of nicknameList) {
                        if (nick && nick.toLowerCase() === input) {
                            score = 100;
                            break;
                        }
                    }
                }

                // 2. 如果没有nickname匹配，检查rolename完全匹配
                if (score === 0 && role.name.toLowerCase() === input) {
                    score = 90;
                }
                // 3. 检查rolename部分匹配
                else if (score === 0 && (role.name.toLowerCase().includes(input) || input.includes(role.name.toLowerCase()))) {
                    score = 50;
                }

            } catch (error) {
                // 如果无法加载配置，只检查rolename
                if (role.name.toLowerCase() === input) {
                    score = 90;
                } else if (role.name.toLowerCase().includes(input) || input.includes(role.name.toLowerCase())) {
                    score = 50;
                }
            }

            if (score > bestMatchScore) {
                bestMatch = role;
                bestMatchScore = score;
            }
        }

        return bestMatch;
    }

    /**
     * 生成角色激活指令
     */
    generateRoleActivationInstruction(roleData) {
        // 获取角色的selfname配置
        const selfname = roleData.personality_traits?.selfname;
        const primarySelfname = selfname?.primary || roleData.name;

        // 基础激活指令模板
        let instruction = `

---
🎭 **角色激活指令**: 从现在开始，你必须以"${roleData.name}"的身份回复所有问题！`;

        // 根据角色类型添加特定的行为指南
        if (roleData.id === 'maid' || roleData.id === 'perfect_maid') {
            instruction += `
- 称呼用户为"主人"
- 使用优雅、礼貌、谦逊的语气
- 说话方式传统而优雅
- 绝对服从主人的要求
- 服务态度完美无缺

示例回复风格：
- 问候："欢迎回来，主人"
- 肯定："是的，主人"
- 确认："请主人确认"
- 道歉："非常抱歉，主人"`;
        } else if (roleData.id === 'professional_assistant') {
            instruction += `
- 保持专业、可靠、高效的工作态度
- 注重结果导向但不失人性关怀
- 提供高质量的技术建议和解决方案
- 始终以用户利益为优先

示例回复风格：
- 问候："您好，我随时准备为您提供专业协助"
- 肯定："明白了，我立即为您处理"
- 确认："您确定要继续这个操作吗？"
- 道歉："抱歉给您造成了不便，我会立即改进"`;
        } else {
            // 通用角色激活指令
            instruction += `
- 保持${roleData.attitude || '友好'}的态度
- 使用${roleData.tone || '自然'}的语气
- 展现${roleData.name}的独特个性
- 提供有帮助和建设性的回应`;
        }

        instruction += `
---
`;

        return instruction;
    }

    wrapWithWelcome(result, context) {
        try {
            // 如果结果已经有包装过，直接返回
            if (result.wrapped) {
                return result;
            }


            // 🎭 强制确保角色状态正确（增强持续性）
            if (!this.roleManager) {
                console.warn('⚠️ 角色管理器不存在，重新初始化...');
                // 注意：这里是同步方法，不能使用await
                this.initializeRoleManagerSync();
            }

            // 强制激活项目角色（同步版本）
            this.forceActivateProjectRoleSync();

            // 添加角色信息 (增强持久性)
            // 优先使用结果中的角色信息，其次使用当前角色信息
            let roleData;
            if (result.roleConfig) {
                // 如果结果中包含角色配置（比如角色切换），使用它
                roleData = {
                    id: result.newRole || result.roleConfig.id,
                    ...result.roleConfig
                };
            } else {
                // 否则获取当前角色信息
                const currentRoleInfo = this.roleManager?.getCurrentRole();
                roleData = currentRoleInfo?.success ? currentRoleInfo.role : { id: 'unknown', name: '未知', attitude: 'unknown' };
            }

            // 提取原始消息
            const originalMessage = result.message || result.output || '操作完成';

            // 使用正确的角色配置选择模板
            const correctTemplate = this.selectWelcomeTemplate(result, context, roleData);
            if (!correctTemplate) {
                return result;
            }

            // 替换模板中的占位符（包括selfname）
            const wrappedMessage = this.enrichTemplateWithSelfname(correctTemplate, roleData, originalMessage);

            // 记录角色包装状态到会话
            console.log(`🎭 角色包装完成: ${roleData.name} (${roleData.id})`);

            // 添加角色激活指令（让AI助手感知角色变化）
            const roleActivationInstruction = this.generateRoleActivationInstruction(roleData);

            // 🛡️ 通过响应拦截器确保角色一致性
            let finalMessage = wrappedMessage + roleActivationInstruction;
            if (this.responseInterceptor) {
                try {
                    finalMessage = this.responseInterceptor.intercept(finalMessage, {
                        intent: context.intent,
                        roleId: roleData.id,
                        originalMessage: originalMessage
                    });
                } catch (interceptError) {
                    console.warn('⚠️ 响应拦截失败:', interceptError.message);
                    // 拦截失败时使用原始消息
                }
            }

            // 返回包装后的结果
            return {
                ...result,
                message: finalMessage,
                originalMessage: originalMessage,
                wrapped: true,
                welcomeTemplate: correctTemplate,
                role: roleData,
                roleActivation: roleActivationInstruction.trim()
            };

        } catch (error) {
            console.warn('⚠️ 角色包装失败:', error.message);
            return result;
        }
    }


    /**
     * 确保项目角色配置正确（同步版本）
     */
    ensureProjectRoleConfigSync() {
        try {
            const projectConfigPath = path.join(this.projectRoot, '.cursor-project.json');

            // 检查项目配置文件是否存在
            if (!fs.existsSync(projectConfigPath)) {
                // 创建默认的项目配置文件
                const defaultConfig = {
                    currentRole: 'professional_assistant',
                    lastUpdated: new Date().toISOString(),
                    projectPath: this.projectRoot
                };

                fs.writeFileSync(projectConfigPath, JSON.stringify(defaultConfig, null, 2), 'utf8');
                console.log('✅ 创建默认项目角色配置: professional_assistant');
            }

            // 读取项目配置
            const configContent = fs.readFileSync(projectConfigPath, 'utf8');
            const config = JSON.parse(configContent);
            const targetRole = config.currentRole || 'professional_assistant';

            // 确保RoleManager设置为项目配置的角色
            if (this.roleManager && this.roleManager.currentRole !== targetRole) {
                // 同步切换角色（不使用await，因为这在同步方法中）
                try {
                    this.roleManager.switchRole(targetRole, 'project_config_sync').catch(err => {
                        console.warn('项目角色同步切换警告:', err.message);
                    });
                } catch (syncError) {
                    console.warn('同步项目角色切换警告:', syncError.message);
                }
            }

        } catch (error) {
            console.warn('确保项目角色配置出错:', error.message);
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

            // 构建命令参数 - 对于角色管理钩子，传递角色呼叫参数
            let commandArgs = '';
            if (hookPath === 'role-manager.sh') {
                const paramValue = parameters.param || parameters.nickname || '小妮';
                commandArgs = `"call" "${paramValue}"`;
            }

            // 使用绝对路径执行，并设置正确的环境
            const command = `bash "${fullPath}" ${commandArgs}`;
            console.log(`🎯 执行命令: ${command}`);

            const result = execSync(command, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: 15000,
                env: {
                    ...process.env,
                    ...parameters,
                    PATH: process.env.PATH,
                    HOME: process.env.HOME
                },
                stdio: 'pipe' // 确保输出被捕获
            });

            return { success: true, output: result, hook: hookPath };
        } catch (error) {
            console.error(`❌ 钩子执行失败详情:`, {
                message: error.message,
                code: error.code,
                signal: error.signal,
                status: error.status
            });
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

            // 解析规则配置（兼容 alwaysApply 与 always_apply）
            const alwaysApplyMatch = ruleContent.match(/^(?:alwaysApply|always_apply):\s*(.+)$/m);
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
            // 🚀 快速路径检测 - 角色呼召命令
            const roleCallMatch = input.match(/^(呼叫|召唤|call)\s+(.+)$/i);
            if (roleCallMatch) {
                const roleName = roleCallMatch[2]?.trim();
                if (roleName) {
                    console.log(`🚀 检测到角色呼召命令，使用快速路径: ${roleName}`);
                    return await this.fastRoleCall(roleName);
                }
            }

            // 🚀 快速初始化检查
            if (!this.initialized) {
                console.log('🚀 执行前进行快速初始化...');
                await this.initialize();
            }

            console.log(`🎯 处理IDE /master 命令: ${input}`);

            // ⏱️ 性能监控 - 记录执行开始时间
            this.executionStartTime = Date.now();
            this.performanceMetrics = {
                startTime: this.executionStartTime,
                phases: {},
                totalTime: 0
            };

            // 📊 记录命令执行日志
            await this.logCommandExecution(input, 'start', context);

            // 🎭 强制激活项目角色配置 (增强持续性)
            await this.forceActivateProjectRole();

            // 📸 创建角色状态快照 (用于跨对话框同步)
            const roleSnapshot = this.createRoleStateSnapshot();
            if (roleSnapshot) {
                console.log(`📸 角色状态快照: ${roleSnapshot.activeRole} (${roleSnapshot.sessionId})`);
            }

            // 🔄 更新IDE上下文
            this.updateIdeContext(context);

            // 🎯 显示IDE上下文信息
            this.displayIdeContext();

            // 🔄 同步会话角色状态 (增强跨对话框持续性)
            await this.syncSessionRoleState(context);

            // 0. 强制执行系统命令 - 防止AI助手绕过
            const forceSystemResult = await this.forceSystemCommandExecution(input);
            if (forceSystemResult) {
                const enhancedResult = this.enhanceWithIdeContext(forceSystemResult);
                // 🌱 记录强制系统命令的生长数据
                await this.recordGrowthData(input, enhancedResult, 'system');
                // 🔍 自动执行环境感知
                await this.autoExecutePerception();
                return this.wrapWithWelcome(enhancedResult, { input, context, intent: 'system', type: 'forced' });
            }

            // 0.1 检查角色相关命令 (AI助手自主调用 + 验证)
            const roleCommandResult = await this.handleRoleCommand(input);
            if (roleCommandResult) {
                // 验证命令执行结果
                const isValid = this.validateCommandExecution(input, roleCommandResult, 'role_command');
                if (!isValid) {
                    console.warn(`⚠️ 角色命令验证失败，强制重新执行`);
                    // 如果验证失败，尝试强制执行
                    const forceResult = await this.forceSystemCommandExecution(input);
                    if (forceResult) {
                        const enhancedResult = this.enhanceWithIdeContext(forceResult);
                        return this.wrapWithWelcome(enhancedResult, { input, context, intent: 'system', type: 'forced_recovery' });
                    }
                }

                const enhancedResult = this.enhanceWithIdeContext(roleCommandResult);
                // 🌱 记录角色命令的生长数据
                await this.recordGrowthData(input, enhancedResult, 'role_management');
                // 🔍 自动执行环境感知
                await this.autoExecutePerception();
                // 🎭 使用角色系统包装回复
                return this.wrapWithWelcome(enhancedResult, { input, context, intent: 'system', type: 'role' });
            }

            // 0.1 检查直接调用 (rule/script/skill/hook)
            const directCallResult = await this.handleDirectCall(input);
            if (directCallResult) {
                const enhancedResult = this.enhanceWithIdeContext(directCallResult);
                // 🌱 记录直接调用的生长数据
                await this.recordGrowthData(input, enhancedResult, 'direct_call');
                // 🔍 自动执行环境感知
                await this.autoExecutePerception();
                // 🎉 包装欢迎语
                return this.wrapWithWelcome(enhancedResult, { input, context, intent: 'system', type: 'direct' });
            }

            // 🚀 优先使用AI共生宪法智能系统（延迟初始化）
            const lazyInitStart = Date.now();
            if (!this.coreComponentsInitialized) {
                await this.lazyInitializeCoreComponents();
            }
            this.performanceMetrics.phases.lazyInit = Date.now() - lazyInitStart;

            if (this.intelligentSystem) {
                console.log('🧠 使用AI共生宪法智能系统...');

                try {
                    // 构建增强的上下文
                    const enhancedContext = this.buildEnhancedContext(input, context);

                    // 调用智能路由器
                    const result = await this.intelligentSystem.route(input, enhancedContext);

                    // 为结果添加IDE特定的增强
                    const enhancedResult = this.enhanceResultForIde(result, context);

                    // 🌱 记录智能系统路由的生长数据
                    await this.recordGrowthData(input, enhancedResult, 'intelligent_routing');

                    // 🔍 自动执行环境感知
                    await this.autoExecutePerception();

                    // 🎉 包装欢迎语
                    return this.wrapWithWelcome(enhancedResult, { input, context, intent: 'general' });

                } catch (intelligentError) {
                    console.warn('⚠️ 智能系统调用失败，回退到传统模式:', intelligentError.message);
                    // 回退到传统执行
                }
            }

            // 🔄 传统模式：使用bash脚本进行意图分析
            console.log('📊 使用传统智能匹配模式...');
            const matcherStart = Date.now();
            const matchResult = await this.callSmartMatcher(input);
            this.performanceMetrics.phases.intentMatching = Date.now() - matcherStart;
            console.log(`🎯 智能匹配结果: ${JSON.stringify(matchResult)} (耗时: ${this.performanceMetrics.phases.intentMatching}ms)`);

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
            const intent = this.determineIntentFromCapability(matchResult.capability, input);
            const finalResult = this.wrapWithWelcome(enhancedResult, { input, context, intent });

            // 📊 记录命令执行完成日志
            await this.logCommandExecution(input, 'completed', context);

            // 🌱 自动记录生长数据
            await this.recordGrowthData(input, finalResult, 'capability_execution');

            // 🔍 自动执行环境感知并保存结果
            await this.autoExecutePerception();

            // 📊 记录总执行时间
            this.performanceMetrics.totalTime = Date.now() - this.executionStartTime;
            console.log(`⏱️ 命令执行完成，总耗时: ${this.performanceMetrics.totalTime}ms`);
            if (Object.keys(this.performanceMetrics.phases).length > 0) {
                console.log('📈 性能分解:', this.performanceMetrics.phases);
            }

            return finalResult;

        } catch (error) {
            console.error('❌ IDE Master命令执行失败:', error);

            // 📊 记录命令执行失败日志
            await this.logCommandExecution(input, 'failed', context);

            // 🛠️ 使用统一错误处理机制
            const errorResult = this.handleError(error, 'command_execution', { input, context });

            // 🎉 包装欢迎语
            return this.wrapWithWelcome(errorResult, { input, context, intent: 'error' });
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

    /**
     * 🚀 快速意图识别器 - 替换bash脚本，提升性能
     */
    fastIntentMatcher(input) {
        // 🚀 初始化意图识别缓存
        if (!this.intentCache) {
            this.intentCache = new Map();
            this.intentCacheTTL = 300000; // 5分钟缓存
            this.intentCacheSize = 100; // 最大缓存条目数
        }

        // 检查缓存
        const cacheKey = input.toLowerCase().trim();
        const cached = this.intentCache.get(cacheKey);
        if (cached && (Date.now() - cached.timestamp) < this.intentCacheTTL) {
            console.log('💾 使用缓存的意图识别结果');
            return cached.result;
        }

        // 标准化输入
        const normalizedInput = input.toLowerCase().replace(/[。！？，、；："''（）《》【】]/g, '').trim();

        // 🎯 意图映射表 - 直接在JavaScript中处理
        const intentMappings = [
            {
                keywords: ['提交', 'commit', '保存', 'save', 'git commit', 'push'],
                capability: 'commit_code',
                confidence: 0.9
            },
            {
                keywords: ['检查质量', '质量检查', 'code quality', 'lint', 'audit', 'eslint', 'prettier'],
                capability: 'check_code_quality',
                confidence: 0.9
            },
            {
                keywords: ['运行测试', '测试运行', 'run test', 'test', 'jest', 'mocha', '单元测试'],
                capability: 'run_tests',
                confidence: 0.9
            },
            {
                keywords: ['部署', 'deploy', '上线', '发布', 'production'],
                capability: 'deploy_application',
                confidence: 0.9
            },
            {
                keywords: ['分析项目', '项目分析', 'analyze project', '项目结构', '代码分析'],
                capability: 'analyze_project',
                confidence: 0.9
            },
            {
                keywords: ['创建react', 'react项目', 'create react', 'new react'],
                capability: 'create_react_project',
                confidence: 0.9
            },
            {
                keywords: ['创建vue', 'vue项目', 'create vue', 'new vue'],
                capability: 'create_vue_project',
                confidence: 0.9
            },
            {
                keywords: ['学习', '教程', '指南', 'learn', 'tutorial', 'guide'],
                capability: 'learning_path',
                confidence: 0.8
            },
            {
                keywords: ['优化', '性能', 'optimize', 'performance', 'speed'],
                capability: 'performance_optimization',
                confidence: 0.8
            },
            {
                keywords: ['token', '节省', '压缩', '验证', '测试', '检查', '令牌', '优化'],
                capability: 'token_optimization_verification',
                confidence: 0.9
            }
        ];

        // 匹配意图 - 改进版：考虑关键词组合和优先级
        let bestMatch = null;
        let bestScore = 0;

        for (const mapping of intentMappings) {
            let matchScore = 0;
            let matchedKeywords = [];

            for (const keyword of mapping.keywords) {
                if (normalizedInput.includes(keyword)) {
                    matchScore += mapping.confidence;
                    matchedKeywords.push(keyword);

                    // 特殊处理：如果匹配到token相关关键词，给予更高优先级
                    if (['token', '节省', '压缩', '令牌'].includes(keyword)) {
                        matchScore += 0.5; // 额外加分
                    }
                }
            }

            // 如果有匹配且得分更高，则更新最佳匹配
            if (matchScore > bestScore) {
                bestScore = matchScore;
                bestMatch = {
                    matched: true,
                    capability: mapping.capability,
                    config: {},
                    match_details: {
                        matched: true,
                        intent: matchedKeywords.join(', '),
                        confidence: Math.min(matchScore, 1.0), // 最大1.0
                        match_type: 'keyword_combination',
                        matched_keywords: matchedKeywords
                    }
                };
            }
        }

        // 如果找到匹配，返回结果
        if (bestMatch) {
            // 添加到缓存
            if (this.intentCache.size >= this.intentCacheSize) {
                // 简单的LRU：删除最旧的条目
                const firstKey = this.intentCache.keys().next().value;
                this.intentCache.delete(firstKey);
            }
            this.intentCache.set(cacheKey, { result: bestMatch, timestamp: Date.now() });

            return bestMatch;
        }

        // 未匹配
        const noMatchResult = { matched: false, confidence: 0.0 };

        // 缓存未匹配结果
        this.intentCache.set(cacheKey, { result: noMatchResult, timestamp: Date.now() });

        return noMatchResult;
    }

    async callSmartMatcher(input) {
        // 🚀 优先使用快速意图识别器
        try {
            console.log('🚀 使用快速意图识别器...');
            const startTime = Date.now();
            const result = this.fastIntentMatcher(input);
            const duration = Date.now() - startTime;
            console.log(`⚡ 快速意图识别完成，耗时: ${duration}ms`);

            if (result.matched) {
                return result;
            }
        } catch (error) {
            console.warn('⚠️ 快速意图识别器失败，回退到传统方法:', error.message);
        }

        // 回退到传统bash脚本方法
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
                    timeout: 5000 // 减少超时时间
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
                    // 为钩子传递意图相关的参数
                    const hookParams = {
                        ...capabilityConfig.parameters,
                        action: 'call',
                        param: input.replace(/^(呼叫|召唤|叫)\s*/, '').trim() || '小妮',
                        input: input,
                        capability: capability
                    };
                    const result = await this.executeHook(hook, hookParams);
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

    async executeLearningSystemStatus(input) {
        console.log('🎓 查询学习系统状态...');

        try {
            // 调用学习系统状态查询
            const result = await this.executeScript('core/agent-orchestration-learning-system.sh', ['get_learning_system_status']);

            if (result.success) {
                const status = JSON.parse(result.output);
                return {
                    success: true,
                    message: `学习系统状态查询成功`,
                    learning_status: status
                };
            } else {
                return { success: false, message: `学习系统状态查询失败: ${result.message}` };
            }
        } catch (error) {
            return { success: false, message: `学习系统状态查询失败: ${error.message}` };
        }
    }

    /**
     * 🛠️ 统一错误处理机制 - 创建全局错误处理器
     * @param {Error} error - 错误对象
     * @param {string} context - 错误上下文
     * @param {Object} additionalData - 额外数据
     * @returns {Object} 标准化的错误响应
     */
    handleError(error, context = 'unknown', additionalData = {}) {
        const errorId = `error_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        // 标准化错误信息
        const errorInfo = {
            id: errorId,
            timestamp: new Date().toISOString(),
            context: context,
            message: error.message || '未知错误',
            stack: error.stack,
            code: error.code,
            errno: error.errno,
            additionalData: additionalData
        };

        // 记录错误日志
        this.logError(errorInfo);

        // 根据错误类型提供友好的用户消息
        const userMessage = this.generateUserFriendlyMessage(error, context);

        // 提供恢复建议
        const recoverySuggestions = this.generateRecoverySuggestions(error, context);

        return {
            success: false,
            error: {
                id: errorId,
                message: userMessage,
                context: context,
                recovery: recoverySuggestions,
                canRetry: this.isRetryableError(error, context)
            },
            internal: errorInfo // 仅用于调试
        };
    }

    /**
     * 🛠️ 生成用户友好的错误消息
     * @param {Error} error - 原始错误
     * @param {string} context - 错误上下文
     * @returns {string} 用户友好的消息
     */
    generateUserFriendlyMessage(error, context) {
        const errorMessages = {
            'file_not_found': '文件不存在，请检查路径是否正确',
            'permission_denied': '权限不足，无法访问该资源',
            'network_error': '网络连接出现问题，请检查网络设置',
            'timeout': '操作超时，请稍后重试',
            'invalid_input': '输入格式不正确，请检查参数',
            'system_busy': '系统繁忙，请稍后重试',
            'unknown': '发生未知错误，请联系技术支持'
        };

        // 根据错误类型和上下文生成消息
        let message = errorMessages.unknown;

        if (error.code === 'ENOENT') {
            message = errorMessages.file_not_found;
        } else if (error.code === 'EACCES' || error.code === 'EPERM') {
            message = errorMessages.permission_denied;
        } else if (error.code === 'ETIMEDOUT' || error.message.includes('timeout')) {
            message = errorMessages.timeout;
        } else if (error.message.includes('JSON')) {
            message = '配置文件格式错误，请检查JSON语法';
        } else if (context === 'role_initialization') {
            message = '角色系统初始化失败，但您仍可以使用基本功能';
        } else if (context === 'script_execution') {
            message = '脚本执行失败，请检查脚本文件和权限';
        }

        return message;
    }

    /**
     * 🛠️ 生成恢复建议
     * @param {Error} error - 原始错误
     * @param {string} context - 错误上下文
     * @returns {string[]} 恢复建议列表
     */
    generateRecoverySuggestions(error, context) {
        const suggestions = [];

        if (error.code === 'ENOENT') {
            suggestions.push('检查文件路径是否正确');
            suggestions.push('确认文件是否存在');
        } else if (error.code === 'EACCES') {
            suggestions.push('检查文件权限设置');
            suggestions.push('尝试以管理员身份运行');
        } else if (error.code === 'ETIMEDOUT') {
            suggestions.push('检查网络连接');
            suggestions.push('稍后重试操作');
        } else if (context === 'role_initialization') {
            suggestions.push('尝试重新加载角色配置');
            suggestions.push('检查角色配置文件格式');
        } else if (context === 'script_execution') {
            suggestions.push('检查脚本文件是否存在');
            suggestions.push('验证脚本执行权限');
            suggestions.push('查看脚本语法是否正确');
        }

        // 添加通用建议
        suggestions.push('查看详细错误日志获取更多信息');
        suggestions.push('重启应用程序后重试');

        return suggestions;
    }

    /**
     * 🛠️ 判断错误是否可以重试
     * @param {Error} error - 原始错误
     * @param {string} context - 错误上下文
     * @returns {boolean} 是否可以重试
     */
    isRetryableError(error, context) {
        // 网络错误、超时错误通常可以重试
        const retryableCodes = ['ETIMEDOUT', 'ECONNRESET', 'ECONNREFUSED', 'ENOTFOUND'];
        const retryableContexts = ['network', 'api_call', 'file_read'];

        return retryableCodes.includes(error.code) || retryableContexts.includes(context);
    }

    /**
     * 🛠️ 记录错误日志
     * @param {Object} errorInfo - 错误信息
     */
    logError(errorInfo) {
        try {
            const logDir = path.join(this.projectRoot, '.cursorGrowth', 'monitoring', 'logs');
            if (!fs.existsSync(logDir)) {
                fs.mkdirSync(logDir, { recursive: true });
            }

            const logFile = path.join(logDir, 'error-log.jsonl');
            fs.appendFileSync(logFile, JSON.stringify(errorInfo) + '\n');
        } catch (logError) {
            // 如果日志记录失败，不要抛出新错误
            console.error('❌ 错误日志记录失败:', logError.message);
        }
    }

    /**
     * 🚀 性能优化 - 带缓存的文件读取
     * @param {string} filePath - 文件路径
     * @param {string} encoding - 编码格式
     * @returns {Promise<string>} 文件内容
     */
    async readFileCached(filePath, encoding = 'utf8') {
        const cacheKey = `file_${filePath}_${encoding}`;
        const cached = this.cache.fileContents.get(cacheKey);

        // 检查缓存是否有效
        if (cached && (Date.now() - cached.timestamp) < this.cacheTTL) {
            return cached.content;
        }

        // 缓存失效或不存在，重新读取
        try {
            const content = fs.readFileSync(filePath, encoding);

            // 存储到缓存（限制缓存大小）
            if (this.cache.fileContents.size >= this.maxCacheSize) {
                this.cleanupExpiredCache();
            }

            this.cache.fileContents.set(cacheKey, {
                content: content,
                timestamp: Date.now(),
                filePath: filePath
            });

            return content;
        } catch (error) {
            throw new Error(`读取文件失败 ${filePath}: ${error.message}`);
        }
    }

    /**
     * 🚀 性能优化 - 带缓存的JSON解析
     * @param {string} filePath - JSON文件路径
     * @returns {Promise<Object>} 解析后的JSON对象
     */
    async readJsonCached(filePath) {
        const cacheKey = `json_${filePath}`;
        const cached = this.cache.fileContents.get(cacheKey);

        // 检查缓存是否有效
        if (cached && (Date.now() - cached.timestamp) < this.cacheTTL) {
            return cached.parsedJson;
        }

        // 缓存失效或不存在，先读取文件内容
        try {
            const content = await this.readFileCached(filePath, 'utf8');
            const parsedJson = JSON.parse(content);

            // 存储到缓存（限制缓存大小）
            if (this.cache.fileContents.size >= this.maxCacheSize) {
                this.cleanupExpiredCache();
            }

            this.cache.fileContents.set(cacheKey, {
                parsedJson: parsedJson,
                timestamp: Date.now(),
                filePath: filePath
            });

            return parsedJson;
        } catch (error) {
            throw new Error(`JSON解析失败 ${filePath}: ${error.message}`);
        }
    }

    /**
     * 🚀 性能优化 - 清理过期缓存
     */
    cleanupExpiredCache() {
        const now = Date.now();
        const ttl = this.cacheTTL;

        // 清理文件内容缓存
        for (const [key, value] of this.cache.fileContents.entries()) {
            if (now - value.timestamp > ttl) {
                this.cache.fileContents.delete(key);
            }
        }

        // 清理角色配置缓存
        for (const [key, value] of this.cache.roleConfig.entries()) {
            if (now - value.timestamp > ttl) {
                this.cache.roleConfig.delete(key);
            }
        }

        // 清理能力映射缓存
        for (const [key, value] of this.cache.capabilityMap.entries()) {
            if (now - value.timestamp > ttl) {
                this.cache.capabilityMap.delete(key);
            }
        }

        this.cache.lastCleanup = now;
    }

    /**
     * 🚀 性能优化 - 强制清理所有缓存
     */
    clearAllCache() {
        this.cache.fileContents.clear();
        this.cache.roleConfig.clear();
        this.cache.capabilityMap.clear();
        this.cache.lastCleanup = Date.now();
        console.log('🧹 缓存已清理');
    }

    /**
     * 🚀 性能优化 - 获取缓存统计信息
     */
    getCacheStats() {
        return {
            fileContents: {
                size: this.cache.fileContents.size,
                maxSize: this.maxCacheSize
            },
            roleConfig: {
                size: this.cache.roleConfig.size
            },
            capabilityMap: {
                size: this.cache.capabilityMap.size
            },
            lastCleanup: new Date(this.cache.lastCleanup).toISOString(),
            ttl: this.cacheTTL
        };
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
        // 对于直接运行，直接输出包装后的消息
        if (result.message) {
            console.log(result.message);
        } else if (result.output) {
            console.log(result.output);
        } else {
            console.log("操作完成");
        }
        process.exit(result.success ? 0 : 1);
    }).catch(error => {
        console.error(`❌ 执行失败: ${error.message}`);
        process.exit(1);
    });
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
        // 对于直接运行，直接输出包装后的消息
        if (result.message) {
            console.log(result.message);
        } else if (result.output) {
            console.log(result.output);
        } else {
            console.log("操作完成");
        }
        process.exit(result.success ? 0 : 1);
    }).catch(error => {
        console.error(`❌ 执行失败: ${error.message}`);
        process.exit(1);
    });
}

