---
description: "VIBE Coding 开发原则 - 文档驱动、测试先行、前后端对齐的开发模式"
apply_when:
  - keywords: ["开发", "coding", "implementation", "vibe", "测试", "功能"]
priority: 12
---

# 🚀 VIBE Coding 开发原则

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## ⚠️⚠️⚠️ 执行前必须检查：项目开发意图检测 ⚠️⚠️⚠️

**在应用VIBE Coding原则之前，必须先通过 `@constitution` 和 `@conversation_intent_analyzer` 的项目创建意图检测**

### 🔍 强制前置条件
- ✅ **已通过宪法审核**: 确认项目意图明确，需求已充分讨论
- ✅ **已完成需求分析**: 通过conversation_intent_analyzer的需求分析流程
- ✅ **获得用户确认**: 用户已明确同意开始开发

**如果未满足上述条件，立即停止并引导用户回到需求讨论阶段**

---

## 🎯 VIBE Coding 核心原则

VIBE Coding 是基于 **文档驱动开发** 和 **测试驱动开发** 的现代软件工程方法论，特别适用于 B/S 架构项目：

### 📚 原则1：文档驱动开发 (Documentation-Driven Development)
**"文档先行，代码跟随，屡次锚定，屡次对齐"**
- 任何开发活动必须从完整文档开始
- 文档不仅是说明，更是开发蓝图和验收标准
- 代码实现必须与文档保持持续对齐

### 🏗️ 原则2：B/S 架构分层开发 (B/S Architecture Layered Development)
**"前端优先，后端跟随，从可见到不可见"**
- 先完成前端可见部分，再开发后端服务
- 开发顺序：UI设计 → 前端交互 → API接口 → 后端实现 → 数据库设计
- 前后端并行开发，但前端先行

### 🧪 原则3：测试驱动开发 (Test-Driven Development)
**"测试先行，代码后至，质量为先"**
- 前端开发完成后立即制定测试计划
- 使用 Playwright 进行端到端测试
- 测试用例先于代码实现，质量标准先于开发

### 🔗 原则4：前后端对齐机制 (Frontend-Backend Alignment)
**"接口契约，文档同步，多次对齐"**
- API 接口文档必须在前后端开发前确定
- 前后端代码必须与接口文档保持对齐
- 开发过程中进行多次对齐验证

---

## 📋 VIBE Coding 开发流程

### 阶段1：需求讨论与文档化 (Phase 1: Requirements Discussion & Documentation)

**触发条件**: 用户表达项目创建意图，通过 `@conversation_intent_analyzer` 检测

#### 1.1 需求深度分析
- **业务需求**: 用户故事、业务流程、核心功能
- **用户体验**: 界面设计、交互流程、使用场景
- **技术需求**: 性能指标、安全要求、可扩展性
- **约束条件**: 技术栈限制、时间预算、资源限制

#### 1.2 架构设计文档
```markdown
## 🏗️ 系统架构设计

### 前端架构
- **技术栈**: React/Vue/Angular + TypeScript
- **组件架构**: 原子设计模式 / 组件库设计
- **状态管理**: Redux/Zustand/Pinia
- **路由设计**: 页面结构和导航流程

### 后端架构
- **API设计**: RESTful/GraphQL 接口规范
- **数据模型**: 数据库设计和关系映射
- **业务逻辑**: 服务层和领域模型设计
- **安全架构**: 认证授权和数据安全

### 部署架构
- **环境规划**: 开发/测试/生产环境
- **CI/CD流程**: 自动化构建和部署
- **监控告警**: 性能监控和错误追踪
```

#### 1.3 UI/UX 设计文档
- **界面原型**: 页面布局和组件设计
- **交互流程**: 用户操作路径和状态变化
- **响应式设计**: 多设备适配方案
- **无障碍设计**: 可用性标准遵循

#### 1.4 数据管理设计
- **数据流设计**: 前后端数据交互规范
- **状态管理**: 客户端和服务端状态同步
- **缓存策略**: 数据缓存和性能优化
- **数据安全**: 敏感数据处理和隐私保护

---

### 阶段2：前后端分层开发 (Phase 2: Frontend-Backend Layered Development)

**核心策略**: **前端优先，后端跟随，从外到内，逐步深入**

#### 2.1 前端先行开发 (Frontend-First Development)

##### 阶段2.1.1: UI 界面开发
```bash
# 前端开发顺序示例
1. 创建项目结构和基础配置
2. 实现页面布局和基础样式
3. 开发核心组件和交互逻辑
4. 集成状态管理和数据流
5. 实现响应式设计和适配
```

