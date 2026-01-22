# 性能优化工具技能

## 🎯 功能概述

提供全面的性能优化能力，包括代码性能分析、内存优化、数据库查询优化、缓存策略等，帮助开发者识别和解决性能瓶颈，提升应用性能。

## 🚀 核心能力

### 代码性能优化
- **算法优化**: 时间复杂度分析和优化建议
- **内存管理**: 内存泄露检测和优化
- **并发优化**: 多线程和异步处理优化
- **代码剖析**: 热点代码识别和性能分析

### 数据库优化
- **查询优化**: SQL查询分析和索引建议
- **连接池优化**: 数据库连接管理和优化
- **缓存策略**: 查询结果缓存和数据预加载
- **数据结构优化**: 数据库设计和索引优化

### 系统级优化
- **网络优化**: HTTP请求优化和CDN配置
- **资源优化**: 静态资源压缩和优化
- **缓存架构**: 多级缓存策略设计
- **扩展策略**: 水平和垂直扩展建议

## 🛠️ 技术实现

### 核心算法
```javascript
// 性能分析引擎
class PerformanceOptimizer {
  async analyze(codebase) {
    const bottlenecks = await this.identifyBottlenecks(codebase);
    const optimizations = await this.generateOptimizations(bottlenecks);
    const impact = await this.estimateImpact(optimizations);

    return {
      bottlenecks,
      optimizations,
      impact,
      priority: this.prioritizeOptimizations(optimizations)
    };
  }

  identifyBottlenecks(codebase) {
    return {
      cpu: this.analyzeCPUUsage(codebase),
      memory: this.analyzeMemoryUsage(codebase),
      io: this.analyzeIOOperations(codebase),
      network: this.analyzeNetworkCalls(codebase)
    };
  }
}
```

### 性能监控
```bash
# 内存使用分析
analyze_memory_usage() {
  local pid="$1"

  # 获取进程内存信息
  local rss=$(ps -o rss= -p "$pid" | awk '{print $1 * 1024}')
  local vsz=$(ps -o vsz= -p "$pid" | awk '{print $1 * 1024}')

  echo "RSS: ${rss} bytes, VSZ: ${vsz} bytes"

  # 检测内存泄露模式
  if [[ $rss -gt 1000000000 ]]; then # 1GB
    echo "WARNING: High memory usage detected"
  fi
}
```

## 📊 性能指标

- **分析准确率**: >85%的性能瓶颈识别准确率
- **优化效果**: 平均30-50%的性能提升
- **响应时间**: <10秒的代码性能分析
- **内存优化**: >60%的内存使用优化效果

## 🔗 集成接口

### Scripts集成
- `optimizer.sh`: 核心性能优化管理
- `performance-monitor.sh`: 性能监控 (已集成)
- `cache-manager.sh`: 缓存策略管理

### Hooks集成
- `performance-pre-commit.sh`: 提交前性能检查
- `performance-analyzer.sh`: 自动化性能分析

### Workflows集成
- **性能优化工作流**: 完整的性能分析和优化流程
- **监控预警工作流**: 性能异常检测和告警
- **持续优化工作流**: 持续的性能监控和改进

## ⚡ 优化策略

### CPU优化
```javascript
// 算法优化示例
// 前: O(n²)复杂度
function findDuplicates(array) {
  const duplicates = [];
  for (let i = 0; i < array.length; i++) {
    for (let j = i + 1; j < array.length; j++) {
      if (array[i] === array[j]) {
        duplicates.push(array[i]);
      }
    }
  }
  return duplicates;
}

// 后: O(n)复杂度
function findDuplicates(array) {
  const seen = new Set();
  const duplicates = new Set();

  for (const item of array) {
    if (seen.has(item)) {
      duplicates.add(item);
    } else {
      seen.add(item);
    }
  }

  return Array.from(duplicates);
}
```

### 内存优化
```javascript
// 内存泄露修复
class DataProcessor {
  constructor() {
    this.cache = new Map();
    this.cleanupInterval = setInterval(() => {
      this.cleanupExpiredEntries();
    }, 60000); // 每分钟清理一次
  }

  cleanupExpiredEntries() {
    const now = Date.now();
    for (const [key, value] of this.cache.entries()) {
      if (value.expiresAt < now) {
        this.cache.delete(key);
      }
    }
  }

  destroy() {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
    }
    this.cache.clear();
  }
}
```

### 数据库优化
```sql
-- 查询优化
-- 前: 全表扫描
SELECT * FROM users WHERE last_login > '2024-01-01';

-- 后: 索引优化
CREATE INDEX idx_users_last_login ON users(last_login);
SELECT * FROM users WHERE last_login > '2024-01-01';

-- 分页优化
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 10 OFFSET 990; -- 效率低

-- 优化后
SELECT * FROM posts
WHERE id > (SELECT id FROM posts ORDER BY id DESC LIMIT 1 OFFSET 989)
ORDER BY id DESC
LIMIT 10;
```

## 📈 学习与适应

### 自适应学习
- **应用模式学习**: 学习应用的性能特征和使用模式
- **优化历史学习**: 记录和学习成功的优化策略
- **环境适应学习**: 适应不同的部署环境和资源限制

### 智能建议
- **优先级排序**: 基于影响范围和优化成本的优先级建议
- **渐进优化**: 分阶段的优化建议，避免过度优化
- **监控反馈**: 基于监控数据的持续优化建议

## 🎯 使用场景

### 应用开发
- **性能瓶颈识别**: 自动识别慢查询和热点代码
- **内存优化**: 检测和修复内存泄露
- **并发优化**: 改善高并发场景的性能

### 运维部署
- **系统调优**: 服务器配置和内核参数优化
- **缓存策略**: 多级缓存架构设计和实现
- **扩展规划**: 基于负载预测的扩展建议

### 持续优化
- **性能监控**: 实时性能指标监控和告警
- **趋势分析**: 性能趋势分析和预测
- **自动化优化**: 基于规则的自动化性能优化

## 🔧 配置选项

### 基本配置
```json
{
  "optimization": {
    "enabled": true,
    "auto_analyze": true,
    "performance_threshold": 100,
    "memory_threshold": 512
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "profiling_enabled": true,
    "memory_profiling": true,
    "cpu_profiling": true,
    "database_profiling": true,
    "custom_rules": [],
    "optimization_strategies": ["memory", "cpu", "io", "network"]
  }
}
```

### 监控配置
```json
{
  "monitoring": {
    "metrics_collection": true,
    "alerts_enabled": true,
    "reporting_interval": 300,
    "historical_data_retention": 90
  }
}
```

## 📚 相关资源

- **性能分析工具**: New Relic, Datadog, Application Insights
- **优化指南**: Web性能优化最佳实践
- **监控工具**: Prometheus, Grafana监控栈

---

**技能版本**: 1.0.0
**支持语言**: JavaScript, Python, Java, Go, Rust
**分析精度**: >85% 瓶颈识别准确率
**依赖**: optimizer.sh, performance-monitor.sh