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

