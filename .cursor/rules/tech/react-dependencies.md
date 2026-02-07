---
description: "React依赖管理和测试 - 包管理、依赖优化和测试策略"
apply_when:
  - file_pattern: "**/package.json"
  - file_pattern: "**/jest.config.js"
  - file_pattern: "**/*.test.jsx"
  - file_pattern: "**/*.test.tsx"
  - keywords: ["npm", "yarn", "测试", "test", "依赖"]
priority: 9
---

# 📦 React 依赖管理和测试

## ⚠️ 执行原则

**MUST** 遵循以下React依赖管理准则：
- **MUST** 定期更新依赖以获取安全修复
- **NEVER** 使用未经审查的第三方包
- **ALWAYS** 锁定依赖版本
- **DO NOT** 忽略已知的安全漏洞
- **MUST** 编写全面的测试
- **ALWAYS** 监控包大小和性能

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

