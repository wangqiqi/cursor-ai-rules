# ❓ 常见问题解答 (FAQ)

*快速解决使用中的常见问题和疑难杂症*

## 🚀 快速开始相关

### Q: 如何开始使用Cursor AI Rules？
**A:** 按照以下步骤快速上手：

```bash
# 1. 获取项目文件
git clone https://github.com/wangqiqi/cursor-ai-rules.git

# 2. 复制到你的项目
cp -r cursor-ai-rules/.cursor /path/to/your-project/

# 3. 进入项目目录
cd /path/to/your-project

# 4. 运行初始化
./.cursor/core/init.sh

# 5. 开始使用
/master 你好，我想创建一个React项目
```

### Q: 系统支持哪些操作系统？
**A:** 完全跨平台支持：
- **Linux**: Ubuntu 18.04+, CentOS 7+, Debian 9+
- **macOS**: 10.15+ (Catalina及以上)
- **Windows**: Windows 10 2004+ (支持WSL2)

### Q: 需要哪些系统依赖？
**A:** 基础要求：
- **Cursor编辑器**: v0.40+
- **Git**: 2.0+
- **Bash**: 4.0+

可选依赖（推荐）：
- **Node.js**: 16.0+ (Web界面功能)
- **npm**: 7.0+ (依赖管理)

## 🎯 核心功能相关

### Q: /master命令不响应怎么办？
**A:** 按以下步骤排查：

```bash
# 1. 检查系统状态
/master 系统状态

# 2. 重新初始化
./.cursor/core/init.sh

# 3. 检查日志
tail -f .cursor/logs/system.log

# 4. 验证配置
/master 验证配置
```

### Q: 如何查看系统支持的所有功能？
**A:** 使用以下命令探索功能：

```bash
# 查看所有可用命令
/master 帮助

# 查看具体功能说明
/master 功能列表

# 获取使用示例
/master 示例 [功能名]
```

### Q: 宪法保护机制是什么？
**A:** 宪法保护是系统的核心安全机制：

**三大公理强制执行**:
1. **意图主权**: 用户意图优先，AI不可违背
2. **信号可信**: 所有输出附带验证链
3. **认知可审计**: 支持3秒内追溯推理过程

**自动触发场景**:
- 检测到"我想创建一个..."等项目创建意图
- 涉及敏感操作（如删除、覆盖）
- 超出权限范围的操作

## 🛠️ 配置与个性化

### Q: 如何备份和恢复配置？
**A:** 配置管理操作：

```bash
# 备份当前配置
/master 导出配置 backup.json

# 从备份恢复
/master 导入配置 backup.json

# 重置为默认配置
/master 重置配置
```

### Q: 配置文件在哪？如何修改？
**A:** 配置层次结构：

```
最高优先级: 运行时配置 (config/runtime.json)
     ↓
用户配置 (~/.cursor/config/user.json)
     ↓
项目配置 (config/project.json)
     ↓
全局配置 (config/global.json)
     ↓
最低优先级: 系统默认 (config/system-defaults.json)
```

**修改配置**:
```bash
# 设置项目配置
/master 设置配置 project.type nodejs

# 设置全局配置
/master 设置配置 global.language zh-CN
```

### Q: 配置不生效怎么办？
**A:** 配置问题排查：

```bash
# 1. 检查配置语法
/master 验证配置

# 2. 查看配置层级
/master 配置层级

# 3. 强制重新加载
/master 重新加载配置

# 4. 检查权限
ls -la .cursor/config/
```

## 🤖 AI人格角色系统

### Q: 如何切换AI人格角色？
**A:** 角色切换方法：

```bash
# 切换到专业助手
/master 切换角色 professional_assistant

# 使用昵称呼叫
/master 呼叫 小妮

# 查看当前角色
/master 当前角色

# 查看所有可用角色
/master 列出角色
```

### Q: 有哪些预设角色可用？
**A:** 21种预设角色分类：

**专业角色** (8个):
- `professional_assistant` - 专业助手 (默认)
- `humble_assistant` - 谦逊助手
- `friendly_partner` - 友好伙伴
- `expert_mentor` - 专家导师
- `creative_artist` - 创意艺术家
- `strict_teacher` - 严格老师
- `funny_comedian` - 幽默喜剧家
- `minimalist_zen` - 极简禅师

**特殊风格角色** (2个):
- `loyal_servant` - 忠诚仆人
- `seductive_assistant` - 魅惑助手

**动漫主题角色** (11个):
- `maid` - 完美女仆
- `queen_sister` - 御姐女王
- 等等...

### Q: 如何创建自定义角色？
**A:** 自定义角色开发：

```bash
# 1. 创建角色文件
mkdir -p config/roles

# 2. 编辑角色配置
cat > config/roles/custom-role.json << 'EOF'
{
  "id": "custom_mentor",
  "name": "自定义导师",
  "description": "专注于特定技术的导师",
  "attitude": "professional",
  "tone": "formal",
  "language_style": "concise",
  "language_patterns": {
    "greetings": ["你好", "欢迎咨询"],
    "agreement": ["好的", "我明白了"]
  }
}
EOF

# 3. 重启系统或热重载
./.cursor/core/restart.sh
```

## 🏗️ 系统架构相关

### Q: .cursor和.cursorGrowth目录有什么区别？
**A:** 双目录架构说明：

