# 🔗 Cursor AI Rules 完整钩子系统集成指南

## 🎯 概述

Cursor AI Rules 现在提供了完整的钩子系统，包含8个专业钩子脚本，覆盖从初始化到监控的完整自动化流程：

### 核心钩子组件
1. **`master-init.sh`** - Master命令自动初始化
2. **`consistency-check.sh`** - 代码一致性检查
3. **`architecture-check.sh`** - 架构合规检查
4. **`performance-monitor.sh`** - 性能监控
5. **`env-perception.sh`** - 环境感知
6. **`event-logger.sh`** - 事件日志记录
7. **`growth-recorder.sh`** - 生长记录
8. **`session-optimizer.sh`** - 会话优化

### 扩展钩子组件
9. **`quality-check.sh`** - 统一质量检查
10. **`token-compression.sh`** - Token压缩优化
11. **`cursor-sync.sh`** - Cursor对话同步
12. **`config-validator.sh`** - 配置验证
13. **`dependency-check.sh`** - 依赖检查

这些钩子基于 `.cursor/core/` 和 `.cursor/config/config/config/` 中的核心脚本改造，适配了钩子系统的输入输出格式，实现了全面的自动化能力。

## 🚀 使用场景

### 1. **Cursor IDE 钩子系统** (当前配置)

```json
// .cursor/features/hooks/hooks.json
{
  "hooks": {
    "beforeSubmitPrompt": [
      {
        "name": "master-init",
        "command": "features/hooks/master-init.sh",
        "enabled": true
      }
    ]
  }
}
```

**触发条件**: 用户在 Cursor IDE 中输入包含 `/master` 或 `master` 关键词的内容

### 2. **独立脚本调用**

```bash
# 直接调用钩子脚本
echo '{"prompt": "/master 初始化项目"}' | bash .cursor/features/hooks/master-init.sh

# 在其他脚本中集成
source .cursor/features/hooks/master-init.sh
ensure_growth_directory "你的需求描述"
```

### 3. **脚本集成模式**

```bash
# 在任何需要 .cursorGrowth 目录的脚本中集成
ensure_growth_directory() {
    local user_input="$1"
    echo "{\"prompt\": \"/master $user_input\"}" | bash ".cursor/features/hooks/master-init.sh" >/dev/null 2>&1

    [ -d ".cursorGrowth" ] && return 0 || return 1
}
```

## 📋 集成示例

### 示例1: 在分析脚本中集成

```bash
#!/bin/bash
# 分析脚本示例

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../features/hooks/master-init.sh"

analyze_project() {
    # 确保生长目录存在
    echo "{\"prompt\": \"/master 项目分析\"}" | bash "$HOOK_SCRIPT" >/dev/null 2>&1

    if [ ! -d ".cursorGrowth" ]; then
        echo "❌ 无法初始化生长目录"
        return 1
    fi

    # 执行分析逻辑
    echo "📊 执行项目分析..."
    # ... 分析代码 ...
}

analyze_project
```

### 示例2: 在构建脚本中集成

```bash
#!/bin/bash
# 构建脚本示例

HOOK_SCRIPT=".cursor/features/hooks/master-init.sh"

build_project() {
    # 初始化生长目录（用于构建记录）
    echo "{\"prompt\": \"/master 项目构建\"}" | bash "$HOOK_SCRIPT" >/dev/null 2>&1

    # 记录构建开始
    mkdir -p ".cursorGrowth/builds"
    echo "{\"build_start\": \"$(date)\"}" > ".cursorGrowth/builds/current.json"

    # 执行构建
    echo "🔨 执行项目构建..."
    # ... 构建逻辑 ...

    # 记录构建结果
    echo "{\"build_end\": \"$(date)\", \"status\": \"success\"}" > ".cursorGrowth/builds/current.json"
}

build_project
```

### 示例3: 在测试脚本中集成

```bash
#!/bin/bash
# 测试脚本示例

HOOK_SCRIPT=".cursor/features/hooks/master-init.sh"

run_tests() {
    # 初始化生长目录（用于测试记录）
    echo "{\"prompt\": \"/master 运行测试\"}" | bash "$HOOK_SCRIPT" >/dev/null 2>&1

    # 创建测试记录目录
    mkdir -p ".cursorGrowth/tests"

    # 执行测试
    echo "🧪 运行测试套件..."

    # 记录测试结果
    local test_result="{\"timestamp\": \"$(date)\", \"status\": \"passed\"}"
    echo "$test_result" > ".cursorGrowth/tests/latest.json"
}

run_tests
```

