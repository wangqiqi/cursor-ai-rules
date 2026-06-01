# 🌱 .cursorGrowth 目录自动创建机制

## 📋 概述

`.cursorGrowth` 目录是 Cursor AI Rules 系统的核心数据存储位置，用于存储项目运行时数据、学习记录、监控指标等。本系统确保在任何情况下调用任何 `.cursor` 内部指令时，该目录都会被自动创建。

### ⚠️ 正确位置（必须遵守）

`.cursorGrowth` **必须**位于项目根目录，与 `.cursor` **同级**：

```
项目根目录/
├── .cursor/          # Cursor 配置与脚本
├── .cursorGrowth/    # 生长数据（与 .cursor 同级，不能放在 .cursor 内部）
└── ...
```

**错误示例**：`.cursor/.cursorGrowth`（在 .cursor 内部）— 系统会自动清理并拒绝使用。

## 🎯 设计原则

### 1. 无条件创建
- **MUST** 在任何指令执行前确保目录存在
- **NEVER** 依赖手动创建目录
- **ALWAYS** 在首次使用时自动初始化
- **DO NOT** 因目录不存在而导致指令失败

### 2. 透明化处理
- **MUST** 在后台静默创建目录
- **ALWAYS** 在DEBUG模式下显示创建信息
- **DO NOT** 干扰正常使用流程
- **MUST** 确保创建失败不影响主流程

### 3. 结构化初始化
- **MUST** 创建完整的标准目录结构
- **ALWAYS** 初始化必要的配置文件
- **DO NOT** 创建不必要的子目录
- **MUST** 支持`.gitignore`自动配置

## 🏗️ 实现机制

### Layer 1: path-config.sh 强制初始化

**文件位置**: `.cursor/core/path-config.sh`

**触发时机**: 当任何脚本source `path-config.sh` 时

**实现逻辑**:
```bash
# 强制初始化生长目录（无条件执行）
force_init_growth_directory() {
    # 无条件创建目录，如果已存在则忽略
    if [ ! -d "$CURSOR_GROWTH" ]; then
        mkdir -p "$CURSOR_GROWTH"
        
        # 创建.gitkeep确保目录被Git跟踪
        echo "{}" > "$CURSOR_GROWTH/.gitkeep" 2>/dev/null || true
        
        # 如果开启了DEBUG模式，输出创建信息
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo "📁 强制创建.cursorGrowth目录: $CURSOR_GROWTH" >&2
        fi
    fi
    
    # 确保标准子目录结构存在
    init_growth_directories 2>/dev/null || true
}

# 立即执行强制初始化（无条件执行）
force_init_growth_directory
```

**特点**:
- ✅ 在脚本加载时立即执行
- ✅ 无条件创建，不检查依赖
- ✅ 失败不影响主流程（使用`|| true`）
- ✅ 自动初始化标准子目录结构

### Layer 2: cursor-master.sh 主入口保护

**文件位置**: `.cursor/cursor-master.sh`

**触发时机**: 当用户调用任何 `/master` 指令时

**实现逻辑**:
```bash
main() {
    # 🌱 强制初始化生长目录（在任何操作之前）
    # 确保调用任何指令时都会创建 .cursorGrowth
    if [ ! -d "$CURSOR_GROWTH" ]; then
        mkdir -p "$CURSOR_GROWTH"
        echo "{}" > "$CURSOR_GROWTH/.gitkeep" 2>/dev/null || true
        if [[ "${DEBUG:-0}" == "1" ]]; then
            echo -e "${CYAN}📁 自动创建.cursorGrowth目录${NC}" >&2
        fi
    fi
    
    # ... 继续正常指令处理
}
```

**特点**:
- ✅ 在主函数开头执行
- ✅ 任何指令都会触发创建
- ✅ 静默执行，不影响用户体验
- ✅ 支持DEBUG模式查看详情

### Layer 3: Cursor 原生 Hooks (beforeSubmitPrompt)

**文件位置**: `.cursor/features/hooks/hooks.json` + `.cursor/hooks/ensure-growth-on-prompt.sh`

**触发时机**: 当用户在 Cursor 对话框提交任何内容（包括 `/master`）时，在发送给 AI 之前执行

**启用要求**:
- Cursor 1.7+ 且需在 **Settings → Features** 中启用 Hooks（若为 Beta 功能）
- 查看 **Output → Hooks** 面板确认钩子是否执行

**若 Hooks 未生效**：Layer 4（AI 规则）会兜底创建

### Layer 4: AI 规则兜底（master.md + growth-ensure-on-master.md）

**文件位置**: `.cursor/commands/master.md`、`.cursor/agents/command-center.md`、`.cursor/rules/growth-ensure-on-master.md`

