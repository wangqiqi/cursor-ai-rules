# ⚖️ 宪法规范 - Cursor AI Rules

*三大公理、四层架构、六维交互协议的完整规范*

## 🧠 核心理念：三大无关性设计原则

### 三大分离原则

#### 1. 项目无关 (Project Agnostic)
- ✅ **核心系统解耦**: `.cursor/` 目录可以在任何Git项目中使用
- ✅ **自动环境适配**: 通过路径检测自动适应不同项目结构
- ✅ **规则技能复用**: 规则、技能、文档等核心功能与具体项目解耦
- ✅ **多项目支持**: 支持在多个项目中同时使用同一套AI系统

#### 2. 系统无关 (System Agnostic)
- ✅ **跨平台技术栈**: 核心功能使用Node.js + Shell实现
- ✅ **智能系统检测**: 自动检测操作系统并适配命令和路径
- ✅ **统一抽象接口**: 屏蔽底层系统差异，提供一致的用户体验
- ✅ **完整兼容性**: 从Linux到Windows的全平台支持

#### 3. 用户无关 (User Agnostic)
- ✅ **AI能力中立**: 核心AI能力不依赖特定用户身份
- ✅ **数据隔离存储**: 通过`.cursorGrowth/`目录存储个性化数据
- ✅ **多用户共享**: 支持多用户共享同一套AI系统
- ✅ **隐私数据保护**: 用户偏好和学习数据完全隔离

---

## 🏛️ 三大公理 (Three Fundamental Axioms)

### 公理1: 意图主权公理 (Intent Sovereignty Axiom)
**人类永远保有对"为何做"与"何为正确"的最终解释权与决策权**

#### 强制执行机制
- **STOP机制**: 检测到项目创建意图时立即停止所有操作
- **人类确认**: 所有重要决策必须获得人类明确批准
- **意图溯源**: 每个响应都包含意图分析的完整推理链
- **边界控制**: 明确的AI能力范围和人类干预点

#### 实现保障
```typescript
interface IntentSovereignty {
  // 意图检测与拦截
  detectProjectCreationIntent(input: string): boolean;

  // 强制人类确认流程
  requireHumanConfirmation(intent: Intent): Promise<HumanDecision>;

  // 决策溯源记录
  createDecisionTrail(decision: Decision): AuditTrail;
}
```

### 公理2: 信号可信公理 (Signal Trustworthiness Axiom)
**AI的一切输出，必须附带可追溯、可验证、可归因的原始信号链**

#### 信号链要求
- **完整溯源**: 每个输出都包含支撑决策的原始信号
- **可验证性**: 信号的真实性和时效性可被验证
- **归因明确**: 清楚标识信号的来源和处理过程
- **透明展示**: 用户可以查看完整的信号处理链

#### 技术实现
```typescript
interface SignalChain {
  // 信号收集
  collectSignals(context: Context): Signal[];

  // 信号验证
  validateSignals(signals: Signal[]): ValidationResult;

  // 链式构建
  buildSignalChain(signals: Signal[]): SignalChain;

  // 可视化展示
  renderSignalChain(chain: SignalChain): UIComponent;
}
```

### 公理3: 认知可审计公理 (Cognitive Auditability Axiom)
**所有AI协作过程，必须支持"三秒回溯"**

#### 审计要求
- **三秒回溯**: 在3秒内定位AI的推理过程和决策依据
- **完整日志**: 所有交互的结构化日志存储
- **历史追溯**: 支持任意历史会话的完整回溯
- **模式分析**: 基于历史数据的交互模式识别

#### 审计系统架构
```typescript
interface CognitiveAudit {
  // 实时记录
  recordInteraction(interaction: UserInteraction): AuditEntry;

  // 三秒回溯
  quickTrace(sessionId: string, timestamp: Date): TraceResult;

  // 历史查询
  queryHistory(filters: QueryFilters): AuditTrail[];

  // 模式分析
  analyzePatterns(trails: AuditTrail[]): PatternAnalysis;
}
```

---

## 🏗️ 四层运行时架构 (Four-Layer Runtime Architecture)

### L1: 信号层 (Signal Layer)
**职责**: 输入世界的可信映射

#### 核心组件
- **Context收集器**: 动态聚合多源上下文信息
- **Index构建器**: 创建项目的知识索引和检索系统
- **Rules加载器**: 透明加载和执行规则系统

#### 技术特性
- **信号新鲜度验证**: TTL机制确保数据时效性
- **多源聚合**: 智能整合文件、环境、历史等多源信号
- **实时更新**: 信号变化的自动检测和更新

### L2: 协议层 (Protocol Layer)
**职责**: 人机交互的语义总线

#### 协议实现
- **MCP协议**: 完整的模型控制协议支持
- **Tools注册**: 工具的动态注册、发现和调用
- **Intent声明**: 意图保真度评分和约束检测

#### 交互标准
- **语义总线**: 标准化的人机交互协议
- **能力发现**: 自动发现和注册可用工具
- **协议协商**: 动态协商通信协议和数据格式

### L3: 代理层 (Agency Layer)
**职责**: 目标导向的自治单元