**.cursor/ 目录** (核心系统):
- **用途**: AI核心功能，规则引擎，脚本库
- **特性**: 可共享、可复制、标准化、版本化
- **内容**: 命令、核心引擎、规则、技能、文档等

**.cursorGrowth/ 目录** (生长数据):
- **用途**: 用户数据、学习记录、缓存文件
- **特性**: 隐私保护、本地化存储、自动管理
- **内容**: 用户偏好、学习数据、会话记录、性能指标

### Q: 系统如何进行环境感知？
**A:** 智能环境感知机制：

```bash
# 手动触发环境感知
./.cursor/core/env-perception.sh

# 查看感知结果
/master 项目信息

# 感知内容包括：
# - 技术栈识别 (React, Vue, Node.js等)
# - 依赖分析 (package.json, requirements.txt)
# - 项目结构 (src/, dist/, config/)
# - 配置文件检测 (.eslintrc, tsconfig.json等)
```

### Q: 如何查看系统运行状态？
**A:** 系统监控命令：

```bash
# 总体状态
/master 系统状态

# 性能指标
/master 性能监控

# 资源使用
/master 资源统计

# 日志查看
tail -f .cursor/logs/system.log
```

## 🔧 开发与扩展

### Q: 如何开发自定义技能？
**A:** 技能开发流程：

```javascript
// skills/custom-skill.skill.js
class CustomSkill {
  static id = 'custom-skill';
  static name = '自定义技能';
  static description = '描述技能功能';

  static parameters = [
    {
      name: 'input',
      type: 'string',
      required: true,
      description: '输入参数'
    }
  ];

  static async execute(context) {
    const { input } = context.parameters;

    // 技能实现逻辑
    const result = await processInput(input);

    return {
      success: true,
      data: result,
      message: '处理完成'
    };
  }
}

module.exports = CustomSkill;
```

### Q: 如何创建自定义规则？
**A:** 规则开发示例：

```javascript
// rules/custom-rule.rule.js
class CustomRule {
  static id = 'custom-rule';
  static name = '自定义规则';
  static description = '检查代码规范';

  static conditions = [
    {
      type: 'file',
      pattern: '\\.(js|ts)$',
      operator: 'match'
    }
  ];

  static actions = [
    {
      type: 'report',
      message: '发现代码问题: {{issue}}',
      severity: 'warning'
    }
  ];

  static validate(context) {
    // 规则验证逻辑
    return issues;
  }
}

module.exports = CustomRule;
```

### Q: 如何调试和故障排除？
**A:** 调试工具使用：

```bash
# 启用调试模式
export CURSOR_DEBUG=true

# 查看详细日志
tail -f .cursor/logs/debug.log

# 运行诊断工具
./.cursor/core/diagnostics.sh

# 生成系统报告
/master 系统诊断报告
```

## 🚨 故障排除

### Q: 系统响应变慢怎么办？
**A:** 性能优化措施：

```bash
# 1. 清理缓存
/master 清理缓存

# 2. 重启服务
./.cursor/core/restart.sh

# 3. 性能分析
/master 性能分析

# 4. 内存优化
/master 内存优化
```

### Q: 磁盘空间不足怎么办？
**A:** 存储空间管理：

```bash
# 查看存储统计
/master 存储统计

# 清理过期缓存
/master 清理过期数据

# 压缩日志文件
/master 压缩日志

# 优化数据存储
/master 数据优化
```

### Q: 如何完全重置系统？
**A:** 系统重置操作：

```bash
# ⚠️ 警告：此操作会清除所有用户数据

# 1. 备份重要数据
/master 导出数据 backup.zip

# 2. 停止所有服务
./.cursor/core/stop.sh

# 3. 清理生长数据
rm -rf .cursorGrowth/

# 4. 重新初始化
./.cursor/core/init.sh

# 5. 恢复备份数据
/master 导入数据 backup.zip
```

## 📞 获取帮助

### Q: 如何获取更多帮助？
**A:** 多种帮助渠道：

```bash
# 1. 内置帮助系统
/master 帮助
/master 帮助 [具体主题]

# 2. 查看文档
# 访问 docs/ 目录下的相关文档

# 3. 社区支持
# - GitHub Issues: 提交问题
# - Discussions: 参与讨论
# - Wiki: 查看详细指南
```

### Q: 发现Bug怎么办？
**A:** Bug报告流程：

```bash
# 1. 收集诊断信息
/master 生成诊断报告

# 2. 描述问题
# - 问题现象
# - 复现步骤
# - 期望行为
# - 实际行为

# 3. 提交Issue
# 在GitHub上创建详细的问题报告
```

### Q: 功能请求如何提交？
**A:** 功能请求提交：

```bash
# 1. 检查是否已存在
/master 功能列表 | grep "类似功能"

# 2. 描述需求
# - 功能场景
# - 解决的问题
# - 预期效果
# - 实现建议

# 3. 创建Feature Request
# 在GitHub上提交功能请求
```

---

## 📚 更多资源

- [快速开始](../getting-started.md) - 5分钟上手指南
- [完整使用指南](../user-guide.md) - 全面功能介绍
- [开发者文档](../developer/) - 扩展开发指南
- [配置管理](../admin/configuration.md) - 系统配置详解
- [API参考](../developer/api-reference.md) - 完整API文档

---

*最后更新: 2026-01-22 | 版本: v9.0.0 | 状态: ❓ 常见问题解答完成*