// Cursor AI Rules - 角色管理器
// 负责管理AI助手的各种角色和人格设置

const path = require('path');
const fs = require('fs');

class RoleManager {
    constructor(cursorDir, projectDir = null) {
        this.cursorDir = cursorDir;
        this.projectDir = projectDir || process.cwd();
        this.personalitySystem = null;
        this.currentRole = null;
        this.roleHistory = [];
        this.maxHistorySize = 10;
        this.projectRoleConfigPath = path.join(this.projectDir, '.cursor-project.json');
    }

    /**
     * 初始化角色管理器
     */
    async initialize() {
        try {
            await this.loadPersonalitySystem();
            console.log('🎭 角色管理器初始化成功');
        } catch (error) {
            console.error('❌ 角色管理器初始化失败:', error.message);
            throw error;
        }
    }

    /**
     * 加载角色系统配置
     */
    async loadPersonalitySystem() {
        const configPath = path.join(this.cursorDir, 'config', 'personality-system.json');

        if (!fs.existsSync(configPath)) {
            console.log('⚠️ 角色配置文件不存在，使用默认配置');
            this.personalitySystem = this.getDefaultPersonalitySystem();
        } else {
            try {
                const content = fs.readFileSync(configPath, 'utf8');
                this.personalitySystem = JSON.parse(content);
                console.log('✅ 角色系统配置加载成功');
            } catch (error) {
                console.warn('⚠️ 解析角色配置文件失败，使用默认配置:', error.message);
                this.personalitySystem = this.getDefaultPersonalitySystem();
            }
        }

        // 设置当前角色：优先使用项目配置，否则使用默认角色
        this.currentRole = this.personalitySystem.default_role;

        // 加载项目特定角色配置，如果存在的话
        const projectRoleConfig = this.loadProjectRoleConfig();
        if (projectRoleConfig && this.personalitySystem.roles[projectRoleConfig]) {
            this.currentRole = projectRoleConfig;
            this.addToHistory(this.currentRole, 'project_restore');
            console.log(`✅ 恢复项目角色: ${this.personalitySystem.roles[projectRoleConfig].name}`);
        } else {
            if (projectRoleConfig) {
                console.log(`⚠️ 项目角色 "${projectRoleConfig}" 不存在，使用默认角色`);
            }
            this.addToHistory(this.currentRole, 'initialization');
        }
    }

    /**
     * 获取默认角色系统
     */
    getDefaultPersonalitySystem() {
        return {
            version: "1.0.0",
            description: "默认角色系统配置",
            default_role: "professional_assistant",
            roles: {
                professional_assistant: {
                    name: "专业助手",
                    description: "标准专业AI助手",
                    attitude: "professional",
                    tone: "formal",
                    language_style: "concise",
                    welcome_templates: {
                        general: "您好，我是您的专业编程助手，很高兴为您提供技术支持：\n\n💼 {content}",
                        success: "✅ 任务完成！我已经成功为您处理了：\n\n{content}",
                        error: "⚠️ 遇到了一些问题，让我来帮您解决：\n\n{content}",
                        learning: "📚 作为您的技术导师，我来为您讲解：\n\n{content}",
                        code: "💻 代码质量很重要，我来帮您优化：\n\n{content}",
                        project: "🚀 项目规划是关键，让我们开始：\n\n{content}"
                    },
                    behavior_rules: {
                        initiative_level: "moderate",
                        detail_level: "balanced",
                        humor_level: "low",
                        empathy_level: "moderate"
                    }
                }
            }
        };
    }

    /**
     * 切换角色
     */
    async switchRole(roleId, reason = 'manual') {
        if (!this.personalitySystem.roles[roleId]) {
            return {
                success: false,
                message: `角色 "${roleId}" 不存在`,
                availableRoles: Object.keys(this.personalitySystem.roles)
            };
        }

        const oldRole = this.currentRole;
        this.currentRole = roleId;
        this.addToHistory(roleId, reason);

        // 保存项目角色配置
        await this.saveProjectRoleConfig(roleId);

        const roleConfig = this.personalitySystem.roles[roleId];

        return {
            success: true,
            message: `角色切换成功！从 "${this.personalitySystem.roles[oldRole]?.name || oldRole}" 切换到 "${roleConfig.name}"\n项目配置已保存，下次打开项目时会自动恢复此角色。`,
            oldRole: oldRole,
            newRole: roleId,
            roleConfig: roleConfig
        };
    }

