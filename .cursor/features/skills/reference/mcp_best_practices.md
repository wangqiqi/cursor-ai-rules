# 📋 MCP Best Practices (本地化)

*基于 Model Context Protocol 官方文档 | 下载时间: 2026-01-16*

## 核心准则

### 服务器和工具命名规范

**命名约定**:
- 使用描述性名称，避免缩写
- 遵循 `kebab-case` 或 `snake_case` 格式
- 名称应该反映工具的功能

**示例**:
```typescript
// ✅ 好的命名
server.setName("github-repo-manager");
server.setName("database_query_tool");

// ❌ 不好的命名
server.setName("gr");
server.setName("dbtool");
```

### 响应格式指南

**JSON vs Markdown**:
- **JSON**: 结构化数据、API响应、表格数据
- **Markdown**: 文本内容、文档、说明性内容
- **混合**: 复杂内容可以结合使用

**最佳实践**:
```typescript
// JSON响应 - 结构化数据
{
  "status": "success",
  "data": {
    "repositories": [
      {"name": "repo1", "stars": 150},
      {"name": "repo2", "stars": 89}
    ]
  }
}

// Markdown响应 - 说明性内容
## Repository Analysis
- **Total repositories**: 2
- **Average stars**: 119.5
- **Most popular**: repo1 (150 ⭐)
```

### 分页最佳实践

**何时使用分页**:
- 结果集超过50个项目
- API响应可能很大
- 用户可能只需要前几个结果

**实现方式**:
```typescript
// 支持分页的工具
{
  "name": "search_repositories",
  "parameters": {
    "query": "string",
    "limit": "number?",  // 默认值: 10
    "offset": "number?"  // 默认值: 0
  }
}
```

### 传输选择

**Streamable HTTP vs Stdio**:
- **Streamable HTTP**: 远程服务器、需要扩展、复杂应用
- **Stdio**: 本地工具、简单脚本、快速原型

**选择标准**:
- 远程部署 → Streamable HTTP
- 本地工具 → Stdio
- 复杂应用 → Streamable HTTP
- 简单脚本 → Stdio

### 安全和错误处理标准

**安全考虑**:
- 验证所有输入参数
- 避免命令注入
- 使用参数化查询
- 限制资源访问

**错误处理**:
```typescript
// 统一的错误响应格式
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid repository name format",
    "details": {
      "field": "repoName",
      "expected": "owner/repo",
      "provided": "invalid-format"
    }
  }
}
```

## 工具设计原则

### 单一职责
每个工具应该只做一件事，并做好这件事。

**示例**:
```typescript
// ✅ 好的设计 - 单一职责
server.registerTool("get_repo_info", {...});
server.registerTool("list_repo_issues", {...});
server.registerTool("create_repo_issue", {...});

// ❌ 不好的设计 - 多重职责
server.registerTool("repo_manager", {...}); // 试图做所有事情
```

### 参数验证
- 所有参数都应该有明确的类型定义
- 提供合理的默认值
- 包含参数描述

**示例**:
```typescript
{
  "parameters": {
    "repoName": {
      "type": "string",
      "description": "Repository name in format 'owner/repo'",
      "pattern": "^[^/]+/[^/]+$"
    },
    "limit": {
      "type": "number",
      "description": "Maximum number of results to return",
      "default": 10,
      "minimum": 1,
      "maximum": 100
    }
  }
}
```

### 响应一致性
- 使用统一的响应格式
- 包含必要的元数据
- 提供有意义的错误信息

## 性能优化

### 缓存策略
- 对频繁访问的数据实施缓存
- 设置合理的缓存过期时间
- 提供缓存失效机制

### 资源管理
- 限制并发请求数量
- 实施超时机制
- 监控资源使用情况

### 错误恢复
- 实现重试机制
- 提供降级方案
- 记录错误信息用于调试

## 测试和质量保证

### 单元测试
- 测试所有工具功能
- 验证参数验证逻辑
- 检查错误处理流程

### 集成测试
- 测试端到端工作流程
- 验证与MCP客户端的兼容性
- 性能和负载测试

### 文档更新
- 保持API文档同步
- 记录已知问题和解决方案
- 提供使用示例

---

*此文档基于 Model Context Protocol 官方最佳实践指南创建，提供MCP服务器开发的核心准则和规范。*