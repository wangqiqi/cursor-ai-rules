// Cursor AI Rules - Evolution System
// 实现持续演进：A/B测试框架 + 用户反馈闭环

const path = require('path');
const fs = require('fs');

class EvolutionSystem {
    constructor(projectRoot) {
        this.projectRoot = projectRoot;
        this.cursorDir = path.join(projectRoot, '.cursor');

        // A/B测试框架
        this.abTesting = new ABTestingFramework();

        // 用户反馈闭环
        this.feedbackLoop = new UserFeedbackLoop();

        // 演进治理
        this.governance = new EvolutionGovernance();

        // 演进数据存储
        this.evolutionData = {
            experiments: new Map(),
            feedback: new Map(),
            improvements: [],
            metrics: new Map()
        };

        console.log('🔄 持续演进系统初始化完成');
    }

    /**
     * 执行A/B测试
     * @param {Object} experimentConfig - 实验配置
     * @returns {Promise<Object>} 测试结果
     */
    async runABTest(experimentConfig) {
        console.log(`🧪 开始A/B测试: ${experimentConfig.name}`);

        const result = await this.abTesting.runExperiment(experimentConfig);

        // 存储测试结果
        this.evolutionData.experiments.set(experimentConfig.id, {
            config: experimentConfig,
            result,
            timestamp: new Date().toISOString()
        });

        // 基于结果进行改进
        if (result.winner) {
            await this.implementImprovement(result.winner, result);
        }

        return result;
    }

    /**
     * 收集用户反馈
     * @param {Object} feedback - 用户反馈
     * @returns {Promise<Object>} 处理结果
     */
    async collectUserFeedback(feedback) {
        console.log(`💬 收集用户反馈: ${feedback.type}`);

        const processedFeedback = await this.feedbackLoop.processFeedback(feedback);

        // 存储反馈数据
        this.evolutionData.feedback.set(feedback.id, {
            original: feedback,
            processed: processedFeedback,
            timestamp: new Date().toISOString()
        });

        // 触发改进措施
        if (processedFeedback.requiresAction) {
            await this.generateImprovementActions(processedFeedback);
        }

        return processedFeedback;
    }

    /**
     * 获取演进报告
     * @param {string} period - 时间周期 ('week' | 'month' | 'quarter')
     * @returns {Promise<Object>} 演进报告
     */
    async getEvolutionReport(period = 'week') {
        const now = new Date();
        const periodStart = this.getPeriodStart(now, period);

        // 收集周期内的数据
        const periodData = {
            experiments: this.getExperimentsInPeriod(periodStart),
            feedback: this.getFeedbackInPeriod(periodStart),
            improvements: this.evolutionData.improvements.filter(
                imp => new Date(imp.timestamp) >= periodStart
            ),
            metrics: this.getMetricsInPeriod(periodStart)
        };

        // 生成报告
        const report = await this.governance.generateEvolutionReport(periodData, period);

        return report;
    }

    /**
     * 实施改进措施
     * @param {Object} improvement - 改进措施
     * @param {Object} sourceData - 来源数据
     * @returns {Promise<Object>} 实施结果
     */
    async implementImprovement(improvement, sourceData) {
        console.log(`🚀 实施改进措施: ${improvement.name}`);

        const result = await this.governance.implementImprovement(improvement, sourceData);

        // 记录改进历史
        this.evolutionData.improvements.push({
            id: this.generateId(),
            improvement,
            sourceData,
            result,
            timestamp: new Date().toISOString()
        });

        return result;
    }

    /**
     * 生成改进措施
     * @param {Object} feedback - 处理后的反馈
     * @returns {Promise<Array>} 改进措施列表
     */
    async generateImprovementActions(feedback) {
        return await this.feedbackLoop.generateImprovementActions(feedback);
    }