## 🔧 高级配置

### 自定义触发关键词

```bash
# 修改钩子脚本中的检测逻辑
if [[ "$command_text" =~ "/(master|cursor|ai)" ]] || [[ "$prompt_text" =~ "(master|cursor|ai)" ]]; then
    # 支持更多关键词触发
fi
```

### 条件初始化

```bash
# 只在特定项目类型下初始化
if [[ "$command_text" =~ "react" ]] && [ -f "package.json" ]; then
    # React项目特有的初始化
fi
```

### 多环境支持

```bash
# 根据环境变量调整初始化行为
case "$CURSOR_ENV" in
    "development")
        # 开发环境配置
        ;;
    "production")
        # 生产环境配置
        ;;
esac
```

## 📊 性能优化

### 异步初始化

```json
// 在 hooks.json 中配置异步执行
{
  "hooks": {
    "onSessionStart": [
      {
        "name": "async-master-init",
        "command": "features/hooks/master-init.sh",
        "async": true,
        "timeout": 5000
      }
    ]
  }
}
```

### 缓存机制

```bash
# 在钩子脚本中添加缓存检查
if [ -f ".cursorGrowth/.init_complete" ]; then
    echo "✅ 生长目录已初始化，跳过" >&2
    return 0
fi

# 初始化完成后创建标记文件
touch ".cursorGrowth/.init_complete"
```

## 🛠️ 故障排除

### 问题1: 钩子没有触发

**检查**:
```bash
# 验证 hooks.json 配置
cat .cursor/features/hooks/hooks.json

# 测试钩子脚本
echo '{"prompt": "/master test"}' | bash .cursor/features/hooks/master-init.sh
```

### 问题2: 初始化失败

**检查**:
```bash
# 检查脚本权限
ls -la .cursor/features/hooks/master-init.sh

# 检查项目根目录计算
cd .cursor/features/hooks
SCRIPT_DIR="$(pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
echo "PROJECT_ROOT: $PROJECT_ROOT"
```

### 问题3: 路径问题

**解决方案**:
```bash
# 使用绝对路径
HOOK_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../features/hooks/master-init.sh"

# 或者使用相对路径
HOOK_SCRIPT="../../../features/hooks/master-init.sh"
```

## 🎯 最佳实践

1. **统一入口**: 在所有需要 `.cursorGrowth` 的脚本中集成相同的初始化逻辑

2. **错误处理**: 总是检查初始化结果，避免脚本在缺少生长目录时崩溃

3. **性能考虑**: 对于频繁调用的脚本，考虑添加缓存机制

4. **用户体验**: 初始化过程应该是透明的，不应该阻塞用户的主要操作

5. **向后兼容**: 确保在 `.cursorGrowth` 不存在时脚本仍能正常工作

## 🚀 扩展应用

### CI/CD 集成

```yaml
# .github/workflows/ci.yml
- name: Setup Cursor AI Rules
  run: |
    echo '{"prompt": "/master CI构建"}' | bash .cursor/features/hooks/master-init.sh
    # CI环境下的特殊配置
```

### Docker 集成

```dockerfile
# Dockerfile
COPY .cursor /app/.cursor
RUN echo '{"prompt": "/master 容器部署"}' | bash .cursor/features/hooks/master-init.sh
```

### IDE 插件集成

```javascript
// VS Code 插件中的集成
const { exec } = require('child_process');

function initializeCursorGrowth() {
    const command = 'echo \'{"prompt": "/master IDE集成"}\' | bash .cursor/features/hooks/master-init.sh';
    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error('初始化失败:', error);
            return;
        }
        console.log('Cursor AI Rules 初始化完成');
    });
}
```

---

**总结**: `master-init.sh` 钩子脚本是一个高度可复用的工具，可以在 Cursor IDE 钩子系统、独立脚本调用、CI/CD 流程、Docker 构建等各种场景中集成使用，确保 `.cursorGrowth` 目录在需要时自动初始化。🎯