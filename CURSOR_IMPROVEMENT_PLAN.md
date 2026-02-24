# .cursor 目录完善计划

> **分析日期**: 2026-02-24  
> **复核日期**: 2026-02-24（二次核实）  
> **分析范围**: `.cursor/`（相对路径，设备/用户/项目无关）  
> **状态**: 高/中优先级任务已执行（2026-02-24）

---

## 📊 分析摘要

### 系统概览

| 模块 | 数量 | 状态 | 说明 |
|------|------|------|------|
| Agents | 1 | ✅ 完整 | command-center 智能命令中枢 |
| Commands | 3 (MD) + 多 JS | ✅ 完整 | master, vibe, command-router |
| Rules | 46 | ✅ 完整 | core/system/workflow/tech/evolution/team |
| Core 脚本 | 75+ | ✅ 完整 | 初始化、编排、质量、缓存等 |
| Hooks | 36 | ✅ 完整 | 会话、提交、质量、学习等 |
| Skills (features) | 37 | ✅ 完整 | registry.json + 技能文件 |
| Skills (project) | 1 | ✅ 完整 | skill-dispatcher |
| Plugins | 1 示例 | ⚠️ 待扩展 | example-plugin |
| Docs | 25+ | ✅ 完整 | 多层级文档体系 |
| Config | 多文件 | ✅ 完整 | global/project/system + Schema |

### 自洽性评估

参考 `CURSOR_SELF_CONSISTENCY_REPORT.md`，系统自洽性评分 **9/10**，各组件职责清晰，功能完整。

---

## 🔴 高优先级问题

### 1. 缺失 verify-system.sh

**现象**: README.md 和 README.en.md 均引用 `./.cursor/verify-system.sh`，但该文件不存在。

**影响**: 用户无法执行「完整验证」和「快速验证」，文档与实现不一致。

**建议**:
- 创建 `verify-system.sh`，实现基础校验逻辑（检查核心脚本、配置、规则、技能等）
- 或从 README 中移除该引用，改为指向现有 `unified-check.sh` 等脚本

### 2. command-center.md 文档路径错误

**现象**: 第 131 行引用：
- `.cursor/SKILL_GUIDE.md` → 实际路径为 `.cursor/docs/guides/SKILL_GUIDE.md`
- `.cursor/CALL_CHAIN.md` → 实际路径为 `.cursor/docs/developer/CALL_CHAIN.md`

**影响**: Agent 或用户按文档查找时可能找不到正确文件。

**建议**: 修正为 `docs/guides/SKILL_GUIDE.md` 和 `docs/developer/CALL_CHAIN.md`。

### 3. CURSOR_SELF_CONSISTENCY_REPORT 路径硬编码

**现象**: 报告内分析路径为 `/home/jwzhou/workspace/cursor-ai-rules/.cursor/`，与当前环境不一致。

**建议**: 使用相对路径或占位符，或增加「分析时自动替换为当前项目路径」的说明。

### 4. ⚠️ 硬编码路径（违反「用户/项目/设备无关」原则）

**原则**: 规则系统应**用户无关、项目无关、设备无关**，内部不应包含具体路径、用户名或项目名。

**需修正的硬编码**:

| 文件 | 问题 | 建议 |
|------|------|------|
| `CURSOR_SELF_CONSISTENCY_REPORT.md` | `/home/jwzhou/workspace/cursor-ai-rules/.cursor/` | 改为 `{{PROJECT_ROOT}}/.cursor/` 或相对路径 |
| `SYSTEM_ARCHITECTURE.md` | `/home/jwzhou/workspace/cursor-ai-rules` | 改为 `{{PROJECT_ROOT}}` |
| `system_info.md` | `/home/user/project` 示例 | 使用 `{{PROJECT_ROOT}}`、`{{WORK_DIR}}` |
| `platform_adapter.md` | `return '/home/user'` | 使用 `$HOME` 或环境变量 |
| `master-sync-trigger.sh` | `/tmp/cursor-master-sync-conversation-$USER.id` | 使用 `$TMPDIR` 或 `$XDG_RUNTIME_DIR` 等 |
| `conversation-init.sh` | `/tmp/cursor-ai-rules-conversation-init-$USER` | 同上 |
| `role-sync.sh` | `/tmp/cursor-role-sync-$USER.log` | 同上 |
| `create-role-context.sh` | `/tmp/cursor-role-context-$USER.md` | 同上 |
| `security-audit.sh` | `/var/log/auth.log`、`/var/log/secure` | 按 OS 检测选择路径，或使用配置 |
| `path-config.sh` | `/tmp/.cursorGrowth` | 使用 `$TMPDIR` 或可配置路径 |
| `growth-directory-auto-init.md` | `/workspace/.cursorGrowth` | 改为 `{{PROJECT_ROOT}}/.cursorGrowth` |

**可保留的合理用法**:
- `/tmp/` 配合 `$$` 的临时文件（如 `cursor-master.sh`、`file-module.sh`）— 标准临时目录
- `https://github.com/wangqiqi/cursor-ai-rules` — 外部引用，可保留或改为占位符

---

## 🟡 中优先级问题

### 4. Skills 双目录命名易混淆

**现象**:
- `.cursor/skills/`：项目技能（skill-dispatcher）
- `.cursor/features/skills/`：技能库（37 个可复用技能）

**建议**（自洽性报告已提出）:
- 在 README、command-center、skill-dispatcher 等文档中明确区分「项目技能」与「技能库」
- 可选：重命名为 `project-skills/` 与 `skill-library/`，需评估改动成本

### 5. features/automation README 与 hooks 不一致

**现象**: `features/automation/README.md` 提到 `command-log.sh`、`event-logger.sh`，但 hooks.json 中对应钩子实际使用 `logging-common.sh` 配合 args。

**建议**: 更新 automation README，说明与 hooks 的对应关系，或统一术语。

### 6. 插件系统仅有示例

**现象**: `plugins/` 仅包含 `example-plugin`，无实际业务插件。

**建议**:
- 将常用能力（如质量检查、性能监控）抽象为可选插件
- 完善插件开发文档和发布流程
- 与 ROADMAP「插件系统标准化」对齐

---

## 🔄 重复功能分析

| 功能域 | 重复位置 | 说明 |
|--------|----------|------|
| **技能匹配/调度** | skill-dispatcher (Skill)、skills-loader.sh、master-executor.js、agent-orchestration-smart-router.sh | 多处实现技能发现、匹配、加载逻辑，建议统一由 skill-dispatcher 或单一 loader 负责 |
| **规则激活判断** | rules-router.md、rules-conflict-resolver.md、cursor-master.sh、master-handler.js | 规则激活、优先级、冲突解决分散在规则与脚本中，可收敛到 rules-router 作为唯一入口 |
| **意图解析** | conversation_intent_analyzer.md、smart-intent-matcher.sh、master-parser.js | 意图解析逻辑重复，建议明确分层：规则负责策略，脚本负责执行 |

---

## ⚔️ 潜在冲突分析

| 冲突场景 | 涉及规则/组件 | 说明 |
|----------|---------------|------|
| **项目创建时机** | constitution.md（必须先讨论） vs generator.md（项目生成器） | 宪法要求检测到创建意图时 STOP 并讨论，生成器可能被误触发；需确保 generator 仅在用户确认后激活 |
| **alwaysApply 命名** | constitution/philosophy 使用 `always_apply`，脚本/命令查找 `alwaysApply` | 命名不一致可能导致脚本无法正确识别「始终应用」规则，建议统一为 Cursor 官方的 `alwaysApply` |

---

## 📐 Cursor 官方最佳实践符合性

