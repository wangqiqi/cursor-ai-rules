# Skill Dispatcher 使用示例

本文档包含 Skill Dispatcher 的各种使用示例和场景。

## 目录

- [基础示例](#基础示例)
- [技能发现](#技能发现)
- [技能匹配](#技能匹配)
- [技能组合](#技能组合)
- [错误处理](#错误处理)
- [高级场景](#高级场景)

---

## 基础示例

### 示例 1: 简单技能发现

**用户输入**:
```
有哪些可用的技能？
```

**Dispatcher 响应**:
```
正在扫描 .cursor/features/skills/ 目录...

✓ 读取注册表: registry.json v2.0.0
✓ 发现 30+ 个可用技能

## 技能分类

🚀 Development (开发) - 4 个技能
🧪 Testing (测试) - 3 个技能
🔒 Security (安全) - 2 个技能
📊 Analysis (分析) - 3 个技能
⚡ Optimization (优化) - 3 个技能
📚 Documentation (文档) - 5 个技能
🤝 Collaboration (协作) - 1 个技能
🎓 Learning (学习) - 2 个技能

需要查看某个分类的详细技能列表吗？
```

### 示例 2: 直接技能调用

**用户输入**:
```
使用 backend-development 技能帮我设计一个用户管理系统
```

**Dispatcher 响应**:
```
✓ 请求技能: backend-development
✓ 检查依赖: nodejs ✓, python ✓, java ✓
✓ 读取技能: .cursor/features/skills/skills/backend-development.md
✓ 技能已加载

正在应用后端开发技能...

## 🎯 用户管理系统后端设计

### 1. 架构设计
基于 backend-development 技能的指导，推荐使用分层架构：
- Controllers (API层)
- Services (业务逻辑层)
- Repositories (数据访问层)
- Models (数据模型层)

### 2. 数据库设计
用户表结构建议：
- id (主键)
- username (唯一索引)
- email (唯一索引)
- password_hash (加密)
- created_at (索引)
- updated_at

### 3. API 端点设计
RESTful API 推荐：
- POST /api/users - 创建用户
- GET /api/users/:id - 获取用户
- PUT /api/users/:id - 更新用户
- DELETE /api/users/:id - 删除用户

[继续应用技能的完整指导...]
```

---

## 技能发现

### 示例 3: 按分类列出技能

**用户输入**:
```
列出所有测试相关的技能
```

**Dispatcher 响应**:
```
## 🧪 Testing (测试) 类技能

### ✓ api-testing (自动安装)
**描述**: 全面的API测试和验证工具
**依赖**: javascript, testing
**文件**: .cursor/features/skills/skills/api-testing.md
**功能**:
- API端点测试
- 请求/响应验证
- 性能测试
- 集成测试

### ✓ test-automation (自动安装)
**描述**: 自动化测试框架和工具
**依赖**: 无
**文件**: .cursor/features/skills/skills/test-automation.md
**功能**:
- 单元测试框架
- 测试运行器
- 测试覆盖率
- CI/CD 集成

### ○ webapp-testing (手动安装)
**描述**: 使用Playwright进行Web应用测试
**依赖**: javascript, node
**文件**: .cursor/features/skills/skills/webapp-testing.md
**功能**:
- E2E 测试
- 浏览器自动化
- 视觉回归测试

---

💡 提示: 带有 ✓ 标记的技能会自动安装使用
```

### 示例 4: 搜索特定技能

**用户输入**:
```
有没有关于 PDF 处理的技能？
```

**Dispatcher 响应**:
```
正在搜索匹配 "PDF" 的技能...

✓ 找到匹配技能: pdf

## 📄 pdf - PDF文档处理

**描述**: PDF文档处理、文本提取和表单填写
**分类**: document
**自动安装**: 否 (需要手动调用)
**依赖**: 无
**文件路径**: .cursor/features/skills/skills/pdf.md

### 主要功能
- 文本提取
- 表单填写
- 文档合并
- 页面操作
- 元数据读取

### 使用场景
- 从PDF提取数据
- 自动填写PDF表单
- 合并多个PDF文件
- 生成PDF报告

需要加载这个技能吗？
```

---

## 技能匹配

### 示例 5: 关键词匹配

**用户输入**:
```
我需要设计一个REST API
```

**Dispatcher 分析**:
```
关键词检测:
- "设计" → 匹配设计类技能
- "REST" → 匹配 API 相关技能
- "API" → 匹配 API 相关技能

最佳匹配: api-design (匹配度: 95%)

✓ 技能: api-design
✓ 分类: development
✓ 自动安装: 是
✓ 依赖: javascript, nodejs

检测项目依赖:
✓ package.json 存在
✓ node_modules/ 存在
✓ 依赖满足

正在加载 api-design 技能...
```

### 示例 6: 语义匹配

**用户输入**:
```
我的代码运行很慢，帮我优化一下
```

**Dispatcher 分析**:
```
语义分析:
- "代码运行很慢" → 性能问题
- "优化" → 需要优化工具

匹配技能:
1. performance-analysis (性能分析) - 主技能
2. optimization-tools (优化工具) - 辅助技能
3. code-analysis (代码分析) - 诊断技能

✓ 组合调用这三个技能
```

### 示例 7: 多技能匹配

**用户输入**:
```
构建一个安全的用户认证系统
```

**Dispatcher 分析**:
```
任务分解:
1. "用户认证" → backend-development, api-design
2. "安全" → security-analysis
3. "系统" → system-analysis

技能组合:
- **主技能**: backend-development (认证系统架构)
- **辅助技能**: api-design (API端点设计)
- **安全技能**: security-analysis (安全验证)
- **分析技能**: system-analysis (系统分析)

执行顺序:
1. backend-development → 设计整体架构
2. api-design → 设计认证API
3. security-analysis → 安全检查和加密
4. system-analysis → 系统集成分析

正在依次加载和应用...
```

---

## 技能组合

### 示例 8: 全栈开发流程

**用户输入**:
```
从零开始构建一个博客应用
```

**Dispatcher 响应**:
```
✓ 任务识别: 全栈开发项目
✓ 复杂度: 高

## 技能组合计划

### Phase 1: 规划和设计
🎯 **system-analysis** (系统分析)
- 分析需求
- 设计系统架构
- 规划技术栈

### Phase 2: 前端开发
🎨 **frontend-design** (前端设计)
- 设计用户界面
- 创建组件
- 实现响应式布局

### Phase 3: 后端开发
⚙️ **backend-development** (后端开发)
- 设计数据库
- 实现API
- 业务逻辑

### Phase 4: API设计
🔌 **api-design** (API设计)
- RESTful API设计
- 接口文档
- 版本控制

### Phase 5: 测试
🧪 **test-automation** (测试自动化)
- 单元测试
- 集成测试
- E2E测试

### Phase 6: 安全
🔒 **security-analysis** (安全分析)
- 代码审计
- 漏洞扫描
- 安全加固

### Phase 7: 性能优化
⚡ **optimization-tools** (优化工具)
- 性能分析
- 代码优化
- 缓存策略

正在按计划执行...

---

[Phase 1: 系统分析]
✓ system-analysis 技能已加载
正在分析博客应用需求...

[Phase 2: 前端设计]
✓ frontend-design 技能已加载
正在设计博客界面...

[继续各阶段...]
```

### 示例 9: API开发流程

**用户输入**:
```
为我的电商网站开发支付API
```

**Dispatcher 响应**:
```
✓ 任务识别: 支付API开发
✓ 敏感度: 高 (涉及支付)

## 技能组合

1. **api-design** (主技能)
   → 设计支付API端点
   → 定义请求/响应格式
   → API版本控制

2. **backend-development** (实现)
   → 实现支付逻辑
   → 集成支付网关
   → 事务处理

3. **security-analysis** (关键)
   → PCI DSS 合规检查
   → 敏感数据加密
   → 防止重放攻击

4. **api-testing** (验证)
   → 功能测试
   → 安全测试
   → 压力测试

5. **documentation-tools** (文档)
   → API文档生成
   → 集成指南
   → 错误码说明

正在应用技能组合...

---

⚠️ 特别注意: 支付API涉及金钱交易，security-analysis 技能会特别关注：
- HTTPS 强制使用
- 请求签名验证
- 敏感信息不记录日志
- 幂等性保证
- 事务完整性
```

---

## 错误处理

### 示例 10: 技能未找到

**用户输入**:
```
使用 non-existent-skill 技能
```

**Dispatcher 响应**:
```
❌ 错误: 技能未找到

请求的技能: non-existent-skill

✓ 已扫描 30 个可用技能
✓ 未找到匹配的技能

## 可能的相似技能:
- backend-development
- system-analysis
- code-analysis

需要查看完整技能列表吗？运行: ./scripts/list-skills.sh
```

### 示例 11: 依赖缺失

**用户输入**:
```
使用 webapp-testing 技能测试我的应用
```

**Dispatcher 响应**:
```
⚠️ 依赖检查失败

请求技能: webapp-testing
需要的依赖:
  ✓ javascript (已满足)
  ✗ nodejs (未检测到)

## 解决方案:

### 选项 1: 安装依赖
```bash
# 安装 Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 选项 2: 选择其他技能
你可以使用以下不依赖 nodejs 的测试技能:
- test-automation (无依赖)
- api-testing (仅需要 javascript)

### 选项 3: 继续使用（可能功能受限）
技能可能无法完全工作

选择哪个选项？
```

### 示例 12: 加载失败

**用户输入**:
```
使用某个损坏的技能
```

**Dispatcher 响应**:
```
❌ 技能加载失败

技能文件: .cursor/features/skills/some-skill.md
错误类型: Markdown 解析错误
错误详情: 第 15 行: 无效的 YAML frontmatter

## 诊断信息:
- 文件存在: ✓
- 文件可读: ✓
- 格式验证: ✗

## 建议操作:
1. 检查技能文件格式
2. 验证 YAML frontmatter 语法
3. 查看错误日志: .cursor/logs/skill-dispatcher.log
4. 使用其他可用技能

需要查看可用的替代技能吗？
```

---

## 高级场景

### 示例 13: 技能元数据查询

**用户输入**:
```
告诉我 api-design 技能的详细信息
```

**Dispatcher 响应**:
```
## 技能详细信息: api-design

### 基本信息
- **技能ID**: api-design
- **显示名称**: API设计
- **描述**: 专业的API设计能力，包括RESTful、GraphQL等
- **分类**: development
- **来源**: cursor-ai-rules

### 安装配置
- **自动安装**: 是
- **优先级**: 高
- **文件路径**: .cursor/features/skills/skills/api-design.md

### 依赖关系
需要的依赖:
- ✓ javascript (已满足)
- ✓ nodejs (已满足)

### 核心功能
1. RESTful API 设计
2. GraphQL API 开发
3. 微服务架构设计
4. API 文档生成
5. API 版本控制

### 适用场景
- 需要设计新API
- 重构现有API
- API文档生成
- API性能优化
- 微服务集成

### 相关技能
- **backend-development**: 后端实现
- **api-testing**: API测试
- **documentation-tools**: 文档生成

需要加载这个技能吗？
```

### 示例 14: 技能推荐

**用户输入**:
```
我是一个初学者，想学习全栈开发
```

**Dispatcher 响应**:
```
✓ 分析用户画像: 初学者
✓ 学习目标: 全栈开发

## 推荐学习路径

### 第一步: 基础学习
🎓 **learning-assistant** (学习助手)
- 编程基础指导
- 学习路径规划
- 问题解答

### 第二步: 代码示例
📖 **code-examples** (代码示例)
- 丰富的代码示例库
- 多种编程语言
- 最佳实践示例

### 第三步: 前端学习
🎨 **frontend-design** (前端设计)
- HTML/CSS/JavaScript
- React 框架
- 响应式设计

### 第四步: 后端学习
⚙️ **backend-development** (后端开发)
- Node.js/Python/Java
- 数据库设计
- API开发

### 第五步: 全栈实践
🚀 **fullstack-development** (全栈开发)
- 前后端集成
- 项目实战
- 部署上线

### 辅助技能
- **git-management**: 版本控制
- **test-automation**: 测试技能
- **documentation-tools**: 文档编写

建议按顺序学习这些技能。需要从哪个开始？
```

### 示例 15: 自定义工作流

**用户输入**:
```
创建一个代码审查工作流
```

**Dispatcher 响应**:
```
✓ 创建自定义工作流: Code Review Workflow

## 工作流定义

**名称**: 代码审查工作流
**目标**: 系统化的代码审查流程

### 技能流程

```
┌─────────────────────────────────────┐
│  1. code-analysis                   │
│     (代码分析 - 初步检查)            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. security-analysis               │
│     (安全分析 - 安全检查)            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  3. performance-analysis            │
│     (性能分析 - 性能检查)            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  4. refactoring-tools               │
│     (重构工具 - 改进建议)            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  5. test-automation                 │
│     (测试自动化 - 验证)              │
└─────────────────────────────────────┘
```

### 执行工作流

对以下代码执行审查：
- [ ] code-analysis ✓
- [ ] security-analysis
- [ ] performance-analysis
- [ ] refactoring-tools
- [ ] test-automation

是否开始执行此工作流？
```

---

## 总结

这些示例展示了 Skill Dispatcher 的各种使用场景：

1. **基础使用** - 简单的技能发现和调用
2. **智能匹配** - 基于关键词和语义的技能匹配
3. **技能组合** - 复杂任务的多技能协作
4. **错误处理** - 优雅的错误处理和恢复
5. **高级场景** - 自定义工作流和智能推荐

通过这些示例，你应该能够充分利用 Skill Dispatcher 来提高开发效率。

---

**文档版本**: 1.0.0  
**最后更新**: 2026-02-07
