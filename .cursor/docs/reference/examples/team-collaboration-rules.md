# 👥 团队规则示例

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 适用场景

这些规则示例适用于：

- **2人以上开发团队**
- **开源项目协作**
- **企业级软件开发**
- **分布式团队协作**

## 📋 团队协作规则模板

### 1. 代码审查规则

创建 `.cursor/rules/team/code-review.md`：

```markdown
---
command: code-review
description: "团队代码审查标准和流程"
alwaysApply: true
---

# 🔍 代码审查规则

## 📝 审查清单

### 功能完整性
- [ ] 代码实现需求的所有功能点
- [ ] 边界条件得到正确处理
- [ ] 错误处理机制完善

### 代码质量
- [ ] 通过所有自动化测试
- [ ] 符合项目的编码规范
- [ ] 代码复杂度在可接受范围内

### 安全性
- [ ] 无安全漏洞风险
- [ ] 输入验证充分
- [ ] 敏感数据处理安全

### 性能
- [ ] 无明显的性能问题
- [ ] 资源使用合理
- [ ] 响应时间满足要求

## 🚀 审查流程

### 提交前自查
```bash
# 运行本地检查
npm run lint
npm run test
npm run build
```

### 审查要求
- **审查者**: 至少1名资深开发者
- **审查时间**: 24小时内完成
- **通过标准**: 所有主要问题解决

### 审查反馈
- **正面反馈**: 认可好的实现
- **建设性意见**: 具体改进建议
- ** blocker**: 必须解决的问题
```

### 2. 分支管理规则

创建 `.cursor/rules/team/branch-management.md`：

```markdown
---
command: branch-management
description: "Git分支管理和合并策略"
alwaysApply: true
---

# 🌿 分支管理规则

## 📂 分支命名规范

### 功能分支
```
feature/ISSUE-123-user-authentication
feature/add-payment-integration
feature/improve-performance
```

### 修复分支
```
bugfix/BUG-456-login-error
hotfix/CRITICAL-789-security-patch
```

### 发布分支
```
release/v2.1.0
release/v2.1.1-hotfix
```

## 🔄 工作流程

### 开发流程
```bash
# 1. 从主分支创建功能分支
git checkout -b feature/ISSUE-123-new-feature main

# 2. 定期同步主分支
git pull origin main

# 3. 提交变更
git add .
git commit -m "feat: add user authentication

- Implement JWT token validation
- Add user registration endpoint
- Add login/logout functionality

Closes #123"

# 4. 推送分支
git push origin feature/ISSUE-123-new-feature
```

### 代码审查后合并
```bash
# 审查通过后合并
git checkout main
git pull origin main
git merge feature/ISSUE-123-new-feature --no-ff
git push origin main

# 删除功能分支
git branch -d feature/ISSUE-123-new-feature
git push origin --delete feature/ISSUE-123-new-feature
```

## 🛡️ 保护规则

### 主分支保护
- **需要审查**: 所有变更必须通过代码审查
- **需要测试**: 必须通过CI/CD流水线
- **禁止直接推送**: 只能通过Pull Request合并

### 发布分支保护
- **版本标签**: 合并时必须创建版本标签
- **变更日志**: 更新CHANGELOG.md
- **文档同步**: 更新相关文档
```

### 3. 提交信息规范

创建 `.cursor/rules/team/commit-convention.md`：

```markdown
---
command: commit-convention
description: "Git提交信息规范和格式要求"
alwaysApply: true
---

# 📝 提交信息规范

## 🎯 提交类型

| 类型 | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add user authentication` |
| `fix` | 修复bug | `fix: resolve login timeout issue` |
| `docs` | 文档更新 | `docs: update API documentation` |
| `style` | 代码格式 | `style: format code with prettier` |
| `refactor` | 代码重构 | `refactor: simplify user service logic` |
| `test` | 测试相关 | `test: add unit tests for auth module` |
| `chore` | 构建工具 | `chore: update dependencies` |
| `perf` | 性能优化 | `perf: optimize database queries` |
| `ci` | CI配置 | `ci: add GitHub Actions workflow` |
| `revert` | 撤销提交 | `revert: revert user auth changes` |

## 📋 提交格式

### 标准格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 示例
```
feat(auth): implement JWT token validation

- Add token generation and verification
- Implement refresh token mechanism
- Add token expiration handling

Closes #123
Breaking changes: API response format changed
```

## 📏 长度限制

- **主题行**: 最多72个字符
- **主体**: 每行最多80个字符
- **脚注**: 根据需要，无长度限制

## 🔗 关联Issue

