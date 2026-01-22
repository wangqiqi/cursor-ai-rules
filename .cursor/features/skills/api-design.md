# API设计技能

## 🎯 功能概述

提供专业的API设计能力，包括RESTful API设计、GraphQL模式设计、API规范验证、文档生成等，帮助开发者设计高质量、可扩展、可维护的API接口。

## 🚀 核心能力

### API设计模式
- **RESTful设计**: 标准的RESTful API设计原则
- **GraphQL设计**: 灵活的GraphQL模式和查询设计
- **微服务API**: 微服务架构下的API设计
- **实时API**: WebSocket和SSE实时API设计

### API规范与标准
- **OpenAPI规范**: 完整的OpenAPI 3.0规范支持
- **JSON:API**: 标准化JSON API响应格式
- **HAL/JSON**: 超媒体API设计
- **API Blueprint**: API文档规范

### API质量保证
- **一致性检查**: API设计的一致性和规范性验证
- **安全性评估**: API安全设计和认证机制验证
- **性能优化**: API性能和缓存策略设计
- **可扩展性评估**: API的可扩展性和维护性评估

## 🛠️ 技术实现

### 核心算法
```javascript
// API设计引擎
class APIDesigner {
  async designAPI(requirements) {
    const analysis = await this.analyzeRequirements(requirements);
    const specification = await this.generateSpecification(analysis);
    const validation = await this.validateDesign(specification);

    return {
      specification,
      documentation: this.generateDocumentation(specification),
      validation,
      recommendations: this.generateRecommendations(validation)
    };
  }

  async generateRESTfulAPI(entity, operations) {
    const endpoints = [];
    const basePath = `/${entity.toLowerCase()}`;

    // CRUD操作映射
    const crudMapping = {
      create: { method: 'POST', path: basePath },
      read: { method: 'GET', path: `${basePath}/{id}` },
      update: { method: 'PUT', path: `${basePath}/{id}` },
      delete: { method: 'DELETE', path: `${basePath}/{id}` },
      list: { method: 'GET', path: basePath }
    };

    for (const operation of operations) {
      if (crudMapping[operation]) {
        endpoints.push({
          ...crudMapping[operation],
          operation,
          description: this.generateDescription(entity, operation)
        });
      }
    }

    return {
      entity,
      endpoints,
      schemas: this.generateSchemas(entity),
      examples: this.generateExamples(entity, operations)
    };
  }
}
```

### RESTful设计规则
```javascript
// RESTful资源设计
const resourceDesign = {
  // 资源命名
  naming: {
    // 使用复数名词
    correct: '/users',      // ✓
    incorrect: '/user'      // ✗
  },

  // 层级关系
  hierarchy: {
    // 嵌套资源
    usersPosts: '/users/{userId}/posts',
    userPost: '/users/{userId}/posts/{postId}'
  },

  // 操作映射
  operations: {
    GET: '读取',
    POST: '创建',
    PUT: '完整更新',
    PATCH: '部分更新',
    DELETE: '删除'
  }
};
```

## 📊 性能指标

- **设计速度**: <10秒的API规范生成
- **规范合规率**: >95%的RESTful设计规范合规
- **文档完整率**: >98%的API接口文档覆盖
- **验证准确率**: >90%的设计问题检测准确率

## 🔗 集成接口

### Scripts集成
- `api-designer.sh`: 核心API设计管理
- `api-validator.sh`: API规范验证
- `api-documenter.sh`: API文档生成

### Hooks集成
- `api-pre-commit.sh`: 提交前API规范检查
- `api-lint.sh`: API设计质量检查

### Workflows集成
- **API设计工作流**: 从需求到实现的完整设计流程
- **API评审工作流**: API设计的同行评审流程
- **API发布工作流**: API版本管理和发布流程

## 📋 API设计原则

