# 🔌 API标准化规范 - Cursor AI Rules

这个目录定义了Cursor AI Rules系统的API标准化规范，确保所有组件都遵循统一的接口约定。

## 📋 API设计原则

### 1. 统一性 (Consistency)
- 所有API遵循相同的调用模式
- 参数命名和返回值格式统一
- 错误处理机制一致

### 2. 简单性 (Simplicity)
- API接口简洁明了
- 参数数量控制在合理范围内
- 返回值结构清晰

### 3. 可扩展性 (Extensibility)
- API设计支持未来扩展
- 版本控制机制完善
- 向后兼容性保证

### 4. 安全性 (Security)
- 输入验证和清理
- 输出内容过滤
- 权限控制机制

## 🏗️ API架构层次

```
API层
├── 统一入口 API       # @master 命令
├── 组件调用 API       # 内部组件通信
├── 扩展插件 API       # 第三方插件接口
└── 管理控制 API       # 系统管理接口
```

## 🎯 统一入口API

### 命令格式
```bash
@master <intent_description> [options]
```

### 参数规范
- **intent_description**: 自然语言描述的用户意图
- **options**: 可选参数（--mode, --verbose等）

### 返回值格式
```json
{
  "status": "success|error|pending",
  "execution_id": "uuid",
  "result": {
    "type": "command_result|error_info|progress_info",
    "data": {},
    "timestamp": "ISO8601"
  },
  "metadata": {
    "duration_ms": 1234,
    "components_used": ["perception", "quality", "skills"],
    "version": "4.3.0"
  }
}
```

## 🔧 组件调用API

### 接口定义
```typescript
interface ComponentAPI {
  // 组件信息
  getInfo(): ComponentInfo;

  // 执行操作
  execute(operation: string, params: any): Promise<ExecutionResult>;

  // 获取状态
  getStatus(): ComponentStatus;

  // 配置管理
  configure(config: any): Promise<void>;
}

interface ComponentInfo {
  name: string;
  version: string;
  capabilities: string[];
  dependencies: string[];
  author: string;
  description: string;
}

interface ExecutionResult {
  success: boolean;
  data?: any;
  error?: ErrorInfo;
  metadata: {
    execution_time_ms: number;
    resources_used: ResourceUsage;
  };
}
```

### 标准操作类型
- `analyze`: 分析操作
- `generate`: 生成操作
- `validate`: 验证操作
- `transform`: 转换操作
- `execute`: 执行操作

## 📊 核心组件API

### 感知引擎API
```typescript
interface PerceptionAPI {
  // 环境检测
  detectEnvironment(): Promise<EnvironmentInfo>;

  // 项目分析
  analyzeProject(): Promise<ProjectAnalysis>;

  // 意图识别
  recognizeIntent(input: string): Promise<IntentAnalysis>;

  // 高级洞察
  generateInsights(analysis: AnalysisResult): Promise<Insights>;
}
```

### 配置管理API
```typescript
interface ConfigAPI {
  // 配置获取
  getConfig(key: string, level?: ConfigLevel): Promise<any>;

  // 配置设置
  setConfig(key: string, value: any, level?: ConfigLevel): Promise<void>;

  // 配置验证
  validateConfig(config: any): Promise<ValidationResult>;

  // 配置合并
  mergeConfigs(configs: Config[]): Promise<MergedConfig>;
}
```

### 质量保障API
```typescript
interface QualityAPI {
  // 代码检查
  lint(files: string[]): Promise<LintResult>;

  // 代码格式化
  format(files: string[]): Promise<FormatResult>;

  // 安全审计
  audit(files: string[]): Promise<SecurityResult>;

  // 质量报告
  report(results: QualityResults[]): Promise<QualityReport>;
}
```

## 🔌 扩展插件API

### 插件接口
```typescript
interface PluginAPI {
  // 插件生命周期
  activate(): Promise<void>;
  deactivate(): Promise<void>;

  // 插件信息
  getManifest(): PluginManifest;

  // 功能执行
  execute(feature: string, params: any): Promise<any>;

  // 事件处理
  onEvent(event: string, handler: EventHandler): void;
}

interface PluginManifest {
  name: string;
  version: string;
  description: string;
  author: string;
  capabilities: PluginCapability[];
  dependencies: string[];
  permissions: string[];
}
```