### 自动关联
- 使用 `Closes #123` 自动关闭issue
- 使用 `Fixes #456` 关联修复的问题
- 使用 `Refs #789` 关联相关讨论

### 手动关联
```bash
# 提交时关联
git commit -m "feat: add search functionality

Implements search across all content types.
Related to discussion in #234"
```

## 🤖 自动化检查

### Pre-commit Hooks
```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_msg=$(cat $1)

# 检查提交格式
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|perf|ci|revert)(\(.+\))?: .{1,}"; then
    echo "❌ 提交信息格式不正确"
    echo "正确格式: type(scope): description"
    exit 1
fi

echo "✅ 提交信息格式正确"
```

### CI/CD检查
```yaml
# .github/workflows/commit-check.yml
name: Commit Message Check
on: [pull_request]

jobs:
  check-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check commit messages
        run: |
          # 检查所有提交信息
          git log --oneline ${{ github.event.pull_request.head.sha }} ^${{ github.event.pull_request.base.sha }} | while read commit; do
            if ! echo "$commit" | grep -qE "^[a-f0-9]+ (feat|fix|docs|style|refactor|test|chore|perf|ci|revert)"; then
              echo "❌ Invalid commit message: $commit"
              exit 1
            fi
          done
          echo "✅ All commit messages are valid"
```
```

### 4. 文档维护规则

创建 `.cursor/rules/team/documentation.md`：

```markdown
---
command: documentation
description: "团队文档维护和更新规范"
alwaysApply: true
---

# 📚 文档维护规则

## 🎯 文档类型

### 代码文档
- **README.md**: 项目概述和快速开始
- **API文档**: 接口说明和使用示例
- **架构文档**: 系统设计和组件关系
- **部署文档**: 环境配置和发布流程

### 团队文档
- **开发规范**: 编码标准和最佳实践
- **工作流程**: 开发和发布流程
- **会议记录**: 重要决策和技术讨论
- **培训资料**: 新成员 onboarding

## 📝 更新时机

### 代码变更时
```markdown
# 新功能开发
- 更新README中的功能说明
- 添加API文档
- 更新CHANGELOG.md

# 重构或重大变更
- 更新架构文档
- 通知团队成员
- 更新相关文档链接
```

### 发布前
```markdown
# 版本发布前检查清单
- [ ] README.md更新到最新版本
- [ ] CHANGELOG.md记录所有变更
- [ ] API文档与代码同步
- [ ] 部署文档测试验证
```

## 🔍 文档质量标准

### 内容完整性
- [ ] 包含所有必要信息
- [ ] 步骤清晰可操作
- [ ] 示例代码正确可运行
- [ ] 常见问题得到解答

### 格式规范
- [ ] 使用Markdown格式
- [ ] 结构清晰，层次分明
- [ ] 图片和图表合适
- [ ] 链接有效可用

### 维护及时性
- [ ] 文档与代码同步
- [ ] 定期review和更新
- [ ] 标记过时内容
- [ ] 版本信息准确

## 🤝 协作流程

### 文档审查
```markdown
# 文档PR审查清单
- [ ] 内容准确完整
- [ ] 格式规范统一
- [ ] 拼写语法正确
- [ ] 示例代码可运行
- [ ] 链接有效可用
```

### 文档负责人
- **技术文档**: 架构师或资深开发者
- **用户文档**: 产品经理
- **API文档**: 后端开发者
- **部署文档**: DevOps工程师

## 🛠️ 工具推荐

### 文档工具
- **MkDocs**: 静态站点生成
- **Docusaurus**: React文档站点
- **GitBook**: 协作文档平台
- **Swagger/OpenAPI**: API文档

### 协作工具
- **GitHub Wiki**: 简单文档协作
- **Notion**: 团队知识库
- **Confluence**: 企业文档管理
- **Google Docs**: 实时协作编辑

### 质量检查
```bash
# 链接检查
npm install -g markdown-link-check
find docs/ -name "*.md" -exec markdown-link-check {} \;

# 拼写检查
npm install -g markdown-spellcheck
find docs/ -name "*.md" -exec markdown-spellcheck {} \;
```
```

### 5. 测试策略规则

创建 `.cursor/rules/team/testing-strategy.md`：

```markdown
---
command: testing-strategy
description: "团队测试策略和质量保障标准"
alwaysApply: true
---

# 🧪 测试策略

## 🎯 测试金字塔

```
           E2E Tests (端到端测试)
                 │
        Integration Tests (集成测试)
                 │
       Unit Tests (单元测试)
                 │
         Code (代码)
```

## 📊 测试覆盖率要求

### 单元测试
- **核心业务逻辑**: ≥90%
- **工具函数**: ≥80%
- **UI组件**: ≥70%
- **配置文件**: ≥50%

