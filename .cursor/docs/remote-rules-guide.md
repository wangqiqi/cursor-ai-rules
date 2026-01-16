# 🌐 远程规则导入指南

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 概述

远程规则导入功能允许你从远程仓库加载和管理Cursor AI Rules规则，实现：

- **团队规则同步**: 统一团队的AI协作规范
- **规则版本管理**: 控制规则的版本和更新
- **企业标准化**: 大规模部署和维护规则
- **社区规则共享**: 使用社区贡献的规则包

## 🚀 快速开始

### 1. 初始化远程规则

```bash
# 添加远程规则源
./cursor-master.sh "add remote rules https://github.com/company/cursor-rules.git"

# 或者使用Master命令
@master add remote rules from https://github.com/company/cursor-rules.git
```

### 2. 导入规则

```bash
# 导入所有规则
./cursor-master.sh "import remote rules"

# 导入特定规则包
./cursor-master.sh "import rules package team-collaboration"

# 预览将要导入的规则
./cursor-master.sh "preview remote rules"
```

### 3. 更新规则

```bash
# 检查更新
./cursor-master.sh "check remote updates"

# 更新所有规则
./cursor-master.sh "update remote rules"

# 更新特定规则包
./cursor-master.sh "update rules package security"
```

## 📂 远程规则结构

### 规则仓库结构

```
remote-rules-repo/
├── packages/                    # 规则包目录
│   ├── team-collaboration/      # 团队协作规则包
│   │   ├── manifest.json       # 包清单
│   │   ├── rules/              # 规则文件
│   │   │   ├── code-review.md
│   │   │   ├── branch-management.md
│   │   │   └── commit-convention.md
│   │   └── config/             # 包配置
│   │       └── default.json
│   ├── security/               # 安全规则包
│   │   ├── manifest.json
│   │   ├── rules/
│   │   └── config/
│   └── devops/                 # DevOps规则包
├── templates/                   # 规则模板
├── scripts/                     # 导入脚本
└── registry.json               # 规则注册表
```

### 包清单格式

```json
// packages/team-collaboration/manifest.json
{
  "name": "team-collaboration",
  "version": "1.2.0",
  "description": "团队协作规则集合",
  "author": "Company Dev Team",
  "license": "MIT",
  "dependencies": {
    "cursor-rules": ">=4.0.0"
  },
  "rules": [
    {
      "name": "code-review",
      "path": "rules/code-review.md",
      "description": "代码审查标准",
      "alwaysApply": true
    },
    {
      "name": "branch-management",
      "path": "rules/branch-management.md",
      "description": "分支管理策略",
      "alwaysApply": true
    }
  ],
  "config": {
    "team_size": "medium",
    "workflow": "git-flow",
    "code_review_required": true
  },
  "compatibility": {
    "min_cursor_version": "0.40.0",
    "supported_languages": ["javascript", "typescript", "python"],
    "required_skills": ["git", "testing"]
  }
}
```

## ⚙️ 配置管理

### 远程源配置

```json
// .cursor/config/remote-sources.json
{
  "sources": [
    {
      "name": "company-rules",
      "url": "https://github.com/company/cursor-rules.git",
      "branch": "main",
      "auth": {
        "type": "token",
        "token_env": "GITHUB_TOKEN"
      },
      "auto_update": true,
      "update_interval_hours": 24
    },
    {
      "name": "community-rules",
      "url": "https://github.com/cursor-community/rules.git",
      "branch": "stable",
      "auth": {
        "type": "none"
      },
      "auto_update": false
    }
  ]
}
```

### 本地规则配置

```json
// .cursor/config/remote-rules.json
{
  "installed_packages": [
    {
      "name": "team-collaboration",
      "version": "1.2.0",
      "source": "company-rules",
      "install_date": "2026-01-16T10:00:00Z",
      "auto_update": true,
      "enabled_rules": [
        "code-review",
        "branch-management",
        "commit-convention"
      ]
    }
  ],
  "update_policy": {
    "auto_check": true,
    "auto_install_minor": true,
    "auto_install_major": false,
    "backup_before_update": true
  }
}
```

