/**
 * Cursor AI Rules - Token使用监控器
 * 实时监控token消耗，提供预警和优化建议
 */

const fs = require('fs').promises;
const path = require('path');

class TokenMonitor {
    constructor(options = {}) {
        this.options = {
            warningThreshold: options.warningThreshold || 800,
            criticalThreshold: options.criticalThreshold || 1000,
            monitoringEnabled: options.monitoringEnabled !== false,
            alertEnabled: options.alertEnabled !== false,
            logFile: options.logFile || path.join(__dirname, '..', '..', '.cursorGrowth', 'analytics', 'token-usage.log'),
            ...options
        };

        this.currentSession = {
            startTime: Date.now(),
            totalTokens: 0,
            totalRequests: 0,
            peakUsage: 0,
            alertsTriggered: 0
        };

        this.usageHistory = [];
        this.maxHistorySize = 1000;

        this.alerts = {
            WARNING: '⚠️ Token使用接近上限',
            CRITICAL: '🚨 Token使用已达到上限，建议优化',
            OPTIMIZATION: '💡 发现优化机会，可节省tokens'
        };
    }

    /**
     * 记录token使用情况
     */
    recordUsage(operation, tokenCount, metadata = {}) {
        if (!this.options.monitoringEnabled) return;

        const usageRecord = {
            timestamp: Date.now(),
            operation,
            tokenCount,
            metadata,
            sessionId: this.currentSession.startTime
        };

        // 更新当前会话统计
        this.currentSession.totalTokens += tokenCount;
        this.currentSession.totalRequests++;
        if (tokenCount > this.currentSession.peakUsage) {
            this.currentSession.peakUsage = tokenCount;
        }

        // 添加到历史记录
        this.usageHistory.push(usageRecord);
        if (this.usageHistory.length > this.maxHistorySize) {
            this.usageHistory.shift();
        }

        // 检查是否需要预警
        this.checkThresholds(tokenCount);

        // 异步写入日志
        this.logUsage(usageRecord).catch(err =>
            console.warn('Token监控日志写入失败:', err.message)
        );
    }

    /**
     * 检查阈值并触发预警
     */
    checkThresholds(currentUsage) {
        if (!this.options.alertEnabled) return;

        // 检查单次使用量
        if (currentUsage >= this.options.criticalThreshold) {
            this.triggerAlert('CRITICAL', {
                currentUsage,
                threshold: this.options.criticalThreshold,
                suggestion: '考虑使用压缩模式或简化请求'
            });
        } else if (currentUsage >= this.options.warningThreshold) {
            this.triggerAlert('WARNING', {
                currentUsage,
                threshold: this.options.warningThreshold,
                suggestion: '建议启用token优化'
            });
        }

        // 检查会话总量
        const sessionAverage = this.currentSession.totalTokens / Math.max(this.currentSession.totalRequests, 1);
        if (sessionAverage > this.options.warningThreshold * 0.8) {
            this.triggerAlert('OPTIMIZATION', {
                sessionAverage: Math.round(sessionAverage),
                totalRequests: this.currentSession.totalRequests,
                suggestion: '会话平均token使用较高，建议启用批量处理'
            });
        }
    }

    /**
     * 触发预警
     */
    triggerAlert(type, data) {
        const alert = {
            type,
            timestamp: Date.now(),
            message: this.alerts[type] || '未知预警',
            data,
            session: this.currentSession
        };

        this.currentSession.alertsTriggered++;

        // 输出预警信息
        console.warn(`[${new Date().toISOString()}] ${alert.message}`);
        if (data.suggestion) {
            console.warn(`建议: ${data.suggestion}`);
        }

        // 这里可以扩展为发送通知、邮件等
        this.handleAlert(alert);
    }

    /**
     * 处理预警（可扩展）
     */
    handleAlert(alert) {
        // 可以在这里添加:
        // - 发送桌面通知
        // - 写入专门的预警日志
        // - 触发自动优化
        // - 发送到监控系统

        // 暂时只记录到控制台
        if (process.env.NODE_ENV === 'development') {
            console.log('Token预警详情:', JSON.stringify(alert, null, 2));
        }
    }

    /**
     * 异步写入使用日志
     */
    async logUsage(record) {
        const logEntry = JSON.stringify(record) + '\n';

        try {
            await fs.appendFile(this.options.logFile, logEntry);
        } catch (error) {
            // 确保日志目录存在
            const logDir = path.dirname(this.options.logFile);
            await fs.mkdir(logDir, { recursive: true });
            await fs.appendFile(this.options.logFile, logEntry);
        }
    }

    /**
     * 获取使用统计
     */
    getUsageStats(timeRange = 3600000) { // 默认1小时
        const cutoffTime = Date.now() - timeRange;
        const recentUsage = this.usageHistory.filter(record => record.timestamp >= cutoffTime);

        const stats = {
            totalRequests: recentUsage.length,
            totalTokens: recentUsage.reduce((sum, record) => sum + record.tokenCount, 0),
            averageTokens: 0,
            peakUsage: 0,
            timeRange,
            operations: {}
        };

        if (recentUsage.length > 0) {
            stats.averageTokens = Math.round(stats.totalTokens / recentUsage.length);
            stats.peakUsage = Math.max(...recentUsage.map(r => r.tokenCount));

            // 按操作统计
            recentUsage.forEach(record => {
                stats.operations[record.operation] = stats.operations[record.operation] || { count: 0, tokens: 0 };
                stats.operations[record.operation].count++;
                stats.operations[record.operation].tokens += record.tokenCount;
            });
        }

        return stats;
    }

    /**
     * 获取优化建议
     */
    getOptimizationSuggestions() {
        const stats = this.getUsageStats();
        const suggestions = [];

        // 基于使用模式的建议
        if (stats.averageTokens > 600) {
            suggestions.push({
                type: 'HIGH_USAGE',
                priority: 'HIGH',
                message: '平均token使用量较高',
                suggestion: '启用minimal压缩模式，减少响应长度'
            });
        }

        if (stats.peakUsage > 900) {
            suggestions.push({
                type: 'PEAK_USAGE',
                priority: 'CRITICAL',
                message: '存在高峰token使用',
                suggestion: '检查是否存在冗长响应，考虑分页或流式输出'
            });
        }

        // 检查是否有重复的操作模式
        const operationCounts = Object.values(stats.operations);
        const highFrequencyOps = operationCounts.filter(op => op.count > 5);

        if (highFrequencyOps.length > 0) {
            suggestions.push({
                type: 'FREQUENT_OPERATIONS',
                priority: 'MEDIUM',
                message: '发现高频重复操作',
                suggestion: '考虑实现操作缓存或批量处理'
            });
        }

        return suggestions;
    }

    /**
     * 重置会话统计
     */
    resetSession() {
        this.currentSession = {
            startTime: Date.now(),
            totalTokens: 0,
            totalRequests: 0,
            peakUsage: 0,
            alertsTriggered: 0
        };
    }

    /**
     * 获取当前会话信息
     */
    getCurrentSession() {
        return {
            ...this.currentSession,
            duration: Date.now() - this.currentSession.startTime,
            averageTokens: this.currentSession.totalRequests > 0 ?
                Math.round(this.currentSession.totalTokens / this.currentSession.totalRequests) : 0
        };
    }

    /**
     * 生成使用报告
     */
    generateReport() {
        const session = this.getCurrentSession();
        const stats = this.getUsageStats();
        const suggestions = this.getOptimizationSuggestions();

        return {
            session,
            statistics: stats,
            optimizationSuggestions: suggestions,
            generatedAt: new Date().toISOString()
        };
    }
}

module.exports = TokenMonitor;