---
description: "Vue.js 开发规则 - 渐进式前端框架最佳实践 (vue, nuxt)"
globs: ["**/*.vue"]
alwaysApply: false
priority: 10
---

# 💚 Vue.js 开发规则

*版本: v4.4.0 | 已拆分组件/组合式至独立规则*

## 🎯 适用场景

- 现代 Web 应用、SPA/MPA
- 移动端 (Cordova/PhoneGap)、桌面 (Electron)
- SSR、SSG、组件库和 UI 框架

## 📚 详细规范引用

- **组件规范**：见 `@vue-basics-components`（项目结构、Options API、组件设计、插槽）
- **组合式 API**：见 `@vue-basics-composables`（Composition API、useAuth、useApi）

## 核心原则

- **MUST** 优先使用 Composition API + `<script setup>`
- **MUST** 使用 `scoped` 样式
- **MUST** 为 `v-for` 提供稳定 `:key`
- **MUST** 用 Pinia 管理全局状态（Vue 3）

---

*引用: @vue-basics-components @vue-basics-composables*
