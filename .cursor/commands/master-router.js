// Cursor AI Rules - Master Command Router
// 负责路由解析后的命令到对应的执行器，实现智能编排

const path = require('path');
const fs = require('fs');

class MasterCommandRouter {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');

        // 初始化组件
        this.parser = null;
        this.executor = null;

        // 路由配置
        this.routeConfig = {
            maxParallelExecutions: 3,
            defaultTimeout: 300000, // 5分钟
            retryAttempts: 2,
            intelligentScheduling: true
        };

        // 能力映射缓存
        this.capabilityCache = new Map();
        this.cacheTTL = 3600000; // 1小时
    }

    /**
     * 初始化路由器
     * @param {Object} options - 初始化选项
     */
    async initialize(options = {}) {
        // 加载解析器
        try {
            const MasterParser = require('./master-parser');
            this.parser = new MasterParser(this.projectRoot);
        } catch (error) {
            throw new Error(`无法加载解析器: ${error.message}`);
        }

        // 加载执行器
        try {
            const MasterExecutor = require('./master-executor');
            this.executor = new MasterExecutor(this.projectRoot);
        } catch (error) {
            throw new Error(`无法加载执行器: ${error.message}`);
        }

        // 应用配置选项
        Object.assign(this.routeConfig, options);

        console.log('🎯 Master路由器初始化完成');
    }

    /**
     * 处理用户输入的主入口
     * @param {string} input - 用户输入
     * @returns {Promise<Object>} 处理结果
     */
    async route(input) {
        try {
            console.log(`🎯 开始路由处理: ${input}`);

            // 1. 解析输入
            const parseResult = await this.parser.parse(input);
            console.log(`📋 解析结果: ${parseResult.type}`);

            // 2. 检查是否需要特殊处理
            if (parseResult.type === 'error') {
                return parseResult;
            }

            // 3. 路由到执行器
            const result = await this.executor.execute(parseResult);

            // 4. 后处理和学习
            await this.postProcess(input, parseResult, result);

            return result;

        } catch (error) {
            console.error('❌ 路由处理失败:', error);
            return this.createErrorResult(`路由失败: ${error.message}`);
        }
    }

    /**
     * 检查MCP工具可用性
     * @param {Object} intentAnalysis - 意图分析结果
     * @returns {Promise<Object>} MCP可用性信息
     */
    async checkMCPAvailability(intentAnalysis) {
        // 这里可以实现MCP工具检测逻辑
        // 目前返回基础结构
        return {
            hasHighPriorityTools: false,
            hasMediumPriorityTools: false,
            availableTools: [],
            recommendedTools: []
        };
    }

    /**
     * 加载能力映射配置
     * @param {string} capability - 能力名称
     * @returns {Promise<Object>} 能力配置
     */
    async loadCapabilityConfig(capability) {
        // 检查缓存
        const cacheKey = `capability_${capability}`;
        const cached = this.capabilityCache.get(cacheKey);

        if (cached && (Date.now() - cached.timestamp) < this.cacheTTL) {
            return cached.config;
        }

        // 加载配置文件
        try {
            const configPath = path.join(this.cursorDir, 'commands', 'capability-map.json');

            if (!fs.existsSync(configPath)) {
                console.warn('⚠️ 能力映射文件不存在');
                return null;
            }

            const configContent = fs.readFileSync(configPath, 'utf8');
            const config = JSON.parse(configContent);

            const capabilityConfig = config.mappings[capability];

            // 缓存结果
            this.capabilityCache.set(cacheKey, {
                config: capabilityConfig,
                timestamp: Date.now()
            });

            return capabilityConfig;

        } catch (error) {
            console.error('❌ 加载能力配置失败:', error);
            return null;
        }
    }

    /**
     * 分析执行依赖关系
     * @param {Object} capabilities - 能力集合
     * @returns {Object} 依赖图
     */
    analyzeDependencies(capabilities) {
        const dependencyGraph = {
            nodes: [],
            edges: []
        };

        // 分析规则依赖
        if (capabilities.rules) {
            capabilities.rules.forEach(rule => {
                dependencyGraph.nodes.push({
                    id: `rule_${rule}`,
                    type: 'rule',
                    name: rule,
                    dependencies: []
                });
            });
        }

        // 分析脚本依赖
        if (capabilities.scripts) {
            capabilities.scripts.forEach(script => {
                dependencyGraph.nodes.push({
                    id: `script_${script}`,
                    type: 'script',
                    name: script,
                    dependencies: this.getScriptDependencies(script)
                });
            });
        }

        // 分析技能依赖
        if (capabilities.skills) {
            capabilities.skills.forEach(skill => {
                const skillDeps = this.getSkillDependencies(skill);
                dependencyGraph.nodes.push({
                    id: `skill_${skill}`,
                    type: 'skill',
                    name: skill,
                    dependencies: skillDeps
                });
            });
        }

        // 构建依赖边
        this.buildDependencyEdges(dependencyGraph);

        return dependencyGraph;
    }

    /**
     * 获取脚本依赖
     * @param {string} scriptName - 脚本名称
     * @returns {string[]} 依赖列表
     */
    getScriptDependencies(scriptName) {
        // 这里可以实现更复杂的依赖分析
        // 目前返回基础依赖
        const dependencies = [];

        // 某些脚本可能依赖环境感知
        if (scriptName.includes('quality') || scriptName.includes('analysis')) {
            dependencies.push('env-perception.sh');
        }

        return dependencies;
    }

    /**
     * 获取技能依赖
     * @param {string} skillName - 技能名称
     * @returns {string[]} 依赖列表
     */
    getSkillDependencies(skillName) {
        // 这里可以实现技能依赖分析
        // 目前返回空数组
        return [];
    }

    /**
     * 构建依赖边
     * @param {Object} graph - 依赖图
     */
    buildDependencyEdges(graph) {
        // 为每个节点建立依赖关系
        graph.nodes.forEach(node => {
            node.dependencies.forEach(dep => {
                // 查找依赖节点
                const depNode = graph.nodes.find(n => n.name === dep);
                if (depNode) {
                    graph.edges.push({
                        from: depNode.id,
                        to: node.id,
                        type: 'depends_on'
                    });
                }
            });
        });
    }

    /**
     * 规划执行顺序
     * @param {Object} capabilities - 能力集合
     * @param {Object} dependencies - 依赖关系
     * @returns {string[]} 执行顺序
     */
    planExecutionOrder(capabilities, dependencies) {
        // 基于依赖关系进行拓扑排序
        const executionOrder = [];
        const visited = new Set();
        const visiting = new Set();

        const visit = (nodeId) => {
            if (visited.has(nodeId)) return;
            if (visiting.has(nodeId)) {
                console.warn(`⚠️ 检测到循环依赖: ${nodeId}`);
                return;
            }

            visiting.add(nodeId);

            // 访问依赖
            const node = dependencies.nodes.find(n => n.id === nodeId);
            if (node) {
                node.dependencies.forEach(dep => {
                    const depNode = dependencies.nodes.find(n => n.name === dep);
                    if (depNode) {
                        visit(depNode.id);
                    }
                });
            }

            visiting.delete(nodeId);
            visited.add(nodeId);
            executionOrder.push(nodeId);
        };

        // 访问所有节点
        dependencies.nodes.forEach(node => {
            if (!visited.has(node.id)) {
                visit(node.id);
            }
        });

        return executionOrder;
    }

    /**
     * 后处理和学习
     * @param {string} input - 原始输入
     * @param {Object} parseResult - 解析结果
     * @param {Object} executionResult - 执行结果
     */
    async postProcess(input, parseResult, executionResult) {
        try {
            // 记录执行历史
            await this.recordExecutionHistory({
                input,
                parseResult,
                executionResult,
                timestamp: new Date().toISOString()
            });

            // 分析执行模式（用于学习和优化）
            if (executionResult.success) {
                await this.analyzeSuccessPatterns(parseResult, executionResult);
            } else {
                await this.analyzeFailurePatterns(parseResult, executionResult);
            }

            // 清理缓存
            this.cleanupExpiredCache();

        } catch (error) {
            console.warn('⚠️ 后处理失败:', error.message);
        }
    }

    /**
     * 记录执行历史
     * @param {Object} record - 执行记录
     */
    async recordExecutionHistory(record) {
        try {
            const historyDir = path.join(this.projectRoot, '.cursorGrowth', 'monitoring', 'logs');
            if (!fs.existsSync(historyDir)) {
                fs.mkdirSync(historyDir, { recursive: true });
            }

            const historyFile = path.join(historyDir, 'execution-history.jsonl');

            fs.appendFileSync(historyFile, JSON.stringify(record) + '\n');
        } catch (error) {
            console.warn('⚠️ 历史记录失败:', error.message);
        }
    }

    /**
     * 分析成功模式
     * @param {Object} parseResult - 解析结果
     * @param {Object} executionResult - 执行结果
     */
    async analyzeSuccessPatterns(parseResult, executionResult) {
        // 这里可以实现成功模式分析，用于优化路由决策
        console.log('✅ 成功模式分析完成');
    }

    /**
     * 分析失败模式
     * @param {Object} parseResult - 解析结果
     * @param {Object} executionResult - 执行结果
     */
    async analyzeFailurePatterns(parseResult, executionResult) {
        // 这里可以实现失败模式分析，用于改进错误处理
        console.log('❌ 失败模式分析完成');
    }

    /**
     * 清理过期缓存
     */
    cleanupExpiredCache() {
        const now = Date.now();
        for (const [key, value] of this.capabilityCache.entries()) {
            if (now - value.timestamp > this.cacheTTL) {
                this.capabilityCache.delete(key);
            }
        }
    }

    /**
     * 获取路由器统计信息
     * @returns {Object} 统计信息
     */
    getStats() {
        return {
            cacheSize: this.capabilityCache.size,
            parserLoaded: !!this.parser,
            executorLoaded: !!this.executor,
            routeConfig: this.routeConfig,
            uptime: process.uptime()
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
            timestamp: new Date().toISOString(),
            router: 'master-router'
        };
    }
}

