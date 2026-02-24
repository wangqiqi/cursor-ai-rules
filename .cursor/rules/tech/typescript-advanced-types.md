---
description: "TypeScript 类型系统 - 类型测试、类型守卫、工具类型、模块声明"
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
priority: 9
---

# TypeScript 类型系统 (Type System)

> 本规则由 `@typescript-advanced` 引用，涵盖类型测试、类型优化与类型安全

## 执行原则

- **MUST** 充分利用 TypeScript 类型系统
- **NEVER** 使用 `any` 逃避类型检查
- **ALWAYS** 编写可重用的类型定义
- **DO NOT** 忽略编译器错误

## 类型测试

```typescript
// types.test.ts
import { expectTypeOf, expectAssignable, expectNotAssignable } from 'expect-type'

expectTypeOf<User>().toMatchTypeOf<{ id: string; email: string; name: string }>()
expectAssignable<StringOrNumber>('hello')
expectNotAssignable<StringOrNumber>(true)
expectTypeOf<Optional<User, 'avatar'>>().toMatchTypeOf<{ id: string; avatar?: string }>()
```

## 类型级别优化

```typescript
// const assertion
const CONFIG = { API_URL: 'https://api.example.com', TIMEOUT: 5000 } as const
type ConfigKeys = keyof typeof CONFIG  // "API_URL" | "TIMEOUT"

// 模板字面量类型
type Route = 'home' | 'about' | 'contact'
type RoutePath = `/${Route}`  // "/" | "/home" | "/about" | "/contact"

// 条件类型
type IsString<T> = T extends string ? true : false

// 递归类型
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P]
}
```

## 类型守卫

```typescript
function isUser(obj: unknown): obj is User {
  return obj && typeof (obj as any).id === 'string' && typeof (obj as any).email === 'string'
}
function processData(data: unknown) {
  if (isUser(data)) {
    console.log(data.name)  // 类型安全
  }
}
```

## 模块声明

```typescript
// types/env.d.ts
declare namespace NodeJS {
  interface ProcessEnv {
    API_URL: string
    DATABASE_URL: string
  }
}

// types/third-party.d.ts
declare module 'some-library' {
  export interface Config { apiKey: string; timeout: number }
  export function init(config: Config): void
}

// 模块增强
declare module 'express' {
  interface Request { user?: User; sessionId?: string }
}
```

---

*引用: @typescript-advanced*
