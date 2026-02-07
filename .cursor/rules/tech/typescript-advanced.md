---
description: "Typescript高级实践 - 测试、性能优化、安全实践和最佳实践"
apply_when:
  - keywords: ["typescript", "测试", "性能", "安全", "优化"]
priority: 9
---

# Typescript 高级实践

本文档是从 `typescript.md` 分割出来的高级主题部分，涵盖测试策略、性能优化、安全实践和最佳实践。

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