# 🛠️ 开发规范与指南

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

## ⚠️ 最高优先级：双目录架构强制要求

### 🚫 绝对禁止的行为
**任何违反以下规定的代码都不能被接受，必须立即重构**：

#### 1. 在 .cursor/ 目录中生成运行时数据
```bash
# ❌ 错误示例
REPORT_FILE="$SCRIPT_DIR/report.json"  # SCRIPT_DIR 指向 .cursor/
echo "{}" > "$REPORT_FILE"

# ✅ 正确示例
REPORT_FILE="$PROJECT_ROOT/.cursorGrowth/reports/$(date +%Y%m%d_%H%M%S).json"
echo "{}" > "$REPORT_FILE"
```

#### 2. 硬编码 .cursor/ 路径进行数据写入
```bash
# ❌ 错误示例
mkdir -p ".cursor/my_feature"
echo "data" > ".cursor/my_feature/file.txt"

# ✅ 正确示例
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"
mkdir -p "$GROWTH_DIR/my_feature"
echo "data" > "$GROWTH_DIR/my_feature/file.txt"
```

#### 3. 在配置文件中存储用户数据
```bash
# ❌ 错误示例
USER_CONFIG="$SCRIPT_DIR/user_config.json"  # 错误：会进入版本控制
echo '{"preference": "value"}' > "$USER_CONFIG"

# ✅ 正确示例
USER_CONFIG="$PROJECT_ROOT/.cursorGrowth/personal/user_profile.json"
echo '{"preference": "value"}' > "$USER_CONFIG"
```

### ✅ 强制要求的模式

#### 脚本初始化模板
```bash
#!/bin/bash

# 获取正确的目录路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# 生长目录 - 所有运行时数据必须存储在这里
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"

# 确保生长目录存在
if [ ! -d "$GROWTH_DIR" ]; then
    echo "🌱 初始化项目生长目录..."
    mkdir -p "$GROWTH_DIR"
fi

# 定义数据目录
MY_FEATURE_DIR="$GROWTH_DIR/my_feature"
REPORTS_DIR="$MY_FEATURE_DIR/reports"
CACHE_DIR="$MY_FEATURE_DIR/cache"

# 初始化功能目录
init_directories() {
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$CACHE_DIR"
}

# 所有数据操作都使用 GROWTH_DIR 下的路径
save_report() {
    local report_file="$REPORTS_DIR/$(date +%Y%m%d_%H%M%S)_report.json"
    echo '{"status": "success"}' > "$report_file"
}

# 所有缓存操作都使用 GROWTH_DIR 下的路径
save_cache() {
    local cache_file="$CACHE_DIR/cache.json"
    echo '{"cached": true}' > "$cache_file"
}
```

#### 变量命名规范
```bash
# ✅ 推荐的变量命名
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"        # 生长目录根目录
FEATURE_DIR="$GROWTH_DIR/my_feature"           # 功能专用目录
REPORTS_DIR="$FEATURE_DIR/reports"             # 报告目录
CACHE_DIR="$FEATURE_DIR/cache"                 # 缓存目录
LOGS_DIR="$GROWTH_DIR/logs"                    # 日志目录

# ❌ 禁止使用的变量命名
SCRIPT_DIR_DATA="$SCRIPT_DIR/data"             # 错误：在 .cursor/ 下
CURSOR_DATA="$CURSOR_DIR/mydata"              # 错误：在 .cursor/ 下
CONFIG_DATA="$CURSOR_DIR/config/runtime.json"  # 错误：在 .cursor/ 下
```

## 🔍 代码审查清单

### 脚本审查要点
- [ ] 是否在 `.cursor/` 目录中生成了任何文件？
- [ ] 是否正确使用了 `$GROWTH_DIR` 变量？
- [ ] 是否初始化了生长目录？
- [ ] 是否所有数据文件都存储在 `.cursorGrowth/` 下？

### 规则审查要点
- [ ] 是否避免了运行时数据生成？
- [ ] 是否正确引用了生长目录路径？
- [ ] 是否提供了正确的路径配置示例？

### 测试审查要点
- [ ] 测试是否验证了正确的目录结构？
- [ ] 测试数据是否存储在正确位置？
- [ ] 清理操作是否正确执行？

## 🛠️ 开发工具与辅助脚本

### 架构合规检查脚本
```bash
#!/bin/bash
# 检查脚本是否符合双目录架构

check_architecture_compliance() {
    local script_file="$1"

    echo "🔍 检查 $script_file 的架构合规性..."

    # 检查是否使用了 .cursor/ 进行数据写入
    if grep -n ">\s*\.cursor/\|echo.*>.*\.cursor/" "$script_file"; then
        echo "❌ 发现违规：向 .cursor/ 目录写入数据"
        return 1
    fi

    # 检查是否正确使用了 GROWTH_DIR
    if grep -q "GROWTH_DIR" "$script_file"; then
        echo "✅ 使用了 GROWTH_DIR 变量"
    else
        echo "⚠️ 警告：未发现 GROWTH_DIR 变量使用"
    fi

    echo "✅ 架构合规检查通过"
    return 0
}
```

