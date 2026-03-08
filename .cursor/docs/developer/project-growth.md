# 🌱 项目生长架构 - Cursor AI Rules

*用户数据管理与持续学习机制*

## 🏗️ 双目录架构设计

Cursor AI Rules 采用创新的双目录架构，将项目无关的配置与项目私有的数据严格分离：

### .cursor/ 目录 (AI核心系统)
**特性**: 可共享、可复制、标准化、版本化
```
.cursor/
├── commands/      # 命令处理器 - 统一的AI接口
├── core/         # 核心引擎 - 智能算法和业务逻辑
├── rules/        # 规则体系 - 三大公理强制执行
├── skills/       # 技能库 - 专业能力扩展
├── docs/         # 文档体系 - 完整用户指南
├── features/     # 高级功能 - 自动化和集成
├── config/       # 系统配置 - 默认设置和模板
└── web/          # Web界面 - 可选图形界面
```

### .cursorGrowth/ 目录 (生长数据)
**特性**: 隐私保护、个性化学习、数据隔离、跨会话持久化
```
.cursorGrowth/
├── perception/       # 环境感知数据
├── user_data/        # 用户偏好和学习数据
├── project/          # 项目特定标识符
├── ai/              # AI学习数据和技能实例
├── analytics/       # 分析数据和统计信息
├── monitoring/      # 系统监控数据
└── integrations/    # 第三方服务集成配置
```

## 🔒 数据隔离与隐私保护

### 核心安全原则

