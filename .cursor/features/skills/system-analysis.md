# 系统分析技能

## 🎯 功能概述

提供全面的系统分析能力，包括项目结构分析、依赖关系梳理、性能瓶颈识别、架构评估等，帮助开发者深入理解系统状态，识别改进机会，制定优化策略。

## 🚀 核心能力

### 项目结构分析
- **代码组织**: 目录结构和模块组织的合理性分析
- **依赖关系**: 内部模块和外部库的依赖关系图
- **复杂度评估**: 代码复杂度、圈复杂度、技术债务评估
- **规模度量**: 项目规模、代码行数、文件数量统计

### 性能分析
- **运行时性能**: CPU使用率、内存消耗、响应时间分析
- **资源利用**: 磁盘I/O、网络I/O、数据库查询分析
- **瓶颈识别**: 性能瓶颈的自动识别和优先级排序
- **扩展性评估**: 系统扩展能力和性能预测

### 架构评估
- **设计模式**: 使用的设计模式和架构模式的识别
- **分层架构**: 前端/后端/API的分层结构分析
- **组件耦合**: 组件间的耦合度和内聚性分析
- **可维护性**: 代码的可维护性和重构难易度评估

## 🛠️ 技术实现

### 核心算法
```javascript
// 系统分析引擎
class SystemAnalyzer {
  async analyzeSystem(projectPath) {
    const structure = await this.analyzeStructure(projectPath);
    const dependencies = await this.analyzeDependencies(projectPath);
    const performance = await this.analyzePerformance(projectPath);
    const architecture = await this.assessArchitecture(structure, dependencies);

    return {
      structure,
      dependencies,
      performance,
      architecture,
      recommendations: this.generateRecommendations(
        structure,
        dependencies,
        performance,
        architecture
      )
    };
  }

  async analyzeStructure(projectPath) {
    const files = await this.scanFiles(projectPath);
    const modules = await this.identifyModules(files);
    const complexity = await this.calculateComplexity(modules);

    return {
      files: files.length,
      modules: modules.length,
      directories: this.countDirectories(projectPath),
      complexity,
      organization: this.assessOrganization(modules)
    };
  }
}
```

### 依赖关系分析
```javascript
// 依赖图构建
function buildDependencyGraph(files) {
  const graph = new Map();
  const reverseGraph = new Map();

  for (const file of files) {
    const imports = extractImports(file);
    const module = getModuleName(file);

    graph.set(module, imports);

    // 构建反向依赖图
    for (const imported of imports) {
      if (!reverseGraph.has(imported)) {
        reverseGraph.set(imported, []);
      }
      reverseGraph.get(imported).push(module);
    }
  }

  return {
    dependencies: graph,
    dependents: reverseGraph,
    cycles: detectCycles(graph),
    centrality: calculateCentrality(graph)
  };
}

// 循环依赖检测
function detectCycles(graph) {
  const cycles = [];
  const visited = new Set();
  const recursionStack = new Set();

  function dfs(node, path) {
    visited.add(node);
    recursionStack.add(node);
    path.push(node);

    const neighbors = graph.get(node) || [];
    for (const neighbor of neighbors) {
      if (!visited.has(neighbor)) {
        dfs(neighbor, path);
      } else if (recursionStack.has(neighbor)) {
        // 发现循环
        const cycleStart = path.indexOf(neighbor);
        cycles.push(path.slice(cycleStart));
      }
    }

    recursionStack.delete(node);
    path.pop();
  }

  for (const node of graph.keys()) {
    if (!visited.has(node)) {
      dfs(node, []);
    }
  }

  return cycles;
}
```

## 📊 性能指标

- **分析速度**: <20秒的完整项目结构分析
- **准确率**: >90%的依赖关系识别准确率
- **复杂度计算**: 标准的圈复杂度计算
- **建议质量**: >85%的分析建议有效性

## 🔗 集成接口

### Scripts集成
- `env-perception.sh`: 系统环境感知和分析
- `code-analyzer.sh`: 代码结构和复杂度分析
- `dependency-analyzer.sh`: 依赖关系深度分析

### Hooks集成
- `analysis-pre-commit.sh`: 提交前系统分析检查
- `structure-validator.sh`: 项目结构规范验证

### Workflows集成
- **系统分析工作流**: 完整的项目分析流程
- **健康监控工作流**: 持续的系统健康状态监控
- **优化建议工作流**: 基于分析结果的改进建议

