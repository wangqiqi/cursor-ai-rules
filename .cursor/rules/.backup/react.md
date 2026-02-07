---
description: "React开发规则 - 组件化前端框架最佳实践"
apply_when:
  - file_pattern: "**/*.jsx"
  - file_pattern: "**/*.tsx"
  - keywords: ["react", "jsx"]
priority: 10
---

# ⚛️ React 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 现代Web应用开发
- 单页应用(SPA)和多页应用(MPA)
- 移动端应用(React Native)
- 桌面应用(React + Electron)
- 服务端渲染(Next.js SSR)
- 静态站点生成(Next.js SSG)
- 组件库和设计系统开发

## 🏗️ 项目结构

### Create React App 项目布局
```
react_project/
├── public/                    # 静态资源
│   ├── index.html
│   ├── favicon.ico
│   ├── manifest.json
│   └── robots.txt
├── src/                       # 源代码
│   ├── index.js              # 应用入口
│   ├── App.js                # 根组件
│   ├── components/           # 可复用组件
│   │   ├── Button/
│   │   │   ├── Button.js
│   │   │   ├── Button.test.js
│   │   │   └── index.js
│   │   ├── Input/
│   │   └── Modal/
│   ├── pages/                # 页面组件
│   │   ├── Home/
│   │   ├── About/
│   │   └── Contact/
│   ├── hooks/                # 自定义Hooks
│   │   ├── useAuth.js
│   │   ├── useApi.js
│   │   └── useLocalStorage.js
│   ├── contexts/             # React Context
│   │   ├── AuthContext.js
│   │   └── ThemeContext.js
│   ├── utils/                # 工具函数
│   │   ├── api.js
│   │   ├── constants.js
│   │   └── helpers.js
│   ├── styles/               # 样式文件
│   │   ├── global.css
│   │   ├── variables.css
│   │   └── components/
│   ├── assets/               # 静态资源
│   │   ├── images/
│   │   └── icons/
│   └── App.test.js           # 根组件测试
├── build/                    # 构建输出
├── node_modules/
├── package.json
├── .env.local               # 本地环境变量
├── .env.development
├── .env.production
└── README.md
```

### Next.js 项目结构
```
nextjs_project/
├── pages/                    # 页面路由 (Pages Router)
│   ├── _app.js              # 应用包装器
│   ├── _document.js         # 文档结构
│   ├── index.js             # 首页
│   ├── about.js
│   └── api/                 # API路由
│       └── users.js
├── components/              # 组件
├── lib/                     # 工具库
├── styles/                  # 样式
├── public/                  # 静态资源
└── package.json
```

### App Router 项目结构 (Next.js 13+)
```
nextjs_app_router/
├── app/                     # App Router
│   ├── layout.js           # 根布局
│   ├── page.js             # 首页
│   ├── about/
│   │   └── page.js
│   ├── api/
│   │   └── users/
│   │       └── route.js
│   └── globals.css
├── components/
├── lib/
├── utils/
└── package.json
```

## 📝 编码规范

