# Cursor AI Rules 项目优化计划

> **目标**: 修复 P0/P1 级关键问题，提升代码质量和可维护性
> **阶段**: 共 3 个阶段，按优先级递进

---

## 阶段一：P0 关键修复（预计 4 个任务）

### 任务 1.1：修复 `common.sh` 中未定义的 `handle_error` 引用

- **文件**: `.cursor/core/common.sh`
- **问题**: 第 96 行 `save_config_file` 函数中调用了 `handle_error` 但该函数从未定义
- **修改方案**: 将 `handle_error` 替换为实际错误处理逻辑，或补全 `handle_error` 函数定义
- **验证**: 执行 `shellcheck .cursor/core/common.sh` 无报错

### 任务 1.2：统一日志函数命名并消除重复定义

- **涉及文件**:
  - `.cursor/core/hooks-engine.sh` — 定义了 `log_warning()`（带 ing）
  - `.cursor/core/common.sh` 第 82 行 — 调用了 `log_warn`（无 ing）
  - 所有独立定义颜色变量和日志函数的脚本
- **修改方案**:
  - 将颜色变量和日志函数统一抽取到 `common.sh`
  - 所有脚本统一 source `common.sh`（而非各自定义）
  - 统一使用 `log_info / log_success / log_warning / log_error` 命名
- **验证**: 运行 `grep -r "log_warn\b" .cursor/core/` 不应有匹配

### 任务 1.3：修复 `init.sh` 环境变量写入 Bug

- **文件**: `.cursor/core/init.sh` 第 162-173 行
- **问题**: 向 `~/.bashrc` / `~/.zshrc` 追加了包含 `$PROJECT_ROOT` 的 source 语句，但该变量在 rc 文件上下文中未定义
- **修改方案**: 替换为绝对路径或确保变量在 source 时已正确定义
- **验证**: 手动测试 `source ~/.bashrc` 后 `$CURSOR_ROOT` 可用

### 任务 1.4：修复 `hooks.json` 中 `growth-directory-check` 钩子的疑似 copy-paste bug

- **文件**: `.cursor/features/hooks/hooks.json`
- **问题**: `growth-directory-check` 钩子的 `command` 与 `master-init` 相同（都是 `master-init.sh`）
- **修改方案**: 阅读 `master-init.sh` 功能，确认是否为预期行为；如确认为 bug，修正为正确的脚本路径
- **验证**: 确认钩子调用的脚本符合其名称语义

---

## 阶段二：P1 重要改进（预计 4 个任务）

### 任务 2.1：统一所有入口脚本的严格模式

- **涉及文件**:
  - `.cursor/cursor-master.sh` — `set -e`
  - `.cursor/core/init.sh` — `set -e`
  - 以及其他入口脚本
- **修改方案**: 统一为 `set -euo pipefail`
- **验证**: 逐个文件 `shellcheck` 通过

### 任务 2.2：消除 agent-orchestration 系列的代码重复

- **涉及文件**: `.cursor/core/agent-orchestration-*.sh`（25 个文件）
- **主要重复内容**:
  - 颜色变量定义（`RED/GREEN/YELLOW/BLUE/NC`）
  - 路径计算样板代码
  - 日志函数
- **修改方案**:
  - 将这些公共内容抽取到 `common.sh` 和 `shared-functions.sh`
  - 25 个 agent 文件统一 source 公共模块
  - 删除重复定义
- **验证**: 确保所有 agent 文件 `shellcheck` 通过，且功能回归测试正常

### 任务 2.3：完善 `project.json`

- **文件**: `.cursor/config/project.json`
- **问题**: 只有 3 个元字段，无实质配置
- **修改方案**: 根据 `.cursor/config/project.json.template` 补全项目配置字段，或删除此占位文件
- **验证**: JSON 格式正确，`jq .` 解析通过

### 任务 2.4：统一技能分类体系

- **涉及文件**:
  - `.cursor/features/skills/registry.json`
  - `.cursor/skills/skill-dispatcher/SKILL.md`
- **问题**: registry.json 的 `categories` 字段与 SKILL.md 的分类不一致，且 cursor-ai-rules 的 17 个技能未被映射
- **修改方案**:
  - 统一分类体系（建议采用 SKILL.md 中的分类）
  - 补全所有技能的 `categories` 映射
- **验证**: 确认所有 37 个技能都有正确的分类归属

---

## 阶段三：P2 架构优化（预计 3 个任务）

### 任务 3.1：补充系统测试覆盖率

- **涉及文件**: `.cursor/tests/` 目录
- **方案**:
  - 为 `init.sh` 编写 bats 测试
  - 为 `agent-orchestration-core.sh` 的核心函数编写测试
  - 为 `hooks-engine.sh` 编写测试
- **验证**: 测试覆盖率从 <1% 提升至 >=15%

### 任务 3.2：优化 `jq` 依赖管理

- **方案**:
  - 在 `init.sh` 的 `check_basic_dependencies` 中加入 `jq` 检查
  - 将 JSON 操作统一封装到 `json-module.sh`
  - 为关键 `jq` 操作添加错误处理
- **验证**: 缺失 `jq` 时系统能给出清晰提示

### 任务 3.3：补充系统组件交互文档

- **文件**: `.cursor/docs/developer/SYSTEM_ARCHITECTURE.md`
- **方案**:
  - 补充 Agents / Commands / Rules / Skills / Hooks 之间的交互流程图
  - 明确 rules-router 和 skill-dispatcher 的职责边界
- **验证**: 文档评审通过

---

## 执行顺序依赖关系

```
阶段一（P0）
├── 1.1 common.sh handle_error 修复    ← 无依赖
├── 1.2 日志函数统一                   ← 无依赖
├── 1.3 init.sh 环境变量修复           ← 无依赖
└── 1.4 hooks.json bug 修复           ← 无依赖

阶段二（P1）
├── 2.1 严格模式统一                   ← 建议在 1.2 之后（日志函数已统一）
├── 2.2 消除 agent 代码重复           ← 依赖 1.2（公共函数已抽取）
├── 2.3 project.json 完善             ← 无依赖
└── 2.4 技能分类统一                   ← 无依赖

阶段三（P2）
├── 3.1 补充测试                      ← 建议在 2.2 之后（代码稳定后加测）
├── 3.2 jq 依赖优化                   ← 建议在 2.2 之后（公共模块已稳定）
└── 3.3 补充架构文档                  ← 无依赖
```

---

## 验证标准

每个任务完成后应执行以下验证：
1. **ShellCheck**: `shellcheck <modified_file>` 通过
2. **语法检查**: `bash -n <modified_file>` 通过
3. **功能回归**: `.cursor/verify-system.sh --quick` 通过
4. **无回归**: `grep` 检查无残留的旧命名/定义

---

## 不接受的范围

以下内容不在此计划中（如需可另立计划）：
- 技术规则合并（React 9 个文件过度拆分）
- 引入内存缓存层（LRU cache）
- 文档版本号统一
- 安全扫描正则优化