**触发时机**: 当 AI 处理包含 `/master` 的用户输入时

**实现**: AI 被显式指示先运行 `bash .cursor/features/automation/automation/scripts/growth_init.sh` 再继续处理

### Layer 5: 旧版 Git/自定义 Hooks 自动初始化

**文件位置**: `.cursor/features/hooks/master-init.sh`

**触发时机**: 当用户首次使用 `/master` 命令时（通过自定义钩子系统）

**实现逻辑**:
```bash
# 检查$CURSOR_GROWTH目录是否存在
if [ ! -d "$GROWTH_DIR" ]; then
    echo "🌱 检测到首次使用Master命令，正在初始化生长目录..." >&2
    
    # 调用生长目录初始化脚本
    if [ -f "$SCRIPT_DIR/../automation/scripts/growth_init.sh" ]; then
        bash "$SCRIPT_DIR/../../automation/scripts/growth_init.sh" >/dev/null 2>&1
    fi
    
    # 创建AI配置文件
    cat > "$GROWTH_DIR/ai-profile.json" << EOF
    ...
    EOF
fi
```

**特点**:
- ✅ 首次使用时完整初始化
- ✅ 创建AI配置文件
- ✅ 创建监控指标文件
- ✅ 用户友好的提示信息

## 📁 目录结构

### 标准子目录（自动创建）

```
.cursorGrowth/
├── perception/           # 环境感知数据
├── user_data/            # 用户相关数据
│   └── master_interactions.json
├── project_data/         # 项目相关数据
├── ai/                   # AI相关数据
│   ├── models/
│   ├── training_data/
│   ├── metrics/
│   └── results/
├── analytics/            # 分析数据
│   ├── data/
│   └── cache/
├── monitoring/           # 系统监控
│   └── logs/
├── integrations/         # 第三方集成
│   ├── sync/
│   └── mcp-configs/
├── conversations/        # 对话记录
├── learning/             # 学习记录
└── .gitkeep             # Git跟踪占位符
```

### 初始化文件

1. **`.gitkeep`**: 确保空目录被Git跟踪
2. **`user/config/project_state.json`**: 项目持久化状态（原 `.cursor-project.json`，含 currentRole、projectId、lastUpdated）
3. **`ai-profile.json`**: AI配置和用户偏好
4. **`analytics-monitoring-metrics.json`**: 监控指标初始化

## 🔧 使用场景

### 场景1: 首次使用

```bash
# 用户首次调用 /master 命令
/master 帮我创建一个React项目

# 系统自动执行：
# 1. 检测 .cursorGrowth 不存在
# 2. 创建目录结构
# 3. 初始化配置文件
# 4. 输出提示信息（首次）
# 5. 继续处理用户请求
```

### 场景2: Git Hook触发

```bash
# 用户执行 git commit
git commit -m "feat: add new feature"

# post-commit hook 自动执行：
# 1. 检查 .cursorGrowth 存在性
# 2. 如果不存在，先创建目录
# 3. 记录提交信息到生长目录
# 4. 触发学习引擎
```

### 场景3: 调用核心脚本

```bash
# 用户调用系统检查
.cursor/cursor-master.sh syscheck

# 脚本自动执行：
# 1. source path-config.sh
# 2. 触发 force_init_growth_directory()
# 3. 确保目录存在
# 4. 继续执行检查
```

## 🛡️ 错误处理

### 创建失败处理

```bash
# 创建目录时可能的错误情况
if ! mkdir -p "$CURSOR_GROWTH" 2>/dev/null; then
    # 静默失败，不影响主流程
    # 在DEBUG模式下输出警告
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "⚠️  生长目录创建失败: $CURSOR_GROWTH" >&2
    fi
fi

# 使用 || true 确保失败不会中断执行
init_growth_directories 2>/dev/null || true
```

### 权限问题处理

```bash
# 如果目录已存在但无写入权限
if [ -d "$CURSOR_GROWTH" ] && [ ! -w "$CURSOR_GROWTH" ]; then
    # 在DEBUG模式下警告
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "⚠️  生长目录无写入权限: $CURSOR_GROWTH" >&2
    fi
    # 继续执行，不中断流程
fi
```

## 🐛 调试模式

### 启用DEBUG模式

```bash
# 方式1: 环境变量
export DEBUG=1
/master help

# 方式2: 命令前缀
DEBUG=1 .cursor/cursor-master.sh syscheck

# 方式3: 在脚本中设置
# 在 cursor-master.sh 或 path-config.sh 中
DEBUG=1
```

### DEBUG输出示例

