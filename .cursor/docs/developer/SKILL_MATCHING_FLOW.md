# 技能匹配规范流程

> 明确技能发现、匹配、加载的规范流程，避免多处重复实现 | 更新: 2026-02-24

## 规范流程

```
用户请求（含技能关键词）
    ↓
① command-center / master 解析意图
    ↓
② 识别为 skills_execution 意图
    ↓
③ 委托给 skill-dispatcher（规范入口）
    ↓
④ skill-dispatcher 读取 registry.json
    ↓
⑤ 匹配：关键词 → 分类 → 依赖检查
    ↓
⑥ 加载 features/skills/[name].md
    ↓
⑦ 应用技能指导，返回结果
```

## 组件职责

| 组件 | 职责 | 不负责 |
|------|------|--------|
| **skill-dispatcher** | 技能发现、匹配、加载的规范入口 | 不直接执行脚本 |
| **skills-loader.sh** | 批量加载、缓存、供脚本调用 | 不替代 skill-dispatcher 的匹配逻辑 |
| **master-executor** | 执行 capability 时调用 skills，应委托 skill-dispatcher 或 skills-loader | 不独立实现匹配算法 |
| **agent-orchestration-smart-router** | Agent 任务分配，可查询技能能力 | 不替代技能内容加载 |

## 实现建议

1. **匹配逻辑集中**: 新增技能时只更新 `registry.json`，匹配规则统一在 skill-dispatcher 描述
2. **脚本调用**: skills-loader 作为 skill-dispatcher 的脚本侧补充，用于批量/缓存场景
3. **master-executor**: 执行 skills 时调用 `skills-loader.sh` 或读取 registry，不重复实现匹配

## 相关文件

- `.cursor/skills/skill-dispatcher/SKILL.md` - 规范入口
- `.cursor/features/skills/registry.json` - 技能元数据
- `.cursor/core/skills-loader.sh` - 脚本侧加载器
