---
description: "Vue.js开发规则 - 渐进式前端框架最佳实践"
apply_when:
  - file_pattern: "**/*.vue"
  - keywords: ["vue", "nuxt"]
priority: 10
---

# 💚 Vue.js 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 现代Web应用开发
- 单页应用(SPA)和多页应用(MPA)
- 移动端应用(Vue + Cordova/PhoneGap)
- 桌面应用(Vue + Electron)
- 服务端渲染(SSR)和静态站点生成(SSG)
- 组件库和UI框架开发

## 🏗️ 项目结构

### Vue CLI 项目布局
```
vue_project/
├── public/                    # 静态资源 (不会被webpack处理)
│   ├── index.html
│   ├── favicon.ico
│   └── assets/
├── src/                       # 源代码
│   ├── main.js               # 应用入口
│   ├── App.vue               # 根组件
│   ├── components/           # 全局组件
│   │   ├── BaseButton.vue
│   │   └── BaseInput.vue
│   ├── views/                # 页面组件
│   │   ├── Home.vue
│   │   └── About.vue
│   ├── router/               # 路由配置
│   │   └── index.js
│   ├── store/                # Vuex状态管理
│   │   └── index.js
│   ├── composables/          # 组合式函数
│   │   ├── useAuth.js
│   │   └── useApi.js
│   ├── utils/                # 工具函数
│   ├── types/                # TypeScript类型定义
│   ├── assets/               # 会被webpack处理的资源
│   │   ├── styles/
│   │   └── images/
│   └── plugins/              # Vue插件
├── tests/                    # 测试
│   ├── unit/                 # 单元测试
│   └── e2e/                  # 端到端测试
├── dist/                     # 构建输出
├── node_modules/            # 依赖包
├── package.json
├── vue.config.js            # Vue CLI配置
├── babel.config.js
├── .eslintrc.js
├── jest.config.js
└── cypress.json
```

### Vue 3 Composition API 项目结构
```
vue3_project/
├── src/
│   ├── components/
│   │   ├── ui/              # UI组件
│   │   └── forms/           # 表单组件
│   ├── composables/         # 组合式函数
│   │   ├── useCounter.js
│   │   ├── useFetch.js
│   │   └── useValidation.js
│   ├── views/
│   ├── router/
│   ├── stores/              # Pinia状态管理
│   │   ├── user.js
│   │   └── cart.js
│   ├── types/
│   └── utils/
├── tests/
└── package.json
```

## 📝 编码规范

### Vue 3 Composition API 最佳实践
```vue
<template>
  <div class="user-profile">
    <h1>{{ user.name }}</h1>
    <p>{{ user.email }}</p>
    <button @click="updateProfile" :disabled="loading">
      {{ loading ? '更新中...' : '更新资料' }}
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user'

// 组合式函数使用
const { validateEmail, formatDate } = useValidation()

// 响应式状态
const loading = ref(false)
const error = ref(null)

// 计算属性
const userStore = useUserStore()
const { user, isAuthenticated } = storeToRefs(userStore)

// 路由参数
const route = useRoute()
const userId = computed(() => route.params.id)

// 表单数据
const form = ref({
  name: '',
  email: '',
  bio: ''
})

// 验证规则
const validationRules = {
  name: (value: string) => value.length >= 2 || '姓名至少2个字符',
  email: (value: string) => validateEmail(value) || '邮箱格式不正确',
  bio: (value: string) => value.length <= 500 || '个人简介不能超过500字符'
}

// 计算属性：表单验证状态
const isFormValid = computed(() => {
  return Object.values(validationRules).every(rule =>
    typeof rule(form.value[rule.name]) !== 'string'
  )
})

// 监听器
watch(() => user.value, (newUser) => {
  if (newUser) {
    form.value = {
      name: newUser.name,
      email: newUser.email,
      bio: newUser.bio || ''
    }
  }
}, { immediate: true })

// 异步函数
const updateProfile = async () => {
  if (!isFormValid.value) return

  loading.value = true
  error.value = null

  try {
    await userStore.updateProfile(userId.value, form.value)
    // 成功提示
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

// 生命周期
onMounted(() => {
  if (!isAuthenticated.value) {
    // 重定向到登录页
  }
})

onUnmounted(() => {
  // 清理资源
})
</script>

<style scoped>
.user-profile {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
```

