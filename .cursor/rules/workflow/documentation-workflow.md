---
description: "文档生成工作流 - 自动化生成项目文档和API文档 (文档, documentation, readme, api doc, docs)"
globs: ["**/*"]
alwaysApply: false
priority: 8
---

# 📚 文档生成工作流 (Documentation Workflow)

*版本: v1.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 核心功能

自动生成和维护项目文档，包括README、API文档、使用指南等。

### ⚠️ 执行原则

**MUST** 遵循以下文档生成原则：
- **MUST** 在代码变更时同步更新文档
- **NEVER** 让文档与代码实现不一致
- **ALWAYS** 包含实际可运行的代码示例
- **MUST** 确保所有链接和引用有效
- **DO NOT** 生成无注释或说明的代码片段

### 📝 文档类型支持

#### README生成
```markdown
# 自动生成项目README
@master 生成项目文档

# 包含以下内容：
- 项目简介
- 安装说明
- 使用方法
- API文档
- 贡献指南
```

#### API文档生成
```bash
# 从代码注释生成API文档
@master 生成API文档

# 支持格式：
- JSDoc
- TypeScript类型定义
- RESTful API规范
```

#### 使用指南生成
```bash
# 生成用户使用指南
@master 创建使用教程

# 包含：
- 快速开始
- 详细配置
- 最佳实践
- 故障排除
```

## 🔄 工作流程

### 1. 文档分析
- 分析项目结构
- 识别代码中的文档标记
- 确定文档生成策略

### 2. 内容生成
- 基于代码生成API文档
- 创建使用示例
- 编写配置说明

### 3. 文档组织
- 整理文档结构
- 创建目录索引
- 建立文档导航

### 4. 质量检查
- 检查文档完整性
- 验证链接有效性
- 确保格式一致性

## 🛠️ 支持的工具

### 文档生成器
- **JSDoc**: JavaScript文档生成
- **TypeDoc**: TypeScript文档生成
- **Sphinx**: Python文档生成
- **Doxygen**: C/C++文档生成

### 格式转换
- **Markdown**: 通用文档格式
- **HTML**: Web文档格式
- **PDF**: 打印文档格式
- **JSON**: API文档格式

## 📋 使用场景

### 新项目初始化
```
项目创建时自动生成：
- 项目README
- 开发环境配置文档
- 部署指南
```

### 代码变更时
```
代码更新时自动更新：
- API文档同步
- 使用示例更新
- 变更日志维护
```

### 发布前
```
发布前自动生成：
- 用户手册
- 部署文档
- 版本说明
```

## ⚙️ 配置选项

### 文档模板
```json
{
  "documentation": {
    "templates": {
      "readme": "custom-readme.md",
      "api": "api-template.md",
      "changelog": "changelog-template.md"
    },
    "auto_update": true,
    "include_examples": true,
    "generate_pdf": false
  }
}
```

### 生成规则
- **触发条件**: 代码提交、版本发布、文档更新
- **输出格式**: Markdown、HTML、PDF
- **包含内容**: API、配置、示例、故障排除

---

*📚 文档生成工作流 - 让文档与代码同步更新*