---
command: typescript
description: "TypeScript开发规则 - 类型安全和高级类型系统最佳实践"
alwaysApply: false
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
    serialize() {
      return JSON.stringify(this)
    }

    static deserialize<T extends Constructor>(this: T, data: string): InstanceType<T> {
      return Object.assign(new this(), JSON.parse(data))
    }
  }
}

// 组合多个Mixin
class User {
  constructor(public name: string, public email: string) {}
}

const TimestampedUser = Timestamped(User)
const SerializableTimestampedUser = Serializable(TimestampedUser)

const user = new SerializableTimestampedUser('John', 'john@example.com')
console.log(user.getTimestamp())  // 数字时间戳
console.log(user.serialize())     // JSON字符串

// ✅ 推荐：类型安全的配置构建器
interface DatabaseConfig {
  host: string
  port: number
  database: string
  username: string
  password: string
  ssl: boolean
  maxConnections: number
}

class DatabaseConfigBuilder {
  private config: Partial<DatabaseConfig> = {}

  host(host: string): this {
    this.config.host = host
    return this
  }

  port(port: number): this {
    this.config.port = port
    return this
  }

  database(database: string): this {
    this.config.database = database
    return this
  }

  credentials(username: string, password: string): this {
    this.config.username = username
    this.config.password = password
    return this
  }

  ssl(enabled: boolean = true): this {
    this.config.ssl = enabled
    return this
  }

  maxConnections(count: number): this {
    this.config.maxConnections = count
    return this
  }

  build(): DatabaseConfig {
    // 类型守卫确保所有必需字段都已设置
    const requiredFields: (keyof DatabaseConfig)[] = ['host', 'port', 'database', 'username', 'password']

    for (const field of requiredFields) {
      if (!(field in this.config)) {
        throw new Error(`Missing required field: ${field}`)
      }
    }

    return {
      ssl: false,
      maxConnections: 10,
      ...this.config
    } as DatabaseConfig
  }
}

// 使用示例
const config = new DatabaseConfigBuilder()
  .host('localhost')
  .port(5432)
  .database('myapp')
  .credentials('user', 'password')
  .ssl(true)
  .maxConnections(20)
  .build()
