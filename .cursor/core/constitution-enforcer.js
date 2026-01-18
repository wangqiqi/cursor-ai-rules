// Cursor AI Rules - Constitution Enforcer
// 实现三大公理的强制执行：意图主权、信号可信、认知可审计

const path = require('path');
const fs = require('fs');

class ConstitutionEnforcer {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');

        // 三大公理执行引擎
        this.intentSovereigntyEngine = new IntentSovereigntyEngine();
        this.signalTrustEngine = new SignalTrustEngine();
        this.cognitiveAuditEngine = new CognitiveAuditEngine();

        // 审计日志
        this.auditLog = [];
        this.maxLogSize = 1000;

        console.log('🏛️ 宪法执行引擎初始化完成');
    }

    /**
     * 执行意图主权公理 - 零违反检测
     * @param {string} input - 用户输入
     * @returns {Object} 检测结果
     */
    enforceIntentSovereignty(input) {
        const startTime = Date.now();
        const result = this.intentSovereigntyEngine.detectAndEnforce(input);

        // 记录审计信息
        this.logAuditEvent('intent_sovereignty_check', {
            input,
            result: result.violated,
            processingTime: Date.now() - startTime,
            timestamp: new Date().toISOString()
        });

        return result;
    }

    /**
     * 执行信号可信公理 - 完整溯源链
     * @param {Object} signal - 信号对象
     * @returns {Object} 溯源结果
     */
    enforceSignalTrust(signal) {
        const startTime = Date.now();
        const result = this.signalTrustEngine.buildAndVerifySignalChain(signal);

        // 记录审计信息
        this.logAuditEvent('signal_trust_verification', {
            signalId: signal.id || 'unknown',
            chainLength: result.chain ? result.chain.length : 0,
            verified: result.verified,
            processingTime: Date.now() - startTime,
            timestamp: new Date().toISOString()
        });

        return result;
    }

    /**
     * 执行认知可审计公理 - 3秒回溯
     * @param {string} queryId - 查询ID
     * @returns {Object} 回溯结果
     */
    enforceCognitiveAudit(queryId) {
        const startTime = Date.now();
        const result = this.cognitiveAuditEngine.perform3SecondRetrospective(queryId);

        const processingTime = Date.now() - startTime;
        const within3Seconds = processingTime <= 3000;

        // 记录审计信息
        this.logAuditEvent('cognitive_audit_retrospective', {
            queryId,
            processingTime,
            within3Seconds,
            found: result.found,
            timestamp: new Date().toISOString()
        });

        // 如果超过3秒，记录违规
        if (!within3Seconds) {
            this.logAuditEvent('constitution_violation', {
                axiom: 'cognitive_audit',
                violation: 'exceeded_3_second_limit',
                processingTime,
                queryId,
                timestamp: new Date().toISOString()
            });
        }

        return {
            ...result,
            processingTime,
            within3Seconds
        };
    }

    /**
     * 综合宪法合规性检查
     * @param {string} input - 用户输入
     * @param {Object} context - 执行上下文
     * @returns {Object} 合规性检查结果
     */
    checkOverallCompliance(input, context = {}) {
        const results = {
            intentSovereignty: this.enforceIntentSovereignty(input),
            signalTrust: context.signal ? this.enforceSignalTrust(context.signal) : null,
            cognitiveAudit: context.queryId ? this.enforceCognitiveAudit(context.queryId) : null,
            overallCompliant: true,
            violations: [],
            timestamp: new Date().toISOString()
        };

        // 检查是否有违规
        if (results.intentSovereignty.violated) {
            results.overallCompliant = false;
            results.violations.push({
                axiom: 'intent_sovereignty',
                reason: results.intentSovereignty.reason,
                severity: 'high'
            });
        }

        if (results.signalTrust && !results.signalTrust.verified) {
            results.overallCompliant = false;
            results.violations.push({
                axiom: 'signal_trust',
                reason: '信号链验证失败',
                severity: 'medium'
            });
        }

        if (results.cognitiveAudit && !results.cognitiveAudit.within3Seconds) {
            results.overallCompliant = false;
            results.violations.push({
                axiom: 'cognitive_audit',
                reason: '回溯时间超过3秒',
                severity: 'medium'
            });
        }

        return results;
    }

    /**
     * 获取宪法状态报告
     * @returns {Object} 状态报告
     */
    getConstitutionStatus() {
        const recentAudits = this.auditLog.slice(-10); // 最近10条审计记录

        return {
            axioms: {
                intent_sovereignty: {
                    status: 'active',
                    violations: recentAudits.filter(a => a.event === 'constitution_violation' && a.data.axiom === 'intent_sovereignty').length
                },
                signal_trust: {
                    status: 'active',
                    violations: recentAudits.filter(a => a.event === 'constitution_violation' && a.data.axiom === 'signal_trust').length
                },
                cognitive_audit: {
                    status: 'active',
                    violations: recentAudits.filter(a => a.event === 'constitution_violation' && a.data.axiom === 'cognitive_audit').length
                }
            },
            auditStats: {
                totalAudits: this.auditLog.length,
                recentAudits: recentAudits.length,
                violations: recentAudits.filter(a => a.event === 'constitution_violation').length
            },
            uptime: process.uptime(),
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 记录审计事件
     * @param {string} event - 事件类型
     * @param {Object} data - 事件数据
     */
    logAuditEvent(event, data) {
        const auditEntry = {
            id: this.generateAuditId(),
            event,
            data,
            timestamp: new Date().toISOString()
        };

        this.auditLog.push(auditEntry);

        // 限制日志大小
        if (this.auditLog.length > this.maxLogSize) {
            this.auditLog = this.auditLog.slice(-this.maxLogSize);
        }

        // 异步写入文件
        this.persistAuditLog(auditEntry);
    }

    /**
     * 生成审计ID
     * @returns {string} 审计ID
     */
    generateAuditId() {
        return `audit_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * 持久化审计日志
     * @param {Object} auditEntry - 审计条目
     */
    async persistAuditLog(auditEntry) {
        try {
            // 📁 日志应该存储在 .cursorGrowth 目录中
            const cursorGrowthDir = path.join(this.projectRoot, '.cursorGrowth');
            const logDir = path.join(cursorGrowthDir, 'monitoring', 'logs');

            // 确保目录存在
            if (!fs.existsSync(logDir)) {
                fs.mkdirSync(logDir, { recursive: true });
            }

            const logFile = path.join(logDir, 'constitution-audit.jsonl');
            fs.appendFileSync(logFile, JSON.stringify(auditEntry) + '\n');

            console.log(`📝 审计日志已保存到: ${logFile}`);
        } catch (error) {
            console.warn('⚠️ 审计日志持久化失败:', error.message);
        }
    }
}

/**
 * 意图主权公理执行引擎
 */
class IntentSovereigntyEngine {
    constructor() {
        // 项目创建意图关键词
        this.creationKeywords = [
            '我想做一个', '我想开发一个', '开发一个', '构建', '创建', '做一个',
            '搭建', '建立', '实现', '设计', '新建', '初始化', '启动'
        ];

        // 上下文关键词（增加检测准确性）
        this.contextKeywords = [
            '项目', '应用', '系统', '平台', '网站', '服务', '工具', '框架'
        ];
    }

    /**
     * 检测并强制执行意图主权
     * @param {string} input - 用户输入
     * @returns {Object} 检测结果
     */
    detectAndEnforce(input) {
        const lowerInput = input.toLowerCase();

        // 多层次检测
        const keywordMatch = this.checkKeywordMatch(lowerInput);
        const contextMatch = this.checkContextMatch(lowerInput);
        const semanticMatch = this.checkSemanticMatch(input);

        // 综合判断是否触发STOP机制
        const violated = keywordMatch.found && (contextMatch.found || semanticMatch.found);

        const result = {
            violated,
            confidence: Math.max(keywordMatch.confidence, contextMatch.confidence, semanticMatch.confidence),
            detection: {
                keywordMatch,
                contextMatch,
                semanticMatch
            }
        };

        if (violated) {
            result.reason = '检测到项目创建意图，触发意图主权公理保护';
            result.action = 'STOP_AND_DISCUSS';
            result.response = this.generateConstitutionResponse(input);
        }

        return result;
    }

    /**
     * 检查关键词匹配
     * @param {string} input - 输入字符串
     * @returns {Object} 匹配结果
     */
    checkKeywordMatch(input) {
        for (const keyword of this.creationKeywords) {
            if (input.includes(keyword)) {
                return {
                    found: true,
                    keyword: keyword,
                    confidence: 0.9
                };
            }
        }
        return { found: false, confidence: 0 };
    }

    /**
     * 检查上下文匹配
     * @param {string} input - 输入字符串
     * @returns {Object} 匹配结果
     */
    checkContextMatch(input) {
        let contextScore = 0;
        let matchedContexts = [];

        for (const context of this.contextKeywords) {
            if (input.includes(context)) {
                contextScore += 0.2;
                matchedContexts.push(context);
            }
        }

        return {
            found: contextScore > 0,
            contexts: matchedContexts,
            confidence: Math.min(contextScore, 1.0)
        };
    }

    /**
     * 检查语义匹配
     * @param {string} input - 输入字符串
     * @returns {Object} 匹配结果
     */
    checkSemanticMatch(input) {
        // 这里可以实现更复杂的语义分析
        // 目前使用简单的启发式规则
        const semanticPatterns = [
            /\b(create|build|develop|make)\b.*\b(project|app|system|platform)\b/i,
            /\b(start|begin|initiate)\b.*\b(new|fresh)\b.*\b(project|application)\b/i
        ];

        for (const pattern of semanticPatterns) {
            if (pattern.test(input)) {
                return {
                    found: true,
                    pattern: pattern.source,
                    confidence: 0.8
                };
            }
        }

        return { found: false, confidence: 0 };
    }

    /**
     * 生成宪法合规性响应
     * @param {string} input - 用户输入
     * @returns {string} 响应内容
     */
    generateConstitutionResponse(input) {
        // 分析项目类型
        const projectType = this.inferProjectType(input);

        let response = `## 🤖 宪法保护机制激活\n\n`;
        response += `🚨 **检测到项目创建意图！**\n\n`;
        response += `### 📋 需求分析\n`;
        response += `- **项目类型**: ${projectType}\n`;
        response += `- **复杂度**: 中等\n\n`;

        response += `### 🛠️ 技术方案建议\n`;
        response += this.generateTechSuggestions(projectType);
        response += `\n\n### ❓ 需要澄清的问题\n`;
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
     * 推断项目类型
     * @param {string} input - 用户输入
     * @returns {string} 项目类型
     */
    inferProjectType(input) {
        const lowerInput = input.toLowerCase();

        if (lowerInput.includes('电商') || lowerInput.includes('商城')) {
            return '电商平台';
        } else if (lowerInput.includes('博客') || lowerInput.includes('内容管理')) {
            return '内容管理系统';
        } else if (lowerInput.includes('数据') || lowerInput.includes('分析')) {
            return '数据分析平台';
        } else if (lowerInput.includes('api') || lowerInput.includes('接口')) {
            return 'API服务';
        } else if (lowerInput.includes('react') || lowerInput.includes('vue') || lowerInput.includes('前端')) {
            return '前端应用';
        } else if (lowerInput.includes('node') || lowerInput.includes('后端')) {
            return '后端服务';
        } else {
            return '通用Web应用';
        }
    }

    /**
     * 生成技术方案建议
     * @param {string} projectType - 项目类型
     * @returns {string} 技术建议
     */
    generateTechSuggestions(projectType) {
        const suggestions = {
            '电商平台': '- 前端: React + TypeScript\n- 后端: Node.js + Express\n- 数据库: PostgreSQL\n- 支付: Stripe集成',
            '内容管理系统': '- 前端: Next.js + MDX\n- 后端: Strapi CMS\n- 数据库: SQLite/PostgreSQL\n- 部署: Vercel',
            '数据分析平台': '- 前端: D3.js + React\n- 后端: Python + FastAPI\n- 数据库: ClickHouse\n- 可视化: Apache ECharts',
            'API服务': '- 框架: FastAPI (Python) 或 Express (Node.js)\n- 文档: OpenAPI/Swagger\n- 测试: Postman + Jest\n- 部署: Docker + Kubernetes',
            '前端应用': '- 框架: React/Vue/Angular\n- 状态管理: Redux/Vuex/NgRx\n- 样式: Tailwind CSS\n- 测试: Jest + React Testing Library',
            '后端服务': '- 语言: Node.js/Python/Go\n- 框架: Express/FastAPI/Gin\n- 数据库: PostgreSQL/MySQL\n- 缓存: Redis',
            '通用Web应用': '- 全栈: Next.js + Prisma\n- 数据库: PostgreSQL\n- 认证: NextAuth.js\n- 部署: Vercel + Railway'
        };

        return suggestions[projectType] || suggestions['通用Web应用'];
    }
}

/**
 * 信号可信公理执行引擎
 */
class SignalTrustEngine {
    constructor() {
        this.signalChains = new Map();
        this.maxChainLength = 50;
    }

    /**
     * 构建并验证信号链
     * @param {Object} signal - 信号对象
     * @returns {Object} 验证结果
     */
    buildAndVerifySignalChain(signal) {
        const signalId = signal.id || this.generateSignalId();
        const chain = this.buildSignalChain(signal);

        // 验证链的完整性和可追溯性
        const verification = this.verifySignalChain(chain);

        return {
            signalId,
            chain,
            verified: verification.valid,
            issues: verification.issues,
            traceabilityScore: this.calculateTraceabilityScore(chain)
        };
    }

    /**
     * 构建信号链
     * @param {Object} signal - 信号对象
     * @returns {Array} 信号链
     */
    buildSignalChain(signal) {
        const chain = [{
            id: signal.id || this.generateSignalId(),
            type: 'source',
            content: signal.content || signal,
            source: signal.source || 'user_input',
            timestamp: signal.timestamp || new Date().toISOString(),
            metadata: signal.metadata || {}
        }];

        // 如果有处理历史，添加到链中
        if (signal.processingHistory) {
            signal.processingHistory.forEach(step => {
                chain.push({
                    id: this.generateSignalId(),
                    type: 'processing',
                    content: step.output,
                    source: step.processor,
                    timestamp: step.timestamp,
                    metadata: step.metadata || {}
                });
            });
        }

        // 如果有推理过程，添加到链中
        if (signal.reasoning) {
            signal.reasoning.forEach(reason => {
                chain.push({
                    id: this.generateSignalId(),
                    type: 'reasoning',
                    content: reason.step,
                    source: 'ai_reasoning',
                    timestamp: new Date().toISOString(),
                    metadata: { confidence: reason.confidence }
                });
            });
        }

        // 限制链长度
        if (chain.length > this.maxChainLength) {
            chain.splice(this.maxChainLength);
        }

        this.signalChains.set(chain[0].id, chain);
        return chain;
    }

    /**
     * 验证信号链
     * @param {Array} chain - 信号链
     * @returns {Object} 验证结果
     */
    verifySignalChain(chain) {
        const issues = [];

        // 检查链的完整性
        if (!chain || chain.length === 0) {
            issues.push('信号链为空');
            return { valid: false, issues };
        }

        // 检查是否有源信号
        const hasSource = chain.some(link => link.type === 'source');
        if (!hasSource) {
            issues.push('缺少源信号');
        }

        // 检查时间戳的合理性
        for (let i = 1; i < chain.length; i++) {
            const prev = new Date(chain[i - 1].timestamp);
            const curr = new Date(chain[i].timestamp);

            if (curr < prev) {
                issues.push(`时间戳不一致: ${chain[i].id}`);
            }
        }

        // 检查元数据的完整性
        chain.forEach(link => {
            if (!link.metadata) {
                issues.push(`缺少元数据: ${link.id}`);
            }
        });

        return {
            valid: issues.length === 0,
            issues
        };
    }

    /**
     * 计算可追溯性评分
     * @param {Array} chain - 信号链
     * @returns {number} 评分 (0-1)
     */
    calculateTraceabilityScore(chain) {
        if (!chain || chain.length === 0) return 0;

        let score = 0.5; // 基础分

        // 链长度加分
        if (chain.length >= 3) score += 0.2;

        // 推理步骤加分
        const reasoningSteps = chain.filter(link => link.type === 'reasoning').length;
        score += Math.min(reasoningSteps * 0.1, 0.2);

        // 元数据完整性加分
        const completeMetadata = chain.filter(link => link.metadata && Object.keys(link.metadata).length > 0).length;
        const metadataRatio = completeMetadata / chain.length;
        score += metadataRatio * 0.1;

        return Math.min(score, 1.0);
    }

    /**
     * 生成信号ID
     * @returns {string} 信号ID
     */
    generateSignalId() {
        return `signal_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
}

/**
 * 认知可审计公理执行引擎
 */
class CognitiveAuditEngine {
    constructor() {
        this.auditRecords = new Map();
        this.maxRecords = 10000;
    }

    /**
     * 执行3秒回溯
     * @param {string} queryId - 查询ID
     * @returns {Object} 回溯结果
     */
    perform3SecondRetrospective(queryId) {
        const startTime = Date.now();

        try {
            const record = this.auditRecords.get(queryId);

            if (!record) {
                return {
                    found: false,
                    reason: '未找到对应的审计记录',
                    processingTime: Date.now() - startTime
                };
            }

            // 构建回溯信息
            const retrospective = {
                queryId,
                originalInput: record.input,
                processingSteps: record.processingSteps || [],
                reasoningChain: record.reasoningChain || [],
                decisionPoints: record.decisionPoints || [],
                finalOutput: record.output,
                processingTime: record.processingTime,
                timestamp: record.timestamp
            };

            return {
                found: true,
                retrospective,
                processingTime: Date.now() - startTime
            };

        } catch (error) {
            return {
                found: false,
                reason: `回溯失败: ${error.message}`,
                processingTime: Date.now() - startTime
            };
        }
    }

    /**
     * 记录审计信息
     * @param {string} queryId - 查询ID
     * @param {Object} record - 审计记录
     */
    recordAuditInfo(queryId, record) {
        if (this.auditRecords.size >= this.maxRecords) {
            // 清理最旧的记录
            const oldestKey = this.auditRecords.keys().next().value;
            this.auditRecords.delete(oldestKey);
        }

        this.auditRecords.set(queryId, {
            ...record,
            recordedAt: new Date().toISOString()
        });
    }

    /**
     * 获取审计统计
     * @returns {Object} 统计信息
     */
    getAuditStats() {
        return {
            totalRecords: this.auditRecords.size,
            maxRecords: this.maxRecords,
            oldestRecord: this.auditRecords.size > 0 ?
                Array.from(this.auditRecords.values())[0].recordedAt : null,
            newestRecord: this.auditRecords.size > 0 ?
                Array.from(this.auditRecords.values())[this.auditRecords.size - 1].recordedAt : null
        };
    }
}

// 导出类
module.exports = ConstitutionEnforcer;

// 测试函数
async function testConstitutionEnforcer() {
    console.log('🧪 测试宪法执行引擎...\n');

    const enforcer = new ConstitutionEnforcer(process.cwd());

    // 测试意图主权
    console.log('=== 测试意图主权公理 ===');
    const testInputs = [
        '我想创建一个电商网站',
        '优化一下代码性能',
        '帮我分析项目结构'
    ];

    for (const input of testInputs) {
        console.log(`\n输入: "${input}"`);
        const result = enforcer.enforceIntentSovereignty(input);
        console.log(`违规: ${result.violated}`);
        console.log(`置信度: ${(result.confidence * 100).toFixed(1)}%`);
    }

    // 测试信号可信
    console.log('\n=== 测试信号可信公理 ===');
    const testSignal = {
        id: 'test_signal_001',
        content: '用户输入测试',
        source: 'test',
        timestamp: new Date().toISOString(),
        processingHistory: [
            {
                processor: 'parser',
                output: '解析结果',
                timestamp: new Date().toISOString()
            }
        ]
    };

    const signalResult = enforcer.enforceSignalTrust(testSignal);
    console.log(`信号ID: ${signalResult.signalId}`);
    console.log(`验证通过: ${signalResult.verified}`);
    console.log(`链长度: ${signalResult.chain.length}`);
    console.log(`可追溯性评分: ${(signalResult.traceabilityScore * 100).toFixed(1)}%`);

    // 获取状态报告
    console.log('\n=== 宪法状态报告 ===');
    const status = enforcer.getConstitutionStatus();
    console.log('三大公理状态:', status.axioms);
    console.log('审计统计:', status.auditStats);
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.includes('--test')) {
        testConstitutionEnforcer().catch(console.error);
    } else {
        console.log('用法:');
        console.log('  node constitution-enforcer.js --test    # 运行测试');
        console.log('  (宪法执行器需要通过编程方式调用)');
    }
}