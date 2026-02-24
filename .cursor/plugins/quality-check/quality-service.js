// 质量检查插件服务
// 封装 quality-manager.sh，提供可编程的质量检查接口

const path = require('path');
const { execSync } = require('child_process');

class QualityService {
    constructor(projectRoot, options = {}) {
        this.projectRoot = projectRoot;
        this.options = options;
        this.cursorDir = path.join(projectRoot, '.cursor');
        this.qualityManagerPath = path.join(this.cursorDir, 'core', 'quality-manager.sh');
        this.initialized = false;
    }

    async initialize() {
        if (!require('fs').existsSync(this.qualityManagerPath)) {
            throw new Error(`quality-manager.sh 不存在: ${this.qualityManagerPath}`);
        }
        this.initialized = true;
    }

    /**
     * 执行质量检查
     * @param {string} mode - lint | format | report | pre-push-check
     * @returns {Object} 检查结果
     */
    async runCheck(mode = 'lint') {
        if (!this.initialized) await this.initialize();

        try {
            const result = execSync(
                `bash "${this.qualityManagerPath}" ${mode}`,
                { cwd: this.projectRoot, encoding: 'utf8', timeout: 60000 }
            );
            return { success: true, output: result, mode };
        } catch (err) {
            return {
                success: false,
                output: err.stdout || err.message,
                error: err.stderr,
                mode
            };
        }
    }

    cleanup() {
        this.initialized = false;
    }
}

module.exports = QualityService;
