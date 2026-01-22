---
command: javascript
description: "JavaScript开发规则 - 现代JavaScript最佳实践"
alwaysApply: false
---

# 📜 JavaScript 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- Node.js 后端开发
- 浏览器前端开发
- 服务端 JavaScript 应用
- 命令行工具和脚本
- 跨平台桌面应用
- 嵌入式 JavaScript 运行时

## 🏗️ 架构原则

### 模块化设计
- **ES6 模块**: 优先使用 `import/export`
- **CommonJS**: Node.js 环境下的模块系统
- **清晰的模块边界**: 每个模块职责单一
- **依赖注入**: 避免硬编码依赖关系

### 代码组织
- **关注点分离**: 业务逻辑、数据访问、表示层分离
- **单一职责**: 每个函数、类、模块只做一件事
- **开闭原则**: 对扩展开放，对修改关闭

## 📝 编码规范

### 命名约定
```javascript
// ✅ 推荐 - 变量和函数
const userName = 'john_doe'
const isUserActive = true
let currentUser = null

function getUserById(userId) {
  // 函数体
}

function calculateTotalPrice(items) {
  // 函数体
}

// ✅ 推荐 - 常量
const MAX_RETRY_COUNT = 3
const API_BASE_URL = 'https://api.example.com'
const DEFAULT_TIMEOUT = 5000

// ✅ 推荐 - 类和构造函数
class UserManager {
  constructor() {
    this.users = []
  }

  addUser(user) {
    this.users.push(user)
  }

  findUserById(id) {
    return this.users.find(user => user.id === id)
  }
}

// ❌ 避免 - 不一致的命名
const user_name = 'john'      // 使用 camelCase
const is_user_active = true   // 使用 camelCase
let CurrentUser = null        // 使用 camelCase
```

### 函数设计
- **单一职责**: 每个函数只做一件事
- **参数限制**: 最多3-4个参数，考虑使用对象参数
- **纯函数优先**: 无副作用的函数更容易测试和推理

```javascript
// ✅ 好的函数设计
function calculateUserScore(activities) {
  return activities
    .filter(activity => activity.completed)
    .reduce((score, activity) => score + activity.points, 0)
}

// ✅ 参数对象化
function createUser({ name, email, age, role = 'user' }) {
  return {
    id: generateId(),
    name,
    email,
    age,
    role,
    createdAt: new Date()
  }
}

// ❌ 避免的函数设计
function processUserData(user, options = {}) {
  // 参数太多且类型不明确
  if (options.validate) {
    // 验证逻辑
  }
  if (options.save) {
    // 保存逻辑
  }
  if (options.notify) {
    // 通知逻辑
  }
  // 做了太多事情
}
```

## 🔧 工具链配置

### ESLint 配置
```json
{
  "env": {
    "browser": true,
    "node": true,
    "es2021": true
  },
  "extends": [
    "eslint:recommended",
    "prettier"
  ],
  "rules": {
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "no-console": "warn",
    "prefer-const": "error",
    "no-var": "error"
  },
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  }
}
```

### Prettier 配置
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

## 🧪 测试策略

### 单元测试
- **测试框架**: Jest、Mocha 或 Jasmine
- **断言库**: 内置断言或 Chai
- **覆盖率**: 目标 80% 以上
- **测试文件**: 与被测文件同名，后缀 `.test.js` 或 `.spec.js`

### 集成测试
- **API 测试**: 使用 Supertest 测试 Express 路由
- **数据库测试**: 测试数据持久化逻辑
- **端到端测试**: Playwright 或 Cypress

```javascript
// 单元测试示例
const { calculateUserScore } = require('./userUtils')

describe('calculateUserScore', () => {
  it('should calculate score correctly', () => {
    const activities = [
      { id: '1', completed: true, points: 10 },
      { id: '2', completed: false, points: 5 },
      { id: '3', completed: true, points: 15 }
    ]

    const result = calculateUserScore(activities)
    expect(result).toBe(25)
  })

  it('should return 0 for empty activities', () => {
    const result = calculateUserScore([])
    expect(result).toBe(0)
  })

  it('should ignore incomplete activities', () => {
    const activities = [
      { id: '1', completed: false, points: 10 },
      { id: '2', completed: true, points: 5 }
    ]

    const result = calculateUserScore(activities)
    expect(result).toBe(5)
  })
})
```

### 测试组织
```javascript
// 测试文件结构
tests/
├── unit/
│   ├── userUtils.test.js
│   └── api.test.js
├── integration/
│   ├── database.test.js
│   └── api-routes.test.js
└── e2e/
    ├── user-journey.test.js
    └── admin-panel.test.js
```

## 🚀 性能优化

