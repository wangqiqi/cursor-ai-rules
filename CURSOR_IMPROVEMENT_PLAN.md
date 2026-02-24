# .cursor 目录完善计划

> **分析日期**: 2026-02-24  
> **复核日期**: 2026-02-24（二次核实）  
> **分析范围**: `.cursor/`（相对路径，设备/用户/项目无关）  
> **状态**: 四轮迭代已完成（2026-02-24）

---

## ✅ 执行进度（已完成）

| 轮次 | 任务 | 状态 |
|------|------|------|
| 1 | verify-system.sh、command-center 路径、硬编码消除、alwaysApply、skills 说明、automation README、constitution/generator、AGENTS.md、README 统计 | ✅ |
| 2 | config-manager CONFIG_DIR、validate_enhanced、always_apply 兼容、CONFIG_SYSTEM_STATUS、PLATFORM_MCP_CHECKLIST、RULES_LENGTH_AUDIT | ✅ |
| 3 | platform_adapter 拆分、quality-check 插件、SKILL_MATCHING_FLOW、vibe-coding 拆分 | ✅ |
| 4 | 完善计划已修复项标记、constitution 拆分 | ✅ |

---

## 📊 分析摘要

### 系统概览

| 模块 | 数量 | 状态 | 说明 |
|------|------|------|------|
| Agents | 1 | ✅ 完整 | command-center 智能命令中枢 |
| Commands | 3 (MD) + 多 JS | ✅ 完整 | master, vibe, command-router |
| Rules | 74 | ✅ 完整 | 含 c-basics/cpp-advanced/intelligent_evolution/vue-advanced/rust-basics 等全部拆分，超长规则 0 个 |
| Core 脚本 | 75+ | ✅ 完整 | 初始化、编排、质量、缓存等 |
| Hooks | 36 | ✅ 完整 | 会话、提交、质量、学习等 |
| Skills (features) | 37 | ✅ 完整 | registry.json + 技能文件 |
| Skills (project) | 1 | ✅ 完整 | skill-dispatcher |
| Plugins | 2 | ✅ 扩展 | example-plugin、quality-check |
| Docs | 25+ | ✅ 完整 | 多层级文档体系 |
| Config | 多文件 | ✅ 完整 | global/project/system + Schema |

### 自洽性评估

参考 `CURSOR_SELF_CONSISTENCY_REPORT.md`，系统自洽性评分 **9/10**，各组件职责清晰，功能完整。

---

## 🔴 高优先级问题（✅ 已修复）

### 1. ~~缺失 verify-system.sh~~ ✅
已创建 `.cursor/verify-system.sh`，委托 `core/unified-check.sh` 执行。

### 2. ~~command-center.md 文档路径错误~~ ✅
已修正为 `docs/guides/SKILL_GUIDE.md` 和 `docs/developer/CALL_CHAIN.md`。

### 3. ~~CURSOR_SELF_CONSISTENCY_REPORT 路径硬编码~~ ✅
已改为 `{{PROJECT_ROOT}}/.cursor/`。

### 4. ~~硬编码路径~~ ✅
已修正：TMPDIR、platform_adapter、path-config、growth-directory、各 hooks 等。

---

## 🟡 中优先级问题（✅ 已修复）

### 5. ~~Skills 双目录命名易混淆~~ ✅
已在 README、SKILL_GUIDE、skill-dispatcher 中明确区分。

### 6. ~~features/automation README 与 hooks 不一致~~ ✅
已更新 automation README，说明 hooks 位于 `../hooks/`。

### 7. ~~插件系统仅有示例~~ ✅
已新增 `quality-check` 插件。

---

## 🔄 重复功能分析

| 功能域 | 重复位置 | 状态 | 说明 |
|--------|----------|------|------|
| **技能匹配/调度** | skill-dispatcher、skills-loader.sh、master-executor.js | ✅ 已收敛 | 任务 15：skills-loader match、parser 委托、executor 纯委托 |
| **规则激活判断** | rules-router.md、rules-conflict-resolver.md、cursor-master.sh、master-handler.js | ✅ 已收敛 | 任务 16：RULE_ACTIVATION_FLOW 文档化，脚本仅 executeRule，无激活逻辑 |
| **意图解析** | conversation_intent_analyzer.md、smart-intent-matcher.sh、master-parser.js | ✅ 已收敛 | 任务 17：INTENT_PARSING_FLOW 文档化，策略/执行分层明确 |

---

## ⚔️ 潜在冲突分析（✅ 已处理）

| 冲突场景 | 状态 |
|----------|------|
| **项目创建时机** | ✅ generator 已标注「须先执行 constitution 讨论流程」 |
| **alwaysApply 命名** | ✅ 已统一为 `alwaysApply`，脚本兼容 `always_apply` |

---

## 📐 Cursor 官方最佳实践符合性

