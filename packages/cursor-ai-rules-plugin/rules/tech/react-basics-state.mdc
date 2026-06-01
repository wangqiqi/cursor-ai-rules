---
description: "React 状态管理 - Context API、useReducer、AuthContext 模式"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 10
---

# React 状态管理 (State)

> 本规则由 `@react-basics` 引用

## Context API + useReducer

```jsx
const AuthContext = createContext()

const authReducer = (state, action) => {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, loading: true, error: null }
    case 'LOGIN_SUCCESS':
      return { ...state, loading: false, user: action.payload, isAuthenticated: true }
    case 'LOGIN_FAILURE':
      return { ...state, loading: false, error: action.payload, isAuthenticated: false }
    case 'LOGOUT':
      return { user: null, isAuthenticated: false, loading: false, error: null }
    default:
      return state
  }
}

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState)

  const login = async (credentials) => {
    dispatch({ type: 'LOGIN_START' })
    try {
      const user = await fetch('/api/auth/login', { ... }).then(r => r.json())
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

  return (
    <AuthContext.Provider value={{ ...state, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}
```

## 使用示例

```jsx
function App() {
  return (
    <AuthProvider>
      <Dashboard />
    </AuthProvider>
  )
}

function Dashboard() {
  const { user, isAuthenticated, login, logout, loading } = useAuth()
  if (!isAuthenticated) return <LoginForm onLogin={login} loading={loading} />
  return <div><h1>欢迎, {user.name}</h1><button onClick={logout}>登出</button></div>
}
```

## 状态管理选择

| 场景 | 推荐方案 |
|------|----------|
| 局部 UI 状态 | useState |
| 跨组件共享 | Context + useReducer |
| 服务端状态 | TanStack Query / SWR |
| 复杂全局状态 | Zustand / Redux |

---

*引用: @react-basics*
