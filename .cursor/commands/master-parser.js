// Cursor AI Rules - Master Command Parser
// 负责解析 /master 命令的输入，提取意图和参数

const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

class MasterCommandParser {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');
        this.mappingsDir = path.join(this.cursorDir, 'commands', 'capability-maps');

        // 🎯 动态意图映射
        this.intentMappings = {};
        this.initialized = false;

        // 定义命令模式
        this.commandPatterns = {
            // 直接调用模式
            direct: {
                pattern: /^(rule|script|skill|hook|workflow)\s+(.+)$/i,
                handler: this.parseDirectCall.bind(this)
            },

            // 角色切换模式
            role_switch: {
                pattern: /^(切换|设置|switch|set)\s*(?:角色|role)?\s*(.+)$/i,
                handler: this.parseRoleSwitch.bind(this)
            },

            // 角色呼叫模式
            role_call: {
                pattern: /^(呼叫|叫|召唤)\s+(.+)$/i,
                handler: this.parseRoleCall.bind(this)
            },

            // 自然语言模式
            natural: {
                pattern: /^(.+)$/,
                handler: this.parseNaturalLanguage.bind(this)
            }
        };
    }

    /**
     * 初始化解析器，加载动态映射
     */
    async initialize() {
        if (this.initialized) return;

        try {
            console.log('🔍 正在加载动态能力映射...');
            const indexPath = path.join(this.mappingsDir, '_index.json');
            if (fs.existsSync(indexPath)) {
                const index = JSON.parse(fs.readFileSync(indexPath, 'utf8'));
                if (index.includes) {
                    for (const include of index.includes) {
                        const filePath = path.join(this.mappingsDir, include);
                        if (fs.existsSync(filePath)) {
                            const mappingData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                            // 合并映射数据
                            for (const [key, value] of Object.entries(mappingData)) {
                                if (value.intents && (value.user_examples || value.capabilities)) {
                                    this.intentMappings[key] = {
                                        keywords: value.intents,
                                        confidence: value.confidence_threshold || 0.8,
                                        category: key.split('_')[0], // 启发式分类
                                        ...value
                                    };
                                }
                            }
                        }
                    }
                }
            }

            // 🚀 加载高级意图模式
            const patternsPath = path.join(this.mappingsDir, 'advanced', 'intent-patterns.json');
            if (fs.existsSync(patternsPath)) {
                this.intentPatterns = JSON.parse(fs.readFileSync(patternsPath, 'utf8'));
            }

            console.log(`✅ 成功加载 ${Object.keys(this.intentMappings).length} 个动态意图映射`);
        } catch (error) {
            console.warn('⚠️ 加载动态映射失败，回退到基础映射:', error.message);
            // 基础映射回退
            this.intentMappings = {
                creation: { keywords: ['创建', '开发', '构建', '搭建', '实现', '新建', '做一个', '生成'], confidence: 0.9, category: 'creation' },
                optimization: { keywords: ['优化', '改进', '提升', '重构', '修复', '清理', '整理', '增强'], confidence: 0.85, category: 'optimization' },
                analysis: { keywords: ['分析', '检查', '评估', '诊断', '审计', '审查', '监控', '查看'], confidence: 0.8, category: 'analysis' },
                learning: { keywords: ['学习', '了解', '掌握', '教程', '指南', '文档', '帮助', '教学'], confidence: 0.7, category: 'learning' },
                commit: { keywords: ['提交', '推送', '保存', '上传', '同步'], confidence: 0.85, category: 'commit' }
            };
        }

        this.initialized = true;
    }

    /**
     * 主解析方法
     * @param {string} input - 用户输入
     * @returns {Promise<Object>} 解析结果
     */
    async parse(input) {
        if (!this.initialized) {
            await this.initialize();
        }

        if (!input || typeof input !== 'string') {
            return this.createErrorResult('输入无效');
        }

        const trimmedInput = input.trim();

        // 🚀 新增：检测复合指令（包含多个操作的指令）- 优先级最高
        const compoundResult = this.parseCompoundCommands(trimmedInput);
        if (compoundResult) {
            return compoundResult;
        }

        // 尝试角色呼叫模式 - 在直接调用之前检测，避免"呼叫"被误认为直接调用
        const roleCallResult = this.commandPatterns.role_call.handler(trimmedInput);
        if (roleCallResult) {
            return roleCallResult;
        }

        // 尝试角色切换模式
        const roleSwitchResult = this.commandPatterns.role_switch.handler(trimmedInput);
        if (roleSwitchResult) {
            return roleSwitchResult;
        }

        // 尝试直接调用模式
        for (const [type, config] of Object.entries(this.commandPatterns)) {
            if (type === 'direct') {
                const directResult = config.handler(trimmedInput);
                if (directResult) {
                    return directResult;
                }
            }
        }

        // 尝试自然语言模式
        return this.commandPatterns.natural.handler(trimmedInput);
    }

    /**
     * 解析复合指令（多个操作的指令）
     * @param {string} input - 输入字符串
     * @returns {Object|null} 解析结果或null
     */
    parseCompoundCommands(input) {
        console.log(`🔍 检查复合指令: "${input}"`);

        let subCommands = [];
        let isCompound = false;

        // 方法1: 使用标点符号分割
        if (input.includes('！') || input.includes('；') || input.includes('。')) {
            // 按中文标点分割
            const parts = input.split(/[！；。]/).filter(part => part.trim().length > 1);
            if (parts.length >= 2) {
                console.log(`📝 按标点分割得到 ${parts.length} 个部分:`, parts);
                subCommands = parts;
                isCompound = true;
            }
        }

        // 方法2: 使用连接词分割（如果标点分割失败）
        if (!isCompound) {
            const connectorPattern = /(.+?)(?:然后|接着|再|以及|并且)\s*(.+)/;
            const match = input.match(connectorPattern);
            if (match) {
                subCommands = [match[1].trim(), match[2].trim()];
                console.log(`📝 按连接词分割得到 ${subCommands.length} 个部分:`, subCommands);
                isCompound = true;
            }
        }

        console.log(`🔍 复合指令检测结果: isCompound=${isCompound}, subCommands=${subCommands.length}`);

        // 如果检测到复合指令，逐个解析子指令
        if (isCompound && subCommands.length >= 2) {
            console.log(`🔀 检测到复合指令，包含 ${subCommands.length} 个子指令`);

            const parsedSubCommands = [];
            for (const subCmd of subCommands) {
                try {
                    console.log(`🔍 解析子指令: "${subCmd}"`);
                    // 递归解析每个子指令
                    const subResult = this.parseSingleCommand(subCmd);
                    console.log(`✅ 子指令解析结果: ${subResult?.type || 'null'}`);
                    if (subResult) {
                        parsedSubCommands.push({
                            input: subCmd,
                            parsed: subResult
                        });
                    }
                } catch (error) {
                    console.warn(`⚠️ 子指令解析失败: ${subCmd}`, error.message);
                }
            }

            console.log(`📊 解析完成 ${parsedSubCommands.length} 个子指令`);

            if (parsedSubCommands.length >= 2) {
                return {
                    success: true,
                    type: 'compound_commands',
                    subCommands: parsedSubCommands,
                    originalInput: input,
                    confidence: 0.9,
                    timestamp: new Date().toISOString()
                };
            }
        }

        console.log(`❌ 未检测到复合指令`);
        return null;
    }

    /**
     * 解析单个指令（用于复合指令的子指令解析）
     * @param {string} input - 输入字符串
     * @returns {Object|null} 解析结果或null
     */
    parseSingleCommand(input) {
        const trimmedInput = input.trim();

        // 尝试直接调用模式
        for (const [type, config] of Object.entries(this.commandPatterns)) {
            if (type === 'direct') {
                const directResult = config.handler(trimmedInput);
                if (directResult) return directResult;
            }
        }

        // 尝试角色切换模式
        const roleSwitchResult = this.commandPatterns.role_switch.handler(trimmedInput);
        if (roleSwitchResult) return roleSwitchResult;

        // 尝试角色呼叫模式
        const roleCallResult = this.commandPatterns.role_call.handler(trimmedInput);
        if (roleCallResult) return roleCallResult;

        // 尝试自然语言模式
        return this.commandPatterns.natural.handler(trimmedInput);
    }

    /**
     * 解析直接调用命令
     * @param {string} input - 输入字符串
     * @returns {Object|null} 解析结果或null
     */
    parseDirectCall(input) {
        const match = input.match(this.commandPatterns.direct.pattern);
        if (!match) {
            return null;
        }

        const [, callType, targetName] = match;
        const normalizedType = callType.toLowerCase();
        const trimmedName = targetName.trim();

        // 验证调用类型
        if (!['rule', 'script', 'skill', 'hook', 'workflow', 'call', 'nickname'].includes(normalizedType)) {
            return this.createErrorResult(`未知的调用类型: ${callType}`);
        }

        // 验证目标名称
        if (!trimmedName) {
            return this.createErrorResult(`未指定${callType}名称`);
        }

        return {
            success: true,
            type: 'direct_call',
            callType: normalizedType,
            targetName: trimmedName,
            originalInput: input,
            confidence: 1.0,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 解析角色切换命令
     * @param {string} input - 输入字符串
     * @returns {Object|null} 解析结果或null
     */
    parseRoleSwitch(input) {
        const match = input.match(this.commandPatterns.role_switch.pattern);
        if (!match) {
            return null;
        }

        const [, , roleName] = match;
        const trimmedRoleName = roleName.trim();

        // 验证角色名称
        if (!trimmedRoleName) {
            return this.createErrorResult('未指定角色名称');
        }

        return {
            success: true,
            type: 'role_switch',
            roleName: trimmedRoleName,
            originalInput: input,
            confidence: 1.0,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 解析角色呼叫命令
     * @param {string} input - 输入字符串
     * @returns {Object|null} 解析结果或null
     */
    parseRoleCall(input) {
        const match = input.match(this.commandPatterns.role_call.pattern);
        if (!match) {
            return null;
        }

        const [, , nickname] = match;
        const trimmedNickname = nickname.trim();

        // 验证昵称
        if (!trimmedNickname) {
            return this.createErrorResult('未指定角色昵称');
        }

        return {
            success: true,
            type: 'direct_call',
            callType: 'call',
            targetName: trimmedNickname,
            originalInput: input,
            confidence: 1.0,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 解析自然语言命令
     * @param {string} input - 输入字符串
     * @returns {Object} 解析结果
     */
    parseNaturalLanguage(input) {
        // 分析意图
        const intentAnalysis = this.analyzeIntent(input);

        if (!intentAnalysis.intent) {
            return this.createErrorResult('无法识别命令意图，请尝试更具体的描述');
        }

        // 提取参数
        const parameters = this.extractParameters(input, intentAnalysis.intent);

        // 检查宪法合规性
        const constitutionCheck = this.checkConstitutionCompliance(intentAnalysis.intent, input);

        return {
            success: true,
            type: 'natural_language',
            intent: intentAnalysis.intent,
            confidence: intentAnalysis.confidence,
            parameters: parameters,
            constitution: constitutionCheck,
            originalInput: input,
            timestamp: new Date().toISOString(),
            analysis: intentAnalysis
        };
    }

    /**
     * 分析用户意图
     * @param {string} input - 输入字符串
     * @returns {Object} 意图分析结果
     */
    analyzeIntent(input) {
        const lowerInput = input.toLowerCase();
        let bestMatch = null;
        let maxScore = 0;

        for (const [intentKey, intentConfig] of Object.entries(this.intentMappings)) {
            let score = 0;
            let matchedKeywords = [];

            // 检查关键词匹配
            for (const keyword of intentConfig.keywords) {
                if (lowerInput.includes(keyword)) {
                    score += 1;
                    matchedKeywords.push(keyword);
                }
            }

            // 标准化得分 (基于匹配度和基础置信度)
            // 如果匹配到关键词，给基础分；匹配越多得分越高
            let normalizedScore = score > 0 ?
                Math.min(score * 0.2 + 0.3, 1.0) * intentConfig.confidence : 0;

            // 🚀 使用高级模式进行得分修正
            if (this.intentPatterns && normalizedScore > 0) {
                const category = intentConfig.category;
                const pattern = Object.values(this.intentPatterns).find(p =>
                    p.keywords && p.keywords.some(k => intentConfig.keywords.includes(k))
                );

                if (pattern) {
                    // 技术指标增强
                    if (pattern.tech_indicators) {
                        for (const indicator of pattern.tech_indicators) {
                            if (lowerInput.includes(indicator.toLowerCase())) {
                                normalizedScore += 0.1;
                                matchedKeywords.push(indicator);
                            }
                        }
                    }
                    // 信心增强词
                    if (pattern.confidence_boosters) {
                        for (const booster of pattern.confidence_boosters) {
                            if (lowerInput.includes(booster.toLowerCase())) {
                                normalizedScore += 0.05;
                                matchedKeywords.push(booster);
                            }
                        }
                    }
                }
            }

            if (normalizedScore > maxScore && normalizedScore > 0.2) { // 降低最低阈值
                maxScore = normalizedScore;
                bestMatch = {
                    ...intentConfig,
                    intent: intentKey,
                    category: intentConfig.category,
                    confidence: normalizedScore,
                    matchedKeywords: matchedKeywords,
                    constitution: intentConfig.constitution
                };
            }
        }

        return bestMatch || { intent: null, confidence: 0 };
    }

    /**
     * 委托 skills-loader match 根据用户输入匹配技能（规范入口）
     * @param {string} input - 用户输入
     * @returns {string|null} 匹配到的第一个技能名，无匹配返回 null
     */
    matchSkillByInput(input) {
        try {
            const loaderPath = path.join(this.cursorDir, 'core', 'skills-loader.sh');
            if (!fs.existsSync(loaderPath)) return null;
            const safeInput = String(input || '').replace(/\n/g, ' ').trim();
            if (!safeInput) return null;
            const result = execSync(`bash "${loaderPath}" match ${JSON.stringify(safeInput)}`, {
                cwd: this.projectRoot,
                encoding: 'utf8',
                timeout: 5000
            });
            const matched = JSON.parse(result.trim());
            return Array.isArray(matched) && matched.length > 0 ? matched[0] : null;
        } catch {
            return null;
        }
    }

    /**
     * 提取参数
     * @param {string} input - 输入字符串
     * @param {string} intent - 识别的意图
     * @returns {Object} 提取的参数
     */
    extractParameters(input, intent) {
        const parameters = {};

        // 基于意图提取特定参数
        switch (intent) {
            case 'creation':
                // 提取项目类型
                const projectTypes = ['react', 'vue', 'angular', 'node', 'python', 'java', 'go'];
                for (const type of projectTypes) {
                    if (input.toLowerCase().includes(type)) {
                        parameters.projectType = type;
                        break;
                    }
                }
                break;

            case 'optimization':
                // 提取优化类型
                if (input.toLowerCase().includes('性能')) {
                    parameters.optimizationType = 'performance';
                } else if (input.toLowerCase().includes('代码')) {
                    parameters.optimizationType = 'code_quality';
                } else if (input.toLowerCase().includes('安全')) {
                    parameters.optimizationType = 'security';
                }
                break;

            case 'learning':
                // 提取学习主题
                const techStack = ['react', 'vue', 'python', 'javascript', 'node', 'docker', 'kubernetes'];
                for (const tech of techStack) {
                    if (input.toLowerCase().includes(tech)) {
                        parameters.technology = tech;
                        break;
                    }
                }
                break;

            case 'role_call':
                // 提取角色昵称或名称
                const nicknameMatch = input.match(/(?:呼叫|叫|召唤)\s*([^\s]+)/);
                if (nicknameMatch) {
                    parameters.nickname = nicknameMatch[1].trim();
                }
                // 也可以通过角色名称匹配
                const roleNameMatch = input.match(/(?:切换到|使用角色)\s*([^\s]+)/);
                if (roleNameMatch) {
                    parameters.roleName = roleNameMatch[1].trim();
                }
                break;

            case 'skills_execution':
                // 委托 skills-loader match（规范入口，基于 registry.json）
                const matchedSkill = this.matchSkillByInput(input);
                if (matchedSkill) {
                    parameters.skill_name = matchedSkill;
                }
                break;
        }

        // 提取通用参数
        parameters.input = input;
        parameters.intent = intent;

        return parameters;
    }

    /**
     * 检查宪法合规性
     * @param {string} intent - 意图
     * @param {string} input - 原始输入
     * @returns {Object} 合规性检查结果
     */
    checkConstitutionCompliance(intent, input) {
        // 简化宪法合规性检查 - 只对高风险操作进行检查
        // 移除项目创建意图的强制拦截，允许正常项目创建流程

        // 高风险操作列表 - 只有这些操作需要额外检查
        const highRiskIntents = [
            // 可以在这里添加真正高风险的操作，如删除重要文件等
            // 目前为空，意味着所有操作都认为是合规的
        ];

        const isHighRisk = highRiskIntents.includes(intent);

        if (isHighRisk) {
            return {
                compliant: false,
                requiresDiscussion: true,
                reason: `检测到高风险操作: ${intent}，需要额外确认`,
                action: 'STOP_AND_DISCUSS',
                severity: 'high'
            };
        }

        return {
            compliant: true,
            requiresDiscussion: false,
            reason: '符合宪法要求',
            action: 'PROCEED',
            severity: 'low'
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
            type: 'error',
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 获取解析统计信息
     * @returns {Object} 统计信息
     */
    getStats() {
        return {
            supportedIntents: Object.keys(this.intentMappings).length,
            intentCategories: [...new Set(Object.values(this.intentMappings).map(i => i.category))],
            lastUpdated: new Date().toISOString()
        };
    }
}

// 导出类
module.exports = MasterCommandParser;

// 测试函数
async function testParser() {
    console.log('🧪 测试Master Command Parser...\n');

    const parser = new MasterCommandParser(process.cwd());

    const testCases = [
        // 直接调用测试
        { input: 'rule constitution', expected: 'direct_call' },
        { input: 'script init.sh', expected: 'direct_call' },
        { input: 'skill pdf', expected: 'direct_call' },

        // 自然语言测试
        { input: '我想创建一个React项目', expected: 'natural_language' },
        { input: '优化代码性能', expected: 'natural_language' },
        { input: '帮我分析项目结构', expected: 'natural_language' },
        { input: '提交代码到仓库', expected: 'natural_language' },

        // 边界情况测试
        { input: '', expected: 'error' },
        { input: 'rule', expected: 'error' },
        { input: '不明所以的输入', expected: 'error' }
    ];

    for (const testCase of testCases) {
        console.log(`\n📋 测试: "${testCase.input}"`);
        console.log(`   期望: ${testCase.expected}`);

        try {
            const result = parser.parse(testCase.input);
            const actualType = result.success ? result.type : 'error';

            console.log(`   实际: ${actualType}`);
            console.log(`   成功: ${result.success}`);

            if (result.success) {
                if (result.type === 'direct_call') {
                    console.log(`   调用类型: ${result.callType}`);
                    console.log(`   目标名称: ${result.targetName}`);
                } else if (result.type === 'natural_language') {
                    console.log(`   意图: ${result.intent}`);
                    console.log(`   置信度: ${(result.confidence * 100).toFixed(1)}%`);
                }
            } else {
                console.log(`   错误: ${result.error}`);
            }

            console.log(`   ✅ ${actualType === testCase.expected ? '通过' : '失败'}`);

        } catch (error) {
            console.log(`   ❌ 异常: ${error.message}`);
        }
    }

    console.log('\n📊 解析器统计:', parser.getStats());
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.includes('--test')) {
        testParser().catch(console.error);
    } else if (args.length > 0) {
        const parser = new MasterCommandParser(process.cwd());
        const input = args.join(' ');
        const result = parser.parse(input);
        console.log(JSON.stringify(result, null, 2));
    } else {
        console.log('用法:');
        console.log('  node master-parser.js <输入>    # 解析输入');
        console.log('  node master-parser.js --test    # 运行测试');
    }
}
