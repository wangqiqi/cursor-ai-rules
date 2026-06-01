# 测试自动化技能

## 🎯 功能概述

提供全面的测试自动化能力，包括单元测试、集成测试、端到端测试、性能测试等，支持测试用例生成、执行编排、结果分析和持续集成，帮助团队建立可靠的自动化测试体系。

## 🚀 核心能力

### 测试类型支持
- **单元测试**: 函数和模块级别的测试
- **集成测试**: 组件间的集成测试
- **端到端测试**: 完整用户流程测试
- **性能测试**: 负载和压力测试
- **API测试**: RESTful API自动化测试

### 测试生命周期管理
- **测试用例生成**: 基于代码的智能测试用例生成
- **测试执行编排**: 并行执行和依赖管理
- **结果收集分析**: 测试结果聚合和趋势分析
- **失败诊断**: 自动失败原因分析和修复建议

### CI/CD集成
- **持续集成**: 自动化测试集成到CI流水线
- **质量门禁**: 测试覆盖率和质量标准的强制检查
- **部署验证**: 部署前的自动化验证测试
- **回滚测试**: 部署失败时的自动回滚验证

## 🛠️ 技术实现

### 核心算法
```javascript
// 测试自动化引擎
class TestAutomationEngine {
  async generateTestSuite(codebase) {
    const analysis = await this.analyzeCodebase(codebase);
    const testCases = await this.generateTestCases(analysis);
    const testSuite = await this.organizeTestSuite(testCases);

    return {
      unitTests: testSuite.unit,
      integrationTests: testSuite.integration,
      e2eTests: testSuite.e2e,
      performanceTests: testSuite.performance
    };
  }

  async executeTestSuite(testSuite, environment) {
    const results = await this.runParallelTests(testSuite, environment);
    const analysis = await this.analyzeResults(results);
    const report = await this.generateReport(analysis);

    return {
      results,
      analysis,
      report,
      recommendations: this.generateRecommendations(analysis)
    };
  }
}
```

### 测试用例生成
```javascript
// 智能测试用例生成
function generateUnitTests(functionCode) {
  const ast = parseCode(functionCode);
  const testCases = [];

  // 分析函数签名
  const params = extractParameters(ast);
  const returnType = extractReturnType(ast);

  // 生成正常情况测试
  testCases.push({
    name: '正常输入测试',
    inputs: generateValidInputs(params),
    expected: generateExpectedOutput(returnType),
    type: 'positive'
  });

  // 生成边界情况测试
  testCases.push({
    name: '边界值测试',
    inputs: generateBoundaryInputs(params),
    expected: generateBoundaryOutput(returnType),
    type: 'boundary'
  });

  // 生成异常情况测试
  testCases.push({
    name: '异常输入测试',
    inputs: generateInvalidInputs(params),
    expected: generateErrorOutput(),
    type: 'negative'
  });

  return testCases;
}
```

## 📊 性能指标

- **测试生成速度**: <5秒的单元测试用例生成
- **测试执行效率**: 并行执行提升3-5倍速度
- **覆盖率达成**: 平均80%+的代码覆盖率
- **失败诊断准确率**: >90%的测试失败原因识别

## 🔗 集成接口

### Scripts集成
- `test-runner.sh`: 核心测试执行管理
- `test-generator.sh`: 测试用例自动生成
- `test-analyzer.sh`: 测试结果分析

### Hooks集成
- `test-pre-commit.sh`: 提交前测试验证
- `test-post-merge.sh`: 合并后回归测试

### Workflows集成
- **CI/CD测试工作流**: 完整的自动化测试流水线
- **测试质量工作流**: 测试覆盖率和质量监控
- **发布验证工作流**: 发布前的全面测试验证

## 🧪 测试框架支持

### JavaScript/TypeScript
```javascript
// Jest测试示例
describe('UserService', () => {
  let userService;
  let mockDatabase;

  beforeEach(() => {
    mockDatabase = createMockDatabase();
    userService = new UserService(mockDatabase);
  });

  describe('createUser', () => {
    it('should create a new user successfully', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      };

      const result = await userService.createUser(userData);

      expect(result.success).toBe(true);
      expect(result.user.id).toBeDefined();
      expect(mockDatabase.save).toHaveBeenCalledWith(userData);
    });

    it('should throw error for invalid email', async () => {
      const userData = {
        name: 'John Doe',
        email: 'invalid-email'
      };

      await expect(userService.createUser(userData))
        .rejects.toThrow('Invalid email format');
    });
  });
});
```

