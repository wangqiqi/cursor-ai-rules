# Cursor AI Rules - 目标目录结构定义

## 📋 概述

根据规划，本项目将 `.cursorGrowth` 重构为以下6个顶级功能目录：

```
.cursorGrowth/
├── core-data/           # 🎯 核心数据层
├── ai-learning/         # 🤖 AI学习层
├── analytics-monitoring/# 📊 分析监控层
├── storage-cache/       # 💾 存储缓存层
├── records-logs/        # 📝 记录日志层
└── system-services/     # 🔧 系统服务层
```

## 🎯 详细目录结构

### 1. core-data/ (核心数据层)
**用途**: 存储项目运行的核心数据和配置
```
core-data/
├── perception/      # 环境感知数据 (传感器数据、上下文信息)
├── user-data/       # 用户行为偏好数据 (用户设置、偏好)
└── project-data/    # 项目指标统计数据 (使用统计、性能指标)
```

### 2. ai-learning/ (AI学习层)
**用途**: AI模型训练、学习和结果存储
```
ai-learning/
├── models/          # 训练好的AI模型文件
├── training-data/   # AI训练数据集
├── metrics/         # AI学习效果指标 (准确率、损失值等)
└── results/         # AI生成的结果数据
```

### 3. analytics-monitoring/ (分析监控层)
**用途**: 系统分析和性能监控
```
analytics-monitoring/
├── data/            # 分析统计结果数据
├── cache/           # 分析过程缓存数据
└── system-metrics/  # 系统性能监控数据 (CPU、内存、响应时间)
```

### 4. storage-cache/ (存储缓存层)
**用途**: 规则、模板和数据的缓存存储
```
storage-cache/
├── rules/           # 规则引擎缓存数据
├── templates/       # 模板缓存数据
└── backups/         # 系统数据备份
```

### 5. records-logs/ (记录日志层)
**用途**: 所有记录和日志的集中管理
```
records-logs/
├── conversations/   # 用户对话历史记录
├── growth-metrics/  # 系统生长指标记录
├── learning-progress/ # AI学习进度记录
└── system-logs/     # 系统运行日志
```

### 6. system-services/ (系统服务层)
**用途**: 系统级服务和配置
```
system-services/
├── config/          # 系统配置文件
├── debug/           # 调试诊断信息
├── compression/     # 数据压缩相关
├── sync/            # 数据同步状态
└── integrations/    # 第三方服务集成
```

## 📊 目录统计

- **顶级目录**: 6个
- **子目录**: 18个
- **总目录数**: 24个 (从原来的34个减少为24个)
- **减少比例**: 29% (34→24)

## 🎯 设计原则

1. **功能集中**: 相关功能集中在一个顶级目录下
2. **层次清晰**: 3级深度，既不过深也不过浅
3. **扩展性好**: 新功能可以自然添加到对应层级
4. **维护简单**: 职责明确，易于理解和维护

## 📋 路径变量映射

```bash
# 顶级目录变量
CORE_DATA_DIR="$CURSOR_GROWTH/core-data"
AI_LEARNING_DIR="$CURSOR_GROWTH/ai-learning"
ANALYTICS_MONITORING_DIR="$CURSOR_GROWTH/analytics-monitoring"
STORAGE_CACHE_DIR="$CURSOR_GROWTH/storage-cache"
RECORDS_LOGS_DIR="$CURSOR_GROWTH/records-logs"
SYSTEM_SERVICES_DIR="$CURSOR_GROWTH/system-services"

# 子目录变量 (自动继承)
PERCEPTION_DIR="$CORE_DATA_DIR/perception"
USER_DATA_DIR="$CORE_DATA_DIR/user-data"
PROJECT_DATA_DIR="$CORE_DATA_DIR/project-data"
# ... 其他子目录变量
```

---

*此目标结构将在Phase 2中通过脚本修改实现*