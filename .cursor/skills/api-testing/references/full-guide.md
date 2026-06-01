# Api Testing — Full Guide

# API测试技能

## 🎯 功能概述

提供全面的API自动化测试能力，包括RESTful API测试、GraphQL测试、性能测试、安全测试、契约测试等，帮助开发者确保API的正确性、性能和安全性，实现从开发到部署的完整API质量保障。

## 🚀 核心能力

### API功能测试
- **RESTful API测试**: GET、POST、PUT、DELETE等HTTP方法测试
- **GraphQL测试**: 查询、变更、订阅的完整测试覆盖
- **WebSocket测试**: 实时通信API的自动化测试
- **文件上传测试**: 多格式文件上传和处理测试

### API质量测试
- **契约测试**: API契约验证和版本兼容性测试
- **负载测试**: 高并发场景下的API性能测试
- **压力测试**: 系统极限情况下的稳定性测试
- **安全测试**: 认证、授权、输入验证的安全测试

### 测试自动化
- **CI/CD集成**: 自动化测试流水线集成
- **测试报告**: 详细的测试结果和趋势分析
- **Mock服务**: API依赖的模拟和服务虚拟化
- **数据管理**: 测试数据的生成和管理

## 🛠️ 技术实现

### 核心算法
```javascript
// API测试引擎
class APITester {
  async executeAPITests(apiSpec, testConfig) {
    const testSuite = await this.generateTestSuite(apiSpec);
    const mockServer = await this.setupMockServices(testConfig.mocks);
    const testEnvironment = await this.prepareTestEnvironment(testConfig);

    const results = await this.runTestSuite(testSuite, {
      environment: testEnvironment,
      mockServer,
      config: testConfig
    });

    return {
      results: this.analyzeResults(results),
      coverage: this.calculateCoverage(results, apiSpec),
      performance: this.analyzePerformance(results),
      recommendations: this.generateRecommendations(results)
    };
  }

  async generateTestSuite(apiSpec) {
    const endpoints = this.parseAPISpec(apiSpec);
    const testCases = [];

    for (const endpoint of endpoints) {
      // 生成正向测试用例
      testCases.push(this.generatePositiveTests(endpoint));

      // 生成负向测试用例
      testCases.push(this.generateNegativeTests(endpoint));

      // 生成边界测试用例
      testCases.push(this.generateBoundaryTests(endpoint));

      // 生成性能测试用例
      testCases.push(this.generatePerformanceTests(endpoint));
    }

    return this.organizeTestSuite(testCases);
  }

  async runTestSuite(testSuite, context) {
    const results = {
      functional: [],
      performance: [],
      security: [],
      contract: []
    };

    // 并行执行功能测试
    results.functional = await this.runFunctionalTests(testSuite.functional, context);

    // 执行性能测试
    results.performance = await this.runPerformanceTests(testSuite.performance, context);

    // 执行安全测试
    results.security = await this.runSecurityTests(testSuite.security, context);

    // 执行契约测试
    results.contract = await this.runContractTests(testSuite.contract, context);

    return results;
  }
}
```

### 测试用例生成
```javascript
// REST API测试用例生成
function generateAPITestCases(endpoint) {
  const testCases = [];

  // GET请求测试
  if (endpoint.method === 'GET') {
    testCases.push({
      name: 'Successful GET request',
      method: 'GET',
      url: endpoint.path,
      expectedStatus: 200,
      validateResponse: (response) => {
        expect(response).toHaveProperty('data');
        expect(Array.isArray(response.data)).toBe(true);
      }
    });

    // 分页测试
    if (endpoint.parameters.includes('page')) {
      testCases.push({
        name: 'GET request with pagination',
        method: 'GET',
        url: `${endpoint.path}?page=1&limit=10`,
        expectedStatus: 200,
        validateResponse: (response) => {
          expect(response).toHaveProperty('data');
          expect(response).toHaveProperty('pagination');
          expect(response.data.length).toBeLessThanOrEqual(10);
        }
      });
    }

    // 错误处理测试
    testCases.push({
      name: 'GET request with invalid ID',
      method: 'GET',
      url: `${endpoint.path}/invalid-id`,
      expectedStatus: 404,
      validateResponse: (response) => {
        expect(response).toHaveProperty('error');
        expect(response.error.code).toBe('NOT_FOUND');
      }
    });
  }

  // POST请求测试
  if (endpoint.method === 'POST') {
    testCases.push({
      name: 'Successful POST request',
      method: 'POST',
      url: endpoint.path,
      body: generateValidRequestBody(endpoint.schema),
      expectedStatus: 201,
      validateResponse: (response) => {
        expect(response).toHaveProperty('id');
        expect(response).toHaveProperty('createdAt');
      }
    });

    // 验证测试
    testCases.push({
      name: 'POST request with invalid data',
      method: 'POST',
      url: endpoint.path,
      body: generateInvalidRequestBody(endpoint.schema),
      expectedStatus: 400,
      validateResponse: (response) => {
        expect(response).toHaveProperty('errors');
        expect(Array.isArray(response.errors)).toBe(true);
      }
    });
  }

  return testCases;
}
```

