---
description: "团队协作规则 - 多开发者环境的最佳实践 (团队, 协作, team, collaboration, 协作开发)"
globs: ["**/*"]
alwaysApply: false
priority: 8
---

# 👥 团队协作规则

*版本: v4.3.0 | 最后更新: 2026-01-15 | 作者: wangqiqi (https://github.com/wangqiqi)*

## ⚠️ 协作原则

**MUST** 遵循以下团队协作准则：
- **MUST** 使用一致的代码风格和规范
- **NEVER** 直接推送到主分支
- **ALWAYS** 进行代码审查
- **DO NOT** 跳过测试环节
- **MUST** 及时同步和解决冲突
- **ALWAYS** 保持沟通透明

## 🎯 适用场景

- 2人以上的开发团队
- 开源项目协作
- 企业级软件开发
- 分布式团队协作

## 📋 协作流程

### Git 工作流

#### 分支策略
```
main (或 master)          # 生产就绪分支
├── develop             # 开发主分支
│   ├── feature/*       # 功能分支
│   ├── bugfix/*        # 缺陷修复分支
│   ├── hotfix/*        # 紧急修复分支
│   └── release/*       # 发布分支
```

#### 提交规范
```bash
# 格式: <type>(<scope>): <subject>
# 示例:
feat(auth): add JWT token authentication
fix(ui): resolve button alignment issue
docs(readme): update installation instructions
refactor(api): optimize database queries
test(auth): add unit tests for login function
```

#### 提交类型
- **feat**: 新功能
- **fix**: 缺陷修复
- **docs**: 文档更新
- **style**: 代码格式调整
- **refactor**: 代码重构
- **test**: 测试相关
- **chore**: 构建工具或辅助工具的变动

### 代码审查 (Code Review)

#### 审查清单
- [ ] **功能完整性**: 实现是否满足需求
- [ ] **代码质量**: 遵循编码规范和最佳实践
- [ ] **测试覆盖**: 是否有足够的测试用例
- [ ] **性能影响**: 新代码是否影响系统性能
- [ ] **安全检查**: 是否存在安全漏洞
- [ ] **文档更新**: 相关文档是否已更新

#### 审查流程
1. **创建 PR/MR**: 推送功能分支并创建合并请求
2. **初步检查**: 作者自查，运行测试套件
3. **同行审查**: 至少1-2名团队成员审查
4. **自动化检查**: CI/CD 流水线验证
5. **批准合并**: 审查通过后合并到目标分支

### 沟通规范

#### 问题跟踪
```markdown
<!-- GitHub Issue 模板 -->
## 问题描述
[清晰简洁的问题描述]

## 重现步骤
1. [第一步]
2. [第二步]
3. [第三步]

## 期望结果
[期望的正确行为]

## 实际结果
[当前的错误行为]

## 环境信息
- OS: [操作系统版本]
- Browser: [浏览器版本，如果适用]
- Version: [应用版本]

## 其他信息
[任何其他相关信息]
```

#### 会议规范
- **站会**: 15分钟，站立进行，汇报进展和障碍
- **计划会议**: 梳理需求，估算工作量
- **回顾会议**: 总结经验教训，持续改进
- **技术分享**: 定期分享技术知识和经验

## 🏗️ 项目结构

### 共享项目布局
```
project/
├── src/                    # 源代码
│   ├── components/         # 可复用组件
│   ├── pages/             # 页面组件
│   ├── services/          # 业务服务
│   ├── utils/             # 工具函数
│   └── types/             # 类型定义
├── tests/                 # 测试文件
│   ├── unit/             # 单元测试
│   ├── integration/      # 集成测试
│   └── e2e/              # 端到端测试
├── docs/                  # 项目文档
│   ├── api/              # API文档
│   ├── guides/           # 使用指南
│   └── architecture/     # 架构文档
├── scripts/               # 构建和部署脚本
├── .github/               # GitHub 配置
│   ├── workflows/        # CI/CD 工作流
│   └── ISSUE_TEMPLATE/   # Issue 模板
└── .cursor/               # AI 协作配置
```

## 📝 文档协作

### README 结构
```markdown
# 项目名称

## 📖 概述
[项目简介、目标和特色]

## 🚀 快速开始
[安装和运行指南]

## 📋 使用指南
[基本使用方法]

## 🏗️ 架构设计
[系统架构和技术选型]

## 🤝 贡献指南
[如何参与项目贡献]

## 📄 许可证
[开源许可证信息]

## 🙋‍♂️ 联系我们
[联系方式和社区信息]
```

### API 文档
- **RESTful API**: 使用 OpenAPI/Swagger 规范
- **GraphQL**: 使用 Schema Definition Language (SDL)
- **SDK**: 提供多语言 SDK 和示例代码

## 🧪 测试策略

### 测试金字塔
```
端到端测试 (E2E)     少量 (10-20%)
  ↕️
集成测试             中等 (20-30%)
  ↕️
单元测试             大量 (50-70%)
```

### 测试责任
- **开发者**: 编写单元测试，确保功能正确
- **QA 团队**: 编写集成和 E2E 测试，确保系统整体质量
- **DevOps**: 维护 CI/CD 流水线，确保测试自动化执行

## 🔒 安全协作

### 凭据管理
```bash
# 使用环境变量管理敏感信息
# .env 文件（不要提交到版本控制）
DATABASE_URL=postgresql://user:password@localhost/db
API_KEY=your-secret-api-key
JWT_SECRET=your-jwt-secret

# 在代码中使用
import os
db_url = os.getenv('DATABASE_URL')
```

### 访问控制
- **最小权限原则**: 只授予必要的访问权限
- **双人审核**: 敏感操作需要双人确认
- **审计日志**: 记录所有重要操作的日志

## 📊 度量和监控

### 团队指标
- **周期时间**: 从需求到交付的时间
- **部署频率**: 代码部署到生产环境的频率
- **变更失败率**: 部署失败的百分比
- **恢复时间**: 从故障到恢复的时间

### 代码质量指标
- **测试覆盖率**: 目标 80%+
- **技术债务**: 识别和跟踪技术债务
- **代码重复率**: 保持在合理范围内
- **圈复杂度**: 控制函数复杂度

## 🚀 持续集成/持续部署 (CI/CD)

### GitHub Actions 示例
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Run tests
      run: npm test
    - name: Build
      run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deploy to production
      run: echo "Deploying to production..."
```

## 🎯 敏捷实践

### Scrum 方法
- **用户故事**: 以用户价值为中心的需求描述
- **故事点**: 使用斐波那契数列估算复杂度
- **燃尽图**: 可视化项目进度和剩余工作
- **回顾会议**: 持续改进团队流程

### 看板方法
- **可视化工作流**: To Do → In Progress → Done
- **限制在制品**: 避免多任务并行，专注质量
- **持续改进**: 识别和消除瓶颈

## 🔧 工具链标准化

### 开发环境
- **IDE**: VS Code + 统一插件配置
- **版本管理**: Git + 统一的提交规范
- **包管理**: npm/yarn/pip 等 + 依赖锁定
- **代码规范**: ESLint + Prettier + Black

### 沟通工具
- **即时通讯**: Slack/Teams/Discord
- **问题跟踪**: GitHub Issues/Jira
- **文档协作**: Notion/Confluence/GitBook
- **视频会议**: Zoom/Google Meet

## 📈 持续改进

### 回顾会议
```markdown
## 回顾会议记录

### 👍 做得好的地方
- 代码审查流程运行良好
- 自动化测试覆盖率提升
- 团队沟通更加顺畅

### 🤔 需要改进的地方
- 部署流程可以进一步优化
- 文档更新有时会滞后
- 技术债务积累需要关注

### 🎯 改进行动
1. 优化 CI/CD 流水线，减少部署时间
2. 建立文档更新检查清单
3. 安排技术债务清理日
```

### 学习和成长
- **技术分享**: 每周技术分享会
- **培训计划**: 针对性技术培训
- **认证考试**: 鼓励获得相关技术认证
- **外部会议**: 支持参加行业会议

---

*团队协作规则应根据团队具体情况进行调整，保持灵活性和适应性。*