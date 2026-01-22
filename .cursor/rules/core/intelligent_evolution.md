---
command: intelligent_evolution
description: "智能演进系统入口 - 规则演进的统一入口和协调器"
alwaysApply: false
---

# 🧠 智能演进系统 (Intelligent Evolution System)

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## 核心理念 (Core Philosophy)

智能演进系统专注于项目的智能化感知和分析，为演进决策提供数据支持。

**系统定位**：作为项目感知和分析的专门系统，为各种演进活动提供智能数据支持。

## 📋 系统架构 (System Architecture)

### 感知能力 (Perception Capabilities)

| 感知类型 | 功能描述 | 数据来源 | 状态 |
|----------|----------|----------|------|
| **项目状态感知** | 分析项目结构、依赖、变化趋势 | 文件系统扫描、Git历史 | ✅ 活跃 |
| **用户行为分析** | 理解协作模式、使用习惯 | 交互日志、操作记录 | ✅ 活跃 |
| **环境特征检测** | 识别技术栈、平台、工具链 | 系统信息、配置文件 | ✅ 活跃 |
| **性能指标收集** | 监控响应时间、资源使用 | 系统监控、性能日志 | ✅ 活跃 |
| **对话意图感知** | 理解用户对话内容和项目需求意图 | 对话历史、关键词分析、自然语言处理 | ⭐ 新增 |
| **上下文感知引用** | 智能选择相关文件和代码片段 | 对话上下文、文件关联分析 | ✅ 活跃 |
| **个性化学习引擎** | 深度学习用户偏好和行为模式 | 交互历史、反馈数据、学习算法 | ✅ 活跃 |
| **性能监控系统** | 实时监控规则性能和系统健康 | 执行时间、缓存效率、错误率统计 | ✅ 活跃 |

### 感知模式 (Perception Modes)

#### 对话意图感知模式 (Conversation Intent Perception Mode) ⭐ 新增

智能系统能够主动理解用户的对话内容，识别项目需求意图，并提供相应的技术规划建议：

##### 意图识别策略 (Intent Recognition Strategies)
- **关键词多层次分析**：识别意图类型（创建/优化/分析）和技术领域（前端/后端/AI等）
- **上下文连续性分析**：考虑对话历史和上下文关系
- **置信度动态评估**：基于关键词匹配度和上下文相关性计算置信度
- **意图合成推理**：将多个关键词组合成复杂意图

##### 意图分类体系 (Intent Classification System)
```yaml
# 一级意图：操作类型
creation: ["创建", "开发", "构建", "设计", "实现"]
optimization: ["优化", "改进", "重构", "升级"]
analysis: ["分析", "评估", "诊断", "检查"]

# 二级意图：技术领域
frontend: ["前端", "界面", "UI", "React", "Vue"]
backend: ["后端", "API", "服务", "Node.js", "Python"]
ai_ml: ["AI", "机器学习", "训练", "推理", "标注"]
```

##### 智能响应生成 (Smart Response Generation)
```typescript
interface IntentResponse {
  // 意图分析结果
  primaryIntent: string      // "creation", "optimization", "analysis"
  techDomains: string[]      // ["frontend", "backend", "ai_ml"]
  confidence: number         // 0.0 - 1.0

  // 响应策略
  responseType: 'direct' | 'confirmatory' | 'clarification'
  suggestions: TechSuggestion[]

  // 个性化调整
  userPreferences: UserPreferences
  projectContext: ProjectContext
}
```

#### 上下文感知引用模式 (Context-Aware Reference Mode) ✅ 活跃

智能系统能够根据对话上下文自动选择和引用最相关的文件和代码片段：

##### 智能引用策略 (Smart Reference Strategies)
- **语义关联分析**：基于对话内容分析相关文件和函数
- **代码依赖追踪**：自动识别相关联的模块和依赖
- **历史上下文记忆**：记住之前的对话和文件引用模式
- **相关性评分排序**：为候选文件计算相关性分数并排序