#### 完全私有化
- **.cursorGrowth/** 目录不会被提交到版本控制系统
- **自动保护**: 系统自动将 `.cursorGrowth/` 添加到 `.gitignore`
- **用户特定**: 每个用户的学习数据和偏好都是独立的

#### 隐私保护条目
```gitignore
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/
```

### 数据分类管理

#### 感知数据 (perception/)
```json
{
  "environment": {
    "os": "linux",
    "node_version": "18.17.0",
    "npm_version": "9.6.7",
    "git_version": "2.34.1"
  },
  "project": {
    "type": "nodejs",
    "framework": "express",
    "dependencies": ["express", "mongoose", "jwt"],
    "structure": {
      "has_src": true,
      "has_tests": true,
      "has_docs": false
    }
  },
  "cache": {
    "last_updated": "2026-01-22T10:30:00Z",
    "ttl": 300000
  }
}
```

#### 用户数据 (user_data/)
```json
{
  "preferences": {
    "language": "zh-CN",
    "theme": "dark",
    "editor": "cursor",
    "notifications": true
  },
  "learning": {
    "skill_level": {
      "javascript": "advanced",
      "react": "intermediate",
      "nodejs": "expert"
    },
    "preferred_patterns": [
      "functional_programming",
      "async_await",
      "modular_architecture"
    ]
  },
  "behavior": {
    "frequent_commands": ["/master optimize", "/master test"],
    "working_hours": "09:00-18:00",
    "collaboration_style": "detailed_feedback"
  }
}
```

## 🚀 智能缓存与性能优化

### 三级缓存架构

#### 内存缓存 (最快访问)
- **存储位置**: 运行时内存
- **TTL**: 5分钟 (短期热点数据)
- **适用场景**: 频繁访问的配置和规则

#### 文件缓存 (持久化存储)
- **存储位置**: `.cursorGrowth/cache/`
- **TTL**: 24小时 (中长期数据)
- **适用场景**: 环境感知结果、分析报告

#### 网络缓存 (最后手段)
- **触发条件**: 本地缓存失效时
- **更新策略**: 按需获取，智能更新
- **适用场景**: 外部数据和最新信息

### 缓存性能指标

#### 命中率统计
- **目标**: 缓存命中率 > 80%
- **当前**: 典型项目可达85-90%
- **收益**: Token节省60%，响应速度提升70%

#### 存储优化
- **自动清理**: 过期数据自动清理
- **压缩存储**: 大文件自动压缩
- **智能预加载**: 预测性数据预加载

## 📊 学习引擎与个性化

### 用户画像构建

#### 技术栈偏好学习
```json
{
  "primary_languages": ["javascript", "typescript", "python"],
  "framework_preferences": {
    "frontend": ["react", "vue"],
    "backend": ["nodejs", "express"],
    "testing": ["jest", "cypress"]
  },
  "coding_patterns": {
    "style": "functional",
    "architecture": "microservices",
    "testing": "tdd"
  }
}
```

#### 行为模式分析
- **工作时间**: 识别用户活跃时段
- **命令频率**: 统计常用命令模式
- **反馈偏好**: 学习用户反馈风格
- **错误模式**: 识别常见错误类型

### 个性化推荐系统

#### 技能推荐
```typescript
interface SkillRecommendation {
  skillId: string;
  confidence: number; // 0-1
  reasoning: string[];
  prerequisites: string[];
  estimatedBenefit: 'high' | 'medium' | 'low';
}
```

#### 内容定制
- **难度调节**: 根据用户水平调整内容复杂度
- **风格适配**: 匹配用户的编程风格偏好
- **进度跟踪**: 记录学习进度和里程碑

## 🔄 数据同步与备份

### 跨设备同步

#### 选择性同步
- **核心偏好**: 用户基本设置和学习数据
- **项目特定**: 本地项目配置和缓存
- **敏感数据**: 永不同步的隐私信息

#### 同步机制
```typescript
class DataSyncManager {
  // 增量同步
  async incrementalSync(): Promise<SyncResult> {
    const changes = await this.detectChanges();
    const conflicts = await this.resolveConflicts(changes);
    return await this.applyChanges(conflicts);
  }

  // 冲突解决
  async resolveConflicts(changes: ChangeSet[]): Promise<ResolvedChanges> {
    // 基于时间戳和内容的重要性自动解决冲突
    // 重要数据优先保留，冲突时提示用户选择
  }
}
```

### 自动备份策略

#### 分层备份
- **实时备份**: 重要数据变更立即备份
- **定期备份**: 每日全量备份
- **异地备份**: 可选的云端备份服务

#### 恢复机制
- **一键恢复**: 快速恢复到指定时间点
- **选择性恢复**: 只恢复指定的数据类型
- **版本管理**: 支持多版本备份管理

## 📈 分析与洞察

### 使用行为分析

#### 命令使用统计
```json
{
  "command_usage": {
    "total_commands": 15420,
    "unique_commands": 89,
    "top_commands": [
      {"command": "/master optimize", "count": 1240},
      {"command": "/master test", "count": 980},
      {"command": "/master analyze", "count": 756}
    ]
  }
}
```

#### 效率提升指标
- **任务完成时间**: 平均减少50%
- **错误率**: 降低70%
- **代码质量**: 提升40%

### 学习效果评估

#### 技能成长追踪
```json
{
  "skill_growth": {
    "javascript": {
      "start_level": "beginner",
      "current_level": "advanced",
      "improvement_rate": 85,
      "time_spent": "240 hours"
    }
  }
}
```

#### 个性化效果
- **推荐准确率**: >80%
- **用户满意度**: >4.5/5.0
- **学习效率**: 提升30%

## 🔧 数据维护工具

### 清理与优化

#### 自动清理脚本
```bash
# 清理过期缓存
./.cursor/core/cache-cleanup.sh

# 优化数据存储
./.cursor/core/data-optimization.sh

# 完整性检查
./.cursor/core/integrity-check.sh
```

#### 手动维护命令
```bash
# 查看存储统计
/master 数据统计

# 清理无用数据
/master 清理数据

# 导出用户数据
/master 导出数据
```

## 🚨 安全与合规

### 数据加密
- **传输加密**: 所有网络传输使用TLS 1.3
- **存储加密**: 敏感数据使用AES-256加密
- **密钥管理**: 安全的密钥轮换和存储

### 隐私合规
- **数据最小化**: 只收集必要的数据
- **用户同意**: 明确的数据使用同意机制
- **删除权利**: 用户随时可删除所有数据

### 审计追踪
- **操作日志**: 所有数据操作的完整记录
- **访问控制**: 基于角色的数据访问权限
- **异常检测**: 自动检测异常数据访问行为

---

## 📚 相关文档

- [系统架构](architecture.md) - 整体技术架构设计
- [配置管理](../admin/configuration.md) - 配置系统使用指南

---

*最后更新: 2026-01-22 | 版本: v9.0.0 | 状态: 🌱 生长数据架构就绪*