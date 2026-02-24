---
description: "系统信息获取器 - 自动获取时间、路径和作者信息的通用机制"
globs: ["**/*.md", "**/*.mdc", "**/*.txt"]
alwaysApply: false
priority: 20
---

# 🔧 系统信息获取器 (System Information Manager)

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## ⚠️ 使用原则

**MUST** 遵循以下系统信息获取准则：
- **MUST** 使用 `{{GENERATION_TIME}}` 作为时间戳占位符
- **NEVER** 硬编码作者信息或时间戳
- **ALWAYS** 通过 `platform_adapter` 获取系统信息
- **DO NOT** 直接依赖操作系统特定命令
- **MUST** 确保路径格式的跨平台兼容性

## 核心功能概述 (Core Functions)

系统信息获取器为.cursor规则系统提供统一的时间戳、路径信息和作者信息管理，确保文档的可追溯性和规范化。

### 自动变量替换
系统自动为文档添加时间戳、作者信息和项目路径，确保内容的可追溯性。

## 🔧 跨平台适配 (Cross-platform Adaptation)

系统信息获取器依赖 `@platform_adapter` 规则提供跨平台兼容性：

### 核心适配功能 (Core Adaptation Features)
- **命令执行**：通过platform_adapter统一执行跨平台命令
- **路径处理**：自动处理不同操作系统的路径格式差异
- **环境变量**：统一访问平台特定的环境变量
- **错误处理**：平台特定的错误信息和恢复策略

### 集成方式 (Integration Method)
```typescript
// 通过platform_adapter获取系统信息
const adapter = PlatformAdapterFactory.create();

const timestamp = await adapter.executeCommand('get_timestamp');
const userName = await adapter.executeCommand('get_user_name');
const userEmail = await adapter.executeCommand('get_user_email');
const projectRoot = await adapter.normalizePath(
  await adapter.executeCommand('get_project_root')
);
```

### 语言环境检测 (Locale Detection)
系统语言环境检测已集成到 `@i18n` 规则中，提供智能的多语言支持和自动语言切换功能。

## 📚 详细使用指南 (Detailed Usage Guide)

### 支持的变量模板 (Supported Variable Templates)

系统信息获取器支持以下变量自动替换：

| 变量                  | 说明         | 示例                      |
| --------------------- | ------------ | ------------------------- |
| `{{GENERATION_TIME}}` | 当前系统时间 | `2025-12-23 09:38:58 CST` |
| `{{AUTHOR_NAME}}`     | Git用户名    | `your.name`               |
| `{{AUTHOR_EMAIL}}`    | Git用户邮箱  | `user@example.com`        |
| `{{PROJECT_ROOT}}`    | 项目根目录   | 运行时替换为实际路径      |
| `{{WORK_DIR}}`        | 当前工作目录 | 运行时替换为实际路径      |

### 模板使用示例 (Template Usage Examples)

```markdown
# 文档模板示例
*版本: v3.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}}*

项目根目录: {{PROJECT_ROOT}}
工作目录: {{WORK_DIR}}
```

### 自定义配置 (Custom Configuration)

创建 `.env.cursor` 文件进行自定义配置：

```bash
# 时间格式配置
TIME_FORMAT="%Y-%m-%d %H:%M:%S %Z"
TIMEZONE="Asia/Shanghai"

# 默认作者信息（当Git不可用时）
DEFAULT_AUTHOR_NAME="项目维护者"
DEFAULT_AUTHOR_EMAIL="maintainer@project.com"

# 项目路径配置
PROJECT_TYPE="git"  # git|workspace|custom
CUSTOM_ROOT_PATH="/path/to/project"
```

### 兼容性说明 (Compatibility Notes)

- **操作系统**: Linux, macOS, Windows
- **Shell**: Bash, Zsh, Fish
- **Git版本**: 2.0+
- **文件类型**: .md, .mdc, .txt, .json, .yaml, .yml

### 故障排除 (Troubleshooting)

#### 时间获取失败
```bash
# 检查系统时间
date

# 检查时区设置
date '+%Z %z'
```

#### Git信息获取失败
```bash
# 检查Git配置
git config --list | grep user

# 设置Git用户信息
git config --global user.name "您的姓名"
git config --global user.email "your.email@example.com"
```

#### 路径检测失败
```bash
# 检查是否为Git仓库
git rev-parse --show-toplevel 2>/dev/null || echo "不是Git仓库"
```

---

*系统信息获取器为.cursor规则体系提供统一的信息获取接口，确保跨平台和多语言环境下的稳定运行。*

