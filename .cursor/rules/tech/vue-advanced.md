---
description: "Vue高级实践 - 测试、性能优化、安全实践和最佳实践"
apply_when:
  - keywords: ["vue", "测试", "性能", "安全", "优化"]
priority: 9
---

# Vue 高级实践

本文档是从 `vue.md` 分割出来的高级主题部分，涵盖测试策略、性能优化、安全实践和最佳实践。

      scss: {
        additionalData: `@import "@/styles/variables.scss";`
      }
    }
  },

  // PWA配置
  pwa: {
    name: 'Vue App',
    themeColor: '#007acc'
  }
}
```

## 🧪 测试策略

### Vue Test Utils 单元测试
```javascript
import { describe, it, expect, beforeEach } from '@jest/globals'
import { mount, shallowMount } from '@vue/test-utils'
import TodoList from '@/components/TodoList.vue'

describe('TodoList.vue', () => {
  let wrapper
  let mockStore

  beforeEach(() => {
    mockStore = {
      state: {
        todos: [
          { id: 1, title: 'Test Todo', completed: false }
        ]
      },
      commit: jest.fn()
    }

    wrapper = mount(TodoList, {
      global: {
        mocks: {
          $store: mockStore
        }
      }
    })
  })

  it('renders todo list', () => {
    expect(wrapper.findAll('.todo-item')).toHaveLength(1)
    expect(wrapper.text()).toContain('Test Todo')
  })

  it('adds new todo', async () => {
    const input = wrapper.find('input[type="text"]')
    const button = wrapper.find('button[type="submit"]')

    await input.setValue('New Todo')
    await button.trigger('click')

    expect(mockStore.commit).toHaveBeenCalledWith('addTodo', {
      title: 'New Todo',
      completed: false
    })
  })

  it('filters todos correctly', async () => {
    const activeButton = wrapper.findAll('button').at(1) // Active filter
    await activeButton.trigger('click')

    // Should only show uncompleted todos
    expect(wrapper.findAll('.todo-item')).toHaveLength(1)
  })
})

// Composition API 测试
import { describe, it, expect } from '@jest/globals'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import UserProfile from '@/components/UserProfile.vue'

describe('UserProfile.vue', () => {
  it('updates profile successfully', async () => {
    const wrapper = mount(UserProfile, {
      global: {
        plugins: [createTestingPinia({
          initialState: {
            user: { name: 'John', email: 'john@example.com' }
          }
        })]
      }
    })

    const nameInput = wrapper.find('input[name="name"]')
    await nameInput.setValue('Jane')

    const submitButton = wrapper.find('button[type="submit"]')
    await submitButton.trigger('click')

    // 验证UI更新
    expect(wrapper.text()).toContain('Jane')
  })
})
```

### Cypress 端到端测试
```javascript
// cypress/integration/todo.spec.js
describe('Todo App', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('adds a new todo', () => {
    cy.get('[data-cy="todo-input"]').type('Learn Vue.js{enter}')
    cy.get('[data-cy="todo-list"]').should('contain', 'Learn Vue.js')
  })

  it('completes a todo', () => {
    cy.get('[data-cy="todo-input"]').type('Write tests{enter}')
    cy.get('[data-cy="todo-item"]').first().find('input[type="checkbox"]').check()
    cy.get('[data-cy="todo-item"]').first().should('have.class', 'completed')
  })

  it('filters todos', () => {
    // 添加多个todos
    cy.get('[data-cy="todo-input"]').type('Todo 1{enter}')
    cy.get('[data-cy="todo-input"]').type('Todo 2{enter}')

    // 完成一个
    cy.get('[data-cy="todo-item"]').first().find('input[type="checkbox"]').check()

    // 过滤显示
    cy.contains('Active').click()
    cy.get('[data-cy="todo-item"]').should('have.length', 1)
  })
})
```

## 🚀 性能优化

### 组件懒加载
```javascript
// 路由懒加载
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    component: () => import('@/views/Profile.vue')
  }
]

// 组件异步加载
const AsyncComponent = defineAsyncComponent({
  loader: () => import('./HeavyComponent.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 3000
})
```

### 虚拟滚动
```vue
<template>
  <div class="virtual-list" ref="container">
    <div class="virtual-list-phantom" :style="{ height: totalHeight + 'px' }"></div>
    <div class="virtual-list-content" :style="{ transform: `translateY(${offset}px)` }">
      <div
        v-for="(item, index) in visibleItems"
        :key="item.id"
        class="virtual-list-item"
        :style="{ height: itemHeight + 'px' }"
      >
        <slot :item="item" :index="index" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  items: {
    type: Array,
    required: true
  },
  itemHeight: {
    type: Number,
    default: 50
  }
})

const container = ref(null)
const scrollTop = ref(0)

const totalHeight = computed(() => props.items.length * props.itemHeight)
const visibleCount = computed(() => Math.ceil(container.value?.clientHeight / props.itemHeight) + 10)
const startIndex = computed(() => Math.floor(scrollTop.value / props.itemHeight))
const endIndex = computed(() => Math.min(startIndex.value + visibleCount.value, props.items.length))
const visibleItems = computed(() => props.items.slice(startIndex.value, endIndex.value))
const offset = computed(() => startIndex.value * props.itemHeight)

const handleScroll = () => {
  scrollTop.value = container.value.scrollTop
}

