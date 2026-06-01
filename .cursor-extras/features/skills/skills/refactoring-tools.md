# 代码重构工具技能

## 🎯 功能概述

提供智能代码重构能力，包括方法提取、变量重命名、类重构、架构优化等高级重构操作，支持安全的重构执行和质量保证。

## 🚀 核心能力

### 重构类型
- **方法重构**: 提取方法、内联方法、方法重命名
- **变量重构**: 变量重命名、常量提取、魔法数字处理
- **类重构**: 类提取、接口提取、继承关系调整
- **架构重构**: 包结构优化、依赖关系梳理

### 智能分析
- **代码异味检测**: 识别需要重构的代码模式
- **依赖分析**: 分析代码间的依赖关系
- **影响范围评估**: 评估重构操作的影响范围
- **风险评估**: 识别潜在的重构风险

### 安全执行
- **备份机制**: 重构前的代码备份
- **逐步执行**: 分步骤的重构执行
- **回滚支持**: 失败时的自动回滚
- **测试验证**: 重构后的自动化测试

## 🛠️ 技术实现

### 核心算法
```javascript
// 智能重构引擎
class RefactoringEngine {
  analyze(code) {
    return {
      smells: this.detectCodeSmells(code),
      opportunities: this.findRefactoringOpportunities(code),
      dependencies: this.analyzeDependencies(code)
    };
  }

  async refactor(code, refactoringType, params) {
    const plan = this.createRefactoringPlan(refactoringType, params);
    const result = await this.executeSafely(plan, code);
    return this.validateResult(result);
  }
}
```

### 代码异味检测
```bash
# 检测长方法
detect_long_methods() {
  local file="$1"
  local max_lines=30

  awk -v max="$max_lines" '
  /^func|^def|^function/ { func=$0; start=NR; line_count=0 }
  /^[[:space:]]*$/ { next }
  { line_count++ }
  /^}/||/^$/{ if(line_count > max) print func ": " line_count " lines"; line_count=0 }
  ' "$file"
}
```

## 📊 性能指标

- **分析速度**: <2秒的单文件重构分析
- **成功率**: >90%的重构操作成功率
- **安全性**: 100%的重构操作可回滚
- **准确率**: >95%的代码异味检测准确率

## 🔗 集成接口

### Scripts集成
- `refactor-manager.sh`: 核心重构管理
- `code-analyzer.sh`: 代码分析和异味检测

### Hooks集成
- `refactor-validator.sh`: 重构验证和质量检查

### Workflows集成
- **代码重构工作流**: 完整的重构分析和执行流程
- **质量提升工作流**: 持续的代码质量改进
- **技术债务管理**: 技术债务识别和偿还

## 🏗️ 重构模式

### 方法重构
```javascript
// 重构前
function processUserData(users) {
  // 验证用户数据
  for(let user of users) {
    if(!user.name || !user.email) {
      throw new Error('Invalid user data');
    }
  }

  // 保存到数据库
  for(let user of users) {
    database.save(user);
  }

  // 发送通知
  for(let user of users) {
    emailService.sendWelcome(user.email);
  }
}

// 重构后
function processUserData(users) {
  validateUsers(users);
  saveUsers(users);
  sendWelcomeEmails(users);
}

function validateUsers(users) { /* ... */ }
function saveUsers(users) { /* ... */ }
function sendWelcomeEmails(users) { /* ... */ }
```

### 类重构
```python
# 重构前: 单一职责违反
class UserManager:
    def create_user(self, data): pass
    def send_email(self, user): pass  # 不相关的职责
    def log_activity(self, action): pass  # 不相关的职责

# 重构后: 职责分离
class UserManager:
    def create_user(self, data): pass

class EmailService:
    def send_email(self, user): pass

class ActivityLogger:
    def log_activity(self, action): pass
```

## 📈 学习与适应

### 自适应学习
- **代码模式学习**: 学习项目的编码模式和风格
- **重构偏好学习**: 记住用户常用的重构操作
- **质量标准学习**: 适应项目的质量标准和规范

### 智能建议
- **重构优先级**: 基于影响范围和收益的优先级排序
- **风险评估**: 评估重构操作的潜在风险
- **最佳实践**: 推荐经过验证的重构模式

## 🎯 使用场景

### 开发场景
- **日常重构**: 方法提取、变量重命名
- **代码审查**: 重构建议和自动化修复
- **技术债务**: 识别和偿还技术债务

### 团队协作
- **代码规范**: 统一的重构标准和实践
- **知识分享**: 重构模式和最佳实践分享
- **质量提升**: 持续的代码质量改进

### 项目维护
- **遗留代码**: 旧代码的重构和现代化
- **架构优化**: 系统架构的重构和优化
- **性能提升**: 性能相关的代码重构

## 🔧 配置选项

### 基本配置
```json
{
  "refactoring": {
    "enabled": true,
    "auto_analyze": true,
    "safe_mode": true,
    "backup_before_refactor": true
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "custom_rules": [],
    "risk_assessment": "strict",
    "auto_apply_safe_refactors": true,
    "integration_testing": true
  }
}
```

### 语言特定配置
```json
{
  "languages": {
    "javascript": {
      "max_function_length": 30,
      "max_class_length": 200,
      "naming_conventions": "camelCase"
    },
    "python": {
      "max_function_length": 50,
      "max_class_length": 300,
      "naming_conventions": "snake_case"
    }
  }
}
```

## 📚 相关资源

- **重构模式**: Martin Fowler的重构书籍和模式
- **代码质量**: 代码异味和质量度量标准
- **工具集成**: IDE重构功能和自动化工具

---

**技能版本**: 1.0.0
**支持语言**: JavaScript, Python, Java, C#, Go
**依赖**: refactor-manager.sh, code-analyzer.sh