# 项目路径全量一致性扫描与修复计划 (Plan)

本项目已完成从「核心层 + `.cursor-extras` 扩展层」到 **单一官方 `.cursor/` 目录** 的迁移。运行时与 CI 均以 `.cursor/` + 根目录 `AGENTS.md` 为准。

## 待办任务清单 (Todo List) — Phase 1

- [x] **Task 1: 修复 README.en.md 软链接问题** [completed]
- [x] **Task 2: 全量路径一致性扫描** [completed]
- [x] **Task 3: 生成路径错配映射表** [completed]
- [x] **Task 4: 执行批量路径修复** [completed]
- [x] **Task 5: 验证修复后的自洽性** [completed]
- [x] **Task 6: 更新 Plan、CHANGELOG.md 与版本管理** [completed]

## 待办任务清单 (Todo List) — Phase 2：Cursor 官方规范

- [x] **Task 2.1: 升级规则至 `.mdc` 标准格式** [completed]
- [x] **Task 2.2: 升级技能（Skills）至标准目录** [completed]
- [x] **Task 2.3: 升级子代理（Subagents）至标准目录** [completed]
- [x] **Task 2.4: 升级配置钩子（Hooks）到标准目录** [completed]
- [x] **Task 2.5: 移除硬编码路径并实行路径自洽** [completed]
- [x] **Task 2.6: 进行最终功能验证与版本管理更新** [completed]

## 待办任务清单 (Todo List) — Phase 3：收尾与清理

- [x] **Task 3.1: README.en.md 迁至 `.cursor/` 并更新根软链** [completed]
- [x] **Task 3.2: CI 与测试脚本统一至 `.cursor/tests/`** [completed]
- [x] **Task 3.3: 根文档 `README.md` / `plan.md` 更新为「复制 `.cursor/` + `AGENTS.md`」** [completed]
- [x] **Task 3.4: 运行时依赖自 extras 并入 `.cursor/` 后删除 `.cursor-extras/`** [completed]
- [x] **Task 3.5: 归档说明写入 `archive/` 并更新 CHANGELOG `[4.6.1]`** [completed]

---

## 讨论与决策记录

- **2026-06-01**: Phase 1 路径一致性修复完成。
- **2026-06-01 (Phase 2)**: Rules/Skills/Agents/Hooks 全面对齐 Cursor 官方 `.cursor/` 结构；76 条 `.mdc`、skill-dispatcher、master/command-center、`hooks.json` + 36 钩子脚本。
- **2026-06-01 (Phase 3 收尾)**: `README.en.md` → `.cursor/README.en.md`；CI 改 `.cursor/tests/`；`plugins/`、automation 等并入 `.cursor/`；**已删除** `.cursor-extras/`；详见 `archive/20260601_222400_cursor-extras_目录删除说明.md`。

**当前开箱即用方式**：`cp -r .cursor` 与 `cp AGENTS.md` 到目标项目根目录即可。

## 待办任务清单 (Todo List) — Phase 4：规范收尾

- [x] **Task 4.1: 删除与 `.mdc` 重复的 workflow/tech `.md` 规则** [completed]
- [x] **Task 4.2: 修复 `constitution.mdc` 及全仓 `.mdc` frontmatter 粘连** [completed]
- [x] **Task 4.3: 迁移高频技能至 `.cursor/skills/<name>/SKILL.md`（10 个含 dispatcher）** [completed]
- [x] **Task 4.4: `unified-check` 适配 `.mdc` / 标准技能路径** [completed]
- [x] **Task 4.5: 验证测试与 CHANGELOG `[4.6.3]`** [completed]

### Phase 4 讨论记录

- **2026-06-01**: Phase 2 剩余小尾巴收尾；`.cursor-extras` 运行时引用仅保留于 `CHANGELOG.md` / `plan.md` 历史说明。
