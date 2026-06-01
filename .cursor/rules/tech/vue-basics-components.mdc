---
description: "Vue 组件规范 - 项目结构、Options API、组件设计、插槽"
globs: ["**/*.vue"]
alwaysApply: false
priority: 10
---

# Vue 组件规范 (Components)

> 本规则由 `@vue-basics` 引用

## 项目结构

### Vue CLI 布局
```
vue_project/
├── src/
│   ├── components/     # 全局组件
│   ├── views/          # 页面组件
│   ├── router/
│   ├── store/          # Vuex
│   ├── composables/    # 组合式函数
│   └── utils/
```

### Vue 3 + Pinia
```
vue3_project/
├── src/
│   ├── components/ui/
│   ├── components/forms/
│   ├── composables/
│   ├── stores/         # Pinia
│   └── router/
```

## Options API 示例

```vue
<template>
  <div class="todo-list">
    <form @submit.prevent="addTodo">
      <input v-model="newTodo" placeholder="添加新任务" required />
      <button type="submit">添加</button>
    </form>
    <ul>
      <li v-for="todo in filteredTodos" :key="todo.id">
        <input type="checkbox" v-model="todo.completed" />
        <span :class="{ completed: todo.completed }">{{ todo.title }}</span>
        <button @click="removeTodo(todo.id)">删除</button>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() { return { newTodo: '', todos: [], filter: 'all' } },
  computed: {
    filteredTodos() {
      switch (this.filter) {
        case 'active': return this.todos.filter(t => !t.completed)
        case 'completed': return this.todos.filter(t => t.completed)
        default: return this.todos
      }
    }
  },
  methods: { addTodo() {...}, removeTodo(id) {...} },
  mounted() {
    const saved = localStorage.getItem('todos')
    if (saved) this.todos = JSON.parse(saved)
  },
  watch: { todos: { handler() { localStorage.setItem('todos', JSON.stringify(this.todos)) }, deep: true } }
}
</script>
```

## 组件设计模式（插槽）

```vue
<!-- BaseCard.vue -->
<template>
  <div class="card" :class="variant">
    <div v-if="$slots.header" class="card-header"><slot name="header" /></div>
    <div class="card-body"><slot /></div>
    <div v-if="$slots.footer" class="card-footer"><slot name="footer" /></div>
  </div>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (v) => ['default', 'primary', 'secondary'].includes(v)
  }
})
</script>
```

## 编码要点

- **MUST** 使用 `scoped` 样式避免污染
- **MUST** 为 `v-for` 提供稳定的 `:key`
- **MUST** 用 `defineProps`/`defineEmits` 定义接口

---

*引用: @vue-basics*
