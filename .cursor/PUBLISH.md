# 🚀 AI共生项目规则系统 - 发布包

## 📦 发布信息

- **版本**: v1.0.0
- **发布日期**: 2025年12月
- **适用环境**: Cursor 编辑器
- **开源协议**: MIT

## 📁 包内容

```
ai-symbiosis-cursor-rules-v1.0.0/
├── README.md                          # 规则总览
├── USAGE.md                           # 详细使用指南
├── cursor-adaptation-setup.sh         # 自动适配脚本
├── rules/                             # 规则文件目录
│   ├── constitution/RULE.md          # AI共生宪法
│   ├── philosophy/RULE.md            # 协作哲学
│   ├── evolution/RULE.md             # 规则演进指南
│   ├── generator/RULE.md             # 规则生成器
│   └── templates/                     # 配置模板
│       ├── RULE.md
│       └── templates.json
└── PUBLISH.md                        # 本文件
```

## 🎯 核心特性

### ✨ 智能适配
- **自动环境检测**: 获取本地时间和Git用户信息
- **模板变量替换**: 支持 `{{AUTHOR_NAME}}`、`{{GENERATION_TIME}}` 等变量
- **一键设置**: 运行脚本即可完成个性化配置

### 🛡️ 安全与隐私
- **无敏感信息**: 不包含任何个人隐私数据
- **本地处理**: 所有适配都在用户本地完成
- **可追溯**: 所有更改都有备份和日志

### 🔧 易于扩展
- **模块化设计**: 每个规则独立，可单独定制
- **标准格式**: 遵循 Cursor 官方规则规范
- **版本控制**: 支持规则的演进和更新

## 🚀 快速开始

### 下载与安装
```bash
# 1. 下载发布包
wget https://example.com/ai-symbiosis-cursor-rules-v1.0.0.tar.gz

# 2. 解压到项目根目录
tar -xzf ai-symbiosis-cursor-rules-v1.0.0.tar.gz
mv ai-symbiosis-cursor-rules-v1.0.0 .cursor

# 3. 运行适配脚本
./.cursor/cursor-adaptation-setup.sh
```

### 验证安装
```bash
# 检查规则是否生效
cursor --version  # 确保 Cursor 正在运行
```

## 📋 使用指南

详细的使用说明请参考 [`USAGE.md`](USAGE.md) 文件。

## 🔄 更新规则

### 升级到新版本
```bash
# 1. 下载新版本
wget https://example.com/ai-symbiosis-cursor-rules-v2.0.0.tar.gz

# 2. 备份当前配置
cp -r .cursor .cursor.backup

# 3. 覆盖安装
tar -xzf ai-symbiosis-cursor-rules-v2.0.0.tar.gz
mv ai-symbiosis-cursor-rules-v2.0.0 .cursor

# 4. 重新适配
./.cursor/cursor-adaptation-setup.sh
```

### 自定义规则
```bash
# 编辑特定规则
vim .cursor/rules/[规则名]/RULE.md

# 提交更改
git add .cursor/
git commit -m "自定义规则配置"
```

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发环境设置
```bash
# 1. Fork 本仓库
# 2. 克隆到本地
git clone https://github.com/your-username/ai-symbiosis-cursor-rules.git

# 3. 创建模板版本用于测试
./.cursor/reset-to-template.sh

# 4. 测试适配脚本
./.cursor/cursor-adaptation-setup.sh
```

## 📞 支持与反馈

- **GitHub Issues**: https://github.com/your-repo/issues
- **讨论区**: https://github.com/your-repo/discussions
- **邮箱**: your-email@example.com

## 📜 开源协议

本项目采用 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。

---

*AI共生项目规则系统致力于提升人机协作效率，为开发者提供更好的AI协作体验。*
