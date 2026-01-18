// Cursor AI Rules - 智能缓存系统
// 实现三级缓存策略：内存 → 文件 → 网络

const fs = require('fs').promises;
const path = require('path');

class SmartCache {
    constructor(options = {}) {
        this.options = {
            maxMemorySize: options.maxMemorySize || 100, // 内存缓存最大条目数
            maxFileSize: options.maxFileSize || 1000, // 文件缓存最大条目数
            defaultTTL: options.defaultTTL || 300000, // 默认TTL 5分钟
            cacheDir: options.cacheDir || path.join(__dirname, '..', '..', '.cursorGrowth', 'cache'),
            ...options
        };

        // 三级缓存层
        this.layers = {
            memory: new Map(),
            file: new Map(),
            network: new Map()
        };

        // 缓存统计
        this.stats = {
            hits: 0,
            misses: 0,
            evictions: 0,
            memoryHits: 0,
            fileHits: 0,
            networkHits: 0
        };

        // 初始化缓存目录
        this.initCacheDir();
    }

    /**
     * 初始化缓存目录
     */
    async initCacheDir() {
        try {
            await fs.mkdir(this.options.cacheDir, { recursive: true });
        } catch (error) {
            console.warn('⚠️ 无法创建缓存目录:', error.message);
        }
    }

    /**
     * 获取缓存数据（三级缓存策略）
     * @param {string} key - 缓存键
     * @param {Function} fetcher - 数据获取函数（网络层）
     * @param {number} ttl - 生存时间（毫秒）
     * @returns {Promise<any>} 缓存的数据
     */
    async get(key, fetcher, ttl = this.options.defaultTTL) {
        // 1. 检查内存缓存
        const memoryData = this.layers.memory.get(key);
        if (memoryData && Date.now() - memoryData.timestamp < ttl) {
            this.stats.hits++;
            this.stats.memoryHits++;
            return memoryData.value;
        }

        // 2. 检查文件缓存
        const fileData = await this.checkFileCache(key, ttl);
        if (fileData !== null) {
            // 将文件数据提升到内存缓存
            this.layers.memory.set(key, { value: fileData, timestamp: Date.now() });
            this.stats.hits++;
            this.stats.fileHits++;
            return fileData;
        }

        // 3. 网络获取（或计算）
        try {
            this.stats.misses++;
            const data = await fetcher();
            await this.saveToFileCache(key, data);
            this.layers.memory.set(key, { value: data, timestamp: Date.now() });
            return data;
        } catch (error) {
            throw new Error(`缓存获取失败: ${error.message}`);
        }
    }

    /**
     * 检查文件缓存
     * @param {string} key - 缓存键
     * @param {number} ttl - 生存时间
     * @returns {Promise<any|null>} 缓存数据或null
     */
    async checkFileCache(key, ttl) {
        try {
            const filePath = this.getCacheFilePath(key);
            const stats = await fs.stat(filePath);

            // 检查文件是否过期
            if (Date.now() - stats.mtime.getTime() > ttl) {
                // 删除过期文件
                await fs.unlink(filePath).catch(() => {});
                return null;
            }

            const data = await fs.readFile(filePath, 'utf8');
            return JSON.parse(data);
        } catch (error) {
            return null;
        }
    }

    /**
     * 保存数据到文件缓存
     * @param {string} key - 缓存键
     * @param {any} data - 要缓存的数据
     */
    async saveToFileCache(key, data) {
        try {
            const filePath = this.getCacheFilePath(key);
            const cacheData = {
                key,
                data,
                timestamp: Date.now(),
                version: '1.0'
            };

            await fs.writeFile(filePath, JSON.stringify(cacheData, null, 2));

            // 维护文件缓存大小
            await this.maintainFileCacheSize();
        } catch (error) {
            console.warn('⚠️ 文件缓存写入失败:', error.message);
        }
    }

    /**
     * 获取缓存文件路径
     * @param {string} key - 缓存键
     * @returns {string} 文件路径
     */
    getCacheFilePath(key) {
        // 使用键的哈希值作为文件名，避免特殊字符问题
        const hash = require('crypto').createHash('md5').update(key).digest('hex');
        return path.join(this.options.cacheDir, `${hash}.json`);
    }

    /**
     * 维护文件缓存大小（LRU策略）
     */
    async maintainFileCacheSize() {
        try {
            const files = await fs.readdir(this.options.cacheDir);
            const cacheFiles = files
                .filter(file => file.endsWith('.json'))
                .map(file => ({
                    name: file,
                    path: path.join(this.options.cacheDir, file),
                    stats: null
                }));

            // 获取文件统计信息
            for (const file of cacheFiles) {
                try {
                    file.stats = await fs.stat(file.path);
                } catch (error) {
                    // 文件可能已被删除
                    continue;
                }
            }

            // 按访问时间排序（LRU）
            cacheFiles.sort((a, b) => {
                if (!a.stats || !b.stats) return 0;
                return a.stats.atime.getTime() - b.stats.atime.getTime();
            });

            // 删除超出限制的文件
            if (cacheFiles.length > this.options.maxFileSize) {
                const filesToDelete = cacheFiles.slice(0, cacheFiles.length - this.options.maxFileSize);
                for (const file of filesToDelete) {
                    try {
                        await fs.unlink(file.path);
                        this.stats.evictions++;
                    } catch (error) {
                        // 删除失败，可能是并发操作
                    }
                }
            }
        } catch (error) {
            console.warn('⚠️ 缓存大小维护失败:', error.message);
        }
    }