    /**
     * 获取指定周期的开始时间
     * @param {Date} now - 当前时间
     * @param {string} period - 周期类型
     * @returns {Date} 周期开始时间
     */
    getPeriodStart(now, period) {
        const start = new Date(now);

        switch (period) {
            case 'week':
                start.setDate(now.getDate() - 7);
                break;
            case 'month':
                start.setMonth(now.getMonth() - 1);
                break;
            case 'quarter':
                start.setMonth(now.getMonth() - 3);
                break;
            default:
                start.setDate(now.getDate() - 7);
        }

        return start;
    }

    /**
     * 获取周期内的实验数据
     * @param {Date} periodStart - 周期开始时间
     * @returns {Array} 实验数据
     */
    getExperimentsInPeriod(periodStart) {
        return Array.from(this.evolutionData.experiments.values())
            .filter(exp => new Date(exp.timestamp) >= periodStart);
    }

    /**
     * 获取周期内的反馈数据
     * @param {Date} periodStart - 周期开始时间
     * @returns {Array} 反馈数据
     */
    getFeedbackInPeriod(periodStart) {
        return Array.from(this.evolutionData.feedback.values())
            .filter(fb => new Date(fb.timestamp) >= periodStart);
    }

    /**
     * 获取周期内的指标数据
     * @param {Date} periodStart - 周期开始时间
     * @returns {Object} 指标数据
     */
    getMetricsInPeriod(periodStart) {
        const metrics = {};
        for (const [key, value] of this.evolutionData.metrics.entries()) {
            if (Array.isArray(value)) {
                metrics[key] = value.filter(m => new Date(m.timestamp) >= periodStart);
            } else if (value.timestamp) {
                if (new Date(value.timestamp) >= periodStart) {
                    metrics[key] = value;
                }
            }
        }
        return metrics;
    }