## 🔧 高级用法

### 创建规则包

#### 1. 初始化包结构

```bash
# 创建规则包
./cursor-master.sh "create rules package my-package"

# 生成包模板
mkdir -p packages/my-package/{rules,config,docs}
touch packages/my-package/manifest.json
```

#### 2. 编写规则

```markdown
<!-- packages/my-package/rules/my-rule.md -->
---
command: my-rule
description: "我的自定义规则"
alwaysApply: false
package: my-package
version: 1.0.0
---

# 我的规则

## 适用场景
- 项目特定需求

## 规则内容
具体规则实现...
```

#### 3. 配置包清单

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "description": "我的规则包",
  "rules": [
    {
      "name": "my-rule",
      "path": "rules/my-rule.md",
      "description": "我的自定义规则"
    }
  ]
}
```

#### 4. 发布包

```bash
# 验证包
./cursor-master.sh "validate package my-package"

# 发布到仓库
git add .
git commit -m "feat: add my-package v1.0.0"
git push origin main

# 创建发布标签
git tag "packages/my-package/v1.0.0"
git push origin --tags
```

### 企业部署

#### 大规模部署脚本

```bash
#!/bin/bash
# deploy-rules.sh

REPOS=("project1" "project2" "project3")
RULES_REPO="https://github.com/company/cursor-rules.git"

for repo in "${REPOS[@]}"; do
  echo "🚀 部署规则到 $repo..."

  cd "$repo"

  # 备份现有配置
  if [ -d ".cursor" ]; then
    cp -r .cursor .cursor.backup.$(date +%Y%m%d_%H%M%S)
  fi

  # 克隆规则仓库
  git clone "$RULES_REPO" .cursor.tmp
  cp -r .cursor.tmp/.cursor .cursor
  rm -rf .cursor.tmp

  # 初始化规则
  ./.cursor/core/init.sh

  # 导入远程规则
  ./.cursor/core/import-remote.sh

  echo "✅ $repo 规则部署完成"
  cd ..
done
```

#### 企业配置模板

```json
// config-templates/enterprise.json
{
  "company": "TechCorp",
  "rules": {
    "standard_packages": [
      "security-baseline",
      "code-quality",
      "team-collaboration"
    ],
    "custom_packages": [
      "company-standards",
      "project-specific-rules"
    ]
  },
  "compliance": {
    "required_rules": ["security-audit", "code-review"],
    "forbidden_patterns": ["console.log", "debugger"],
    "mandatory_coverage": 85
  },
  "monitoring": {
    "report_to": "devops@company.com",
    "schedule": "weekly",
    "metrics": ["rule_adoption", "compliance_rate"]
  }
}
```

### 社区规则

#### 使用社区规则

```bash
# 添加社区规则源
@master add remote rules from https://github.com/cursor-community/official-rules.git

# 浏览可用规则包
@master list remote packages