### RESTful设计原则
```
1. 统一接口 (Uniform Interface)
   • 资源标识: URI唯一标识资源
   • 标准方法: GET, POST, PUT, DELETE
   • 自描述消息: 状态码和媒体类型
   • 超媒体作为应用状态引擎: HATEOAS

2. 无状态 (Stateless)
   • 每个请求包含完整上下文
   • 服务器不存储客户端状态
   • 提高可扩展性和可靠性

3. 可缓存 (Cacheable)
   • 明确标识可缓存资源
   • 使用适当的缓存策略
   • 减少服务器负载

4. 客户端-服务器分离
   • 关注点分离
   • 独立演进能力

5. 分层系统 (Layered System)
   • 中间层可插拔
   • 负载均衡和安全层
   • 封装遗留系统
```

### GraphQL设计原则
```graphql
# 模式优先设计
type Query {
  user(id: ID!): User
  users(filter: UserFilter, pagination: Pagination): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): UserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UserPayload!
}

type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

# 分页设计
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

## 🎨 API规范示例

### OpenAPI 3.0 规范
```yaml
openapi: 3.0.3
info:
  title: User Management API
  version: 1.0.0
  description: 用户管理API

servers:
  - url: https://api.example.com/v1
    description: Production server

paths:
  /users:
    get:
      summary: 获取用户列表
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
      responses:
        '200':
          description: 成功获取用户列表
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'

    post:
      summary: 创建新用户
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: 用户创建成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

  /users/{id}:
    get:
      summary: 获取单个用户
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: 成功获取用户
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: 用户不存在

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
          format: email
        createdAt:
          type: string
          format: date-time
      required:
        - id
        - name
        - email

    CreateUserRequest:
      type: object
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        email:
          type: string
          format: email
      required:
        - name
        - email

    Pagination:
      type: object
      properties:
        page:
          type: integer
        limit:
          type: integer
        total:
          type: integer
        totalPages:
          type: integer
```

## 📈 学习与适应

### 自适应学习
- **项目模式学习**: 学习项目的API设计模式和规范
- **技术栈适应**: 适应不同的后端技术和框架
- **团队规范学习**: 学习团队的API设计偏好和标准

### 智能建议
- **最佳实践建议**: 基于行业标准的API设计建议
- **性能优化建议**: API性能和缓存优化建议
- **安全加固建议**: API安全设计和防护建议

## 🎯 使用场景

### Web API设计
- **RESTful API**: 标准的CRUD操作API设计
- **GraphQL API**: 灵活的数据查询API设计
- **实时API**: WebSocket和SSE实时通信API

### 微服务API
- **服务间通信**: 微服务间的API设计
- **API网关**: 统一入口的API网关设计
- **服务发现**: API的自动发现和注册

### 移动端API
- **移动优化**: 移动应用友好的API设计
- **离线支持**: 离线数据同步API设计
- **版本管理**: API版本控制和兼容性管理

## 🔧 配置选项

### 基本配置
```json
{
  "api_design": {
    "enabled": true,
    "default_style": "restful",
    "documentation_format": "openapi",
    "validation_enabled": true
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "supported_styles": ["restful", "graphql", "grpc"],
    "custom_rules": [],
    "integration_tools": ["swagger", "postman", "insomnia"],
    "quality_checks": {
      "consistency": true,
      "security": true,
      "performance": true,
      "maintainability": true
    }
  }
}
```

### 规范配置
```json
{
  "standards": {
    "openapi_version": "3.0.3",
    "naming_convention": "camelCase",
    "response_format": "json-api",
    "authentication": "bearer-jwt",
    "pagination": "cursor-based",
    "error_handling": "rfc7807"
  }
}
```

## 📚 相关资源

- **API规范**: OpenAPI, JSON:API, HAL
- **设计工具**: Swagger, Postman, Insomnia
- **文档工具**: ReDoc, Swagger UI

---

**技能版本**: 1.0.0
**支持规范**: OpenAPI 3.0, GraphQL, RESTful
**验证规则**: 50+ API设计规则
**依赖**: api-designer.sh, api-validator.sh