### React Hooks 最佳实践
```jsx
import React, { useState, useEffect, useCallback, useMemo, useContext } from 'react'
import { useQuery, useMutation } from '@tanstack/react-query'
import { useAuth } from '@/hooks/useAuth'
import { AuthContext } from '@/contexts/AuthContext'

// 自定义Hook：数据获取
function useUserProfile(userId) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(res => res.json()),
    enabled: !!userId,
    staleTime: 5 * 60 * 1000, // 5分钟
  })
}

// 自定义Hook：表单管理
function useForm(initialValues, validate) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState({})
  const [touched, setTouched] = useState({})

  const handleChange = useCallback((name, value) => {
    setValues(prev => ({ ...prev, [name]: value }))

    // 清除错误
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: undefined }))
    }
  }, [errors])

  const handleBlur = useCallback((name) => {
    setTouched(prev => ({ ...prev, [name]: true }))

    // 验证字段
    const fieldErrors = validate({ [name]: values[name] })
    if (fieldErrors[name]) {
      setErrors(prev => ({ ...prev, [name]: fieldErrors[name] }))
    }
  }, [validate, values])

  const handleSubmit = useCallback((onSubmit) => (e) => {
    e.preventDefault()

    const validationErrors = validate(values)
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors)
      setTouched(Object.keys(values).reduce((acc, key) => ({
        ...acc, [key]: true
      }), {}))
      return
    }

    onSubmit(values)
  }, [validate, values])

  const reset = useCallback(() => {
    setValues(initialValues)
    setErrors({})
    setTouched({})
  }, [initialValues])

  return {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    handleSubmit,
    reset,
    isValid: Object.keys(errors).length === 0
  }
}

// 主组件
function UserProfile({ userId }) {
  const { user, isAuthenticated } = useContext(AuthContext)
  const { data: profile, isLoading, error } = useUserProfile(userId)

  const validationRules = {
    name: (value) => value?.length >= 2 ? null : '姓名至少2个字符',
    email: (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) ? null : '邮箱格式不正确',
  }

  const {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    handleSubmit,
    isValid
  } = useForm({
    name: profile?.name || '',
    email: profile?.email || ''
  }, validationRules)

  const updateProfile = useMutation({
    mutationFn: (data) => fetch(`/api/users/${userId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }).then(res => res.json())
  })

  const onSubmit = async (formData) => {
    try {
      await updateProfile.mutateAsync(formData)
      // 成功提示
    } catch (err) {
      console.error('更新失败:', err)
    }
  }

  if (!isAuthenticated) {
    return <div>请先登录</div>
  }

  if (isLoading) {
    return <div>加载中...</div>
  }

  if (error) {
    return <div>加载失败: {error.message}</div>
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="name">姓名</label>
        <input
          id="name"
          type="text"
          value={values.name}
          onChange={(e) => handleChange('name', e.target.value)}
          onBlur={() => handleBlur('name')}
        />
        {touched.name && errors.name && (
          <span className="error">{errors.name}</span>
        )}
      </div>

      <div>
        <label htmlFor="email">邮箱</label>
        <input
          id="email"
          type="email"
          value={values.email}
          onChange={(e) => handleChange('email', e.target.value)}
          onBlur={() => handleBlur('email')}
        />
        {touched.email && errors.email && (
          <span className="error">{errors.email}</span>
        )}
      </div>

      <button type="submit" disabled={!isValid || updateProfile.isLoading}>
        {updateProfile.isLoading ? '更新中...' : '更新资料'}
      </button>
    </form>
  )
}

export default UserProfile
```

### 函数组件和类组件
```jsx
import React, { Component } from 'react'
import PropTypes from 'prop-types'

// 函数组件 (推荐)
const TodoItem = ({ todo, onToggle, onDelete }) => {
  return (
    <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={() => onToggle(todo.id)}
      />
      <span>{todo.title}</span>
      <button onClick={() => onDelete(todo.id)}>删除</button>
    </div>
  )
}

TodoItem.propTypes = {
  todo: PropTypes.shape({
    id: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    completed: PropTypes.bool.isRequired,
  }).isRequired,
  onToggle: PropTypes.func.isRequired,
  onDelete: PropTypes.func.isRequired,
}

// 类组件 (当需要生命周期或复杂状态管理时)
class TodoList extends Component {
  constructor(props) {
    super(props)
    this.state = {
      todos: [],
      filter: 'all'
    }
  }

  componentDidMount() {
    // 从localStorage加载数据
    const savedTodos = localStorage.getItem('todos')
    if (savedTodos) {
      this.setState({ todos: JSON.parse(savedTodos) })
    }
  }

  componentDidUpdate(prevProps, prevState) {
    // 保存到localStorage
    if (prevState.todos !== this.state.todos) {
      localStorage.setItem('todos', JSON.stringify(this.state.todos))
    }
  }

