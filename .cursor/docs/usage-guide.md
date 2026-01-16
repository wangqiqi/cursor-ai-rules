# 📖 Cursor AI Rules 使用指南

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 快速开始

### 智能Master一键初始化

```bash
cd your-project
# 将 .cursor 目录放入项目根目录

# 🚀 智能Master - 自然语言驱动，AI自动编排所有操作
@master 我想创建一个React项目     # AI自动感知并执行完整流程
@master 需要优化代码质量           # 自动触发质量检查和修复
@master 帮我分析项目现状           # 智能生成项目分析报告
```

**AI智能编排流程：**
1. 🧠 **意图理解**: AI自动解析你的需求
2. ⚡ **智能组合**: 自动选择规则+技能+脚本+工作流
3. 🎯 **一键执行**: 零配置，AI自动处理所有细节
4. 📊 **实时反馈**: 提供详细的执行报告和建议

### 传统手动设置

```bash
# 统一初始化 (替代所有旧脚本)
./.cursor/core/init.sh

# 环境感知分析
./.cursor/core/env-perception.sh

# 质量检查管理
./.cursor/quality/quality-manager.sh
```

## 🛠️ 核心功能

### 1. 智能Master控制器

#### 自然语言驱动
```bash
# 在Cursor对话框中
@master 我想创建一个React项目
@master 需要优化代码质量
@master 帮我分析项目现状

# 或者在命令行中
./cursor-master.sh "我想创建一个React项目"
```

#### 智能命令识别
- **项目创建**: `创建React项目`, `新建Vue应用`, `初始化Node.js项目`
- **代码质量**: `代码检查`, `格式化代码`, `修复ESLint错误`
- **项目分析**: `分析项目`, `查看依赖`, `检查配置`

### 2. 环境感知系统

#### 自动检测技术栈
```bash
# 单步执行所有分析
./.cursor/core/env-perception.sh
```

**检测内容:**
- 🏗️ **项目架构**: 文件结构分析
- 👥 **团队规模**: Git贡献者统计
- 📊 **开发阶段**: 代码成熟度评估
- 🌍 **技术栈**: 自动识别编程语言和框架
- 🔧 **工具链**: 检测构建工具和依赖管理器

#### 感知结果示例
```
📊 项目分析报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏗️ 架构类型: 前端应用
👥 团队规模: 个人项目 (1名开发者)
📈 成熟度: 概念验证阶段
🌍 主要语言: JavaScript (87.3%)
🔧 框架: React 18.2.0
📦 包管理器: npm
```

### 3. 统一质量保障

#### 自动化检查
```bash
# 代码质量检查
./.cursor/quality/quality-manager.sh lint

# 格式化代码
./.cursor/quality/quality-manager.sh format

# 安全审计
./.cursor/quality/quality-manager.sh audit
```

#### 质量工具集成
- ✅ **ESLint**: JavaScript代码质量检查
- ✅ **Prettier**: 代码自动格式化
- ✅ **安全扫描**: 敏感信息检测

## 📋 规则系统

### 核心规则

| 规则 | 描述 | 应用方式 |
|------|------|----------|
| **constitution** | AI共生宪法 - 人机协作核心原则 | 始终应用 |
| **philosophy** | 交流哲学与协作模式 | 始终应用 |
| **intelligent_evolution** | 智能演进系统 | 智能应用 |
| **system_info** | 系统信息获取器 | 始终应用 |

### 技术栈规则

| 规则 | 适用场景 |
|------|----------|
| **javascript** | JavaScript/TypeScript项目 |
| **python** | Python开发项目 |
| **java** | Java企业级应用 |
| **go** | Go语言项目 |

### 工作流规则

| 规则 | 功能 |
|------|------|
| **eslint** | ESLint代码检查 |
| **generator** | 项目配置生成 |
| **templates** | 模板管理 |

## 🎨 Skills扩展系统

