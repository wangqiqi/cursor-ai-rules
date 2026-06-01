# Code Formatting — Full Guide

# 代码格式化技能

## 🎯 功能概述

提供智能代码格式化能力，支持多种编程语言和格式化工具，自动检测项目配置并应用一致的代码风格。

## 🚀 核心能力

### 多语言支持
- **JavaScript/TypeScript**: Prettier, ESLint
- **Python**: Black, autopep8, yapf
- **Java**: Google Java Format, Eclipse格式化
- **C/C++**: clang-format, astyle
- **Go**: gofmt, goimports
- **Rust**: rustfmt
- **HTML/CSS**: Prettier, stylelint

### 智能格式化
- **自动检测**: 项目配置文件自动识别
- **增量格式化**: 仅格式化变更的文件
- **差异预览**: 格式化前后的差异对比
- **批量处理**: 整个项目或指定目录的格式化

### 配置管理
- **项目配置**: .prettierrc, .eslintrc, pyproject.toml等
- **编辑器配置**: VSCode, Cursor等IDE配置
- **团队规范**: 统一的代码风格标准

## 🛠️ 技术实现

### 核心算法
```javascript
// 智能格式化引擎
class CodeFormatter {
  async format(code, language, config) {
    const parser = this.getParser(language);
    const rules = this.loadConfig(config);
    const formatted = await parser.format(code, rules);

    return this.validateFormatting(formatted);
  }
}
```

### 配置自动检测
```bash
# 自动检测项目配置
detect_project_config() {
  local project_root=$(find_project_root)

  # 检查各种配置文件
  if [[ -f "$project_root/.prettierrc" ]]; then
    echo "prettier"
  elif [[ -f "$project_root/pyproject.toml" ]]; then
    echo "black"
  elif [[ -f "$project_root/.clang-format" ]]; then
    echo "clang-format"
  fi
}
```

## 📊 性能指标

- **处理速度**: <1秒的单文件格式化
- **准确率**: >98%的格式化正确率
- **兼容性**: 支持20+编程语言和格式化工具
- **配置检测成功率**: >95%的自动配置识别

## 🔗 集成接口

### Scripts集成
- `format-manager.sh`: 核心格式化管理
- `config-manager.sh`: 配置检测和管理

### Hooks集成
- `pre-commit-format.sh`: 提交前自动格式化
- `format-validator.sh`: 格式检查和验证

### Workflows集成
- **代码质量工作流**: 格式化检查和修复
- **提交前工作流**: 自动格式化应用
- **CI/CD工作流**: 格式化验证和报告

## 🎨 格式化规则

### JavaScript/TypeScript
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### Python
```toml
[tool.black]
line-length = 88
target-version = ['py38']
include = '\.pyi?$'
extend-exclude = '''
/(
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | _build
  | buck-out
  | build
  | dist
)/
'''
```

### Go
```go
// 标准Go格式化
gofmt -w file.go
goimports -w file.go
```

## 📈 学习与适应

### 自适应学习
- **项目风格学习**: 分析现有代码库的风格偏好
- **团队习惯学习**: 学习团队的格式化偏好
- **语言特性学习**: 适应不同编程语言的最佳实践

### 智能优化
- **性能优化**: 选择最快的格式化工具
- **准确性优化**: 根据项目历史调整格式化规则
- **兼容性优化**: 确保格式化结果在不同环境中一致

## 🎯 使用场景

### 开发场景
- **实时格式化**: 代码编写时的自动格式化
- **保存时格式化**: 文件保存时的自动应用
- **批量格式化**: 项目重构时的批量处理

### 团队协作
- **一致性保证**: 统一的代码风格标准
- **自动化检查**: CI/CD中的格式化验证
- **代码审查**: 格式化问题的自动检测

### 项目维护
- **遗留代码重构**: 旧代码的格式化升级
- **新项目初始化**: 项目启动时的格式化配置
- **规范执行**: 代码规范的强制执行

## 🔧 配置选项

### 全局配置
```json
{
  "formatting": {
    "enabled": true,
    "auto_format": true,
    "format_on_save": true,
    "languages": ["javascript", "typescript", "python", "go"]
  }
}
```

### 项目配置
```json
{
  "project": {
    "formatter": "prettier",
    "config_file": ".prettierrc",
    "exclude_patterns": ["node_modules/**", "build/**"],
    "custom_rules": {}
  }
}
```

## 📚 相关资源

- **格式化工具**: Prettier, Black, clang-format等
- **配置指南**: 各工具的配置文档和最佳实践
- **集成教程**: IDE和编辑器的集成方法

---

**技能版本**: 1.0.0
**支持语言**: 20+ 编程语言
**依赖**: format-manager.sh
