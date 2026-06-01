# Skill Dispatcher Reference

技能调度器的详细参考文档，包含完整的技能列表、匹配规则和调用协议。

## 技能注册表解析

### Registry.json 结构

```json
{
  "version": "2.0.0",
  "skills": {
    "legacy": {
      "[skill-id]": {
        "name": "技能显示名称",
        "description": "技能描述",
        "category": "分类",
        "auto_install": boolean,
        "path": "相对路径",
        "conditions": {
          "dependencies": ["依赖列表"]
        },
        "dependencies": ["依赖列表"],
        "source": "来源"
      }
    }
  },
  "categories": {
    "[category]": ["skill-id-list"]
  }
}
```

### 完整技能列表

#### Development (开发类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| api-design | API设计 | RESTful、GraphQL等API设计 | ✅ | javascript, nodejs |
| backend-development | 后端开发 | 后端系统设计和开发指导 | ✅ | nodejs, python, java |
| fullstack-development | 全栈开发 | 前后端全栈开发指导 | ✅ | javascript, react, nodejs |
| web-artifacts-builder | Web工件构建 | React和Tailwind构建组件 | ❌ | javascript, react, node |

#### Testing (测试类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| api-testing | API测试 | API测试和验证工具 | ✅ | javascript, testing |
| test-automation | 测试自动化 | 自动化测试框架和工具 | ✅ | - |
| webapp-testing | Web应用测试 | Playwright进行Web测试 | ❌ | javascript, node |

#### Security (安全类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| security-analysis | 安全分析 | 代码安全漏洞检测和修复 | ✅ | - |
| vulnerability-scanning | 漏洞扫描 | 安全漏洞扫描和修复建议 | ✅ | - |

#### Analysis (分析类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| code-analysis | 代码分析 | 智能代码分析和质量评估 | ✅ | - |
| performance-analysis | 性能分析 | 应用性能分析和优化建议 | ✅ | - |
| system-analysis | 系统分析 | 系统架构和设计分析工具 | ✅ | - |

#### Optimization (优化类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| optimization-tools | 优化工具 | 代码和性能优化工具集 | ✅ | - |
| refactoring-tools | 重构工具 | 代码重构和架构优化工具 | ✅ | - |
| ssr-optimization | SSR优化 | 服务器端渲染优化 | ❌ | react, nextjs |

#### Documentation (文档类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| documentation-tools | 文档工具 | 文档生成和维护工具 | ✅ | - |
| docx | Word文档处理 | Word文档创建、编辑和格式化 | ❌ | - |
| pdf | PDF文档处理 | PDF文档处理、文本提取和表单 | ❌ | - |
| pptx | PowerPoint演示文稿 | 演示文稿创建、编辑和格式化 | ❌ | - |
| xlsx | Excel电子表格 | 电子表格创建、编辑和数据分析 | ❌ | - |

#### Collaboration (协作类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| git-management | Git管理 | Git版本控制和团队协作工具 | ✅ | - |

#### Learning (学习类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| code-examples | 代码示例 | 丰富的编程语言代码示例库 | ✅ | - |
| learning-assistant | 学习助手 | 编程学习和技能提升助手 | ✅ | - |

#### AI Integration (AI集成类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| mcp-builder | MCP构建器 | MCP服务器开发和集成工具 | ❌ | python, node |

#### Design (设计类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| canvas-design | 画布设计 | 基于画布的设计和图形创建 | ❌ | fonts |
| frontend-design | 前端界面设计 | 创建高质量的前端界面和组件 | ❌ | javascript, html, css |
| theme-factory | 主题工厂 | 设计主题创建和管理 | ❌ | - |

#### Creative (创意类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| algorithmic-art | 算法艺术生成 | 使用p5.js创建算法艺术 | ❌ | javascript |
| slack-gif-creator | Slack GIF创建器 | 为Slack创建动画GIF | ❌ | python |

#### Enterprise (企业类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| brand-guidelines | 品牌指南 | 应用Anthropic品牌规范 | ❌ | - |
| internal-comms | 内部通讯 | 内部通讯和消息传递 | ❌ | - |

#### Productivity (生产力类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| doc-coauthoring | 文档协作 | 文档共同创作和协作工具 | ❌ | - |

#### Debugging (调试类)

| ID | 名称 | 描述 | 自动安装 | 依赖 |
|---|------|------|---------|------|
| debug-assistant | 智能调试助手 | 使用隔离和模式分析的调试 | ❌ | bash, coreutils |

## 关键词匹配表

### API 相关