##### 引用触发条件 (Reference Triggers)
```typescript
interface ContextReference {
  // 对话关键词触发
  keywords: string[]          // ["用户认证", "登录", "token"]

  // 文件类型偏好
  fileTypes: string[]         // [".ts", ".js", ".auth.ts"]

  // 代码模式匹配
  patterns: RegExp[]          // [/auth/, /login/, /jwt/]

  // 依赖关系追踪
  dependencies: string[]      // ["passport", "jsonwebtoken"]
}

// 自动引用示例
const authContext: ContextReference = {
  keywords: ["用户登录", "认证"],
  fileTypes: [".auth.ts", ".login.ts"],
  patterns: [/auth/, /login/, /token/],
  dependencies: ["passport", "jsonwebtoken"]
}
```

##### 实际应用场景 (Practical Scenarios)

**场景1：功能开发引用**
```
用户: "优化用户登录流程"

智能引用:
- @src/auth/login.ts (主要登录逻辑)
- @src/auth/jwt.ts (token处理)
- @src/models/User.ts (用户模型)
- @src/middleware/auth.ts (认证中间件)
```

**场景2：Bug修复引用**
```
用户: "修复注册表单验证错误"

智能引用:
- @src/components/RegisterForm.tsx (注册表单)
- @src/validation/schemas.ts (验证规则)
- @src/utils/validators.ts (验证工具函数)
- @tests/auth.test.ts (相关测试)
```

#### 个性化学习引擎 (Personalized Learning Engine) ⭐ 新增

基于生长文件夹中的学习数据，提供深度个性化的AI协作体验：

##### 学习维度 (Learning Dimensions)
- **沟通偏好学习**：分析用户的语言偏好、详细程度、技术术语使用等
- **编码风格学习**：学习用户的命名约定、代码风格、框架偏好等
- **项目模式学习**：理解用户在不同团队规模和项目阶段的行为模式
- **任务效率学习**：分析用户完成不同类型任务的效率和偏好

##### 自适应算法 (Adaptive Algorithms)
```typescript
interface LearningEngine {
  // 实时学习
  learnFromInteraction(interaction: UserInteraction): void

  // 模式识别
  recognizePatterns(history: InteractionHistory[]): Pattern[]

  // 偏好预测
  predictPreferences(context: Context): UserPreferences

  // 行为适应
  adaptBehavior(preferences: UserPreferences): Adaptation[]
}

// 学习流程示例
const learningEngine = new LearningEngine()

// 1. 从交互中学习
learningEngine.learnFromInteraction({
  task: "代码审查",
  userResponse: "太详细了，简洁点",
  timestamp: Date.now()
})

// 2. 识别模式
const patterns = learningEngine.recognizePatterns(history)
// 返回: ["偏好简洁回复", "关注性能问题"]

// 3. 预测偏好
const preferences = learningEngine.predictPreferences({
  task: "重构建议",
  complexity: "high"
})
// 返回: {detail_level: "concise", focus_areas: ["performance"]}

// 4. 适应行为
const adaptations = learningEngine.adaptBehavior(preferences)
// 返回: ["减少解释", "优先性能建议"]
```

##### 学习数据存储 (Learning Data Storage)
所有学习数据安全存储在 `.cursorGrowth/learning/` 目录：
```
.cursorGrowth/learning/
├── preferences.json       # 个性化偏好
├── patterns.json         # 识别的模式
├── adaptations.json      # 适应的行为
├── feedback_history.json # 反馈历史
└── metrics.json         # 学习指标
```

#### 模块同步感知模式 (Module Synchronization Awareness Mode) ⭐ 新增

智能系统能够主动检测和提醒模块间的同步需求，确保AI编程时的上下文完整性：

