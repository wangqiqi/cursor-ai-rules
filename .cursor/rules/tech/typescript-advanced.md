---
description: "TypeScript 高级实践 - 测试、性能优化、安全实践和最佳实践 (typescript, 测试, 性能, 安全, 优化)"
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
priority: 9
---

# TypeScript 高级实践

本文档涵盖 TypeScript 高级开发主题。详细规范已拆分至独立规则。

## ⚠️ 执行原则

**MUST** 遵循以下准则：
- **MUST** 充分利用 TypeScript 类型系统
- **NEVER** 使用 `any` 逃避类型检查
- **ALWAYS** 编写可重用的类型定义
- **DO NOT** 忽略编译器错误
- **MUST** 保持类型定义的更新
- **ALWAYS** 使用严格的类型检查

## 📚 详细规范引用

- **类型系统**：见 `@typescript-advanced-types`（类型测试、类型守卫、工具类型、模块声明）
- **高级实践**：见 `@typescript-advanced-practices`（性能优化、安全实践、最佳实践、项目组织）

---

*此规则适用于现代 TypeScript 开发项目。充分利用类型系统提高代码质量和开发效率。*