    /**
     * 维护内存缓存大小
     */
    maintainMemoryCacheSize() {
        if (this.layers.memory.size > this.options.maxMemorySize) {
            // LRU策略：删除最久未使用的条目
            const entries = Array.from(this.layers.memory.entries());
            entries.sort((a, b) => a[1].timestamp - b[1].timestamp);

            const entriesToDelete = entries.slice(0, this.layers.memory.size - this.options.maxMemorySize);
            for (const [key] of entriesToDelete) {
                this.layers.memory.delete(key);
                this.stats.evictions++;
            }
        }
    }

    /**
     * 手动设置缓存
     * @param {string} key - 缓存键
     * @param {any} value - 缓存值
     * @param {number} ttl - 生存时间
     */
    set(key, value, ttl = this.options.defaultTTL) {
        this.layers.memory.set(key, {
            value,
            timestamp: Date.now(),
            ttl
        });

        // 维护内存缓存大小
        this.maintainMemoryCacheSize();

        // 异步保存到文件缓存
        this.saveToFileCache(key, value);
    }

    /**
     * 删除缓存
     * @param {string} key - 缓存键
     */
    async delete(key) {
        // 删除内存缓存
        this.layers.memory.delete(key);

        // 删除文件缓存
        try {
            const filePath = this.getCacheFilePath(key);
            await fs.unlink(filePath);
        } catch (error) {
            // 文件可能不存在
        }
    }

    /**
     * 清空所有缓存
     */
    async clear() {
        // 清空内存缓存
        this.layers.memory.clear();

        // 清空文件缓存
        try {
            const files = await fs.readdir(this.options.cacheDir);
            for (const file of files) {
                if (file.endsWith('.json')) {
                    await fs.unlink(path.join(this.options.cacheDir, file));
                }
            }
        } catch (error) {
            console.warn('⚠️ 清空文件缓存失败:', error.message);
        }

        // 重置统计
        this.stats = {
            hits: 0,
            misses: 0,
            evictions: 0,
            memoryHits: 0,
            fileHits: 0,
            networkHits: 0
        };
    }

    /**
     * 获取缓存统计信息
     * @returns {Object} 统计信息
     */
    getStats() {
        const totalRequests = this.stats.hits + this.stats.misses;
        const hitRate = totalRequests > 0 ? (this.stats.hits / totalRequests * 100).toFixed(1) + '%' : '0%';

        return {
            ...this.stats,
            totalRequests,
            hitRate,
            memorySize: this.layers.memory.size,
            fileCacheDir: this.options.cacheDir
        };
    }

    /**
     * 获取命中率
     * @returns {string} 命中率百分比
     */
    getHitRate() {
        const total = this.stats.hits + this.stats.misses;
        return total > 0 ? (this.stats.hits / total * 100).toFixed(1) + '%' : '0%';
    }

    /**
     * 检查缓存是否存在且未过期
     * @param {string} key - 缓存键
     * @param {number} ttl - 生存时间
     * @returns {Promise<boolean>} 是否存在有效缓存
     */
    async has(key, ttl = this.options.defaultTTL) {
        // 检查内存缓存
        const memoryData = this.layers.memory.get(key);
        if (memoryData && Date.now() - memoryData.timestamp < ttl) {
            return true;
        }

        // 检查文件缓存
        return await this.checkFileCache(key, ttl) !== null;
    }
}

// 导出类
module.exports = SmartCache;

// 测试函数
async function testSmartCache() {
    console.log('🧪 测试智能缓存系统...\n');

    const cache = new SmartCache({
        maxMemorySize: 10,
        maxFileSize: 50,
        defaultTTL: 10000 // 10秒TTL用于测试
    });

    // 测试基本功能
    console.log('1. 测试基本缓存操作...');

    // 设置缓存
    cache.set('test:key1', { data: 'value1' });
    cache.set('test:key2', { data: 'value2' });

    // 获取缓存
    const value1 = await cache.get('test:key1', async () => {
        console.log('   🔄 从网络获取 key1');
        return { data: 'network_value1' };
    });
    console.log('   ✅ 获取 key1:', value1);

    // 再次获取（应该命中缓存）
    const value1Again = await cache.get('test:key1', async () => {
        console.log('   ❌ 不应该调用网络获取');
        return { data: 'error' };
    });
    console.log('   ✅ 再次获取 key1:', value1Again);

    // 测试网络获取
    console.log('\n2. 测试网络获取...');
    const networkValue = await cache.get('test:network', async () => {
        console.log('   🌐 模拟网络请求...');
        await new Promise(resolve => setTimeout(resolve, 100));
        return { data: 'from_network', timestamp: Date.now() };
    });
    console.log('   ✅ 网络获取结果:', networkValue);

    // 测试统计信息
    console.log('\n3. 测试统计信息...');
    const stats = cache.getStats();
    console.log('   📊 缓存统计:', {
        总请求数: stats.totalRequests,
        命中数: stats.hits,
        命中率: stats.hitRate,
        内存缓存大小: stats.memorySize
    });

    // 测试缓存清理
    console.log('\n4. 测试缓存清理...');
    await cache.clear();
    const clearedStats = cache.getStats();
    console.log('   🧹 清理后统计:', clearedStats);

    console.log('\n✅ 智能缓存系统测试完成');
}

// 如果直接运行此脚本
if (require.main === module) {
    testSmartCache().catch(console.error);
}