#### 代理管理
- **Agent生命周期**: 智能体的创建、配置、销毁管理
- **Model执行**: 多模型支持和性能优化调度
- **Plan生成**: 计划的生成、验证和执行跟踪

#### 自治能力
- **目标驱动**: 基于明确目标的自主决策
- **能力评估**: 实时评估AI能力的边界和限制
- **主权边界**: 明确的AI行使范围声明

### L4: 主权层 (Sovereignty Layer)
**职责**: 人类决策的终极界面

#### 决策界面
- **哲学引擎**: 三大公理的具体实现机制
- **治理系统**: 规则的加载、执行和冲突解决
- **5D规则界面**: 六维交互协议的完整实现

#### 人类干预
- **决策追踪**: 完整的人类决策过程记录
- **干预界面**: 直观的人类控制和干预界面
- **主权保障**: 人类意图的最终解释权和决策权

---

## 🔄 六维交互协议 (Six-Dimensional Interaction Protocol)

### D1: 意图声明协议 (Intent Declaration Protocol)
**确保意图的准确理解和声明**

#### 协议机制
- **保真度评分**: 0-100分的意图理解准确度评估
- **约束检测**: 自动识别未覆盖的约束条件
- **澄清触发**: 评分<85时自动触发补充确认

#### 实现标准
```typescript
interface IntentDeclaration {
  // 意图解析
  parseIntent(input: string): IntentAnalysis;

  // 保真度评估
  calculateFidelity(intent: Intent, context: Context): number;

  // 约束检测
  detectConstraints(intent: Intent): Constraint[];

  // 澄清请求
  requestClarification(constraints: Constraint[]): ClarificationRequest;
}
```

### D2: 信号校验协议 (Signal Check Protocol)
**确保所有信号的可追溯性和可验证性**

#### 校验机制
- **点击溯源**: 一键查看支撑决策的原始信号
- **Context展示**: 相关上下文片段的可视化
- **规则透明**: 激活规则的状态和优先级展示

#### 溯源标准
- **信号链完整**: 从输入到输出的完整处理链
- **时效性验证**: 信号的时间戳和有效期检查
- **来源可信**: 信号来源的身份验证和信任评估

### D3: 边界设定协议 (Boundary Setting Protocol)
**明确AI能力的行使范围和人类干预点**

#### 边界管理
- **委托深度控制**: 1-5级的AI能力范围设置
- **实时范围渲染**: AI能力边界的可视化展示
- **权限确认**: 提升委托级别时的强制确认

#### 动态调整
- **上下文感知**: 基于任务复杂度自动调整边界
- **渐进授权**: 从简单任务到复杂任务的逐步授权
- **边界记忆**: 保存用户的委托偏好设置

### D4: 审计留痕协议 (Audit Logging Protocol)
**完整记录所有交互过程，支持历史追溯**

#### 审计机制
- **快捷键摘要**: Ctrl+Shift+A生成会话摘要
- **结构化存储**: 标准化格式的审计日志
- **历史回溯**: 支持任意时间段的交互历史查询

#### 数据标准
- **日志完整性**: 包含时间戳、用户ID、操作类型、结果
- **存储安全**: 日志的加密存储和访问控制
- **保留策略**: 符合法规要求的日志保留期限

### D5: 认知演进协议 (Cognitive Evolution Protocol)
**跟踪和促进AI能力的持续学习和改进**

#### 演进跟踪
- **进化报告**: 每周自动生成认知进化报告
- **学习成果**: 量化展示学习进步和能力提升
- **里程碑庆祝**: 识别和庆祝成长里程碑

#### 个性化学习
- **用户模型**: 基于交互数据的用户能力模型
- **学习路径**: 个性化的技能提升路径规划
- **反馈循环**: 学习效果的持续评估和调整

### D6: 多文件协作协议 (Multi-File Collaboration Protocol)
**支持复杂任务的多文件协同处理**

#### 协作机制
- **序列规划**: 自动规划多文件编辑执行序列
- **依赖追踪**: 文件间依赖关系的自动识别
- **原子操作**: 支持多文件变更的原子性保证

#### 一致性保障
- **事务管理**: 多文件操作的事务性保证
- **冲突解决**: 自动检测和解决文件冲突
- **回滚支持**: 失败时的完整回滚机制

---

## 📋 技术规范附录

### 数据格式标准
- **JSON Schema**: 所有配置文件的格式验证
- **API规范**: RESTful API和GraphQL接口标准
- **日志格式**: 结构化日志的统一格式

### 安全规范
- **加密标准**: AES-256数据加密
- **认证机制**: JWT令牌和OAuth2.0
- **访问控制**: 基于角色的权限管理(RBAC)

### 性能标准
- **响应时间**: 简单查询<500ms，复杂分析<2s
- **并发能力**: 支持1000+并发用户
- **资源效率**: CPU<10%，内存<200MB

---

## 📚 相关规范

- [API规范](api-spec.md) - 接口定义和技术标准
- [安全规范](security-spec.md) - 安全要求和实现标准
- [性能规范](performance-spec.md) - 性能指标和测试标准

---

*最后更新: 2026-01-22 | 版本: v9.0.0 | 状态: ⚖️ 宪法规范完成*