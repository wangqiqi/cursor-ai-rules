# 🔗 钩子系统

钩子系统提供了事件驱动的自动化处理能力，在特定事件发生时自动执行相应的处理逻辑。

## 📁 目录结构

```
hooks/
├── hooks.json      # 钩子配置文件
└── README.md       # 钩子系统文档
```

## 🎯 钩子事件类型

### 文件操作钩子
- `afterFileEdit`: 文件编辑后触发
- `beforeFileSave`: 文件保存前触发
- `afterFileSave`: 文件保存后触发

### 命令执行钩子
- `beforeShellExecution`: Shell命令执行前触发
- `afterShellExecution`: Shell命令执行后触发

### AI交互钩子
- `beforeSubmitPrompt`: 提交提示前触发
- `afterAgentResponse`: AI响应后触发

### 会话管理钩子
- `onSessionStart`: 会话开始时触发
- `onSessionEnd`: 会话结束时触发
- `stop`: 会话停止时触发

## ⚙️ 钩子配置

`hooks.json` 配置示例：

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "features/automation/hooks/code-quality.sh",
        "timeout": 5000,
        "async": false
      }
    ],
    "beforeShellExecution": [
      {
        "command": "features/automation/hooks/security-audit.sh",
        "timeout": 2000,
        "async": true
      }
    ],
    "afterAgentResponse": [
      {
        "command": "features/automation/hooks/rule-usage-tracker.sh",
        "timeout": 1000,
        "async": true
      }
    ]
  }
}
```

## 🔧 钩子开发

### 钩子脚本规范

每个钩子脚本应该：

1. **接受标准输入**: 从stdin接收事件数据
2. **返回适当状态**: 0表示成功，非0表示失败
3. **处理超时**: 在合理时间内完成执行
4. **错误处理**: 优雅地处理错误情况

### 钩子脚本模板

```bash
#!/bin/bash

# 钩子脚本模板
# 参数: 钩子事件类型和相关数据

HOOK_EVENT="$1"
HOOK_DATA="$2"

# 日志函数
log() {
    echo "[HOOK:$(basename "$0")] $(date '+%H:%M:%S') $*" >&2
}

# 主处理逻辑
main() {
    log "执行钩子: $HOOK_EVENT"

    case "$HOOK_EVENT" in
        "afterFileEdit")
            # 处理文件编辑事件
            handle_file_edit "$HOOK_DATA"
            ;;
        "beforeShellExecution")
            # 处理命令执行前检查
            handle_command_check "$HOOK_DATA"
            ;;
        *)
            log "未知钩子事件: $HOOK_EVENT"
            exit 1
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 📊 监控和调试

### 钩子执行日志
所有钩子执行都会记录到系统日志中：

```
[HOOK:code-quality.sh] 14:30:15 执行钩子: afterFileEdit
[HOOK:code-quality.sh] 14:30:16 检查完成，耗时 1200ms
```

### 调试模式
启用调试模式查看详细执行信息：

```bash
export CURSOR_HOOK_DEBUG=true
# 然后执行触发钩子的操作
```

## 🚨 错误处理

### 钩子执行失败
- 不会阻止主要操作的执行
- 错误信息会记录到日志
- 可以配置是否显示用户通知

### 超时处理
- 超过配置超时时间的钩子会被强制终止
- 记录超时事件到日志
- 可以配置重试策略

## 🔒 安全考虑

- 钩子脚本只能访问授权的资源
- 敏感操作需要额外的权限验证
- 钩子执行会被审计和监控

---

*钩子系统提供了强大而灵活的事件驱动自动化能力，是系统可扩展性的重要组成部分。*