```

### 异步编程和错误处理
```typescript
// ✅ 推荐：类型安全的异步函数
async function fetchUserData(userId: string): Promise<Result<User, Error>> {
  try {
    const response = await fetch(`/api/users/${userId}`)

    if (!response.ok) {
      if (response.status === 404) {
        return { success: false, error: new Error('User not found') }
      }
      return { success: false, error: new Error(`HTTP ${response.status}`) }
    }

    const userData = await response.json()
    const user: User = {
      id: userData.id,
      email: userData.email,
      name: userData.name,
      role: userData.role as UserRole,
      createdAt: new Date(userData.createdAt),
      updatedAt: new Date(userData.updatedAt)
    }

    return { success: true, data: user }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

// ✅ 推荐：泛型异步工具
class AsyncQueue<T> {
  private queue: Array<(resolve: (value: T) => void, reject: (error: any) => void) => void> = []
  private processing = false

  async enqueue<R>(operation: () => Promise<R>): Promise<R> {
    return new Promise<R>((resolve, reject) => {
      this.queue.push(async (resolveOp, rejectOp) => {
        try {
          const result = await operation()
          resolveOp(result as unknown as T)
          resolve(result)
        } catch (error) {
          rejectOp(error)
          reject(error)
        }
      })

      this.processQueue()
    })
  }

  private async processQueue(): Promise<void> {
    if (this.processing || this.queue.length === 0) {
      return
    }

    this.processing = true

    while (this.queue.length > 0) {
      const operation = this.queue.shift()!
      await new Promise<void>((resolve, reject) => {
        operation(resolve, reject)
      })
    }

    this.processing = false
  }
}

// ✅ 推荐：类型安全的Promise工具
type PromiseResult<T> = PromiseFulfilledResult<T> | PromiseRejectedResult

function allSettled<T extends readonly unknown[] | []>(
  promises: T
): Promise<{ -readonly [P in keyof T]: PromiseResult<Awaited<T[P]>> }> {
  return Promise.allSettled(promises) as any
}

async function handleMultipleRequests<T>(
  requests: Array<() => Promise<T>>
): Promise<{ successes: T[]; failures: Error[] }> {
  const results = await allSettled(requests.map(req => req()))

  const successes: T[] = []
  const failures: Error[] = []

  results.forEach(result => {
    if (result.status === 'fulfilled') {
      successes.push(result.value)
    } else {
      failures.push(result.reason instanceof Error ? result.reason : new Error(String(result.reason)))
    }
  })

  return { successes, failures }
}

// ✅ 推荐：资源管理器模式
class ResourceManager<T> {
  private resources = new Map<string, T>()
  private cleanupCallbacks = new Map<string, () => void>()

  register(id: string, resource: T, cleanup?: () => void): void {
    this.resources.set(id, resource)
    if (cleanup) {
      this.cleanupCallbacks.set(id, cleanup)
    }
  }

  get<K extends T>(id: string): K | undefined {
    return this.resources.get(id) as K | undefined
  }

  has(id: string): boolean {
    return this.resources.has(id)
  }

  remove(id: string): boolean {
    const existed = this.resources.delete(id)
    const cleanup = this.cleanupCallbacks.get(id)
    if (cleanup) {
      cleanup()
      this.cleanupCallbacks.delete(id)
    }
    return existed
  }

  clear(): void {
    // 按注册相反顺序清理
    const ids = Array.from(this.cleanupCallbacks.keys()).reverse()
    ids.forEach(id => this.remove(id))
  }
}

// 使用示例
const dbManager = new ResourceManager<DatabaseConnection>()

// 注册数据库连接
dbManager.register('main', connection, () => connection.close())

// 类型安全的获取
const conn = dbManager.get<DatabaseConnection>('main')
```

## 🛠️ 依赖管理

### tsconfig.json 配置
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/components/*": ["src/components/*"],
      "@/utils/*": ["src/utils/*"],
      "@/types/*": ["src/types/*"]
    },
    "typeRoots": ["./node_modules/@types", "./src/types"],
    "types": ["node", "jest"],
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": false,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  },
  "include": [
    "src/**/*",
    "tests/**/*",
    "scripts/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "**/*.spec.ts",
    "**/*.test.ts"
  ],
  "ts-node": {
    "esm": true,
    "experimentalSpecifierResolution": "node"
  }
}
```

### 类型声明文件
```typescript
// types/globals.d.ts
declare global {
  interface Window {
    __REDUX_DEVTOOLS_EXTENSION__?: any
    gtag?: (...args: any[]) => void
  }

  interface ProcessEnv {
    NODE_ENV: 'development' | 'production' | 'test'
    API_URL: string
    DATABASE_URL: string
  }

  namespace NodeJS {
    interface ProcessEnv extends ProcessEnv {}
  }
}

export {}

// types/third-party.d.ts
declare module 'some-library' {
  export interface Config {
    apiKey: string
    timeout: number
  }

  export function init(config: Config): void
  export function request(endpoint: string): Promise<any>
}

// types/module-augmentation.d.ts
import 'express'

declare module 'express' {
  interface Request {
    user?: User
    sessionId?: string
  }

  interface Response {
    sendSuccess<T>(data: T, message?: string): void
    sendError(error: Error | string, statusCode?: number): void
  }
}
```

## 🧪 测试策略

### 类型测试
```typescript
// types.test.ts
import { expectTypeOf, expectAssignable, expectNotAssignable } from 'expect-type'

// 接口测试
expectTypeOf<User>().toMatchTypeOf<{
  id: string
  email: string
  name: string
  role: UserRole
  createdAt: Date
  updatedAt: Date
}>()

// 联合类型测试
type StringOrNumber = string | number
expectAssignable<StringOrNumber>('hello')
expectAssignable<StringOrNumber>(42)
expectNotAssignable<StringOrNumber>(true)

// 泛型测试
expectTypeOf<Optional<User, 'avatar'>>().toMatchTypeOf<{
  id: string
  email: string
  name: string
  role: UserRole
  createdAt: Date
  updatedAt: Date
  avatar?: string
}>()

// 函数类型测试
type Predicate<T> = (value: T) => boolean
expectTypeOf<Predicate<number>>().toEqualTypeOf<(value: number) => boolean>()

// 工具类型测试
expectTypeOf<DeepPartial<User>>().toMatchTypeOf<{
  id?: string
  email?: string
  name?: string
  role?: UserRole
  createdAt?: Date
  updatedAt?: Date
  avatar?: string
}>()
```

### 集成测试类型安全
```typescript
// tests/api.integration.test.ts
import { expectTypeOf } from 'expect-type'
import { apiClient } from '../src/services/api'

describe('API Client Integration', () => {
  it('should return typed user data', async () => {
    const response = await apiClient.getUser('123')

    // 编译时类型检查
    expectTypeOf(response).toMatchTypeOf<ApiResponse<User>>()

    if (response.success) {
      expectTypeOf(response.data).toMatchTypeOf<User>()
      expect(typeof response.data.id).toBe('string')
      expect(typeof response.data.email).toBe('string')
    }
  })

  it('should handle paginated responses', async () => {
    const response = await apiClient.getUsers({ page: 1, limit: 10 })

    expectTypeOf(response).toMatchTypeOf<PaginatedResponse<User>>()

    if (response.success) {
      expect(Array.isArray(response.data)).toBe(true)
      expectTypeOf(response.pagination).toMatchTypeOf<{
        page: number
        limit: number
        total: number
        totalPages: number
      }>()
    }
  })
})

// 类型安全的mock
interface MockApiClient {
  getUser: (id: string) => Promise<ApiResponse<User>>
  getUsers: (params: { page: number; limit: number }) => Promise<PaginatedResponse<User>>
}

const createMockApiClient = (): MockApiClient => ({
  getUser: async (id: string) => ({
    success: true,
    data: {
      id,
      email: 'test@example.com',
      name: 'Test User',
      role: 'user',
      createdAt: new Date(),
      updatedAt: new Date()
    },
    timestamp: Date.now()
  }),

  getUsers: async (params) => ({
    success: true,
    data: [],
    pagination: {
      page: params.page,
      limit: params.limit,
      total: 0,
      totalPages: 0
    },
    timestamp: Date.now()
  })
})
```

## 🚀 性能优化

### 类型级别的优化
```typescript
// ✅ 推荐：const assertion 优化
const CONFIG = {
  API_URL: 'https://api.example.com',
  TIMEOUT: 5000,
  RETRIES: 3
} as const

// 类型被推断为字面量类型而不是string
type ConfigKeys = keyof typeof CONFIG
// "API_URL" | "TIMEOUT" | "RETRIES"

// ✅ 推荐：模板字面量类型优化
type Route = 'home' | 'about' | 'contact'
type RoutePath = `/${Route}`

// 类型: "/" | "/home" | "/about" | "/contact"

// ✅ 推荐：条件类型优化编译时计算
type IsString<T> = T extends string ? true : false

type Result1 = IsString<'hello'>    // true
type Result2 = IsString<42>        // false

// ✅ 推荐：递归类型处理大数据结构
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P]
}

interface MutableUser {
  name: string
  profile: {
    age: number
    settings: {
      theme: string
    }
  }
}

type ReadonlyUser = DeepReadonly<MutableUser>
// 所有嵌套属性都是readonly

// ✅ 推荐：类型安全的缓存
class TypeSafeCache<K extends string, V> {
  private cache = new Map<K, { value: V; timestamp: number }>()

  set(key: K, value: V): void {
    this.cache.set(key, { value, timestamp: Date.now() })
  }

  get(key: K): V | undefined {
    const entry = this.cache.get(key)
    return entry?.value
  }

  has(key: K): boolean {
    return this.cache.has(key)
  }

  clear(): void {
    this.cache.clear()
  }
}

// 使用示例
const userCache = new TypeSafeCache<'user' | 'admin', User>()
userCache.set('user', userData)  // 类型安全
const cachedUser = userCache.get('user')  // 类型推断为User | undefined
```

### 编译时优化
```typescript
// ✅ 推荐：常量折叠和死代码消除
const DEBUG = false

function log(message: string) {
  if (DEBUG) {
    console.log(message)
  }
}

// 在生产构建中，DEBUG为false，整个if块会被移除

// ✅ 推荐：枚举优化
enum HttpStatus {
  OK = 200,
  Created = 201,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
  InternalServerError = 500
}

// 编译为数字常量，比字符串更高效

// ✅ 推荐：类型守卫优化运行时检查
function isUser(obj: any): obj is User {
  return obj &&
         typeof obj.id === 'string' &&
         typeof obj.email === 'string' &&
         typeof obj.name === 'string'
}

function processData(data: unknown) {
  if (isUser(data)) {
    // TypeScript知道这里data是User类型
    console.log(data.name)  // 类型安全，无需额外检查
  }
}

// ✅ 推荐：泛型特化优化
interface Processor<T> {
  process(input: T): T
}

class StringProcessor implements Processor<string> {
  process(input: string): string {
    return input.toUpperCase()
  }
}

class NumberProcessor implements Processor<number> {
  process(input: number): number {
    return input * 2
  }
}

// 编译时类型检查，运行时无额外开销
```

## 🔒 安全实践

### 类型安全的输入验证
```typescript
// ✅ 推荐：类型安全的验证器
interface Validator<T> {
  validate(value: unknown): value is T
  sanitize(value: unknown): T | null
}

class EmailValidator implements Validator<string> {
  private readonly emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

  validate(value: unknown): value is string {
    return typeof value === 'string' && this.emailRegex.test(value)
  }

  sanitize(value: unknown): string | null {
    if (typeof value !== 'string') return null

    const trimmed = value.trim().toLowerCase()
    return this.validate(trimmed) ? trimmed : null
  }
}

class PasswordValidator implements Validator<string> {
  private readonly minLength = 8
  private readonly requireUppercase = true
  private readonly requireLowercase = true
  private readonly requireNumbers = true

  validate(value: unknown): value is string {
    if (typeof value !== 'string') return false

    const password = value
    if (password.length < this.minLength) return false

    if (this.requireUppercase && !/[A-Z]/.test(password)) return false
    if (this.requireLowercase && !/[a-z]/.test(password)) return false
    if (this.requireNumbers && !/\d/.test(password)) return false

    return true
  }

  sanitize(value: unknown): string | null {
    return typeof value === 'string' ? value : null
  }
}

// 表单验证器组合
class FormValidator<T extends Record<string, unknown>> {
  private validators = new Map<keyof T, Validator<any>>()

  addField<K extends keyof T>(field: K, validator: Validator<T[K]>): this {
    this.validators.set(field, validator)
    return this
  }

  validate(data: unknown): data is T {
    if (typeof data !== 'object' || data === null) return false

    for (const [field, validator] of this.validators) {
      const value = (data as any)[field]
      if (!validator.validate(value)) {
        return false
      }
    }

    return true
  }

  sanitize(data: unknown): Partial<T> | null {
    if (typeof data !== 'object' || data === null) return null

    const sanitized: Partial<T> = {}

    for (const [field, validator] of this.validators) {
      const value = (data as any)[field]
      const sanitizedValue = validator.sanitize(value)

      if (sanitizedValue !== null) {
        sanitized[field] = sanitizedValue
      }
    }

    return sanitized
  }
}

// 使用示例
const userValidator = new FormValidator<User>()
  .addField('email', new EmailValidator())
  .addField('name', {
    validate: (value: unknown): value is string => typeof value === 'string' && value.length >= 2,
    sanitize: (value: unknown): string | null => typeof value === 'string' ? value.trim() : null
  })

function createUser(userData: unknown) {
  if (!userValidator.validate(userData)) {
    throw new Error('Invalid user data')
  }

  // TypeScript 知道 userData 是 User 类型
  return userData
}
```

### 类型安全的数据库操作
```typescript
// ✅ 推荐：类型安全的ORM
interface DatabaseModel<T> {
  tableName: string
  create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T>
  findById(id: string): Promise<T | null>
  findAll(): Promise<T[]>
  update(id: string, data: Partial<T>): Promise<T>
  delete(id: string): Promise<boolean>
}

class TypeSafeRepository<T extends { id: string }> implements DatabaseModel<T> {
  constructor(
    public tableName: string,
    private db: DatabaseConnection
  ) {}

  async create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T> {
    const now = new Date()
    const record = {
      ...data,
      id: this.generateId(),
      createdAt: now,
      updatedAt: now
    } as T

    await this.db.insert(this.tableName, record)
    return record
  }

  async findById(id: string): Promise<T | null> {
    const result = await this.db.query(
      `SELECT * FROM ${this.tableName} WHERE id = $1`,
      [id]
    )
    return result.rows[0] || null
  }

  async findAll(): Promise<T[]> {
    const result = await this.db.query(`SELECT * FROM ${this.tableName}`)
    return result.rows
  }

  async update(id: string, data: Partial<T>): Promise<T> {
    const updates = { ...data, updatedAt: new Date() }
    const setClause = Object.keys(updates)
      .map((key, index) => `${key} = $${index + 2}`)
      .join(', ')

    const values = [...Object.values(updates), id]

    const result = await this.db.query(
      `UPDATE ${this.tableName} SET ${setClause} WHERE id = $1 RETURNING *`,
      values
    )

    if (result.rows.length === 0) {
      throw new Error('Record not found')
    }

    return result.rows[0]
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      `DELETE FROM ${this.tableName} WHERE id = $1`,
      [id]
    )
    return result.rowCount > 0
  }

  private generateId(): string {
    return Math.random().toString(36).substr(2, 9)
  }
}

// 类型安全的查询构建器
class QueryBuilder<T> {
  private conditions: Array<(item: T) => boolean> = []

  where(condition: (item: T) => boolean): this {
    this.conditions.push(condition)
    return this
  }

  and(condition: (item: T) => boolean): this {
    this.conditions.push(condition)
    return this
  }

  or(condition: (item: T) => boolean): this {
    const lastCondition = this.conditions.pop()
    if (lastCondition) {
      this.conditions.push((item: T) =>
        lastCondition(item) || condition(item)
      )
    }
    return this
  }

  orderBy<K extends keyof T>(key: K, desc = false): this {
    // 实现排序逻辑
    return this
  }

  limit(count: number): this {
    // 实现限制逻辑
    return this
  }

  offset(count: number): this {
    // 实现偏移逻辑
    return this
  }

  async execute(): Promise<T[]> {
    // 实际的数据库查询实现
    return []
  }
}

// 使用示例
interface UserFilter {
  name?: string
  email?: string
  role?: UserRole
  createdAfter?: Date
}

const userRepo = new TypeSafeRepository<User>('users', dbConnection)

// 类型安全的查询
const users = await new QueryBuilder<User>()
  .where(user => user.role === 'admin')
  .and(user => user.createdAt > new Date('2023-01-01'))
  .orderBy('createdAt', true)
  .limit(10)
  .execute()
```

## 📊 最佳实践

### 项目组织最佳实践
```
src/
├── types/           # 全局类型定义
│   ├── api.ts      # API相关类型
│   ├── models.ts   # 数据模型
│   ├── common.ts   # 通用类型和工具类型
│   └── index.ts    # 类型导出
├── utils/           # 工具函数
│   ├── validation.ts
│   ├── formatting.ts
│   ├── async.ts
│   └── index.ts
├── services/        # 业务服务
│   ├── api.ts
│   ├── auth.ts
│   └── index.ts
├── components/      # UI组件 (如果适用)
├── hooks/           # 自定义Hooks (如果适用)
├── constants/       # 常量定义
└── index.ts         # 主入口
```

### 类型定义管理
```typescript
// types/index.ts - 集中导出所有类型
export * from './api'
export * from './models'
export * from './common'

// types/models.ts - 数据模型
export interface BaseEntity {
  id: string
  createdAt: Date
  updatedAt: Date
}

export interface User extends BaseEntity {
  email: string
  name: string
  role: UserRole
  avatar?: string
}

// types/api.ts - API相关
export interface ApiResponse<T = any> {
  data: T
  success: boolean
  message?: string
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

// types/common.ts - 通用类型
export type UserRole = 'admin' | 'user' | 'moderator'

export type Status = 'idle' | 'loading' | 'success' | 'error'

export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>

export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}
```

### 命名约定
```typescript
// 文件名：kebab-case 或 camelCase
user-service.ts
userService.ts
string-utils.ts

// 类型名：PascalCase
interface UserProfile {}
type UserRole = 'admin' | 'user'
class UserService {}

// 变量名：camelCase
const userName: string
let isLoading: boolean

// 函数名：camelCase
function getUserById(id: string) {}
const createUser = (user: User) => {}

// 常量：SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3
const API_BASE_URL = '/api'

// 泛型参数：PascalCase，通常单个大写字母
function identity<T>(value: T): T
interface Repository<T, K> {}

// 私有成员：下划线前缀
class UserService {
  private _cache: Map<string, User>
  private _config: ServiceConfig
}
```

---

*此规则适用于现代TypeScript开发项目。充分利用类型系统提高代码质量和开发效率。*