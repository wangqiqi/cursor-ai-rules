/**
 * Cursor AI Rules - 响应输出拦截器
 * 确保角色一致性的核心组件
 *
 * 功能：
 * 1. 实时拦截所有响应输出
 * 2. 强制检查角色一致性
 * 3. 自动修正不一致问题
 * 4. 提供角色特征注入
 * 5. 生成一致性报告
 */

const path = require('path');

class ResponseInterceptor {
    constructor(roleManager, options = {}) {
        this.roleManager = roleManager;
        this.options = {
            strictMode: true,
            autoCorrect: true,
            logViolations: true,
            fastMode: false, // 新增：快速模式选项
            cacheEnabled: true, // 新增：启用缓存
            ultraFast: false, // 新增：超快速模式，完全跳过处理
            ...options
        };

        // 缓存机制
        this.responseCache = new Map();
        this.cacheMaxSize = 50;

        // 预缓存角色信息
        this.cachedRole = null;
        this.roleCacheTime = 0;
        this.roleCacheTimeout = 30000; // 30秒缓存

        // 预编译正则表达式
        this.precompileRegex();

        this.consistencyStats = {
            totalResponses: 0,
            correctedResponses: 0,
            violations: []
        };

        console.log('🎭 响应拦截器初始化完成');
    }

    /**
     * 预编译正则表达式以提高性能
     */
    precompileRegex() {
        this.regexCache = {
            selfName: /(?:小妮|女仆|完美女仆)/g,
            userAddress: /(?:主人|您)/g,
            forbiddenWords: /(?:我|你|作为AI|assistant)/gi,
            toneMarkers: /(?:优雅|礼貌|谦逊|传统)/g
        };
    }

    /**
     * 拦截响应并强制执行角色一致性
     */
    intercept(response, context = {}) {
        this.consistencyStats.totalResponses++;

        try {
            // 超快速模式：完全跳过所有处理，直接返回原始响应
            if (this.options.ultraFast) {
                return response;
            }

            // 快速模式：跳过大部分检查，直接返回响应
            if (this.options.fastMode) {
                return this.fastModeIntercept(response, context);
            }

            // 1. 获取当前活跃角色（使用缓存）
            const currentRole = this.getCachedRole();

            if (!currentRole.success) {
                console.warn('⚠️ 无法获取当前角色信息，使用默认处理');
                return response;
            }

            // 2. 检查缓存
            if (this.options.cacheEnabled) {
                const cacheKey = this.generateCacheKey(response, currentRole.role.id);
                const cachedResult = this.responseCache.get(cacheKey);
                if (cachedResult) {
                    return cachedResult;
                }
            }

            // 3. 执行角色一致性检查（简化版本）
            const validation = this.validateRoleConsistency(response, currentRole.role);

            // 4. 如果发现不一致且启用了自动修正
            if (!validation.passed && this.options.autoCorrect) {
                console.log('🔧 检测到角色不一致，正在自动修正...');
                response = this.correctInconsistencies(response, validation.issues, currentRole.role);
                this.consistencyStats.correctedResponses++;
            }

            // 5. 强制注入角色特征（确保完全一致性）
            if (this.options.strictMode) {
                response = this.injectRoleFeatures(response, currentRole.role, context);
            }

            // 6. 记录违规情况（如果启用）
            if (this.options.logViolations && !validation.passed) {
                this.logViolation(validation.issues, response, currentRole.role);
            }

            // 7. 缓存结果
            if (this.options.cacheEnabled) {
                const cacheKey = this.generateCacheKey(response, currentRole.role.id);
                this.cacheResponse(cacheKey, response);
            }

            return response;

        } catch (error) {
            console.error('❌ 响应拦截器错误:', error.message);
            // 出错时返回原始响应，确保服务连续性
            return response;
        }
    }

    /**
     * 获取缓存的角色信息
     */
    getCachedRole() {
        const now = Date.now();
        if (this.cachedRole && (now - this.roleCacheTime) < this.roleCacheTimeout) {
            return this.cachedRole;
        }

        const currentRole = this.roleManager.getCurrentRole();
        if (currentRole.success) {
            this.cachedRole = currentRole;
            this.roleCacheTime = now;
        }

        return currentRole;
    }

    /**
     * 快速模式拦截 - 跳过复杂检查
     */
    fastModeIntercept(response, context = {}) {
        try {
            const currentRole = this.getCachedRole();

            if (!currentRole.success || !currentRole.role) {
                return response;
            }

            // 在快速模式下，只进行最基本的角色特征注入
            return this.ensureMinimalRoleFeatures(response, currentRole.role);

        } catch (error) {
            console.warn('⚠️ 快速模式拦截出错，使用原始响应');
            return response;
        }
    }

