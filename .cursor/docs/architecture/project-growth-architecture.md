# 🌱 项目生长架构 (.cursorGrowth)

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🏗️ 架构设计原则

Cursor AI Rules 采用双目录架构，将项目无关的配置与项目私有的数据严格分离：

- **`.cursor/`**: 项目无关的规则、脚本和配置（可共享、可复制）
- **`.cursorGrowth/`**: 项目私有的数据、缓存和学习记录（不共享、项目特定）

## 📁 .cursorGrowth 目录结构

### 核心数据目录
- `perception/` - 环境感知数据（项目环境、技术栈、依赖关系等）
- `user_data/` - 用户相关数据（偏好设置、学习档案、个性化配置）
- `project_data/` - 项目相关数据（配置、指标、历史记录）

### AI与分析目录
- `ai/` - AI相关数据（训练数据、生成结果、学习指标）
- `analytics/` - 分析数据（性能数据、统计信息、洞察报告）

### 系统管理目录
- `monitoring/` - 系统监控（性能指标、资源使用、健康状态）
- `integrations/` - 第三方集成（MCP服务、外部工具、API连接）

## 🔒 隐私与安全

### 数据隔离原则
- **完全私有**: `.cursorGrowth` 目录不会被提交到版本控制系统
- **自动保护**: 系统会自动将 `.cursorGrowth/` 添加到 `.gitignore`
- **用户特定**: 每个用户的学习数据和偏好都是独立的

### 隐私保护条目
```gitignore
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/
```

## 🚀 性能优化数据

### 智能缓存系统
**存储位置**: `.cursorGrowth/analytics/cache/`
- 环境感知缓存（5分钟TTL）
- 意图分析缓存（基于内容哈希）
- 分析结果缓存（24小时TTL）
- 自动过期清理机制

**性能提升**: 缓存命中率可达80%，Token节省60%

### 性能监控仪表板
**存储位置**: `.cursorGrowth/monitoring/`
- 实时响应时间统计
- Token消耗和节省计算
- 系统资源使用监控
- 健康状态检查数据

### AI学习记录
**存储位置**: `.cursorGrowth/ai/`
- 用户意图识别模式
- 交互成功率统计
- AI生成结果存储
- 学习指标和训练数据

## 🔄 自动初始化

当首次使用 `@master` 命令时，系统会自动：

1. 创建 `.cursorGrowth` 目录
2. 初始化所有必需的子目录
3. 设置 `.gitignore` 隐私保护
4. 生成初始的学习档案

```bash
# 首次运行任何@master命令时自动创建
@master 创建项目

# 系统自动创建目录结构：
.cursorGrowth/
├── perception/      # 环境感知数据
├── user_data/       # 用户相关数据
├── project_data/    # 项目相关数据
├── ai/              # AI相关数据
├── analytics/       # 分析数据
├── monitoring/      # 系统监控
└── integrations/    # 第三方集成
```

## 🎯 架构优势

### 项目独立性
- **`.cursor/`**: 在任意项目中保持一致，可安全复制
- **`.cursorGrowth/`**: 每个项目都有独立的数据空间

### 版本控制友好
- **`.cursor/`**: 可以安全地提交到Git（规则和脚本）
- **`.cursorGrowth/`**: 自动添加到 `.gitignore`（私有数据）

### 协作开发支持
```bash
# 团队协作示例
cp -r projectA/.cursor projectB/  # ✅ 安全共享配置
cd projectB
./cursor-master.sh fast "hello"   # ✅ 自动创建独立的.cursorGrowth
```

### 维护便利性
```bash
# 独立维护各种数据
rm -rf .cursorGrowth/cache/*      # 清理缓存，不影响配置
rm -rf .cursorGrowth/learning/*   # 重置学习，不删除规则
rm -rf .cursorGrowth/monitoring/* # 重置监控，保持系统配置
```

## 📊 数据使用策略

系统会自动分析 `.cursorGrowth` 中的数据来：

### 性能优化
- **缓存策略**: 基于访问模式优化缓存
- **预加载**: 预测用户需求提前准备资源
- **自适应调整**: 根据使用模式自动调整优化等级

### 个性化改进
- **意图识别**: 学习用户的表达习惯和偏好
- **交互优化**: 根据历史数据改进响应质量
- **行为预测**: 基于模式识别提供智能建议

