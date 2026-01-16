# 🚀 Cursor AI Rules - 让AI成为你的超级编程伙伴

[![Cursor](https://img.shields.io/badge/Cursor-AI-blue?style=for-the-badge&logo=cursor&logoColor=white)](https://cursor.com)
[![Version](https://img.shields.io/badge/version-4.3.0-green?style=for-the-badge)](https://github.com/wangqiqi/cursor-ai-rules/releases)
[![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)](LICENSE)

[![Rules](https://img.shields.io/badge/rules-21-blue?style=flat-square)]()
[![Scripts](https://img.shields.io/badge/scripts-3-orange?style=flat-square)]()

🌍 **[English](README.en.md) | [中文](README.md)**

**🌟 颠覆性的AI编程协作体验 - 让AI真正理解你的项目和需求**

📚 **[快速开始](.cursor/docs/quick-start.md)** | **[基础使用](.cursor/docs/user-guide/basic-usage.md)** | **[详细指南](.cursor/docs/usage-guide.md)** | **[高级配置](.cursor/docs/user-guide/advanced-config.md)** | **[开发规范](.cursor/docs/development-guidelines.md)**

采用 [Cursor 规则系统](https://cursor.com/cn/docs/context/rules) 定义的 AI 协作规范，结合单步多任务感知、智能缓存和规则系统，实现高效、安全的人机协作。

## 🤝 核心协作原则

这是一个专为人机高效协作而设计的智能AI协作系统。

### 人类意图主权
- 人类决策始终优先于AI建议
- AI提供选项，人类做出最终选择
- 所有AI操作都需要人类确认

### 信号透明性
- AI必须解释推理过程和数据来源
- 所有输出都应可追溯和可验证
- 明确标注信息来源归属

### 安全协作
- 不自动执行破坏性操作
- 所有系统变更都需要明确批准
- 对所有建议进行风险评估

## 🏗️ 系统架构

### 双目录设计
Cursor AI Rules 采用创新的双目录架构：

- **`.cursor/`** 📁 **项目无关配置**
  - 规则定义、核心脚本、文档
  - 可安全复制到任意项目
  - 支持版本控制和团队共享

- **`.cursorGrowth/`** 🌱 **项目私有数据**
  - AI学习记录、缓存数据、性能监控
  - 每个项目独立生长，用户数据隔离
  - 自动添加到 `.gitignore` 保护隐私

### 架构优势
- **🔄 可复制性**: `.cursor` 目录可在任意项目间复制
- **🔒 隐私保护**: `.cursorGrowth` 数据完全私有不共享
- **👥 协作友好**: 团队共享配置，每个人的数据都是独立的
- **⚡ 性能优化**: 本地缓存和学习数据提升响应速度

**📖 [详细架构说明](.cursor/docs/project-growth-architecture.md)**

## 🛠️ 开发指南

### 代码质量
- 遵循既定的编码标准
- 优先考虑可读性和可维护性
- 包含适当的文档说明

### 项目结构
- 保持有组织的文件结构
- 使用一致的命名约定
- 保持依赖项更新

## 📋 工作流集成

### 规则系统
- 利用 `.cursor/rules` 提供专门指导
- 根据上下文和文件类型应用规则
- 组合多个规则以实现全面覆盖

### 智能功能
- 利用自动环境检测
- 使用感知系统进行项目分析
- 应用自适应规则优化

## 🌍 语言支持

### 多语言项目
- 自动检测技术栈
- 语言特定的最佳实践
- 跨平台兼容性

### 国际化
- 支持多种人类语言
- 提供双语文档
- 对全球开发者社区友好

## 🔧 技术环境

### 支持平台
- Linux、macOS、Windows
- 各种CPU架构

### 工具集成
- 自动工具链检测
- 编译器和构建工具支持
- 开发环境适配

## ⚡ 核心特性

| 特性 | 说明 | 效果 |
|------|------|------|
| 🧠 **统一智能命令入口** | `@master` 一键唤醒所有能力，自然语言驱动AI协作 | **零记忆负担** |
| 🎯 **单步多任务感知** | 一次性完成所有项目分析，4层架构智能编排 | **Token节省 60%** |
| ⚙️ **分层配置管理系统** | 5层配置体系，支持动态配置和验证 | **配置灵活性 95%↑** |
| 🔧 **统一质量保障体系** | 分层质量检查(Lint/Format/Audit/Report) | **代码质量 80%↑** |
| 🏗️ **4层架构重构** | Core/Config/Quality/Features清晰职责划分 | **维护性 75%↑** |
| 💾 **智能缓存系统** | 基于文件变化的缓存机制 | **响应速度 5x提升** |
| 🛡️ **优雅降级** | 环境检测和容错处理 | **稳定性 99.9%** |
| 🔓 **开箱即用** | 无需配置，复制即用 | 支持任何项目、任何语言 |

## 📋 智能规则系统

| 规则 | 描述 | 应用方式 | 状态 |
|------|------|----------|------|
| **master** | 智能Master控制器 - 自动感知需求并智能执行内部命令 | 始终应用 | ✅ |
| **constitution** | AI共生宪法 - 人机协作核心原则 | 始终应用 | ✅ |
| **philosophy** | 交流哲学与协作模式 | 始终应用 | ✅ |
| **intelligent_evolution** | 智能演进系统 - 统一协调感知和进化 | 智能应用 | ✅ |
| **generator** | 项目规则生成器 - 自动化生成个性化规则配置 | 代码文件 | ✅ |
| **system_info** | 系统信息获取器 - 自动获取时间、路径、作者信息 | 始终应用 | ✅ |
| **templates** | 配置模板 - 自动化生成项目初始化配置 | 配置文件 | ✅ |
| **i18n** | 国际化支持系统 - 自动检测语言偏好并切换沟通 | 始终应用 | ✅ |
| **platform_adapter** | 跨平台适配器 - 统一管理不同OS间的命令、路径和环境 | 始终应用 | ✅ |
| **module_manager** | 规则管理系统 - 管理规则依赖关系、激活控制和扩展机制 | 始终应用 | ✅ |
| **eslint** | ESLint代码质量检查 - 自动检测和修复JavaScript代码问题 | 始终应用 | ✅ |
| **evolution-philosophy** | 演进哲学 - 规则演进的核心理念和原则 | 智能应用 | ✅ |
| **evolution-manual** | 手动演进流程 - 人工触发的规则演进管理 | 智能应用 | ✅ |
| **evolution-automation** | 自动化演进系统 - 基于感知数据的智能优化 | 智能应用 | ✅ |
| **evolution-governance** | 演进治理机制 - 规则演进的安全保障和质量控制 | 智能应用 | ✅ |
| **collaboration** | 团队协作规则 - 多开发者环境的最佳实践 | 智能应用 | ✅ |
| **conversation_intent_analyzer** | 会话意图分析器 - 智能理解用户需求和意图 | 始终应用 | ✅ |
| **vibe-coding** | VIBE Coding开发原则 - 文档驱动、测试先行、前后端对齐 | 代码文件 | ✅ |
| **rules-router** | 规则路由系统 - 智能分发和管理规则请求 | 始终应用 | ✅ |
| **javascript** | JavaScript/TypeScript开发规则 - 现代前端开发最佳实践 | 代码文件 | ✅ |
| **python** | Python开发规则 - 后端开发和数据处理最佳实践 | 代码文件 | ✅ |

### 🎯 Skills扩展系统 (20个专业技能)

| 技能分类 | 技能数量 | 功能描述 | 状态 |
|----------|----------|----------|------|
| **文档处理** | 4个 | docx, pdf, pptx, xlsx - Office文档处理和转换 | ✅ 全部集成 |
| **创意设计** | 5个 | algorithmic-art, canvas-design, frontend-design, theme-factory, slack-gif-creator | ✅ 全部集成 |
| **AI集成** | 5个 | mcp-builder, skill-creator, node_mcp_server, python_mcp_server, mcp_specification | ✅ 全部集成 |
| **企业协作** | 3个 | brand-guidelines, internal-comms, doc-coauthoring | ✅ 全部集成 |
| **测试开发** | 3个 | webapp-testing, web-artifacts-builder, evaluation | ✅ 全部集成 |

## 🚀 快速开始

开始使用Cursor AI Rules的推荐方式：

```bash
cd your-project
# 将 .cursor 目录放入项目根目录

# 🚀 智能Master - 自然语言驱动，AI自动编排所有操作
@master 我想创建一个React项目
```

**📖 [完整快速开始指南](.cursor/docs/quick-start.md)**

## 🎛️ 核心特性

### 🧠 统一智能入口
`@master` 命令让AI自动理解你的意图，智能编排规则、技能和脚本。

### 🎯 单步多任务感知
一次分析完成所有项目感知，4层架构智能协作。

### ⚙️ 分层配置管理系统
5层配置体系，支持动态配置和验证。

### 🔧 统一质量保障
分层质量检查(Lint/Format/Audit/Report)。

### 🏗️ 4层架构重构
Core/Config/Quality/Features清晰职责划分。

### 💾 智能缓存系统
基于文件变化的缓存机制。

### 🛡️ 开箱即用
支持任何项目、任何语言，无需配置。

**📖 [详细功能介绍](.cursor/docs/user-guide/core-features.md)**

## 🔧 高级配置

### 自定义规则
1. 编辑规则文件：`.cursor/rules/*/RULE.md`
2. 遵循frontmatter格式
3. 更新版本号

### 性能调优
```bash
# 重新运行感知分析
./.cursor/core/env-perception.sh

# 检查环境
./.cursor/core/env-perception.sh
```

## 📦 分发与部署

### 快速部署
```bash
# 方法1：复制.cursor目录到项目根目录（推荐）
cp -r /path/to/cursor-ai-rules/.cursor /path/to/your-project/
cd /path/to/your-project
./.cursor/core/init.sh

# 方法2：从Git仓库克隆（如果已发布）
# git clone <your-repo-url> cursor-ai-rules
# cp -r cursor-ai-rules/.cursor your-project/
# cd your-project && ./.cursor/core/init.sh
```

**特点：**
- 🔄 **自动适配**: 系统自动检测项目环境，无需手动配置
- 🌍 **多语言支持**: 支持JavaScript、Python、Go、Rust、Java、C/C++等多种语言
- 👤 **用户无关**: 使用Git配置或通用默认值，无硬编码用户信息
- 📁 **项目无关**: 自动分析项目结构和团队动态

### 企业部署
```bash
# 批量部署到多个项目
for project in project1 project2 project3; do
  cp -r .cursor "$project/"
  cd "$project"
  ./.cursor/core/init.sh
  cd ..
done
```

**适用场景：**
- 🏢 **企业环境**: 统一团队协作规范
- 👥 **多项目管理**: 标准化开发流程
- 🔄 **持续集成**: 自动环境适配和规则同步

## 🆘 故障排除

### 智能诊断
```bash
# 一键诊断所有问题
./.cursor/core/init.sh --help

# 环境完整性检查
./.cursor/core/env-perception.sh
```

### 常见问题

**Q: 初始化失败？**
```bash
# 检查权限和环境
ls -la .cursor/core/init.sh
./.cursor/core/env-perception.sh
```

**Q: 设置问题？**
```bash
# 重新运行环境检查
./.cursor/core/env-perception.sh
# 重新运行设置
./.cursor/core/init.sh
```

## 🤝 贡献指南

### 规则优化
1. 在不同项目中测试新规则
2. 确保向后兼容性
3. 更新文档和示例

### 性能改进
- 关注Token消耗优化
- 测试缓存机制效果
- 验证规则执行性能

## 📊 技术指标

| 指标 | v1.0 | v4.2.0 | v4.3.0 | 提升 |
|------|------|------|-------|------|
| 初始化时间 | ~30s | ~5s | ~3s | **90%↑** |
| 感知耗时 | ~10s | ~1s | ~0.5s | **95%↑** |
| Token节省 | 基准 | 60%↓ | 70%↓ | **70%↑** |
| 组件数量 | 42个 | 42个 | 38个 | **9.5%↓** |
| 文件总数 | 100+ | 77个 | 171个 | **122%↑** |
| 配置灵活性 | 基础 | 中等 | 高 | **95%↑** |
| 维护性 | 基准 | +60% | +75% | **显著提升** |
| 扩展性 | 有限 | 无限 | 智能 | **AI驱动** |

## 📋 环境要求

- **Cursor 编辑器** v0.40+
- **Git** 2.0+
- **Bash** 4.0+
- **jq** (JSON处理器，可选但推荐)

---

## 🎯 开箱即用特性

### 无关项目
- ✅ 自动检测技术栈（JavaScript、Python、Go、Rust、Java、C/C++等）
- ✅ 智能分析团队规模和开发阶段
- ✅ 动态适配项目复杂度要求
- ✅ 无硬编码项目特定信息

### 无关用户
- ✅ 使用Git配置获取用户信息
- ✅ 支持无Git环境的通用默认值
- ✅ 自动获取本地时间和时区
- ✅ **自动隐私保护**: 主动管理 `.gitignore`，防止敏感数据泄露

### 无关语言
- ✅ 自动检测项目文件结构
- ✅ 支持主流编程语言
- ✅ 智能推荐语言特定最佳实践
- ✅ 可扩展新语言支持

### 自主感知和进化
- ✅ 单步多任务项目分析
- ✅ 持续学习用户协作偏好
- ✅ 基于数据驱动的规则优化
- ✅ 渐进式系统进化

---

## 🌱 项目生长系统 (.cursorGrowth)

### 🎯 智能生长目录

系统会在项目根目录**首次使用时**自动创建 `.cursorGrowth` 目录，用于存储项目私有信息和生长数据。

#### 🔒 自动隐私保护

系统会**自动管理**项目根目录的 `.gitignore` 文件，确保生长数据不会被意外提交：

- **新项目**: 自动创建包含隐私保护规则的 `.gitignore` 文件
- **现有项目**: 在现有 `.gitignore` 文件开头添加 `.cursorGrowth/` 忽略规则
- **验证生效**: 自动验证Git忽略规则是否正确生效

**隐私保护条目**:
```gitignore
# Cursor AI 生长数据 - 自动感知和学习
# 这些数据包含用户偏好、本地配置和学习数据，不应在仓库中跟踪
.cursorGrowth/
```

```bash
# 首次运行任何@master命令时自动创建
@master 创建React项目

# 系统自动创建目录结构：
.cursorGrowth/
├── README.md                     # 生长目录说明
├── learning/                     # AI学习数据
│   ├── profile.json             # 用户和项目学习档案
│   └── master_interactions.json # 交互历史
├── conversations/               # 对话记录
│   └── session_*.json          # 每次对话的详细记录
├── debug/                       # 调试信息
│   └── error_*.json            # 错误和异常记录
├── growth/                      # 生长指标
│   └── metrics.json            # 项目生长统计
└── personal/                    # 个性化数据
    └── user_profile.json       # 用户偏好和习惯
```

### 📊 自动记录的数据类型

#### **学习数据 (learning/)**
- 用户意图识别模式和准确率
- 成功执行的命令组合模式
- 失败案例和改进建议
- 个性化偏好学习

#### **对话历史 (conversations/)**
- 每次与AI助手的完整对话记录
- 意图识别结果和决策过程
- 执行结果和用户反馈
- 项目上下文信息

#### **调试信息 (debug/)**
- 执行失败的详细错误信息
- 系统异常和边界情况
- 性能问题和瓶颈分析
- 故障排除建议

#### **生长指标 (growth/)**
- 总交互次数统计
- 成功率趋势
- 意图类型分布分析
- 每日活跃度跟踪

#### **个性化资料 (personal/)**
- 用户语言偏好自动检测
- 常用意图类型统计
- 交互风格和偏好分析

### 🧠 智能学习机制

#### **自动学习 (每次调用)**
```bash
# 每次使用@master命令时，系统自动：
1. 📝 记录用户输入和意图识别结果
2. 📊 更新学习统计和模式分析
3. 👤 累积个性化偏好数据
4. 📈 计算生长指标和趋势
5. 🧠 优化未来响应策略
```

#### **主动学习 (指定命令)**
```bash
# 主动触发深度学习
@master 学习项目模式     # 分析.cursorGrowth数据
@master 优化我的偏好     # 基于历史数据调整AI行为
@master 分析使用习惯     # 生成详细使用分析报告
@master 显示生长状态     # 显示项目生长状态
```

### 🔒 隐私和安全

#### **数据保护措施**
- `.cursorGrowth` 目录**不会被提交**到版本控制
- 所有数据存储在本地项目目录
- 自动生成隐私保护说明
- 符合隐私保护最佳实践

#### **数据使用原则**
- 数据仅用于改进AI助手服务质量
- 不会上传到外部服务器
- 用户可以随时查看、导出或删除数据
- 支持数据匿名化和隐私模式

### 📈 生长可视化

#### **查看生长状态**
```bash
@master 显示生长状态    # 查看项目生长指标
@master 分析学习进度    # 显示AI学习成果
@master 生成成长报告    # 完整的生长分析报告
```

#### **生长指标示例**
```
🌱 项目生长状态 (2026-01-16)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 总交互次数: 45次
✅ 成功率: 92%
🎯 最常用意图: 项目创建 (40%), 代码优化 (35%)
📈 学习改进: +15% 意图识别准确率
👤 用户偏好: 中文界面, React技术栈
📅 活跃天数: 12天
```

### 🎓 学习命令详解

#### **@master 学习项目模式**
- 分析.cursorGrowth/learning/中的数据
- 识别用户行为模式和偏好
- 优化未来命令响应准确性
- 生成个性化使用建议

#### **@master 优化我的偏好**
- 分析用户交互历史
- 根据用户偏好调整AI行为
- 提升意图识别准确率
- 个性化交互风格

#### **@master 分析使用习惯**
- 生成详细的使用统计报告
- 识别效率提升机会
- 提供使用优化建议
- 预测未来使用趋势

---

*🌱 Cursor AI Rules v4.3.0 - 智能生长系统让AI助手持续进化，项目随着每次交互而生长！*

*核心创新*: 从静态工具到动态生长实体，从单次交互到持续学习，从通用AI到个性化助手！

*🚀 Cursor AI Rules v4.3.0 - 统一智能入口，4层架构重构，AI真正成为编程助手*
*最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*
*基于 Cursor 官方规范，集成智能感知、决策和进化系统*