| 关键词 | 匹配技能 |
|--------|---------|
| API, 接口 | api-design, api-testing |
| REST, RESTful | api-design |
| GraphQL | api-design |
| API测试 | api-testing |

### 后端相关

| 关键词 | 匹配技能 |
|--------|---------|
| 后端, 服务端 | backend-development |
| 数据库, DB | backend-development |
| 服务器, Server | backend-development |
| 性能, 优化 | optimization-tools, performance-analysis |

### 前端相关

| 关键词 | 匹配技能 |
|--------|---------|
| 前端, 界面 | frontend-design |
| React, Vue | fullstack-development, frontend-design |
| 组件, UI | frontend-design, web-artifacts-builder |

### 测试相关

| 关键词 | 匹配技能 |
|--------|---------|
| 测试, Test | test-automation |
| 单元测试 | test-automation |
| 集成测试 | test-automation, api-testing |
| E2E测试 | webapp-testing |

### 安全相关

| 关键词 | 匹配技能 |
|--------|---------|
| 安全, Security | security-analysis |
| 漏洞, Vulnerability | vulnerability-scanning |
| 加密, Encryption | security-analysis |

### 代码质量相关

| 关键词 | 匹配技能 |
|--------|---------|
| 重构, Refactor | refactoring-tools |
| 代码分析 | code-analysis |
| 代码格式 | code-formatting |
| 性能分析 | performance-analysis |

### 文档相关

| 关键词 | 匹配技能 |
|--------|---------|
| 文档, Docs | documentation-tools |
| Word, .docx | docx |
| PDF, .pdf | pdf |
| PowerPoint, .pptx | pptx |
| Excel, .xlsx | xlsx |

### Git相关

| 关键词 | 匹配技能 |
|--------|---------|
| Git, 版本控制 | git-management |
| Commit, 提交 | git-management |
| Branch, 分支 | git-management |
| Merge, 合并 | git-management |

## 技能组合模式

### 全栈开发流程

```
fullstack-development (主)
├── frontend-design (前端界面)
├── backend-development (后端API)
├── api-design (API设计)
├── api-testing (API测试)
└── security-analysis (安全检查)
```

### API开发流程

```
api-design (主)
├── backend-development (后端实现)
├── api-testing (API测试)
├── documentation-tools (API文档)
└── security-analysis (安全验证)
```

### 性能优化流程

```
performance-analysis (主)
├── code-analysis (代码分析)
├── optimization-tools (优化实施)
├── refactoring-tools (重构)
└── test-automation (验证)
```

### 安全审查流程

```
security-analysis (主)
├── vulnerability-scanning (漏洞扫描)
├── code-analysis (代码分析)
└── git-management (版本检查)
```

### 文档创建流程

```
documentation-tools (主)
├── docx (Word文档)
├── pdf (PDF文档)
├── pptx (演示文稿)
└── xlsx (电子表格)
```

## 依赖检测规则

### JavaScript 检测

```javascript
// 检测项目是否使用 JavaScript
if (文件存在("package.json") 
    || 文件存在("*.js")
    || 文件存在("*.jsx")
    || 文件存在("*.ts")
    || 文件存在("*.tsx")) {
    return "javascript";
}
```

### Python 检测

```python
# 检测项目是否使用 Python
if 文件存在("requirements.txt") 
   or 文件存在("setup.py")
   or 文件存在("*.py"):
    return "python"
```

### Node.js 检测

```javascript
// 检测项目是否使用 Node.js
if (文件存在("package.json") 
    && 文件存在("node_modules/")) {
    return "nodejs";
}
```

### React 检测

```javascript
// 检测项目是否使用 React
if (package.json包含("react")
    || 文件存在("*.jsx")) {
    return "react";
}
```

## 技能加载优先级

```
1. auto_install: true 的技能优先
2. 依赖完全满足的技能优先
3. 核心技能优先于辅助技能
4. 分类匹配的技能优先
5. 关键词匹配度高的技能优先
```

## 错误码

| 错误码 | 描述 | 解决方案 |
|-------|------|---------|
| SKILL_NOT_FOUND | 技能文件不存在 | 检查技能路径 |
| DEPENDENCY_MISSING | 依赖未满足 | 安装依赖或选择其他技能 |
| INVALID_FORMAT | 技能格式无效 | 检查技能文件格式 |
| LOAD_FAILED | 加载失败 | 检查文件权限和内容 |
| REGISTRY_ERROR | 注册表错误 | 重新生成 registry.json |

---

**文档版本**: 1.0.0  
**最后更新**: 2026-02-07
