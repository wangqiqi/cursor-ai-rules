# 🔧 高级配置指南

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## ⚙️ 配置管理系统

### 5层配置层级

Cursor AI Rules 采用5层配置体系，按优先级从低到高：

1. **系统默认配置** (最低优先级)
   - 位置: `config/system-defaults.json`
   - 内容: 内置默认值

2. **全局配置**
   - 位置: `config/global.json`
   - 内容: 跨项目通用设置

3. **项目配置**
   - 位置: `config/project.json`
   - 内容: 项目特定配置

4. **用户配置**
   - 位置: `~/.cursor/config/user.json`
   - 内容: 个人偏好设置

5. **运行时配置** (最高优先级)
   - 位置: `config/runtime.json`
   - 内容: 动态生成的配置

### 配置管理命令

```bash
# 查看配置状态
./.cursor/core/core/config/config-manager.sh status

# 获取配置值
./.cursor/core/core/config/config-manager.sh get .system.log_level

# 设置配置值
./.cursor/core/core/config/config-manager.sh set .features.automation.enabled true

# 验证配置一致性
./.cursor/core/core/config/config-manager.sh validate

# 生成配置报告
./.cursor/core/core/config/config-manager.sh report
```

## 📋 自定义规则开发

### 规则文件结构

```markdown
---
command: your_rule_name
description: "规则描述"
alwaysApply: false
---

# 规则标题

规则内容...
```

### 规则存放位置
- **核心规则**: `rules/core/`
- **语言规则**: `rules/tech/`
- **工作流规则**: `rules/workflow/`
- **团队规则**: `rules/team/`

### 规则最佳实践
1. **明确范围**: 每个规则只解决一个明确的问题
2. **提供上下文**: 包含足够的信息让AI理解适用场景
3. **版本控制**: 使用语义化版本号
4. **向后兼容**: 新版本规则应兼容旧版本

## 🎯 技能扩展系统

### 技能分类

| 分类 | 数量 | 功能描述 |
|------|------|----------|
| 文档处理 | 4个 | Office文档处理和转换 |
| 创意设计 | 5个 | 设计工具和创意生成 |
| AI集成 | 5个 | MCP服务器和AI工具集成 |
| 企业协作 | 3个 | 企业级协作功能 |
| 测试开发 | 3个 | 测试和开发工具 |

### 自定义技能开发

1. **技能文件**: `features/skills/your-skill.md`
2. **注册技能**: 更新 `features/skills/registry.json`
3. **测试技能**: 使用技能测试环境验证

## 🔌 钩子系统 (Hooks)

### 可用钩子点

- `pre-commit`: 提交前检查
- `post-commit`: 提交后处理
- `pre-push`: 推送前验证
- `post-merge`: 合并后处理
- `on-error`: 错误处理
- `on-success`: 成功回调

### 钩子配置

```bash
# 启用钩子
./.cursor/features/hooks/enable.sh pre-commit code-quality

# 禁用钩子
./.cursor/features/hooks/disable.sh pre-commit code-quality

# 查看钩子状态
./.cursor/features/hooks/status.sh
```

## 📊 性能调优

### 缓存优化

```bash
# 清理缓存
./.cursor/core/performance-cache.sh clean

# 查看缓存统计
./.cursor/core/performance-cache.sh stats

# 重新构建缓存
./.cursor/core/performance-cache.sh rebuild
```

### 内存优化

```bash
# 查看内存使用
./.cursor/core/performance-monitor.sh memory

# 调整内存限制
./.cursor/core/core/config/config-manager.sh set .performance.resource_limits.memory_mb 512
```

## 🔒 安全配置

### 输入验证

```json
{
  "security": {
    "input_validation": true,
    "output_filtering": true,
    "rate_limiting": {
      "enabled": true,
      "max_requests_per_minute": 60
    }
  }
}
```

### 隐私保护

- 自动管理 `.gitignore` 文件
- 数据隔离存储在 `.cursorGrowth/` 目录
- 支持数据匿名化和隐私模式

## 🌱 生长系统配置

### 生长数据管理

```bash
# 查看生长状态
@master 显示生长状态

# 分析学习进度
@master 分析学习进度

# 清理生长数据
./.cursor/core/growth-manager.sh clean
```

### 个性化设置

- **语言偏好**: 自动检测和切换
- **交互风格**: 学习用户偏好
- **意图模式**: 优化识别准确率

---

*🔧 高级配置指南 - 定制化你的AI协作体验*