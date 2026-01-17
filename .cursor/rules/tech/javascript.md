---
command: javascript
description: "JavaScript/TypeScript开发规则 - 现代前端开发最佳实践"
alwaysApply: false
---

# 📜 JavaScript/TypeScript 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-15 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 适用场景

- Node.js 后端开发
- React/Vue/Angular 前端框架
- TypeScript 项目
- 现代 JavaScript 开发

## 🏗️ 架构原则

### 模块化设计
- **ES6 模块**: 优先使用 `import/export`
- **清晰的模块边界**: 每个模块职责单一
- **依赖注入**: 避免硬编码依赖关系

### 类型安全 (TypeScript)
- **严格模式**: 启用所有严格类型检查
- **接口定义**: 为所有数据结构定义接口
- **泛型使用**: 在适当的地方使用泛型提高复用性

## 📝 编码规范

### 命名约定
```typescript
// ✅ 推荐
interface UserProfile {
  readonly id: string;
  displayName: string;
  emailAddress: string;
  isActive: boolean;
  createdAt: Date;
}

// ❌ 避免
interface user_profile {
  readonly ID: string;
  display_name: string;
  email_address: string;
  is_active: boolean;
  created_at: Date;
}
```

### 函数设计
- **单一职责**: 每个函数只做一件事
- **参数限制**: 最多3-4个参数，考虑使用对象参数
- **纯函数优先**: 无副作用的函数更容易测试和推理

```typescript
// ✅ 好的函数设计
function calculateUserScore(activities: UserActivity[]): number {
  return activities
    .filter(activity => activity.completed)
    .reduce((score, activity) => score + activity.points, 0);
}

// ❌ 避免的函数设计
function processUserData(user: any, options: any = {}): any {
  // 做了太多事情，参数类型不明确
}
```

## 🔧 工具链配置

### ESLint 配置
```json
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "warn"
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
  "tabWidth": 2
}
```

## 🧪 测试策略

### 单元测试
- **测试框架**: Jest 或 Vitest
- **断言库**: 内置断言或 Chai
- **覆盖率**: 目标 80% 以上

### 集成测试
- **API 测试**: 使用 Supertest 测试 Express 路由
- **组件测试**: React Testing Library
- **端到端测试**: Playwright 或 Cypress

```typescript
// 单元测试示例
describe('calculateUserScore', () => {
  it('should calculate score correctly', () => {
    const activities: UserActivity[] = [
      { id: '1', completed: true, points: 10 },
      { id: '2', completed: false, points: 5 },
      { id: '3', completed: true, points: 15 }
    ];

    const result = calculateUserScore(activities);
    expect(result).toBe(25);
  });
});
```

## 🚀 性能优化

### 代码分割
- **动态导入**: 使用 `import()` 实现代码分割
- **路由级分割**: 按页面分割代码
- **组件级分割**: 大组件的懒加载

### 内存管理
- **避免内存泄漏**: 正确清理事件监听器和定时器
- **对象池**: 复用频繁创建的对象
- **垃圾回收优化**: 减少闭包和循环引用

## 🔒 安全考虑

### 输入验证
- **数据消毒**: 使用库如 `validator.js` 验证输入
- **类型检查**: 利用 TypeScript 的类型系统
- **边界检查**: 验证数组索引和对象属性访问

### 敏感数据处理
- **环境变量**: 敏感信息存储在环境变量中
- **加密存储**: 密码等敏感数据必须加密
- **日志清理**: 避免在日志中记录敏感信息

## 📚 最佳实践

### 错误处理
```typescript
// ✅ 推荐的错误处理
class ApiError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function fetchUserData(userId: string): Promise<UserData> {
  try {
    const response = await fetch(`/api/users/${userId}`);

    if (!response.ok) {
      throw new ApiError(response.status, 'Failed to fetch user data');
    }

    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }
    throw new ApiError(500, 'Internal server error');
  }
}
```

### 异步编程
- **Promise 最佳实践**: 避免 Promise 地狱
- **Async/await**: 优先使用 async/await 语法
- **错误传播**: 正确传播异步错误

### 设计模式
- **工厂模式**: 创建对象时使用工厂函数
- **观察者模式**: 事件驱动的组件通信
- **策略模式**: 算法的动态切换

## 🔄 现代化迁移

### 从 JavaScript 到 TypeScript
1. **渐进式迁移**: 从类型定义开始
2. **配置严格模式**: 逐步启用严格检查
3. **重构关键路径**: 先迁移核心业务逻辑

### 框架升级
- **React**: 从 Class 组件到 Hook
- **Node.js**: 采用最新的 LTS 版本
- **构建工具**: 从 Webpack 迁移到 Vite

## 📊 监控和度量

### 性能指标
- **Core Web Vitals**: LCP、FID、CLS
- **运行时性能**: 内存使用、CPU 使用率
- **包大小**: 构建产物大小监控

### 质量指标
- **测试覆盖率**: 单元测试和集成测试覆盖
- **代码复杂度**: 圈复杂度、函数长度
- **技术债务**: 过时依赖、代码异味

---

*此规则适用于现代 JavaScript/TypeScript 开发项目。如有特殊需求，请根据具体项目情况调整。*