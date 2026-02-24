# .cursor 测试

> 任务 20：verify-system、规则校验等基础测试

## 测试脚本

| 脚本 | 说明 |
|------|------|
| `run-verify-test.sh` | 验证 verify-system.sh --quick 能正常执行，检查 Rules 统计、超长规则为 0 |

## 运行

```bash
./.cursor/tests/run-verify-test.sh
```

## 扩展

可继续添加：
- master-parser 澄清模块测试
- 规则 frontmatter 校验测试
- 路径引用一致性测试