```bash
$ DEBUG=1 /master help
📁 强制创建.cursorGrowth目录: {{PROJECT_ROOT}}/.cursorGrowth
🔍 Path Config Debug:
  项目标识符: proj_abc123
  项目显示名: my-project
  ...
🎯 ===== 智能Master控制器 =====
```

## ✅ 验证检查

### 检查目录是否存在

```bash
# 检查目录
test -d "$PROJECT_ROOT/.cursorGrowth" && echo "✅ 目录存在" || echo "❌ 目录不存在"

# 检查标准子目录
ls -la "$PROJECT_ROOT/.cursorGrowth/"
```

### 检查初始化文件

```bash
# 检查.gitkeep
test -f "$PROJECT_ROOT/.cursorGrowth/.gitkeep" && echo "✅ .gitkeep存在"

# 检查AI配置
test -f "$PROJECT_ROOT/.cursorGrowth/ai-profile.json" && echo "✅ AI配置存在"
```

### 测试自动创建

```bash
# 1. 删除目录（如果存在）
rm -rf .cursorGrowth

# 2. 调用任意指令
/master help

# 3. 验证目录已创建
ls -la .cursorGrowth/
```

## 📊 保障级别

### Level 1: 基础保障（100%）
- ✅ 任何脚本source path-config.sh时触发
- ✅ 覆盖所有核心脚本
- ✅ 无条件创建，无依赖要求

### Level 2: 入口保障（100%）
- ✅ cursor-master.sh主函数强制创建
- ✅ 覆盖所有用户命令
- ✅ 主入口零遗漏

### Level 3: Hook保障（100%）
- ✅ Git hooks自动初始化
- ✅ 首次使用完整初始化
- ✅ 用户友好提示

### Level 4: 容错保障（100%）
- ✅ 创建失败不影响主流程
- ✅ 静默处理，不干扰使用
- ✅ 失败时可重试

## 🎯 最佳实践

### 开发新脚本时

```bash
#!/bin/bash
# ✅ 正确做法：第一时间source path-config.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"

# 此时 .cursorGrowth 目录已保证存在
# 可以安全使用 $CURSOR_GROWTH 变量
echo "data" > "$CURSOR_GROWTH/mydata/file.txt"
```

### 检查目录存在性

```bash
# ❌ 不推荐：手动检查和创建
if [ ! -d ".cursorGrowth" ]; then
    mkdir -p .cursorGrowth
fi

# ✅ 推荐：直接使用，相信自动创建机制
# 目录已由 path-config.sh 确保存在
echo "data" > "$CURSOR_GROWTH/mydata/file.txt"
```

### 调试目录问题

```bash
# 启用DEBUG模式查看创建过程
DEBUG=1 /master your-command

# 检查目录权限
ls -la .cursorGrowth/

# 验证环境变量
echo $CURSOR_GROWTH
```

## 🔄 版本历史

### v4.3.0 (2026-02-07)
- ✅ 添加 `force_init_growth_directory()` 函数
- ✅ 在 `path-config.sh` 中立即执行强制初始化
- ✅ 在 `cursor-master.sh` 主函数添加双重保障
- ✅ 完善错误处理和DEBUG支持
- ✅ 100%保障任何指令调用时都会创建目录

### v4.2.0及以前
- ✅ 基础目录创建逻辑
- ✅ Git hooks初始化
- ✅ 部分脚本手动创建

## 🔧 对话框 /master 未创建 .cursorGrowth 的排查

当在 Cursor 聊天框输入 `/master` 后 `.cursorGrowth` 仍未创建时：

### 1. 检查 Cursor Hooks 是否启用

- 打开 **Cursor Settings → Features**，确认 **Hooks** 或 **Third-party skills** 已开启
- 打开 **Output** 面板，选择 **Hooks** 通道，查看是否有钩子执行日志或报错

### 2. 手动创建（临时方案）

```bash
bash .cursor/features/automation/automation/scripts/growth_init.sh
```

### 3. 依赖 AI 规则兜底

若 Hooks 未生效，AI 会在处理 `/master` 时根据 `master.md` 和 `growth-ensure-on-master.md` 的指示自动运行上述脚本。**再次发送包含 `/master` 的消息**，AI 会先创建目录再继续处理。

### 4. 验证钩子脚本

```bash
echo '{"workspace_roots":["'"$(pwd)"'"]}' | bash .cursor/hooks/ensure-growth-on-prompt.sh
ls -la .cursorGrowth/
```

## 📚 相关文档

- [路径配置系统](../developer/path-config-system.md)
- [项目生长目录](./project-growth.md)
- [开发指南](../developer/development-guidelines.md)

---

*最后更新: {{GENERATION_TIME}}*
*作者: Cursor AI Rules Team*