参考 [Cursor 规则](https://cursor.com/cn/docs/context/rules)、[命令](https://cursor.com/cn/docs/context/commands)、[Agent Skills](https://cursor.com/cn/docs/context/skills)：

### 规则 (Rules)

| 官方规范 | 当前状态 | 建议 |
|----------|----------|------|
| Frontmatter: `description`, `globs`, `alwaysApply` | 使用 `apply_when`、`always_apply` (snake_case) | 统一为 `alwaysApply` (camelCase)，`apply_when` 可能非官方支持 |
| 规则控制在 500 行以内 | 部分规则较长 | 拆分超长规则，按官方建议保持聚焦 |
| 避免模糊指导，可操作 | 部分规则较抽象 | 增加具体示例和可执行步骤 |
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

### AGENTS.md

| 官方规范 | 当前状态 | 建议 |
|----------|----------|------|
| 项目根目录 `AGENTS.md` 作为 Agent 指令 | 缺失 | 创建根目录 `AGENTS.md`，简要说明可用 Agent 及如何引用 command-center |

---

## 🟢 低优先级 / 增强建议

### 7. 缺少 AGENTS.md 根级入口

**现象**: Cursor 规范支持项目根目录 `AGENTS.md` 作为 Agent 入口，当前仅有 `.cursor/agents/command-center.md`。

**建议**: 在项目根目录创建 `AGENTS.md`，简要说明可用 Agent 及如何引用 command-center。

### 8. 文档与实现数量不一致

**现象**:
- README 称「31 规则」「100+ 脚本」「30+ 钩子」
- 实际：46 规则文件、75+ core 脚本、36 hooks 脚本

**建议**: 统一 README 中的统计数据，或改为「30+」「75+」等近似表述并注明「约」。

### 9. 配置热重载与 Schema 验证

**现象**: ROADMAP 提到「配置热重载」「JSON Schema 验证」，需确认 `config-manager.sh`、`cursor-config.schema.json` 是否已实现。

**建议**: 对照 ROADMAP 逐项检查配置系统能力，未实现部分加入完善计划。

### 10. 跨平台与 MCP 集成

**现象**: 存在 `platform_adapter.md`、`local-mcp-integration.sh`、`mcp-detector.sh`，需验证 Windows/macOS 实际支持情况。

**建议**: 建立跨平台测试清单，并在文档中标注各平台支持状态。

---

## 📋 完善任务清单（按执行顺序）

| 序号 | 任务 | 优先级 | 预估工作量 |
|------|------|--------|------------|
| 1 | 创建或修正 verify-system.sh 引用 | 高 | 小 |
| 2 | 修正 command-center.md 文档路径 | 高 | 小 |
| 3 | 消除硬编码路径（见上文表格） | 高 | 中 |
| 4 | 统一规则 frontmatter：`always_apply` → `alwaysApply` | 高 | 小 |
| 5 | 在关键文档中明确 skills 双目录及 features/skills 非标准格式 | 中 | 小 |
| 6 | 统一 features/automation README 与 hooks 描述 | 中 | 小 |
| 7 | 收敛技能匹配逻辑，避免多处重复实现 | 中 | 中 |
| 8 | 明确 constitution 与 generator 的触发顺序，避免冲突 | 中 | 小 |
| 9 | 创建根目录 AGENTS.md | 低 | 小 |
| 10 | 统一 README 统计数据 | 低 | 小 |
| 11 | 对照 ROADMAP 检查配置系统实现状态 | 中 | 中 |
| 12 | 建立跨平台与 MCP 支持清单 | 低 | 中 |
| 13 | 扩展插件系统（与 ROADMAP 同步） | 中 | 大 |

---

## 🔗 与 ROADMAP 的关联

本完善计划与 `ROADMAP.md` 的对应关系：

| ROADMAP 章节 | 本计划对应项 |
|--------------|--------------|
| 2.1 跨平台兼容性 | 任务 9 |
| 2.2 配置系统重构 | 任务 8 |
| 4.1 插件生态体系 | 任务 10 |
| 3.1 测试覆盖完善 | 建议新增：为 verify-system 等增加测试 |

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