##### 同步触发条件 (Synchronization Triggers)
- **共享资源修改**：检测到常量、类型、配置的变更
- **接口变更**：API、函数签名、数据结构的修改
- **依赖关系变化**：导入/导出关系的改变
- **架构重构**：影响多个模块的结构调整

##### 智能同步提醒 (Smart Synchronization Reminders)
```typescript
interface SyncReminder {
  // 同步类型
  type: 'shared_constant' | 'type_definition' | 'api_interface' | 'config_change'

  // 受影响文件
  affectedFiles: FileLocation[]

  // 具体同步操作
  requiredActions: SyncAction[]

  // 优先级
  priority: 'critical' | 'high' | 'medium' | 'low'

  // 自动化建议
  autoFixSuggestions?: AutoFix[]
}

interface SyncAction {
  file: string
  line?: number
  description: string
  codeSnippet?: string
  autoFixable: boolean
}

interface AutoFix {
  type: 'add_import' | 'update_property' | 'modify_type' | 'update_test'
  parameters: Record<string, any>
}
```

##### 同步感知算法 (Synchronization Awareness Algorithm)
```typescript
interface SynchronizationAwareness {
  // 变更检测
  detectChanges(file: File, changes: Change[]): DetectedChanges

  // 影响分析
  analyzeImpact(changes: DetectedChanges, project: Project): ImpactAnalysis

  // 同步规划
  planSynchronization(impact: ImpactAnalysis): SyncPlan

  // 智能提醒
  generateReminders(plan: SyncPlan): SyncReminder[]

  // 学习优化
  learnFromSync(syncResult: SyncResult): void
}

class ModuleSyncDetector implements SynchronizationAwareness {
  async detectChanges(file: File, changes: Change[]): Promise<DetectedChanges> {
    const detected: DetectedChanges = {
      sharedConstants: [],
      typeDefinitions: [],
      apiInterfaces: [],
      configChanges: []
    }

    for (const change of changes) {
      // 检测共享常量变更
      if (this.isSharedConstant(change)) {
        detected.sharedConstants.push({
          name: change.identifier,
          oldValue: change.oldValue,
          newValue: change.newValue,
          file: file.path
        })
      }

      // 检测类型定义变更
      if (this.isTypeDefinition(change)) {
        detected.typeDefinitions.push({
          typeName: change.identifier,
          changeType: change.type, // 'add' | 'remove' | 'modify'
          details: change.details,
          file: file.path
        })
      }

      // 检测API接口变更
      if (this.isApiInterface(change)) {
        detected.apiInterfaces.push({
          interfaceName: change.identifier,
          methodChanges: change.methodChanges,
          file: file.path
        })
      }

      // 检测配置变更
      if (this.isConfigChange(change)) {
        detected.configChanges.push({
          configKey: change.identifier,
          oldValue: change.oldValue,
          newValue: change.newValue,
          file: file.path
        })
      }
    }

    return detected
  }

  async analyzeImpact(changes: DetectedChanges, project: Project): Promise<ImpactAnalysis> {
    const impact: ImpactAnalysis = {
      directImpacts: [],
      indirectImpacts: [],
      severity: 'low',
      confidence: 0
    }

    // 分析直接影响
    for (const constant of changes.sharedConstants) {
      const usages = await this.findUsages(project, constant.name, 'constant')
      impact.directImpacts.push(...usages)
    }

    for (const typeDef of changes.typeDefinitions) {
      const usages = await this.findUsages(project, typeDef.typeName, 'type')
      impact.directImpacts.push(...usages)
    }

    // 分析间接影响（依赖链）
    impact.indirectImpacts = await this.traceDependencyChain(impact.directImpacts)

    // 计算严重程度
    impact.severity = this.calculateSeverity(impact.directImpacts.length, impact.indirectImpacts.length)
    impact.confidence = this.calculateConfidence(impact.directImpacts, impact.indirectImpacts)

    return impact
  }

  private calculateSeverity(directCount: number, indirectCount: number): Severity {
    const total = directCount + indirectCount
    if (total >= 10) return 'critical'
    if (total >= 5) return 'high'
    if (total >= 2) return 'medium'
    return 'low'
  }

  private calculateConfidence(directImpacts: Impact[], indirectImpacts: Impact[]): number {
    // 基于直接影响的确定性和间接影响的推断性计算置信度
    const directConfidence = Math.min(directImpacts.length * 0.1, 0.8)
    const indirectConfidence = indirectImpacts.length * 0.05
    return Math.min(directConfidence + indirectConfidence, 0.95)
  }
}
```

