---
command: system_info
description: "系统信息获取器 - 自动获取时间、路径和作者信息的通用机制"
globs: ["*.md", "*.mdc", "*.txt"]
alwaysApply: true
---

# 🔧 系统信息获取器 (System Information Manager)

*版本: v4.1.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

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

---

*系统信息获取器为.cursor规则体系提供统一的信息获取接口，确保跨平台和多语言环境下的稳定运行。*