## 📊 性能指标

- **测试生成速度**: <10秒的完整API测试套件生成
- **测试执行效率**: 并行执行提升5-10倍速度
- **覆盖率达成**: >90%的API端点测试覆盖
- **误报率**: <5%的测试失败误报率

## 🔗 集成接口

### Scripts集成
- `api-tester.sh`: 核心API测试管理
- `contract-tester.sh`: API契约测试
- `performance-tester.sh`: API性能测试

### Hooks集成
- `api-test-pre-commit.sh`: 提交前API测试验证
- `api-contract-validator.sh`: API契约验证

### Workflows集成
- **API测试工作流**: 完整的API自动化测试流程
- **发布验证工作流**: API发布前的全面验证
- **监控告警工作流**: API质量监控和告警

## 🧪 测试框架支持

### REST API测试
```javascript
// 使用Supertest进行REST API测试
const request = require('supertest');
const app = require('../app');

describe('User API', () => {
  describe('GET /users', () => {
    it('should return list of users', async () => {
      const response = await request(app)
        .get('/users')
        .expect(200)
        .expect('Content-Type', /json/);

      expect(response.body).toHaveProperty('data');
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
    });

    it('should support filtering', async () => {
      const response = await request(app)
        .get('/users?status=active')
        .expect(200);

      expect(response.body.data.every(user => user.status === 'active')).toBe(true);
    });

    it('should handle invalid query parameters', async () => {
      const response = await request(app)
        .get('/users?page=invalid')
        .expect(400);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('POST /users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securePassword123'
      };

      const response = await request(app)
        .post('/users')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.name).toBe(userData.name);
      expect(response.body.email).toBe(userData.email);
      expect(response.body).not.toHaveProperty('password'); // 密码不应返回
    });

    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/users')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('errors');
      expect(response.body.errors).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ field: 'name', message: 'Name is required' }),
          expect.objectContaining({ field: 'email', message: 'Email is required' })
        ])
      );
    });

    it('should validate email format', async () => {
      const response = await request(app)
        .post('/users')
        .send({
          name: 'John Doe',
          email: 'invalid-email',
          password: 'password123'
        })
        .expect(400);

      expect(response.body).toHaveProperty('errors');
      expect(response.body.errors).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ field: 'email', message: 'Invalid email format' })
        ])
      );
    });
  });

  describe('GET /users/:id', () => {
    it('should return user by ID', async () => {
      const userId = '123';
      const response = await request(app)
        .get(`/users/${userId}`)
        .expect(200);

      expect(response.body).toHaveProperty('id', userId);
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('email');
    });

    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/users/non-existent-id')
        .expect(404);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error.code).toBe('USER_NOT_FOUND');
    });
  });
});
```

