# 脚本修改计划

## 📅 Phase 2: 脚本更新 (3天) - 详细执行计划

### Day 2: 高优先级核心脚本 (4小时工作)
**目标**: 建立基础设施，确保其他脚本能正常工作

#### 1. 创建 shared-functions.sh (2小时)
```bash
# 创建位置: .cursor/core/shared-functions.sh
# 包含内容:
- 项目识别函数 (generate_project_identifier, get_project_root_path, validate_project_context)
- 路径操作函数 (safe_file_operation)
- 日志记录函数 (log_message)
- 配置管理函数 (safe_read_config, safe_write_config)
- 目录管理函数 (ensure_directory_structure)
- 错误处理函数 (handle_error, setup_error_handling, cleanup_on_exit)
- 校验和函数 (calculate_checksum, verify_checksum)

# 验证方式:
1. 语法检查: bash -n shared-functions.sh
2. 加载测试: source shared-functions.sh && validate_project_context
```

#### 2. 修改 path-config.sh (2小时)
```bash
# 修改内容:
1. 加载共享函数库
2. 定义6个顶级目录变量
3. 定义18个子目录变量
4. 保持向后兼容的别名
5. 自动执行项目上下文验证

# 具体修改:
- 添加: source "$SCRIPT_DIR/shared-functions.sh"
- 添加: validate_project_context || exit 1
- 添加新的路径变量定义
- 保持旧变量作为别名

# 验证方式:
1. 语法检查
2. 变量定义测试
3. 项目上下文验证测试
```

### Day 3: 主要功能脚本 (6小时工作)
**目标**: 修改核心业务逻辑脚本

#### 3. 重构 growth-recorder.sh (2小时)
```bash
# 修改内容:
1. 添加共享函数库引用
2. 替换GROWTH_DIR变量使用
3. 使用新的目录变量

# 具体修改位置:
- 第41行: mkdir -p "$LEARNING_PROGRESS_DIR" "$CONVERSATIONS_DIR" "$GROWTH_METRICS_DIR"
- 第89行: "$CONVERSATIONS_DIR/initial_conversation.json"
- 第112行: "$GROWTH_METRICS_DIR/metrics.json"
- 其他相关位置...

# 验证方式:
1. 语法检查
2. 删除.cursorGrowth后测试目录生成
```

#### 4. 重构 growth-manager.sh (2小时)
```bash
# 修改内容:
1. 添加共享函数库引用
2. 替换GROWTH_DIR变量使用

# 具体修改位置:
- 第203行: "$GROWTH_METRICS_DIR/metrics.json"

# 验证方式:
1. 语法检查
2. 删除.cursorGrowth后测试目录生成
```

#### 5. 重构 cursor-master.sh (2小时)
```bash
# 修改内容:
1. 添加共享函数库引用
2. 替换多处路径引用

# 具体修改位置:
- learning/* → learning-progress/*
- conversations/* → conversations/*
- growth/* → growth-metrics/*

# 需要仔细检查的行:
- 第1128行: master_interactions.json
- 第1168行: session_*.json
- 第1242,1287,1926,1951,2010,2045行

# 验证方式:
1. 语法检查
2. 删除.cursorGrowth后测试功能
```

### Day 4: 功能模块和钩子脚本 (6小时工作)
**目标**: 完善功能模块和标准化钩子脚本

#### 6. 重构 performance-monitor.sh (1.5小时)
```bash
# 修改内容:
1. 添加共享函数库引用
2. 替换ANALYTICS_DIR相关变量

# 具体修改位置:
- ANALYTICS_DATA_DIR → $ANALYTICS_DATA_DIR
- ANALYTICS_CACHE_DIR → $ANALYTICS_CACHE_DIR

# 验证方式:
1. 语法检查
2. 监控功能测试
```

#### 7. 重构 self-learning-engine.sh (1.5小时)
```bash
# 修改内容:
1. 添加共享函数库引用
2. 替换AI_DIR相关变量

# 具体修改位置:
- LEARNING_DIR → $AI_LEARNING_DIR
- LEARNING_MODELS_DIR → $AI_MODELS_DIR
- 等...

# 验证方式:
1. 语法检查
2. AI学习功能测试
```

#### 8. 重构 growth_init.sh (1小时)
```bash
# 修改内容:
1. 添加共享函数库引用
2. 替换GROWTH_DIR相关变量

# 验证方式:
1. 语法检查
2. 初始化功能测试
```

