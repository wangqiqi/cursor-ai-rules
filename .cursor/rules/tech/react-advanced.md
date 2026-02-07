---
description: "React高级实践 - 性能优化、安全实践和最佳实践"
apply_when:
  - keywords: ["性能优化", "security", "best practices", "优化", "安全"]
priority: 9
---

# ⚛️ React 高级实践

本文档是从 `react.md` 分割出来的高级主题部分，涵盖性能优化、安全实践和最佳实践。

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

