---
description: "演进哲学 - 项目规则持续演进的核心理念和原则指导"
apply_when:
  - keywords: ["演进", "evolution", "优化", "改进", "迭代"]
priority: 8
---

# 🧠 演进哲学 (Evolution Philosophy)

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## 核心理念 (Core Philosophy)

演进哲学定义了.cursor规则系统的持续改进原则和方法论，为规则演进提供理论指导框架。

**核心主张**：项目规则不是一成不变的，而是随着项目发展、团队成长和技术变化而持续演进的动态系统。

## 🎯 演进原则 (Evolution Principles)

### ⚠️ 执行原则

**MUST** 遵循以下演进原则：
- **NEVER** 进行大规模激进式重构
- **MUST** 每个改动都经过验证
- **ALWAYS** 确保改动可以安全回退
- **MUST** 使用量化指标评估效果
- **DO NOT** 忽视用户反馈

### 渐进式改进 (Incremental Improvement)
- **MUST** 从小改动开始，避免大规模重构
- **ALWAYS** 持续验证每个改动
- **MUST** 确保所有改动都可以安全回退

### 数据驱动决策 (Data-Driven Decisions)
- **量化评估**: 使用可衡量的指标评估规则效果
- **用户反馈**: 重视实际使用者的意见和建议
- **效果追踪**: 持续监控改进措施的实际效果

### 用户中心设计 (User-Centric Design)
- **以人为本**: 规则演进以提升开发体验为首要目标
- **适应性强**: 能够适应不同团队规模和技术栈
- **包容性好**: 考虑不同经验水平和使用习惯的用户

### 可持续演进 (Sustainable Evolution)
- **最小阻力**: 演进过程本身不应带来额外负担
- **自动化优先**: 尽可能通过自动化减少手动维护成本
- **标准化流程**: 建立可重复的演进流程和规范

### 📋 演进配置示例

#### 基本演进配置
```yaml
# .cursor/evolution-config.yaml
evolution:
  enabled: true
  mode: "incremental"  # incremental | aggressive | conservative
  
  safety:
    auto_rollback: true
    backup_before_changes: true
    validation_required: true
    
  monitoring:
    track_metrics: true
    collect_feedback: true
    analyze_patterns: true
```

#### 自动化演进规则
```yaml
# 定义何时触发自动演进
triggers:
  - condition: "error_rate > 5%"
    action: "revert_changes"
    priority: "critical"
    
  - condition: "user_feedback_negative > 20%"
    action: "schedule_review"
    priority: "high"
    
  - condition: "new_pattern_detected"
    action: "analyze_and_propose"
    priority: "medium"
```

## 📈 演进目标体系 (Evolution Goals Framework)

### 效率目标 (Efficiency Goals)
- 减少重复劳动和无效操作
- 提升任务完成速度和质量
- 优化资源利用率

### 质量目标 (Quality Goals)
- 提升代码和文档质量标准
- 减少错误和缺陷发生率
- 改善协作一致性

### 体验目标 (Experience Goals)
- 降低学习和使用门槛
- 提升用户满意度和接受度
- 增强系统的可用性和易用性

---

*演进哲学定义了.cursor规则系统的持续改进原则和方法论，为规则演进提供理论指导和实践框架。*
