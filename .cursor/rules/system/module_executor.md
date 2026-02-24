---
description: "模块执行器和监控器 - 命令调度、性能监控和配置管理 (执行, 调度, 监控, 性能, 配置)"
globs: ["**/*"]
alwaysApply: false
priority: 19
---

# 🚀 模块执行器和监控器 (Module Executor & Monitor)

本文档是从 `module_manager.md` 分割出来的执行和监控部分。

## ⚠️ 执行原则

**MUST** 遵循以下模块执行准则：
- **MUST** 在执行前验证所有依赖项
- **NEVER** 跳过模块初始化检查
- **ALWAYS** 监控执行性能和资源使用
- **DO NOT** 在未处理错误的情况下继续执行
- **MUST** 确保线程安全和并发控制
- **ALWAYS** 记录执行日志用于审计

### 加载策略 (Loading Strategies)

#### 即时加载 (Immediate Loading)
```typescript
class ImmediateLoader implements ModuleLoader {
  async load(moduleName: string): Promise<ModuleInstance> {
    const module = await this.registry.get(moduleName);
    if (!module) {
      throw new Error(`Module ${moduleName} not found`);
    }

    // 检查缓存
    const cached = this.cache.get(moduleName);
    if (cached && this.isCacheValid(cached, module)) {
      return cached.instance;
    }

    // 解析依赖
    const resolution = await this.resolver.resolve(moduleName);

    // 按顺序加载依赖
    for (const depName of resolution.loadOrder) {
      if (depName !== moduleName) {
        await this.load(depName);
      }
    }

    // 加载主模块
    const instance = await this.loadModuleInstance(module);

    // 缓存实例
    this.cache.set(moduleName, {
      instance,
      timestamp: Date.now(),
      metadata: module.metadata
    });

    return instance;
  }
}
```

#### 懒加载 (Lazy Loading)
```typescript
class LazyLoader implements ModuleLoader {
  private loadingPromises: Map<string, Promise<ModuleInstance>> = new Map();

  async load(moduleName: string): Promise<ModuleInstance> {
    if (this.loadingPromises.has(moduleName)) {
      return this.loadingPromises.get(moduleName)!;
    }

    const loadPromise = this.performLazyLoad(moduleName);
    this.loadingPromises.set(moduleName, loadPromise);

    return loadPromise;
  }

  private async performLazyLoad(moduleName: string): Promise<ModuleInstance> {
    // 延迟加载逻辑
    await this.delay(100); // 模拟网络延迟或其他准备时间

    const module = await this.registry.get(moduleName);
    if (!module) {
      throw new Error(`Module ${moduleName} not found`);
    }

    return this.loadModuleInstance(module);
  }
}
```

### 加载优化 (Loading Optimization)

#### 并行加载 (Parallel Loading)
```typescript
class ParallelLoader implements ModuleLoader {
  async load(moduleName: string): Promise<ModuleInstance> {
    const resolution = await this.resolver.resolve(moduleName);

    // 构建加载任务图
    const loadTasks = new Map<string, Promise<ModuleInstance>>();

    // 并行加载所有依赖
    const dependencyPromises = resolution.loadOrder
      .filter(name => name !== moduleName)
      .map(async (depName) => {
        const promise = this.load(depName);
        loadTasks.set(depName, promise);
        return promise;
      });

    // 等待所有依赖加载完成
    await Promise.all(dependencyPromises);

    // 加载主模块
    const instance = await this.loadModuleInstance(
      await this.registry.get(moduleName)
    );

    return instance;
  }
}
```

## 🎮 命令调度器 (Command Dispatcher)

### 命令路由 (Command Routing)
```typescript
class CommandDispatcher {
  private routes: Map<string, CommandRoute> = new Map();

  registerRoute(commandName: string, moduleName: string, methodName: string): void {
    this.routes.set(commandName, {
      module: moduleName,
      method: methodName,
      capabilities: this.getModuleCapabilities(moduleName)
    });
  }

  async dispatch(command: Command): Promise<CommandResult> {
    const route = this.routes.get(command.name);
    if (!route) {
      throw new Error(`Command ${command.name} not found`);
    }

    // 检查模块是否已加载
    const moduleInstance = await this.loader.load(route.module);

    // 执行命令
    const result = await moduleInstance.execute(route.method, command.params);

    // 记录执行统计
    await this.recordExecutionStats(command, result);

    return result;
  }
}
```