onMounted(() => {
  container.value.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  container.value?.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
.virtual-list {
  height: 400px;
  overflow: auto;
  position: relative;
}

.virtual-list-phantom {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
}

.virtual-list-content {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
}
</style>
```

### 状态管理优化
```javascript
// stores/user.js - Pinia
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // 状态
  const user = ref(null)
  const loading = ref(false)

  // 计算属性
  const isAuthenticated = computed(() => !!user.value)
  const displayName = computed(() => user.value?.name || 'Guest')

  // 动作
  const login = async (credentials) => {
    loading.value = true
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials)
      })
      user.value = await response.json()
    } finally {
      loading.value = false
    }
  }

  const logout = () => {
    user.value = null
  }

  return {
    user,
    loading,
    isAuthenticated,
    displayName,
    login,
    logout
  }
})
```

## 🔒 安全实践

### 输入验证和清理
```javascript
// composables/useValidation.js
import { ref } from 'vue'

export function useValidation() {
  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  const validatePassword = (password) => {
    // 至少8位，包含大小写字母和数字
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/
    return passwordRegex.test(password)
  }

  const sanitizeHtml = (html) => {
    // 使用DOMPurify或其他库清理HTML
    return html.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
  }

  const validateInput = (input, rules) => {
    const errors = []

    if (rules.required && (!input || input.trim() === '')) {
      errors.push('此字段为必填项')
    }

    if (rules.minLength && input.length < rules.minLength) {
      errors.push(`最少需要${rules.minLength}个字符`)
    }

    if (rules.maxLength && input.length > rules.maxLength) {
      errors.push(`最多只能${rules.maxLength}个字符`)
    }

    if (rules.pattern && !rules.pattern.test(input)) {
      errors.push('格式不正确')
    }

    return errors
  }

  return {
    validateEmail,
    validatePassword,
    sanitizeHtml,
    validateInput
  }
}
```

### XSS防护
```vue
<template>
  <!-- 安全的HTML渲染 -->
  <div v-html="sanitizedContent"></div>

  <!-- 安全的URL处理 -->
  <a :href="safeUrl" target="_blank" rel="noopener noreferrer">
    {{ linkText }}
  </a>
</template>

<script setup>
import { computed } from 'vue'
import DOMPurify from 'dompurify'

const props = defineProps({
  rawContent: String,
  url: String,
  linkText: String
})

// 清理HTML内容
const sanitizedContent = computed(() => {
  if (!props.rawContent) return ''
  return DOMPurify.sanitize(props.rawContent, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em'],
    ALLOWED_ATTR: []
  })
})

// 验证和清理URL
const safeUrl = computed(() => {
  if (!props.url) return '#'

  try {
    const url = new URL(props.url)

    // 只允许http和https协议
    if (!['http:', 'https:'].includes(url.protocol)) {
      return '#'
    }

    // 检查是否为可信域名
    const trustedDomains = ['example.com', 'trusted-site.com']
    if (!trustedDomains.some(domain => url.hostname.endsWith(domain))) {
      return '#'
    }

    return url.toString()
  } catch {
    return '#'
  }
})
</script>
```

## 📊 最佳实践

### 项目组织最佳实践
```javascript
// 目录结构约定
src/
├── components/     # 可复用组件
│   ├── ui/        # 基础UI组件
│   ├── forms/     # 表单组件
│   └── layout/    # 布局组件
├── views/         # 页面级组件
├── composables/   # 组合式函数
├── stores/        # 状态管理
├── router/        # 路由配置
├── types/         # TypeScript类型
├── utils/         # 工具函数
└── styles/        # 样式文件
```

### 组件命名约定
```javascript
// 文件名：PascalCase
UserProfile.vue
TodoList.vue
BaseButton.vue

// 组件名：与文件名一致
export default {
  name: 'UserProfile'
}

// 事件名：camelCase
this.$emit('userUpdated', userData)

// Props名：camelCase
props: {
  userData: Object,
  isLoading: Boolean
}
```

### 状态管理模式
```javascript
// 组合式store模式
import { ref, computed } from 'vue'

export function useCounter() {
  const count = ref(0)

  const doubleCount = computed(() => count.value * 2)

  const increment = () => {
    count.value++
  }

  const decrement = () => {
    count.value--
  }

  return {
    count,
    doubleCount,
    increment,
    decrement
  }
}

// 全局store模式
import { defineStore } from 'pinia'

export const useAppStore = defineStore('app', {
  state: () => ({
    theme: 'light',
    language: 'zh-CN'
  }),

  getters: {
    isDark: (state) => state.theme === 'dark'
  },

  actions: {
    toggleTheme() {
      this.theme = this.theme === 'light' ? 'dark' : 'light'
    },

    setLanguage(lang) {
      this.language = lang
    }
  }
})
```

### 代码分割和懒加载
```javascript
// 路由级代码分割
const routes = [
  {
    path: '/dashboard',
    component: () => import(/* webpackChunkName: "dashboard" */ '@/views/Dashboard.vue'),
    children: [
      {
        path: 'analytics',
        component: () => import(/* webpackChunkName: "analytics" */ '@/views/Analytics.vue')
      }
    ]
  }
]

// 组件级懒加载
const LazyComponent = defineAsyncComponent({
  loader: () => import('./HeavyComponent.vue'),
  loadingComponent: () => import('./LoadingSpinner.vue'),
  errorComponent: () => import('./ErrorComponent.vue'),
  delay: 200,
  timeout: 3000
})
```

---

*此规则适用于现代Vue.js开发项目。优先使用Vue 3 Composition API，注重组件化和代码复用性。*