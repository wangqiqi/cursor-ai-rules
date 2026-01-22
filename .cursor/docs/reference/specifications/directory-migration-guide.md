# 🔄 Directory Structure Migration Guide

**迁移日期:** 2026-01-18
**迁移原因:** 解决目录结构概念重叠问题
**影响范围:** 所有使用 .cursorGrowth 路径的脚本

## 📊 迁移对比

### 旧结构问题
```
.cursorGrowth/ (重叠问题多)
├── data/
│   ├── perception/          # 环境感知数据
│   ├── user_preferences/    # 用户偏好 (重叠!)
│   └── project_metrics/     # 项目指标
├── ai/
│   ├── data/                # AI训练数据 (重叠!)
│   └── metrics/             # AI学习指标
├── personal/                # 个性化数据 (重叠!)
├── analytics/               # 分析数据
├── cache/analysis/          # 分析缓存 (重叠!)
└── monitoring/              # 系统监控
```

### 新结构优化
```
.cursorGrowth/ (层次清晰)
├── perception/              # 环境感知数据
├── user_data/               # 用户相关数据 (统一管理)
├── project_data/            # 项目相关数据 (统一管理)
├── ai/
│   ├── training_data/       # AI训练数据 (明确命名)
│   ├── results/             # AI生成结果 (新增)
│   └── metrics/             # AI学习指标
├── analytics/
│   ├── data/                # 分析数据
│   └── cache/               # 分析缓存 (分离管理)
├── monitoring/              # 系统性能监控
└── integrations/            # 第三方集成 (原mcps重命名)
```

## 🔄 路径映射表

| 旧路径                   | 新路径              | 迁移说明                |
| ------------------------ | ------------------- | ----------------------- |
| `data/perception/`       | `perception/`       | 提升到顶级目录          |
| `data/user_preferences/` | `user_data/`        | 合并到统一用户数据目录  |
| `data/project_metrics/`  | `project_data/`     | 合并到统一项目数据目录  |
| `personal/`              | `user_data/`        | 合并到用户数据目录      |
| `ai/data/`               | `ai/training_data/` | 明确为训练数据          |
| `cache/analysis/`        | `analytics/cache/`  | 移到analytics下统一管理 |
| `mcps/`                  | `integrations/`     | 更通用的命名            |
| `learning/`              | `user_data/`        | 合并用户学习数据        |

## 🛠️ 脚本更新指南

### 1. 环境变量更新
```bash
# 旧变量 (已废弃)
DATA_DIR="$CURSOR_GROWTH/data"
PERSONAL_DIR="$CURSOR_GROWTH/personal"
MCPS_DIR="$CURSOR_GROWTH/mcps"

# 新变量 (推荐使用)
PERCEPTION_DIR="$CURSOR_GROWTH/perception"
USER_DATA_DIR="$CURSOR_GROWTH/user_data"
PROJECT_DATA_DIR="$CURSOR_GROWTH/project_data"
INTEGRATIONS_DIR="$CURSOR_GROWTH/integrations"
```

### 2. 文件路径更新
```bash
# 旧路径
"$DATA_DIR/user_preferences/profile.json"
"$PERSONAL_DIR/settings.json"
"$MCPS_DIR/config.json"

# 新路径
"$USER_DATA_DIR/preferences.json"
"$USER_DATA_DIR/settings.json"
"$INTEGRATIONS_DIR/mcp_config.json"
```

### 3. 脚本更新步骤

#### Step 1: 识别受影响的脚本
```bash
grep -r "DATA_DIR\|PERSONAL_DIR\|MCPS_DIR" .cursor/
grep -r "data/user_preferences\|data/project_metrics" .cursor/
grep -r "ai/data\|cache/analysis" .cursor/
```

#### Step 2: 更新环境变量使用
```bash
# 在脚本开头添加新的变量定义
PERCEPTION_DIR="$CURSOR_GROWTH/perception"
USER_DATA_DIR="$CURSOR_GROWTH/user_data"
PROJECT_DATA_DIR="$CURSOR_GROWTH/project_data"
AI_TRAINING_DIR="$CURSOR_GROWTH/ai/training_data"
ANALYTICS_CACHE_DIR="$CURSOR_GROWTH/analytics/cache"
```

#### Step 3: 更新文件路径
```bash
# 批量替换路径
sed 's|$DATA_DIR/user_preferences|$USER_DATA_DIR|g' script.sh
sed 's|$PERSONAL_DIR|$USER_DATA_DIR|g' script.sh
sed 's|$MCPS_DIR|$INTEGRATIONS_DIR|g' script.sh
```

## 📋 待更新脚本清单

### 高优先级 (立即更新)
- [ ] `self-learning-engine.sh` - 使用 ai/training_data/
- [ ] `performance-monitor.sh` - 使用 analytics/data/ 和 analytics/cache/
- [ ] `env-perception.sh` - 使用 perception/ 目录

### 中优先级 (本周内更新)
- [ ] `cursor-master.sh` - 更新备份和用户数据路径
- [ ] `config-manager.sh` - 更新配置存储路径
- [ ] `token-compression.sh` - 使用 compression/ 目录

### 低优先级 (可选更新)
- [ ] 钩子脚本 - 根据实际使用情况更新
- [ ] 测试脚本 - 更新测试路径
- [ ] 文档 - 更新路径引用

## ✅ 迁移验证

### 自动化验证脚本
```bash
#!/bin/bash
# migration-validator.sh

echo "🔍 验证目录结构迁移..."

# 检查新目录存在
check_dir "perception" "环境感知目录"
check_dir "user_data" "用户数据目录"
check_dir "project_data" "项目数据目录"
check_dir "ai/training_data" "AI训练数据目录"
check_dir "analytics/cache" "分析缓存目录"

# 检查旧目录已清理
check_old_dir "data" "旧的data目录"
check_old_dir "personal" "旧的personal目录"
check_old_dir "mcps" "旧的mcps目录"

echo "✅ 迁移验证完成"
```

### 手动验证步骤
1. **目录结构检查**: `find .cursorGrowth -type d | sort`
2. **文件路径验证**: 检查脚本中硬编码的路径
3. **功能测试**: 运行关键脚本确保功能正常
4. **性能测试**: 验证路径解析性能

## 🛡️ 回滚计划

如果迁移出现问题，可以通过以下步骤回滚：

1. **恢复旧的 path-config.sh**
2. **删除新创建的目录**
3. **重新创建旧的目录结构**
4. **验证所有脚本恢复正常**

## 📞 支持与帮助

- **迁移状态**: 查看 `migration-status.md`
- **问题反馈**: 在相关脚本中添加 TODO 注释
- **进度跟踪**: 更新此文档的完成状态

---

**迁移负责人:** AI Assistant
**最后更新:** 2026-01-18