// 导出类
module.exports = MasterCommandRouter;

// 测试函数
async function testRouter() {
    console.log('🧪 测试Master Command Router...\n');

    const router = new MasterCommandRouter(process.cwd());

    try {
        // 初始化
        await router.initialize();
        console.log('✅ 路由器初始化成功');

        // 测试路由
        const testInputs = [
            'rule constitution',
            'script init.sh',
            '我想创建一个React项目',
            '优化代码性能'
        ];

        for (const input of testInputs) {
            console.log(`\n📋 测试输入: "${input}"`);
            try {
                const result = await router.route(input);
                console.log(`   结果: ${result.success ? '✅ 成功' : '❌ 失败'}`);
                if (!result.success) {
                    console.log(`   错误: ${result.error}`);
                }
            } catch (error) {
                console.log(`   异常: ${error.message}`);
            }
        }

        console.log('\n📊 路由器统计:', router.getStats());

    } catch (error) {
        console.error('❌ 测试失败:', error);
    }
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.includes('--test')) {
        testRouter().catch(console.error);
    } else if (args.length > 0) {
        (async () => {
            const router = new MasterCommandRouter(process.cwd());
            await router.initialize();

            const input = args.join(' ');
            const result = await router.route(input);

            console.log(JSON.stringify(result, null, 2));
        })().catch(console.error);
    } else {
        console.log('用法:');
        console.log('  node master-router.js <输入>    # 路由处理输入');
        console.log('  node master-router.js --test    # 运行测试');
    }
}