# 安装热门规则包
@master install package react-best-practices
@master install package python-dev-standards
@master install package security-hardening
```

#### 贡献社区规则

1. **Fork官方仓库**
   ```bash
   git clone https://github.com/cursor-community/official-rules.git
   cd official-rules
   git checkout -b my-contribution
   ```

2. **创建规则包**
   ```bash
   ./scripts/create-package.sh "my-awesome-rules"
   ```

3. **编写规则和测试**
   ```bash
   # 编辑规则文件
   vim packages/my-awesome-rules/rules/*.md

   # 运行测试
   npm test
   ```

4. **提交贡献**
   ```bash
   git add .
   git commit -m "feat: add my-awesome-rules package"
   git push origin my-contribution
   # 创建Pull Request
   ```

## 🔒 安全考虑

### 认证和授权

#### Token认证
```bash
# 设置GitHub Token
export GITHUB_TOKEN=your_token_here

# 配置认证
./cursor-master.sh "config remote auth github token $GITHUB_TOKEN"
```

#### SSH密钥认证
```bash
# 配置SSH
ssh-keygen -t ed25519 -C "cursor-rules@company.com"
# 添加公钥到GitHub

# 使用SSH URL
./cursor-master.sh "add remote rules git@github.com:company/cursor-rules.git"
```

### 安全扫描

#### 规则安全检查
```bash
# 扫描远程规则安全性
./cursor-master.sh "scan remote security"

# 查看安全报告
cat .cursor/security/remote-rules-audit.json
```

#### 信任管理
```json
// .cursor/config/trust.json
{
  "trusted_sources": [
    "github.com/company/*",
    "github.com/cursor-community/*"
  ],
  "blocked_sources": [
    "untrusted-site.com/*"
  ],
  "signature_required": true,
  "signature_keys": [
    "company-gpg-key-id"
  ]
}
```

## 📊 监控和管理

### 使用情况监控

```bash
# 查看规则使用统计
@master show rules usage

# 生成采用报告
@master generate adoption report

# 监控规则合规性
@master check compliance
```

### 更新管理

#### 自动更新配置
```json
// .cursor/config/auto-update.json
{
  "enabled": true,
  "schedule": "daily",
  "time": "02:00",
  "packages": {
    "security": {
      "auto_update": true,
      "update_channel": "stable"
    },
    "team-rules": {
      "auto_update": true,
      "update_channel": "latest"
    }
  },
  "backup": {
    "enabled": true,
    "retention_days": 30,
    "location": ".cursor/backups"
  }
}
```

#### 更新日志
```bash
# 查看更新历史
@master show update history

# 回滚到特定版本
@master rollback rules to v1.1.0

# 查看变更内容
@master show changes in update
```

## 🐛 故障排除

### 常见问题

**Q: 无法连接到远程仓库？**
```bash
# 检查网络连接
curl -I https://github.com

# 检查认证
./cursor-master.sh "test remote connection"

# 重新配置认证
./cursor-master.sh "reconfig remote auth"
```

**Q: 规则导入失败？**
```bash
# 检查包完整性
./cursor-master.sh "validate package <package-name>"

# 查看错误日志
cat .cursor/logs/remote-import.log

# 手动导入
./cursor-master.sh "import package <package-name> --force"
```

**Q: 规则冲突？**
```bash
# 查看冲突规则
./cursor-master.sh "check conflicts"

# 解决冲突
./cursor-master.sh "resolve conflict <rule-name> --keep local"

# 合并规则
./cursor-master.sh "merge rules <rule1> <rule2>"
```

### 调试模式

```bash
# 启用详细日志
export CURSOR_DEBUG=remote

# 运行导入调试
./cursor-master.sh "import remote rules --debug"

# 查看调试日志
tail -f .cursor/logs/remote-debug.log
```

## 📚 最佳实践

### 企业使用建议

1. **建立规则治理委员会**
   - 定义规则开发流程
   - 审核和批准新规则
   - 维护规则质量标准

2. **实施渐进式部署**
   - 从试点项目开始
   - 分阶段推广规则
   - 收集反馈持续改进

3. **建立监控体系**
   - 规则采用率统计
   - 合规性监控
   - 效果评估和改进

### 团队协作建议

1. **版本控制策略**
   - 使用语义化版本
   - 维护changelog
   - 定期发布稳定版本

2. **文档和培训**
   - 维护规则使用文档
   - 提供培训和示例
   - 建立支持渠道

3. **持续改进**
   - 定期review规则效果
   - 收集用户反馈
   - 基于数据优化规则

---

*🌐 远程规则导入让团队协作更高效标准化*
*最后更新: 2026-01-16 | 作者: wangqiqi*