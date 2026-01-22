# Cursor AI Rules - 脚本架构文档

## 📋 概述

本文档描述了Cursor AI Rules系统的完整脚本架构，经过Phase 1-4的优化和重构，实现了高度模块化和标准化的脚本系统。

## 🏗️ 架构总览

### 核心原则
- **模块化设计**: 功能分离，职责单一
- **标准化接口**: 统一的CLI框架和参数解析
- **向后兼容**: 保持现有功能的同时提供现代化接口
- **可扩展性**: 易于添加新功能和新模块

### 目录结构
```
/.cursor/core/
├── cli-framework.sh        # 🔧 统一CLI框架
├── logging-module.sh       # 📝 高级日志模块
├── json-module.sh          # 📄 JSON处理模块
├── file-module.sh          # 📁 文件操作模块
├── shared-functions.sh     # 🔄 共享函数库
├── path-config.sh          # 🗂️ 路径配置系统
├── *-manager.sh            # 🎯 核心管理脚本
└── *-module.sh             # 🧩 专用功能模块
```

## 🎯 核心模块详解

### 1. CLI框架 (`cli-framework.sh`)

**功能**: 提供统一的命令行接口和参数处理

**核心函数**:
- `parse_cli_args()` - 参数解析
- `cli_show_help()` - 帮助显示
- `cli_log()` - 统一日志
- `cli_confirm()` - 用户确认
- `cli_validate_command()` - 命令验证

**使用示例**:
```bash
# 标准化的main函数模板
main() {
    parse_cli_args "$@" || return 1

    # 处理全局标志
    for flag in "${CLI_FLAGS[@]}"; do
        case "$flag" in
            "help") cli_show_help "Script Name" "Description" ... ;;
            "version") cli_show_version "Script Name" ;;
        esac
    done

    cli_validate_command "command1" "command2" || return 1
    # 执行命令逻辑
}
```

### 2. 日志模块 (`logging-module.sh`)

**功能**: 高级日志记录和性能监控

**特性**:
- 多级别日志 (DEBUG, INFO, WARNING, ERROR, SUCCESS)
- 文件和控制台双重输出
- 自动日志轮转
- 性能监控和统计

**使用示例**:
```bash
logging_set_level "info"
logging_set_file "/var/log/script.log"

logging_info "操作开始"
logging_function_start "process_data"
# 执行操作
logging_function_end "process_data"
logging_success "操作完成"
```

### 3. JSON模块 (`json-module.sh`)

**功能**: 统一的JSON读写和验证

**核心功能**:
- JSON语法验证
- 键值读写操作
- 数组操作
- 模式验证
- 备份和恢复

**使用示例**:
```bash
# 验证JSON文件
json_validate "config.json" || exit 1

# 读取配置
value=$(json_get "config.json" '.database.host')

# 设置配置
json_set "config.json" '.database.port' '5432'

# 数组操作
json_array_append "config.json" '.features' '"new_feature"'
```

### 4. 文件模块 (`file-module.sh`)

**功能**: 安全的文件和目录操作

**核心功能**:
- 安全的文件创建、复制、移动、删除
- 目录操作和权限管理
- 文件查找和信息获取
- 备份和哈希计算

**使用示例**:
```bash
# 安全创建文件
file_create "/path/to/file.txt" "content"

# 备份文件
file_backup "/important/file.txt"

# 查找文件
file_find "." "*.log" "f"
```

## 🎯 核心管理脚本

### 配置管理器 (`config-manager.sh`)
**继承功能**: `config-validator.sh` (验证功能)

**主要功能**:
- 配置层级管理 (system → global → project → user)
- 配置验证和合并
- 增强的JSON验证
- 跨配置一致性检查

**命令**:
```bash
config-manager.sh init          # 初始化配置系统
config-manager.sh validate      # 验证配置
config-manager.sh merge         # 合并配置层级
config-manager.sh get <key>     # 获取配置值
config-manager.sh set <key> <value>  # 设置配置值
```

### 质量管理器 (`quality-manager.sh`)
**继承功能**: `quality-reporter.sh` (报告功能)

**主要功能**:
- 代码质量检查 (ESLint, Prettier, etc.)
- 代码格式化
- 安全审计
- 质量报告生成 (Markdown/HTML)

**命令**:
```bash
quality-manager.sh lint         # 代码质量检查
quality-manager.sh format       # 代码格式化
quality-manager.sh security     # 安全审计
quality-manager.sh comprehensive # 完整质量检查
```

### 环境感知器 (`env-perception.sh`)
**继承功能**: `perception-enhancer.sh` (增强功能)

