# ⚙️ 自动化工具层

这个目录包含了定时任务、Git 钩子和自动化脚本。**系统事件钩子**（如 code-quality、consistency-check 等）位于 `../hooks/`，由 `hooks.json` 配置。

## 📁 目录结构

```
automation/
├── cron/          # 定时任务配置
│   └── *.cron     # 自动化任务配置
├── git-hooks/     # Git 事件钩子
│   ├── install-hooks.sh        # 钩子安装脚本
│   ├── post-commit             # 提交后智能处理
│   └── pre-push                # 推送前质量检查
└── scripts/       # 自动化脚本
```

**系统钩子**（位于 `../hooks/`，由 hooks.json 注册）：
- code-quality.sh、consistency-check.sh、dependency-check.sh、quality-check.sh 等
- command-log / event-logger：由 logging-common.sh 配合 args 实现
```

## 🎯 职责范围

### Hooks (事件钩子)
- **代码质量**: 文件编辑后的自动质量检查
- **安全审计**: 命令执行前的安全验证
- **使用跟踪**: 规则和技能的使用统计
- **会话管理**: 对话会话的总结和记录

### Scripts (自动化脚本)
- **环境管理**: 环境检测、适配和配置
- **质量保障**: 代码检查、格式化和审计
- **工具集成**: 插件管理、技能转换
- **初始化**: 项目和系统的初始化设置

## 🚀 使用方法

### 定时任务系统
自动执行的后台任务：

```bash
# 查看定时任务配置
cat automation/cron/cursor-ai-rules.cron

# 安装定时任务
crontab automation/cron/cursor-ai-rules.cron
```

### Git钩子系统
智能Git事件处理：

```bash
# 安装Git钩子
bash automation/git-hooks/install-hooks.sh

# 手动触发钩子
bash automation/git-hooks/post-commit  # 提交后处理
bash automation/git-hooks/pre-push     # 推送前检查
```

### 系统钩子系统
系统事件自动触发：

```json
// hooks.json 配置示例
{
  "hooks": {
    "afterFileSave": [{"command": "features/hooks/code-quality.sh"}],
    "beforeSubmitPrompt": [{"command": "features/hooks/prompt-security.sh"}],
    "afterAgentResponse": [{"command": "core/agent-orchestration-engine.sh"}]
  }
}
```

### 脚本调用
通过统一命令入口调用：

```bash
# 环境检查
/master script env-perception

# 代码质量检查
/master script quality

```

## 🔧 开发指南

### 添加新钩子
1. 在 `../hooks/` 目录创建钩子脚本
2. 确保脚本有执行权限: `chmod +x hook-name.sh`
3. 在 `hooks.json` 中注册钩子事件
4. 添加相应的文档和测试

### 添加新脚本
1. 在 `scripts/` 目录创建脚本文件
2. 添加执行权限和shebang
3. 在相关文档中添加使用说明
4. 更新capability-map.json（如果需要）

## 📊 性能监控

- 钩子执行时间监控
- 脚本资源使用统计
- 自动化任务成功率跟踪
- 系统性能影响评估

---

*自动化工具层是系统的执行核心，提供了丰富的事件驱动和脚本化功能。*