// Cursor AI Rules - 缓存管理器
// 统一管理所有缓存的生命周期和失效机制

const LRUCache = require('./lru-cache');

class CacheManager {
    constructor() {
        this.caches = new Map();
        this.cleanupInterval = 300000; // 5分钟清理一次
        this.isRunning = false;

        // 启动自动清理
        this.startAutoCleanup();
    }

    /**
     * 创建或获取缓存实例
     * @param {string} name - 缓存名称
     * @param {Object} options - 缓存选项
     * @returns {LRUCache} 缓存实例
     */
    getCache(name, options = {}) {
        if (!this.caches.has(name)) {
            const cache = new LRUCache(
                options.maxSize || 100,
                options.ttl || 300000 // 5分钟默认TTL
            );
            this.caches.set(name, cache);
            console.log(`💾 创建缓存实例: ${name} (大小: ${options.maxSize || 100}, TTL: ${(options.ttl || 300000) / 1000}s)`);
        }

        return this.caches.get(name);
    }

    /**
     * 删除缓存实例
     * @param {string} name - 缓存名称
     */
    deleteCache(name) {
        const deleted = this.caches.delete(name);
        if (deleted) {
            console.log(`🗑️ 删除缓存实例: ${name}`);
        }
        return deleted;
    }

    /**
     * 清空所有缓存
     */
    clearAll() {
        this.caches.forEach((cache, name) => {
            cache.clear();
            console.log(`🧹 清空缓存: ${name}`);
        });
    }

    /**
     * 获取缓存统计信息
     * @returns {Object} 所有缓存的统计信息
     */
    getStats() {
        const stats = {
            totalCaches: this.caches.size,
            caches: {},
            overall: {
                totalItems: 0,
                totalHits: 0,
                totalMisses: 0,
                totalEvictions: 0
            }
        };

        for (const [name, cache] of this.caches.entries()) {
            const cacheStats = cache.getStats();
            stats.caches[name] = cacheStats;

            stats.overall.totalItems += cacheStats.size;
            stats.overall.totalHits += cacheStats.hits;
            stats.overall.totalMisses += cacheStats.misses;
            stats.overall.totalEvictions += cacheStats.evictions;
        }

        const totalRequests = stats.overall.totalHits + stats.overall.totalMisses;
        stats.overall.hitRate = totalRequests > 0 ?
            `${(stats.overall.totalHits / totalRequests * 100).toFixed(2)}%` : '0%';

        return stats;
    }

    /**
     * 手动触发缓存清理
     */
    cleanup() {
        console.log('🧽 手动触发缓存清理...');

        let totalCleaned = 0;
        for (const [name, cache] of this.caches.entries()) {
            const beforeSize = cache.size();
            cache.cleanup();
            const afterSize = cache.size();
            const cleaned = beforeSize - afterSize;

            if (cleaned > 0) {
                console.log(`  ${name}: 清理 ${cleaned} 个过期项`);
                totalCleaned += cleaned;
            }
        }

        console.log(`✅ 缓存清理完成，共清理 ${totalCleaned} 个过期项`);
        return totalCleaned;
    }

    /**
     * 启动自动清理
     */
    startAutoCleanup() {
        if (this.isRunning) {
            return;
        }

        this.isRunning = true;
        console.log(`⏰ 启动自动缓存清理 (间隔: ${this.cleanupInterval / 1000}s)`);

        this.cleanupTimer = setInterval(() => {
            this.cleanup();
        }, this.cleanupInterval);
    }

    /**
     * 停止自动清理
     */
    stopAutoCleanup() {
        if (this.cleanupTimer) {
            clearInterval(this.cleanupTimer);
            this.cleanupTimer = null;
            this.isRunning = false;
            console.log('⏸️ 停止自动缓存清理');
        }
    }

    /**
     * 设置清理间隔
     * @param {number} interval - 清理间隔（毫秒）
     */
    setCleanupInterval(interval) {
        this.cleanupInterval = interval;

        // 重新启动清理
        this.stopAutoCleanup();
        this.startAutoCleanup();
    }

    /**
     * 批量操作
     * @param {Object} operations - 批量操作配置
     */
    async batchOperation(operations) {
        const results = {};

        for (const [cacheName, operation] of Object.entries(operations)) {
            const cache = this.getCache(cacheName);

            switch (operation.type) {
                case 'set':
                    if (operation.entries) {
                        cache.setMultiple(operation.entries);
                        results[cacheName] = { success: true, type: 'set' };
                    }
                    break;

                case 'get':
                    if (operation.keys) {
                        results[cacheName] = {
                            success: true,
                            type: 'get',
                            data: cache.getMultiple(operation.keys)
                        };
                    }
                    break;

                case 'clear':
                    cache.clear();
                    results[cacheName] = { success: true, type: 'clear' };
                    break;

                default:
                    results[cacheName] = {
                        success: false,
                        error: `未知操作类型: ${operation.type}`
                    };
            }
        }

        return results;
    }

    /**
     * 导出缓存数据
     * @param {string} cacheName - 缓存名称
     * @returns {Object} 缓存数据
     */
    exportCache(cacheName) {
        const cache = this.caches.get(cacheName);
        if (!cache) {
            return null;
        }

        const data = {};
        for (const key of cache.keys()) {
            data[key] = cache.get(key);
        }

        return {
            name: cacheName,
            exportedAt: new Date().toISOString(),
            data
        };
    }

    /**
     * 导入缓存数据
     * @param {Object} cacheData - 缓存数据
     */
    importCache(cacheData) {
        if (!cacheData.name || !cacheData.data) {
            throw new Error('无效的缓存数据格式');
        }

        const cache = this.getCache(cacheData.name);
        cache.setMultiple(cacheData.data);

        console.log(`📥 导入缓存: ${cacheData.name} (${Object.keys(cacheData.data).length} 项)`);
        return true;
    }

    /**
     * 获取缓存健康状态
     * @returns {Object} 健康状态报告
     */
    getHealthReport() {
        const report = {
            timestamp: new Date().toISOString(),
            status: 'healthy',
            issues: [],
            caches: {}
        };

        for (const [name, cache] of this.caches.entries()) {
            const stats = cache.getStats();
            report.caches[name] = stats;

            // 检查缓存利用率
            if (stats.utilization.replace('%', '') > 90) {
                report.issues.push({
                    type: 'high_utilization',
                    cache: name,
                    message: `缓存利用率过高: ${stats.utilization}`
                });
            }

            // 检查命中率
            if (stats.hitRate.replace('%', '') < 50 && stats.hits + stats.misses > 100) {
                report.issues.push({
                    type: 'low_hit_rate',
                    cache: name,
                    message: `缓存命中率偏低: ${stats.hitRate}`
                });
            }
        }

        if (report.issues.length > 0) {
            report.status = 'warning';
        }

        return report;
    }

    /**
     * 销毁缓存管理器
     */
    destroy() {
        this.stopAutoCleanup();
        this.clearAll();
        console.log('💥 缓存管理器已销毁');
    }
}

// 创建全局单例实例
const globalCacheManager = new CacheManager();

// 导出类和全局实例
module.exports = CacheManager;
module.exports.global = globalCacheManager;