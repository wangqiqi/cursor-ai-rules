---
description: "Vue 测试策略 - Vue Test Utils、Cypress E2E"
globs: ["**/*.vue"]
alwaysApply: false
priority: 9
---

# Vue 测试策略 (Testing)

> 本规则由 `@vue-advanced` 引用

## Vue Test Utils

```javascript
import { mount } from '@vue/test-utils'
import TodoList from '@/components/TodoList.vue'

describe('TodoList.vue', () => {
  it('renders todo list', () => {
    const wrapper = mount(TodoList, { global: { mocks: { $store: mockStore } } })
    expect(wrapper.findAll('.todo-item')).toHaveLength(1)
  })

  it('adds new todo', async () => {
    await wrapper.find('input').setValue('New Todo')
    await wrapper.find('button').trigger('click')
    expect(mockStore.commit).toHaveBeenCalledWith('addTodo', expect.any(Object))
  })
})
```

## Composition API + Pinia 测试

```javascript
const wrapper = mount(UserProfile, {
  global: {
    plugins: [createTestingPinia({
      initialState: { user: { name: 'John', email: 'john@example.com' } }
    })]
  }
})
```

## Cypress E2E

```javascript
it('adds a new todo', () => {
  cy.get('[data-cy="todo-input"]').type('Learn Vue.js{enter}')
  cy.get('[data-cy="todo-list"]').should('contain', 'Learn Vue.js')
})
```

## 原则

- **MUST** 使用 data-cy 属性便于 E2E 选择
- **MUST** 用 createTestingPinia 隔离 store 状态

---

*引用: @vue-advanced*
