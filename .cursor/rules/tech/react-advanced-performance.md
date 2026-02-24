---
description: "React 性能优化 - memo、useMemo、useCallback、虚拟化、代码分割"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 9
---

# React 性能优化 (Performance)

> 本规则由 `@react-advanced` 引用

## React.memo 和 useMemo

```jsx
const TodoItem = memo(({ todo, onToggle, onDelete }) => (
  <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
    <input type="checkbox" checked={todo.completed} onChange={() => onToggle(todo.id)} />
    <span>{todo.title}</span>
    <button onClick={() => onDelete(todo.id)}>删除</button>
  </div>
))

const TodoList = ({ todos, onToggle, onDelete }) => {
  const filteredTodos = useMemo(() => todos.filter(t => !t.completed), [todos])
  const handleToggle = useCallback((id) => onToggle(id), [onToggle])
  const handleDelete = useCallback((id) => onDelete(id), [onDelete])

  return (
    <ul>
      {filteredTodos.map(todo => (
        <TodoItem key={todo.id} todo={todo} onToggle={handleToggle} onDelete={handleDelete} />
      ))}
    </ul>
  )
}
```

## 虚拟化列表

```jsx
import { FixedSizeList as List } from 'react-window'

const VirtualizedTodoList = ({ todos, onToggle, onDelete }) => {
  const Row = ({ index, style }) => (
    <div style={style}>
      <TodoItem todo={todos[index]} onToggle={onToggle} onDelete={onDelete} />
    </div>
  )
  return (
    <List height={400} itemCount={todos.length} itemSize={50} width="100%">
      {Row}
    </List>
  )
}
```

## 代码分割和懒加载

```jsx
import { Suspense, lazy } from 'react'

const Home = lazy(() => import('./pages/Home'))
const About = lazy(() => import('./pages/About'))

function App() {
  return (
    <Suspense fallback={<div>加载中...</div>}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
      </Routes>
    </Suspense>
  )
}
```

## 状态管理优化 (Zustand 选择器)

```jsx
const useFilteredTodos = () => useStore(state => state.filteredTodos())
const useTodoActions = () => useStore(state => ({
  addTodo: state.addTodo,
  toggleTodo: state.toggleTodo
}), shallow)
```

## 原则

- **NEVER** 在 render 中创建新函数（用 useCallback）
- **MUST** 对列表项使用 memo
- **MUST** 对昂贵计算使用 useMemo

---

*引用: @react-advanced*