### Python
```python
# pytest测试示例
import pytest
from user_service import UserService
from unittest.mock import Mock, patch

class TestUserService:
    @pytest.fixture
    def user_service(self):
        mock_db = Mock()
        return UserService(mock_db)

    def test_create_user_success(self, user_service):
        user_data = {
            'name': 'John Doe',
            'email': 'john@example.com'
        }

        result = user_service.create_user(user_data)

        assert result['success'] is True
        assert 'id' in result['user']
        user_service.db.save.assert_called_once_with(user_data)

    def test_create_user_invalid_email(self, user_service):
        user_data = {
            'name': 'John Doe',
            'email': 'invalid-email'
        }

        with pytest.raises(ValueError, match='Invalid email format'):
            user_service.create_user(user_data)

    @pytest.mark.parametrize('email,expected_valid', [
        ('user@example.com', True),
        ('invalid-email', False),
        ('user@.com', False),
        ('', False)
    ])
    def test_email_validation(self, user_service, email, expected_valid):
        result = user_service.validate_email(email)
        assert result == expected_valid
```

### API测试
```javascript
// API测试示例
const request = require('supertest');
const app = require('../app');

describe('User API', () => {
  describe('GET /users', () => {
    it('should return list of users', async () => {
      const response = await request(app)
        .get('/users')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/users?page=1&limit=10')
        .expect(200);

      expect(response.body).toHaveProperty('data');
      expect(response.body).toHaveProperty('pagination');
      expect(response.body.pagination.page).toBe(1);
    });
  });

  describe('POST /users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      };

      const response = await request(app)
        .post('/users')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.name).toBe(userData.name);
      expect(response.body.email).toBe(userData.email);
    });

    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/users')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('errors');
      expect(response.body.errors).toContain('name is required');
      expect(response.body.errors).toContain('email is required');
    });
  });
});
```

## 📈 学习与适应

### 自适应学习
- **代码模式学习**: 学习项目的测试模式和最佳实践
- **失败模式学习**: 分析测试失败的常见原因和模式
- **覆盖率学习**: 理解项目的测试覆盖率目标和要求

### 智能建议
- **测试用例优化**: 基于历史数据的测试用例优化建议
- **覆盖率提升**: 识别未覆盖的代码路径和建议
- **测试效率改进**: 优化测试执行时间和资源使用

## 🎯 使用场景

### 开发测试
- **单元测试**: 函数和类的自动化单元测试
- **组件测试**: React/Vue组件的自动化测试
- **集成测试**: 服务间的集成测试验证

### API测试
- **RESTful API**: 完整的API端点测试覆盖
- **GraphQL API**: GraphQL查询和变更测试
- **WebSocket**: 实时通信API测试

### 端到端测试
- **用户流程**: 完整用户操作流程测试
- **跨浏览器**: 多浏览器兼容性测试
- **移动端**: 移动应用端到端测试

### 性能与负载测试
- **负载测试**: 高并发场景下的性能测试
- **压力测试**: 系统极限情况的压力测试
- **稳定性测试**: 长时间运行的稳定性测试

## 🔧 配置选项

### 基本配置
```json
{
  "testing": {
    "enabled": true,
    "auto_generate": true,
    "parallel_execution": true,
    "coverage_target": 80
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "frameworks": ["jest", "pytest", "cypress"],
    "environments": ["unit", "integration", "e2e"],
    "reporting": {
      "format": "html",
      "history": true,
      "trends": true
    },
    "ci_integration": {
      "github_actions": true,
      "gitlab_ci": false,
      "jenkins": false
    }
  }
}
```

### 覆盖率配置
```json
{
  "coverage": {
    "enabled": true,
    "target": 80,
    "thresholds": {
      "branches": 75,
      "functions": 80,
      "lines": 80,
      "statements": 80
    },
    "exclude": [
      "node_modules/**",
      "test/**",
      "**/*.test.js",
      "**/*.spec.js"
    ]
  }
}
```

## 📚 相关资源

- **测试框架**: Jest, pytest, Cypress, Playwright
- **断言库**: Chai, Hamcrest, AssertJ
- **模拟工具**: Sinon, unittest.mock, Mockito

---

**技能版本**: 1.0.0
**支持框架**: Jest, pytest, Cypress, Playwright, Selenium
**测试类型**: 单元测试, 集成测试, E2E测试, 性能测试
**依赖**: test-runner.sh, test-generator.sh