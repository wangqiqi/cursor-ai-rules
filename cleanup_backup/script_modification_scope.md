# 脚本修改范围确定

## 📊 分析结果总结

基于对68个脚本文件的分析，发现以下情况：

- **使用 mkdir 的脚本**: 85个 (包含重复统计)
- **硬编码路径引用**: 157处
- **旧变量引用**: 173处

### 关键变量使用统计
- `GROWTH_DIR`: 107处使用 (最重要)
- `ANALYTICS_DIR`: 24处使用
- `AI_DIR`: 18处使用
- `CACHE_DIR`: 24处使用
- `LOGS_DIR`: 4处使用

## 🎯 优先级排序的脚本修改范围

### 高优先级 (核心功能，需要首先修改)

#### 1. path-config.sh (路径变量定义)
**修改内容**:
- 添加项目识别功能
- 定义新的6层级目录结构变量
- 保持向后兼容的旧变量别名

**影响范围**: 所有其他脚本都依赖此文件

#### 2. shared-functions.sh (新建共享函数库)
**修改内容**:
- 创建项目识别函数
- 实现目录操作函数
- 添加日志和错误处理函数
- 提供文件操作安全接口

**影响范围**: 所有脚本都需要加载此库

#### 3. growth-recorder.sh (核心数据记录)
**修改内容**:
```bash
# 第41行: 目录创建
旧: mkdir -p "$GROWTH_DIR/learning" "$GROWTH_DIR/conversations" "$GROWTH_DIR/growth"
新: mkdir -p "$LEARNING_PROGRESS_DIR" "$CONVERSATIONS_DIR" "$GROWTH_METRICS_DIR"

# 第89行: 文件路径
旧: "$GROWTH_DIR/conversations/initial_conversation.json"
新: "$CONVERSATIONS_DIR/initial_conversation.json"

# 第112行: 文件路径
旧: "$GROWTH_DIR/growth/metrics.json"
新: "$GROWTH_METRICS_DIR/metrics.json"
```

#### 4. growth-manager.sh (生长指标管理)
**修改内容**:
```bash
# 第203行: 文件路径
旧: "$GROWTH_DIR/growth/metrics.json"
新: "$GROWTH_METRICS_DIR/metrics.json"
```

