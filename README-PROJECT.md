# 🚀 Cursor AI Rules - 项目级使用指南

## 📦 快速开始

将 `.cursor` 目录复制到你的任何项目中，即可获得完整的AI编程助手！

```bash
# 方法1: 从这个仓库复制
cp -r /path/to/cursor-ai-rules/.cursor ~/your-project/

# 方法2: 直接下载并解压
# 下载 .cursor 目录到你的项目中
```

## 🎯 四种使用方式

### 💬 对话框命令 `/master` (推荐)
在Cursor IDE对话框中输入：
```
/master 学习JavaScript
/master 创建一个React项目
/master 分析代码质量
```

### 📝 代码注释命令 `@master`
在代码注释中使用：
```javascript
// @master 我想创建一个React项目
// @master 优化这段代码的性能
// @master 分析这个函数的复杂度
```

### 🖥️ 终端脚本命令
```bash
# 在项目根目录运行
.cursor/cursor-master.sh 学习 React
.cursor/cursor-master.sh 创建项目
.cursor/cursor-master.sh 分析代码
```

### 🌐 Web图形界面
```bash
# 启动Web界面
cd .cursor/web
npm install
npm start

# 在浏览器中访问 http://localhost:3000
```

## 📁 项目结构

复制到你的项目后，结构如下：

```
your-project/
├── .cursor/                    # 🧠 AI助手核心
│   ├── cursor-master.sh       # 🖥️ 终端脚本
│   ├── LICENSE                 # 📄 许可证
│   ├── README.md              # 📚 中文文档
│   ├── README.en.md           # 📚 英文文档
│   ├── commands/              # 🎯 命令处理器
│   ├── core/                  # ⚙️ 核心引擎
│   ├── rules/                 # 📋 规则系统
│   ├── docs/                  # 📖 详细文档
│   ├── features/              # 🔧 高级功能
│   └── web/                   # 🌐 Web界面
└── your-code/                 # 你的项目代码
```

## ⚙️ 配置说明

### 1. 权限设置
```bash
# 确保脚本有执行权限
chmod +x .cursor/cursor-master.sh
chmod +x .cursor/web/server.js
```

### 2. Web界面依赖
```bash
# 安装Web界面依赖（可选）
cd .cursor/web
npm install
```

### 3. 项目特定配置
- 系统会自动适应你的项目类型
- 支持JavaScript, Python, Go, Rust等
- 自动检测技术栈和依赖

## 🚀 立即开始

1. **复制 `.cursor` 目录** 到你的项目
2. **在Cursor IDE中打开项目**
3. **开始使用AI助手**：
   - 输入 `/master` 开始对话
   - 在代码中添加 `// @master` 注释
   - 运行 `.cursor/cursor-master.sh` 脚本

## 💡 使用技巧

### 对话框使用
- `/master 学习[技术名]` - 获取学习资源
- `/master 创建[项目类型]` - 项目脚手架
- `/master 分析[代码问题]` - 智能分析

### 代码注释使用
- `// @master 解释这段代码` - 代码解释
- `// @master 重构这个函数` - 代码重构
- `// @master 优化性能` - 性能建议

### 终端使用
- 适合批量处理和CI/CD集成
- 支持复杂参数和管道操作
- 提供详细的执行日志

## 📚 更多资源

- **完整文档**: `.cursor/README.md`
- **Web界面**: `http://localhost:3000`
- **API文档**: `.cursor/docs/api/`

---

**🎉 现在你的项目也有AI编程助手了！**