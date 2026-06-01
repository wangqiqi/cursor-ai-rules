---
description: "React 组件规范 - 项目结构、函数组件、类组件"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 10
---

# React 组件规范 (Components)

> 本规则由 `@react-basics` 引用

## 项目结构

### Create React App 布局
```
react_project/
├── src/
│   ├── components/     # 可复用组件 (Button/, Input/, Modal/)
│   ├── pages/         # 页面组件
│   ├── hooks/         # 自定义 Hooks
│   ├── contexts/      # React Context
│   └── utils/
```

### Next.js 结构
```
nextjs_project/
├── pages/             # Pages Router
│   ├── _app.js
│   └── api/           # API 路由
├── components/
└── lib/
```

### App Router (Next.js 13+)
```
nextjs_app_router/
├── app/
│   ├── layout.js
│   ├── page.js
│   └── api/
├── components/
└── lib/
```

## 函数组件 (推荐)

```jsx
const TodoItem = ({ todo, onToggle, onDelete }) => (
  <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
    <input type="checkbox" checked={todo.completed} onChange={() => onToggle(todo.id)} />
    <span>{todo.title}</span>
    <button onClick={() => onDelete(todo.id)}>删除</button>
  </div>
)

TodoItem.propTypes = {
  todo: PropTypes.shape({
    id: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    completed: PropTypes.bool.isRequired,
  }).isRequired,
  onToggle: PropTypes.func.isRequired,
  onDelete: PropTypes.func.isRequired,
}
```

## 类组件 (生命周期/复杂状态时)

```jsx
class TodoList extends Component {
  state = { todos: [], filter: 'all' }

  componentDidMount() {
    const saved = localStorage.getItem('todos')
    if (saved) this.setState({ todos: JSON.parse(saved) })
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevState.todos !== this.state.todos) {
      localStorage.setItem('todos', JSON.stringify(this.state.todos))
    }
  }

  handleAddTodo = (title) => {
    this.setState(prev => ({
      todos: [...prev.todos, { id: Date.now(), title, completed: false }]
    }))
  }

  render() {
    const filtered = this.getFilteredTodos()
    return (
      <div className="todo-list">
        <TodoForm onSubmit={this.handleAddTodo} />
        <ul>{filtered.map(todo => <TodoItem key={todo.id} todo={todo} ... />)}</ul>
      </div>
    )
  }
}
```

## 编码要点

- **MUST** 优先使用函数组件
- **MUST** 使用 PropTypes 或 TypeScript 定义 props
- **DO NOT** 在 render 中创建新函数（使用 useCallback 或类方法）

---

*引用: @react-basics*
