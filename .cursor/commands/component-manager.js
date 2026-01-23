// Cursor AI Rules - 组件管理器
// 负责管理Master系统的各个组件，实现解耦和插件化架构

const path = require('path');
const fs = require('fs');
const { global: cacheManager } = require('../core/cache-manager');

class ComponentManager {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');
        this.components = new Map();
        this.dependencies = new Map();
        this.healthStatus = new Map();
        this.eventListeners = new Map();

        // 插件目录
        this.pluginsDir = path.join(this.cursorDir, 'plugins');
        this.builtinComponentsDir = path.join(this.cursorDir, 'commands');

        // 插件注册表 - 支持动态发现
        this.componentRegistry = new Map();
        this.discoveredPlugins = new Map();
        this.pluginConfigs = new Map();

        // 服务注册表 - 用于松耦合的服务发现
        this.services = new Map();

        // 🚀 全局缓存管理器 - 性能优化
        this.cache = cacheManager.getCache('components', { maxSize: 200, ttl: 600000 }); // 200项，10分钟TTL

        // 内置核心组件
        this.registerBuiltinComponents();

        // 自动发现插件
        this.discoverPlugins();
    }

    /**
     * 注册内置核心组件
     */
    registerBuiltinComponents() {
        const builtinComponents = {
            parser: {
                module: './master-parser',
                dependencies: [],
                singleton: true,
                type: 'builtin',
                priority: 100,
                services: ['intent-parser', 'command-parser']
            },
            router: {
                module: './master-router',
                dependencies: [],
                singleton: true,
                type: 'builtin',
                priority: 90,
                services: ['command-router', 'intent-router']
            },
            executor: {
                module: './master-executor',
                dependencies: [],
                singleton: true,
                type: 'builtin',
                priority: 80,
                services: ['command-executor', 'task-executor']
            },
            roleManager: {
                module: './role-manager',
                dependencies: [],
                singleton: true,
                type: 'builtin',
                priority: 70,
                services: ['role-management', 'personality-system']
            },
            responseInterceptor: {
                module: '../core/response-interceptor',
                dependencies: [],
                singleton: true,
                type: 'builtin',
                priority: 60,
                services: ['response-filter', 'content-moderation']
            }
        };

        Object.entries(builtinComponents).forEach(([name, config]) => {
            this.componentRegistry.set(name, config);
        });
    }

    /**
     * 自动发现插件
     */
    discoverPlugins() {
        try {
            // 确保插件目录存在
            if (!fs.existsSync(this.pluginsDir)) {
                fs.mkdirSync(this.pluginsDir, { recursive: true });
                console.log(`📁 创建插件目录: ${this.pluginsDir}`);
                return;
            }

            const pluginDirs = fs.readdirSync(this.pluginsDir, { withFileTypes: true })
                .filter(dirent => dirent.isDirectory())
                .map(dirent => dirent.name);

            for (const pluginName of pluginDirs) {
                this.loadPluginManifest(pluginName);
            }

            console.log(`🔍 发现 ${this.discoveredPlugins.size} 个插件`);
        } catch (error) {
            console.warn(`⚠️ 插件发现失败: ${error.message}`);
        }
    }

    /**
     * 加载插件清单
     * @param {string} pluginName - 插件名称
     */
    loadPluginManifest(pluginName) {
        const pluginDir = path.join(this.pluginsDir, pluginName);
        const manifestPath = path.join(pluginDir, 'manifest.json');

        try {
            if (!fs.existsSync(manifestPath)) {
                console.warn(`⚠️ 插件 ${pluginName} 缺少 manifest.json 文件`);
                return;
            }

            const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

            // 验证清单格式
            if (!this.validatePluginManifest(manifest)) {
                console.warn(`⚠️ 插件 ${pluginName} 清单格式无效`);
                return;
            }

            // 注册插件组件
            manifest.components.forEach(component => {
                const componentName = `${pluginName}.${component.name}`;
                this.componentRegistry.set(componentName, {
                    ...component,
                    module: path.join(pluginDir, component.module),
                    plugin: pluginName,
                    type: 'plugin',
                    priority: manifest.priority || 50
                });
            });

            this.discoveredPlugins.set(pluginName, manifest);
            console.log(`📦 加载插件: ${pluginName} (${manifest.components.length} 个组件)`);

        } catch (error) {
            console.warn(`⚠️ 加载插件 ${pluginName} 失败: ${error.message}`);
        }
    }

    /**
     * 验证插件清单
     * @param {Object} manifest - 插件清单
     * @returns {boolean} 是否有效
     */
    validatePluginManifest(manifest) {
        return manifest &&
            typeof manifest.name === 'string' &&
            typeof manifest.version === 'string' &&
            Array.isArray(manifest.components) &&
            manifest.components.every(comp =>
                comp.name && comp.module && comp.description
            );
    }

    /**
     * 注册组件
     * @param {string} name - 组件名称
     * @param {Object} config - 组件配置
     */
    registerComponent(name, config) {
        this.componentRegistry.set(name, {
            ...config,
            singleton: config.singleton !== false, // 默认单例模式
            type: config.type || 'custom',
            priority: config.priority || 0,
            services: config.services || [] // 组件提供的服务列表
        });
        console.log(`📦 注册组件: ${name} (${config.type || 'custom'})`);
    }

    /**
     * 注册服务 - 松耦合的服务发现机制
     * @param {string} serviceName - 服务名称
     * @param {string} componentName - 提供服务的组件名
     * @param {Object} serviceInfo - 服务信息
     */
    registerService(serviceName, componentName, serviceInfo = {}) {
        if (!this.services.has(serviceName)) {
            this.services.set(serviceName, []);
        }

        // 检查是否已注册相同组件的服务
        const existingServices = this.services.get(serviceName);
        const existingIndex = existingServices.findIndex(s => s.component === componentName);

        if (existingIndex >= 0) {
            // 更新现有服务
            existingServices[existingIndex] = {
                component: componentName,
                info: serviceInfo,
                registeredAt: Date.now()
            };
        } else {
            // 添加新服务
            existingServices.push({
                component: componentName,
                info: serviceInfo,
                registeredAt: Date.now()
            });
        }

        // 按优先级排序（如果有的话）
        existingServices.sort((a, b) => (b.info.priority || 0) - (a.info.priority || 0));

        console.log(`🔗 注册服务: ${serviceName} (由 ${componentName} 提供)`);
    }

    /**
     * 发现服务 - 按需发现可用服务
     * @param {string} serviceName - 服务名称
     * @param {Object} criteria - 筛选条件
     * @returns {Array} 匹配的服务列表
     */
    discoverServices(serviceName, criteria = {}) {
        const services = this.services.get(serviceName) || [];

        if (Object.keys(criteria).length === 0) {
            return services;
        }

        // 根据条件筛选服务
        return services.filter(service => {
            for (const [key, value] of Object.entries(criteria)) {
                if (service.info[key] !== value) {
                    return false;
                }
            }
            return true;
        });
    }

    /**
     * 获取服务实例 - 自动加载组件并返回服务
     * @param {string} serviceName - 服务名称
     * @param {Object} criteria - 服务筛选条件
     * @returns {Promise<Object>} 服务实例
     */
    async getService(serviceName, criteria = {}) {
        const services = this.discoverServices(serviceName, criteria);

        if (services.length === 0) {
            throw new Error(`服务未找到: ${serviceName}`);
        }

        // 使用第一个匹配的服务（已按优先级排序）
        const service = services[0];
        const component = await this.getComponent(service.component);

        // 如果组件有getService方法，使用它，否则返回组件本身
        if (typeof component.getService === 'function') {
            return await component.getService(serviceName, criteria);
        }

        return component;
    }

    /**
     * 启用插件
     * @param {string} pluginName - 插件名称
     */
    enablePlugin(pluginName) {
        if (!this.discoveredPlugins.has(pluginName)) {
            throw new Error(`插件未发现: ${pluginName}`);
        }

        const config = this.pluginConfigs.get(pluginName) || {};
        config.enabled = true;
        this.pluginConfigs.set(pluginName, config);

        console.log(`✅ 启用插件: ${pluginName}`);
    }

    /**
     * 禁用插件
     * @param {string} pluginName - 插件名称
     */
    disablePlugin(pluginName) {
        const config = this.pluginConfigs.get(pluginName) || {};
        config.enabled = false;
        this.pluginConfigs.set(pluginName, config);

        // 清理已加载的插件组件
        this.unloadPluginComponents(pluginName);

        console.log(`⏸️ 禁用插件: ${pluginName}`);
    }

    /**
     * 卸载插件组件
     * @param {string} pluginName - 插件名称
     */
    unloadPluginComponents(pluginName) {
        for (const [componentName, config] of this.componentRegistry.entries()) {
            if (config.plugin === pluginName && this.components.has(componentName)) {
                this.components.delete(componentName);
                this.healthStatus.delete(componentName);
                console.log(`🗑️ 卸载组件: ${componentName}`);
            }
        }
    }

    /**
     * 检查插件是否启用
     * @param {string} pluginName - 插件名称
     * @returns {boolean} 是否启用
     */
    isPluginEnabled(pluginName) {
        const config = this.pluginConfigs.get(pluginName);
        return config ? config.enabled !== false : true; // 默认启用
    }

    /**
     * 获取组件实例
     * @param {string} name - 组件名称
     * @param {Object} options - 创建选项
     * @returns {Promise<Object>} 组件实例
     */
    async getComponent(name, options = {}) {
        const registry = this.componentRegistry.get(name);
        if (!registry) {
            throw new Error(`组件未注册: ${name}`);
        }

        // 检查插件是否启用
        if (registry.plugin && !this.isPluginEnabled(registry.plugin)) {
            throw new Error(`插件未启用: ${registry.plugin}`);
        }

        // 检查依赖
        await this.ensureDependencies(name);

        // 🚀 缓存优化 - 检查组件缓存
        const cacheKey = `component:${name}`;
        const cachedComponent = this.cache.get(cacheKey);

        if (cachedComponent && registry.singleton && this.isHealthy(name)) {
            console.log(`💾 从缓存加载组件: ${name}`);
            return cachedComponent;
        }

        // 单例模式
        if (registry.singleton && this.components.has(name)) {
            const component = this.components.get(name);
            if (this.isHealthy(name)) {
                // 添加到LRU缓存
                this.lruCache.set(cacheKey, component);
                return component;
            } else {
                // 不健康则重新创建
                console.warn(`⚠️ 组件 ${name} 不健康，重新创建`);
                this.components.delete(name);
                this.cache.delete(cacheKey);
            }
        }

        // 创建新实例
        try {
            const component = await this.createComponent(name, options);
            if (registry.singleton) {
                this.components.set(name, component);
                // 🚀 添加到缓存
                this.cache.set(`component:${name}`, component);
            }
            this.updateHealthStatus(name, 'healthy');
            return component;
        } catch (error) {
            this.updateHealthStatus(name, 'failed', error.message);
            throw error;
        }
    }

    /**
     * 确保依赖组件已创建
     * @param {string} name - 组件名称
     */
    async ensureDependencies(name) {
        const registry = this.componentRegistry.get(name);
        if (!registry || !registry.dependencies) {
            return;
        }

        for (const dep of registry.dependencies) {
            if (!this.components.has(dep) || !this.isHealthy(dep)) {
                await this.getComponent(dep);
            }
        }
    }

    /**
     * 创建组件实例
     * @param {string} name - 组件名称
     * @param {Object} options - 创建选项
     * @returns {Promise<Object>} 组件实例
     */
    async createComponent(name, options = {}) {
        const registry = this.componentRegistry.get(name);
        if (!registry) {
            throw new Error(`组件配置不存在: ${name}`);
        }

        try {
            // 动态加载模块
            let ComponentClass;
            try {
                const modulePath = registry.module;
                ComponentClass = require(modulePath);
            } catch (error) {
                // 如果相对路径失败，尝试绝对路径
                const absolutePath = path.resolve(this.cursorDir, 'commands', registry.module);
                ComponentClass = require(absolutePath);
            }

            // 处理不同的模块导出格式
            let Constructor;
            if (typeof ComponentClass === 'function') {
                Constructor = ComponentClass;
            } else if (ComponentClass.default) {
                Constructor = ComponentClass.default;
            } else {
                // 如果是对象，寻找可能的构造函数
                const keys = Object.keys(ComponentClass);
                const possibleConstructor = keys.find(key => key.endsWith('Parser') || key.endsWith('Router') || key.endsWith('Executor') || key.endsWith('Manager'));
                if (possibleConstructor) {
                    Constructor = ComponentClass[possibleConstructor];
                } else {
                    throw new Error(`无法确定组件 ${name} 的构造函数`);
                }
            }

            // 创建实例
            const instance = new Constructor(this.projectRoot, options);

            // 如果组件有initialize方法，调用它
            if (typeof instance.initialize === 'function') {
                await instance.initialize();
            }

            // 自动注册组件提供的服务
            if (registry.services && registry.services.length > 0) {
                for (const serviceName of registry.services) {
                    this.registerService(serviceName, name, {
                        version: instance.version || '1.0.0',
                        priority: registry.priority || 0,
                        capabilities: instance.capabilities || []
                    });
                }
            }

            console.log(`✅ 组件 ${name} 创建成功`);
            return instance;

        } catch (error) {
            console.error(`❌ 创建组件 ${name} 失败:`, error.message);
            throw error;
        }
    }

    /**
     * 检查组件健康状态
     * @param {string} name - 组件名称
     * @returns {boolean} 是否健康
     */
    isHealthy(name) {
        const status = this.healthStatus.get(name);
        return status && status.state === 'healthy';
    }

    /**
     * 更新组件健康状态
     * @param {string} name - 组件名称
     * @param {string} state - 状态
     * @param {string} error - 错误信息
     */
    updateHealthStatus(name, state, error = null) {
        this.healthStatus.set(name, {
            state,
            error,
            timestamp: new Date().toISOString(),
            lastChecked: Date.now()
        });

        // 触发健康状态变更事件
        this.emitEvent('healthChanged', { name, state, error });
    }

    /**
     * 获取所有组件的健康状态
     * @returns {Object} 健康状态报告
     */
    getHealthReport() {
        const report = {
            timestamp: new Date().toISOString(),
            components: {},
            overall: 'healthy'
        };

        let hasIssues = false;
        for (const [name, status] of this.healthStatus.entries()) {
            report.components[name] = status;
            if (status.state !== 'healthy') {
                hasIssues = true;
            }
        }

        if (hasIssues) {
            report.overall = 'degraded';
        }

        return report;
    }

    /**
     * 重新加载组件
     * @param {string} name - 组件名称
     */
    async reloadComponent(name) {
        console.log(`🔄 重新加载组件: ${name}`);

        // 清理现有实例
        if (this.components.has(name)) {
            this.components.delete(name);
        }

        // 清除缓存（如果有的话）
        try {
            const registry = this.componentRegistry.get(name);
            if (registry) {
                delete require.cache[require.resolve(registry.module)];
            }
        } catch (error) {
            // 忽略缓存清理错误
        }

        // 重新创建组件
        return await this.getComponent(name);
    }

    /**
     * 批量初始化核心组件
     * @returns {Promise<Object>} 初始化结果
     */
    async initializeCoreComponents() {
        console.log('🏗️ 初始化核心组件...');

        const coreComponents = ['parser', 'router', 'executor'];
        const results = {};

        for (const name of coreComponents) {
            try {
                results[name] = await this.getComponent(name);
                console.log(`✅ 核心组件 ${name} 初始化成功`);
            } catch (error) {
                console.error(`❌ 核心组件 ${name} 初始化失败:`, error.message);
                results[name] = null;
            }
        }

        return results;
    }

    /**
     * 事件系统 - 添加事件监听器
     * @param {string} event - 事件名称
     * @param {Function} callback - 回调函数
     */
    on(event, callback) {
        if (!this.eventListeners.has(event)) {
            this.eventListeners.set(event, []);
        }
        this.eventListeners.get(event).push(callback);
    }

    /**
     * 事件系统 - 触发事件
     * @param {string} event - 事件名称
     * @param {Object} data - 事件数据
     */
    emitEvent(event, data) {
        const listeners = this.eventListeners.get(event);
        if (listeners) {
            listeners.forEach(callback => {
                try {
                    callback(data);
                } catch (error) {
                    console.error(`事件监听器错误 (${event}):`, error.message);
                }
            });
        }
    }

    /**
     * 清理资源
     */
    cleanup() {
        console.log('🧹 清理组件管理器资源...');

        // 清理组件实例
        this.components.clear();
        this.healthStatus.clear();
        this.eventListeners.clear();

        console.log('✅ 组件管理器资源已清理');
    }

    /**
     * 分析依赖关系
     * @returns {Object} 依赖关系分析结果
     */
    analyzeDependencies() {
        const analysis = {
            components: {},
            cycles: [],
            orphans: [],
            stronglyConnected: [],
            dependencyDepth: {},
            reverseDependencies: new Map()
        };

        // 构建依赖图
        for (const [name, config] of this.componentRegistry.entries()) {
            analysis.components[name] = {
                dependencies: config.dependencies || [],
                type: config.type,
                plugin: config.plugin
            };

            // 构建反向依赖图
            for (const dep of (config.dependencies || [])) {
                if (!analysis.reverseDependencies.has(dep)) {
                    analysis.reverseDependencies.set(dep, []);
                }
                analysis.reverseDependencies.get(dep).push(name);
            }
        }

        // 检测循环依赖
        analysis.cycles = this.detectCycles();

        // 查找孤立组件（无依赖也无被依赖）
        for (const [name, info] of Object.entries(analysis.components)) {
            const hasDeps = info.dependencies.length > 0;
            const isDepended = analysis.reverseDependencies.has(name) &&
                analysis.reverseDependencies.get(name).length > 0;

            if (!hasDeps && !isDepended) {
                analysis.orphans.push(name);
            }
        }

        // 计算依赖深度
        analysis.dependencyDepth = this.calculateDependencyDepth();

        return analysis;
    }

    /**
     * 检测循环依赖
     * @returns {Array} 循环依赖列表
     */
    detectCycles() {
        const cycles = [];
        const visited = new Set();
        const recursionStack = new Set();

        const visit = (name, path = []) => {
            if (recursionStack.has(name)) {
                // 找到循环
                const cycleStart = path.indexOf(name);
                cycles.push(path.slice(cycleStart).concat(name));
                return;
            }

            if (visited.has(name)) {
                return;
            }

            visited.add(name);
            recursionStack.add(name);

            const config = this.componentRegistry.get(name);
            if (config && config.dependencies) {
                for (const dep of config.dependencies) {
                    visit(dep, [...path, name]);
                }
            }

            recursionStack.delete(name);
        };

        for (const name of this.componentRegistry.keys()) {
            if (!visited.has(name)) {
                visit(name);
            }
        }

        return cycles;
    }

    /**
     * 计算依赖深度
     * @returns {Object} 各组件的依赖深度
     */
    calculateDependencyDepth() {
        const depths = {};
        const calculateDepth = (name, visited = new Set()) => {
            if (visited.has(name)) {
                return 0; // 避免循环
            }

            if (depths[name] !== undefined) {
                return depths[name];
            }

            const config = this.componentRegistry.get(name);
            if (!config || !config.dependencies || config.dependencies.length === 0) {
                return depths[name] = 0;
            }

            visited.add(name);
            let maxDepth = 0;

            for (const dep of config.dependencies) {
                const depDepth = calculateDepth(dep, visited);
                maxDepth = Math.max(maxDepth, depDepth);
            }

            visited.delete(name);
            return depths[name] = maxDepth + 1;
        };

        for (const name of this.componentRegistry.keys()) {
            calculateDepth(name);
        }

        return depths;
    }

    /**
     * 优化依赖关系 - 移除不必要的依赖
     */
    optimizeDependencies() {
        console.log('🔧 优化组件依赖关系...');

        const analysis = this.analyzeDependencies();

        // 报告循环依赖
        if (analysis.cycles.length > 0) {
            console.warn('⚠️ 检测到循环依赖:');
            analysis.cycles.forEach((cycle, index) => {
                console.warn(`  ${index + 1}. ${cycle.join(' → ')}`);
            });
        }

        // 报告孤立组件
        if (analysis.orphans.length > 0) {
            console.log('📋 孤立组件 (可考虑移除或集成):');
            analysis.orphans.forEach(orphan => {
                console.log(`  - ${orphan}`);
            });
        }

        // 建议优化：移除传递性依赖
        const optimizations = this.findTransitiveDependencies();

        if (optimizations.length > 0) {
            console.log('💡 建议移除的传递性依赖:');
            optimizations.forEach(opt => {
                console.log(`  - ${opt.component}: 可移除对 ${opt.dependency} 的直接依赖`);
            });
        }

        return {
            cycles: analysis.cycles,
            orphans: analysis.orphans,
            optimizations,
            dependencyDepth: analysis.dependencyDepth
        };
    }

    /**
     * 查找传递性依赖
     * @returns {Array} 可移除的传递性依赖
     */
    findTransitiveDependencies() {
        const optimizations = [];
        const analysis = this.analyzeDependencies();

        for (const [name, info] of Object.entries(analysis.components)) {
            for (const directDep of info.dependencies) {
                // 检查是否存在更短的路径
                const depth = analysis.dependencyDepth[directDep] || 0;

                // 如果通过其他路径也能到达，且深度相同或更短，则可能是传递性依赖
                for (const otherDep of info.dependencies) {
                    if (otherDep !== directDep) {
                        const otherDepth = analysis.dependencyDepth[otherDep] || 0;
                        const directDepth = analysis.dependencyDepth[directDep] || 0;

                        if (otherDepth >= directDepth &&
                            this.hasPath(otherDep, directDep, analysis)) {
                            optimizations.push({
                                component: name,
                                dependency: directDep,
                                reason: `通过 ${otherDep} 可以间接依赖`
                            });
                        }
                    }
                }
            }
        }

        return optimizations;
    }

    /**
     * 检查是否存在从from到to的路径
     * @param {string} from - 起始组件
     * @param {string} to - 目标组件
     * @param {Object} analysis - 依赖分析结果
     * @returns {boolean} 是否存在路径
     */
    hasPath(from, to, analysis) {
        const visited = new Set();

        const dfs = (current) => {
            if (current === to) {
                return true;
            }

            if (visited.has(current)) {
                return false;
            }

            visited.add(current);

            const info = analysis.components[current];
            if (info && info.dependencies) {
                for (const dep of info.dependencies) {
                    if (dfs(dep)) {
                        return true;
                    }
                }
            }

            return false;
        };

        return dfs(from);
    }

    /**
     * 获取组件统计信息
     * @returns {Object} 统计信息
     */
    getStats() {
        const componentTypes = {
            builtin: 0,
            plugin: 0,
            custom: 0
        };

        for (const config of this.componentRegistry.values()) {
            componentTypes[config.type] = (componentTypes[config.type] || 0) + 1;
        }

        return {
            registeredComponents: this.componentRegistry.size,
            loadedComponents: this.components.size,
            healthyComponents: Array.from(this.healthStatus.values()).filter(s => s.state === 'healthy').length,
            failedComponents: Array.from(this.healthStatus.values()).filter(s => s.state === 'failed').length,
            componentTypes,
            enabledPlugins: Array.from(this.pluginConfigs.values()).filter(c => c.enabled !== false).length,
            totalPlugins: this.discoveredPlugins.size,
            cache: this.cache.getStats()
        };
    }
}

// 导出类
module.exports = ComponentManager;