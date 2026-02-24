---
description: "TypeScript 高级实践 - 性能优化、安全实践、最佳实践"
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
priority: 9
---

# TypeScript 高级实践 (Advanced Practices)

> 本规则由 `@typescript-advanced` 引用，涵盖性能、安全与项目组织

## 性能优化

### 编译时优化

```typescript
const DEBUG = false
function log(message: string) {
  if (DEBUG) { console.log(message) }  // 生产构建时会被移除
}

enum HttpStatus { OK = 200, Created = 201, BadRequest = 400 }
// 编译为数字常量，比字符串更高效
```

### 类型安全缓存

```typescript
class TypeSafeCache<K extends string, V> {
  private cache = new Map<K, { value: V; timestamp: number }>()
  set(key: K, value: V): void { this.cache.set(key, { value, timestamp: Date.now() }) }
  get(key: K): V | undefined { return this.cache.get(key)?.value }
}
```

## 安全实践

### 类型安全验证器

```typescript
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
    return typeof value === 'string' && this.validate(value) ? value.trim() : null
  }
}
```

### 类型安全 ORM

```typescript
interface DatabaseModel<T> {
  create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T>
  findById(id: string): Promise<T | null>
  update(id: string, data: Partial<T>): Promise<T>
}
```

## 最佳实践

### 项目组织

```
src/
├── types/           # 全局类型
│   ├── api.ts
│   ├── models.ts
│   └── index.ts
├── utils/
├── services/
└── constants/
```

### 命名约定

- 类型/接口: `PascalCase`
- 变量/函数: `camelCase`
- 常量: `SCREAMING_SNAKE_CASE`
- 泛型: 单字母 `T`, `K`, `V`

### 类型集中导出

```typescript
// types/index.ts
export * from './api'
export * from './models'
export * from './common'
```

---

*引用: @typescript-advanced*