##### 实际应用场景 (Practical Scenarios)

**场景1：共享常量修改引用**
```
用户修改: src/shared/constants.ts
export const API_BASE_URL = 'https://new-api.example.com'

智能同步感知:
🔔 检测到共享常量变更

📋 影响分析 (置信度: 92%):
├── 🔴 src/services/apiService.ts:15 (直接使用API_BASE_URL)
├── 🔴 src/components/ConfigPanel.tsx:23 (显示配置)
├── 🔴 tests/api.test.ts:8 (测试mock数据)
└── 🟡 src/utils/apiHelpers.ts:45 (可能受影响的辅助函数)

⚡ 建议同步操作:
1. 更新ApiService中的基础URL使用
2. 更新配置面板的默认值显示
3. 修改测试用例的mock数据
4. 检查辅助函数是否需要更新

🤖 自动化修复建议:
- 批量替换API_BASE_URL的使用
- 更新测试文件中的mock值
```

**场景2：类型定义变更引用**
```
用户修改: src/shared/types.ts
export interface User {
  id: string
  name: string      // 新增
  email: string
  role: UserRole   // 新增
}

智能同步感知:
🔔 检测到类型定义变更

📋 影响分析 (置信度: 88%):
├── 🔴 src/services/userService.ts (需要更新数据处理)
├── 🔴 src/components/UserForm.tsx (需要添加输入字段)
├── 🔴 src/api/userApi.ts (需要更新接口)
├── 🔴 tests/user.test.ts (需要更新测试数据)
└── 🟡 src/pages/UserProfile.tsx (可能需要UI更新)

⚡ 建议同步操作:
1. 更新UserService的数据验证逻辑
2. 添加UserForm的新字段输入框
3. 修改API接口以支持新字段
4. 更新测试用例的数据结构
5. 检查页面组件是否需要更新
```

##### 同步执行流程 (Synchronization Execution Flow)
```typescript
// 1. 检测变更
const changes = await detector.detectChanges(file, codeChanges)

// 2. 分析影响
const impact = await detector.analyzeImpact(changes, project)

// 3. 生成同步计划
const plan = await detector.planSynchronization(impact)

// 4. 生成智能提醒
const reminders = await detector.generateReminders(plan)

// 5. 用户确认后执行
if (await userConfirms(reminders)) {
  await executeSyncPlan(plan)
}

// 6. 学习优化
await detector.learnFromSync(syncResult)
```

##### 学习和适应机制 (Learning & Adaptation Mechanisms)
```json
{
  "sync_learning": {
    "patterns": {
      "shared_constants": {
        "common_impacts": ["services", "components", "tests"],
        "auto_fix_rate": 0.85,
        "user_acceptance": 0.92
      },
      "type_definitions": {
        "common_impacts": ["services", "components", "apis", "tests"],
        "complexity_factor": 1.3,
        "manual_review_rate": 0.65
      }
    },
    "user_preferences": {
      "preferred_order": ["critical", "high", "medium"],
      "auto_fix_threshold": "high_confidence",
      "reminder_style": "grouped_by_file"
    },
    "performance_metrics": {
      "detection_accuracy": 0.94,
      "false_positive_rate": 0.06,
      "user_satisfaction": 0.89
    }
  }
}
```

