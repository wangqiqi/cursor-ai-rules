---
description: "规则冲突解决器 - 优先级矩阵、冲突解决和性能监控"
apply_when:
  - keywords: ["冲突", "优先级", "性能", "监控"]
priority: 19
---

# ⚡ 规则冲突解决和监控 (Rule Conflict Resolver & Monitor)

本文档是从 `rules-router.md` 分割出来的冲突解决和监控部分。

## ⚠️ 解决原则

**MUST** 遵循以下冲突解决准则：
- **MUST** 基于优先级矩阵解决规则冲突
- **NEVER** 随意忽略或禁用冲突的规则
- **ALWAYS** 记录冲突解决决策
- **DO NOT** 让规则冲突影响系统稳定性
- **MUST** 定期审查和优化冲突解决策略
- **ALWAYS** 提供冲突解决的透明性

### 优先级计算模型

```typescript
interface RulePriority {
  basePriority: number;     // 基础优先级
  contextBoost: number;     // 上下文提升
  userPreference: number;   // 用户偏好
  recencyBonus: number;     // 最近使用奖励
  finalPriority: number;    // 最终优先级
}

class PriorityCalculator {
  calculatePriorities(
    rules: string[],
    context: RuleActivationContext
  ): Record<string, RulePriority> {

    const priorities: Record<string, RulePriority> = {};

    for (const rule of rules) {
      const basePriority = RULE_DEPENDENCIES[rule]?.priority ?? 5;

      // 上下文提升
      let contextBoost = 0;
      if (this.isHighlyRelevant(rule, context)) {
        contextBoost += 3;
      } else if (this.isModeratelyRelevant(rule, context)) {
        contextBoost += 1;
      }

      // 用户偏好
      const userPreference = context.userPreferences?.rule_preferences?.[rule] ?? 0;

      // 最近使用奖励 (模拟)
      const recencyBonus = Math.random() * 2; // 0-2的随机值

      const finalPriority = basePriority + contextBoost + userPreference + recencyBonus;

      priorities[rule] = {
        basePriority,
        contextBoost,
        userPreference,
        recencyBonus,
        finalPriority
      };
    }

    return priorities;
  }

  private isHighlyRelevant(rule: string, context: RuleActivationContext): boolean {
    const highRelevanceMap: Record<string, string[]> = {
      "javascript": ["javascript", "typescript", "react", "vue", "node"],
      "python": ["python", "django", "fastapi", "flask"],
      "collaboration": ["team", "collaboration", "git", "merge"],
      "generator": ["create", "new", "init", "generate"],
      "eslint": ["lint", "quality", "check", "fix"]
    };

    const relevantContexts = highRelevanceMap[rule] ?? [];
    return relevantContexts.some(ctx =>
      context.userIntent.includes(ctx) ||
      context.techStack.includes(ctx) ||
      context.projectType.includes(ctx)
    );
  }

  private isModeratelyRelevant(rule: string, context: RuleActivationContext): boolean {
    // 中等相关性逻辑
    return false; // 简化实现
  }
}
```

## ⚡ 规则冲突解决

### 冲突检测和解决

```typescript
interface RuleConflict {
  rule1: string;
  rule2: string;
  reason: "explicit_conflict" | "resource_conflict" | "priority_conflict";
  resolution: "keep_higher_priority" | "keep_both" | "remove_lower_priority";
}

class ConflictResolver {
  resolveConflicts(
    activeRules: string[],
    conflicts: RuleConflict[],
    priorities: Record<string, RulePriority>
  ): string[] {

    const resolvedRules = new Set(activeRules);

    for (const conflict of conflicts) {
      const priority1 = priorities[conflict.rule1]?.finalPriority ?? 0;
      const priority2 = priorities[conflict.rule2]?.finalPriority ?? 0;

      switch (conflict.resolution) {
        case "keep_higher_priority":
          if (priority1 > priority2) {
            resolvedRules.delete(conflict.rule2);
          } else {
            resolvedRules.delete(conflict.rule1);
          }
          break;

        case "keep_both":
          // 允许共存
          break;

        case "remove_lower_priority":
          if (priority1 > priority2) {
            resolvedRules.delete(conflict.rule2);
          } else {
            resolvedRules.delete(conflict.rule1);
          }
          break;
      }
    }

    return Array.from(resolvedRules);
  }
}
```

## 📊 规则性能监控

### 激活统计和优化