### 集成测试
- **API接口**: 100%
- **数据库操作**: 100%
- **第三方集成**: ≥80%

### 端到端测试
- **关键用户流程**: ≥90%
- **常见使用场景**: ≥70%

## 🏃 测试类型

### 单元测试
```javascript
// userService.test.js
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // 测试实现
    });

    it('should throw error for invalid email', async () => {
      // 测试实现
    });
  });
});
```

### 集成测试
```javascript
// userAPI.integration.test.js
describe('User API Integration', () => {
  beforeAll(async () => {
    // 启动测试数据库
    // 初始化测试数据
  });

  describe('POST /users', () => {
    it('should create user and return user data', async () => {
      // API集成测试
    });
  });
});
```

### 端到端测试
```javascript
// userRegistration.e2e.test.js
describe('User Registration Flow', () => {
  it('should allow user to register and login', async () => {
    // 完整用户流程测试
    await page.goto('/register');
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="register-button"]');

    await page.waitForSelector('[data-testid="success-message"]');
    expect(await page.textContent('[data-testid="success-message"]'))
      .toContain('Registration successful');
  });
});
```

## 🚀 测试流程

### 开发阶段
```bash
# TDD开发流程
1. 编写失败的测试
npm run test:watch

2. 实现代码使测试通过
npm run test

3. 重构代码
npm run test

4. 提交代码
git commit -m "feat: implement user registration"
```

### 提交前检查
```bash
# 运行所有测试
npm run test:all

# 检查覆盖率
npm run test:coverage

# 运行lint检查
npm run lint
```

### CI/CD集成
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm run test:ci
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 📈 质量指标

### 测试通过率
- **单元测试**: ≥95%
- **集成测试**: ≥90%
- **E2E测试**: ≥85%

### 性能基准
- **测试执行时间**: <5分钟
- **内存使用**: <500MB
- **磁盘使用**: <1GB

### 维护指标
- **测试代码占比**: ≥30%
- **测试用例数量**: 随代码增长
- **废弃测试清理**: 定期review

## 👥 责任分配

### 开发者责任
- 编写单元测试
- 确保测试通过
- 维护测试质量

### QA工程师责任
- 编写集成测试
- 编写E2E测试
- 执行探索性测试

### 技术负责人责任
- 制定测试策略
- 监控测试覆盖率
- 确保测试基础设施

## 🛠️ 测试工具

### 单元测试框架
- **Jest**: JavaScript测试框架
- **Vitest**: 快速的单元测试
- **pytest**: Python测试框架
- **JUnit**: Java测试框架

### 测试工具
- **Playwright**: 端到端测试
- **Cypress**: Web应用测试
- **Selenium**: 浏览器自动化
- **Postman/Newman**: API测试

### 覆盖率工具
- **Istanbul/nyc**: JavaScript覆盖率
- **coverage.py**: Python覆盖率
- **JaCoCo**: Java覆盖率
```

## 📋 团队配置示例

### 小型团队配置

```json
// .cursor/config/project.json
{
  "team": {
    "size": "small",
    "workflow": "agile",
    "code_review": {
      "required_reviews": 1,
      "auto_merge": false
    },
    "testing": {
      "unit_test_coverage": 80,
      "integration_required": false,
      "e2e_required": false
    }
  }
}
```

### 中型团队配置

```json
// .cursor/config/project.json
{
  "team": {
    "size": "medium",
    "workflow": "scrum",
    "code_review": {
      "required_reviews": 2,
      "auto_merge": false
    },
    "testing": {
      "unit_test_coverage": 90,
      "integration_required": true,
      "e2e_required": false
    }
  }
}
```

### 大型团队配置

```json
// .cursor/config/project.json
{
  "team": {
    "size": "large",
    "workflow": "scaled_agile",
    "code_review": {
      "required_reviews": 3,
      "auto_merge": false
    },
    "testing": {
      "unit_test_coverage": 95,
      "integration_required": true,
      "e2e_required": true
    }
  }
}
```

## 🎯 最佳实践

### 持续改进
- **定期review测试策略**
- **分析测试失败模式**
- **优化测试执行时间**
- **更新测试用例覆盖新功能**

### 团队协作
- **测试知识分享**
- **结对编程测试编写**
- **测试review纳入流程**
- **测试失败及时沟通**

### 工具自动化
- **测试用例自动生成**
- **测试报告自动化**
- **测试环境自动化部署**
- **测试结果集成通知**

---

*👥 团队协作规则让多人开发更有序高效*
*最后更新: 2026-01-16 | 作者: wangqiqi*