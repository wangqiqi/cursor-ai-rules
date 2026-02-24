# 意图解析规范流程

> 明确意图解析的策略与执行分层 | 更新: 2026-02-24

## 分层架构

```
策略层（规则）
    ↓
conversation_intent_analyzer.md
  - 项目创建意图检测策略
  - STOP 行为定义
  - 响应模板
    ↓
执行层（脚本）
    ↓
① master-parser.js
   - 意图解析：analyzeIntent()
   - 数据源：intent-mappings.json、intent-patterns.json
   - 输出：intent、confidence、parameters
    ↓
② smart-intent-matcher.sh（能力匹配，与意图解析互补）
   - 能力映射：用户输入 → capability-map.json
   - 场景：cursor-master、master-handler 的能力路由
   - 与 master-parser 的 intent 为不同维度
```

## 组件职责

| 组件 | 职责 | 数据源 |
|------|------|--------|
| **conversation_intent_analyzer.md** | 策略：项目创建检测、STOP 规则、澄清模板 | 规则内容 |
| **conversation_intent_classification** | 意图分类定义（引用） | 规则 |
| **master-parser.js** | 执行：意图解析、参数提取、宪法合规 | intent-mappings.json |
| **smart-intent-matcher.sh** | 执行：能力匹配（capability） | capability-map.json |

## 意图 vs 能力

| 维度 | 意图 (Intent) | 能力 (Capability) |
|------|---------------|-------------------|
| 负责组件 | master-parser | smart-intent-matcher |
| 示例 | creation, learning, skills_execution | commit_code, check_code_quality |
| 用途 | 路由到 executor 流程 | 映射到具体能力配置 |

## 实现状态（2026-02-24）

1. **策略层**: conversation_intent_analyzer 定义项目创建检测与 STOP 行为
2. **执行层**: master-parser 从 JSON 配置解析意图，不硬编码策略
3. **能力层**: smart-intent-matcher 独立负责 capability 匹配，与 intent 解耦

## 相关文件

- `.cursor/rules/workflow/conversation_intent_analyzer.md` - 策略入口
- `.cursor/commands/master-parser.js` - 意图解析执行
- `.cursor/core/smart-intent-matcher.sh` - 能力匹配
- `.cursor/commands/mappings/intent-mappings.json` - 意图配置