**主要功能**:
- 项目环境分析
- 技术栈检测
- MCP工具集成
- 智能意图分析

**命令**:
```bash
env-perception.sh analyze       # 环境分析
env-perception.sh detect        # 技术栈检测
env-perception.sh enhanced      # 增强感知
```

### 优化器 (`optimizer.sh`)
**继承功能**:
- `performance-monitor.sh` (监控功能)
- `performance-cache.sh` (缓存功能)

**主要功能**:
- 性能监控和分析
- 智能缓存管理
- 系统优化策略
- 健康检查

**命令**:
```bash
optimizer.sh analyze            # 性能分析
optimizer.sh optimize           # 系统优化
optimizer.sh cache              # 缓存管理
optimizer.sh status             # 状态报告
```

### Git管理器 (`git-manager.sh`)
**继承功能**: `enhanced-git-commit.sh` (增强提交)

**主要功能**:
- 智能Git操作
- 增强的提交信息生成
- 分支管理和远程操作
- 仓库维护

**命令**:
```bash
git-manager.sh commit [enhanced]  # 智能提交
git-manager.sh branch <action>    # 分支管理
git-manager.sh status             # 仓库状态
git-manager.sh cleanup            # 仓库清理
```

### 测试运行器 (`test-runner.sh`)
**使用CLI框架**: ✅ (已重构)

**主要功能**:
- 多框架测试支持 (Jest, Vitest, Pytest, etc.)
- 覆盖率报告生成
- 自动框架检测
- 测试报告输出

**命令**:
```bash
test-runner.sh run <framework>    # 运行指定测试
test-runner.sh auto               # 自动检测并运行
test-runner.sh coverage           # 生成覆盖率
test-runner.sh report             # 生成报告
```

## 🔗 钩子系统集成

### 自动质量检查
```json
{
  "name": "quality-reporter",
  "command": "core/quality-manager.sh",
  "args": ["generate_report"],
  "timeout": 12000
}
```

### 配置验证
```json
{
  "name": "config-validator",
  "command": "core/config-manager.sh",
  "args": ["validate_enhanced"],
  "timeout": 5000
}
```

### 会话学习
```json
{
  "name": "session-learning",
  "command": "core/continuous-learning-loop.sh",
  "args": ["session_summary"],
  "timeout": 15000
}
```

## 📊 优化成果统计

### Phase 1-4 完成情况
- ✅ **脚本数量**: 38个 → 33个 (减少13%)
- ✅ **重复脚本**: 9个 → 2个 (减少78%)
- ✅ **新模块**: 4个核心模块
- ✅ **CLI标准化**: 统一接口框架
- ✅ **引用更新**: 所有配置正确更新

### 架构改进
- **模块化程度**: 从单体脚本到模块化系统
- **代码复用性**: 公共功能提取为独立模块
- **维护效率**: 减少重复代码，提高维护性
- **扩展性**: 新功能易于集成

## 🚀 使用指南

### 开发者指南

#### 添加新模块
1. 创建模块文件 `*-module.sh`
2. 实现标准化的CLI接口
3. 在主脚本中集成模块功能
4. 更新相关文档

#### 遵循CLI标准
```bash
#!/bin/bash
source "$SCRIPT_DIR/cli-framework.sh"
source "$SCRIPT_DIR/path-config.sh"

cli_init "Module Name"

main() {
    # 使用CLI框架的标准模式
    parse_cli_args "$@" || return 1
    # ... 处理逻辑
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 用户指南

#### 基本使用
```bash
# 显示帮助
script.sh --help

# 详细输出
script.sh command --verbose

# JSON输出
script.sh command --json

# 静默模式
script.sh command --quiet
```

#### 质量检查流程
```bash
# 完整质量检查
quality-manager.sh comprehensive

# 生成报告
quality-manager.sh report
```

#### 配置管理
```bash
# 验证配置
config-manager.sh validate

# 获取配置值
config-manager.sh get .system.log_level

# 设置配置值
config-manager.sh set .features.automation.enabled true
```

## 🔄 持续改进

### Phase 5 计划
- **插件化架构**: 实现脚本插件系统
- **配置驱动**: 通过配置文件控制脚本行为
- **API标准化**: 为所有脚本提供REST API接口
- **监控面板**: 统一的脚本监控和状态面板

### 维护建议
- 定期更新模块依赖
- 监控脚本性能指标
- 收集用户反馈进行改进
- 保持向后兼容性

---

**文档版本**: 1.0.0
**最后更新**: 2025-01-22
**维护者**: Cursor AI Rules Team