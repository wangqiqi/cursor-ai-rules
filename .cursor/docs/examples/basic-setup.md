# 🏗️ 基础设置示例

本指南将帮助你快速设置和配置 Cursor AI Rules，实现智能的 AI 协作环境。

## 📋 前置条件

- Cursor 编辑器 (v0.40+)
- Git (推荐，用于版本控制)
- Bash shell 环境
- 网络连接 (用于下载依赖)

## 🚀 快速开始

### 步骤1: 获取 Cursor AI Rules

```bash
# 方法1: 从GitHub克隆
git clone https://github.com/your-repo/cursor-ai-rules.git
cd cursor-ai-rules

# 方法2: 下载Release包
# 从GitHub Releases下载最新版本
wget https://github.com/your-repo/cursor-ai-rules/releases/latest/download/cursor-ai-rules.zip
unzip cursor-ai-rules.zip
cd cursor-ai-rules
```

### 步骤2: 部署到项目

```bash
# 假设你的项目在 /path/to/your-project
YOUR_PROJECT="/path/to/your-project"

# 复制.cursor目录到你的项目
cp -r .cursor "$YOUR_PROJECT/"

# 进入项目目录
cd "$YOUR_PROJECT"
```

### 步骤3: 初始化系统

```bash
# 运行自适应初始化
.cursor/bootstrap/init.sh

# 这将自动：
# 1. 检测你的项目环境
# 2. 识别技术栈和工具
# 3. 生成项目配置
# 4. 激活相关规则
# 5. 安装适配技能
```

### 步骤4: 验证安装

```bash
# 检查系统状态
.cursor/automation/scripts/env-check.sh

# 查看激活的配置
ls .cursor/rules/        # 查看激活的规则
ls .cursor/skills/active/ # 查看激活的技能
```

## ⚙️ 项目配置示例

### Node.js + React 项目

**项目结构**:
```
my-react-app/
├── package.json
├── src/
│   ├── App.js
│   ├── components/
│   └── utils/
├── public/
└── .cursor/          # Cursor AI Rules 配置
```

**初始化输出示例**:
```
🚀 Cursor AI Rules - 自适应初始化器
===================================
🎯 智能检测项目环境，自动配置AI协作规则

🔍 检测项目环境...
  🛠️  技术栈检测...
    ✅ 检测到技术栈: node,react,typescript
  👥 团队规模: 个人开发
  📊 项目成熟度: 开发阶段 (分数: 4/8)

⚙️ 生成项目配置...
✅ 项目配置已生成: .cursor/config/project.json

📋 激活项目规则...
✅ 已激活 8 个规则

🎯 安装适配技能...
✅ 已安装 5 个技能
```

**生成的配置**:
```json
// .cursor/config/project.json
{
  "generated_at": "2024-01-15T14:30:00+08:00",
  "project": {
    "name": "my-react-app",
    "tech_stack": "node,react,typescript",
    "team_size": "personal",
    "maturity": "development"
  },
  "features": {
    "skills": {
      "installed": ["nodejs", "react", "typescript", "testing"],
      "available": ["vue", "angular", "docker", "ci-cd"]
    },
    "rules": {
      "activated": ["javascript.md", "react.md", "typescript.md", "testing.md"]
    }
  }
}
```

### Python + Django 项目

**项目结构**:
```
django-blog/
├── manage.py
├── requirements.txt
├── blog/
│   ├── models.py
│   ├── views.py
│   └── templates/
├── static/
└── .cursor/
```

**初始化输出**:
```
🔍 检测项目环境...
  🛠️  技术栈检测...
    ✅ 检测到技术栈: python,django
  👥 团队规模: 团队协作
  📊 项目成熟度: 开发阶段 (分数: 5/8)

📋 激活项目规则...
✅ 已激活 6 个规则
- python.md
- django.md
- collaboration.md
- testing.md

🎯 安装适配技能...
✅ 已安装 4 个技能
- python
- django
- testing
- collaboration
```

### Go + Gin 项目

**项目结构**:
```
go-api/
├── go.mod
├── main.go
├── handlers/
├── models/
├── middleware/
└── .cursor/
```

**配置特点**:
- 激活 Go 开发规则
- 启用微服务架构指导
- 配置测试和文档生成

## 🎨 自定义配置

### 修改全局设置

编辑 `.cursor/config/overrides.json`:

```json
{
  "overrides": {
    "system": {
      "log_level": "debug",
      "auto_update": false
    },
    "features": {
      "automation": {
        "scheduling": true
      },
      "intelligence": {
        "prediction": true
      }
    },
    "performance": {
      "max_memory_mb": 1024,
      "cache_enabled": true
    }
  },
  "disabled": {
    "skills": ["unused-skill"],
    "hooks": ["performance-monitor"]
  }
}
```

