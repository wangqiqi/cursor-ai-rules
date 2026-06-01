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
③ master-parser 委托 skills-loader match <input>（关键词→技能名）
    ↓
④ skills-loader 读取 registry.json，匹配 key/name/description/category
    ↓
⑤ 返回匹配的技能名列表（JSON）
    ↓
⑥ master-executor 委托 skills-loader load + execute
    ↓
⑦ 应用技能指导，返回结果
```

## 组件职责

| 组件 | 职责 | 不负责 |
|------|------|--------|
| **skill-dispatcher** | AI 侧规范入口，描述匹配策略与调用流程 | 不直接执行脚本 |
| **skills-loader.sh** | 脚本侧匹配（match）、加载（load）、执行（execute） | 匹配逻辑基于 registry，不硬编码 |
| **master-parser** | 意图识别后委托 `skills-loader match` 提取技能名 | 不独立实现关键词→技能映射 |
| **master-executor** | 执行 skills 时委托 `skills-loader load/execute` | 不独立实现匹配算法 |
| **agent-orchestration-smart-router** | Agent 任务分配，可查询技能能力 | 不替代技能内容加载 |

## 实现状态（2026-02-24 收敛完成）

1. **skills-loader match**: 新增 `match <input>` 命令，基于 registry 匹配，输出 JSON 数组
2. **master-parser**: 已移除硬编码 skillKeywords，委托 `matchSkillByInput()` → skills-loader match
3. **master-executor**: 已移除 findSkill 依赖，纯委托 skills-loader load+execute

## 相关文件

- `.cursor/skills/skill-dispatcher/SKILL.md` - AI 规范入口
- `.cursor/features/skills/registry.json` - 技能元数据（唯一数据源）
- `.cursor/core/skills-loader.sh` - 脚本侧加载器（含 match 命令）