参考 [Cursor 规则](https://cursor.com/cn/docs/context/rules)、[命令](https://cursor.com/cn/docs/context/commands)、[Agent Skills](https://cursor.com/cn/docs/context/skills)：

### 规则 (Rules)

| 官方规范 | 当前状态 | 建议 |
|----------|----------|------|
| Frontmatter: `description`, `globs`, `alwaysApply` | ✅ 已统一 | 任务 18：已全部迁移至 `globs`、`alwaysApply` |
| 规则控制在 500 行以内 | ✅ 已达标 | 74 规则，超长 0 个 |
| 避免模糊指导，可操作 | 部分规则较抽象 | 任务 19：增加具体示例和可执行步骤 |
| 引用文件用 `@filename` 而非复制 | 已使用 | 保持 |

### 命令 (Commands)

| 官方规范 | 当前状态 | 建议 |
|----------|----------|------|
| `.cursor/commands` 下 `.md` 文件 | 符合 | 保持 |
| 纯 Markdown 描述命令行为 | master.md 有 `handler: "./master-handler.js"` | 扩展用法，需确认 Cursor 是否支持；若不支持，可保留为文档说明 |
| 命令名即文件名 | master.md、vibe.md 等 | 符合 |

### Agent Skills

| 官方规范 | 当前状态 | 建议 |
|----------|----------|------|
| `.cursor/skills/` 中每技能一个文件夹，含 `SKILL.md` | skill-dispatcher 符合 | 符合 |
| `features/skills/` 为 flat .md + registry.json | **非标准格式** | 官方格式为每技能独立文件夹；当前为自定义扩展，需在文档中明确说明 |
| Frontmatter: `name`, `description` | skill-dispatcher 符合 | 符合 |

### AGENTS.md ✅

| 官方规范 | 当前状态 |
|----------|----------|
| 项目根目录 `AGENTS.md` | ✅ 已创建 |

---

## 🟢 低优先级（✅ 已处理）

| 项 | 状态 |
|----|------|
| AGENTS.md 根入口 | ✅ |
| README 统计数据 | ✅ 已统一为 74 规则、75+ 脚本、36 钩子 |
| 配置系统状态 | ✅ 见 CONFIG_SYSTEM_STATUS.md |
| 跨平台清单 | ✅ 见 PLATFORM_MCP_CHECKLIST.md |

---

## 📋 完善任务清单（按执行顺序）

| 序号 | 任务 | 状态 |
|------|------|------|
| 1 | 创建或修正 verify-system.sh 引用 | ✅ |
| 2 | 修正 command-center.md 文档路径 | ✅ |
| 3 | 消除硬编码路径 | ✅ |
| 4 | 统一规则 frontmatter：`always_apply` → `alwaysApply` | ✅ |
| 5 | 明确 skills 双目录及 features/skills 非标准格式 | ✅ |
| 6 | 统一 features/automation README 与 hooks 描述 | ✅ |
| 7 | 技能匹配流程文档化（SKILL_MATCHING_FLOW） | ✅ 文档完成 |
| 8 | 明确 constitution 与 generator 的触发顺序 | ✅ |
| 9 | 创建根目录 AGENTS.md | ✅ |
| 10 | 统一 README 统计数据 | ✅ |
| 11 | 对照 ROADMAP 检查配置系统实现状态 | ✅ |
| 12 | 建立跨平台与 MCP 支持清单 | ✅ |
| 13 | 扩展插件系统（quality-check 插件） | ✅ |
| 14 | 规则拆分（platform_adapter、vibe-coding、constitution、conversation_intent、typescript-advanced、react-basics、vue-basics、react-advanced、c-basics、cpp-advanced、intelligent_evolution、vue-advanced、rust-basics 等） | ✅ 已完成（74 规则，超长 0 个） |
| 15 | 技能匹配代码级收敛 | ✅ skills-loader match、parser 委托、executor 纯委托 |
| 16 | 规则激活收敛：以 rules-router 为唯一入口，脚本只调用 | ✅ 已完成（RULE_ACTIVATION_FLOW 文档化） |
| 17 | 意图解析收敛：规则负责策略，脚本负责执行，明确分层 | ✅ 已完成（INTENT_PARSING_FLOW 文档化） |
| 18 | frontmatter 统一：`apply_when` → `globs`（或官方推荐字段） | ✅ 已完成（74 规则已迁移） |
| 19 | 规则示例补充：为抽象规则增加可执行示例 | 🔄 待执行 |
| 20 | 测试覆盖：verify-system、规则校验等 | 🔄 待执行 |

---

## 🔗 与 ROADMAP 的关联

本完善计划与 `ROADMAP.md` 的对应关系：

| ROADMAP 章节 | 本计划对应项 |
|--------------|--------------|
| 2.1 跨平台兼容性 | 任务 9 |
| 2.2 配置系统重构 | 任务 8 |
| 4.1 插件生态体系 | 任务 10 |
| 3.1 测试覆盖完善 | 任务 20 |
| 重复功能收敛 | 任务 16、17 |
| 规则最佳实践 | 任务 18、19 |

**建议**: 执行本计划中的高优先级任务后，在 ROADMAP 中标注「.cursor 基础完善已完成」，并将中低优先级任务与 ROADMAP 各阶段合并规划。

---

## 📁 相关文档

- [ROADMAP.md](ROADMAP.md) - 项目发展规划
- [.cursor/README.md](.cursor/README.md) - 系统导航
- [.cursor/docs/reference/CURSOR_SELF_CONSISTENCY_REPORT.md](.cursor/docs/reference/CURSOR_SELF_CONSISTENCY_REPORT.md) - 自洽性分析
- [.cursor/docs/developer/CALL_CHAIN.md](.cursor/docs/developer/CALL_CHAIN.md) - 调用链
- [.cursor/docs/guides/SKILL_GUIDE.md](.cursor/docs/guides/SKILL_GUIDE.md) - 技能指南

### Cursor 官方文档

- [规则 (Rules)](https://cursor.com/cn/docs/context/rules)
- [命令 (Commands)](https://cursor.com/cn/docs/context/commands)
- [Agent Skills](https://cursor.com/cn/docs/context/skills)

---

*本计划基于 2026-02-24 的 .cursor 目录二次核实分析生成，执行前请根据最新代码状态复核。*