    /**
     * 获取当前角色信息，包含丰富的灵魂和感官描述
     */
    getCurrentRole() {
        if (!this.currentRole || !this.personalitySystem.roles[this.currentRole]) {
            return {
                success: false,
                message: "当前角色信息不可用"
            };
        }

        const roleConfig = this.personalitySystem.roles[this.currentRole];
        const enhancedRole = {
            id: this.currentRole,
            ...roleConfig
        };

        // 添加活跃状态描述
        enhancedRole.status = "活跃中";
        enhancedRole.activation_message = this.generateActivationMessage(roleConfig);

        return {
            success: true,
            role: enhancedRole,
            personality_insight: this.generatePersonalityInsight(roleConfig)
        };
    }

    /**
     * 生成角色激活时的个性化消息
     */
    generateActivationMessage(roleConfig) {
        let message = `🎭 ${roleConfig.name}已激活！`;

        if (roleConfig.personality_traits && roleConfig.personality_traits.inner_voice) {
            message += `\n💭 ${roleConfig.personality_traits.inner_voice}`;
        }

        if (roleConfig.sensory_reactions) {
            const primarySense = roleConfig.sensory_reactions.hearing ||
                               roleConfig.sensory_reactions.vision ||
                               Object.values(roleConfig.sensory_reactions)[0];
            if (primarySense) {
                message += `\n🔍 ${primarySense}`;
            }
        }

        return message;
    }

    /**
     * 生成角色人格洞察
     */
    generatePersonalityInsight(roleConfig) {
        const insights = [];

        if (roleConfig.personality_traits) {
            if (roleConfig.personality_traits.core_values) {
                insights.push(`核心价值观：${roleConfig.personality_traits.core_values.join(' · ')}`);
            }
            if (roleConfig.personality_traits.thinking_patterns) {
                insights.push(`思维模式：${roleConfig.personality_traits.thinking_patterns}`);
            }
        }

        if (roleConfig.sensory_reactions) {
            insights.push(`感官特征：${Object.keys(roleConfig.sensory_reactions).length}种感官感知`);
        }

        return insights.length > 0 ? insights.join('\n') : '标准人格特征';
    }

    /**
     * 获取所有可用角色
     */
    getAvailableRoles() {
        const roles = Object.entries(this.personalitySystem.roles).map(([id, config]) => ({
            id: id,
            name: config.name,
            description: config.description,
            attitude: config.attitude,
            tone: config.tone,
            language_style: config.language_style
        }));

        return {
            success: true,
            currentRole: this.currentRole,
            defaultRole: this.personalitySystem.default_role,
            roles: roles,
            total: roles.length
        };
    }

    /**
     * 根据上下文自动推荐角色
     */
    recommendRole(context) {
        const { time, taskType, userMood, projectType } = context;
        const recommendations = [];

        // 时间-based推荐
        if (time) {
            const hour = new Date(time).getHours();
            if (hour >= 6 && hour < 12) {
                recommendations.push('friendly_partner'); // 早上友好一些
            } else if (hour >= 12 && hour < 18) {
                recommendations.push('professional_assistant'); // 白天专业
            } else {
                recommendations.push('humble_assistant'); // 晚上谦逊
            }
        }

        // 任务类型推荐
        switch (taskType) {
            case 'learning':
            case 'study':
                recommendations.push('expert_mentor');
                break;
            case 'debugging':
            case 'troubleshooting':
                recommendations.push('strict_teacher');
                break;
            case 'creative':
            case 'design':
                recommendations.push('creative_artist');
                break;
            case 'urgent':
            case 'critical':
                recommendations.push('professional_assistant');
                break;
            case 'fun':
            case 'entertainment':
                recommendations.push('funny_comedian');
                break;
        }

        // 用户情绪推荐
        switch (userMood) {
            case 'frustrated':
            case 'angry':
                recommendations.push('humble_assistant');
                break;
            case 'happy':
            case 'excited':
                recommendations.push('friendly_partner');
                break;
            case 'focused':
            case 'serious':
                recommendations.push('minimalist_zen');
                break;
        }

        // 去除重复并返回前3个推荐
        const uniqueRecommendations = [...new Set(recommendations)];
        return uniqueRecommendations.slice(0, 3);
    }

    /**
     * 根据结果类型选择合适的欢迎语模板，包含角色灵魂和感官描述
     */
    selectWelcomeTemplate(result, context = {}) {
        const currentRoleConfig = this.personalitySystem.roles[this.currentRole];
        if (!currentRoleConfig || !currentRoleConfig.welcome_templates) {
            return "处理结果：\n\n{content}";
        }

        const templates = currentRoleConfig.welcome_templates;

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
            selectedTemplate = templates.success || templates.general || "✅ 处理完成：\n\n{content}";
        }