  handleAddTodo = (title) => {
    const newTodo = {
      id: Date.now(),
      title,
      completed: false
    }

    this.setState(prevState => ({
      todos: [...prevState.todos, newTodo]
    }))
  }

  handleToggleTodo = (id) => {
    this.setState(prevState => ({
      todos: prevState.todos.map(todo =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    }))
  }

  handleDeleteTodo = (id) => {
    this.setState(prevState => ({
      todos: prevState.todos.filter(todo => todo.id !== id)
    }))
  }

  getFilteredTodos = () => {
    const { todos, filter } = this.state

    switch (filter) {
      case 'active':
        return todos.filter(todo => !todo.completed)
      case 'completed':
        return todos.filter(todo => todo.completed)
      default:
        return todos
    }
  }

  render() {
    const { filter } = this.state
    const filteredTodos = this.getFilteredTodos()

    return (
      <div className="todo-list">
        <h1>待办事项</h1>

        <TodoForm onSubmit={this.handleAddTodo} />

        <div className="filters">
          {['all', 'active', 'completed'].map(filterType => (
            <button
              key={filterType}
              className={filter === filterType ? 'active' : ''}
              onClick={() => this.setState({ filter: filterType })}
            >
              {filterType === 'all' ? '全部' :
               filterType === 'active' ? '未完成' : '已完成'}
            </button>
          ))}
        </div>

        <ul>
          {filteredTodos.map(todo => (
            <TodoItem
              key={todo.id}
              todo={todo}
              onToggle={this.handleToggleTodo}
              onDelete={this.handleDeleteTodo}
            />
          ))}
        </ul>
      </div>
    )
  }
}

export { TodoItem, TodoList }
```

### 自定义Hooks设计模式
```javascript
// hooks/useLocalStorage.js
import { useState, useEffect } from 'react'

function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.warn(`Error reading localStorage key "${key}":`, error)
      return initialValue
    }
  })

  const setValue = (value) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value
      setStoredValue(valueToStore)
      window.localStorage.setItem(key, JSON.stringify(valueToStore))
    } catch (error) {
      console.warn(`Error setting localStorage key "${key}":`, error)
    }
  }

  return [storedValue, setValue]
}

// hooks/useDebounce.js
import { useState, useEffect } from 'react'

function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])

  return debouncedValue
}

// hooks/useAsync.js
import { useState, useEffect, useCallback } from 'react'

function useAsync(asyncFunction, immediate = true) {
  const [status, setStatus] = useState('idle')
  const [value, setValue] = useState(null)
  const [error, setError] = useState(null)

  const execute = useCallback(() => {
    setStatus('pending')
    setValue(null)
    setError(null)

    return asyncFunction()
      .then(response => {
        setValue(response)
        setStatus('success')
        return response
      })
      .catch(error => {
        setError(error)
        setStatus('error')
        throw error
      })
  }, [asyncFunction])

  useEffect(() => {
    if (immediate) {
      execute()
    }
  }, [execute, immediate])

  return { execute, status, value, error }
}

// hooks/useIntersectionObserver.js
import { useEffect, useRef, useState } from 'react'

function useIntersectionObserver(options = {}) {
  const [isIntersecting, setIsIntersecting] = useState(false)
  const [entry, setEntry] = useState(null)
  const ref = useRef()

  useEffect(() => {
    const element = ref.current
    if (!element) return

    const observer = new IntersectionObserver(
      ([entry]) => {
        setIsIntersecting(entry.isIntersecting)
        setEntry(entry)
      },
      options
    )

    observer.observe(element)

    return () => {
      observer.unobserve(element)
    }
  }, [options])

  return [ref, isIntersecting, entry]
}
```

### Context API 和状态管理
```jsx
// contexts/AuthContext.js
import React, { createContext, useContext, useReducer, useEffect } from 'react'

const AuthContext = createContext()