### 创意设计技能
- **algorithmic-art**: 算法艺术生成 (p5.js)
- **canvas-design**: 画布设计和图形创建
- **frontend-design**: 前端界面设计
- **theme-factory**: 主题设计和定制

### 企业协作技能
- **brand-guidelines**: 品牌指南应用
- **internal-comms**: 内部通讯优化
- **doc-coauthoring**: 文档协作编写

### AI集成技能
- **mcp-builder**: MCP服务器开发
- **slack-gif-creator**: Slack GIF创建
- **skill-creator**: AI技能定制

### 开发工具技能
- **webapp-testing**: Web应用测试
- **web-artifacts-builder**: Web组件构建

## ⚙️ 配置管理

### 分层配置体系

```
全局配置 (global.json)
    ↓
项目配置 (project.json)
    ↓
用户覆盖 (overrides.json)
```

#### 配置优先级
1. **用户覆盖**: 最高优先级，个性化设置
2. **项目配置**: 项目特定配置
3. **全局配置**: 系统默认值

### 动态配置更新
```bash
# 验证配置
./.cursor/config/config-validator.sh

# 管理配置
./.cursor/config/config-manager.sh
```

## 🔧 高级用法

### 自定义规则开发

1. **创建规则文件**
   ```bash
   # 在 .cursor/rules/ 目录下创建新规则
   touch .cursor/rules/custom/my-rule.md
   ```

2. **规则格式**
   ```markdown
   ---
   command: my-rule
   description: "我的自定义规则"
   alwaysApply: false
   ---

   # 规则内容
   ## 适用场景
   - 特定项目类型

   ## 规则说明
   详细的使用说明...
   ```

### Hooks系统

#### 自动化Hooks
- **code-quality.sh**: 代码质量检查
- **security-audit.sh**: 安全审计
- **prompt-security.sh**: 提示安全过滤
- **session-summary.sh**: 会话总结

#### 自定义Hooks
```bash
# 在 .cursor/features/hooks/ 目录添加新hook
cp template.sh .cursor/features/hooks/my-hook.sh
chmod +x .cursor/features/hooks/my-hook.sh
```

## 📊 监控和报告

### 系统监控
```bash
# 环境完整性检查
./.cursor/core/env-perception.sh

# 质量报告生成
./.cursor/quality/report/quality-reporter.sh

# 配置验证
./.cursor/config/config-validator.sh
```

### 日志系统
```bash
# 查看系统日志
tail -f .cursor/logs/system.log

# 调试模式
export CURSOR_DEBUG=true
./cursor-master.sh "debug command"
```

## 🐛 故障排除

### 常见问题

**Q: Master命令无响应？**
```bash
# 检查环境
./.cursor/core/env-perception.sh

# 重新初始化
./.cursor/core/init.sh
```

**Q: 规则不生效？**
```bash
# 验证规则文件
ls -la .cursor/rules/

# 检查配置
./.cursor/config/config-validator.sh
```

**Q: 技能无法加载？**
```bash
# 检查技能注册表
cat .cursor/features/skills/registry.json

# 验证技能文件
ls -la .cursor/features/skills/
```

### 性能优化

#### 缓存管理
```bash
# 清理缓存
rm -rf .cursor/cache/

# 重新生成缓存
./.cursor/core/env-perception.sh --force
```

#### 内存优化
```json
// .cursor/config/global.json
{
  "performance": {
    "cache_enabled": true,
    "cache_size_mb": 100,
    "compression": true
  }
}
```

## 📚 更多资源

- **[系统信息指南](system-info-guide.md)**: 环境检测和系统信息
- **[智能进化指南](intelligent-evolution-guide.md)**: AI学习和优化
- **[团队规则示例](team-rules-example.md)**: 多开发者协作配置
- **[远程规则导入](remote-rules-guide.md)**: 远程规则管理

---

*🚀 Cursor AI Rules v4.3.0 - 让AI成为你的超级编程助手*
*最后更新: 2026-01-16 | 作者: wangqiqi*