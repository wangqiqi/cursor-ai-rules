# Webapp Testing — Full Guide

# 🎯 Skills扩展: webapp-testing

Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.

## 🔧 使用方法

```bash
/master skill:webapp-testing [参数]
```

## 📚 原始文档

description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
license: Complete terms in LICENSE.txt

## 🔧 VIBE Coding 集成

此技能已深度集成到 VIBE Coding 开发原则中，支持文档驱动和测试驱动的开发流程：

```bash
# VIBE Coding 测试流程
/master vibe-coding test-plan    # 生成测试计划
/master vibe-coding e2e-tests    # 执行端到端测试
/master vibe-coding alignment-check # 测试与功能对齐验证
```

## 📖 详细技术指南

### Web应用测试策略
1. **单元测试**: 测试单个组件和函数的正确性
2. **集成测试**: 验证组件间的交互和数据流
3. **端到端测试**: 模拟真实用户场景的完整流程
4. **性能测试**: 评估应用在不同负载下的表现
5. **可访问性测试**: 确保应用对所有用户都是可访问的
6. **跨浏览器测试**: 验证在不同浏览器和设备上的兼容性

### VIBE Coding 测试流程

#### 阶段1：测试计划制定（前端开发完成后）
```typescript
// 生成基于需求的测试计划
interface TestPlan {
  userStories: UserStory[]
  testScenarios: TestScenario[]
  acceptanceCriteria: AcceptanceCriterion[]
}

// 自动生成测试用例
function generateTestCases(requirements: Requirements): TestCase[] {
  // 基于用户故事生成测试用例
  // 识别边界条件和异常场景
  // 创建数据驱动测试
}
```

#### 阶段2：测试驱动开发
```typescript
// 测试先行开发模式
describe('User Registration', () => {
  it('should successfully register new user', async () => {
    // 1. 准备测试数据（测试先行）
    const testData = generateTestData('validUser')

    // 2. 执行测试（功能实现前）
    await registerUser(testData)

    // 3. 验证结果（验收标准）
    expect(userExists(testData.email)).toBe(true)
  })

  it('should reject invalid email format', async () => {
    // 边界条件测试
    const invalidData = generateTestData('invalidEmail')

    await expect(registerUser(invalidData))
      .rejects.toThrow('Invalid email format')
  })
})
```

#### 阶段3：前后端对齐测试
```typescript
// API 契约测试 - 验证前后端接口一致性
describe('API Contract Alignment', () => {
  it('should match frontend API expectations', async () => {
    const frontendContract = loadFrontendAPIContract()
    const backendImplementation = inspectBackendAPI()

    expect(backendImplementation).toMatchContract(frontendContract)
  })

  it('should handle error responses consistently', async () => {
    const errorScenarios = generateErrorScenarios()

    for (const scenario of errorScenarios) {
      const response = await callAPIWithError(scenario)
      expect(response).toMatchErrorContract()
    }
  })
})
```

### 测试最佳实践
- 编写可维护和可读的测试代码
- 使用描述性的测试名称和断言
- 实现测试数据管理和清理
- 平衡测试覆盖率和执行时间
- 集成到CI/CD管道中实现自动化
- **VIBE Coding**: 测试计划先行，验收标准明确，对齐验证持续

### VIBE Coding 专用测试配置

#### 测试环境配置
```json
{
  "vibeTesting": {
    "testDriven": true,
    "documentationFirst": true,
    "alignmentChecks": true,
    "phaseGates": {
      "frontendComplete": "tests_written",
      "backendComplete": "contract_verified",
      "integrationComplete": "e2e_passed"
    }
  }
}
```

#### 自动化测试流水线
```yaml
# VIBE Coding CI/CD Pipeline
stages:
  - documentation
  - frontend-dev
  - backend-dev
  - testing
  - alignment
  - deployment

frontend-dev:
  script:
    - npm run test:unit
    - npm run test:integration
  only:
    changes:
      - frontend/**

testing:
  script:
    - npx playwright test
    - npm run test:alignment
  dependencies:
    - frontend-dev
    - backend-dev
```

---
*来源: Anthropic Skills库 | 集成时间: 2026-01-15*
