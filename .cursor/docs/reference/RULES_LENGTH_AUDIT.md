# 规则长度审计

> Cursor 建议规则控制在 500 行以内 | 更新: 2026-02-24

## 超长规则 (>500 行)

| 规则 | 行数 | 建议 |
|------|------|------|
| conversation_intent_analyzer.md | 712 | 拆分为「意图分类」+「对话模板」 |
| typescript-advanced.md | 674 | 拆分为「类型系统」+「高级模式」 |
| react-basics.md | 673 | 拆分为「组件」+「Hooks」+「状态」 |
| c-basics.md | 670 | 拆分为「语法」+「内存」+「实践」 |
| react-advanced.md | 570 | 拆分为「性能」+「安全」+「测试」 |
| cpp-advanced.md | 568 | 拆分为「模板」+「并发」+「最佳实践」 |
| vue-basics.md | 561 | 拆分为「组件」+「组合式」+「路由」 |
| intelligent_evolution.md | 554 | 拆分为「入口」+「策略」+「规则」 |
| constitution.md | 542 | 核心宪法，可拆分「检测」+「原则」 |
| vibe-coding.md | 540 | 拆分为「流程」+「接口」+「示例」 |
| vue-advanced.md | 529 | 拆分为「测试」+「性能」+「安全」 |
| rust-basics.md | 517 | 拆分为「所有权」+「类型」+「实践」 |
| platform_adapter.md | 501 | 拆分为「路径」+「命令」+「环境」 |

## 拆分原则

1. 按功能域拆分，保持单一职责
2. 使用 `@filename` 引用而非复制内容
3. 保持各规则可独立应用（按 globs/description）

## 参考

- [Cursor 规则最佳实践](https://cursor.com/cn/docs/context/rules)
