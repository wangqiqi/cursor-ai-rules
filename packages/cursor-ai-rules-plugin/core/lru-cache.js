// Cursor AI Rules - LRU缓存系统
// 基于Least Recently Used算法的缓存实现

class LRUCache {
    constructor(maxSize = 100, ttl = 300000) { // 默认5分钟TTL
        this.maxSize = maxSize;
        this.ttl = ttl;
        this.cache = new Map();
        this.accessOrder = new Map(); // 用于跟踪访问顺序
        this.accessCounter = 0;
        this.stats = {
            hits: 0,
            misses: 0,
            evictions: 0,
            sets: 0
        };
    }

    /**
     * 获取缓存项
     * @param {string} key - 缓存键
     * @returns {*} 缓存值或undefined
     */
    get(key) {
        const item = this.cache.get(key);

        if (!item) {
            this.stats.misses++;
            return undefined;
        }

        // 检查是否过期
        if (this.isExpired(item)) {
            this.delete(key);
            this.stats.misses++;
            return undefined;
        }

        // 更新访问顺序
        this.updateAccessOrder(key);
        this.stats.hits++;

        return item.value;
    }

    /**
     * 设置缓存项
     * @param {string} key - 缓存键
     * @param {*} value - 缓存值
     * @param {number} customTTL - 自定义TTL（可选）
     */
    set(key, value, customTTL = null) {
        const ttl = customTTL || this.ttl;
        const expiresAt = Date.now() + ttl;

        // 如果键已存在，先删除旧的
        if (this.cache.has(key)) {
            this.delete(key);
        }

        // 检查是否需要清理空间
        if (this.cache.size >= this.maxSize) {
            this.evictLRU();
        }

        // 添加新项
        this.cache.set(key, {
            value,
            expiresAt,
            createdAt: Date.now(),
            accessCount: 0
        });

        this.updateAccessOrder(key);
        this.stats.sets++;
    }

    /**
     * 删除缓存项
     * @param {string} key - 缓存键
     * @returns {boolean} 是否成功删除
     */
    delete(key) {
        const deleted = this.cache.delete(key);
        if (deleted) {
            this.accessOrder.delete(key);
        }
        return deleted;
    }

    /**
     * 清空缓存
     */
    clear() {
        this.cache.clear();
        this.accessOrder.clear();
        this.resetStats();
    }

    /**
     * 检查键是否存在且未过期
     * @param {string} key - 缓存键
     * @returns {boolean} 是否存在
     */
    has(key) {
        const item = this.cache.get(key);
        return item && !this.isExpired(item);
    }

    /**
     * 获取缓存大小
     * @returns {number} 缓存中的项数
     */
    size() {
        // 清理过期项
        this.cleanup();
        return this.cache.size;
    }

    /**
     * 获取所有键
     * @returns {Array} 键数组
     */
    keys() {
        this.cleanup();
        return Array.from(this.cache.keys());
    }

    /**
     * 获取缓存统计信息
     * @returns {Object} 统计信息
     */
    getStats() {
        const totalRequests = this.stats.hits + this.stats.misses;
        const hitRate = totalRequests > 0 ? (this.stats.hits / totalRequests * 100).toFixed(2) : 0;

        return {
            ...this.stats,
            size: this.size(),
            maxSize: this.maxSize,
            hitRate: `${hitRate}%`,
            utilization: `${((this.size() / this.maxSize) * 100).toFixed(2)}%`
        };
    }

    /**
     * 重置统计信息
     */
    resetStats() {
        this.stats = {
            hits: 0,
            misses: 0,
            evictions: 0,
            sets: 0
        };
    }

    /**
     * 检查项是否过期
     * @param {Object} item - 缓存项
     * @returns {boolean} 是否过期
     */
    isExpired(item) {
        return Date.now() > item.expiresAt;
    }

    /**
     * 更新访问顺序
     * @param {string} key - 缓存键
     */
    updateAccessOrder(key) {
        this.accessCounter++;
        this.accessOrder.set(key, this.accessCounter);

        const item = this.cache.get(key);
        if (item) {
            item.accessCount++;
        }
    }

    /**
     * 淘汰最少使用的项 (LRU)
     */
    evictLRU() {
        if (this.accessOrder.size === 0) {
            return;
        }

        // 找到访问计数最小的项
        let lruKey = null;
        let minAccess = Infinity;

        for (const [key, accessCount] of this.accessOrder.entries()) {
            if (accessCount < minAccess) {
                minAccess = accessCount;
                lruKey = key;
            }
        }

        if (lruKey) {
            this.delete(lruKey);
            this.stats.evictions++;
        }
    }

    /**
     * 清理过期项
     */
    cleanup() {
        const now = Date.now();
        const expiredKeys = [];

        for (const [key, item] of this.cache.entries()) {
            if (now > item.expiresAt) {
                expiredKeys.push(key);
            }
        }

        expiredKeys.forEach(key => this.delete(key));
    }

    /**
     * 批量设置
     * @param {Object} entries - 键值对对象
     */
    setMultiple(entries) {
        Object.entries(entries).forEach(([key, value]) => {
            this.set(key, value);
        });
    }

    /**
     * 批量获取
     * @param {Array} keys - 键数组
     * @returns {Object} 结果对象
     */
    getMultiple(keys) {
        const result = {};
        keys.forEach(key => {
            const value = this.get(key);
            if (value !== undefined) {
                result[key] = value;
            }
        });
        return result;
    }

    /**
     * 获取或设置 (缓存模式)
     * @param {string} key - 缓存键
     * @param {Function} factory - 值工厂函数
     * @param {number} customTTL - 自定义TTL
     * @returns {*} 缓存值
     */
    async getOrSet(key, factory, customTTL = null) {
        let value = this.get(key);

        if (value === undefined) {
            value = await factory();
            this.set(key, value, customTTL);
        }

        return value;
    }

    /**
     * 同步版本的获取或设置
     * @param {string} key - 缓存键
     * @param {Function} factory - 值工厂函数
     * @param {number} customTTL - 自定义TTL
     * @returns {*} 缓存值
     */
    getOrSetSync(key, factory, customTTL = null) {
        let value = this.get(key);

        if (value === undefined) {
            value = factory();
            this.set(key, value, customTTL);
        }

        return value;
    }
}

// 导出类
module.exports = LRUCache;