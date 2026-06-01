# 规则激活规范流程

> 明确规则激活、冲突解决、脚本执行的职责边界 | 更新: 2026-06-01

## 规范流程

```
规则激活（由 Cursor IDE 自动完成）
    ↓
① Cursor IDE 根据规则 frontmatter 加载
   - globs: 当前打开文件匹配时加载
   - alwaysApply: true 时始终加载
   - description: Agent 按需智能加载（Apply Intelligently）
    ↓
② 规则策略参考（AI 侧）
   - @rules-router: 激活策略、依赖、优先级
   - @rules-conflict-resolver: 冲突解决
    ↓
③ 用户显式调用「rule X」时
   - master-parser 解析为 direct_call
   - master-executor / cursor-master 执行 executeRule(X)
   - 仅执行指定规则，不参与激活决策
```

## 组件职责

| 组件 | 职责 | 不负责 |
|------|------|--------|
| **@rules-router** | 规则激活策略、依赖关系、优先级矩阵的规范入口 | 不执行脚本 |
| **@rules-conflict-resolver** | 冲突解决策略，由 @rules-router 引用 | 不独立定义激活逻辑 |
| **Cursor IDE** | 根据 globs/alwaysApply/description 自动加载 `.mdc` 规则 | 不解析自定义 apply_when |
| **master-executor / cursor-master** | 用户请求「rule X」时执行该规则 | 不决定激活哪些规则 |
| **master-handler** | 同上，IDE 集成场景 | 不实现规则选择逻辑 |

## 实现状态（2026-06-01）

1. **frontmatter 统一**: 76 个规则均为 `.mdc`，使用 `description`、`globs`、`alwaysApply`（官方格式）
2. **交叉引用**: 规则间使用 `@规则名`（无 `.md` / `.mdc` 后缀）
3. **@rules-router**: 规范入口，定义激活策略
4. **@rules-conflict-resolver**: 引用 @rules-router，专注冲突解决
5. **脚本**: 仅提供 executeRule(name)，无激活决策逻辑

## 相关文件

- `.cursor/rules/rules-router.mdc` - 规则激活策略规范
- `.cursor/rules/rules-conflict-resolver.mdc` - 冲突解决
- `.cursor/commands/master-executor.js` - executeRule 委托
- `.cursor/cursor-master.sh` - execute_rule_call
