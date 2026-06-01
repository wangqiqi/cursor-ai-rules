---
description: "Vue 性能优化 - 懒加载、虚拟滚动、响应式优化"
globs: ["**/*.vue"]
alwaysApply: false
priority: 9
---

# Vue 性能优化 (Performance)

> 本规则由 `@vue-advanced` 引用

## 路由懒加载

```javascript
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true }
  }
]
```

## 组件异步加载

```javascript
const AsyncComponent = defineAsyncComponent({
  loader: () => import('./HeavyComponent.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 3000
})
```

## 虚拟滚动

```vue
<template>
  <div class="virtual-list" ref="container">
    <div class="virtual-list-phantom" :style="{ height: totalHeight + 'px' }"></div>
    <div class="virtual-list-content" :style="{ transform: `translateY(${offset}px)` }">
      <div v-for="item in visibleItems" :key="item.id" class="virtual-item">
        {{ item.content }}
      </div>
    </div>
  </div>
</template>
```

## 原则

- **MUST** 对路由使用懒加载
- **MUST** 对大列表使用虚拟滚动
- **MUST** 用 shallowRef 优化大对象响应式

---

*引用: @vue-advanced*
