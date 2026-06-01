# 跨平台与 MCP 支持清单

> 更新: 2026-02-24

## 跨平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| **Linux** | ✅ 主要支持 | 开发与测试主环境 |
| **macOS** | ⚠️ 待验证 | 需验证 Bash 4+、jq、路径差异 |
| **Windows** | ⚠️ 待验证 | 需 WSL2 或 Git Bash；部分路径需适配 |
| **WSL2** | ✅ 支持 | 视为 Linux 环境 |

### 已做跨平台适配

- 临时目录: 使用 `${TMPDIR:-/tmp}` 替代硬编码 `/tmp`
- 用户目录: 使用 `$HOME`、`$USERPROFILE`、`process.env.HOME`
- 路径: `platform_adapter.md`、`path-config.sh` 提供 OS 抽象

### 待验证项

- [ ] macOS: `stat` 命令格式差异
- [ ] Windows: 路径分隔符、`/usr/bin` 等工具可用性
- [ ] 各平台 Shell 版本 (Bash 4+)

## MCP 集成

| 组件 | 状态 | 说明 |
|------|------|------|
| `mcp-detector.sh` | ✅ 存在 | 检测 MCP 可用性 |
| `local-mcp-integration.sh` | ✅ 存在 | 本地 MCP 集成 |
| `mcp-integration-guide.md` | ✅ 存在 | 集成文档 |
| `reference/mcp_*.md` | ✅ 存在 | MCP 规范参考 |

### 相关文档

- [MCP 集成指南](../developer/mcp-integration-guide.md)
- `.cursor/skills/mcp-best-practices/references/full-guide.md`

## 验证命令

```bash
# 快速验证
./.cursor/verify-system.sh --quick

# 配置验证
./.cursor/core/config-manager.sh validate
```