##### 阶段2.1.2: API 接口设计
```typescript
// 接口契约定义示例
interface UserAPI {
  // 用户管理
  getUsers(params: UserQuery): Promise<UserList>
  createUser(data: UserCreate): Promise<User>
  updateUser(id: string, data: UserUpdate): Promise<User>
  deleteUser(id: string): Promise<void>

  // 认证相关
  login(credentials: LoginCredentials): Promise<AuthToken>
  logout(): Promise<void>
  refreshToken(token: string): Promise<AuthToken>
}
```

##### 阶段2.1.3: Mock 数据开发
- 创建前端 Mock 服务
- 模拟后端 API 响应
- 支持前端独立开发和测试

#### 2.2 后端跟随开发 (Backend-Following Development)

##### 阶段2.2.1: API 实现
```python
# 后端开发顺序示例
1. 实现认证和授权模块
2. 开发核心业务 API 接口
3. 实现数据访问层和业务逻辑
4. 添加数据验证和错误处理
5. 实现缓存和性能优化
```

##### 阶段2.2.2: 数据库设计
- 根据前端需求设计数据模型
- 实现数据库迁移脚本
- 设置索引和性能优化

##### 阶段2.2.3: 集成测试
- 后端单元测试
- API 接口测试
- 数据库操作测试

#### 2.3 前后端联调对齐 (Frontend-Backend Integration)

##### 对齐检查清单
- [ ] API 接口返回格式与前端期望一致
- [ ] 错误处理和状态码规范统一
- [ ] 数据验证规则前后端同步
- [ ] 认证授权机制协调一致
- [ ] 缓存策略和数据同步机制

---

### 阶段3：测试驱动开发 (Phase 3: Test-Driven Development)

**核心理念**: **测试先行，代码质量为本，自动化保障**

#### 3.1 前端测试计划制定

##### 单元测试 (Unit Tests)
```typescript
// 组件单元测试示例
describe('UserProfile Component', () => {
  it('should display user name correctly', () => {
    // 准备测试数据
    const user = { name: 'John Doe', email: 'john@example.com' }

    // 渲染组件
    render(<UserProfile user={user} />)

    // 验证显示内容
    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })
})
```

##### 集成测试 (Integration Tests)
```typescript
// 页面集成测试示例
describe('Login Flow', () => {
  it('should allow user to login successfully', async () => {
    // 启动测试服务器
    const server = await startTestServer()

    // 渲染登录页面
    render(<LoginPage />, { wrapper: TestWrapper })

    // 填写登录表单
    await userEvent.type(screen.getByLabelText('Email'), 'user@example.com')
    await userEvent.type(screen.getByLabelText('Password'), 'password123')

    // 提交表单
    await userEvent.click(screen.getByRole('button', { name: 'Login' }))

    // 验证跳转到首页
    await waitFor(() => {
      expect(window.location.pathname).toBe('/dashboard')
    })
  })
})
```

#### 3.2 Playwright E2E 测试计划

##### 测试策略设计
```typescript
// Playwright E2E测试配置
export const testConfig = {
  // 测试环境
  baseURL: process.env.TEST_BASE_URL || 'http://localhost:3000',

  // 浏览器配置
  browsers: ['chromium', 'firefox', 'webkit'],

  // 测试用例组织
  testSuites: {
    critical: ['login', 'user-registration', 'core-features'],
    smoke: ['basic-navigation', 'error-handling'],
    regression: ['all-features']
  },

  // 测试数据管理
  testData: {
    users: ['admin', 'regular-user', 'guest'],
    scenarios: ['happy-path', 'error-cases', 'edge-cases']
  }
}
```

##### 核心业务流程测试
```typescript
// 用户注册流程E2E测试
test('user registration flow', async ({ page }) => {
  // 访问注册页面
  await page.goto('/register')

  // 填写注册表单
  await page.fill('[data-testid="email"]', 'newuser@example.com')
  await page.fill('[data-testid="password"]', 'securePassword123')
  await page.fill('[data-testid="confirm-password"]', 'securePassword123')

  // 提交注册
  await page.click('[data-testid="register-button"]')

  // 验证成功跳转到登录页面
  await expect(page).toHaveURL('/login')
  await expect(page.locator('[data-testid="success-message"]'))
    .toContainText('Registration successful')
})
```

