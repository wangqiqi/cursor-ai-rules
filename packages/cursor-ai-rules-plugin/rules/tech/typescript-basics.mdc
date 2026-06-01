---
description: "TypeScript开发规则 - 类型安全和高级类型系统最佳实践 (typescript, ts)"
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
priority: 10
---

# 🔷 TypeScript 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 大型JavaScript项目开发
- 需要类型安全的Web应用
- Node.js服务端开发
- 跨平台移动应用开发
- 桌面应用开发
- 库和框架开发
- 企业级应用开发

## 🏗️ 项目结构

### TypeScript项目布局
```
typescript_project/
├── src/
│   ├── index.ts                 # 应用入口
│   ├── types/                   # 类型定义
│   │   ├── index.ts            # 类型导出
│   │   ├── api.ts              # API类型
│   │   ├── models.ts           # 数据模型
│   │   └── common.ts           # 通用类型
│   ├── utils/                   # 工具函数
│   │   ├── index.ts
│   │   ├── validation.ts
│   │   ├── formatting.ts
│   │   └── async.ts
│   ├── services/                # 业务服务
│   │   ├── api.ts
│   │   ├── auth.ts
│   │   └── storage.ts
│   ├── components/              # UI组件 (如果适用)
│   └── lib/                     # 第三方库封装
├── tests/                       # 测试文件
│   ├── unit/
│   ├── integration/
│   └── types/                   # 类型测试
├── scripts/                     # 构建脚本
├── dist/                        # 编译输出
├── tsconfig.json               # TypeScript配置
├── package.json
├── .eslintrc.js
├── jest.config.js
└── README.md
```

### 类型定义组织
```typescript
// types/api.ts
export interface ApiResponse<T = any> {
  data: T
  message?: string
  success: boolean
  timestamp: number
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}

export interface User {
  id: string
  email: string
  name: string
  avatar?: string
  role: UserRole
  createdAt: Date
  updatedAt: Date
}

export interface CreateUserRequest {
  email: string
  name: string
  password: string
}

export interface UpdateUserRequest extends Partial<CreateUserRequest> {
  id: string
}

// types/common.ts
export type UserRole = 'admin' | 'user' | 'moderator'

export type Status = 'idle' | 'loading' | 'success' | 'error'

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'

export interface BaseEntity {
  id: string
  createdAt: Date
  updatedAt: Date
}

// 泛型工具类型
export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>

export type RequiredFields<T, K extends keyof T> = T & Required<Pick<T, K>>

export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}

export type NonNullable<T> = T extends null | undefined ? never : T
```

## 📝 编码规范