#### 5. cursor-master.sh (主控制器)
**修改内容**: 多处路径引用更新
- learning/* → learning-progress/*
- conversations/* → conversations/*
- growth/* → growth-metrics/*

### 中优先级 (功能模块)

#### 6. performance-monitor.sh (性能监控)
**修改内容**:
```bash
# 第19-21行: 目录变量定义
旧:
ANALYTICS_DATA_DIR="$ANALYTICS_DIR/data"
ANALYTICS_CACHE_DIR="$ANALYTICS_DIR/cache"

新:
ANALYTICS_DATA_DIR="$ANALYTICS_DATA_DIR"  # 使用统一变量
ANALYTICS_CACHE_DIR="$ANALYTICS_CACHE_DIR"  # 使用统一变量
```

#### 7. self-learning-engine.sh (AI学习引擎)
**修改内容**:
```bash
# 第22-25行: 目录变量定义
旧:
LEARNING_DIR="$AI_DIR"
LEARNING_MODELS_DIR="$LEARNING_DIR/models"
LEARNING_DATA_DIR="$LEARNING_DIR/data"
LEARNING_METRICS_DIR="$LEARNING_DIR/metrics"

新:
LEARNING_DIR="$AI_LEARNING_DIR"           # 使用统一变量
LEARNING_MODELS_DIR="$AI_MODELS_DIR"      # 使用统一变量
LEARNING_TRAINING_DIR="$AI_TRAINING_DATA_DIR"  # 使用统一变量
LEARNING_METRICS_DIR="$AI_METRICS_DIR"    # 使用统一变量
```

#### 8. growth_init.sh (初始化脚本)
**修改内容**:
```bash
# 第44行: 目录创建
旧: "$GROWTH_DIR/learning"
新: "$LEARNING_PROGRESS_DIR"

# 第87行: 文件路径
旧: "$GROWTH_DIR/learning/preferences.json"
新: "$LEARNING_PROGRESS_DIR/preferences.json"
```

### 低优先级 (钩子脚本群)

#### 9. 钩子脚本批量修改 (6个脚本)
**需要修改的脚本**:
- `session-summary.sh`: `$CURSOR_GROWTH/logs/` → `$SYSTEM_LOGS_DIR/`
- `rule-usage-tracker.sh`: `$CURSOR_GROWTH/logs/` → `$SYSTEM_LOGS_DIR/`
- `command-log.sh`: `$CURSOR_GROWTH/logs/` → `$SYSTEM_LOGS_DIR/`
- `security-audit.sh`: `$CURSOR_GROWTH/logs/` → `$SYSTEM_LOGS_DIR/`
- `prompt-security.sh`: `$CURSOR_GROWTH/logs/` → `$SYSTEM_LOGS_DIR/`
- `code-quality.sh`: `$CURSOR_GROWTH/logs/` → `$SYSTEM_LOGS_DIR/`

**修改模式**:
```bash
# 统一替换模式
旧: $CURSOR_GROWTH/logs/*
新: $SYSTEM_LOGS_DIR/*

# 示例
旧: $CURSOR_GROWTH/logs/rule-usage.log
新: $SYSTEM_LOGS_DIR/rule-usage.log
```

### 需要检查的其他脚本

#### 10. master-init.sh (初始化大量旧目录)
**特殊处理**: 此脚本创建了很多旧的目录结构
```bash
# 当前代码:
mkdir -p "$GROWTH_DIR"/{learning,conversations,growth,personal,cache,monitoring,debug,logs,sync,mcps,compression}

# 需要改为: 使用共享的目录创建函数
ensure_directory_structure
```

#### 11. 其他脚本检查
需要检查以下脚本是否使用了旧路径：
- `context-manager.sh`: 使用 AI_DIR
- `pattern-analyzer.sh`: 使用 ANALYSIS_DIR
- `continuous-learning-loop*.sh`: 使用各种学习相关目录
- `cursor-sync.sh`: 使用 GROWTH_DIR/sync
- `logging.sh`: 使用 LOG_DIR
- 其他脚本...

## 📋 修改统计

### 脚本数量统计
- **高优先级**: 5个脚本 (path-config.sh, shared-functions.sh, growth-recorder.sh, growth-manager.sh, cursor-master.sh)
- **中优先级**: 3个脚本 (performance-monitor.sh, self-learning-engine.sh, growth_init.sh)
- **低优先级**: 6个钩子脚本
- **需要检查**: 10+个其他脚本
- **总计**: 24+个脚本需要修改或检查

### 修改复杂度评估
- **简单修改**: 变量名替换 - 10个脚本
- **中等修改**: 路径重构 - 8个脚本
- **复杂修改**: 逻辑重构 - 6个脚本

## 🎯 建议的修改顺序

1. **先创建基础设施** (Day 2)
   - shared-functions.sh
   - path-config.sh

2. **再修改核心脚本** (Day 2-3)
   - growth-recorder.sh, growth-manager.sh, cursor-master.sh

3. **然后修改功能脚本** (Day 3-4)
   - performance-monitor.sh, self-learning-engine.sh, growth_init.sh

4. **最后修改钩子脚本** (Day 4)
   - 6个钩子脚本批量处理

5. **检查和完善** (Day 5)
   - 检查其他脚本，补充遗漏

## ⚠️ 注意事项

1. **安全第一**: 禁止使用 sed -i，必须手动检查每处修改
2. **备份策略**: 每个脚本修改前都要创建备份
3. **测试验证**: 每次修改后都要删除 .cursorGrowth 重新测试
4. **逐步推进**: 不要一次性修改太多脚本
5. **向后兼容**: 保留旧变量作为新变量的别名