### 内存管理
- **避免内存泄漏**: 正确清理事件监听器、定时器和DOM引用
- **对象池**: 复用频繁创建的对象
- **垃圾回收优化**: 减少闭包和循环引用
- **大对象处理**: 使用流处理大文件，避免一次性加载到内存

### 运行时优化
- **算法优化**: 选择合适的数据结构和算法
- **缓存策略**: 合理使用内存缓存和持久化缓存
- **异步处理**: 使用Promise和async/await优化并发
- **事件循环**: 避免阻塞主线程的操作

## 🔒 安全考虑

### 输入验证
- **数据消毒**: 使用库如 `validator.js` 验证和清理输入
- **边界检查**: 验证数组索引和对象属性访问
- **类型检查**: 运行时类型验证和转换
- **SQL注入防护**: 使用参数化查询或ORM

### 敏感数据处理
- **环境变量**: 敏感信息存储在环境变量中
- **加密存储**: 密码等敏感数据必须加密
- **日志清理**: 避免在日志中记录敏感信息
- **HTTPS**: 始终使用HTTPS传输敏感数据

### 运行时安全
- **XSS防护**: 转义用户输入的内容
- **CSRF防护**: 实现CSRF token验证
- **内容安全策略**: 配置CSP头
- **依赖安全**: 定期更新依赖包，检查已知漏洞

## 📚 最佳实践

### 错误处理
```javascript
// ✅ 推荐的错误处理
class ApiError extends Error {
  constructor(statusCode, message) {
    super(message)
    this.name = 'ApiError'
    this.statusCode = statusCode
  }
}

async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/${userId}`)

    if (!response.ok) {
      throw new ApiError(response.status, 'Failed to fetch user data')
    }

    return await response.json()
  } catch (error) {
    if (error instanceof ApiError) {
      throw error
    }
    throw new ApiError(500, 'Internal server error')
  }
}

// ✅ 错误恢复策略
function withRetry(fn, maxRetries = 3, delay = 1000) {
  return async (...args) => {
    let lastError

    for (let i = 0; i <= maxRetries; i++) {
      try {
        return await fn(...args)
      } catch (error) {
        lastError = error

        if (i < maxRetries) {
          await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)))
        }
      }
    }

    throw lastError
  }
}
```

### 异步编程
- **Promise 最佳实践**: 避免 Promise 地狱，使用 Promise.all 和 Promise.race
- **Async/await**: 优先使用 async/await 语法
- **错误传播**: 正确传播异步错误
- **并发控制**: 限制并发请求数量

```javascript
// ✅ Promise 并发控制
class ConcurrencyLimiter {
  constructor(maxConcurrent) {
    this.maxConcurrent = maxConcurrent
    this.running = 0
    this.queue = []
  }

  async execute(fn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject })
      this.processQueue()
    })
  }

  async processQueue() {
    if (this.running >= this.maxConcurrent || this.queue.length === 0) {
      return
    }

    this.running++
    const { fn, resolve, reject } = this.queue.shift()

    try {
      const result = await fn()
      resolve(result)
    } catch (error) {
      reject(error)
    } finally {
      this.running--
      this.processQueue()
    }
  }
}
```

### 设计模式
- **工厂模式**: 创建对象时使用工厂函数
- **观察者模式**: 事件驱动的组件通信
- **策略模式**: 算法的动态切换
- **单例模式**: 全局状态管理
- **装饰器模式**: 功能增强而不修改原对象

## 🔄 现代化迁移

### 语言特性升级
1. **ES6+ 特性**: 使用箭头函数、模板字符串、解构赋值
2. **模块化**: 从 CommonJS 迁移到 ES6 模块
3. **异步编程**: 从回调地狱到 Promise/async-await

### 框架和工具升级
- **Node.js**: 采用最新的 LTS 版本
- **npm/yarn**: 迁移到 pnpm 或 Yarn 2+
- **构建工具**: 从 Webpack 迁移到 Vite/Rollup
- **测试框架**: 从 Mocha+Jasmine 迁移到 Jest/Vitest

## 📊 监控和度量

### 性能指标
- **响应时间**: API响应时间、页面加载时间
- **吞吐量**: 每秒处理请求数、并发用户数
- **资源使用**: 内存使用、CPU使用率、磁盘I/O
- **错误率**: 应用错误率、异常处理率

### 质量指标
- **测试覆盖率**: 单元测试和集成测试覆盖
- **代码复杂度**: 圈复杂度、函数长度、嵌套深度
- **技术债务**: 过时依赖、代码异味、安全漏洞
- **可维护性**: 代码重复率、注释覆盖率

### 日志和监控
- **结构化日志**: 使用一致的日志格式
- **错误追踪**: 收集和分析运行时错误
- **性能监控**: 应用性能监控(APM)
- **业务指标**: 关键业务指标跟踪

---

*此规则适用于现代 JavaScript 开发项目。遵循ES6+最佳实践，确保代码质量和性能。*