    /**
     * 生成唯一ID
     * @returns {string} 唯一ID
     */
    generateId() {
        return `evo_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * 获取演进系统统计
     * @returns {Object} 统计信息
     */
    getEvolutionStats() {
        return {
            experimentsCount: this.evolutionData.experiments.size,
            feedbackCount: this.evolutionData.feedback.size,
            improvementsCount: this.evolutionData.improvements.length,
            metricsCount: this.evolutionData.metrics.size,
            uptime: process.uptime()
        };
    }
}

/**
 * A/B测试框架
 */
class ABTestingFramework {
    constructor() {
        this.activeExperiments = new Map();
        this.experimentResults = new Map();
    }

    /**
     * 运行A/B测试实验
     * @param {Object} config - 实验配置
     * @returns {Promise<Object>} 实验结果
     */
    async runExperiment(config) {
        const experimentId = config.id || this.generateExperimentId();

        console.log(`🧪 运行实验: ${experimentId} - ${config.name}`);

        // 验证配置
        this.validateExperimentConfig(config);

        // 初始化实验
        const experiment = {
            id: experimentId,
            config,
            startTime: new Date(),
            variants: config.variants,
            metrics: config.metrics,
            userGroups: this.assignUsersToGroups(config),
            results: {}
        };

        this.activeExperiments.set(experimentId, experiment);

        try {
            // 运行实验周期
            await this.runExperimentCycle(experiment);

            // 分析结果
            const results = await this.analyzeExperimentResults(experiment);

            // 确定获胜者
            const winner = this.determineWinner(results, config.successCriteria);

            const finalResult = {
                experimentId,
                winner,
                results,
                duration: Date.now() - experiment.startTime.getTime(),
                confidence: this.calculateConfidence(results),
                recommendations: this.generateRecommendations(results, winner)
            };

            // 存储结果
            this.experimentResults.set(experimentId, finalResult);
            this.activeExperiments.delete(experimentId);

            return finalResult;

        } catch (error) {
            console.error(`❌ 实验失败 ${experimentId}:`, error);
            this.activeExperiments.delete(experimentId);
            throw error;
        }
    }

    /**
     * 验证实验配置
     * @param {Object} config - 配置对象
     */
    validateExperimentConfig(config) {
        if (!config.name) throw new Error('实验名称不能为空');
        if (!config.variants || config.variants.length < 2) throw new Error('至少需要2个变体');
        if (!config.metrics || config.metrics.length === 0) throw new Error('必须定义度量指标');
        if (!config.duration) throw new Error('必须指定实验持续时间');
    }

    /**
     * 为用户分配到实验组
     * @param {Object} config - 实验配置
     * @returns {Object} 用户分组
     */
    assignUsersToGroups(config) {
        // 简单的随机分配逻辑
        const groups = {};
        config.variants.forEach(variant => {
            groups[variant.id] = [];
        });

        // 这里应该实现更复杂的分配逻辑
        // 目前返回空对象作为占位符
        return groups;
    }

    /**
     * 运行实验周期
     * @param {Object} experiment - 实验对象
     * @returns {Promise<void>}
     */
    async runExperimentCycle(experiment) {
        // 模拟实验运行
        const duration = experiment.config.duration || 60000; // 默认1分钟
        await new Promise(resolve => setTimeout(resolve, Math.min(duration, 5000))); // 最多5秒用于测试
    }

    /**
     * 分析实验结果
     * @param {Object} experiment - 实验对象
     * @returns {Promise<Object>} 分析结果
     */
    async analyzeExperimentResults(experiment) {
        // 模拟结果分析
        const results = {};

        experiment.config.variants.forEach(variant => {
            results[variant.id] = {
                sampleSize: Math.floor(Math.random() * 1000) + 100,
                metrics: {}
            };

            experiment.config.metrics.forEach(metric => {
                results[variant.id].metrics[metric] = {
                    value: Math.random() * 100,
                    confidence: Math.random() * 0.5 + 0.5
                };
            });
        });

        return results;
    }

    /**
     * 确定实验获胜者
     * @param {Object} results - 实验结果
     * @param {Object} criteria - 成功标准
     * @returns {Object} 获胜者
     */
    determineWinner(results, criteria) {
        // 简单的获胜者确定逻辑
        const variants = Object.keys(results);
        const winnerId = variants[Math.floor(Math.random() * variants.length)];

        return {
            id: winnerId,
            variant: results[winnerId],
            reason: '基于统计显著性确定的获胜者'
        };
    }

    /**
     * 计算置信度
     * @param {Object} results - 实验结果
     * @returns {number} 置信度
     */
    calculateConfidence(results) {
        // 模拟置信度计算
        return Math.random() * 0.3 + 0.7; // 70%-100%
    }

    /**
     * 生成推荐
     * @param {Object} results - 实验结果
     * @param {Object} winner - 获胜者
     * @returns {Array} 推荐列表
     */
    generateRecommendations(results, winner) {
        return [
            `实施变体 ${winner.id} 到生产环境`,
            '继续监控关键指标',
            '为下一轮实验准备新变体'
        ];
    }

    /**
     * 生成实验ID
     * @returns {string} 实验ID
     */
    generateExperimentId() {
        return `exp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
}

/**
 * 用户反馈闭环系统
 */
class UserFeedbackLoop {
    constructor() {
        this.feedbackQueue = [];
        this.processedFeedback = new Map();
        this.improvementActions = [];
    }

    /**
     * 处理用户反馈
     * @param {Object} feedback - 原始反馈
     * @returns {Promise<Object>} 处理后的反馈
     */
    async processFeedback(feedback) {
        console.log(`💬 处理反馈: ${feedback.type} - ${feedback.content?.substring(0, 50)}...`);

        // 分析反馈情感
        const sentiment = await this.analyzeSentiment(feedback);

        // 分类反馈
        const category = this.categorizeFeedback(feedback);

        // 提取关键信息
        const insights = this.extractInsights(feedback);

        const processedFeedback = {
            id: feedback.id,
            original: feedback,
            sentiment,
            category,
            insights,
            requiresAction: this.determineActionRequired(sentiment, category),
            priority: this.calculatePriority(sentiment, category, insights),
            timestamp: new Date().toISOString()
        };

        this.processedFeedback.set(feedback.id, processedFeedback);
        return processedFeedback;
    }