##### 跨浏览器兼容性测试
```typescript
// 多浏览器测试示例
test.describe('Cross-browser Compatibility', () => {
  test('should work on all supported browsers', async ({ browserName }) => {
    // 根据浏览器类型调整测试逻辑
    const isWebkit = browserName === 'webkit'

    if (isWebkit) {
      // WebKit 特定测试逻辑
      test.skip() // 如果某些功能在 Safari 中不支持
    }

    // 通用测试逻辑
    // ...
  })
})
```

#### 3.3 测试自动化集成

##### CI/CD 集成
```yaml
# GitHub Actions CI 配置示例
name: E2E Tests
on: [push, pull_request]

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Run Playwright tests
        run: npx playwright test

      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

---

### 阶段4：多次对齐验证 (Phase 4: Multiple Alignment Verification)

**核心原则**: **屡次锚定，屡次对齐，确保一致性**

#### 4.1 文档与代码对齐 (Documentation-Code Alignment)

##### 对齐检查清单
- [ ] 功能实现与需求文档一致
- [ ] API 接口与接口文档同步
- [ ] UI 实现与设计稿匹配
- [ ] 数据结构与数据模型一致
- [ ] 业务逻辑与业务规则符合

##### 对齐验证流程
```bash
# 文档对齐检查脚本示例
#!/bin/bash

echo "🔍 开始文档与代码对齐检查..."

# 1. API文档与代码对齐
echo "📋 检查API接口文档..."
check_api_alignment

# 2. 需求文档与功能对齐
echo "📝 检查需求实现..."
check_requirements_alignment

# 3. 设计文档与UI对齐
echo "🎨 检查UI设计一致性..."
check_ui_alignment

# 4. 数据模型对齐
echo "🗄️ 检查数据模型..."
check_data_alignment

echo "✅ 对齐检查完成"
```

#### 4.2 前后端接口对齐 (Frontend-Backend Interface Alignment)

##### 接口契约验证
```typescript
// 接口契约验证工具
interface ContractValidator {
  validateAPIContract(apiSpec: APISpec, implementation: APIImpl): ValidationResult

  validateDataContract(dataSpec: DataSpec, implementation: DataImpl): ValidationResult

  validateErrorContract(errorSpec: ErrorSpec, implementation: ErrorImpl): ValidationResult
}

// 使用示例
const validator = new ContractValidator()

// 验证API契约
const apiResult = validator.validateAPIContract(openAPISpec, expressRoutes)
if (!apiResult.isValid) {
  console.error('API契约不匹配:', apiResult.errors)
}

// 验证数据契约
const dataResult = validator.validateDataContract(dataSchema, mongooseModels)
if (!dataResult.isValid) {
  console.error('数据契约不匹配:', dataResult.errors)
}
```

#### 4.3 测试与功能对齐 (Test-Function Alignment)

##### 测试覆盖率验证
```typescript
// 测试覆盖率报告生成
interface CoverageReporter {
  generateCoverageReport(): CoverageReport

  checkCoverageThresholds(report: CoverageReport): ThresholdResult

  identifyUncoveredCode(report: CoverageReport): UncoveredAreas
}

// 覆盖率检查示例
const reporter = new CoverageReporter()
const coverage = reporter.generateCoverageReport()

// 检查分支覆盖率
if (coverage.branches < 80) {
  throw new Error(`分支覆盖率不足: ${coverage.branches}% (需要 >= 80%)`)
}

// 检查函数覆盖率
if (coverage.functions < 90) {
  throw new Error(`函数覆盖率不足: ${coverage.functions}% (需要 >= 90%)`)
}
```

---

## 🛠️ 实施工具与质量门禁

详见 @vibe-coding-tools.md

---

## 🔄 与现有规则的协同

### 与 @constitution 的协同
- **遵循意图主权**: 所有开发决策需用户确认
- **保证信号可信**: 文档和代码对齐提供可验证的依据
- **支持审计**: 多阶段对齐验证提供完整审计链

### 与 @conversation_intent_analyzer 的协同
- **需求分析前置**: 在项目创建前完成详细需求分析
- **方案讨论优先**: 架构设计需经过充分讨论
- **澄清问题机制**: 开发过程中持续澄清和确认需求

### 与 @webapp-testing 的协同
- **测试技能扩展**: 基于现有Playwright技能构建E2E测试流程
- **测试驱动集成**: 将测试计划纳入开发流程的强制环节
- **自动化测试**: 利用现有测试基础设施实现自动化测试

---

*🚀 VIBE Coding v4.3.0 - 文档驱动开发，测试先行，前后端对齐，让高质量软件开发成为标准实践*

*核心创新*: 从传统瀑布式开发到文档驱动开发，从分离的前后端到协同的对齐机制，从被动的测试到主动的质量保障！