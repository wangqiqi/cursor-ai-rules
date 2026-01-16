# 🔗 Hooks API 文档

Cursor AI Rules 的钩子系统允许你在 AI 协作流程的关键节点自动执行自定义脚本。

## 🎯 Hooks 概述

### 支持的事件类型

| 事件                   | 触发时机   | 示例用途             |
| ---------------------- | ---------- | -------------------- |
| `afterFileEdit`        | 文件编辑后 | 代码格式化、语法检查 |
| `beforeShellExecution` | 命令执行前 | 安全审计、权限检查   |
| `afterShellExecution`  | 命令执行后 | 日志记录、清理任务   |
| `beforeSubmitPrompt`   | 提示提交前 | 内容过滤、安全检查   |
| `afterAgentResponse`   | AI响应后   | 响应分析、使用统计   |
| `stop`                 | 会话结束时 | 会话总结、资源清理   |

### 钩子配置结构

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": ".cursor/features/hooks/code-quality.sh",
        "timeout": 5000,
        "working_directory": ".",
        "environment": {
          "CUSTOM_VAR": "value"
        }
      }
    ]
  }
}
```

## 📝 钩子脚本规范

### 脚本接口

每个钩子脚本应遵循以下接口：

```bash
#!/bin/bash
# 钩子脚本示例

# 输入参数（通过环境变量）
# CURSOR_HOOK_EVENT - 触发的事件类型
# CURSOR_HOOK_DATA - 事件相关数据（JSON格式）
# CURSOR_PROJECT_ROOT - 项目根目录

echo "🔗 钩子触发: $CURSOR_HOOK_EVENT"

# 解析事件数据
if [ -n "$CURSOR_HOOK_DATA" ]; then
    # 使用jq解析JSON数据（如果可用）
    if command -v jq >/dev/null 2>&1; then
        file_path=$(echo "$CURSOR_HOOK_DATA" | jq -r '.file_path // empty')
        command=$(echo "$CURSOR_HOOK_DATA" | jq -r '.command // empty')
    fi
fi

# 执行钩子逻辑
case "$CURSOR_HOOK_EVENT" in
    "afterFileEdit")
        # 文件编辑后的处理
        if [[ "$file_path" == *.js ]] || [[ "$file_path" == *.ts ]]; then
            echo "📝 检查JavaScript/TypeScript文件: $file_path"
            # 执行代码质量检查
            npx eslint "$file_path" --fix
        fi
        ;;
    "beforeShellExecution")
        # 命令执行前的安全检查
        echo "🔒 审计命令: $command"
        # 检查危险命令
        if [[ "$command" == *"rm -rf"* ]] || [[ "$command" == *"sudo"* ]]; then
            echo "⚠️  检测到高风险命令，需要确认"
            exit 1
        fi
        ;;
    *)
        echo "ℹ️  未处理的钩子事件: $CURSOR_HOOK_EVENT"
        ;;
esac

# 返回值
# 0 - 成功，继续执行
# 1 - 失败，中止操作
exit 0
```

### 环境变量

钩子脚本可以访问以下环境变量：

| 变量                  | 描述                | 示例                          |
| --------------------- | ------------------- | ----------------------------- |
| `CURSOR_HOOK_EVENT`   | 触发的事件类型      | `afterFileEdit`               |
| `CURSOR_HOOK_DATA`    | 事件数据（JSON）    | `{"file_path":"src/main.js"}` |
| `CURSOR_PROJECT_ROOT` | 项目根目录          | `/home/user/project`          |
| `CURSOR_CONFIG_PATH`  | 配置目录路径        | `.cursor/config`              |
| `CURSOR_VERSION`      | Cursor AI Rules版本 | `4.2.0`                       |

## 🛠️ 内置钩子

### 代码质量钩子

**文件**: `.cursor/features/hooks/code-quality.sh`

**功能**: 文件编辑后的代码质量检查和格式化

**支持的文件类型**:
- JavaScript/TypeScript: ESLint + Prettier
- Python: Black + Flake8
- Go: gofmt + golint
- Rust: rustfmt + clippy

### 安全审计钩子

**文件**: `.cursor/features/hooks/security-audit.sh`

**功能**: 命令执行前的安全检查

**检查内容**:
- 危险命令模式识别
- 文件权限检查
- 敏感数据泄露检测
- 网络安全验证

### 命令日志钩子

**文件**: `.cursor/features/hooks/command-log.sh`

**功能**: 命令执行后的日志记录

**记录内容**:
- 执行时间和持续时间
- 命令成功/失败状态
- 资源使用情况
- 执行上下文信息

### 提示安全钩子

**文件**: `.cursor/features/hooks/prompt-security.sh`

**功能**: AI提示提交前的安全过滤

**过滤规则**:
- 敏感信息检测
- 恶意内容识别
- 合规性检查
- 内容长度限制

### 规则使用跟踪钩子

**文件**: `.cursor/features/hooks/rule-usage-tracker.sh`

**功能**: AI响应后的规则使用统计

**统计内容**:
- 规则激活频率
- 技能使用情况
- 响应质量指标
- 用户偏好分析

### 会话总结钩子

**文件**: `.cursor/features/hooks/session-summary.sh`

**功能**: 会话结束时的总结报告

**生成内容**:
- 会话统计信息
- 使用的规则和技能
- 性能指标
- 改进建议

## 🔧 自定义钩子开发

### 开发步骤

1. **创建钩子脚本**
```bash
# 创建自定义钩子
mkdir -p .cursor/features/hooks/custom
cat > .cursor/features/hooks/custom/my-hook.sh << 'EOF'
#!/bin/bash
# 自定义钩子脚本