```typescript
interface RuleActivationStats {
  rule: string;
  activationCount: number;
  averageActivationTime: number;
  successRate: number;
  userSatisfaction: number;
  lastActivated: Date;
}

class RulePerformanceMonitor {
  private stats: Map<string, RuleActivationStats> = new Map();

  recordActivation(
    rule: string,
    activationTime: number,
    success: boolean,
    userFeedback?: number
  ): void {
    const existing = this.stats.get(rule) ?? {
      rule,
      activationCount: 0,
      averageActivationTime: 0,
      successRate: 0,
      userSatisfaction: 0,
      lastActivated: new Date()
    };

    const newCount = existing.activationCount + 1;
    const newAvgTime = (existing.averageActivationTime * existing.activationCount + activationTime) / newCount;
    const newSuccessRate = ((existing.successRate * existing.activationCount) + (success ? 1 : 0)) / newCount;
    const newSatisfaction = userFeedback ??
      ((existing.userSatisfaction * existing.activationCount) / newCount);

    this.stats.set(rule, {
      ...existing,
      activationCount: newCount,
      averageActivationTime: newAvgTime,
      successRate: newSuccessRate,
      userSatisfaction: newSatisfaction,
      lastActivated: new Date()
    });
  }

  getPerformanceReport(): RuleActivationStats[] {
    return Array.from(this.stats.values())
      .sort((a, b) => b.activationCount - a.activationCount);
  }

  optimizeRulePriorities(): Record<string, number> {
    const optimizations: Record<string, number> = {};

    for (const [rule, stats] of this.stats) {
      // 基于性能数据调整优先级
      let priorityAdjustment = 0;

      if (stats.successRate > 0.9) priorityAdjustment += 1;
      if (stats.userSatisfaction > 4.0) priorityAdjustment += 1;
      if (stats.averageActivationTime < 100) priorityAdjustment += 0.5;

      if (stats.successRate < 0.7) priorityAdjustment -= 1;
      if (stats.userSatisfaction < 3.0) priorityAdjustment -= 1;

      optimizations[rule] = priorityAdjustment;
    }

    return optimizations;
  }
}
```

## 🔧 集成接口

### 与Master命令的集成

```typescript
// 集成到 master.md 的规则路由接口
interface RulesRouterIntegration {
  // 规则路由入口
  routeRules(context: RuleActivationContext): Promise<RuleActivationResult>;

  // 规则性能反馈
  reportRulePerformance(rule: string, metrics: RulePerformanceMetrics): void;

  // 动态规则学习
  learnFromInteraction(context: RuleActivationContext, result: RuleActivationResult): void;
}

// Master命令中的集成使用
class MasterCommandController {
  private rulesRouter: RulesRouterIntegration;

  async executeUserRequest(userInput: string): Promise<ExecutionResult> {
    // 1. 解析用户意图
    const intent = await this.parseIntent(userInput);

    // 2. 构建规则激活上下文
    const context: RuleActivationContext = {
      userIntent: userInput,
      projectType: await this.detectProjectType(),
      techStack: await this.detectTechStack(),
      teamSize: await this.detectTeamSize(),
      developmentStage: await this.detectDevStage(),
      environment: await this.detectEnvironment(),
      userPreferences: await this.getUserPreferences()
    };

    // 3. 路由规则
    const ruleResult = await this.rulesRouter.routeRules(context);

    // 4. 执行规则激活的逻辑
    const executionResult = await this.executeWithRules(ruleResult);

    // 5. 报告性能
    for (const rule of ruleResult.activeRules) {
      this.rulesRouter.reportRulePerformance(rule, {
        activationTime: executionResult.duration,
        success: executionResult.success,
        userSatisfaction: executionResult.userFeedback
      });
    }

    // 6. 学习优化
    this.rulesRouter.learnFromInteraction(context, ruleResult);

    return executionResult;
  }
}
```

## 🎯 使用示例

### 基本规则路由

```typescript
// 示例：React项目创建
const context: RuleActivationContext = {
  userIntent: "我想创建一个React项目",
  projectType: "frontend",
  techStack: ["javascript", "react"],
  teamSize: 1,
  developmentStage: "initialization",
  environment: "development",
  userPreferences: { language: "zh-CN" }
};

const result = await rulesRouter.routeRules(context);
// result.activeRules = ["conversation_intent_analyzer", "generator", "templates", "javascript"]
// result.priorityOrder = ["conversation_intent_analyzer", "generator", "templates", "javascript"]
```

### 高级规则路由

```typescript
// 示例：团队代码审查
const context: RuleActivationContext = {
  userIntent: "团队需要进行代码审查",
  projectType: "webapp",
  techStack: ["typescript", "react"],
  teamSize: 5,
  developmentStage: "development",
  environment: "ci/cd",
  userPreferences: { collaboration: true }
};

const result = await rulesRouter.routeRules(context);
// result.activeRules = ["collaboration", "eslint", "intelligent_evolution", "javascript", "evolution-governance"]
// result.priorityOrder = ["collaboration", "eslint", "intelligent_evolution", "javascript", "evolution-governance"]
```

## 📋 规则路由配置

### 规则路由配置文件

```json
{
  "rules_router_config": {
    "version": "1.0.0",
    "enable_performance_monitoring": true,
    "enable_learning": true,
    "conflict_resolution_strategy": "priority_based",
    "max_activation_depth": 5,
    "cache_enabled": true,
    "cache_ttl_seconds": 3600,

    "custom_activation_rules": {
      "enterprise_mode": {
        "condition": "team_size > 10",
        "additional_rules": ["evolution-governance", "platform_adapter"],
        "priority_boost": 2
      },

      "strict_quality_mode": {
        "condition": "quality_gate_enabled",
        "additional_rules": ["eslint", "intelligent_evolution"],
        "priority_boost": 3
      }
    },

    "rule_overrides": {
      "javascript": {
        "priority": 8,
        "activation_condition": "javascript_or_typescript_files"
      }
    }
  }
}
```

---

*🎯 规则路由器让AI能够智能地编排和激活最合适的规则组合*