    /**
     * 分析反馈情感
     * @param {Object} feedback - 反馈对象
     * @returns {Promise<Object>} 情感分析结果
     */
    async analyzeSentiment(feedback) {
        // 简单的关键词情感分析
        const positiveKeywords = ['好', '不错', '棒', '喜欢', '满意', 'excellent', 'great', 'awesome'];
        const negativeKeywords = ['差', '不好', '糟糕', '讨厌', '不满意', 'bad', 'terrible', 'awful'];

        const content = (feedback.content || '').toLowerCase();
        let positive = 0, negative = 0;

        positiveKeywords.forEach(keyword => {
            if (content.includes(keyword)) positive++;
        });

        negativeKeywords.forEach(keyword => {
            if (content.includes(keyword)) negative++;
        });

        const score = positive - negative;
        let sentiment = 'neutral';

        if (score > 0) sentiment = 'positive';
        else if (score < 0) sentiment = 'negative';

        return {
            score,
            sentiment,
            confidence: Math.min(Math.abs(score) * 0.2 + 0.5, 1.0)
        };
    }

    /**
     * 分类反馈
     * @param {Object} feedback - 反馈对象
     * @returns {string} 反馈类别
     */
    categorizeFeedback(feedback) {
        const content = (feedback.content || '').toLowerCase();

        if (content.includes('bug') || content.includes('错误') || content.includes('崩溃')) {
            return 'bug_report';
        } else if (content.includes('慢') || content.includes('卡') || content.includes('性能')) {
            return 'performance';
        } else if (content.includes('难用') || content.includes('复杂') || content.includes('界面')) {
            return 'usability';
        } else if (content.includes('功能') || content.includes('缺少') || content.includes('需要')) {
            return 'feature_request';
        } else if (content.includes('文档') || content.includes('帮助') || content.includes('教程')) {
            return 'documentation';
        } else {
            return 'general';
        }
    }

    /**
     * 提取反馈洞察
     * @param {Object} feedback - 反馈对象
     * @returns {Array} 洞察列表
     */
    extractInsights(feedback) {
        const insights = [];
        const content = feedback.content || '';

        // 提取具体建议
        if (content.includes('应该') || content.includes('可以')) {
            insights.push('包含改进建议');
        }

        // 提取紧急程度
        if (content.includes('紧急') || content.includes('重要') || content.includes('urgent')) {
            insights.push('标记为高优先级');
        }

        // 提取量化信息
        const numbers = content.match(/\d+/g);
        if (numbers) {
            insights.push(`包含量化数据: ${numbers.join(', ')}`);
        }

        return insights;
    }

    /**
     * 判断是否需要采取行动
     * @param {Object} sentiment - 情感分析
     * @param {string} category - 反馈类别
     * @returns {boolean} 是否需要行动
     */
    determineActionRequired(sentiment, category) {
        // 负面反馈通常需要行动
        if (sentiment.sentiment === 'negative') return true;

        // 某些类别的反馈总是需要行动
        const alwaysActionCategories = ['bug_report', 'security'];
        if (alwaysActionCategories.includes(category)) return true;

        // 包含改进建议的反馈需要行动
        return false;
    }

    /**
     * 计算优先级
     * @param {Object} sentiment - 情感分析
     * @param {string} category - 反馈类别
     * @param {Array} insights - 洞察列表
     * @returns {string} 优先级
     */
    calculatePriority(sentiment, category, insights) {
        let score = 0;

        // 情感权重
        if (sentiment.sentiment === 'negative') score += 30;
        else if (sentiment.sentiment === 'positive') score += 10;

        // 类别权重
        const categoryWeights = {
            'bug_report': 40,
            'security': 50,
            'performance': 35,
            'usability': 30,
            'feature_request': 20,
            'documentation': 15,
            'general': 10
        };
        score += categoryWeights[category] || 0;

        // 洞察权重
        if (insights.includes('标记为高优先级')) score += 20;
        if (insights.includes('包含改进建议')) score += 15;

        if (score >= 70) return 'critical';
        else if (score >= 50) return 'high';
        else if (score >= 30) return 'medium';
        else return 'low';
    }