### 目录结构验证脚本
```bash
#!/bin/bash
# 验证项目目录结构是否正确

validate_directory_structure() {
    echo "📁 验证目录结构..."

    # 检查 .cursor/ 是否干净
    if find ".cursor" -name "*.log" -o -name "*.json" -o -name "*[0-9]*.txt" | grep -v config/ | grep -v monitoring/metrics.json; then
        echo "❌ 发现 .cursor/ 目录中的运行时文件"
        return 1
    fi

    # 检查 .cursorGrowth/ 是否存在
    if [ ! -d ".cursorGrowth" ]; then
        echo "❌ 缺少 .cursorGrowth/ 目录"
        return 1
    fi

    # 检查 .gitignore 是否包含 .cursorGrowth/
    if ! grep -q "^\.cursorGrowth/" .gitignore 2>/dev/null; then
        echo "⚠️ .gitignore 未包含 .cursorGrowth/"
    fi

    echo "✅ 目录结构验证通过"
    return 0
}
```

## 📚 最佳实践

### 1. 始终定义 GROWTH_DIR
```bash
# 在每个脚本开头
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"
```

### 2. 使用功能专用子目录
```bash
# 为每个功能创建专用目录
MY_FEATURE_DIR="$GROWTH_DIR/my_feature"
REPORTS_DIR="$MY_FEATURE_DIR/reports"
CACHE_DIR="$MY_FEATURE_DIR/cache"
```

### 3. 初始化目录结构
```bash
init_directories() {
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$CACHE_DIR"
}
```

### 4. 使用时间戳文件名
```bash
# 避免文件名冲突
timestamp=$(date '+%Y%m%d_%H%M%S')
report_file="$REPORTS_DIR/report_$timestamp.json"
```

### 5. 错误处理和清理
```bash
# 确保错误时也清理临时文件
trap 'cleanup_temp_files' EXIT

cleanup_temp_files() {
    rm -f "$TEMP_DIR"/*.tmp 2>/dev/null || true
}
```

## 🚨 常见错误模式

### 错误模式1：忘记定义 GROWTH_DIR
```bash
# ❌ 错误
DATA_DIR=".cursor/mydata"
echo "data" > "$DATA_DIR/file.txt"

# ✅ 正确
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"
DATA_DIR="$GROWTH_DIR/mydata"
echo "data" > "$DATA_DIR/file.txt"
```

### 错误模式2：硬编码路径
```bash
# ❌ 错误
mkdir -p "../.cursorGrowth/mydata"  # 相对路径不稳定
echo "data" > "../.cursorGrowth/mydata/file.txt"

# ✅ 正确
GROWTH_DIR="$PROJECT_ROOT/.cursorGrowth"
DATA_DIR="$GROWTH_DIR/mydata"
mkdir -p "$DATA_DIR"
echo "data" > "$DATA_DIR/file.txt"
```

### 错误模式3：混合使用不同目录
```bash
# ❌ 错误
CONFIG_FILE="$CURSOR_DIR/config.json"      # .cursor/ 目录
DATA_FILE="$GROWTH_DIR/data.json"          # .cursorGrowth/ 目录
# 配置文件和数据文件分离在不同位置

# ✅ 正确
CONFIG_FILE="$GROWTH_DIR/config/user.json"  # 都在生长目录
DATA_FILE="$GROWTH_DIR/data/app.json"
```

## 📋 合规性检查清单

### 新脚本开发检查清单
- [ ] 定义了 `GROWTH_DIR` 变量？
- [ ] 所有数据文件路径都使用 `GROWTH_DIR`？
- [ ] 没有向 `.cursor/` 目录写入任何文件？
- [ ] 初始化了生长目录结构？
- [ ] 提供了正确的错误处理和清理？

### 现有脚本修改检查清单
- [ ] 识别了所有向 `.cursor/` 写入的文件操作？
- [ ] 迁移了所有数据存储到 `.cursorGrowth/`？
- [ ] 更新了所有相关的路径变量？
- [ ] 测试了修改后的功能是否正常？
- [ ] 清理了错误生成的旧文件？

---

*🛠️ 此开发规范确保所有代码都遵循双目录架构原则，维护系统的可复制性、安全性和长期可维护性。*

*任何违反此规范的代码必须立即重构，严重违反可能导致代码无法合并。*