#### 性能监控系统 (Performance Monitoring System) ⭐ 新增

基于生长文件夹的监控数据，提供全面的系统性能洞察：

##### 监控指标 (Monitoring Metrics)
- **规则性能指标**：各规则的执行时间、成功率、缓存命中率
- **系统健康指标**：内存使用、API调用次数、错误率
- **用户体验指标**：任务完成率、满意度评分、会话时长
- **学习效果指标**：适应成功率、模式识别准确度、优化效果

##### 实时监控仪表板 (Real-time Monitoring Dashboard)
```typescript
interface PerformanceMonitor {
  // 实时指标收集
  collectMetrics(operation: Operation): Metrics

  // 性能分析
  analyzePerformance(metrics: Metrics[]): Analysis

  // 优化建议
  generateOptimizations(analysis: Analysis): Optimization[]

  // 健康检查
  healthCheck(): HealthStatus
}

// 监控示例
const monitor = new PerformanceMonitor()

// 1. 收集指标
const metrics = monitor.collectMetrics({
  rule: 'constitution',
  execution_time: 150,
  success: true,
  cache_hit: false
})

// 2. 性能分析
const analysis = monitor.analyzePerformance([metrics])
// 返回: {bottlenecks: ['rule_execution'], improvements: ['cache_optimization']}

// 3. 生成优化建议
const optimizations = monitor.generateOptimizations(analysis)
// 返回: ['启用规则缓存', '优化执行顺序']

// 4. 健康检查
const health = monitor.healthCheck()
// 返回: {status: 'healthy', issues: [], recommendations: []}
```

##### 监控数据存储 (Monitoring Data Storage)
性能数据存储在 `.cursorGrowth/monitoring/` 目录：
```
.cursorGrowth/monitoring/
├── usage_metrics.json      # 使用统计
├── performance_logs.json   # 性能日志
├── error_logs.json         # 错误日志
├── health_reports.json     # 健康报告
└── optimization_history.json # 优化历史
```

##### 自动优化触发 (Automatic Optimization Triggers)
- **性能阈值触发**：当响应时间超过阈值时自动优化
- **错误率触发**：当错误率升高时触发诊断和修复
- **缓存效率触发**：当缓存命中率降低时优化缓存策略
- **资源使用触发**：当内存/CPU使用过高时进行资源优化

#### 实时感知模式 (Real-time Perception Mode)
```
使用场景：需要即时了解项目状态变化
触发方式：文件保存、Git提交、命令执行时自动触发
输出：当前项目状态快照和变化分析
```

#### 周期性分析模式 (Periodic Analysis Mode)
```
使用场景：定期评估项目健康度和趋势分析
触发方式：每日/每周定时执行
输出：项目趋势报告和改进建议
```

#### 事件驱动模式 (Event-Driven Mode)
```
使用场景：特定事件发生时进行深度分析
触发方式：依赖变化、新功能上线、性能问题等
输出：针对性分析报告和解决方案建议
```

## 🎯 使用指南 (Usage Guide)

### 快速开始 (Quick Start)
1. 激活智能感知：`@intelligent_evolution`
2. 配置感知范围：指定需要监控的项目路径
3. 设置报告频率：选择实时、定时或事件驱动模式
4. 集成到工作流：与其他规则结合使用感知数据

### 数据集成 (Data Integration)
```markdown
# 与演进系统集成
@intelligent_evolution @evolution-automation

# 与协作系统集成
@intelligent_evolution @philosophy

# 与治理系统集成
@intelligent_evolution @evolution-governance
```

### 最佳实践 (Best Practices)
- 定期检查感知数据的准确性和及时性
- 根据项目特点调整感知频率和范围
- 将感知结果作为决策的重要参考依据
- 结合人工判断，避免过度依赖自动化感知

---

*智能演进系统专注于项目的智能化感知和分析，为演进决策和规则优化提供数据支持和洞察。*

