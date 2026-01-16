# ⚙️ 自动化工具层

这个目录包含了所有自动化工具和脚本，负责处理各种自动化任务。

## 📁 目录结构

```
automation/
├── hooks/         # 事件钩子系统
│   ├── code-quality.sh     # 代码质量检查钩子
│   ├── command-log.sh      # 命令日志钩子
│   ├── prompt-security.sh  # 提示安全钩子
│   ├── rule-usage-tracker.sh # 规则使用跟踪
│   ├── security-audit.sh   # 安全审计钩子
│   ├── session-summary.sh  # 会话总结钩子
│   └── test-hooks.sh       # 测试钩子
└── scripts/       # 自动化脚本
    ├── check.sh            # 代码检查脚本
    ├── convert_to_agent_skills.sh # 技能转换脚本
    ├── cursor-adaptation-setup.sh # 环境适配脚本
    ├── enable.sh           # 工具启用脚本
    ├── env_check.sh        # 环境检查脚本
    ├── growth_init.sh      # 增长初始化脚本
    ├── perception.sh       # 感知分析脚本
    └── plugin_manager.sh   # 插件管理脚本
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

### 钩子系统
钩子由系统自动触发，无需手动调用：

```json
// hooks.json 配置示例
{
  "hooks": {
    "afterFileEdit": [{"command": "automation/hooks/code-quality.sh"}],
    "beforeShellExecution": [{"command": "automation/hooks/security-audit.sh"}]
  }
}
```

### 脚本调用
通过统一命令入口调用：

```bash
# 环境检查
@master script env_check.sh

# 代码质量检查
@master script check.sh

# 插件管理
@master script plugin_manager.sh
```

## 🔧 开发指南

### 添加新钩子
1. 在 `hooks/` 目录创建钩子脚本
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