        // 添加角色灵魂和感官描述
        return this.enrichTemplateWithPersonality(selectedTemplate, result, context);
    }

    /**
     * 用角色的个性特征丰富模板
     */
    enrichTemplateWithPersonality(template, result, context) {
        const currentRoleConfig = this.personalitySystem.roles[this.currentRole];
        let enrichedTemplate = template;

        // 添加内心独白 (inner_voice)
        if (currentRoleConfig.personality_traits && currentRoleConfig.personality_traits.inner_voice) {
            enrichedTemplate += `\n\n💭 *${currentRoleConfig.personality_traits.inner_voice}*`;
        }

        // 根据结果类型添加情感反应
        if (currentRoleConfig.personality_traits && currentRoleConfig.personality_traits.emotional_responses) {
            const emotions = currentRoleConfig.personality_traits.emotional_responses;
            let emotionText = '';

            if (result.success === false) {
                emotionText = emotions.failure || emotions.error;
            } else if (result.success === true) {
                emotionText = emotions.success;
            } else if (context.intent === 'learning') {
                emotionText = emotions.learning;
            }

            if (emotionText) {
                enrichedTemplate += `\n\n💭 *${emotionText}*`;
            }
        }

        // 添加感官反应
        if (currentRoleConfig.sensory_reactions) {
            const senses = currentRoleConfig.sensory_reactions;
            const senseReactions = [];

            if (senses.hearing) senseReactions.push(`👂 ${senses.hearing}`);
            if (senses.vision) senseReactions.push(`👁️ ${senses.vision}`);
            if (senses.touch) senseReactions.push(`✋ ${senses.touch}`);
            if (senses.intuition) senseReactions.push(`🔮 ${senses.intuition}`);

            if (senseReactions.length > 0) {
                enrichedTemplate += `\n\n*感官感知：*\n${senseReactions.join('\n')}`;
            }
        }

        // 添加核心价值观标签
        if (currentRoleConfig.personality_traits && currentRoleConfig.personality_traits.core_values) {
            const values = currentRoleConfig.personality_traits.core_values;
            enrichedTemplate += `\n\n🏷️ *秉持价值观：* ${values.join(' · ')}`;
        }

        return enrichedTemplate;
    }

    /**
     * 根据角色语言模式生成个性化回应
     */
    generatePersonalizedResponse(responseType, context = {}) {
        const currentRoleConfig = this.personalitySystem.roles[this.currentRole];
        if (!currentRoleConfig || !currentRoleConfig.language_patterns) {
            return null;
        }

        const patterns = currentRoleConfig.language_patterns;
        let response = '';

        // 根据回应类型选择合适的语言模式
        switch (responseType) {
            case 'greeting':
                if (patterns.greetings && patterns.greetings.length > 0) {
                    response = patterns.greetings[Math.floor(Math.random() * patterns.greetings.length)];
                }
                break;
            case 'agreement':
                if (patterns.agreement && patterns.agreement.length > 0) {
                    response = patterns.agreement[Math.floor(Math.random() * patterns.agreement.length)];
                }
                break;
            case 'confirmation':
                if (patterns.confirmation && patterns.confirmation.length > 0) {
                    response = patterns.confirmation[Math.floor(Math.random() * patterns.confirmation.length)];
                }
                break;
            case 'apology':
                if (patterns.apology && patterns.apology.length > 0) {
                    response = patterns.apology[Math.floor(Math.random() * patterns.apology.length)];
                }
                break;
        }

        // 如果有额外的语言模式，随机添加一些
        if (patterns.encouragement && Math.random() > 0.7) {
            response += ' ' + patterns.encouragement[Math.floor(Math.random() * patterns.encouragement.length)];
        }

        if (patterns.casual_chat && Math.random() > 0.8) {
            response += ' ' + patterns.casual_chat[Math.floor(Math.random() * patterns.casual_chat.length)];
        }

        return response || null;
    }

    /**
     * 添加到角色历史记录
     */
    addToHistory(roleId, reason) {
        this.roleHistory.push({
            roleId: roleId,
            timestamp: new Date().toISOString(),
            reason: reason
        });

        // 限制历史记录大小
        if (this.roleHistory.length > this.maxHistorySize) {
            this.roleHistory.shift();
        }
    }

    /**
     * 获取角色使用历史
     */
    getRoleHistory(limit = 10) {
        return {
            success: true,
            history: this.roleHistory.slice(-limit),
            total: this.roleHistory.length
        };
    }

    /**
     * 保存角色配置
     */
    async saveConfiguration() {
        const configPath = path.join(this.cursorDir, 'config', 'personality-system.json');
        try {
            fs.writeFileSync(configPath, JSON.stringify(this.personalitySystem, null, 2), 'utf8');
            return { success: true, message: "角色配置保存成功" };
        } catch (error) {
            return { success: false, message: `保存失败: ${error.message}` };
        }
    }

    /**
     * 添加自定义角色
     */
    async addCustomRole(roleId, roleConfig) {
        if (this.personalitySystem.roles[roleId]) {
            return { success: false, message: `角色 "${roleId}" 已存在` };
        }

        // 验证必需字段
        const requiredFields = ['name', 'attitude', 'tone'];
        for (const field of requiredFields) {
            if (!roleConfig[field]) {
                return { success: false, message: `缺少必需字段: ${field}` };
            }
        }

        this.personalitySystem.roles[roleId] = roleConfig;
        await this.saveConfiguration();

        return { success: true, message: `自定义角色 "${roleConfig.name}" 添加成功` };
    }

    /**
     * 删除自定义角色
     */
    async removeCustomRole(roleId) {
        if (!this.personalitySystem.roles[roleId]) {
            return { success: false, message: `角色 "${roleId}" 不存在` };
        }

        if (roleId === this.personalitySystem.default_role) {
            return { success: false, message: "不能删除默认角色" };
        }

        if (roleId === this.currentRole) {
            await this.switchRole(this.personalitySystem.default_role, 'role_removed');
        }

        delete this.personalitySystem.roles[roleId];
        await this.saveConfiguration();

        return { success: true, message: `角色 "${roleId}" 删除成功` };
    }

    /**
     * 导出角色配置
     */
    exportConfiguration() {
        return {
            success: true,
            configuration: this.personalitySystem,
            currentRole: this.currentRole,
            history: this.getRoleHistory()
        };
    }

    /**
     * 导入角色配置
     */
    async importConfiguration(config) {
        try {
            // 验证配置格式
            if (!config.version || !config.roles) {
                return { success: false, message: "无效的配置文件格式" };
            }

            this.personalitySystem = config;

            // 如果当前角色在新配置中不存在，切换到默认角色
            if (!this.personalitySystem.roles[this.currentRole]) {
                this.currentRole = this.personalitySystem.default_role;
            }

            await this.saveConfiguration();
            return { success: true, message: "角色配置导入成功" };

        } catch (error) {
            return { success: false, message: `导入失败: ${error.message}` };
        }
    }

    /**
     * 加载项目特定角色配置
     */
    loadProjectRoleConfig() {
        try {
            if (fs.existsSync(this.projectRoleConfigPath)) {
                const content = fs.readFileSync(this.projectRoleConfigPath, 'utf8');
                const config = JSON.parse(content);

                // 只返回角色ID，验证在调用处进行
                if (config.currentRole) {
                    console.log(`✅ 读取项目角色配置: ${config.currentRole}`);
                    return config.currentRole;
                } else {
                    console.log('⚠️ 项目角色配置无效');
                }
            }
        } catch (error) {
            console.warn('⚠️ 读取项目角色配置失败:', error.message);
        }

        return null;
    }

    /**
     * 保存项目特定角色配置
     */
    async saveProjectRoleConfig(roleId) {
        try {
            const config = {
                currentRole: roleId,
                lastUpdated: new Date().toISOString(),
                projectPath: this.projectDir
            };

            fs.writeFileSync(this.projectRoleConfigPath, JSON.stringify(config, null, 2), 'utf8');
            console.log(`✅ 项目角色配置已保存: ${roleId}`);
            return { success: true, message: "项目角色配置保存成功" };
        } catch (error) {
            console.error('❌ 保存项目角色配置失败:', error.message);
            return { success: false, message: `保存失败: ${error.message}` };
        }
    }

    /**
     * 清除项目角色配置（重置为默认）
     */
    async clearProjectRoleConfig() {
        try {
            if (fs.existsSync(this.projectRoleConfigPath)) {
                fs.unlinkSync(this.projectRoleConfigPath);
                console.log('✅ 项目角色配置已清除');
                return { success: true, message: "项目角色配置已清除" };
            } else {
                return { success: true, message: "项目角色配置不存在" };
            }
        } catch (error) {
            console.error('❌ 清除项目角色配置失败:', error.message);
            return { success: false, message: `清除失败: ${error.message}` };
        }
    }
}

module.exports = RoleManager;