// Cursor AI Rules - 角色管理器
// 负责管理AI助手的各种角色和人格设置

const path = require('path');
const fs = require('fs');

class RoleManager {
    constructor(cursorDir) {
        this.cursorDir = cursorDir;
        this.personalitySystem = null;
        this.currentRole = null;
        this.roleHistory = [];
        this.maxHistorySize = 10;
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

        // 设置默认角色
        this.currentRole = this.personalitySystem.default_role;
        this.addToHistory(this.currentRole, 'initialization');
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

        const roleConfig = this.personalitySystem.roles[roleId];

        return {
            success: true,
            message: `角色切换成功！从 "${this.personalitySystem.roles[oldRole]?.name || oldRole}" 切换到 "${roleConfig.name}"`,
            oldRole: oldRole,
            newRole: roleId,
            roleConfig: roleConfig
        };
    }

    /**
     * 获取当前角色信息
     */
    getCurrentRole() {
        if (!this.currentRole || !this.personalitySystem.roles[this.currentRole]) {
            return {
                success: false,
                message: "当前角色信息不可用"
            };
        }

        return {
            success: true,
            role: {
                id: this.currentRole,
                ...this.personalitySystem.roles[this.currentRole]
            }
        };
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
     * 根据结果类型选择合适的欢迎语模板
     */
    selectWelcomeTemplate(result, context = {}) {
        const currentRoleConfig = this.personalitySystem.roles[this.currentRole];
        if (!currentRoleConfig || !currentRoleConfig.welcome_templates) {
            return "处理结果：\n\n{content}";
        }

        const templates = currentRoleConfig.welcome_templates;

        // 根据结果类型选择模板
        if (result.success === false) {
            return templates.error || templates.general || "⚠️ 处理遇到问题：\n\n{content}";
        }

        // 根据意图选择模板
        if (context.intent) {
            switch (context.intent) {
                case 'learning':
                    return templates.learning || templates.general;
                case 'creation':
                case 'project':
                    return templates.project || templates.general;
                case 'optimization':
                case 'code':
                    return templates.code || templates.general;
                default:
                    return templates.general;
            }
        }

        // 默认使用成功模板
        return templates.success || templates.general || "✅ 处理完成：\n\n{content}";
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
}

module.exports = RoleManager;