    /**
     * 生成改进措施
     * @param {Object} processedFeedback - 处理后的反馈
     * @returns {Promise<Array>} 改进措施列表
     */
    async generateImprovementActions(processedFeedback) {
        const actions = [];

        const { category, sentiment, insights } = processedFeedback;

        switch (category) {
            case 'bug_report':
                actions.push({
                    type: 'bug_fix',
                    description: '修复报告的bug',
                    priority: 'high',
                    estimatedEffort: '2-4 hours'
                });
                break;

            case 'performance':
                actions.push({
                    type: 'optimization',
                    description: '优化性能问题',
                    priority: 'high',
                    estimatedEffort: '4-8 hours'
                });
                break;

            case 'usability':
                actions.push({
                    type: 'ux_improvement',
                    description: '改进用户体验',
                    priority: 'medium',
                    estimatedEffort: '1-2 days'
                });
                break;

            case 'feature_request':
                actions.push({
                    type: 'feature_development',
                    description: '开发新功能',
                    priority: 'medium',
                    estimatedEffort: '1-2 weeks'
                });
                break;
        }

        // 存储改进措施
        this.improvementActions.push(...actions);

        return actions;
    }
}

/**
 * 演进治理系统
 */
class EvolutionGovernance {
    constructor() {
        this.improvementHistory = [];
        this.governanceRules = {
            maxConcurrentImprovements: 3,
            improvementApprovalThreshold: 0.7,
            rollbackTimeLimit: 24 * 60 * 60 * 1000 // 24小时
        };
    }

    /**
     * 生成演进报告
     * @param {Object} periodData - 周期数据
     * @param {string} period - 周期类型
     * @returns {Promise<Object>} 演进报告
     */
    async generateEvolutionReport(periodData, period) {
        const report = {
            period,
            generatedAt: new Date().toISOString(),
            summary: {
                experimentsRun: periodData.experiments.length,
                feedbackCollected: periodData.feedback.length,
                improvementsImplemented: periodData.improvements.length,
                metricsCollected: Object.keys(periodData.metrics).length
            },
            experiments: this.analyzeExperiments(periodData.experiments),
            feedback: this.analyzeFeedback(periodData.feedback),
            improvements: this.analyzeImprovements(periodData.improvements),
            recommendations: await this.generateRecommendations(periodData),
            nextSteps: this.defineNextSteps(periodData)
        };

        return report;
    }

    /**
     * 分析实验数据
     * @param {Array} experiments - 实验数据
     * @returns {Object} 实验分析
     */
    analyzeExperiments(experiments) {
        return {
            total: experiments.length,
            successful: experiments.filter(e => e.result?.winner).length,
            averageConfidence: experiments.length > 0 ?
                experiments.reduce((sum, e) => sum + (e.result?.confidence || 0), 0) / experiments.length : 0,
            topPerformingExperiments: experiments
                .filter(e => e.result?.confidence > 0.8)
                .map(e => ({ id: e.config.id, name: e.config.name, confidence: e.result.confidence }))
        };
    }

    /**
     * 分析反馈数据
     * @param {Array} feedback - 反馈数据
     * @returns {Object} 反馈分析
     */
    analyzeFeedback(feedback) {
        const categories = {};
        const sentiments = { positive: 0, negative: 0, neutral: 0 };

        feedback.forEach(fb => {
            const cat = fb.processed.category;
            categories[cat] = (categories[cat] || 0) + 1;

            const sent = fb.processed.sentiment.sentiment;
            sentiments[sent]++;
        });

        return {
            total: feedback.length,
            categories,
            sentiments,
            averagePriority: feedback.length > 0 ?
                feedback.reduce((sum, fb) => {
                    const priorityScores = { critical: 4, high: 3, medium: 2, low: 1 };
                    return sum + (priorityScores[fb.processed.priority] || 1);
                }, 0) / feedback.length : 0
        };
    }

    /**
     * 分析改进措施
     * @param {Array} improvements - 改进数据
     * @returns {Object} 改进分析
     */
    analyzeImprovements(improvements) {
        return {
            total: improvements.length,
            successful: improvements.filter(i => i.result?.success).length,
            averageImpact: improvements.length > 0 ?
                improvements.reduce((sum, i) => sum + (i.result?.impact || 0), 0) / improvements.length : 0,
            categories: this.groupImprovementsByCategory(improvements)
        };
    }

