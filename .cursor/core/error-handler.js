// Cursor AI Rules - 统一错误处理系统
// 提供人性化的错误信息和智能修复建议

class ErrorHandler {
    /**
     * 格式化错误信息，提供结构化输出和修复建议
     * @param {Error} error - 原始错误对象
     * @param {Object} context - 错误上下文信息
     * @returns {Object} 格式化后的错误信息
     */
    static formatError(error, context = {}) {
        return {
            type: error.name || 'UnknownError',
            message: error.message || '未知错误',
            context: context,
            timestamp: new Date().toISOString(),
            suggestions: this.generateSuggestions(error),
            stack: error.stack,
            severity: this.determineSeverity(error)
        };
    }

    /**
     * 生成针对性错误修复建议
     * @param {Error} error - 错误对象
     * @returns {Array} 修复建议列表
     */
    static generateSuggestions(error) {
        const errorName = error.name;
        const errorMessage = error.message.toLowerCase();

        // 网络相关错误
        if (errorName === 'NetworkError' || errorMessage.includes('network') || errorMessage.includes('connection')) {
            return [
                '检查网络连接是否正常',
                '验证代理设置是否正确',
                '尝试更换国内镜像源',
                '检查防火墙设置',
                '确认目标服务是否可用'
            ];
        }

        // 权限相关错误
        if (errorName === 'PermissionError' || errorMessage.includes('permission') || errorMessage.includes('access denied')) {
            return [
                '检查文件/目录权限设置',
                '验证当前用户角色和权限',
                '确认目录所有权',
                '尝试以管理员权限运行',
                '检查文件锁定状态'
            ];
        }

        // 配置相关错误
        if (errorName === 'ConfigError' || errorMessage.includes('config') || errorMessage.includes('configuration')) {
            return [
                '验证配置文件格式是否正确',
                '检查必需字段是否完整',
                '更新配置版本',
                '检查配置文件路径',
                '验证配置值范围'
            ];
        }

        // 文件系统错误
        if (errorMessage.includes('no such file') || errorMessage.includes('not found')) {
            return [
                '检查文件路径是否正确',
                '确认文件是否存在',
                '验证工作目录',
                '检查文件权限',
                '尝试绝对路径'
            ];
        }

        // 内存相关错误
        if (errorMessage.includes('memory') || errorMessage.includes('heap')) {
            return [
                '增加内存限制',
                '优化内存使用',
                '检查内存泄漏',
                '重启应用',
                '减少并发操作'
            ];
        }

        // 默认建议
        return [
            '查看详细错误日志',
            '检查系统环境配置',
            '尝试重新运行操作',
            '联系技术支持团队'
        ];
    }

    /**
     * 确定错误严重程度
     * @param {Error} error - 错误对象
     * @returns {string} 严重程度: 'low' | 'medium' | 'high' | 'critical'
     */
    static determineSeverity(error) {
        const errorMessage = error.message.toLowerCase();
        const errorName = error.name;

        // 严重错误
        if (errorName === 'ConstitutionViolationError' ||
            errorMessage.includes('constitution') ||
            errorMessage.includes('security')) {
            return 'critical';
        }

        // 高严重度错误
        if (errorName === 'PermissionError' ||
            errorMessage.includes('permission') ||
            errorMessage.includes('access denied')) {
            return 'high';
        }

        // 中等严重度错误
        if (errorName === 'NetworkError' ||
            errorMessage.includes('network') ||
            errorMessage.includes('timeout')) {
            return 'medium';
        }

        // 低严重度错误
        return 'low';
    }

    /**
     * 记录错误到日志系统
     * @param {Error} error - 错误对象
     * @param {Object} context - 上下文信息
     */
    static logError(error, context = {}) {
        const formattedError = this.formatError(error, context);

        console.error(`❌ [${formattedError.severity.toUpperCase()}] ${formattedError.type}: ${formattedError.message}`);
        console.error(`📅 时间: ${formattedError.timestamp}`);
        console.error(`🔍 上下文:`, formattedError.context);

        if (formattedError.suggestions.length > 0) {
            console.error(`💡 建议修复步骤:`);
            formattedError.suggestions.forEach((suggestion, index) => {
                console.error(`   ${index + 1}. ${suggestion}`);
            });
        }

        // 可以扩展到写入文件日志
        this.writeToLogFile(formattedError);
    }

    /**
     * 写入错误日志到文件
     * @param {Object} formattedError - 格式化后的错误信息
     */
    static async writeToLogFile(formattedError) {
        try {
            const fs = require('fs').promises;
            const path = require('path');

            // 确定日志文件路径
            const logDir = path.join(process.cwd(), '.cursorGrowth', 'monitoring', 'logs');
            await fs.mkdir(logDir, { recursive: true });

            const logFile = path.join(logDir, 'error.log');
            const logEntry = JSON.stringify(formattedError) + '\n';

            await fs.appendFile(logFile, logEntry);
        } catch (logError) {
            // 避免日志写入失败导致递归错误
            console.warn('⚠️ 无法写入错误日志:', logError.message);
        }
    }

    /**
     * 创建用户友好的错误响应
     * @param {Error} error - 原始错误
     * @param {Object} context - 上下文信息
     * @returns {Object} 用户友好的错误响应
     */
    static createUserFriendlyResponse(error, context = {}) {
        const formattedError = this.formatError(error, context);

        return {
            success: false,
            error: {
                title: this.getErrorTitle(formattedError),
                message: formattedError.message,
                suggestions: formattedError.suggestions,
                severity: formattedError.severity,
                canRetry: this.canRetry(error)
            },
            timestamp: formattedError.timestamp
        };
    }

    /**
     * 获取用户友好的错误标题
     * @param {Object} formattedError - 格式化错误
     * @returns {string} 错误标题
     */
    static getErrorTitle(formattedError) {
        const titleMap = {
            'NetworkError': '网络连接问题',
            'PermissionError': '权限访问问题',
            'ConfigError': '配置参数问题',
            'ValidationError': '数据验证问题',
            'TimeoutError': '操作超时问题',
            'ConstitutionViolationError': '宪法合规性警告'
        };

        return titleMap[formattedError.type] || '操作执行失败';
    }

    /**
     * 判断操作是否可以重试
     * @param {Error} error - 错误对象
     * @returns {boolean} 是否可以重试
     */
    static canRetry(error) {
        const errorName = error.name;
        const errorMessage = error.message.toLowerCase();

        // 可以重试的错误类型
        const retryableErrors = [
            'NetworkError',
            'TimeoutError',
            'TemporaryFailureError'
        ];

        // 包含重试关键词的错误信息
        const retryableKeywords = [
            'timeout',
            'temporary',
            'retry',
            'unavailable'
        ];

        return retryableErrors.includes(errorName) ||
            retryableKeywords.some(keyword => errorMessage.includes(keyword));
    }
}

// 导出类
module.exports = ErrorHandler;

// 测试函数
async function testErrorHandler() {
    console.log('🧪 测试错误处理系统...\n');

    // 测试不同类型的错误
    const testErrors = [
        new Error('Network connection failed'),
        new Error('Permission denied: cannot access file'),
        new Error('Configuration file not found'),
        new Error('Constitution violation detected')
    ];

    for (const error of testErrors) {
        console.log(`测试错误: ${error.message}`);
        ErrorHandler.logError(error, { component: 'test', userId: 'test-user' });
        console.log('---');
    }

    console.log('✅ 错误处理系统测试完成');
}

// 如果直接运行此脚本
if (require.main === module) {
    testErrorHandler().catch(console.error);
}