### 添加自定义规则

```bash
# 创建自定义规则
cat > .cursor/rules/custom/my-rule.md << 'EOF'
---
command: my-rule
description: "我的自定义规则"
alwaysApply: false
---

# 🎯 我的自定义规则

## 适用场景
- 当需要应用特定团队规范时

## 指导原则
1. 使用统一的命名约定
2. 遵循既定的代码结构
3. 包含必要的文档
EOF

# 重新初始化以激活新规则
.cursor/bootstrap/init.sh
```

### 手动安装技能

```bash
# 查看可用技能
.cursor/automation/scripts/skill-list.sh

# 安装特定技能
.cursor/automation/scripts/skill-install.sh docker
.cursor/automation/scripts/skill-install.sh kubernetes

# 验证安装
ls .cursor/skills/active/
```

## 🔧 高级配置

### 多环境支持

为不同环境创建专门配置：

```bash
# 开发环境配置
cp .cursor/config/project.json .cursor/config/project.dev.json

# 生产环境配置
cp .cursor/config/project.json .cursor/config/project.prod.json

# 编辑生产环境配置，启用更多安全检查
# project.prod.json 中设置：
# "security": { "audit_logging": true, "data_encryption": true }
```

### CI/CD 集成

在 CI/CD 流水线中使用：

```yaml
# .github/workflows/ci.yml
name: CI/CD

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Setup Cursor AI Rules
      run: |
        .cursor/bootstrap/init.sh

    - name: Run AI-enhanced tests
      run: |
        npm test
        # AI 会自动应用测试相关规则和技能

    - name: AI code review
      run: |
        .cursor/automation/scripts/code-review.sh
```

### Docker 集成

```dockerfile
# Dockerfile
FROM node:18-alpine

# 复制项目文件
COPY . .

# 设置 Cursor AI Rules
RUN .cursor/bootstrap/init.sh

# AI 会根据Docker环境自动调整配置
# - 启用容器化相关技能
# - 配置适合容器环境的规则
# - 优化资源使用

CMD ["npm", "start"]
```

## 📊 监控和维护

### 查看系统状态

```bash
# 环境健康检查
.cursor/automation/scripts/env-check.sh

# 技能状态检查
.cursor/automation/scripts/skill-status.sh

# 配置验证
.cursor/config/merge-config.sh
cat .cursor/config/merged.json | jq .metadata
```

### 日志管理

```bash
# 查看系统日志
ls .cursor/logs/

# 监控钩子执行
tail -f .cursor/logs/hooks/*.log

# 分析技能使用
cat .cursor/logs/skill-usage.json | jq .
```

### 定期维护

```bash
# 每周执行的维护任务
.cursor/automation/scripts/maintenance.sh

# 清理缓存和临时文件
.cursor/automation/scripts/cleanup.sh

# 更新技能和规则
.cursor/automation/scripts/update.sh
```

## 🐛 故障排除

### 初始化失败

```bash
# 检查权限
ls -la .cursor/
chmod +x .cursor/bootstrap/*.sh
chmod +x .cursor/automation/scripts/*.sh

# 重新检测环境
.cursor/bootstrap/detect.sh

# 检查日志
tail -f .cursor/logs/init.log
```

### 技能安装问题

```bash
# 强制重新安装
.cursor/automation/scripts/skill-install.sh --force nodejs

# 检查网络连接
curl -I https://api.github.com

# 手动清理并重新安装
rm -rf .cursor/skills/active/
.cursor/bootstrap/init.sh
```

### 配置冲突

```bash
# 重置配置
rm .cursor/config/project.json
.cursor/bootstrap/init.sh

# 检查配置合并
.cursor/config/merge-config.sh
```

## 🎯 最佳实践

### 项目结构建议

1. **保持 .cursor 目录清洁**: 不要修改自动生成的文件
2. **使用 overrides.json 自定义**: 通过覆盖配置实现个性化
3. **定期更新**: 保持 Cursor AI Rules 为最新版本
4. **团队共享配置**: 将 overrides.json 纳入版本控制

### 协作建议

1. **团队配置统一**: 团队成员使用相同的 overrides.json
2. **分支策略**: 为不同环境维护独立的配置分支
3. **文档同步**: 保持项目文档与 AI 配置同步
4. **定期审查**: 定期审查和优化 AI 协作配置

---

*此示例基于 Cursor AI Rules v4.2.0 | 最后更新: 2024-01-15*