### GraphQL测试
```javascript
// 使用Apollo Server测试GraphQL API
const { ApolloServer } = require('apollo-server');
const { createTestClient } = require('apollo-server-testing');
const { gql } = require('apollo-server');

const server = new ApolloServer({ typeDefs, resolvers });
const { query, mutate } = createTestClient(server);

describe('User GraphQL API', () => {
  describe('Query users', () => {
    it('should return list of users', async () => {
      const GET_USERS = gql`
        query GetUsers($first: Int, $after: String) {
          users(first: $first, after: $after) {
            edges {
              node {
                id
                name
                email
              }
              cursor
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
      `;

      const { data } = await query({
        query: GET_USERS,
        variables: { first: 10 }
      });

      expect(data.users.edges).toHaveLength(10);
      expect(data.users.pageInfo.hasNextPage).toBe(true);
    });

    it('should filter users by status', async () => {
      const GET_ACTIVE_USERS = gql`
        query GetActiveUsers {
          users(filter: { status: ACTIVE }) {
            edges {
              node {
                id
                name
                status
              }
            }
          }
        }
      `;

      const { data } = await query({ query: GET_ACTIVE_USERS });

      expect(data.users.edges.every(edge =>
        edge.node.status === 'ACTIVE'
      )).toBe(true);
    });
  });

  describe('Mutation createUser', () => {
    it('should create a new user', async () => {
      const CREATE_USER = gql`
        mutation CreateUser($input: CreateUserInput!) {
          createUser(input: $input) {
            user {
              id
              name
              email
            }
            errors {
              field
              message
            }
          }
        }
      `;

      const { data } = await mutate({
        mutation: CREATE_USER,
        variables: {
          input: {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'securePassword123'
          }
        }
      });

      expect(data.createUser.user).toHaveProperty('id');
      expect(data.createUser.user.name).toBe('John Doe');
      expect(data.createUser.errors).toBeNull();
    });

    it('should validate input data', async () => {
      const CREATE_USER = gql`
        mutation CreateUser($input: CreateUserInput!) {
          createUser(input: $input) {
            user {
              id
              name
              email
            }
            errors {
              field
              message
            }
          }
        }
      `;

      const { data } = await mutate({
        mutation: CREATE_USER,
        variables: {
          input: {
            name: '',
            email: 'invalid-email',
            password: '123'
          }
        }
      });

      expect(data.createUser.user).toBeNull();
      expect(data.createUser.errors).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ field: 'name', message: 'Name is required' }),
          expect.objectContaining({ field: 'email', message: 'Invalid email format' }),
          expect.objectContaining({ field: 'password', message: 'Password too short' })
        ])
      );
    });
  });
});
```

## 📈 学习与适应

### 自适应学习
- **API模式学习**: 学习项目的API设计模式和规范
- **测试模式学习**: 理解项目的测试偏好和模式
- **失败模式学习**: 分析API测试失败的常见原因

### 智能建议
- **测试覆盖建议**: 基于API复杂度的测试覆盖建议
- **性能基准建议**: API性能测试的基准建议
- **安全加固建议**: API安全测试的改进建议

## 🎯 使用场景

### 开发测试
- **单元测试**: API函数和方法的单元测试
- **集成测试**: API与其他服务的集成测试
- **回归测试**: API变更后的回归测试

### QA测试
- **功能测试**: API功能的完整性测试
- **兼容性测试**: 不同客户端的兼容性测试
- **边界测试**: API输入输出的边界条件测试

### 运维监控
- **健康检查**: API可用性和性能监控
- **负载测试**: 高并发场景下的性能测试
- **故障注入**: 系统弹性和容错能力测试

## 🔧 配置选项

### 基本配置
```json
{
  "api_testing": {
    "enabled": true,
    "auto_generate": true,
    "parallel_execution": true,
    "coverage_target": 90
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "test_types": ["functional", "performance", "security", "contract"],
    "environments": {
      "development": "http://localhost:3000",
      "staging": "https://api-staging.example.com",
      "production": "https://api.example.com"
    },
    "authentication": {
      "type": "bearer",
      "token_endpoint": "/auth/token",
      "refresh_endpoint": "/auth/refresh"
    },
    "performance": {
      "load_test": {
        "enabled": true,
        "concurrent_users": 100,
        "duration": 300
      },
      "stress_test": {
        "enabled": true,
        "max_users": 1000,
        "ramp_up_time": 60
      }
    }
  }
}
```

### 报告配置
```json
{
  "reporting": {
    "formats": ["html", "json", "junit"],
    "integrations": {
      "slack": true,
      "teams": false,
      "email": true
    },
    "thresholds": {
      "failure_rate": 5,
      "performance_degradation": 10,
      "security_vulnerabilities": 0
    }
  }
}
```

## 📚 相关资源

- **测试工具**: Postman, Insomnia, REST Client
- **测试框架**: Jest, Supertest, Artillery
- **性能工具**: k6, Artillery, JMeter

---

**技能版本**: 1.0.0
**支持协议**: REST, GraphQL, WebSocket
**测试类型**: 功能测试, 性能测试, 安全测试, 契约测试
**并发支持**: 1000+ 并发请求
**依赖**: api-tester.sh
