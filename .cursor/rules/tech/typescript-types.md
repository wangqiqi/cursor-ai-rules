---
description: "TypeScript高级类型系统 - 泛型、条件类型和类型推导"
apply_when:
  - keywords: ["typescript", "泛型", "类型", "泛型", "条件类型"]
priority: 9
---

# 🔷 TypeScript 高级类型系统

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