echo "🎯 自定义钩子触发"

# 你的自定义逻辑
case "$CURSOR_HOOK_EVENT" in
    "customEvent")
        echo "处理自定义事件"
        ;;
esac

exit 0
EOF

chmod +x .cursor/features/hooks/custom/my-hook.sh
```

2. **注册钩子**
```json
// 编辑 .cursor/automation/config.json
{
  "version": 1,
  "hooks": {
    "customEvent": [
      {
        "command": ".cursor/features/hooks/custom/my-hook.sh"
      }
    ]
  }
}
```

3. **测试钩子**
```bash
# 手动触发测试
CURSOR_HOOK_EVENT="customEvent" \
CURSOR_HOOK_DATA='{"test": true}' \
.cursor/features/hooks/custom/my-hook.sh
```

### 最佳实践

#### 性能优化
- 钩子执行时间应控制在5秒以内
- 避免阻塞操作和长时间等待
- 使用异步处理复杂任务

#### 错误处理
- 钩子失败不应阻止主要操作
- 提供有意义的错误信息
- 记录详细的调试信息

#### 安全性
- 验证输入数据的安全性
- 避免执行用户提供的命令
- 使用白名单验证文件路径

#### 可维护性
- 为钩子脚本编写文档
- 使用一致的命名约定
- 定期审查和更新钩子逻辑

## 📊 调试和监控

### 日志位置

钩子执行日志保存在：`.cursor/logs/hooks/`

```
.cursor/logs/hooks/
├── code-quality.log      # 代码质量钩子日志
├── security-audit.log    # 安全审计日志
├── command-log.log       # 命令日志
├── prompt-security.log   # 提示安全日志
├── rule-usage.log        # 规则使用日志
└── session-summary.log   # 会话总结日志
```

### 调试模式

启用调试模式查看详细执行信息：

```bash
# 设置环境变量
export CURSOR_HOOK_DEBUG=true

# 查看钩子执行详情
tail -f .cursor/logs/hooks/*.log
```

### 性能监控

```bash
# 查看钩子性能统计
cat .cursor/logs/hooks/performance.json

# 监控执行时间
grep "duration" .cursor/logs/hooks/*.log | tail -10
```

## 🎯 高级用法

### 条件执行

```bash
#!/bin/bash
# 条件执行钩子

# 只在工作时间内执行
current_hour=$(date +%H)
if [ "$current_hour" -ge 9 ] && [ "$current_hour" -le 17 ]; then
    echo "🕒 工作时间内，执行完整检查"
    # 执行完整检查
else
    echo "🌙 非工作时间，跳过复杂检查"
    # 只执行基本检查
fi
```

### 钩子链

```bash
#!/bin/bash
# 钩子链示例

# 执行前置钩子
if [ -f ".cursor/hooks/pre-$CURSOR_HOOK_EVENT.sh" ]; then
    .cursor/hooks/pre-$CURSOR_HOOK_EVENT.sh
fi

# 执行主要逻辑
# ...

# 执行后置钩子
if [ -f ".cursor/hooks/post-$CURSOR_HOOK_EVENT.sh" ]; then
    .cursor/hooks/post-$CURSOR_HOOK_EVENT.sh
fi
```

---

*Hooks API v1.0 | Cursor AI Rules 4.2.0*