## 📈 系统指标分析

### 代码质量指标
```
- 圈复杂度 (Cyclomatic Complexity)
  • 优秀: < 10
  • 良好: 10-15
  • 需要改进: 15-20
  • 复杂: > 20

- 代码行数 (Lines of Code)
  • 函数: < 50行
  • 类: < 300行
  • 文件: < 1000行
  • 模块: < 5000行

- 注释覆盖率
  • 目标: > 30%
  • 优秀: > 50%
```

### 架构质量指标
```
- 耦合度 (Coupling)
  • 松耦合: 依赖关系少
  • 内聚性: 相关功能集中

- 分层清晰度
  • 关注点分离
  • 单向依赖
  • 清晰边界

- 可扩展性
  • 模块化程度
  • 接口抽象
  • 配置灵活性
```

### 性能指标
```
- 响应时间
  • API: < 200ms
  • 页面: < 1000ms
  • 查询: < 100ms

- 资源利用
  • CPU: < 70%
  • 内存: < 80%
  • 磁盘: < 90%

- 可扩展性
  • 并发用户: > 1000
  • 请求/秒: > 100
```

## 🔍 分析维度

### 静态分析
- **代码结构**: 文件组织、命名规范、编码风格
- **依赖关系**: 导入导出、模块耦合、循环依赖
- **复杂度度量**: 圈复杂度、认知复杂度、维护复杂度
- **规范合规**: 编码规范、文档规范、测试覆盖

### 动态分析
- **运行时性能**: CPU/内存使用、响应时间、吞吐量
- **资源利用**: 磁盘I/O、网络I/O、数据库查询
- **并发能力**: 多线程性能、锁竞争、死锁检测
- **内存管理**: 内存泄露、垃圾回收、对象生命周期

### 架构分析
- **设计模式**: 常用的设计模式识别和评估
- **分层架构**: 前端/后端/API的分层合理性
- **组件关系**: 组件耦合、内聚、职责分离
- **扩展性**: 水平扩展、垂直扩展、弹性伸缩

## 📈 学习与适应

### 自适应学习
- **项目特征学习**: 学习项目的规模、复杂度、技术栈特征
- **团队偏好学习**: 理解团队的编码风格和架构偏好
- **历史趋势学习**: 分析项目的发展趋势和改进方向

### 智能建议
- **优化优先级**: 基于影响范围和改进成本的优先级排序
- **渐进改进**: 分阶段的系统改进建议
- **最佳实践**: 基于行业标准的改进建议

## 🎯 使用场景

### 项目评估
- **新项目启动**: 项目结构设计和规范建立
- **现有项目分析**: 遗留代码的结构分析和重构建议
- **技术债务评估**: 技术债务的识别和偿还计划

### 性能优化
- **性能诊断**: 系统性能瓶颈的识别和分析
- **资源优化**: CPU、内存、磁盘等资源的优化建议
- **扩展规划**: 基于负载预测的系统扩展建议

### 架构改进
- **重构规划**: 基于分析结果的架构重构建议
- **模块化改进**: 提高代码的可维护性和可扩展性
- **技术选型**: 技术栈优化和现代化建议

## 🔧 配置选项

### 基本配置
```json
{
  "system_analysis": {
    "enabled": true,
    "auto_analyze": true,
    "analysis_depth": "standard",
    "report_format": "markdown"
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "analysis_types": ["static", "dynamic", "architectural"],
    "metrics_thresholds": {
      "complexity": 15,
      "coverage": 80,
      "response_time": 200
    },
    "custom_rules": [],
    "integration_tools": ["sonar", "lighthouse", "webpack-bundle-analyzer"]
  }
}
```

### 报告配置
```json
{
  "reporting": {
    "enabled": true,
    "schedule": "weekly",
    "recipients": ["tech-lead", "architect"],
    "formats": ["html", "pdf", "json"],
    "historical_trends": true
  }
}
```

## 📚 相关资源

- **分析工具**: SonarQube, ESLint, Prettier
- **性能工具**: Lighthouse, WebPageTest, GTmetrix
- **架构工具**: Structurizr, C4 Model, ArchiMate

---

**技能版本**: 1.0.0
**分析维度**: 静态分析, 动态分析, 架构分析
**指标类型**: 50+ 系统质量指标
**依赖**: env-perception.sh, code-analyzer.sh