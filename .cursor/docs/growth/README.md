# 🌱 项目生长目录 (.cursorGrowth)

此目录包含项目的AI学习数据和生长信息。
这些数据不会被提交到版本控制，是项目私有的。

## 📂 目录结构 (7目录 + 子目录规划)

### 🎯 核心数据目录
- **perception/** - 环境感知数据
  - `env_cache.json` - 环境缓存
  - `tech_stack.json` - 技术栈分析
  - `dependencies.json` - 依赖关系
- **user_data/** - 用户相关数据
  - `profile.json` - 用户学习档案
  - `preferences.json` - 个性化偏好
  - `learning_history.json` - 学习记录
- **project_data/** - 项目相关数据
  - `config.json` - 项目配置
  - `metrics.json` - 项目指标
  - `history.json` - 项目历史

### 🤖 AI与分析目录
- **ai/** - AI相关数据
  - `training_data/` - 训练数据
  - `results/` - 生成结果
  - `metrics.json` - AI学习指标
  - `skills/` - 已加载的AI技能
  - `cache/` - AI缓存数据
- **analytics/** - 分析数据
  - `data/` - 分析数据
  - `cache/` - 分析缓存
  - `reports/` - 分析报告

### 🔧 系统管理目录
- **monitoring/** - 系统监控
  - `performance.log` - 性能日志
  - `metrics.json` - 监控指标
  - `health.json` - 健康状态
  - `logs/` - 系统日志 (hooks, skills等)
  - `pids/` - 进程ID文件
- **integrations/** - 第三方集成
  - `mcp_services/` - MCP服务配置
  - `api_connections/` - API连接信息
  - `external_tools/` - 外部工具配置

## 📚 相关文档

- **[目录结构规划](directory-structure.md)** - 完整的目录结构设计和标准
- **[最佳实践分析](best-practices-analysis.md)** - 目录设计的分析和评估报告

---

## 📋 目录规划演进

- **v1.0**: 7目录规范 (核心数据分类)
- **v1.1**: 7目录 + 子目录规划 (功能细分优化)

**迁移说明**: 额外创建的目录已重新组织到7目录规范中，确保目录结构的整洁和一致性。

---

*🌱 项目生长目录 - AI学习数据的安全存储空间*
