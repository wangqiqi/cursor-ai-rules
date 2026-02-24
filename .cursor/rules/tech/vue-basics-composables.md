---
description: "Vue 组合式 API - Composition API、useAuth、useApi 等"
globs: ["**/*.vue"]
alwaysApply: false
priority: 10
---

# Vue 组合式 API (Composables)

> 本规则由 `@vue-basics` 引用

## Composition API 最佳实践

```vue
<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user'

const loading = ref(false)
const error = ref(null)
const userStore = useUserStore()
const { user, isAuthenticated } = storeToRefs(userStore)
const route = useRoute()
const userId = computed(() => route.params.id)

const form = ref({ name: '', email: '', bio: '' })

const validationRules = {
  name: (v: string) => v.length >= 2 || '姓名至少2个字符',
  email: (v: string) => validateEmail(v) || '邮箱格式不正确',
}

watch(() => user.value, (newUser) => {
  if (newUser) form.value = { name: newUser.name, email: newUser.email, bio: newUser.bio || '' }
}, { immediate: true })

const updateProfile = async () => {
  loading.value = true
  try {
    await userStore.updateProfile(userId.value, form.value)
  } catch (err) { error.value = err.message }
  finally { loading.value = false }
}

onMounted(() => { if (!isAuthenticated.value) { /* 重定向 */ } })
</script>
```

## 组合式函数 useAuth

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
    try {
      await userStore.login(credentials)
      await router.push('/dashboard')
    } catch (err) { error.value = err.message }
    finally { isLoading.value = false }
  }

  const logout = async () => {
    await userStore.logout()
    await router.push('/login')
  }

  return { isLoading, error, isAuthenticated, currentUser, login, logout }
}
```

## 组合式函数 useApi

```javascript
export function useApi(baseURL = '/api') {
  const loading = ref(false)
  const error = ref(null)

  const request = async (endpoint, options = {}) => {
    loading.value = true
    try {
      const res = await fetch(`${baseURL}${endpoint}`, {
        headers: { 'Content-Type': 'application/json', ...options.headers },
        ...options
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      return await res.json()
    } catch (err) { error.value = err.message; throw err }
    finally { loading.value = false }
  }

  return {
    loading, error,
    get: (ep, opts) => request(ep, { ...opts, method: 'GET' }),
    post: (ep, data, opts) => request(ep, { ...opts, method: 'POST', body: JSON.stringify(data) }),
  }
}
```

## 最佳实践

- **MUST** 使用 `storeToRefs` 解构 Pinia store 保持响应式
- **MUST** 在 `onUnmounted` 中清理订阅/定时器
- **DO NOT** 在 `setup` 顶层使用 `await`（用 `onMounted` 或立即执行）

---

*引用: @vue-basics*
