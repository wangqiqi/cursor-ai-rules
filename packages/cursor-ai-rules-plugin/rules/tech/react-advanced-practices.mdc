---
description: "React 最佳实践 - 文件组织、命名约定、组件设计模式"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 9
---

# React 最佳实践 (Best Practices)

> 本规则由 `@react-advanced` 引用

## 文件组织

```
src/
├── components/
│   ├── ui/           # 基础 UI 组件
│   ├── forms/        # 表单组件
│   ├── layout/       # 布局组件
│   └── common/       # 通用组件
├── pages/
├── hooks/
├── contexts/
├── utils/
├── services/
└── types/
```

## 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 组件文件 | PascalCase | UserProfile.jsx |
| Hook 文件 | camelCase | useAuth.js |
| 事件处理器 | handle + PascalCase | handleSubmit |
| 自定义 Hook | use + PascalCase | useUserProfile |

## 组件设计模式

### 高阶组件 (HOC)
```jsx
function withLoading(Component) {
  return function WrappedComponent({ loading, ...props }) {
    if (loading) return <div>加载中...</div>
    return <Component {...props} />
  }
}
```

### Render Props
```jsx
<DataProvider url="/api/users">
  {({ data, loading, error }) => {
    if (loading) return <div>加载中...</div>
    if (error) return <div>错误</div>
    return <ul>{data.map(u => <li key={u.id}>{u.name}</li>)}</ul>
  }}
</DataProvider>
```

### Compound Components
```jsx
const Tabs = ({ children }) => {
  const [activeTab, setActiveTab] = useState(0)
  return React.Children.map(children, (child, i) =>
    React.cloneElement(child, { isActive: i === activeTab, onClick: () => setActiveTab(i) })
  )
}
```

## 原则

- **MUST** 优化组件渲染性能
- **DO NOT** 忽略可访问性 (a11y)
- **ALWAYS** 测试组件行为

---

*引用: @react-advanced*
