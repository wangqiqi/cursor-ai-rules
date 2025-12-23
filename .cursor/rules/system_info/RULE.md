---
description: "系统信息获取器 - 自动获取时间、路径和作者信息的通用机制"
globs: ["*.md", "*.mdc", "*.txt", "*.json", "*.yaml", "*.yml"]
alwaysApply: true
---

# 🔧 系统信息获取器 (System Information Manager)

*版本: v1.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>*

## 核心功能概述 (Core Functions)

系统信息获取器为.cursor规则系统提供统一的系统信息获取和管理机制，确保所有文档和配置都能自动获取准确的时间戳、项目路径和作者信息。

## 📅 时间获取机制 (Time Acquisition System)

### 自动时间获取
每次生成或更新文档时，自动获取当前系统本地时间：

**获取命令**：
```bash
# 标准格式时间戳
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S %Z')

# ISO 8601格式
ISO_TIME=$(date '+%Y-%m-%dT%H:%M:%S%z')

# 简短格式
SHORT_TIME=$(date '+%Y-%m-%d %H:%M')
```

### 时间格式标准
- **完整格式**: `2025-12-23 14:30:45 CST`
- **ISO格式**: `2025-12-23T14:30:45+0800`
- **日期格式**: `2025-12-23`
- **时间格式**: `14:30:45`

### 变量替换规则
在所有文档模板中使用 `{{GENERATION_TIME}}` 变量，系统会自动替换为当前时间。

## 📁 项目路径检测 (Project Path Detection)

### 自动路径识别
系统自动检测项目根目录，支持多种场景：

**Git仓库检测**：
```bash
# 获取Git仓库根目录
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# 获取当前工作目录
WORK_DIR=$(pwd)

# 获取脚本执行目录
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
```

### 路径变量系统
- `{{PROJECT_ROOT}}`: 项目根目录绝对路径
- `{{WORK_DIR}}`: 当前工作目录
- `{{SCRIPT_DIR}}`: 脚本所在目录

### 跨平台兼容性
支持Linux、macOS、Windows路径格式自动转换。

## 👤 作者信息获取 (Author Information Acquisition)

### Git配置获取
自动从Git配置获取用户信息：

```bash
# 获取作者姓名
AUTHOR_NAME=$(git config --get user.name 2>/dev/null || echo "未知作者")

# 获取作者邮箱
AUTHOR_EMAIL=$(git config --get user.email 2>/dev/null || echo "unknown@example.com")

# 获取Git用户名（备选）
GIT_USER=$(git config --get user.name 2>/dev/null || whoami)
```

### 变量替换系统
- `{{AUTHOR_NAME}}`: Git配置的用户名
- `{{AUTHOR_EMAIL}}`: Git配置的用户邮箱
- `{{GIT_USER}}`: 系统用户名（备选）

### 隐私保护
- 仅在需要时获取用户信息
- 不存储或缓存个人信息
- 支持匿名模式

## ⚙️ 配置模板系统 (Configuration Template System)

### 环境变量配置
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

### 规则配置模板
```json
{
  "time": {
    "format": "%Y-%m-%d %H:%M:%S %Z",
    "timezone": "local",
    "update_interval": "realtime"
  },
  "path": {
    "detection_method": "auto",
    "fallback_path": ".",
    "path_format": "absolute"
  },
  "author": {
    "source": "git",
    "fallback_name": "系统用户",
    "fallback_email": "user@local",
    "privacy_mode": false
  }
}
```

## 🔄 自动变量替换 (Automatic Variable Replacement)

### 文档元数据自动生成
所有文档头部自动添加标准元数据：

```markdown
*版本: v1.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>*
```

### 代码注释标准
```javascript
// Created: {{GENERATION_TIME}}
// Author: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}
// Project: {{PROJECT_ROOT}}
// Description: 功能描述
```

### 配置文件模板
```yaml
# 项目配置文件
project:
  name: "My Project"
  version: "1.0.0"
  created: "{{GENERATION_TIME}}"
  author: "{{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>"
  root_path: "{{PROJECT_ROOT}}"
```

## 🛠️ 使用方法 (Usage Instructions)

### 1. 规则激活
将 `system_info` 规则目录复制到目标项目的 `.cursor/rules/` 目录下：

```bash
# 从规则仓库复制
cp -r /path/to/rules-repo/.cursor/rules/system_info .cursor/rules/

# 或手动创建目录和文件
mkdir -p .cursor/rules/system_info
# 然后创建 RULE.md 和 config.json 文件
```

### 2. 自动生效
规则激活后，在所有支持的文件类型中：

- 使用 `{{GENERATION_TIME}}` 自动替换为当前时间
- 使用 `{{AUTHOR_NAME}}` 和 `{{AUTHOR_EMAIL}}` 自动替换为Git用户信息
- 使用 `{{PROJECT_ROOT}}` 自动替换为项目根目录

### 3. 自定义配置
如需自定义行为，创建 `.env.cursor` 文件：

```bash
# 创建环境配置文件
cat > .env.cursor << EOF
TIME_FORMAT="%Y-%m-%d %H:%M:%S %Z"
DEFAULT_AUTHOR_NAME="您的姓名"
DEFAULT_AUTHOR_EMAIL="your.email@example.com"
EOF
```

## 🔍 故障排除 (Troubleshooting)

### 时间获取失败
```bash
# 检查系统时间
date

# 检查时区设置
date '+%Z %z'

# 手动测试时间格式
date '+%Y-%m-%d %H:%M:%S %Z'
```

### Git信息获取失败
```bash
# 检查Git配置
git config --list | grep user

# 设置Git用户信息
git config --global user.name "您的姓名"
git config --global user.email "your.email@example.com"
```

### 路径检测失败
```bash
# 检查当前目录
pwd

# 检查是否为Git仓库
git rev-parse --show-toplevel 2>/dev/null || echo "不是Git仓库"

# 检查权限
ls -la
```

## 📊 性能优化 (Performance Optimization)

### 缓存机制
- 时间戳缓存：同一操作内复用时间戳
- 路径信息缓存：减少重复检测
- Git信息缓存：减少配置查询

### 异步处理
- 非阻塞式信息获取
- 并行处理多个变量替换
- 智能跳过已知信息

## 🔒 安全考虑 (Security Considerations)

### 信息泄露防护
- 不自动包含敏感路径信息
- 支持隐私模式下的匿名操作
- 过滤敏感环境变量

### 权限控制
- 遵循最小权限原则
- 不执行需要特权的系统命令
- 支持沙盒环境运行

---

*此规则为.cursor系统提供统一的系统信息获取能力，确保所有项目文档和配置的一致性和准确性。*
