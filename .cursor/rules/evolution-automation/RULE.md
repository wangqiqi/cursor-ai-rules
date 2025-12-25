---
description: "自动化演进系统 - 基于感知数据的智能规则自动优化"
globs: ["*.json", "*.yaml", "*.yml"]
alwaysApply: false
---

# 🤖 自动化演进系统 (Automated Evolution System)

*版本: v1.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_NAME}}}*

## 🎯 核心机制 (Core Mechanisms)

自动化演进系统通过持续感知项目状态和用户行为，实现规则的智能优化和自动调整。

## 📊 感知维度 (Perception Dimensions)

### 项目变化感知 (Project Change Detection)

#### 技术栈感知 (Technology Stack Awareness)
系统自动检测技术栈变化，包括：
- 框架版本升级
- 新依赖引入
- 构建工具变更
- 语言特性更新

#### 团队动态感知 (Team Dynamics Awareness)
监控团队协作模式变化：
- 成员数量变化
- 角色结构调整
- 协作习惯演变
- 沟通模式转变

#### 项目规模感知 (Project Scale Awareness)
跟踪项目复杂度指标：
- 代码行数增长趋势
- 文件和目录结构变化
- 模块化程度评估
- 技术债务积累

#### 开发阶段感知 (Development Stage Awareness)
识别项目生命周期阶段：
- 从概念验证到产品化
- 从单人开发到团队协作
- 从快速原型到稳定维护

### 用户行为感知 (User Behavior Analysis)

#### 沟通模式学习 (Communication Pattern Learning)
```json
{
  "communication_style": {
    "preferred_language": "zh-CN",
    "detail_level": "balanced",
    "confirmation_frequency": "medium"
  },
  "technical_focus": {
    "testing_emphasis": 0.8,
    "security_concern": 0.7,
    "performance_priority": 0.6
  }
}
```

#### 偏好模式识别 (Preference Pattern Recognition)
系统学习用户的协作偏好：
- 自主执行 vs 逐步指导
- 简洁响应 vs 详细解释
- 主动建议 vs 被动响应

## 🔄 自动优化流程 (Automatic Optimization Process)

### 触发条件 (Trigger Conditions)

#### 阈值触发 (Threshold-Based Triggers)
```yaml
evolution_triggers:
  project_scale_change:
    threshold: 0.25
    cooldown_days: 7
  team_change:
    threshold: 1
    cooldown_days: 14
  user_preference_accumulation:
    threshold: 10
    cooldown_days: 3
```

#### 模式触发 (Pattern-Based Triggers)
```yaml
pattern_triggers:
  repeated_issues:
    threshold: 3
    time_window_days: 14
  efficiency_patterns:
    threshold: 5
    success_rate_threshold: 0.8
```

### 优化策略 (Optimization Strategies)

#### 规则参数调整 (Rule Parameter Tuning)
- 根据项目规模调整规则严格程度
- 根据团队成熟度优化协作流程
- 根据用户偏好定制交互模式

#### 新规则生成 (New Rule Generation)
- 基于常见问题模式创建预防性规则
- 根据最佳实践识别生成指导性规则
- 基于用户反馈创建改进性规则

#### 规则冲突解决 (Rule Conflict Resolution)
- 自动检测规则间矛盾
- 基于优先级和上下文选择适用规则
- 生成冲突解决建议

## 📈 学习算法 (Learning Algorithms)

### 数据收集 (Data Collection)
```json
{
  "usage_metrics": {
    "rule_activation_count": 150,
    "average_response_time": 2.3,
    "user_satisfaction_score": 4.2
  },
  "feedback_analysis": {
    "positive_signals": 45,
    "negative_signals": 12,
    "improvement_suggestions": 8
  }
}
```

### 模型训练 (Model Training)
- 基于历史数据训练优化模型
- 使用强化学习优化规则参数
- 应用聚类分析识别用户群体

### 效果评估 (Effectiveness Evaluation)
- A/B测试不同规则配置
- 用户满意度调查和分析
- 性能指标监控和趋势分析

## 🛡️ 安全保障 (Safety Safeguards)

### 渐进式部署 (Gradual Rollout)
- 新规则从低风险环境开始测试
- 逐步扩大应用范围
- 实时监控异常情况

### 回滚机制 (Rollback Mechanisms)
- 自动检测性能下降
- 一键回滚到上一版本
- 保留完整的变更历史

### 人工监督 (Human Oversight)
- 重要变更需要人工审核
- 定期人工评估自动化效果
- 紧急情况下可手动干预

## 📊 性能监控 (Performance Monitoring)

### 效率指标 (Efficiency Metrics)
- 规则执行时间
- 系统响应延迟
- 资源使用情况

### 准确性指标 (Accuracy Metrics)
- 规则触发准确率
- 用户偏好预测准确度
- 自动化优化成功率

### 稳定性指标 (Stability Metrics)
- 系统可用性百分比
- 异常情况发生率
- 恢复时间指标