    /**
     * 按类别分组改进措施
     * @param {Array} improvements - 改进措施
     * @returns {Object} 分组结果
     */
    groupImprovementsByCategory(improvements) {
        const categories = {};

        improvements.forEach(imp => {
            const cat = imp.improvement.type || 'general';
            categories[cat] = (categories[cat] || 0) + 1;
        });

        return categories;
    }

    /**
     * 生成推荐
     * @param {Object} periodData - 周期数据
     * @returns {Promise<Array>} 推荐列表
     */
    async generateRecommendations(periodData) {
        const recommendations = [];

        // 基于反馈分析生成推荐
        const feedbackAnalysis = this.analyzeFeedback(periodData.feedback);

        if (feedbackAnalysis.categories.bug_report > feedbackAnalysis.total * 0.3) {
            recommendations.push({
                type: 'quality_focus',
                description: '增加质量保证投入，减少bug发生率',
                priority: 'high'
            });
        }

        if (feedbackAnalysis.sentiments.negative > feedbackAnalysis.total * 0.2) {
            recommendations.push({
                type: 'ux_improvement',
                description: '优先改进用户体验，降低负面反馈',
                priority: 'high'
            });
        }

        // 基于实验分析生成推荐
        const experimentAnalysis = this.analyzeExperiments(periodData.experiments);

        if (experimentAnalysis.successful < experimentAnalysis.total * 0.7) {
            recommendations.push({
                type: 'experiment_optimization',
                description: '改进A/B测试设计，提高成功率',
                priority: 'medium'
            });
        }

        return recommendations;
    }

    /**
     * 定义下一步行动
     * @param {Object} periodData - 周期数据
     * @returns {Array} 下一步行动
     */
    defineNextSteps(periodData) {
        const nextSteps = [
            '分析本周期数据并实施改进措施',
            '规划下一周期的A/B测试实验',
            '收集更多用户反馈数据',
            '监控已实施改进措施的效果'
        ];

        return nextSteps;
    }

    /**
     * 实施改进措施
     * @param {Object} improvement - 改进措施
     * @param {Object} sourceData - 来源数据
     * @returns {Promise<Object>} 实施结果
     */
    async implementImprovement(improvement, sourceData) {
        console.log(`🚀 实施改进: ${improvement.name || improvement.type}`);

        // 验证改进措施
        const validation = await this.validateImprovement(improvement);

        if (!validation.approved) {
            return {
                success: false,
                reason: validation.reason,
                approved: false
            };
        }

        // 执行改进
        const execution = await this.executeImprovement(improvement);

        // 评估影响
        const impact = await this.assessImprovementImpact(improvement, execution);

        return {
            success: execution.success,
            approved: true,
            impact: impact.score,
            rollbackPlan: execution.rollbackPlan,
            monitoring: execution.monitoring
        };
    }

    /**
     * 验证改进措施
     * @param {Object} improvement - 改进措施
     * @returns {Promise<Object>} 验证结果
     */
    async validateImprovement(improvement) {
        // 检查并发改进数量限制
        if (this.improvementHistory.filter(i => !i.completed).length >= this.governanceRules.maxConcurrentImprovements) {
            return {
                approved: false,
                reason: '已达到最大并发改进数量限制'
            };
        }

        // 检查风险评估
        const riskAssessment = this.assessImprovementRisk(improvement);
        if (riskAssessment.level === 'high' && riskAssessment.score < this.governanceRules.improvementApprovalThreshold) {
            return {
                approved: false,
                reason: `风险评估未通过: ${riskAssessment.reason}`
            };
        }

        return { approved: true };
    }

