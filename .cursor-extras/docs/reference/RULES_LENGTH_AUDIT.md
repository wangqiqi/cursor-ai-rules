# 规则长度审计

> Cursor 建议规则控制在 500 行以内 | 更新: 2026-02-24

## 当前状态

- **规则总数**: 75 个
- **超长规则 (>500 行)**: 0 个 ✅ 已全部拆分达标

## 历史超长规则（已拆分）

| 规则 | 行数 | 建议 |
|------|------|------|
| conversation_intent_analyzer.md | ~~712~~ 106 | ✅ 已拆分至 conversation_intent_classification、conversation_intent_templates |
| typescript-advanced.md | ~~674~~ 29 | ✅ 已拆分至 typescript-advanced-types、typescript-advanced-practices |
| react-basics.md | ~~673~~ 36 | ✅ 已拆分至 react-basics-components、react-basics-hooks、react-basics-state |
| c-basics.md | ~~670~~ 精简 | ✅ 已拆分至 c-basics-syntax、c-basics-memory、c-basics-practices |
| react-advanced.md | ~~570~~ 29 | ✅ 已拆分至 react-advanced-performance、react-advanced-security、react-advanced-practices |
| cpp-advanced.md | ~~568~~ 精简 | ✅ 已拆分至 cpp-advanced-templates、cpp-advanced-concurrency、cpp-advanced-practices |
| vue-basics.md | ~~561~~ 33 | ✅ 已拆分至 vue-basics-components、vue-basics-composables |
| intelligent_evolution.md | ~~554~~ 精简 | ✅ 已拆分至 intelligent_evolution-entry、intelligent_evolution-strategies |
| constitution.md | ~~542~~ 450 | ✅ 已拆分至 constitution_architecture.md（已达标） |
| vibe-coding.md | ~~540~~ 470 | ✅ 已拆分至 vibe-coding-tools.md |
| vue-advanced.md | ~~529~~ 精简 | ✅ 已拆分至 vue-advanced-testing、vue-advanced-performance |
| rust-basics.md | ~~517~~ 精简 | ✅ 已拆分至 rust-basics-ownership、rust-basics-types、rust-basics-practices |
| platform_adapter.md | ~~501~~ 424 | ✅ 已拆分路径至 platform_adapter_paths.md |

## 拆分原则

1. 按功能域拆分，保持单一职责
2. 使用 `@filename` 引用而非复制内容
3. 保持各规则可独立应用（按 globs/description）

## 参考

- [Cursor 规则最佳实践](https://cursor.com/cn/docs/context/rules)