const authReducer = (state, action) => {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, loading: true, error: null }
    case 'LOGIN_SUCCESS':
      return {
        ...state,
        loading: false,
        user: action.payload,
        isAuthenticated: true
      }
    case 'LOGIN_FAILURE':
      return {
        ...state,
        loading: false,
        error: action.payload,
        isAuthenticated: false
      }
    case 'LOGOUT':
      return {
        user: null,
        isAuthenticated: false,
        loading: false,
        error: null
      }
    default:
      return state
  }
}

const initialState = {
  user: null,
  isAuthenticated: false,
  loading: false,
  error: null
}

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState)

  useEffect(() => {
    // 检查本地存储中的认证信息
    const token = localStorage.getItem('authToken')
    if (token) {
      // 验证token并设置用户状态
      validateToken(token)
    }
  }, [])

  const login = async (credentials) => {
    dispatch({ type: 'LOGIN_START' })

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials)
      })

      if (!response.ok) {
        throw new Error('登录失败')
      }

      const user = await response.json()
      localStorage.setItem('authToken', user.token)

      dispatch({ type: 'LOGIN_SUCCESS', payload: user })
    } catch (error) {
      dispatch({ type: 'LOGIN_FAILURE', payload: error.message })
    }
  }

  const logout = () => {
    localStorage.removeItem('authToken')
    dispatch({ type: 'LOGOUT' })
  }

  const validateToken = async (token) => {
    try {
      const response = await fetch('/api/auth/validate', {
        headers: { Authorization: `Bearer ${token}` }
      })

      if (response.ok) {
        const user = await response.json()
        dispatch({ type: 'LOGIN_SUCCESS', payload: user })
      } else {
        logout()
      }
    } catch (error) {
      logout()
    }
  }

  return (
    <AuthContext.Provider value={{
      ...state,
      login,
      logout
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

// 使用示例
function App() {
  return (
    <AuthProvider>
      <Dashboard />
    </AuthProvider>
  )
}

function Dashboard() {
  const { user, isAuthenticated, login, logout, loading } = useAuth()

  if (!isAuthenticated) {
    return <LoginForm onLogin={login} loading={loading} />
  }

  return (
    <div>
      <h1>欢迎, {user.name}</h1>
      <button onClick={logout}>登出</button>
    </div>
  )
}
```

## 🛠️ 依赖管理

### package.json 配置
```json
{
  "name": "react-app",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "@tanstack/react-query": "^4.24.0",
    "axios": "^1.3.0",
    "zustand": "^4.3.0",
    "styled-components": "^5.3.0",
    "react-hook-form": "^7.43.0",
    "react-hot-toast": "^2.4.0"
  },
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.0",
    "@testing-library/user-event": "^14.4.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@vitejs/plugin-react": "^3.1.0",
    "vite": "^4.1.0",
    "eslint": "^8.35.0",
    "eslint-plugin-react": "^7.32.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "prettier": "^2.8.0",
    "husky": "^8.0.0",
    "lint-staged": "^13.1.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "lint": "eslint src --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write src/**/*.{js,jsx,ts,tsx,json,css,md}",
    "prepare": "husky install"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

### Vite 配置
```javascript
// vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': '/src',
      '@components': '/src/components',
      '@hooks': '/src/hooks',
      '@utils': '/src/utils',
      '@styles': '/src/styles'
    }
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          ui: ['styled-components']
        }
      }
    }
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.js']
  }
})
```

## 🧪 测试策略

### React Testing Library 测试
```jsx
import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { BrowserRouter } from 'react-router-dom'
import TodoApp from './TodoApp'
import { server } from '../mocks/server'

// 建立测试环境
const createTestQueryClient = () => new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
      cacheTime: 0
    },
    mutations: {
      retry: false
    }
  }
})

const TestWrapper = ({ children }) => (
  <QueryClientProvider client={createTestQueryClient()}>
    <BrowserRouter>
      {children}
    </BrowserRouter>
  </QueryClientProvider>
)

// 单元测试
describe('TodoApp', () => {
  beforeAll(() => server.listen())
  afterEach(() => server.resetHandlers())
  afterAll(() => server.close())

  test('renders todo app correctly', () => {
    render(
      <TestWrapper>
        <TodoApp />
      </TestWrapper>
    )

    expect(screen.getByText('待办事项')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('添加新任务')).toBeInTheDocument()
  })

  test('adds a new todo', async () => {
    render(
      <TestWrapper>
        <TodoApp />
      </TestWrapper>
    )

    const input = screen.getByPlaceholderText('添加新任务')
    const button = screen.getByRole('button', { name: /添加/i })

    await userEvent.type(input, '学习React')
    await userEvent.click(button)

    await waitFor(() => {
      expect(screen.getByText('学习React')).toBeInTheDocument()
    })
  })

  test('toggles todo completion', async () => {
    render(
      <TestWrapper>
        <TodoApp />
      </TestWrapper>
    )

    // 添加任务
    const input = screen.getByPlaceholderText('添加新任务')
    await userEvent.type(input, '测试任务')
    await userEvent.click(screen.getByRole('button', { name: /添加/i }))

    // 找到复选框并点击
    const checkbox = screen.getByRole('checkbox')
    await userEvent.click(checkbox)

    // 验证任务被标记为完成
    const todoItem = screen.getByText('测试任务')
    expect(todoItem).toHaveClass('completed')
  })

  test('filters todos correctly', async () => {
    render(
      <TestWrapper>
        <TodoApp />
      </TestWrapper>
    )

    // 添加两个任务
    const input = screen.getByPlaceholderText('添加新任务')
    await userEvent.type(input, '任务1')
    await userEvent.click(screen.getByRole('button', { name: /添加/i }))

    await userEvent.clear(input)
    await userEvent.type(input, '任务2')
    await userEvent.click(screen.getByRole('button', { name: /添加/i }))

    // 完成第一个任务
    const checkboxes = screen.getAllByRole('checkbox')
    await userEvent.click(checkboxes[0])

    // 点击"未完成"过滤器
    await userEvent.click(screen.getByRole('button', { name: '未完成' }))

    // 应该只显示一个任务（未完成的）
    await waitFor(() => {
      const todoItems = screen.getAllByText(/任务/)
      expect(todoItems).toHaveLength(1)
      expect(screen.getByText('任务2')).toBeInTheDocument()
    })
  })
})

// Hook测试
import { renderHook, act } from '@testing-library/react'
import { useCounter } from '../hooks/useCounter'

describe('useCounter', () => {
  test('should increment counter', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })

  test('should decrement counter', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
      result.current.increment()
      result.current.decrement()
    })

    expect(result.current.count).toBe(1)
  })
})

// 自定义渲染器
import { render } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false }
    }
  })

  return ({ children }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )
}

const customRender = (ui, options = {}) =>
  render(ui, { wrapper: createWrapper(), ...options })

export * from '@testing-library/react'
export { customRender as render }
```

### Cypress 端到端测试
```javascript
// cypress/integration/todo.spec.js
describe('Todo App E2E', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('should load the app', () => {
    cy.contains('待办事项').should('be.visible')
  })

  it('should add a new todo', () => {
    cy.get('[data-cy="todo-input"]').type('学习Cypress{enter}')
    cy.contains('学习Cypress').should('be.visible')
  })

  it('should complete a todo', () => {
    // 添加任务
    cy.get('[data-cy="todo-input"]').type('测试任务{enter}')

    // 完成任务
    cy.get('[data-cy="todo-item"]').first().find('input[type="checkbox"]').check()

    // 验证样式变化
    cy.get('[data-cy="todo-item"]').first().should('have.class', 'completed')
  })

  it('should persist todos after page reload', () => {
    // 添加任务
    cy.get('[data-cy="todo-input"]').type('持久化测试{enter}')
    cy.contains('持久化测试').should('be.visible')

    // 刷新页面
    cy.reload()

    // 验证任务仍然存在
    cy.contains('持久化测试').should('be.visible')
  })
})
```

## 🚀 性能优化

### React.memo 和 useMemo 优化
```jsx
import React, { memo, useMemo, useCallback } from 'react'

// 组件记忆化
const TodoItem = memo(({ todo, onToggle, onDelete }) => {
  console.log('TodoItem render:', todo.id)

  return (
    <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={() => onToggle(todo.id)}
      />
      <span>{todo.title}</span>
      <button onClick={() => onDelete(todo.id)}>删除</button>
    </div>
  )
})

// 自定义比较函数
const areEqual = (prevProps, nextProps) => {
  return (
    prevProps.todo.id === nextProps.todo.id &&
    prevProps.todo.completed === nextProps.todo.completed &&
    prevProps.todo.title === nextProps.todo.title
  )
}

const OptimizedTodoItem = memo(TodoItem, areEqual)

// 列表组件优化
const TodoList = ({ todos, onToggle, onDelete }) => {
  // 记忆化过滤逻辑
  const filteredTodos = useMemo(() => {
    return todos.filter(todo => !todo.completed)
  }, [todos])

  // 记忆化事件处理器
  const handleToggle = useCallback((id) => {
    onToggle(id)
  }, [onToggle])

  const handleDelete = useCallback((id) => {
    onDelete(id)
  }, [onDelete])

  return (
    <ul>
      {filteredTodos.map(todo => (
        <OptimizedTodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}
          onDelete={handleDelete}
        />
      ))}
    </ul>
  )
}

// 虚拟化列表
import { FixedSizeList as List } from 'react-window'

const VirtualizedTodoList = ({ todos, onToggle, onDelete }) => {
  const Row = ({ index, style }) => {
    const todo = todos[index]
    return (
      <div style={style}>
        <TodoItem
          todo={todo}
          onToggle={onToggle}
          onDelete={onDelete}
        />
      </div>
    )
  }

  return (
    <List
      height={400}
      itemCount={todos.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </List>
  )
}
```

### 代码分割和懒加载
```jsx
import React, { Suspense, lazy } from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'

// 懒加载组件
const Home = lazy(() => import('./pages/Home'))
const About = lazy(() => import('./pages/About'))
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Admin = lazy(() => import('./pages/Admin'))

// 加载组件
const LoadingSpinner = () => <div>加载中...</div>
const ErrorBoundary = ({ children }) => {
  // 错误边界实现
  return children
}

// 主应用组件
function App() {
  return (
    <ErrorBoundary>
      <Router>
        <Suspense fallback={<LoadingSpinner />}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/about" element={<About />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/admin" element={<Admin />} />
          </Routes>
        </Suspense>
      </Router>
    </ErrorBoundary>
  )
}

// 基于路由的代码分割
import loadable from '@loadable/component'

const AsyncHome = loadable(() => import('./pages/Home'), {
  fallback: <LoadingSpinner />
})

const AsyncDashboard = loadable(() => import('./pages/Dashboard'), {
  fallback: <LoadingSpinner />
})
```

### 状态管理优化
```jsx
// Zustand store 优化
import create from 'zustand'
import { subscribeWithSelector } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

const useStore = create(
  subscribeWithSelector(
    immer((set, get) => ({
      todos: [],
      filter: 'all',

      // 计算属性
      filteredTodos: () => {
        const { todos, filter } = get()
        switch (filter) {
          case 'active':
            return todos.filter(todo => !todo.completed)
          case 'completed':
            return todos.filter(todo => todo.completed)
          default:
            return todos
        }
      },

      // 动作
      addTodo: (title) =>
        set(state => {
          state.todos.push({
            id: Date.now(),
            title,
            completed: false
          })
        }),

      toggleTodo: (id) =>
        set(state => {
          const todo = state.todos.find(t => t.id === id)
          if (todo) {
            todo.completed = !todo.completed
          }
        }),

      setFilter: (filter) => set({ filter }),

      // 异步动作
      loadTodos: async () => {
        const response = await fetch('/api/todos')
        const todos = await response.json()
        set({ todos })
      }
    }))
  )
)

// 选择器优化
const useFilteredTodos = () =>
  useStore(state => state.filteredTodos())

const useTodoActions = () =>
  useStore(state => ({
    addTodo: state.addTodo,
    toggleTodo: state.toggleTodo
  }), shallow)

// 使用示例
function TodoApp() {
  const filteredTodos = useFilteredTodos()
  const { addTodo, toggleTodo } = useTodoActions()
  const filter = useStore(state => state.filter)
  const setFilter = useStore(state => state.setFilter)

  // 只在filter变化时重新渲染
  return (
    <div>
      <FilterButtons filter={filter} onFilterChange={setFilter} />
      <TodoList todos={filteredTodos} onToggle={toggleTodo} />
      <AddTodoForm onAdd={addTodo} />
    </div>
  )
}
```

## 🔒 安全实践

### 输入验证和清理
```jsx
import React, { useState } from 'react'
import DOMPurify from 'dompurify'

// 输入验证Hook
function useFormValidation(initialValues, validationRules) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState({})
  const [touched, setTouched] = useState({})

  const validateField = (name, value) => {
    const rules = validationRules[name]
    if (!rules) return null

    for (const rule of rules) {
      const error = rule(value)
      if (error) return error
    }
    return null
  }

  const handleChange = (name, value) => {
    setValues(prev => ({ ...prev, [name]: value }))

    // 实时验证
    const error = validateField(name, value)
    setErrors(prev => ({ ...prev, [name]: error }))
  }

  const handleBlur = (name) => {
    setTouched(prev => ({ ...prev, [name]: true }))
  }

  const isValid = Object.values(errors).every(error => !error)

  return {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    isValid
  }
}

// 安全组件
function SafeHtml({ html, className }) {
  const sanitizedHtml = React.useMemo(() => {
    return DOMPurify.sanitize(html, {
      ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
      ALLOWED_ATTR: ['href', 'target', 'rel']
    })
  }, [html])

  return (
    <div
      className={className}
      dangerouslySetInnerHTML={{ __html: sanitizedHtml }}
    />
  )
}

// 表单组件
function ContactForm() {
  const validationRules = {
    name: [
      (value) => !value ? '姓名不能为空' : null,
      (value) => value.length < 2 ? '姓名至少2个字符' : null,
      (value) => /[<>&"']/.test(value) ? '姓名包含无效字符' : null
    ],
    email: [
      (value) => !value ? '邮箱不能为空' : null,
      (value) => !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) ? '邮箱格式不正确' : null
    ],
    message: [
      (value) => !value ? '消息不能为空' : null,
      (value) => value.length > 1000 ? '消息不能超过1000个字符' : null
    ]
  }

  const { values, errors, touched, handleChange, handleBlur, isValid } =
    useFormValidation({
      name: '',
      email: '',
      message: ''
    }, validationRules)

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!isValid) return

    // 发送数据到安全的API端点
    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          name: values.name.trim(),
          email: values.email.trim(),
          message: values.message.trim()
        })
      })

      if (response.ok) {
        // 成功处理
        console.log('消息发送成功')
      } else {
        console.error('发送失败')
      }
    } catch (error) {
      console.error('网络错误:', error)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="name">姓名</label>
        <input
          id="name"
          type="text"
          value={values.name}
          onChange={(e) => handleChange('name', e.target.value)}
          onBlur={() => handleBlur('name')}
        />
        {touched.name && errors.name && (
          <span className="error">{errors.name}</span>
        )}
      </div>

      <div>
        <label htmlFor="email">邮箱</label>
        <input
          id="email"
          type="email"
          value={values.email}
          onChange={(e) => handleChange('email', e.target.value)}
          onBlur={() => handleBlur('email')}
        />
        {touched.email && errors.email && (
          <span className="error">{errors.email}</span>
        )}
      </div>

      <div>
        <label htmlFor="message">消息</label>
        <textarea
          id="message"
          value={values.message}
          onChange={(e) => handleChange('message', e.target.value)}
          onBlur={() => handleBlur('message')}
          rows={5}
        />
        {touched.message && errors.message && (
          <span className="error">{errors.message}</span>
        )}
      </div>

      <button type="submit" disabled={!isValid}>
        发送消息
      </button>
    </form>
  )
}
```

## 📊 最佳实践

### 文件和组件组织
```
src/
├── components/
│   ├── ui/           # 基础UI组件
│   │   ├── Button/
│   │   │   ├── Button.jsx
│   │   │   ├── Button.test.jsx
│   │   │   └── index.js
│   │   └── Input/
│   ├── forms/        # 表单组件
│   ├── layout/       # 布局组件
│   └── common/       # 通用组件
├── pages/           # 页面组件
├── hooks/           # 自定义Hooks
├── contexts/        # React Context
├── utils/           # 工具函数
├── constants/       # 常量定义
├── services/        # API服务
├── styles/          # 样式文件
└── types/           # TypeScript类型
```

### 命名约定
```jsx
// 组件文件：PascalCase
UserProfile.jsx
TodoList.jsx
LoginForm.jsx

// Hook文件：camelCase
useAuth.js
useLocalStorage.js
useApi.js

// 工具文件：camelCase
apiClient.js
dateUtils.js
stringHelpers.js

// 测试文件：与被测文件同名 + .test
UserProfile.test.jsx
useAuth.test.js

// 组件名：与文件名一致
const UserProfile = () => { ... }

// Props接口：PascalCase + Props
interface UserProfileProps {
  userId: string
  showAvatar?: boolean
}

// 事件处理器：handle + PascalCase
const handleSubmit = () => { ... }
const handleInputChange = () => { ... }

// 自定义Hook：use + PascalCase
const useUserProfile = () => { ... }
```

### 组件设计模式
```jsx
// 高阶组件 (HOC)
function withLoading(Component) {
  return function WrappedComponent({ loading, ...props }) {
    if (loading) {
      return <div>加载中...</div>
    }
    return <Component {...props} />
  }
}

// Render Props模式
class DataProvider extends React.Component {
  state = { data: null, loading: true, error: null }

  componentDidMount() {
    this.fetchData()
  }

  async fetchData() {
    try {
      const data = await fetch(this.props.url)
      this.setState({ data, loading: false })
    } catch (error) {
      this.setState({ error, loading: false })
    }
  }

  render() {
    return this.props.children(this.state)
  }
}

// 使用render props
function UserList() {
  return (
    <DataProvider url="/api/users">
      {({ data, loading, error }) => {
        if (loading) return <div>加载中...</div>
        if (error) return <div>错误: {error.message}</div>
        return (
          <ul>
            {data.map(user => (
              <li key={user.id}>{user.name}</li>
            ))}
          </ul>
        )
      }}
    </DataProvider>
  )
}

// Compound Components模式
const Tabs = ({ children }) => {
  const [activeTab, setActiveTab] = React.useState(0)

  return React.Children.map(children, (child, index) =>
    React.cloneElement(child, {
      isActive: index === activeTab,
      onClick: () => setActiveTab(index)
    })
  )
}

const Tab = ({ isActive, onClick, children }) => (
  <button
    className={isActive ? 'active' : ''}
    onClick={onClick}
  >
    {children}
  </button>
)

// 使用compound components
function App() {
  return (
    <Tabs>
      <Tab>首页</Tab>
      <Tab>设置</Tab>
      <Tab>关于</Tab>
    </Tabs>
  )
}
```

---

*此规则适用于现代React开发项目。优先使用函数组件和Hooks，注重组件化和状态管理。*