#### 9. 批量修改钩子脚本 (2小时)
```bash
# 需要修改的脚本:
- session-summary.sh
- rule-usage-tracker.sh
- command-log.sh
- security-audit.sh
- prompt-security.sh
- code-quality.sh

# 修改模式:
- 添加共享函数库引用
- $CURSOR_GROWTH/logs/ → $SYSTEM_LOGS_DIR/

# 验证方式:
- 批量语法检查
- 日志功能测试
```

### 补充任务: 检查其他脚本 (1天预留)

#### 10. 检查和修改其他脚本
```bash
# 需要检查的脚本:
- master-init.sh (特殊处理)
- context-manager.sh
- pattern-analyzer.sh
- continuous-learning-loop*.sh
- cursor-sync.sh
- logging.sh
- 其他使用旧变量的脚本

# 检查标准:
- 是否使用了旧的路径变量
- 是否有硬编码路径
- 是否需要重构使用共享函数
```

## ⚠️ 安全执行指南

### 每次修改的标准化流程

#### 1. 准备阶段 (10分钟)
```bash
# 备份脚本
cp script.sh script.sh.backup

# 检查当前使用情况
grep -n "旧变量名" script.sh
grep -n "硬编码路径" script.sh
```

#### 2. 修改阶段 (按计划执行)
```bash
# 添加共享函数库引用
sed -i '1a source "$SCRIPT_DIR/shared-functions.sh"' script.sh

# 添加项目上下文验证
sed -i '/shared-functions.sh/a validate_project_context || handle_error 1 "项目上下文验证失败"' script.sh

# 手动替换路径变量 (禁止自动替换)
# 使用编辑器逐个检查和修改
```

#### 3. 验证阶段 (20分钟)
```bash
# 语法检查
bash -n script.sh

# 删除.cursorGrowth测试
rm -rf .cursorGrowth
bash script.sh  # 测试脚本是否能生成正确目录结构

# 功能测试
# 检查是否生成了期望的目录
# 检查文件是否写到正确位置
```

#### 4. 记录阶段 (5分钟)
```bash
# 记录修改内容
echo "修改完成: script.sh" >> modification_log.txt
echo "- 添加了共享函数库引用" >> modification_log.txt
echo "- 替换了X处路径变量" >> modification_log.txt
echo "- 通过了语法和功能测试" >> modification_log.txt
```

## 📊 进度跟踪表

| 脚本名称 | 优先级 | 修改状态 | 验证状态 | 负责人 | 预估时间 |
|---------|--------|----------|----------|--------|----------|
| shared-functions.sh | 高 | ✅ 创建 | ✅ 测试 | AI | 2h |
| path-config.sh | 高 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 2h |
| growth-recorder.sh | 高 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 2h |
| growth-manager.sh | 高 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 2h |
| cursor-master.sh | 高 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 2h |
| performance-monitor.sh | 中 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 1.5h |
| self-learning-engine.sh | 中 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 1.5h |
| growth_init.sh | 中 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 1h |
| 钩子脚本(6个) | 低 | ⏳ 待修改 | ⏳ 待验证 | 开发者 | 2h |
| 其他脚本检查 | 低 | ⏳ 待检查 | ⏳ 待验证 | 开发者 | 4h |

## 🎯 质量保证措施

### 每日检查清单
- [ ] 所有修改的脚本通过语法检查
- [ ] 所有脚本在删除.cursorGrowth后能正确生成目录
- [ ] 项目上下文验证在所有脚本中正常工作
- [ ] 共享函数库被正确引用和使用
- [ ] 日志记录到正确的位置
- [ ] 配置文件读写正常工作

### 风险控制
- **备份策略**: 每个脚本都有完整的备份
- **回滚计划**: 如果发现问题可以立即回滚
- **测试环境**: 使用独立的测试环境验证
- **逐步推进**: 每天只修改少量脚本，确保质量

### 验收标准
- **功能验收**: 所有脚本能正常执行核心功能
- **路径验收**: 所有文件都写入正确的位置
- **性能验收**: 脚本执行效率不下降
- **兼容性验收**: 旧功能仍然可用
- **安全性验收**: 项目隔离机制正常工作

## 🚀 成功标志

Phase 2 完成时应该达到：
1. **所有高优先级脚本**完成修改和验证
2. **项目隔离机制**在所有脚本中生效
3. **目录结构**能够从干净状态正确生成
4. **共享函数库**被所有脚本正确使用
5. **向后兼容性**保持完整

准备好开始 Phase 2 了吗？🎯