### 类型系统最佳实践
```typescript
// ✅ 推荐：明确的类型注解
interface UserService {
  getUser(id: string): Promise<User | null>
  createUser(user: CreateUserRequest): Promise<User>
  updateUser(id: string, updates: Partial<User>): Promise<User>
  deleteUser(id: string): Promise<void>
}

// ✅ 推荐：泛型约束和默认值
class ApiClient<TConfig = {}> {
  constructor(private config: TConfig & { baseURL: string }) {}

  async request<T = any>(
    method: HttpMethod,
    endpoint: string,
    data?: any
  ): Promise<ApiResponse<T>> {
    const url = `${this.config.baseURL}${endpoint}`

    // 类型守卫
    const isValidMethod = (method: string): method is HttpMethod => {
      return ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].includes(method)
    }

    if (!isValidMethod(method)) {
      throw new Error(`Invalid HTTP method: ${method}`)
    }

    // 实现请求逻辑...
    return {} as ApiResponse<T>
  }
}

// ✅ 推荐：联合类型和类型守卫
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E }

function isSuccess<T, E>(result: Result<T, E>): result is { success: true; data: T } {
  return result.success
}

function handleApiResult<T>(result: Result<T>) {
  if (isSuccess(result)) {
    console.log('Success:', result.data)
    return result.data
  } else {
    console.error('Error:', result.error)
    throw result.error
  }
}

// ✅ 推荐：条件类型和映射类型
type EventHandlers<T> = {
  [K in keyof T as `on${Capitalize<string & K>}Change`]?: (value: T[K]) => void
}

interface FormData {
  name: string
  email: string
  age: number
}

// 生成: { onNameChange?: (value: string) => void; onEmailChange?: (value: string) => void; onAgeChange?: (value: number) => void }
type FormEventHandlers = EventHandlers<FormData>

// ✅ 推荐：模板字面量类型
type HttpStatusCode = 200 | 201 | 400 | 401 | 404 | 500

type HttpStatusMessage<T extends HttpStatusCode> =
  T extends 200 ? 'OK' :
  T extends 201 ? 'Created' :
  T extends 400 ? 'Bad Request' :
  T extends 401 ? 'Unauthorized' :
  T extends 404 ? 'Not Found' :
  T extends 500 ? 'Internal Server Error' :
  never

function getStatusMessage<T extends HttpStatusCode>(code: T): HttpStatusMessage<T> {
  // TypeScript 会根据code的值推断返回类型
  switch (code) {
    case 200: return 'OK' as HttpStatusMessage<T>
    case 201: return 'Created' as HttpStatusMessage<T>
    case 400: return 'Bad Request' as HttpStatusMessage<T>
    case 401: return 'Unauthorized' as HttpStatusMessage<T>
    case 404: return 'Not Found' as HttpStatusMessage<T>
    case 500: return 'Internal Server Error' as HttpStatusMessage<T>
    default: throw new Error('Unknown status code')
  }
}

// ✅ 推荐：类和接口的高级用法
abstract class BaseService {
  protected readonly apiClient: ApiClient

  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient
  }

  protected async handleError(error: unknown): Promise<never> {
    if (error instanceof Error) {
      console.error(`Service error: ${error.message}`)
      throw error
    }
    throw new Error('Unknown error occurred')
  }
}

class UserService extends BaseService implements UserService {
  async getUser(id: string): Promise<User | null> {
    try {
      const response = await this.apiClient.request<User>('GET', `/users/${id}`)
      return response.success ? response.data : null
    } catch (error) {
      await this.handleError(error)
    }
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    try {
      const response = await this.apiClient.request<User>('POST', '/users', userData)

      if (!response.success) {
        throw new Error(response.message || 'Failed to create user')
      }

      return response.data
    } catch (error) {
      await this.handleError(error)
    }
  }

  async updateUser(id: string, updates: Partial<User>): Promise<User> {
    try {
      const response = await this.apiClient.request<User>('PUT', `/users/${id}`, updates)

      if (!response.success) {
        throw new Error(response.message || 'Failed to update user')
      }

      return response.data
    } catch (error) {
      await this.handleError(error)
    }
  }

  async deleteUser(id: string): Promise<void> {
    try {
      const response = await this.apiClient.request('DELETE', `/users/${id}`)

      if (!response.success) {
        throw new Error(response.message || 'Failed to delete user')
      }
    } catch (error) {
      await this.handleError(error)
    }
  }
}

// ✅ 推荐：装饰器模式
function logged(target: any, propertyName: string, descriptor: PropertyDescriptor) {
  const method = descriptor.value

  descriptor.value = async function (...args: any[]) {
    const start = Date.now()
    console.log(`Calling ${propertyName} with args:`, args)

    try {
      const result = await method.apply(this, args)
      const duration = Date.now() - start
      console.log(`${propertyName} completed in ${duration}ms`)
      return result
    } catch (error) {
      const duration = Date.now() - start
      console.error(`${propertyName} failed after ${duration}ms:`, error)
      throw error
    }
  }
}

class DataService extends BaseService {
  @logged
  async fetchData(endpoint: string): Promise<any> {
    return this.apiClient.request('GET', endpoint)
  }

  @logged
  async saveData(endpoint: string, data: any): Promise<any> {
    return this.apiClient.request('POST', endpoint, data)
  }
}
```

### 高级类型模式
```typescript
// ✅ 推荐：函数重载
function createElement(tag: 'input'): HTMLInputElement
function createElement(tag: 'div'): HTMLDivElement
function createElement(tag: 'button'): HTMLButtonElement
function createElement(tag: string): HTMLElement {
  return document.createElement(tag)
}

// 使用示例
const input = createElement('input')  // 类型: HTMLInputElement
const div = createElement('div')      // 类型: HTMLDivElement

// ✅ 推荐：Builder模式
class QueryBuilder<T> {
  private conditions: Array<(item: T) => boolean> = []

  where(condition: (item: T) => boolean): this {
    this.conditions.push(condition)
    return this
  }

  and(condition: (item: T) => boolean): this {
    return this.where(condition)
  }

  or(condition: (item: T) => boolean): this {
    // 实现OR逻辑
    const lastCondition = this.conditions.pop()
    if (lastCondition) {
      this.conditions.push((item: T) => lastCondition(item) || condition(item))
    } else {
      this.conditions.push(condition)
    }
    return this
  }

  execute(items: T[]): T[] {
    return items.filter(item =>
      this.conditions.every(condition => condition(item))
    )
  }
}

// 使用示例
interface Product {
  id: number
  name: string
  price: number
  category: string
}

const products: Product[] = [
  { id: 1, name: 'Laptop', price: 1000, category: 'Electronics' },
  { id: 2, name: 'Book', price: 20, category: 'Books' },
  { id: 3, name: 'Phone', price: 500, category: 'Electronics' }
]

const results = new QueryBuilder<Product>()
  .where(p => p.category === 'Electronics')
  .and(p => p.price > 100)
  .execute(products)
// 结果: [{ id: 1, name: 'Laptop', ... }, { id: 3, name: 'Phone', ... }]

// ✅ 推荐：Mixin模式
type Constructor<T = {}> = new (...args: any[]) => T

function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    timestamp = Date.now()

    getTimestamp() {
      return this.timestamp
    }
  }
}

function Serializable<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