### Vue 3 Options API (兼容性写法)
```vue
<template>
  <div class="todo-list">
    <h1>待办事项</h1>
    <form @submit.prevent="addTodo">
      <input v-model="newTodo" placeholder="添加新任务" required />
      <button type="submit">添加</button>
    </form>

    <ul>
      <li v-for="todo in filteredTodos" :key="todo.id" class="todo-item">
        <input type="checkbox" v-model="todo.completed" />
        <span :class="{ completed: todo.completed }">{{ todo.title }}</span>
        <button @click="removeTodo(todo.id)">删除</button>
      </li>
    </ul>

    <div class="filters">
      <button @click="filter = 'all'" :class="{ active: filter === 'all' }">
        全部
      </button>
      <button @click="filter = 'active'" :class="{ active: filter === 'active' }">
        未完成
      </button>
      <button @click="filter = 'completed'" :class="{ active: filter === 'completed' }">
        已完成
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TodoList',
  data() {
    return {
      newTodo: '',
      todos: [],
      filter: 'all'
    }
  },
  computed: {
    filteredTodos() {
      switch (this.filter) {
        case 'active':
          return this.todos.filter(todo => !todo.completed)
        case 'completed':
          return this.todos.filter(todo => todo.completed)
        default:
          return this.todos
      }
    }
  },
  methods: {
    addTodo() {
      if (!this.newTodo.trim()) return

      this.todos.push({
        id: Date.now(),
        title: this.newTodo.trim(),
        completed: false
      })

      this.newTodo = ''
    },
    removeTodo(id) {
      const index = this.todos.findIndex(todo => todo.id === id)
      if (index > -1) {
        this.todos.splice(index, 1)
      }
    }
  },
  mounted() {
    // 从localStorage加载数据
    const saved = localStorage.getItem('todos')
    if (saved) {
      this.todos = JSON.parse(saved)
    }
  },
  watch: {
    todos: {
      handler() {
        // 保存到localStorage
        localStorage.setItem('todos', JSON.stringify(this.todos))
      },
      deep: true
    }
  }
}
</script>

<style scoped>
.todo-list {
  max-width: 500px;
  margin: 0 auto;
  padding: 2rem;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.5rem;
  border-bottom: 1px solid #eee;
}

.completed {
  text-decoration: line-through;
  color: #999;
}

.filters {
  margin-top: 1rem;
  display: flex;
  gap: 0.5rem;
}

.active {
  background-color: #007acc;
  color: white;
}
</style>
```

### 组合式函数 (Composables)
```javascript
// composables/useAuth.js
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { userStore } from '@/stores/user'

export function useAuth() {
  const router = useRouter()
  const isLoading = ref(false)
  const error = ref(null)

  const isAuthenticated = computed(() => userStore.isAuthenticated)
  const currentUser = computed(() => userStore.user)

  const login = async (credentials) => {
    isLoading.value = true
    error.value = null

    try {
      await userStore.login(credentials)
      await router.push('/dashboard')
    } catch (err) {
      error.value = err.message
    } finally {
      isLoading.value = false
    }
  }

  const logout = async () => {
    await userStore.logout()
    await router.push('/login')
  }

  return {
    isLoading,
    error,
    isAuthenticated,
    currentUser,
    login,
    logout
  }
}

// composables/useApi.js
import { ref } from 'vue'

export function useApi(baseURL = '/api') {
  const loading = ref(false)
  const error = ref(null)

  const request = async (endpoint, options = {}) => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(`${baseURL}${endpoint}`, {
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        },
        ...options
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      return await response.json()
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  const get = (endpoint, options = {}) =>
    request(endpoint, { ...options, method: 'GET' })

  const post = (endpoint, data, options = {}) =>
    request(endpoint, {
      ...options,
      method: 'POST',
      body: JSON.stringify(data)
    })

  return {
    loading,
    error,
    get,
    post,
    put: (endpoint, data, options = {}) =>
      request(endpoint, {
        ...options,
        method: 'PUT',
        body: JSON.stringify(data)
      }),
    delete: (endpoint, options = {}) =>
      request(endpoint, { ...options, method: 'DELETE' })
  }
}
```

### 组件设计模式
```vue
<!-- components/BaseCard.vue -->
<template>
  <div class="card" :class="variant">
    <div v-if="$slots.header" class="card-header">
      <slot name="header" />
    </div>

    <div class="card-body">
      <slot />
    </div>

    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'primary', 'secondary'].includes(value)
  }
})
</script>

<style scoped>
.card {
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
}

.card-header {
  padding: 1rem;
  background-color: #f8f9fa;
  border-bottom: 1px solid #ddd;
}

.card-body {
  padding: 1rem;
}

.card-footer {
  padding: 1rem;
  background-color: #f8f9fa;
  border-top: 1px solid #ddd;
}

/* 变体样式 */
.primary {
  border-color: #007acc;
}

.primary .card-header {
  background-color: #007acc;
  color: white;
}
</style>
```

## 🛠️ 依赖管理

### package.json 配置
```json
{
  "name": "vue-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build",
    "test:unit": "vue-cli-service test:unit",
    "test:e2e": "vue-cli-service test:e2e",
    "lint": "vue-cli-service lint",
    "type-check": "vue-tsc --noEmit"
  },
  "dependencies": {
    "vue": "^3.3.0",
    "@vueuse/core": "^10.0.0",
    "pinia": "^2.1.0",
    "vue-router": "^4.2.0",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    "@vue/cli-plugin-babel": "~5.0.0",
    "@vue/cli-plugin-eslint": "~5.0.0",
    "@vue/cli-plugin-router": "~5.0.0",
    "@vue/cli-plugin-typescript": "~13.0.0",
    "@vue/cli-plugin-unit-jest": "~5.0.0",
    "@vue/cli-service": "~5.0.0",
    "@vue/eslint-config-prettier": "^8.0.0",
    "@vue/eslint-config-typescript": "^12.0.0",
    "@vue/tsconfig": "^0.4.0",
    "@types/jest": "^29.5.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "eslint-plugin-vue": "^9.0.0",
    "typescript": "~5.2.0",
    "vue-tsc": "^1.8.0"
  }
}
```

### Vue CLI 配置
```javascript
// vue.config.js
module.exports = {
  // 开发服务器配置
  devServer: {
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  },

  // 构建配置
  configureWebpack: {
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src')
      }
    }
  },

  // CSS配置
  css: {
    loaderOptions: {