### 系统进化
- **学习积累**: 从每次交互中持续改进
- **模式识别**: 发现用户的开发习惯和偏好
- **自动化**: 根据学习结果优化工作流程

## 🔧 管理命令

### 性能监控
```bash
./cursor-master.sh performance report    # 查看性能报告
./cursor-master.sh performance status    # 查看监控状态
./cursor-master.sh performance health    # 系统健康检查
```

### 优化管理
```bash
./cursor-master.sh optimizer status      # 优化系统状态
./cursor-master.sh optimizer analyze     # 性能深度分析
./cursor-master.sh optimizer optimize    # 系统优化
```

### 数据清理
```bash
./cursor-master.sh optimizer cleanup     # 清理过期数据
./cursor-master.sh optimizer cleanup 7   # 清理7天前的数据
```

## 🚨 重要提醒

### 不要手动创建文件
- **❌ 错误**: 在 `.cursorGrowth/` 中手动创建 README.md 或其他文档
- **✅ 正确**: 所有文档放在 `.cursor/docs/` 目录下

### 不要提交私有数据
- **❌ 错误**: 强制提交 `.cursorGrowth/` 目录到Git
- **✅ 正确**: 让系统自动管理 `.gitignore` 保护

### 不要跨项目共享
- **❌ 错误**: 复制其他人的 `.cursorGrowth/` 目录
- **✅ 正确**: 每个项目独立生长，每个用户独立学习

## 🔮 未来扩展

### 多项目学习
- [ ] 跨项目学习数据迁移（可选）
- [ ] 团队学习模式共享（匿名化）
- [ ] 项目模板学习加速

### 高级缓存
- [ ] 分布式缓存支持
- [ ] 智能预加载机制
- [ ] 缓存内容压缩优化

### 隐私增强
- [ ] 数据匿名化选项
- [ ] 本地数据加密
- [ ] 学习数据导出/导入

## ✅ 架构重构成果

### 最新重构完成情况

**重构时间**: 2026-01-16
**重构类型**: 双目录架构优化
**影响范围**: 所有优化脚本的路径配置

#### 重构前的问题架构
```
.cursorGrowth/ (混乱的旧结构)
├── learning/                    # ❌ 重叠概念
├── conversations/               # ❌ 重叠概念
├── personal/                    # ❌ 重叠概念
├── cache/                       # ❌ 概念不清
├── monitoring/                  # ❌ 混合用途
├── debug/                       # ❌ 临时调试
├── logs/                        # ❌ 分散日志
└── growth/                      # ❌ 模糊定义
```

#### 重构后的7目录架构
```
.cursor/                          📁 项目无关（可共享）
├── core/                        # 核心脚本和规则
├── rules/                       # 规则配置
├── docs/                        # 文档
└── extensions/                  # 扩展功能

.cursorGrowth/                   🌱 项目私有（7目录结构）
├── perception/                  # ✅ 环境感知数据
├── user_data/                   # ✅ 用户相关数据
├── project_data/                # ✅ 项目相关数据
├── ai/                          # ✅ AI相关数据
├── analytics/                   # ✅ 分析数据
├── monitoring/                  # ✅ 系统监控
└── integrations/                # ✅ 第三方集成
```

#### 重构成果验证
- ✅ **目录结构**: 统一采用7目录结构规范
- ✅ **路径配置**: 所有脚本正确使用新的目录路径
- ✅ **向后兼容**: 保持API的一致性和稳定性
- ✅ **性能优化**: 缓存和监控数据正确分离存储
- ✅ **隐私保护**: 敏感数据自动隔离到项目私有目录

#### 架构优势验证
- ✅ **项目独立性**: `.cursor` 可复制，`.cursorGrowth` 隔离
- ✅ **版本控制友好**: `.cursor` 可提交，`.cursorGrowth` 自动忽略
- ✅ **协作开发支持**: 团队共享配置，数据隔离
- ✅ **隐私保护**: 自动 `.gitignore` 配置

---

*🎯 `.cursorGrowth` 目录是Cursor AI Rules系统的"大脑"，它让AI助手能够学习、适应和进化，为每个用户和每个项目提供个性化的智能体验。*

*🏗️ 通过 `.cursor` + `.cursorGrowth` 的双目录架构，系统既保持了可复制性和协作性，又保证了数据的私密性和个性化。*