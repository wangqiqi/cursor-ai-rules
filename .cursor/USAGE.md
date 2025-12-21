# AI共生项目规则 - 发布版本使用指南

## 📦 什么是这个发布版本？

这是一个可安全分享的 AI 协作规则系统，专为 Cursor 编辑器设计。下载后可以自动适配到任何人的本地环境。

## 🚀 快速开始

### 1. 下载和放置
```bash
# 将整个 public_cursor 目录下载到您的项目根目录
# 并重命名为 .cursor

your-project/
├── .cursor/          # ← 将发布版本放在这里
│   ├── README.md
│   ├── cursor-adaptation-setup.sh
│   └── rules/
└── 其他项目文件...
```

### 2. 自动适配
```bash
# 运行自动适配脚本
./.cursor/cursor-adaptation-setup.sh
```

脚本会自动：
- ✅ 获取您的本地时间和时区
- ✅ 读取您的 Git 配置信息
- ✅ 替换所有模板变量
- ✅ 创建备份（以防需要恢复）

### 3. 开始使用
适配完成后，规则会自动在 Cursor 中生效！

## 🎯 规则包含

| 规则 | 说明 | 适用范围 |
|------|------|----------|
| **constitution** | AI共生宪法 - 核心协作原则 | 始终应用 |
| **philosophy** | 协作模式 - 沟通准则 | 始终应用 |
| **evolution** | 规则演进指南 - 持续改进方法 | 智能应用 |
| **generator** | 规则生成器 - 自动化生成规则 | 代码文件 |
| **templates** | 配置模板 - 项目初始化配置 | 配置文件 |

## 🔧 高级用法

### 手动重置
如果需要重新适配或分享给他人：
```bash
# 脚本会将当前版本重置为通用模板版本
./.cursor/reset-to-template.sh  # (如果存在)
```

### 自定义规则
编辑相应规则文件：
```bash
.cursor/rules/[规则名]/RULE.md
```

## 📋 环境要求

- **Cursor 编辑器** (推荐最新版本)
- **Git** (用于获取用户信息)
- **Bash** (用于运行适配脚本)

## 🆘 故障排除

### 脚本无法运行
```bash
# 确保脚本有执行权限
chmod +x .cursor/cursor-adaptation-setup.sh
```

### Git 信息获取失败
```bash
# 检查 Git 配置
git config --get user.name
git config --get user.email

# 如果为空，请设置：
git config --global user.name "您的姓名"
git config --global user.email "您的邮箱"
```

### 时间戳不正确
脚本会自动使用系统本地时间。如果时区不正确，请检查系统设置。

## 📞 支持

这个规则系统是开源的，欢迎提交 Issue 或 Pull Request！

---

*最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>*
