// Cursor AI Rules - Master Command Parser
// 负责解析 /master 命令的输入，提取意图和参数

const path = require('path');
const fs = require('fs');

class MasterCommandParser {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');

        // 定义命令模式
        this.commandPatterns = {
            // 直接调用模式
            direct: {
                pattern: /^(rule|script|skill|hook|workflow)\s+(.+)$/i,
                handler: this.parseDirectCall.bind(this)
            },

            // 自然语言模式
            natural: {
                pattern: /^(.+)$/,
                handler: this.parseNaturalLanguage.bind(this)
            }
        };

        // 意图分类映射
        this.intentMappings = {
            // 项目创建意图
            creation: {
                keywords: ['创建', '开发', '构建', '搭建', '实现', '新建', '做一个', '生成'],
                confidence: 0.9,
                category: 'creation',
                constitution: 'intent_sovereignty'
            },

            // 代码优化意图
            optimization: {
                keywords: ['优化', '改进', '提升', '重构', '修复', '清理', '整理', '增强'],
                confidence: 0.85,
                category: 'optimization'
            },

            // 分析意图
            analysis: {
                keywords: ['分析', '检查', '评估', '诊断', '审计', '审查', '监控', '查看'],
                confidence: 0.8,
                category: 'analysis'
            },

            // 部署运维意图
            deployment: {
                keywords: ['部署', '发布', '上线', '运行', '启动', '停止', '重启', '维护'],
                confidence: 0.75,
                category: 'deployment'
            },

            // 学习意图
            learning: {
                keywords: ['学习', '了解', '掌握', '教程', '指南', '文档', '帮助', '教学'],
                confidence: 0.7,
                category: 'learning'
            },

            // 测试意图
            testing: {
                keywords: ['测试', '验证', '检查', '运行测试', '单元测试', '集成测试'],
                confidence: 0.8,
                category: 'testing'
            },

            // 提交意图
            commit: {
                keywords: ['提交', '推送', '保存', '上传', '同步'],
                confidence: 0.85,
                category: 'commit'
            }
        };
    }

    /**
     * 主解析方法
     * @param {string} input - 用户输入
     * @returns {Object} 解析结果
     */
    parse(input) {
        if (!input || typeof input !== 'string') {
            return this.createErrorResult('输入无效');
        }

        const trimmedInput = input.trim();

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
        if (!['rule', 'script', 'skill', 'hook', 'workflow'].includes(normalizedType)) {
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

            // 标准化得分 (基于关键词数量和基础置信度)
            const normalizedScore = score > 0 ?
                (score / intentConfig.keywords.length) * intentConfig.confidence : 0;

            if (normalizedScore > maxScore && normalizedScore > 0.3) { // 最低阈值
                maxScore = normalizedScore;
                bestMatch = {
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
        // 检查是否触发宪法保护
        const isCreationIntent = intent === 'creation';

        if (isCreationIntent) {
            return {
                compliant: false,
                requiresDiscussion: true,
                reason: '检测到项目创建意图，触发宪法第1条：意图主权公理',
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