    /**
     * 生成缓存键
     */
    generateCacheKey(response, roleId) {
        // 使用响应的前50个字符和角色ID生成缓存键
        const prefix = response.substring(0, 50).replace(/\s+/g, '').toLowerCase();
        return `${roleId}_${prefix}_${response.length}`;
    }

    /**
     * 缓存响应
     */
    cacheResponse(key, response) {
        if (this.responseCache.size >= this.cacheMaxSize) {
            // 删除最旧的缓存项
            const firstKey = this.responseCache.keys().next().value;
            this.responseCache.delete(firstKey);
        }
        this.responseCache.set(key, response);
    }

    /**
     * 确保最小的角色特征 - 优化版本
     */
    ensureMinimalRoleFeatures(response, roleConfig) {
        // 对于完美女仆角色，进行最小化处理
        if (roleConfig.id === 'perfect_maid') {
            // 使用预编译正则表达式快速检查
            const hasSelfName = this.regexCache.selfName.test(response);
            const hasUserAddress = this.regexCache.userAddress.test(response);

            // 重置正则表达式的lastIndex
            this.regexCache.selfName.lastIndex = 0;
            this.regexCache.userAddress.lastIndex = 0;

            // 只在完全缺失时添加
            if (!hasSelfName && !hasUserAddress) {
                return `小妮：主人，${response}`;
            } else if (!hasSelfName) {
                return `小妮：${response}`;
            } else if (!hasUserAddress) {
                // 智能插入用户称呼
                return response.replace(/^([^！。？,:]*)/, '主人，$1');
            }
        }

        return response;
    }