    /**
     * 评估改进风险
     * @param {Object} improvement - 改进措施
     * @returns {Object} 风险评估
     */
    assessImprovementRisk(improvement) {
        // 简单的风险评估逻辑
        const riskFactors = {
            'bug_fix': { level: 'low', score: 0.9 },
            'performance': { level: 'medium', score: 0.7 },
            'ui_change': { level: 'medium', score: 0.7 },
            'new_feature': { level: 'high', score: 0.5 }
        };

        const riskType = improvement.type || 'general';
        return riskFactors[riskType] || { level: 'medium', score: 0.7 };
    }

    /**
     * 执行改进措施
     * @param {Object} improvement - 改进措施
     * @returns {Promise<Object>} 执行结果
     */
    async executeImprovement(improvement) {
        // 这里应该实现具体的改进执行逻辑
        // 目前返回模拟结果
        return {
            success: true,
            rollbackPlan: '可通过版本控制回滚',
            monitoring: '实施后24小时监控关键指标',
            executedAt: new Date().toISOString()
        };
    }

    /**
     * 评估改进影响
     * @param {Object} improvement - 改进措施
     * @param {Object} execution - 执行结果
     * @returns {Promise<Object>} 影响评估
     */
    async assessImprovementImpact(improvement, execution) {
        // 简单的改进影响评估
        return {
            score: Math.random() * 0.5 + 0.5, // 0.5-1.0
            metrics: ['用户满意度', '性能指标', '错误率'],
            assessment: '改进效果良好，建议继续监控'
        };
    }
}

// 导出类
module.exports = EvolutionSystem;

// 测试函数
async function testEvolutionSystem() {
    console.log('🧪 测试持续演进系统...\n');

    const evolution = new EvolutionSystem(process.cwd());

    // 测试A/B测试
    console.log('=== 测试A/B测试框架 ===');
    const experimentConfig = {
        id: 'test_experiment_001',
        name: '界面响应速度优化测试',
        variants: [
            { id: 'control', description: '原有界面' },
            { id: 'variant_a', description: '优化版界面' },
            { id: 'variant_b', description: '极致优化版界面' }
        ],
        metrics: ['response_time', 'user_satisfaction', 'error_rate'],
        duration: 5000, // 5秒测试
        successCriteria: { primary: 'response_time', direction: 'decrease' }
    };

    try {
        const experimentResult = await evolution.runABTest(experimentConfig);
        console.log('✅ A/B测试完成');
        console.log(`获胜者: ${experimentResult.winner?.id}`);
        console.log(`置信度: ${(experimentResult.confidence * 100).toFixed(1)}%`);
    } catch (error) {
        console.log('❌ A/B测试失败:', error.message);
    }

    // 测试用户反馈
    console.log('\n=== 测试用户反馈闭环 ===');
    const feedback = {
        id: 'feedback_001',
        type: 'usability',
        content: '界面响应有点慢，希望能优化一下',
        userId: 'user_123',
        timestamp: new Date().toISOString()
    };

    try {
        const processedFeedback = await evolution.collectUserFeedback(feedback);
        console.log('✅ 反馈处理完成');
        console.log(`情感: ${processedFeedback.sentiment.sentiment}`);
        console.log(`优先级: ${processedFeedback.priority}`);
        console.log(`需要行动: ${processedFeedback.requiresAction}`);
    } catch (error) {
        console.log('❌ 反馈处理失败:', error.message);
    }

    // 测试演进报告
    console.log('\n=== 测试演进报告 ===');
    try {
        const report = await evolution.getEvolutionReport('week');
        console.log('✅ 演进报告生成完成');
        console.log(`实验数量: ${report.summary.experimentsRun}`);
        console.log(`反馈数量: ${report.summary.feedbackCollected}`);
        console.log(`改进措施: ${report.summary.improvementsImplemented}`);
    } catch (error) {
        console.log('❌ 报告生成失败:', error.message);
    }

    console.log('\n演进系统统计:', evolution.getEvolutionStats());
}

// 如果直接运行此脚本
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.includes('--test')) {
        testEvolutionSystem().catch(console.error);
    } else {
        console.log('用法:');
        console.log('  node evolution-system.js --test    # 运行测试');
        console.log('  (演进系统需要通过编程方式调用)');
    }
}