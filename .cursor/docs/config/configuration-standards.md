# 🔧 配置规范标准

*版本: v1.0.0 | 最后更新: 2026-01-16 | 作者: wangqiqi*

## 📋 概述

Cursor AI Rules系统采用多层配置架构，确保配置的一致性、可维护性和可扩展性。本文档定义了系统中各种配置文件的标准格式和规范。

## 🎯 配置层级架构

```
全局配置 (global/)
├── 系统默认配置 (system-defaults.json)
├── 全局配置 (global.json)
└── 智能进化配置 (intelligent_evolution.config.json)

项目配置 (project/)
├── 项目配置 (project.json.template)
└── 覆盖配置 (overrides.json)

组件配置 (component/)
├── 能力映射 (capability-map.json)
├── 钩子配置 (hooks.json)
├── 调试配置 (debug-config.json)
├── 质量配置 (config/ - eslint, prettier)
└── 安全配置 (audit/security-config.json)
```

## 📝 配置格式规范

### 1. Frontmatter格式 (Rules & Skills)

**适用文件**: `rules/**/*.md`, `features/skills/*.md`

```yaml
---
command: rule_name                    # 必需: 命令标识符
description: "规则描述"               # 必需: 功能描述
globs: ["*.js", "*.ts"]              # 可选: 文件匹配模式
alwaysApply: true                     # 可选: 是否始终应用 (默认: false)
version: "1.0.0"                     # 可选: 版本号
priority: 100                        # 可选: 执行优先级 (1-1000)
tags: ["javascript", "quality"]      # 可选: 标签分类
dependencies: ["other_rule"]         # 可选: 依赖关系
---

# 规则内容 (Markdown格式)
```

### 2. JSON配置格式 (系统配置)

**适用文件**: `config/*.json`

```json
{
  "$schema": "../config/schema-file.json",  // 可选: JSON Schema引用
  "version": "1.0.0",                         // 必需: 配置版本
  "description": "配置描述",                  // 必需: 功能描述
  "metadata": {                              // 可选: 元数据
    "created_at": "2026-01-16T10:00:00Z",
    "last_updated": "2026-01-16T10:00:00Z",
    "author": "wangqiqi"
  },
  "config": {                                // 必需: 配置内容
    // 具体配置项
  },
  "validation": {                            // 可选: 验证规则
    "required_fields": ["field1", "field2"],
    "field_types": {
      "field1": "string",
      "field2": "number"
    }
  }
}
```

### 3. Shell脚本配置格式

**适用文件**: `core/*.sh`, `features/hooks/*.sh`

```bash
#!/bin/bash
# 🔧 脚本标题
# 描述: 脚本功能描述
# 版本: v1.0.0
# 作者: wangqiqi
# 依赖: dependency1.sh, dependency2.sh

set -e  # 错误退出
set -u  # 未定义变量检查
set -o pipefail  # 管道错误检查

# 常量定义 (大写)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly CONFIG_FILE="${SCRIPT_DIR}/config.json"

# 函数定义
main() {
    # 主函数
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 🏷️ 命名规范

### 文件命名
- **规则文件**: `lowercase-with-hyphens.md`
- **技能文件**: `skill-name.md`
- **钩子脚本**: `event-action.sh`
- **配置JSON**: `component-config.json`
- **核心脚本**: `feature-action.sh`

### 变量命名 (Shell)
```bash
# 常量 (大写下划线)
readonly CONFIG_FILE="config.json"
readonly MAX_RETRIES=3

# 函数 (小写下划线)
load_config() {}
validate_input() {}

# 局部变量 (小写下划线)
local temp_file="/tmp/temp"
local retry_count=0
```

### 变量命名 (JSON)
```json
{
  "camelCase": "camelCase格式",
  "snake_case": "snake_case格式",
  "kebab-case": "kebab-case格式(仅key)",
  "CONSTANT_CASE": "常量大写格式"
}
```

## 🔗 依赖关系管理

### 规则依赖
```yaml
---
dependencies: ["base_rule", "other_rule"]
---
```

### 脚本依赖
```bash
# 在脚本开头声明依赖
# 依赖: core/common.sh, core/core/config/config-manager.sh
```

### 配置依赖
```json
{
  "dependencies": {
    "required_configs": ["global.json", "project.json"],
    "optional_configs": ["overrides.json"]
  }
}
```

## ✅ 配置验证

### 自动验证规则
1. **Frontmatter验证**: 检查必需字段和格式
2. **JSON Schema验证**: 验证JSON配置结构
3. **依赖检查**: 验证依赖关系完整性
4. **语法检查**: Shell脚本语法验证
5. **一致性检查**: 跨文件配置一致性

### 验证命令
```bash
# 验证所有配置
.cursor/core/core/config/config-validator.sh validate-all

# 验证特定组件
.cursor/core/core/config/config-validator.sh validate-rules
.cursor/core/core/config/config-validator.sh validate-skills
.cursor/core/core/config/config-validator.sh validate-hooks
```

## 📊 配置优先级

### 全局优先级 (从高到低)
1. **用户覆盖** (`overrides.json`)
2. **项目配置** (`project.json`)
3. **全局配置** (`global.json`)
4. **系统默认** (`system-defaults.json`)

### 规则优先级
```yaml
priority: 100  # 1-1000, 越高优先级越高
```

## 🔄 配置更新流程

### 新增配置
1. 在相应目录创建配置文件
2. 遵循命名和格式规范
3. 添加验证规则
4. 更新依赖关系
5. 测试配置生效

### 修改配置
1. 备份原有配置
2. 修改配置内容
3. 运行验证检查
4. 测试配置生效
5. 更新版本号

### 删除配置
1. 检查依赖关系
2. 更新引用配置
3. 删除配置文件
4. 清理相关验证规则

## 🚨 配置错误处理

### 常见错误类型
- **格式错误**: Frontmatter/JSON语法错误
- **依赖缺失**: 引用不存在的配置或脚本
- **类型不匹配**: 配置值类型不符合预期
- **权限错误**: 配置文件权限不足

### 错误恢复
```bash
# 查看配置错误
.cursor/core/core/config/config-validator.sh check-errors

# 自动修复 (如果可能)
.cursor/core/core/config/config-validator.sh auto-fix

# 生成修复报告
.cursor/core/core/config/config-validator.sh report-issues
```

## 📈 配置监控

### 配置健康检查
```bash
# 每日健康检查
.cursor/core/health-check.sh config

# 配置变更监控
.cursor/core/config-monitor.sh watch
```

### 配置指标
- 配置加载时间
- 配置验证通过率
- 配置变更频率
- 依赖关系完整性

---

*🔧 配置规范标准 - 确保Cursor AI Rules系统的配置一致性和可维护性*