### 命令队列管理 (Command Queue Management)
```typescript
interface CommandQueue {
  add(command: Command): Promise<string>; // 返回命令ID
  cancel(commandId: string): Promise<boolean>;
  getStatus(commandId: string): Promise<CommandStatus>;
  getQueue(): Promise<Command[]>;
  prioritize(commandId: string): Promise<boolean>;
}

class PriorityCommandQueue implements CommandQueue {
  private queue: PriorityQueue<QueuedCommand> = new PriorityQueue();

  async add(command: Command): Promise<string> {
    const queuedCommand: QueuedCommand = {
      id: this.generateId(),
      command,
      priority: this.calculatePriority(command),
      timestamp: Date.now(),
      status: 'queued'
    };

    this.queue.enqueue(queuedCommand, queuedCommand.priority);
    return queuedCommand.id;
  }

  private calculatePriority(command: Command): number {
    // 基于命令类型、用户角色、紧急程度等计算优先级
    let priority = 0;

    if (command.urgent) priority += 100;
    if (command.userRole === 'admin') priority += 50;
    if (command.type === 'system_maintenance') priority += 25;

    return priority;
  }
}
```

## 📊 性能监控器 (Performance Monitor)

### 监控指标 (Monitoring Metrics)
```json
{
  "performance_metrics": {
    "module_performance": {
      "load_time": {
        "eslint_integration": 150,
        "git_integration": 80,
        "i18n_support": 45
      },
      "memory_usage": {
        "eslint_integration": 25,
        "git_integration": 15,
        "i18n_support": 8
      },
      "cpu_usage": {
        "eslint_integration": 5.2,
        "git_integration": 2.1,
        "i18n_support": 1.8
      }
    },
    "command_performance": {
      "execution_time": {
        "eslint_check": 1200,
        "git_commit": 800,
        "file_save": 200
      },
      "success_rate": {
        "eslint_check": 0.98,
        "git_commit": 0.95,
        "file_save": 0.99
      },
      "error_rate": {
        "eslint_check": 0.02,
        "git_commit": 0.05,
        "file_save": 0.01
      }
    },
    "system_resources": {
      "total_memory": 8192,
      "used_memory": 2048,
      "available_memory": 6144,
      "cpu_cores": 8,
      "load_average": 2.5
    }
  }
}
```

### 性能优化策略 (Performance Optimization Strategies)

#### 缓存策略 (Caching Strategies)
```json
{
  "caching_strategies": {
    "module_cache": {
      "ttl": "1h",
      "invalidation_events": ["module_update", "config_change"],
      "max_size": "100MB"
    },
    "command_cache": {
      "ttl": "5m",
      "cacheable_commands": ["status_check", "info_query"],
      "exclude_patterns": ["*write*", "*modify*"]
    },
    "metadata_cache": {
      "ttl": "24h",
      "compression": true,
      "persistent": true
    }
  }
}
```

#### 资源管理 (Resource Management)
```typescript
class ResourceManager {
  private limits = {
    maxConcurrentModules: 10,
    maxMemoryPerModule: 50 * 1024 * 1024, // 50MB
    maxCpuPerModule: 10, // 10%
    timeoutPerCommand: 30000 // 30秒
  };

  async allocateResources(moduleName: string): Promise<ResourceAllocation> {
    const currentUsage = await this.getCurrentUsage();

    if (currentUsage.activeModules >= this.limits.maxConcurrentModules) {
      throw new Error('Maximum concurrent modules limit reached');
    }

    return {
      memoryLimit: this.limits.maxMemoryPerModule,
      cpuLimit: this.limits.maxCpuPerModule,
      timeout: this.limits.timeoutPerCommand
    };
  }

  async monitorResources(): Promise<void> {
    setInterval(async () => {
      const usage = await this.getCurrentUsage();

      if (usage.memoryUsage > 0.8) {
        await this.triggerOptimization('memory');
      }

      if (usage.cpuUsage > 0.9) {
