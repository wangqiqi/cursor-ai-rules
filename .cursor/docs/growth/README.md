# 🌱 项目生长目录 (.cursorGrowth)

此目录包含项目的AI学习数据和生长信息。
这些数据不会被提交到版本控制，是项目私有的。

## 📂 目录结构 (按数据类型组织)

### 🎯 核心生长数据
- **learning/** - AI学习数据
  - `profile.json` - 用户学习档案
  - `master_interactions.json` - @master交互历史
  - `patterns.json` - 意图识别模式
- **conversations/** - 对话记录
  - `cursor_*.json` - Cursor IDE对话同步
  - `initial_conversation.json` - 初始化对话

### 📊 分析与统计
- **growth/** - 生长指标
  - `metrics.json` - 生长统计数据
- **monitoring/** - 系统监控
  - `metrics.json` - 性能指标
  - `performance.log` - 性能日志
  - `token_usage.log` - Token使用统计

### 🔧 系统数据
- **cache/** - 缓存优化
  - `env_perception:*.cache` - 环境感知缓存
  - `intent_analysis:*.cache` - 意图分析缓存
- **logs/** - 系统日志
  - 各种系统操作日志
- **sync/** - 同步管理
  - `cursor_sync_status.json` - Cursor数据同步状态

### 🌐 外部集成
- **mcps/** - MCP生态系统
  - `user-pdf-reader/` - PDF阅读器MCP资源
  - 其他MCP服务的配置和资源
- **compression/** - Token压缩数据 *(由optimizer.sh自动管理)*
  - 压缩字典、缓存、性能数据
- **personal/** - 个性化数据 *(按需生成)*
- **debug/** - 调试信息 *(按需生成)*

## 📚 相关文档

- **[目录结构规划](directory-structure.md)** - 完整的目录结构设计和标准
- **[最佳实践分析](best-practices-analysis.md)** - 目录设计的分析和评估报告

---

*🌱 项目生长目录 - AI学习数据的安全存储空间*
