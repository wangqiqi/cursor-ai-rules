# 🚀 Cursor AI Rules 快速开始指南

欢迎使用 Cursor AI Rules！这是一个智能的 AI 协作增强系统，能够自动适配你的项目环境并提供个性化的 AI 协作体验。

## 📦 安装和初始化

### 自动安装（推荐）

```bash
# 1. 下载项目
git clone https://github.com/your-repo/cursor-ai-rules.git
cd cursor-ai-rules

# 2. 复制到你的项目
cp -r .cursor /path/to/your-project/

# 3. 进入项目并初始化
cd /path/to/your-project
.cursor/bootstrap/init.sh
```

### 手动安装

```bash
# 1. 创建.cursor目录
mkdir .cursor

# 2. 下载并解压最新版本
# 从GitHub Releases下载最新版本

# 3. 初始化
.cursor/bootstrap/init.sh
```

## 🔍 系统自检

运行初始化后，系统会自动：

1. **环境检测** - 检测你的操作系统、编程环境和工具链
2. **项目分析** - 识别技术栈、团队规模和项目成熟度
3. **配置生成** - 自动生成适合你项目的配置
4. **规则激活** - 启用相关的 AI 协作规则
5. **技能安装** - 安装适配的技术技能

## 🎯 核心功能

### 智能规则系统
- 📋 **自动规则激活** - 根据项目特点自动启用相关规则
- 🧠 **智能感知** - 理解你的编码意图和项目上下文
- 📈 **持续优化** - 基于使用习惯持续改进协作体验

### 自适应技能库
- 🎨 **按需安装** - 只安装你需要的技能
- 🔧 **自动检测** - 根据技术栈自动推荐技能
- 📚 **技能市场** - 从社区获取更多专业技能

### 自动化工作流
- ⚡ **智能钩子** - 在关键时刻自动执行相关任务
- 🤖 **脚本工具** - 提供常用的开发和维护脚本
- 🔄 **持续集成** - 与你的开发流程无缝集成

## 💡 使用示例

### 项目初始化
```bash
# 初始化新项目
.cursor/bootstrap/init.sh

# 查看项目状态
.cursor/automation/scripts/env-check.sh

# 重新检测环境
.cursor/bootstrap/detect.sh
```

### 配置管理
```bash
# 合并配置
.cursor/config/merge-config.sh

# 查看当前配置
cat .cursor/config/merged.json | jq .merged.features

# 自定义配置
# 编辑 .cursor/config/overrides.json
```

### 规则和技能管理
```bash
# 查看激活的规则
ls .cursor/rules/*.md

# 查看已安装技能
ls .cursor/skills/active/

# 手动安装技能
.cursor/automation/scripts/skill-install.sh <skill-name>
```

## ⚙️ 自定义配置

### 用户覆盖配置

编辑 `.cursor/config/overrides.json`：

```json
{
  "overrides": {
    "system": {
      "log_level": "debug"
    },
    "features": {
      "automation": {
        "scheduling": true
      }
    }
  },
  "disabled": {
    "hooks": ["performance-monitor"],
    "skills": ["unused-skill"]
  }
}
```

### 环境变量

```bash
# 自定义日志目录
export CURSOR_LOGS_DIR="/custom/logs"

# 禁用自动更新
export CURSOR_AUTO_UPDATE=false

# 设置代理
export CURSOR_PROXY="http://proxy.company.com:8080"
```

## 🔧 故障排除

### 常见问题

#### 初始化失败
```bash
# 检查权限
ls -la .cursor/
chmod +x .cursor/bootstrap/*.sh

# 重新运行检测
.cursor/bootstrap/detect.sh

# 查看详细日志
tail -f .cursor/logs/detection.log
```

#### 配置问题
```bash
# 重置配置
rm .cursor/config/project.json
.cursor/bootstrap/init.sh

# 验证配置
.cursor/config/merge-config.sh
cat .cursor/config/merged.json
```

#### 技能安装失败
```bash
# 检查网络连接
curl -I https://api.github.com

# 手动安装技能
.cursor/automation/scripts/skill-install.sh --force <skill-name>

# 查看技能日志
tail -f .cursor/logs/skill-install.log
```

## 📞 获取帮助

- 📖 **文档**: `.cursor/docs/`
- 🐛 **问题**: [GitHub Issues](https://github.com/your-repo/issues)
- 💬 **讨论**: [GitHub Discussions](https://github.com/your-repo/discussions)
- 📧 **邮件**: support@cursor-ai-rules.com

## 🎉 下一步

1. **探索功能** - 尝试不同的AI协作场景
2. **自定义配置** - 根据团队需求调整配置
3. **贡献技能** - 开发和分享新的专业技能
4. **参与社区** - 加入用户社区，分享经验

---

*最后更新: 2024-01-15 | Cursor AI Rules v4.2.0*