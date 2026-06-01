---
description: "对话意图响应模板库 - 项目创建、技术咨询、重构同步等标准模板"
globs: ["**/*"]
alwaysApply: false
priority: 17
---

# 响应模板库 (Response Template Library)

> 本规则由 `@conversation_intent_analyzer` 引用，定义各类意图的标准响应模板

## 响应策略选择

- **高置信度 (>0.8)**：直接给出建议
- **中等置信度 (0.6-0.8)**：给出建议并询问确认
- **低置信度 (<0.6)**：提出澄清问题

## 项目创建模板

```markdown
## 🤖 项目创建意图检测

检测到你想要**创建新项目**！

### 📋 需求分析
- **项目类型**: {{primary_intent}}
- **技术领域**: {{tech_domains}}
- **复杂度评估**: {{complexity_level}}

### 🛠️ 推荐技术方案

#### 前端技术栈
{{frontend_suggestions}}

#### 后端技术栈
{{backend_suggestions}}

#### 数据库选择
{{database_suggestions}}

#### 部署方案
{{deployment_suggestions}}

### ❓ 需要澄清的问题
{{clarification_questions}}

你希望深入讨论哪个方面？或者有其他具体需求吗？🎯
```

## 技术咨询模板

```markdown
## 🤖 技术咨询意图检测

你似乎在咨询**{{tech_domain}}**相关技术！

### 🔍 技术分析
基于你的描述"{{user_input}}"，我建议：

### 📖 学习路径
{{learning_path}}

### 🛠️ 工具推荐
{{tool_recommendations}}

### 📚 资源推荐
{{resource_recommendations}}

你对哪个具体技术点感兴趣？🤔
```

## 重构同步模板

```markdown
## 🤖 重构同步意图检测

检测到你需要进行**模块同步修改**！

### 📋 变更分析
- **变更类型**: {{change_type}}
- **受影响文件数**: {{affected_files_count}}
- **置信度**: {{confidence_level}}

### 🔍 同步影响分析

#### 直接影响的文件
{{direct_impacts}}

#### 间接影响的文件
{{indirect_impacts}}

#### 推荐同步操作
{{sync_actions}}

### ⚡ 自动化修复建议
{{auto_fix_suggestions}}

### ❓ 确认操作
你希望我按优先级顺序帮你处理这些同步修改吗？或者你想先手动检查某些文件？

**建议优先级**: 关键影响 → 高影响 → 中等影响 🎯
```

## 个性化响应要点

1. **技术偏好**：根据用户偏好的框架/语言调整建议
2. **项目经验**：根据历史项目调整复杂度与细节程度
3. **澄清问题**：最多 3 个，聚焦关键决策点

## 配置与扩展

```yaml
conversation_intent_analyzer:
  intent_recognition:
    confidence_threshold: 0.7
    context_window: 5
  response:
    clarification_questions_max: 3
```

---

*引用: @conversation_intent_analyzer*
