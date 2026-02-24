---
description: "React 开发规则 - 组件化前端框架最佳实践 (react, jsx)"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 10
---

# ⚛️ React 开发规则

*版本: v4.4.0 | 已拆分组件/Hooks/状态至独立规则*

## 🎯 适用场景

- 现代 Web 应用、SPA/MPA
- 移动端 (React Native)、桌面 (Electron)
- 服务端渲染 (Next.js SSR)、静态站点 (SSG)
- 组件库和设计系统

## 📚 详细规范引用

- **组件规范**：见 `@react-basics-components`（项目结构、函数组件、类组件）
- **Hooks 规范**：见 `@react-basics-hooks`（自定义 Hooks、useForm、useLocalStorage、useDebounce 等）
- **状态管理**：见 `@react-basics-state`（Context API、useReducer、AuthContext 模式）

## 核心原则

- **MUST** 优先使用函数组件 + Hooks
- **MUST** 使用 PropTypes 或 TypeScript 定义 props
- **MUST** 用 useCallback/useMemo 优化性能
- **DO NOT** 在 render 中创建新函数或对象

---

*引用: @react-basics-components @react-basics-hooks @react-basics-state*
