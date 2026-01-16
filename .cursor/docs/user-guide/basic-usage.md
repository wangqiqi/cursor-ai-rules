# 📖 基础使用指南

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 智能Master使用

直接用自然语言描述你的需求：

```bash
# 在Cursor对话框中
@master 我想创建一个React项目
@master 需要优化代码质量
@master 帮我分析项目现状

# 或者在命令行中
./cursor-master.sh "我想创建一个React项目"
```

## 🛠️ 传统规则引用

设置完成后，规则会自动应用。你也可以手动引用：

```markdown
@constitution - AI共生宪法
@intelligent_evolution - 智能进化建议
@system_info - 系统信息获取
```

## 💡 实际应用场景

### 代码审查时：
```
基于项目技术栈(JavaScript)和当前阶段(概念验证阶段)，
建议采用轻量级代码规范，重点关注基础语法正确性。
```

### 项目规划时：
```
检测到单人开发模式，建议采用敏捷开发流程：
- 每日代码提交
- 简化文档要求
- 快速原型验证
```

### 问题诊断时：
```
智能感知显示项目规模小，复杂度低，
推荐使用简单架构，避免过度设计。
```

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

---

*🎯 基础使用指南 - 让AI助手更好地理解你的需求*