### 钩子插件API
```typescript
interface HookPluginAPI {
  // 钩子注册
  registerHook(eventType: string, config: HookConfig): Promise<string>;

  // 钩子注销
  unregisterHook(hookId: string): Promise<void>;

  // 钩子管理
  listHooks(): Promise<HookInfo[]>;
  enableHook(hookId: string): Promise<void>;
  disableHook(hookId: string): Promise<void>;
}
```

## 🎮 管理控制API

### 系统管理API
```typescript
interface SystemAPI {
  // 系统状态
  getSystemStatus(): Promise<SystemStatus>;

  // 组件管理
  listComponents(): Promise<ComponentInfo[]>;
  getComponentStatus(name: string): Promise<ComponentStatus>;
  restartComponent(name: string): Promise<void>;

  // 日志管理
  getLogs(component?: string, level?: LogLevel): Promise<LogEntry[]>;

  // 性能监控
  getPerformanceMetrics(): Promise<PerformanceMetrics>;
}
```

### 监控API
```typescript
interface MonitoringAPI {
  // 指标收集
  collectMetrics(component: string): Promise<MetricsData>;

  // 健康检查
  healthCheck(component: string): Promise<HealthStatus>;

  // 告警管理
  getAlerts(): Promise<Alert[]>;
  acknowledgeAlert(alertId: string): Promise<void>;
}
```

## 📋 错误处理规范

### 错误代码体系
```typescript
enum ErrorCode {
  // 系统级别错误
  SYSTEM_ERROR = 'SYSTEM_ERROR',
  CONFIG_ERROR = 'CONFIG_ERROR',
  NETWORK_ERROR = 'NETWORK_ERROR',

  // 组件级别错误
  COMPONENT_NOT_FOUND = 'COMPONENT_NOT_FOUND',
  COMPONENT_TIMEOUT = 'COMPONENT_TIMEOUT',
  COMPONENT_EXECUTION_FAILED = 'COMPONENT_EXECUTION_FAILED',

  // API级别错误
  INVALID_PARAMETERS = 'INVALID_PARAMETERS',
  PERMISSION_DENIED = 'PERMISSION_DENIED',
  RESOURCE_NOT_FOUND = 'RESOURCE_NOT_FOUND',

  // 业务级别错误
  VALIDATION_FAILED = 'VALIDATION_FAILED',
  OPERATION_NOT_SUPPORTED = 'OPERATION_NOT_SUPPORTED'
}
```

### 错误响应格式
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "输入参数验证失败",
    "details": {
      "field": "email",
      "reason": "格式不正确"
    },
    "timestamp": "2026-01-16T10:30:00Z",
    "request_id": "req_123456"
  }
}
```

## 🔄 版本控制

### API版本策略
- **主版本**: 大幅变更时递增 (4.3.0 → 5.0.0)
- **次版本**: 新功能添加时递增 (4.3.0 → 4.4.0)
- **补丁版本**: 错误修复时递增 (4.3.0 → 4.3.1)

### 兼容性保证
- **向后兼容**: 新版本API不破坏现有调用
- **废弃警告**: 废弃API提前通知用户
- **迁移路径**: 提供从旧版本到新版本的迁移指南

## 🧪 测试规范

### API测试要求
- **单元测试**: 每个API方法都有对应的单元测试
- **集成测试**: API间的交互测试
- **性能测试**: 高负载下的性能表现
- **兼容性测试**: 不同版本间的兼容性

### 测试数据标准
```json
{
  "test_cases": [
    {
      "name": "valid_input_test",
      "input": {"param": "value"},
      "expected_output": {"result": "success"},
      "assertions": ["status_code", "response_format", "performance"]
    }
  ]
}
```

## 📚 使用指南

### API调用示例
```bash
# 感知引擎调用
@master script core/env-perception.sh perception

# 配置管理调用
@master script core/core/config/config-manager.sh get .system.log_level

# 质量检查调用
@master script core/quality-manager.sh lint
```

### 错误处理示例
```bash
# 处理API错误
if [ $? -ne 0 ]; then
    echo "API调用失败，检查错误信息"
    # 解析错误响应
    # 执行恢复操作
fi
```

## 🚀 未来扩展

### 计划中的API
- **实时通信API**: WebSocket支持的实时通信
- **批量操作API**: 支持批量处理的API
- **缓存API**: 智能缓存管理的API
- **分析API**: 数据分析和报告生成的API

### 扩展机制
- **插件市场**: 第三方插件的发布和发现
- **自定义API**: 用户自定义API扩展
- **服务发现**: 动态API服务的注册和发现

---

*统一的API标准化规范确保了系统的可扩展性、一致性和可维护性，是构建强大AI助手的基础。*