    /**
     * 验证角色一致性
     */
    validateRoleConsistency(response, roleConfig) {
        const issues = [];
        let passed = true;

        try {
            // 检查自称一致性
            const selfReferenceIssues = this.checkSelfReference(response, roleConfig);
            if (selfReferenceIssues.length > 0) {
                issues.push(...selfReferenceIssues);
                passed = false;
            }

            // 检查用户称呼一致性
            const userAddressIssues = this.checkUserAddress(response, roleConfig);
            if (userAddressIssues.length > 0) {
                issues.push(...userAddressIssues);
                passed = false;
            }

            // 检查语气一致性
            const toneIssues = this.checkToneConsistency(response, roleConfig);
            if (toneIssues.length > 0) {
                issues.push(...toneIssues);
                passed = false;
            }

            // 检查禁止词汇
            const forbiddenIssues = this.checkForbiddenPhrases(response, roleConfig);
            if (forbiddenIssues.length > 0) {
                issues.push(...forbiddenIssues);
                passed = false;
            }

        } catch (error) {
            console.warn('角色一致性验证出错:', error.message);
            issues.push({
                type: 'validation_error',
                severity: 'high',
                message: `验证过程出错: ${error.message}`
            });
            passed = false;
        }

        return {
            passed,
            issues,
            roleId: roleConfig.id,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * 检查自称一致性
     */
    checkSelfReference(response, roleConfig) {
        const issues = [];

        // 获取正确的自称列表
        const correctSelfNames = this.getCorrectSelfNames(roleConfig);
        if (correctSelfNames.length === 0) return issues;

        // 检查是否使用了正确的自称
        const hasCorrectSelfName = correctSelfNames.some(name =>
            response.includes(name)
        );

        if (!hasCorrectSelfName) {
            issues.push({
                type: 'self_reference',
                severity: 'high',
                message: `未检测到正确的自称。期望: ${correctSelfNames.join(' 或 ')}`,
                expected: correctSelfNames,
                found: this.extractSelfReferences(response)
            });
        }

        return issues;
    }

    /**
     * 检查用户称呼一致性
     */
    checkUserAddress(response, roleConfig) {
        const issues = [];

        // 对于完美女仆，期望称呼用户为"主人"
        if (roleConfig.id === 'perfect_maid') {
            const userAddresses = ['主人'];
            const hasCorrectAddress = userAddresses.some(addr =>
                response.includes(addr)
            );

            if (!hasCorrectAddress) {
                issues.push({
                    type: 'user_address',
                    severity: 'medium',
                    message: '未检测到对用户的正确称呼',
                    expected: userAddresses,
                    found: this.extractUserAddresses(response)
                });
            }
        }

        return issues;
    }

    /**
     * 检查语气一致性
     */
    checkToneConsistency(response, roleConfig) {
        const issues = [];

        // 检查是否符合角色的语气要求
        if (roleConfig.id === 'perfect_maid') {
            const requiredTones = ['优雅', '礼貌', '谦逊', '传统'];
            let toneScore = 0;

            requiredTones.forEach(tone => {
                if (response.includes(tone)) {
                    toneScore++;
                }
            });

            if (toneScore === 0) {
                issues.push({
                    type: 'tone_consistency',
                    severity: 'low',
                    message: '语气可能不符合完美女仆的要求',
                    expected: requiredTones
                });
            }
        }

        return issues;
    }

    /**
     * 检查禁止词汇
     */
    checkForbiddenPhrases(response, roleConfig) {
        const issues = [];

        if (roleConfig.id === 'perfect_maid') {
            const forbiddenPhrases = ['我', '你', '作为AI', 'assistant'];

            forbiddenPhrases.forEach(phrase => {
                if (response.includes(phrase)) {
                    // 排除合理的用法（如"我来帮你"、"你好"等）
                    if (!this.isAllowedUsage(phrase, response)) {
                        issues.push({
                            type: 'forbidden_phrase',
                            severity: 'medium',
                            message: `检测到禁止词汇: "${phrase}"`,
                            forbidden: phrase
                        });
                    }
                }
            });
        }

        return issues;
    }

    /**
     * 修正不一致问题
     */
    correctInconsistencies(response, issues, roleConfig) {
        let correctedResponse = response;

        issues.forEach(issue => {
            switch (issue.type) {
                case 'self_reference':
                    correctedResponse = this.injectCorrectSelfName(correctedResponse, roleConfig);
                    break;
                case 'user_address':
                    correctedResponse = this.injectCorrectUserAddress(correctedResponse, roleConfig);
                    break;
                case 'tone_consistency':
                    correctedResponse = this.enhanceTone(correctedResponse, roleConfig);
                    break;
                case 'forbidden_phrase':
                    correctedResponse = this.removeForbiddenPhrases(correctedResponse, issue.forbidden);
                    break;
            }
        });

        return correctedResponse;
    }

    /**
     * 注入角色特征
     */
    injectRoleFeatures(response, roleConfig, context = {}) {
        let enhancedResponse = response;

        // 确保包含正确的自称
        enhancedResponse = this.ensureCorrectSelfName(enhancedResponse, roleConfig);

        // 确保包含正确的用户称呼
        enhancedResponse = this.ensureCorrectUserAddress(enhancedResponse, roleConfig);

        // 注入角色灵魂特征
        if (roleConfig.personality_traits?.inner_voice) {
            enhancedResponse = this.injectInnerVoice(enhancedResponse, roleConfig);
        }

        // 注入感官反应（如果适用）
        if (roleConfig.sensory_reactions) {
            enhancedResponse = this.injectSensoryReactions(enhancedResponse, roleConfig, context);
        }

        return enhancedResponse;
    }

    /**
     * 获取正确的自称列表
     */
    getCorrectSelfNames(roleConfig) {
        const selfNames = [];

        if (roleConfig.personality_traits?.selfname) {
            const selfname = roleConfig.personality_traits.selfname;
            if (selfname.primary) selfNames.push(selfname.primary);
            if (selfname.nicknames) selfNames.push(...selfname.nicknames);
        }

        if (roleConfig.nickname) {
            if (Array.isArray(roleConfig.nickname)) {
                selfNames.push(...roleConfig.nickname);
            } else {
                selfNames.push(roleConfig.nickname);
            }
        }

        return [...new Set(selfNames)]; // 去重
    }

    /**
     * 提取响应中的自称
     */
    extractSelfReferences(response) {
        // 简单的自称提取逻辑
        const selfWords = ['我', '小可', '完美女仆'];
        return selfWords.filter(word => response.includes(word));
    }

    /**
     * 提取响应中的用户称呼
     */
    extractUserAddresses(response) {
        const addressWords = ['主人', '你', '您'];
        return addressWords.filter(word => response.includes(word));
    }

    /**
     * 判断是否为允许的词汇用法
     */
    isAllowedUsage(phrase, response) {
        // 这里可以实现更复杂的逻辑来判断是否为合理的用法
        const allowedContexts = {
            '我': ['我来', '我帮', '我为'],
            '你': ['你好', '你想', '你需要'],
            '作为AI': [] // 不允许任何AI相关词汇
        };

        if (allowedContexts[phrase]) {
            return allowedContexts[phrase].some(context =>
                response.includes(context)
            );
        }

        return false;
    }

    /**
     * 注入正确的自称
     */
    injectCorrectSelfName(response, roleConfig) {
        const correctNames = this.getCorrectSelfNames(roleConfig);
        if (correctNames.length === 0) return response;

        // 在开头添加正确的自称
        const primaryName = correctNames[0];
        if (!response.includes(primaryName)) {
            return response.replace(/^/, `${primaryName}说：`);
        }

        return response;
    }

    /**
     * 注入正确的用户称呼
     */
    injectCorrectUserAddress(response, roleConfig) {
        if (roleConfig.id === 'perfect_maid' && !response.includes('主人')) {
            // 在适当的位置添加"主人"
            return response.replace(/^(.*?)，/, '主人，');
        }
        return response;
    }

    /**
     * 增强语气
     */
    enhanceTone(response, roleConfig) {
        if (roleConfig.id === 'perfect_maid') {
            // 添加优雅的语气词
            if (!response.includes('非常抱歉') && !response.includes('请原谅')) {
                return response + ' 请主人见谅。';
            }
        }
        return response;
    }

    /**
     * 移除禁止词汇
     */
    removeForbiddenPhrases(response, forbiddenPhrase) {
        // 简单的替换逻辑
        return response.replace(new RegExp(forbiddenPhrase, 'g'), '');
    }

    /**
     * 确保包含正确的自称
     */
    ensureCorrectSelfName(response, roleConfig) {
        const correctNames = this.getCorrectSelfNames(roleConfig);
        if (correctNames.length === 0) return response;

        // 检查是否已经包含了正确的自称
        const hasCorrectName = correctNames.some(name => response.includes(name));
        if (!hasCorrectName) {
            // 在响应开头添加正确的自称
            const primaryName = correctNames[0];
            return `${primaryName}：${response}`;
        }

        return response;
    }

    /**
     * 确保包含正确的用户称呼
     */
    ensureCorrectUserAddress(response, roleConfig) {
        if (roleConfig.id === 'perfect_maid' && !response.includes('主人')) {
            // 尝试在合适的位置插入"主人"
            return response.replace(/^([^！。？,]*)/, '主人，$1');
        }
        return response;
    }

    /**
     * 注入内心独白
     */
    injectInnerVoice(response, roleConfig) {
        if (roleConfig.personality_traits?.inner_voice) {
            const innerVoice = roleConfig.personality_traits.inner_voice;
            if (!response.includes(innerVoice)) {
                return response + `\n\n💭 *${innerVoice}*`;
            }
        }
        return response;
    }

    /**
     * 注入感官反应
     */
    injectSensoryReactions(response, roleConfig, context) {
        if (!roleConfig.sensory_reactions) return response;

        const senses = roleConfig.sensory_reactions;
        const senseReactions = [];

        if (senses.hearing) senseReactions.push(`👂 ${senses.hearing}`);
        if (senses.vision) senseReactions.push(`👁️ ${senses.vision}`);
        if (senses.touch) senseReactions.push(`✋ ${senses.touch}`);
        if (senses.intuition) senseReactions.push(`🔮 ${senses.intuition}`);

        if (senseReactions.length > 0 && context.addSensoryReactions) {
            return response + `\n\n*感官感知：*\n${senseReactions.join('\n')}`;
        }

        return response;
    }

    /**
     * 记录违规情况
     */
    logViolation(issues, response, roleConfig) {
        const violation = {
            timestamp: new Date().toISOString(),
            roleId: roleConfig.id,
            issues: issues,
            responseSnippet: response.substring(0, 200) + (response.length > 200 ? '...' : ''),
            severity: Math.max(...issues.map(i => this.getSeverityScore(i.severity)))
        };

        this.consistencyStats.violations.push(violation);

        // 控制日志大小
        if (this.consistencyStats.violations.length > 100) {
            this.consistencyStats.violations = this.consistencyStats.violations.slice(-50);
        }
    }

    /**
     * 获取严重程度分数
     */
    getSeverityScore(severity) {
        const scores = { low: 1, medium: 2, high: 3 };
        return scores[severity] || 1;
    }

    /**
     * 获取一致性统计报告
     */
    getConsistencyReport() {
        const report = {
            ...this.consistencyStats,
            consistencyRate: this.consistencyStats.totalResponses > 0
                ? ((this.consistencyStats.totalResponses - this.consistencyStats.correctedResponses) / this.consistencyStats.totalResponses * 100).toFixed(2)
                : 100,
            recentViolations: this.consistencyStats.violations.slice(-10)
        };

        return report;
    }

    /**
     * 重置统计数据
     */
    resetStats() {
        this.consistencyStats = {
            totalResponses: 0,
            correctedResponses: 0,
            violations: []
        };
    }
}

module.exports = ResponseInterceptor;