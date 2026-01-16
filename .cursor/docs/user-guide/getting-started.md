# 🚀 快速开始 - Cursor AI Rules

欢迎使用Cursor AI Rules！这个指南将帮助您快速上手这个强大的AI编程助手系统。

## 📋 前置要求

### 系统要求
- **操作系统**: Linux, macOS, Windows
- **Cursor编辑器**: v0.40+
- **Git**: 2.0+
- **Bash**: 4.0+

### 环境准备
```bash
# 检查基本工具
git --version
node --version  # 可选，但推荐
npm --version   # 可选，但推荐
```

## ⚡ 快速安装

### 方法1：一键初始化（推荐）
```bash
# 1. 将.cursor目录放入项目根目录
cp -r /path/to/cursor-ai-rules/.cursor /path/to/your-project/

# 2. 运行一键初始化
cd /path/to/your-project
./.cursor/init.sh
```

### 方法2：核心初始化
```bash
# 运行核心初始化（仅基础功能）
./.cursor/core/init.sh
```

## 🎯 立即体验

### 第一个AI命令
```bash
# 在Cursor对话框中输入
@master 我想创建一个React项目
```

系统会：
1. 🤖 检测到项目创建意图
2. 📋 分析您的需求
3. 🛠️ 推荐技术方案
4. ❓ 提出澄清问题
5. 💡 等待确认后开始创建

### 探索更多功能
```bash
# 代码质量检查
@master 检查代码质量

# 项目分析
@master 分析项目现状

# 技术学习
@master 学习React
```

## 📚 核心概念

### 统一命令入口
所有功能都通过 `@master` 命令访问：
- **智能感知**: 自动理解您的意图
- **自动编排**: 智能组合所需功能
- **一键执行**: 无需记忆复杂命令

### 能力映射系统
系统内置了丰富的能力映射：
- **项目创建**: React, Vue, Python, Go等
- **代码质量**: ESLint, Prettier, 安全审计
- **文档处理**: Word, PDF, 演示文稿
- **开发工具**: Git工作流, 测试, 部署

## 🔧 基本配置

### 自动配置
初始化脚本会自动：
- ✅ 检测技术栈
- ✅ 配置质量工具
- ✅ 设置开发环境
- ✅ 启用推荐规则

### 自定义配置
如需自定义：
```bash
# 查看当前配置
./.cursor/config/config-manager.sh status

# 修改配置
./.cursor/config/config-manager.sh set .system.log_level debug
```

## 🚨 常见问题

### 初始化失败
```bash
# 检查权限
ls -la .cursor/init.sh

# 重新运行
./.cursor/init.sh
```

### 命令无响应
```bash
# 检查系统状态
@master status

# 验证环境
./.cursor/core/env-perception.sh
```

### 功能不工作
```bash
# 检查配置
./.cursor/config/config-manager.sh validate

# 查看日志（如果有）
tail -f ~/.cursor/logs/*.log
```

## 🎯 下一步

### 深入学习
1. **基本使用**: 阅读 `../usage-guide.md`
2. **高级功能**: 阅读 `../intelligent-evolution-guide.md`
3. **故障排除**: 阅读 `../usage-guide.md#故障排除`

### 探索功能
- 尝试不同的项目创建命令
- 体验代码质量检查功能
- 探索技能系统的各种能力

### 自定义配置
- 根据团队需求调整配置
- 添加自定义规则和技能
- 集成现有工作流

## 💡 提示

- **从简单开始**: 先体验基础功能，再深入高级特性
- **保持更新**: 定期更新到最新版本以获得新功能
- **寻求帮助**: 遇到问题时使用 `@master help` 或查看文档

---

🎉 恭喜！您已经成功开始了Cursor AI Rules之旅。享受AI赋能的编程体验！