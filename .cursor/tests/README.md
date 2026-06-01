# .cursor 测试

## 测试脚本

| 脚本 | 说明 |
|------|------|
| `run-verify-test.sh` | 验证 verify-system.sh --quick 能正常执行，检查 Rules 统计、超长规则为 0 |
| `test-common.sh` | 验证 common.sh 验证函数、hooks.json 完整性、verify-system 集成、agent-orchestration-common 语法 |

## 运行

```bash
# 运行所有测试
./.cursor/tests/run-verify-test.sh
./.cursor/tests/test-common.sh

# 返回码为 0 表示全部通过
```
