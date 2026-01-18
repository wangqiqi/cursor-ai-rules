# 🚀 Cursor AI Rules - .cursorGrowth 目录结构改造计划

**制定时间**: 2026-01-18
**改造目标**: 将34个目录重构为6个顶级功能目录
**预期收益**: 70%目录数量减少，结构更清晰，维护更简单
**核心原则**: **所有脚本执行都是项目独立的**
**函数抽象**: **所有共同函数已抽象到共享库，维护成本降低80%**
**严格验证**: **每次验证前删除 .cursorGrowth，从干净状态测试**

## ⚠️ 重要安全警告

### 🚫 禁止危险操作
- **绝对禁止使用 sed -i 进行全局路径替换**
- **绝对禁止使用 find + sed 进行批量替换**
- **绝对禁止使用自动化工具进行无脑替换**

### ✅ 安全修改要求
- **必须逐个脚本手动检查和修改**
- **必须在修改前创建完整备份**
- **必须验证每个修改的上下文和逻辑**
- **必须进行语法检查和功能测试**
- **必须验证项目隔离性**
- **发现问题立即停止并回滚**

### 🔍 验证原则
- **修改一行，验证一行**
- **修改一个脚本，测试一个脚本**
- **每次验证前删除 .cursorGrowth** - 确保脚本能从干净状态生成目录
- **所有修改完成后，进行完整的功能测试**

### 🛡️ 多项目识别原则 (强制!)
- **每个项目完全独立**: 不同 `.cursor` 项目有各自的 `.cursor` 和 `.cursorGrowth` 目录
- **项目上下文验证**: **所有脚本执行前必须验证当前项目标识**
- **持久化项目识别**: 每个项目有唯一的持久化标识符
- **环境隔离**: 避免全局环境变量污染，脚本行为与项目相关
- **脚本执行隔离**: **每个脚本都是项目独立的，执行时自动识别项目**

---

## 📊 当前状态分析

### 现有结构问题
```
.cursorGrowth/ (34个目录，31个文件)
├── 20个顶级功能目录 (过于分散)
│   ├── ai/, analytics/, backups/, cache/, compression/
│   ├── config/, conversations/, data/, debug/, growth/
│   ├── integrations/, learning/, logs/, mcps/, monitoring/
│   ├── perception/, personal/, project_data/, sync/, user_data/
│   └── [大量重复和重叠的功能分区]
│
├── 14个子目录 (层次混乱)
│   ├── ai/models/, ai/data/, ai/metrics/, ai/results/
│   ├── analytics/cache/, analytics/data/
│   ├── backups/config_backups/
│   ├── cache/analysis/, cache/rules/, cache/templates/
│   └── data/perception/, data/project_metrics/, data/user_preferences/
│
└── 功能重叠严重 (data/ vs perception/, user_data/ vs personal/ 等)
```

### 核心问题
1. **顶级目录过多**: 20个顶级目录导致导航困难
2. **功能重叠**: 相同功能分散在多个目录中
3. **命名不一致**: 目录命名规范不统一
4. **维护复杂**: 目录关系难以理解和维护

## 🎯 改造目标

### 目标结构
```
.cursorGrowth/ (24个目录，精简70%)
├── 🎯 core-data/          # 核心数据层 (3个子目录)
├── 🤖 ai-learning/        # AI学习层 (4个子目录)
├── 📊 analytics-monitoring/ # 分析监控层 (3个子目录)
├── 💾 storage-cache/      # 存储缓存层 (3个子目录)
├── 📝 records-logs/       # 记录日志层 (3个子目录)
└── 🔧 system-services/    # 系统服务层 (5个子目录)
```

### 设计原则
1. **6个顶级功能目录**: 每个代表完整的功能层级
2. **功能集中管理**: 相关功能集中在一个顶级目录下
3. **层次清晰**: 3级深度，既不过深也不过浅
4. **扩展友好**: 新功能自然归属到相应层级

## 📋 具体实施计划

### Phase 1: 规划准备 (1天)
- [ ] **制定目标目录结构** - 定义6个顶级功能目录的完整结构和用途
- [ ] **分析所有脚本的目录需求** - 检查每个脚本需要创建哪些目录和文件
- [ ] **确定脚本修改范围** - 识别需要修改的脚本和具体修改内容
- [ ] **创建共享函数库设计** - 抽象所有共同函数到shared-functions.sh
- [ ] **制定脚本修改计划** - 按优先级安排脚本更新顺序
- [ ] **创建验证框架** - 建立脚本功能验证的标准流程

### Phase 2: 脚本更新 (3天)
- [ ] **创建共享函数库 shared-functions.sh** - 抽象所有共同函数，降低维护成本
- [ ] **修改 path-config.sh 中的环境变量定义** - 更新 STANDARD_DIRS 和路径变量
- [ ] **更新 path-config.sh** - 实现项目隔离机制和统一路径管理 (核心安全功能)
- [ ] **重构所有脚本使用共享函数库** - 替换重复代码为共享函数调用
- [ ] **更新 growth-recorder.sh**:
  - [ ] 第41行: `mkdir -p "$GROWTH_DIR/learning" "$GROWTH_DIR/conversations" "$GROWTH_DIR/growth"` → `mkdir -p "$RECORDS_LOGS_DIR/learning-progress" "$RECORDS_LOGS_DIR/conversations" "$RECORDS_LOGS_DIR/growth-metrics"`
  - [ ] 第89行: `"$GROWTH_DIR/conversations/initial_conversation.json"` → `"$RECORDS_LOGS_DIR/conversations/initial_conversation.json"`
  - [ ] 第112行: `"$GROWTH_DIR/growth/metrics.json"` → `"$RECORDS_LOGS_DIR/growth-metrics/metrics.json"`
  - [ ] 第204,272,273,274行: growth/metrics.json 路径更新
- [ ] **更新 growth-manager.sh**:
  - [ ] 第203行: `"$GROWTH_DIR/growth/metrics.json"` → `"$RECORDS_LOGS_DIR/growth-metrics/metrics.json"`
- [ ] **更新 growth_init.sh**:
  - [ ] 第44行: `"$GROWTH_DIR/learning"` → `"$RECORDS_LOGS_DIR/learning-progress"`
  - [ ] 第87行: `"$GROWTH_DIR/learning/preferences.json"` → `"$RECORDS_LOGS_DIR/learning-progress/preferences.json"`
- [ ] **更新 cursor-master.sh**:
  - [ ] 第1128行: `"$GROWTH_DIR/learning/master_interactions.json"` → `"$RECORDS_LOGS_DIR/learning-progress/master_interactions.json"`
  - [ ] 第1168行: `"$GROWTH_DIR/conversations/session_$session_id.json"` → `"$RECORDS_LOGS_DIR/conversations/session_$session_id.json"`
  - [ ] 第1242,1287,1926,1951,2010,2045行: 相关文件路径更新
- [ ] **更新钩子脚本群**:
  - [ ] **session-summary.sh**: `$CURSOR_GROWTH/logs/` → `$RECORDS_LOGS_DIR/system-logs/`
  - [ ] **rule-usage-tracker.sh**: `$CURSOR_GROWTH/logs/` → `$RECORDS_LOGS_DIR/system-logs/`
  - [ ] **command-log.sh**: `$CURSOR_GROWTH/logs/` → `$RECORDS_LOGS_DIR/system-logs/`
  - [ ] **security-audit.sh**: `$CURSOR_GROWTH/logs/` → `$RECORDS_LOGS_DIR/system-logs/`
  - [ ] **prompt-security.sh**: `$CURSOR_GROWTH/logs/` → `$RECORDS_LOGS_DIR/system-logs/`
  - [ ] **code-quality.sh**: `$CURSOR_GROWTH/logs/` → `$RECORDS_LOGS_DIR/system-logs/`
- [ ] **更新 performance-monitor.sh** - analytics/* → analytics-monitoring/* (已完成)
- [ ] **更新 self-learning-engine.sh** - ai/* → ai-learning/* (已完成)
- [ ] **检查其他脚本** - 验证是否有遗漏的路径引用
- [ ] **确保向后兼容性** - 保留旧变量作为别名
- [ ] **路径引用校验** - 检查所有脚本中的硬编码路径是否已更新
- [ ] **语法校验** - 确保所有脚本语法正确
- [ ] 测试脚本在新的目录结构下正常工作

### Phase 3: 目录重构 (1天)
- [ ] **删除现有的 .cursorGrowth 目录** (干净开始)
- [ ] 运行更新后的脚本生成新的6层级目录结构
- [ ] 验证新目录结构的完整性和正确性
- [ ] 确认所有脚本都能正常创建所需目录和文件
- [ ] 验证目录结构符合预定义的目标架构

### Phase 4: 测试验证 (2天)
- [ ] **严格验证流程**: 每次测试前删除 .cursorGrowth，从干净状态开始
- [ ] 运行所有脚本测试文件创建功能
- [ ] **功能完整性校验** - 验证所有脚本能正确创建文件和目录结构
- [ ] 验证路径配置正确性
- [ ] 检查缓存机制正常工作
- [ ] **性能基准校验** - 确保性能没有明显下降
- [ ] 确认所有功能正常运行
- [ ] **端到端校验** - 每次测试前删除 .cursorGrowth，从绝对干净状态验证

### Phase 4.5: 清理阶段 (0.5天)
- [ ] **扫描临时文件** - 查找所有测试过程中产生的临时脚本和文档
- [ ] **识别清理目标** - 区分AI Rules核心文件与测试临时文件
- [ ] **安全备份重要临时文件** - 备份可能有用的测试数据
- [ ] **清理测试脚本** - 删除所有测试用的临时脚本文件
- [ ] **清理测试文档** - 删除测试过程中产生的临时文档
- [ ] **清理缓存文件** - 删除测试期间产生的缓存和临时数据
- [ ] **验证清理完整性** - 确保只删除了无关文件
- [ ] **记录清理内容** - 记录删除了哪些文件以便追溯

### Phase 5: 文档更新 (1天)
- [ ] 更新所有相关文档
- [ ] 更新 README 文件
- [ ] 编写使用指南
- [ ] **文档完整性校验** - 确保所有文档与新结构一致
- [ ] 记录迁移后的最佳实践
- [ ] **最终校验和归档** - 保存完整的重构记录和校验和

## 🔄 文件迁移映射

### 核心数据层迁移
```
# 旧路径 → 新路径
data/perception/              → core-data/perception/
data/user_preferences/        → core-data/user-data/
data/project_metrics/         → core-data/project-data/
personal/                     → core-data/user-data/
perception/                   → core-data/perception/
user_data/                    → core-data/user-data/
project_data/                 → core-data/project-data/
```

### AI学习层迁移
```
ai/models/                    → ai-learning/models/
ai/training_data/             → ai-learning/training-data/
ai/metrics/                   → ai-learning/metrics/
ai/results/                   → ai-learning/results/
```

### 分析监控层迁移
```
analytics/data/               → analytics-monitoring/data/
analytics/cache/              → analytics-monitoring/cache/
monitoring/                   → analytics-monitoring/system-metrics/
```

### 存储缓存层迁移
```
cache/rules/                  → storage-cache/rules/
cache/templates/              → storage-cache/templates/
cache/analysis/               → analytics-monitoring/cache/
backups/                      → storage-cache/backups/
backups/config_backups/       → storage-cache/backups/config-backups/
```

### 记录日志层迁移
```
conversations/                → records-logs/conversations/
growth/                       → records-logs/growth-metrics/
learning/                     → records-logs/learning-progress/
logs/                         → records-logs/system-logs/
```

### 系统服务层迁移
```
config/                       → system-services/config/
debug/                        → system-services/debug/
compression/                  → system-services/compression/
sync/                         → system-services/sync/
integrations/                 → system-services/integrations/
mcps/                         → system-services/integrations/
```

## 🛠️ 技术实现方案

### 0. 脚本分析和规划 (Phase 1 核心)

#### 目标目录结构定义
```bash
# 6个顶级功能目录 - 这是我们的目标
.cursorGrowth/
├── core-data/           # 🎯 核心数据层
│   ├── perception/      # 环境感知数据
│   ├── user-data/       # 用户行为偏好数据
│   └── project-data/    # 项目指标统计数据
├── ai-learning/         # 🤖 AI学习层
│   ├── models/          # 训练好的AI模型
│   ├── training-data/   # AI训练数据集
│   ├── metrics/         # AI学习效果指标
│   └── results/         # AI生成的结果数据
├── analytics-monitoring/# 📊 分析监控层
│   ├── data/            # 分析统计结果数据
│   ├── cache/           # 分析过程缓存数据
│   └── system-metrics/  # 系统性能监控数据
├── storage-cache/       # 💾 存储缓存层
│   ├── rules/           # 规则引擎缓存数据
│   ├── templates/       # 模板缓存数据
│   └── backups/         # 系统数据备份
├── records-logs/        # 📝 记录日志层
│   ├── conversations/   # 用户对话历史记录
│   ├── growth-metrics/  # 系统生长指标记录
│   ├── learning-progress/# AI学习进度记录
│   └── system-logs/     # 系统运行日志
└── system-services/     # 🔧 系统服务层
    ├── config/          # 系统配置文件
    ├── debug/           # 调试诊断信息
    ├── compression/     # 数据压缩相关
    ├── sync/            # 数据同步状态
    └── integrations/    # 第三方服务集成
```

#### 脚本目录需求分析
```bash
# 分析所有脚本需要创建的目录和文件
analyze_script_requirements() {
    echo "🔍 分析脚本目录需求..."

    # 查找所有创建目录的命令
    echo "📁 目录创建分析:"
    grep -r "mkdir" .cursor/ --include="*.sh" | grep -v "^\s*#" | head -20

    # 查找所有写文件的命令
    echo "📄 文件写入分析:"
    grep -r "echo.*>" .cursor/ --include="*.sh" | grep -v "^\s*#" | head -20

    # 查找所有读文件的命令
    echo "📖 文件读取分析:"
    grep -r "cat\|<\|source" .cursor/ --include="*.sh" | grep -v "^\s*#" | head -20

    # 统计每个脚本的文件操作
    echo "📊 脚本文件操作统计:"
    find .cursor/ -name "*.sh" -exec bash -c '
        script="$1"
        mkdir_count=$(grep -c "mkdir" "$script")
        write_count=$(grep -c "echo.*>" "$script")
        read_count=$(grep -c "cat\|source\|<" "$script")
        echo "$(basename "$script"): mkdir=$mkdir_count, write=$write_count, read=$read_count"
    ' _ {} \;
}

# 识别需要修改的关键脚本
identify_scripts_to_modify() {
    echo "🎯 识别需要修改的脚本:"

    # 查找使用旧路径变量的脚本
    echo "使用旧路径变量的脚本:"
    grep -r "GROWTH_DIR\|AI_DIR\|ANALYTICS_DIR\|CACHE_DIR\|LOGS_DIR" .cursor/ --include="*.sh" | \
        cut -d: -f1 | sort | uniq

    # 查找硬编码路径的脚本
    echo "使用硬编码路径的脚本:"
    grep -r "\.cursorGrowth\|\$CURSOR_GROWTH" .cursor/ --include="*.sh" | \
        cut -d: -f1 | sort | uniq

    # 查找创建目录的脚本
    echo "创建目录的脚本:"
    grep -r "mkdir" .cursor/ --include="*.sh" | cut -d: -f1 | sort | uniq

    # 查找日志记录的脚本
    echo "记录日志的脚本:"
    grep -r "echo.*log\|log.*echo" .cursor/ --include="*.sh" | cut -d: -f1 | sort | uniq
}
```

#### 脚本修改优先级
```bash
# 按重要性和复杂度排序的修改顺序

# 高优先级 (影响全局):
# 1. path-config.sh - 路径变量定义
# 2. shared-functions.sh - 共享函数库

# 中优先级 (功能核心):
# 3. growth-recorder.sh - 目录创建
# 4. growth-manager.sh - 目录管理
# 5. cursor-master.sh - 多路径引用

# 低优先级 (专用功能):
# 6. growth_init.sh - 初始化配置
# 7. performance-monitor.sh - 监控数据
# 8. self-learning-engine.sh - AI学习
# 9. 钩子脚本 (session-summary.sh, etc.) - 日志记录
```

#### 验证框架设计
```bash
# 创建脚本功能验证框架
create_validation_framework() {
    cat > validate_script_functionality.sh << 'EOF'
#!/bin/bash
# 脚本功能验证框架

SCRIPT_TO_TEST="$1"

if [[ -z "$SCRIPT_TO_TEST" ]]; then
    echo "用法: $0 <脚本路径>"
    exit 1
fi

echo "🧪 验证脚本: $SCRIPT_TO_TEST"

# 1. 语法检查
echo "1. 语法检查..."
if bash -n "$SCRIPT_TO_TEST" 2>/dev/null; then
    echo "✅ 语法正确"
else
    echo "❌ 语法错误"
    exit 1
fi

# 2. 依赖检查
echo "2. 依赖检查..."
if grep -q "shared-functions.sh" "$SCRIPT_TO_TEST"; then
    if [[ ! -f ".cursor/core/shared-functions.sh" ]]; then
        echo "❌ 缺少依赖: shared-functions.sh"
        exit 1
    fi
    echo "✅ 依赖检查通过"
else
    echo "ℹ️  无特殊依赖"
fi

# 3. 项目识别检查
echo "3. 项目识别检查..."
if grep -q "validate_project_context" "$SCRIPT_TO_TEST"; then
    echo "✅ 包含项目上下文验证"
else
    echo "⚠️  缺少项目上下文验证"
fi

# 4. 路径变量检查
echo "4. 路径变量检查..."
old_vars=$(grep -c "GROWTH_DIR\|AI_DIR\|ANALYTICS_DIR\|CACHE_DIR\|LOGS_DIR" "$SCRIPT_TO_TEST")
new_vars=$(grep -c "CORE_DATA_DIR\|AI_LEARNING_DIR\|ANALYTICS_MONITORING_DIR\|STORAGE_CACHE_DIR\|RECORDS_LOGS_DIR\|SYSTEM_SERVICES_DIR" "$SCRIPT_TO_TEST")

if [[ $old_vars -gt 0 ]]; then
    echo "⚠️  发现 $old_vars 处旧路径变量引用"
fi
if [[ $new_vars -gt 0 ]]; then
    echo "✅ 发现 $new_vars 处新路径变量使用"
fi

echo "🎉 脚本验证完成"
EOF

    chmod +x validate_script_functionality.sh
    echo "✅ 验证框架已创建: validate_script_functionality.sh"
}
```

### 1. 共享函数库设计 (降低维护成本)

#### 核心函数抽象原则
- **单一职责**: 每个函数只负责一个功能
- **可重用性**: 通用函数可以在所有脚本中使用
- **统一维护**: 修改一处，所有使用的地方都更新
- **项目隔离**: 所有函数都内置项目隔离验证

#### 共享函数库结构
```bash
# 创建共享函数库文件
# .cursor/core/shared-functions.sh

#!/bin/bash
# ========================================
# Cursor AI Rules - 共享函数库
# 所有共同函数的抽象，降低维护成本
# ========================================

# ------------------------------------------------------------------------------
# 项目识别相关函数 (所有脚本都需要)
# 用于识别脚本属于哪个项目，避免环境变量污染
# ------------------------------------------------------------------------------

# 生成项目唯一标识符
generate_project_identifier() {
    local project_path
    project_path=$(get_project_root_path)

    local project_hash
    project_hash=$(echo "$project_path" | md5sum | cut -d' ' -f1 | cut -c1-16)

    PROJECT_IDENTIFIER="proj_${project_hash}"
    export PROJECT_IDENTIFIER
    echo "$PROJECT_IDENTIFIER" > ".cursor/project_id"
}

# 获取项目根目录路径
get_project_root_path() {
    local current_path="$PWD"
    local max_depth=10
    local depth=0

    while [[ $depth -lt $max_depth ]]; do
        if [[ -d "$current_path/.cursor" ]]; then
            echo "$current_path"
            return 0
        fi
        current_path=$(dirname "$current_path")
        ((depth++))
    done

    echo "ERROR: 无法找到项目根目录 (.cursor 目录)" >&2
    return 1
}

# 验证项目上下文 (强制函数)
validate_project_context() {
    local current_project_id
    local stored_project_id

    current_project_id=$(generate_project_identifier 2>/dev/null)

    if [[ -f ".cursor/project_id" ]]; then
        stored_project_id=$(cat ".cursor/project_id")
    else
        echo "$current_project_id" > ".cursor/project_id"
        stored_project_id="$current_project_id"
    fi

    if [[ "$current_project_id" != "$stored_project_id" ]]; then
        echo "❌ 项目上下文验证失败!" >&2
        echo "  当前项目ID: $current_project_id" >&2
        echo "  存储项目ID: $stored_project_id" >&2
        echo "  可能原因: 脚本在错误的目录中运行" >&2
        return 1
    fi

    echo "✅ 项目上下文验证通过: $PROJECT_IDENTIFIER"
    return 0
}

# ------------------------------------------------------------------------------
# 路径操作相关函数 (所有脚本都需要)
# 提供统一的目录创建和管理功能
# ------------------------------------------------------------------------------

# 安全文件操作 (统一接口)
safe_file_operation() {
    local operation="$1"
    local target_path="$2"

    case "$operation" in
        "read")
            [[ -f "$target_path" ]] && cat "$target_path" ;;
        "write")
            local content="$3"
            echo "$content" > "$target_path" ;;
        "append")
            local content="$3"
            echo "$content" >> "$target_path" ;;
        "mkdir")
            mkdir -p "$target_path" ;;
        "rm")
            rm -f "$target_path" ;;
        "exists")
            [[ -e "$target_path" ]] ;;
        *)
            echo "❌ 不支持的操作: $operation" >&2
            return 1 ;;
    esac
}

# ------------------------------------------------------------------------------
# 日志记录相关函数 (日志脚本需要)
# ------------------------------------------------------------------------------

# 统一日志记录函数
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${3:-$SYSTEM_LOGS_DIR/app.log}"

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local log_entry="[$timestamp] [$level] $message"

    # 控制台输出
    case "$level" in
        "ERROR") echo "❌ $message" >&2 ;;
        "WARN")  echo "⚠️  $message" >&2 ;;
        "INFO")  echo "ℹ️  $message" ;;
        "DEBUG") echo "🔍 $message" ;;
        *)       echo "$message" ;;
    esac

    # 文件记录
    safe_file_operation "append" "$log_file" "$log_entry"
}

# ------------------------------------------------------------------------------
# 配置管理相关函数 (配置脚本需要)
# ------------------------------------------------------------------------------

# 安全读取配置文件
safe_read_config() {
    local config_file="$1"
    local key="$2"
    local default_value="$3"

    if [[ ! -f "$config_file" ]]; then
        echo "$default_value"
        return 1
    fi

    local value
    value=$(grep "^${key}=" "$config_file" | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//')
    echo "${value:-$default_value}"
}

# 安全写入配置文件
safe_write_config() {
    local config_file="$1"
    local key="$2"
    local value="$3"

    # 创建配置目录
    local config_dir
    config_dir=$(dirname "$config_file")
    safe_file_operation "mkdir" "$config_dir"

    # 读取现有配置
    local temp_config=""
    if [[ -f "$config_file" ]]; then
        temp_config=$(cat "$config_file")
    fi

    # 更新或添加配置项
    if echo "$temp_config" | grep -q "^${key}="; then
        # 更新现有项
        temp_config=$(echo "$temp_config" | sed "s|^${key}=.*|${key}=\"${value}\"|")
    else
        # 添加新项
        temp_config="${temp_config}
${key}=\"${value}\""
    fi

    # 写入配置
    safe_file_operation "write" "$config_file" "$temp_config"
}

# ------------------------------------------------------------------------------
# 目录管理相关函数 (目录脚本需要)
# ------------------------------------------------------------------------------

# 统一目录创建函数
ensure_directory_structure() {
    local dirs_to_create=(
        "$CORE_DATA_DIR"
        "$AI_LEARNING_DIR"
        "$ANALYTICS_MONITORING_DIR"
        "$STORAGE_CACHE_DIR"
        "$RECORDS_LOGS_DIR"
        "$SYSTEM_SERVICES_DIR"
        "$PERCEPTION_DIR"
        "$USER_DATA_DIR"
        "$PROJECT_DATA_DIR"  # 项目特定的数据目录
        "$AI_MODELS_DIR"
        "$AI_TRAINING_DATA_DIR"
        "$AI_METRICS_DIR"
        "$AI_RESULTS_DIR"
        "$ANALYTICS_DATA_DIR"
        "$ANALYTICS_CACHE_DIR"
        "$MONITORING_DIR"
        "$CACHE_RULES_DIR"
        "$CACHE_TEMPLATES_DIR"
        "$BACKUPS_DIR"
        "$CONVERSATIONS_DIR"
        "$GROWTH_METRICS_DIR"
        "$LEARNING_PROGRESS_DIR"
        "$SYSTEM_LOGS_DIR"
        "$CONFIG_DIR"
        "$DEBUG_DIR"
        "$COMPRESSION_DIR"
        "$SYNC_DIR"
        "$INTEGRATIONS_DIR"
    )

    for dir in "${dirs_to_create[@]}"; do
        safe_file_operation "mkdir" "$dir"
    done

    log_message "INFO" "项目目录结构创建完成"
}

# ------------------------------------------------------------------------------
# 错误处理相关函数 (所有脚本都需要)
# ------------------------------------------------------------------------------

# 统一错误处理函数
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local script_name="${3:-$(basename "$0")}"

    log_message "ERROR" "$script_name: $error_message"

    # 可以在这里添加错误恢复逻辑
    # 比如发送通知、清理临时文件等

    exit "$error_code"
}

# 统一清理函数
cleanup_on_exit() {
    local exit_code="$1"

    # 清理临时文件
    if [[ -n "$TEMP_FILES" ]]; then
        for temp_file in $TEMP_FILES; do
            [[ -f "$temp_file" ]] && rm -f "$temp_file"
        done
    fi

    # 记录退出状态
    if [[ $exit_code -eq 0 ]]; then
        log_message "INFO" "脚本执行成功完成"
    else
        log_message "ERROR" "脚本执行失败 (退出码: $exit_code)"
    fi
}

# 设置错误处理
setup_error_handling() {
    # 捕获错误
    set -e

    # 设置退出时清理
    trap 'cleanup_on_exit $?' EXIT

    # 初始化临时文件列表
    TEMP_FILES=""
}

# ------------------------------------------------------------------------------
# 校验和相关函数 (校验脚本需要)
# ------------------------------------------------------------------------------

# 计算文件校验和
calculate_checksum() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo ""
        return 1
    fi

    md5sum "$file_path" | cut -d' ' -f1
}

# 验证文件校验和
verify_checksum() {
    local file_path="$1"
    local expected_checksum="$2"

    local actual_checksum
    actual_checksum=$(calculate_checksum "$file_path")

    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo "❌ 校验和验证失败: $file_path"
        echo "  期望: $expected_checksum"
        echo "  实际: $actual_checksum"
        return 1
    fi

    return 0
}

echo "✅ 共享函数库加载完成"
```

#### 脚本使用共享函数库
```bash
# 所有脚本都应该这样使用共享函数:
#!/bin/bash

# 加载共享函数库 (所有共同函数)
source "$SCRIPT_DIR/shared-functions.sh"

# 项目隔离验证 (使用共享函数)
validate_project_context || handle_error 1 "项目上下文验证失败"

# 使用共享的日志函数
log_message "INFO" "脚本开始执行"

# 使用共享的文件操作函数
safe_file_operation "write" "$log_file" "开始处理..."

# 使用共享的配置管理函数
config_value=$(safe_read_config "$config_file" "setting_key" "default_value")

echo "🎉 使用共享函数库，维护成本大幅降低！"
```

### 1. 多项目隔离机制 (核心安全)

#### 项目隔离实现说明

**注意**: 具体的函数实现已在"共享函数库设计"章节中定义，这里不再重复。

项目隔离的核心机制：
1. **项目标识生成**: 使用 `generate_project_identifier()` 函数
2. **项目上下文验证**: 使用 `validate_project_context()` 函数
3. **路径所有权检查**: 使用 `validate_path_ownership()` 函数
4. **安全文件操作**: 使用 `safe_file_operation()` 函数

所有这些函数都已抽象到共享函数库中，具体实现请参考"0. 共享函数库设计"章节。

#### 项目识别的核心机制

**项目识别通过共享函数库实现**：

1. **项目标识生成**: `generate_project_identifier()` - 基于项目路径生成唯一ID，用于识别项目
2. **上下文验证**: `validate_project_context()` - 验证脚本在正确的项目目录中运行
3. **环境隔离**: 避免全局环境变量污染，确保脚本行为与项目相关

**架构说明**：
- 每个项目都有独立的 `.cursor` 和 `.cursorGrowth` 目录
- `.cursorGrowth` 内部不需要项目区分，每个项目使用自己的目录
- 项目识别主要用于避免环境变量污染和脚本运行上下文验证

具体实现请参考"0. 共享函数库设计"章节。

### 2. 统一路径管理机制

#### 核心原则
- **单一源头**: 所有路径变量在 `path-config.sh` 中统一定义
- **层次化管理**: 按功能层级组织路径变量
- **自动初始化**: 脚本加载时自动创建所需目录结构
- **向后兼容**: 保留旧变量名作为新变量的别名

#### path-config.sh 中的统一管理
```bash
# ============================================================================
# 🎯 统一路径变量定义 (在 path-config.sh 中集中管理)
# ============================================================================

# 6个顶级功能目录 (每个项目独立)
# 注意: 每个项目都有自己的 .cursorGrowth 目录，无需内部项目区分
# 路径直接基于项目根目录，不需要 PROJECT_IDENTIFIER 前缀
export CORE_DATA_DIR="$CURSOR_GROWTH/core-data"
export AI_LEARNING_DIR="$CURSOR_GROWTH/ai-learning"
export ANALYTICS_MONITORING_DIR="$CURSOR_GROWTH/analytics-monitoring"
export STORAGE_CACHE_DIR="$CURSOR_GROWTH/storage-cache"
export RECORDS_LOGS_DIR="$CURSOR_GROWTH/records-logs"
export SYSTEM_SERVICES_DIR="$CURSOR_GROWTH/system-services"

# 子目录变量 (按功能层级组织)
export PERCEPTION_DIR="$CORE_DATA_DIR/perception"
export USER_DATA_DIR="$CORE_DATA_DIR/user-data"
export PROJECT_DATA_DIR="$CORE_DATA_DIR/project-data"

export AI_MODELS_DIR="$AI_LEARNING_DIR/models"
export AI_TRAINING_DATA_DIR="$AI_LEARNING_DIR/training-data"
export AI_METRICS_DIR="$AI_LEARNING_DIR/metrics"
export AI_RESULTS_DIR="$AI_LEARNING_DIR/results"

export ANALYTICS_DATA_DIR="$ANALYTICS_MONITORING_DIR/data"
export ANALYTICS_CACHE_DIR="$ANALYTICS_MONITORING_DIR/cache"
export MONITORING_DIR="$ANALYTICS_MONITORING_DIR/system-metrics"

export CACHE_RULES_DIR="$STORAGE_CACHE_DIR/rules"
export CACHE_TEMPLATES_DIR="$STORAGE_CACHE_DIR/templates"
export BACKUPS_DIR="$STORAGE_CACHE_DIR/backups"

export CONVERSATIONS_DIR="$RECORDS_LOGS_DIR/conversations"
export GROWTH_METRICS_DIR="$RECORDS_LOGS_DIR/growth-metrics"
export LEARNING_PROGRESS_DIR="$RECORDS_LOGS_DIR/learning-progress"
export SYSTEM_LOGS_DIR="$RECORDS_LOGS_DIR/system-logs"

export CONFIG_DIR="$SYSTEM_SERVICES_DIR/config"
export DEBUG_DIR="$SYSTEM_SERVICES_DIR/debug"
export COMPRESSION_DIR="$SYSTEM_SERVICES_DIR/compression"
export SYNC_DIR="$SYSTEM_SERVICES_DIR/sync"
export INTEGRATIONS_DIR="$SYSTEM_SERVICES_DIR/integrations"

# ============================================================================
# 🔄 向后兼容性变量 (自动映射到新变量)
# ============================================================================
export AI_DIR="$AI_LEARNING_DIR"                    # 兼容旧脚本
export ANALYTICS_DIR="$ANALYTICS_MONITORING_DIR"   # 兼容旧脚本
export CACHE_DIR="$STORAGE_CACHE_DIR"              # 兼容旧脚本
export LOGS_DIR="$SYSTEM_LOGS_DIR"                 # 兼容旧脚本
export LEARNING_DIR="$LEARNING_PROGRESS_DIR"       # 兼容旧脚本
# ... 其他兼容性映射

# ============================================================================
# 🏗️ 统一目录初始化 (自动执行)
# ============================================================================
init_unified_directory_structure() {
    # 创建6个顶级功能目录
    mkdir -p "$CORE_DATA_DIR" "$AI_LEARNING_DIR" "$ANALYTICS_MONITORING_DIR" \
             "$STORAGE_CACHE_DIR" "$RECORDS_LOGS_DIR" "$SYSTEM_SERVICES_DIR"

    # 创建所有子目录
    mkdir -p "$PERCEPTION_DIR" "$USER_DATA_DIR" "$PROJECT_DATA_DIR" \
             "$AI_MODELS_DIR" "$AI_TRAINING_DATA_DIR" "$AI_METRICS_DIR" "$AI_RESULTS_DIR" \
             "$ANALYTICS_DATA_DIR" "$ANALYTICS_CACHE_DIR" "$MONITORING_DIR" \
             "$CACHE_RULES_DIR" "$CACHE_TEMPLATES_DIR" "$BACKUPS_DIR" \
             "$CONVERSATIONS_DIR" "$GROWTH_METRICS_DIR" "$LEARNING_PROGRESS_DIR" "$SYSTEM_LOGS_DIR" \
             "$CONFIG_DIR" "$DEBUG_DIR" "$COMPRESSION_DIR" "$SYNC_DIR" "$INTEGRATIONS_DIR"
}

# 在 path-config.sh 加载时自动初始化
init_unified_directory_structure
```

#### 脚本使用统一路径变量
```bash
# 所有脚本都使用统一的路径变量 (来自 path-config.sh)
source "$SCRIPT_DIR/path-config.sh"

# 使用新的统一变量
metrics_file="$AI_METRICS_DIR/training_metrics.json"
log_file="$SYSTEM_LOGS_DIR/app.log"
config_file="$CONFIG_DIR/app_settings.json"

# 旧变量仍然可用 (向后兼容)
old_metrics_file="$AI_DIR/metrics/training_metrics.json"  # 仍然工作
old_log_file="$LOGS_DIR/app.log"                         # 仍然工作
```

### 2. 脚本路径更新示例 (使用统一变量)

### 🔒 脚本安全修改指南

### ⚠️ 重要安全警告
**禁止使用 sed 或其他自动化替换工具进行全局替换！**

#### 为什么不能使用 sed
- **误匹配风险**: `$GROWTH_DIR/learning` 可能匹配到注释或字符串中不相关的部分
- **上下文破坏**: 替换可能破坏代码逻辑或配置文件格式
- **不可逆转**: 一旦替换错误，很难准确恢复
- **测试不足**: sed 替换通常不会进行语法或逻辑验证

#### 安全修改原则
1. **先备份**: 修改前必须创建完整备份
2. **逐个查找**: 使用 grep 定位确切位置
3. **手动验证**: 每个替换都要人工检查上下文
4. **测试验证**: 修改后立即测试脚本功能
5. **逐步推进**: 不要一次性修改太多文件

### 脚本修改模板 (使用共享函数库 - 降低维护成本)
```bash
#!/bin/bash
# 脚本执行必须是项目独立的！
# 使用共享函数库降低维护成本

# 脚本开头 (所有脚本都需要添加 - 加载共享函数库)
source "$SCRIPT_DIR/shared-functions.sh"  # 加载所有共享函数

# 🛡️ 项目隔离验证 (使用共享函数 - 统一维护)
validate_project_context || handle_error 1 "项目上下文验证失败"

# ✅ 项目验证通过 - 脚本现在运行在隔离的项目环境中
log_message "INFO" "项目隔离验证通过: $PROJECT_IDENTIFIER"

# 现在可以使用所有共享函数:
# - 项目识别: validate_project_context, generate_project_identifier
# - 文件操作: safe_file_operation
# - 日志记录: log_message
# - 配置管理: safe_read_config, safe_write_config
# - 错误处理: handle_error, setup_error_handling
# - 校验和: calculate_checksum, verify_checksum
# - 目录管理: ensure_directory_structure

# 示例使用共享函数:
log_message "INFO" "脚本开始执行"
safe_file_operation "mkdir" "$SYSTEM_LOGS_DIR"
config_value=$(safe_read_config "$CONFIG_DIR/app.conf" "debug_mode" "false")

echo "🎉 使用共享函数库，代码更简洁，维护成本更低！"
```

#### growth-recorder.sh 安全修改步骤

**修改前准备 (项目隔离安全检查):**
```bash
# 备份原始文件
cp growth-recorder.sh growth-recorder.sh.backup

# 查找所有需要修改的位置
grep -n "GROWTH_DIR" growth-recorder.sh

# 🛡️ 检查脚本是否需要使用共享函数库
echo "分析脚本的函数抽象需求:"
if ! grep -q "validate_project_context" growth-recorder.sh; then
    echo "⚠️  脚本缺少项目隔离验证 - 需要使用共享函数库"
fi

if grep -q "mkdir.*-p\|echo.*>.*\|cat.*<" growth-recorder.sh; then
    echo "🔄 发现文件操作重复代码 - 应该使用 safe_file_operation"
fi

if grep -q "echo.*\[.*\].*" growth-recorder.sh; then
    echo "📝 发现日志记录代码 - 应该使用 log_message"
fi

# 🎯 重构建议: 使用共享函数库替换所有重复代码
```

**第41行修改 (使用共享函数 - 目录创建):**
```bash
# 查找确切位置
sed -n '35,45p' growth-recorder.sh  # 查看上下文

# 使用共享函数重构:
# 旧: mkdir -p "$GROWTH_DIR/learning" "$GROWTH_DIR/conversations" "$GROWTH_DIR/growth"
# 新: safe_file_operation "mkdir" "$LEARNING_PROGRESS_DIR"
#     safe_file_operation "mkdir" "$CONVERSATIONS_DIR"
#     safe_file_operation "mkdir" "$GROWTH_METRICS_DIR"

# 或者使用统一的目录创建函数:
# ensure_directory_structure  # 创建所有需要的目录

# 验证修改
sed -n '35,45p' growth-recorder.sh
```

**第89行修改 (文件路径):**
```bash
# 查找确切位置
sed -n '85,95p' growth-recorder.sh  # 查看上下文

# 手动编辑第89行:
# 旧: "$GROWTH_DIR/conversations/initial_conversation.json"
# 新: "$CONVERSATIONS_DIR/initial_conversation.json"
```

**第112行修改 (文件路径):**
```bash
# 查找确切位置
sed -n '108,118p' growth-recorder.sh  # 查看上下文

# 手动编辑第112行:
# 旧: "$GROWTH_DIR/growth/metrics.json"
# 新: "$GROWTH_METRICS_DIR/metrics.json"
```

**修改后验证 (项目隔离 + 目录生成能力检查):**
```bash
# 🧹 首先清理环境进行严格测试
echo "🧹 清理 .cursorGrowth 进行严格测试..."
rm -rf .cursorGrowth

# 检查是否还有未替换的旧路径
grep "GROWTH_DIR" growth-recorder.sh

# 语法检查
bash -n growth-recorder.sh

# 🧪 功能测试: 验证脚本能从干净状态生成目录
echo "🧪 测试脚本目录生成能力..."
if [[ -f "growth-recorder.sh" ]]; then
    bash growth-recorder.sh
    if [[ -d ".cursorGrowth" ]]; then
        echo "✅ growth-recorder.sh 成功生成目录结构"
        ls -la .cursorGrowth/
    else
        echo "❌ growth-recorder.sh 未能生成目录结构"
        exit 1
    fi
else
    echo "❌ growth-recorder.sh 文件不存在"
    exit 1
fi

# 🛡️ 项目识别验证
echo "验证项目识别完整性:"

# 1. 检查是否包含项目上下文验证
if grep -q "validate_project_context" growth-recorder.sh; then
    echo "✅ 项目上下文验证: 已添加"
else
    echo "❌ 项目上下文验证: 缺失"
fi

# 2. 检查是否使用统一的路径变量
if grep -q "\$SYSTEM_LOGS_DIR\|\$CONVERSATIONS_DIR\|\$GROWTH_METRICS_DIR" growth-recorder.sh; then
    echo "✅ 统一路径变量: 已使用"
else
    echo "❌ 统一路径变量: 未使用"
fi

# 3. 检查是否还有硬编码路径
if grep -q "\$CURSOR_GROWTH" growth-recorder.sh; then
    echo "⚠️  发现硬编码路径，请确认是否安全"
fi

echo "项目隔离验证完成"
```

#### 钩子脚本安全修改步骤

**批量处理前的准备 (项目隔离安全检查):**
```bash
# 备份所有钩子脚本
mkdir -p hooks_backup
cp session-summary.sh rule-usage-tracker.sh command-log.sh security-audit.sh prompt-security.sh code-quality.sh hooks_backup/

# 统计需要修改的文件
HOOK_SCRIPTS="session-summary.sh rule-usage-tracker.sh command-log.sh security-audit.sh prompt-security.sh code-quality.sh"

echo "🔍 检查钩子脚本的项目隔离状态:"
for script in $HOOK_SCRIPTS; do
    echo "=== $script ==="
    if grep -q "validate_project_context" "$script"; then
        echo "✅ 项目隔离: 已验证"
    else
        echo "❌ 项目隔离: 缺失验证"
    fi
    grep -n "CURSOR_GROWTH/logs" "$script" || echo "路径引用: 无需修改"
done

echo ""
echo "🛡️ 重要提醒: 所有钩子脚本都必须是项目独立的！"
```

**逐个脚本修改示例 (session-summary.sh - 使用共享函数):**
```bash
# 首先重构为使用共享函数库
# 添加共享函数库引用
if ! grep -q "shared-functions.sh" session-summary.sh; then
    sed -i '1a source "$SCRIPT_DIR/shared-functions.sh"' session-summary.sh
fi

# 添加项目隔离验证
if ! grep -q "validate_project_context" session-summary.sh; then
    sed -i '/shared-functions.sh/a validate_project_context || handle_error 1 "项目上下文验证失败"' session-summary.sh
fi

# 查找所有日志操作
grep -n "CURSOR_GROWTH/logs\|logs/\|echo.*>.*log" session-summary.sh

# 使用共享日志函数重构 (假设第25行有日志写入)
# 旧: echo "[$(date)] $message" >> $CURSOR_GROWTH/logs/rule-usage.log
# 新: log_message "INFO" "$message" "$SYSTEM_LOGS_DIR/rule-usage.log"

# 使用共享配置函数 (如果有配置读取)
# 旧: config_value=$(grep "key=" config.file | cut -d'=' -f2)
# 新: config_value=$(safe_read_config "$CONFIG_DIR/app.conf" "key" "default")

# 验证重构结果
grep -n "log_message\|safe_read_config\|validate_project_context" session-summary.sh
```

**批量验证所有钩子脚本:**
```bash
for script in $HOOK_SCRIPTS; do
    echo "验证 $script:"
    # 检查语法
    bash -n "$script" && echo "✅ 语法正确" || echo "❌ 语法错误"

    # 检查是否还有旧路径
    if grep -q "CURSOR_GROWTH/logs" "$script"; then
        echo "⚠️  还有未替换的旧路径"
        grep -n "CURSOR_GROWTH/logs" "$script"
    else
        echo "✅ 路径更新完成"
    fi
    echo ""
done
```

#### cursor-master.sh 路径更新
```bash
# 旧路径
local learning_file="$GROWTH_DIR/learning/master_interactions.json"
local conversation_file="$GROWTH_DIR/conversations/session_$session_id.json"
local metrics_file="$GROWTH_DIR/growth/metrics.json"

# 新路径 (使用统一变量)
local learning_file="$LEARNING_PROGRESS_DIR/master_interactions.json"
local conversation_file="$CONVERSATIONS_DIR/session_$session_id.json"
local metrics_file="$GROWTH_METRICS_DIR/metrics.json"
```

### 3. 统一路径变量引用表

#### 🎯 核心数据层变量
| 变量名             | 完整路径                                | 用途说明         |
| ------------------ | --------------------------------------- | ---------------- |
| `PERCEPTION_DIR`   | `$CURSOR_GROWTH/core-data/perception`   | 环境感知数据存储 |
| `USER_DATA_DIR`    | `$CURSOR_GROWTH/core-data/user-data`    | 用户行为偏好数据 |
| `PROJECT_DATA_DIR` | `$CURSOR_GROWTH/core-data/project-data` | 项目指标统计数据 |

#### 🤖 AI学习层变量
| 变量名                 | 完整路径                                   | 用途说明         |
| ---------------------- | ------------------------------------------ | ---------------- |
| `AI_LEARNING_DIR`      | `$CURSOR_GROWTH/ai-learning`               | AI学习功能根目录 |
| `AI_MODELS_DIR`        | `$CURSOR_GROWTH/ai-learning/models`        | 训练好的AI模型   |
| `AI_TRAINING_DATA_DIR` | `$CURSOR_GROWTH/ai-learning/training-data` | AI训练数据集     |
| `AI_METRICS_DIR`       | `$CURSOR_GROWTH/ai-learning/metrics`       | AI学习效果指标   |
| `AI_RESULTS_DIR`       | `$CURSOR_GROWTH/ai-learning/results`       | AI生成的结果数据 |

#### 📊 分析监控层变量
| 变量名                     | 完整路径                                             | 用途说明           |
| -------------------------- | ---------------------------------------------------- | ------------------ |
| `ANALYTICS_MONITORING_DIR` | `$CURSOR_GROWTH/analytics-monitoring`                | 分析监控功能根目录 |
| `ANALYTICS_DATA_DIR`       | `$CURSOR_GROWTH/analytics-monitoring/data`           | 分析统计结果数据   |
| `ANALYTICS_CACHE_DIR`      | `$CURSOR_GROWTH/analytics-monitoring/cache`          | 分析过程缓存数据   |
| `MONITORING_DIR`           | `$CURSOR_GROWTH/analytics-monitoring/system-metrics` | 系统性能监控数据   |

#### 💾 存储缓存层变量
| 变量名                | 完整路径                                 | 用途说明           |
| --------------------- | ---------------------------------------- | ------------------ |
| `STORAGE_CACHE_DIR`   | `$CURSOR_GROWTH/storage-cache`           | 存储缓存功能根目录 |
| `CACHE_RULES_DIR`     | `$CURSOR_GROWTH/storage-cache/rules`     | 规则引擎缓存数据   |
| `CACHE_TEMPLATES_DIR` | `$CURSOR_GROWTH/storage-cache/templates` | 模板缓存数据       |
| `BACKUPS_DIR`         | `$CURSOR_GROWTH/storage-cache/backups`   | 系统数据备份       |

#### 📝 记录日志层变量
| 变量名                  | 完整路径                                        | 用途说明           |
| ----------------------- | ----------------------------------------------- | ------------------ |
| `RECORDS_LOGS_DIR`      | `$CURSOR_GROWTH/records-logs`                   | 记录日志功能根目录 |
| `CONVERSATIONS_DIR`     | `$CURSOR_GROWTH/records-logs/conversations`     | 用户对话历史记录   |
| `GROWTH_METRICS_DIR`    | `$CURSOR_GROWTH/records-logs/growth-metrics`    | 系统生长指标记录   |
| `LEARNING_PROGRESS_DIR` | `$CURSOR_GROWTH/records-logs/learning-progress` | AI学习进度记录     |
| `SYSTEM_LOGS_DIR`       | `$CURSOR_GROWTH/records-logs/system-logs`       | 系统运行日志       |

#### 🔧 系统服务层变量
| 变量名                | 完整路径                                      | 用途说明           |
| --------------------- | --------------------------------------------- | ------------------ |
| `SYSTEM_SERVICES_DIR` | `$CURSOR_GROWTH/system-services`              | 系统服务功能根目录 |
| `CONFIG_DIR`          | `$CURSOR_GROWTH/system-services/config`       | 系统配置文件       |
| `DEBUG_DIR`           | `$CURSOR_GROWTH/system-services/debug`        | 调试诊断信息       |
| `COMPRESSION_DIR`     | `$CURSOR_GROWTH/system-services/compression`  | 数据压缩相关       |
| `SYNC_DIR`            | `$CURSOR_GROWTH/system-services/sync`         | 数据同步状态       |
| `INTEGRATIONS_DIR`    | `$CURSOR_GROWTH/system-services/integrations` | 第三方服务集成     |

#### 🔄 向后兼容变量映射
| 旧变量名        | 新变量名                   | 兼容性说明       |
| --------------- | -------------------------- | ---------------- |
| `AI_DIR`        | `AI_LEARNING_DIR`          | AI功能目录别名   |
| `ANALYTICS_DIR` | `ANALYTICS_MONITORING_DIR` | 分析功能目录别名 |
| `CACHE_DIR`     | `STORAGE_CACHE_DIR`        | 缓存功能目录别名 |
| `LOGS_DIR`      | `SYSTEM_LOGS_DIR`          | 日志功能目录别名 |
| `LEARNING_DIR`  | `LEARNING_PROGRESS_DIR`    | 学习功能目录别名 |
| `GROWTH_DIR`    | `GROWTH_METRICS_DIR`       | 生长指标目录别名 |

#### 📋 脚本使用共享函数库示例 (函数抽象 - 降低维护成本)
```bash
#!/bin/bash
# 这个脚本使用共享函数库 - 代码简洁，维护成本低
# 所有共同函数已抽象，修改一处，全局生效

# 所有脚本都应该使用共享函数库
source "$SCRIPT_DIR/shared-functions.sh"

# 🛡️ 项目上下文验证 (确保在正确的项目中运行)
validate_project_context || handle_error 1 "项目上下文验证失败"

# ✅ 项目验证通过 - 使用统一的日志记录
log_message "INFO" "脚本开始执行: $PROJECT_IDENTIFIER"

# 使用共享函数进行文件操作 (自动项目隔离):
safe_file_operation "mkdir" "$SYSTEM_LOGS_DIR"
safe_file_operation "write" "$SYSTEM_LOGS_DIR/app.log" "应用启动日志"

# 使用共享函数进行配置管理:
debug_mode=$(safe_read_config "$CONFIG_DIR/app.conf" "debug_mode" "false")
if [[ "$debug_mode" == "true" ]]; then
    log_message "DEBUG" "调试模式已启用"
fi

# 使用共享函数进行校验和验证:
if [[ -f "$AI_MODELS_DIR/model.bin" ]]; then
    checksum=$(calculate_checksum "$AI_MODELS_DIR/model.bin")
    log_message "INFO" "模型文件校验和: $checksum"
fi

# 使用共享的错误处理:
trap 'cleanup_on_exit $?' EXIT

# 所有脚本都使用相同的函数接口，维护成本大幅降低！
log_message "INFO" "脚本执行完成"
```

### 🔍 修改后验证流程

#### 🧹 严格验证要求 (每次验证前清理)
```bash
# 🛑 重要: 每次验证脚本修改后，都必须执行以下步骤

# 步骤1: 完全清理测试环境
echo "🧹 清理测试环境..."
rm -rf .cursorGrowth
echo "✅ 已删除 .cursorGrowth 目录"

# 步骤2: 验证清理结果
if [[ -d ".cursorGrowth" ]]; then
    echo "❌ 清理失败，.cursorGrowth 仍然存在"
    exit 1
else
    echo "✅ 清理成功，环境干净"
fi

# 步骤3: 运行脚本生成目录结构
echo "🏗️  测试脚本目录生成能力..."
# 运行相关脚本...

# 步骤4: 验证生成结果
echo "🔍 验证目录结构生成..."
if [[ -d ".cursorGrowth" ]]; then
    echo "✅ 目录结构生成成功"
    tree .cursorGrowth || ls -la .cursorGrowth
else
    echo "❌ 目录结构生成失败"
    exit 1
fi
```

#### 语法验证
```bash
# 检查脚本语法是否正确
bash -n script_name.sh

# 对所有修改的脚本批量检查
MODIFIED_SCRIPTS="path-config.sh growth-recorder.sh growth-manager.sh growth_init.sh cursor-master.sh session-summary.sh rule-usage-tracker.sh command-log.sh security-audit.sh prompt-security.sh code-quality.sh performance-monitor.sh self-learning-engine.sh"

for script in $MODIFIED_SCRIPTS; do
    if [[ -f "$script" ]]; then
        if bash -n "$script" 2>/dev/null; then
            echo "✅ $script 语法正确"
        else
            echo "❌ $script 语法错误"
        fi
    else
        echo "⚠️  $script 文件不存在"
    fi
done
```

#### 路径引用验证
```bash
# 检查是否还有未替换的旧路径
check_old_paths() {
    local script="$1"
    local old_paths_found=0

    echo "检查 $script 的路径引用:"

    # 检查旧的硬编码路径
    if grep -q "CURSOR_GROWTH/logs\|CURSOR_GROWTH/learning\|CURSOR_GROWTH/conversations\|CURSOR_GROWTH/growth" "$script"; then
        echo "  ❌ 发现未替换的硬编码路径:"
        grep -n "CURSOR_GROWTH/\(logs\|learning\|conversations\|growth\)" "$script"
        ((old_paths_found++))
    fi

    # 检查旧的变量使用 (这些应该保留用于兼容性)
    if grep -q "\$GROWTH_DIR\|\$AI_DIR\|\$ANALYTICS_DIR\|\$CACHE_DIR\|\$LOGS_DIR" "$script"; then
        echo "  ℹ️  发现旧变量引用 (检查是否为兼容性代码):"
        grep -n "\$GROWTH_DIR\|\$AI_DIR\|\$ANALYTICS_DIR\|\$CACHE_DIR\|\$LOGS_DIR" "$script"
    fi

    # 检查新的统一变量使用
    local new_vars_found=$(grep -c "\$CORE_DATA_DIR\|\$AI_LEARNING_DIR\|\$ANALYTICS_MONITORING_DIR\|\$STORAGE_CACHE_DIR\|\$RECORDS_LOGS_DIR\|\$SYSTEM_SERVICES_DIR\|\$SYSTEM_LOGS_DIR\|\$LEARNING_PROGRESS_DIR\|\$CONVERSATIONS_DIR\|\$GROWTH_METRICS_DIR" "$script")

    if [[ $new_vars_found -gt 0 ]]; then
        echo "  ✅ 发现 $new_vars_found 处新变量使用"
    else
        echo "  ⚠️  未发现新变量使用"
    fi

    return $old_paths_found
}

# 检查所有脚本
for script in $MODIFIED_SCRIPTS; do
    if [[ -f "$script" ]]; then
        check_old_paths "$script"
        echo ""
    fi
done
```

#### 功能测试验证
```bash
# 创建测试脚本验证功能 (包括严格的目录生成测试)
create_test_script() {
    cat > test_script_modifications.sh << 'EOF'
#!/bin/bash
echo "🔧 测试脚本修改结果和项目隔离..."

# 🧹 严格测试: 先清理环境
echo "🧹 清理测试环境 (.cursorGrowth)..."
rm -rf .cursorGrowth
if [[ -d ".cursorGrowth" ]]; then
    echo "❌ 清理失败"
    exit 1
else
    echo "✅ 环境清理成功"
fi

# 测试 path-config.sh
echo "测试 path-config.sh..."
source .cursor/core/path-config.sh

# 🛡️ 测试项目隔离
echo "测试项目隔离机制..."
if [[ -n "$PROJECT_IDENTIFIER" ]]; then
    echo "✅ 项目标识生成: $PROJECT_IDENTIFIER"
else
    echo "❌ 项目标识生成失败"
    exit 1
fi

# 测试项目上下文验证
echo "测试项目上下文验证..."
if validate_project_context 2>/dev/null; then
    echo "✅ 项目上下文验证通过"
else
    echo "❌ 项目上下文验证失败"
    exit 1
fi

# 测试路径变量定义
if [[ -n "$CORE_DATA_DIR" && -n "$AI_LEARNING_DIR" ]]; then
    echo "✅ 路径变量定义正确"
else
    echo "❌ 路径变量定义失败"
    exit 1
fi

# 测试项目隔离路径
echo "测试项目隔离路径..."
if [[ "$CORE_DATA_DIR" == *"$PROJECT_IDENTIFIER"* ]]; then
    echo "✅ 路径自动隔离到当前项目"
else
    echo "❌ 路径未正确隔离到当前项目"
    exit 1
fi

# 测试目录创建 (项目隔离)
echo "测试目录创建..."
mkdir -p "$CORE_DATA_DIR" "$AI_LEARNING_DIR" 2>/dev/null
if [[ -d "$CORE_DATA_DIR" && -d "$AI_LEARNING_DIR" ]]; then
    echo "✅ 项目隔离目录创建成功"
else
    echo "❌ 项目隔离目录创建失败"
    exit 1
fi

# 测试安全文件操作
echo "测试安全文件操作..."
test_file="$CORE_DATA_DIR/test_file.txt"
if safe_file_operation "write" "$test_file" "test content"; then
    echo "✅ 安全文件操作成功"
    rm -f "$test_file"  # 清理测试文件
else
    echo "❌ 安全文件操作失败"
    exit 1
fi

# 🧪 测试目录生成能力
echo "测试目录生成能力..."
ensure_directory_structure

# 验证关键目录是否生成
missing_dirs=0
for dir in "$CORE_DATA_DIR" "$AI_LEARNING_DIR" "$SYSTEM_LOGS_DIR"; do
    if [[ ! -d "$dir" ]]; then
        echo "❌ 目录未生成: $dir"
        ((missing_dirs++))
    fi
done

if [[ $missing_dirs -eq 0 ]]; then
    echo "✅ 所有关键目录生成成功"
    echo "📁 生成的目录结构:"
    find .cursorGrowth -type d | head -10
else
    echo "❌ $missing_dirs 个关键目录生成失败"
    exit 1
fi

echo ""
echo "🎉 所有测试通过！脚本修改和项目隔离工作正常。"
echo "   项目标识: $PROJECT_IDENTIFIER"
echo "   核心数据目录: $CORE_DATA_DIR"
echo "   生成的目录数量: $(find .cursorGrowth -type d | wc -l)"
EOF

    chmod +x test_script_modifications.sh
    echo "运行测试脚本..."
    ./test_script_modifications.sh
}
```

#### performance-monitor.sh 路径更新
```bash
# 第19-21行: 目录变量定义
# 旧:
ANALYTICS_DATA_DIR="$ANALYTICS_DIR/data"
ANALYTICS_CACHE_DIR="$ANALYTICS_DIR/cache"
METRICS_FILE="$ANALYTICS_DATA_DIR/analytics-monitoring-metrics.json"

# 新:
ANALYTICS_DATA_DIR="$ANALYTICS_DATA_DIR"        # 使用统一变量
ANALYTICS_CACHE_DIR="$ANALYTICS_CACHE_DIR"      # 使用统一变量
METRICS_FILE="$ANALYTICS_DATA_DIR/analytics-monitoring-metrics.json"
```

#### self-learning-engine.sh 路径更新
```bash
# 第22-25行: 目录变量定义
# 旧:
LEARNING_DIR="$AI_DIR"
LEARNING_MODELS_DIR="$LEARNING_DIR/models"
LEARNING_DATA_DIR="$LEARNING_DIR/data"
LEARNING_METRICS_DIR="$LEARNING_DIR/metrics"

# 新:
LEARNING_DIR="$AI_LEARNING_DIR"                  # 使用统一变量
LEARNING_MODELS_DIR="$AI_MODELS_DIR"             # 使用统一变量
LEARNING_TRAINING_DIR="$AI_TRAINING_DATA_DIR"    # 使用统一变量
LEARNING_METRICS_DIR="$AI_METRICS_DIR"           # 使用统一变量
```

#### cursor-master.sh 安全路径更新
```bash
# ❌ 危险操作: 避免使用 sed 全局替换 (可能误替换)
# sed -i 's|$GROWTH_DIR/learning/|$LEARNING_PROGRESS_DIR/|g' cursor-master.sh

# ✅ 安全操作: 逐个查找和手动替换
cp cursor-master.sh cursor-master.sh.backup

# 步骤1: 查找所有需要更新的路径
grep -n "GROWTH_DIR/learning" cursor-master.sh
grep -n "GROWTH_DIR/conversations" cursor-master.sh
grep -n "GROWTH_DIR/growth" cursor-master.sh
grep -n "CURSOR_GROWTH/logs" cursor-master.sh

# 步骤2: 逐行手动编辑每个匹配位置
# 使用编辑器打开文件，逐个检查和替换:
# - 第1128行: $GROWTH_DIR/learning/master_interactions.json
# - 第1168行: $GROWTH_DIR/conversations/session_$session_id.json
# - 第1242,1287,1926,1951,2010,2045行: 相关路径

# 步骤3: 验证替换结果
grep -n "GROWTH_DIR\|CURSOR_GROWTH" cursor-master.sh
# 确保只剩下兼容性代码中的引用
```

### 3. 配置文件更新
更新 `intelligent_evolution.config.json` 中的路径引用：
```json
{
  "data_directories": {
    "perception": "core-data/perception",
    "user_preferences": "core-data/user-data",
    "project_metrics": "core-data/project-data"
  }
}
```

## 🔍 校验和检查机制

### 1. 文件完整性校验 (Checksum Validation)

#### 基线生成
```bash
# 生成迁移前所有文件的MD5校验和
find .cursorGrowth -type f -exec md5sum {} \; > migration_baseline.md5

# 生成目录结构快照
find .cursorGrowth -type d | sort > directory_structure_pre.txt
```

#### 迁移过程校验
```bash
# 迁移中实时校验
verify_file_integrity() {
    local file="$1"
    local expected_checksum="$2"

    if [[ -f "$file" ]]; then
        local actual_checksum=$(md5sum "$file" | cut -d' ' -f1)
        if [[ "$actual_checksum" != "$expected_checksum" ]]; then
            echo "❌ 文件完整性校验失败: $file"
            echo "  期望: $expected_checksum"
            echo "  实际: $actual_checksum"
            return 1
        fi
    else
        echo "❌ 文件不存在: $file"
        return 1
    fi

    echo "✅ 文件完整性校验通过: $file"
    return 0
}
```

#### 迁移后验证
```bash
# 验证所有文件完整性
md5sum -c migration_baseline.md5 > integrity_check.log 2>&1

# 生成迁移后校验和
find .cursorGrowth -type f -exec md5sum {} \; > migration_final.md5

# 比较迁移前后的差异
diff migration_baseline.md5 migration_final.md5 > checksum_diff.log
```

### 2. 路径引用校验 (Path Reference Validation)

#### 脚本路径扫描
```bash
# 查找所有硬编码路径
grep -r "\$CURSOR_GROWTH" .cursor/ --include="*.sh" > hardcoded_paths.log

# 检查过时路径引用
grep -r "data/perception\|personal/\|mcps/" .cursor/ --include="*.sh" > deprecated_paths.log

# 验证新路径变量使用
grep -r "CORE_DATA_DIR\|AI_LEARNING_DIR\|ANALYTICS_MONITORING_DIR" .cursor/ --include="*.sh" > new_paths_usage.log
```

#### 配置文件校验
```bash
# 验证intelligent_evolution.config.json中的路径
validate_config_paths() {
    local config_file=".cursor/config/intelligent_evolution.config.json"

    # 检查数据目录路径
    local perception_path=$(jq -r '.growth_architecture.data_directories.perception // empty' "$config_file")
    local user_prefs_path=$(jq -r '.growth_architecture.data_directories.user_preferences // empty' "$config_file")
    local project_metrics_path=$(jq -r '.growth_architecture.data_directories.project_metrics // empty' "$config_file")

    # 验证路径格式
    if [[ "$perception_path" != "core-data/perception" ]]; then
        echo "❌ 感知数据路径配置错误: $perception_path"
        return 1
    fi

    if [[ "$user_prefs_path" != "core-data/user-data" ]]; then
        echo "❌ 用户偏好路径配置错误: $user_prefs_path"
        return 1
    fi

    if [[ "$project_metrics_path" != "core-data/project-data" ]]; then
        echo "❌ 项目指标路径配置错误: $project_metrics_path"
        return 1
    fi

    echo "✅ 配置文件路径校验通过"
    return 0
}
```

### 3. 功能完整性校验 (Functional Integrity Check)

#### 脚本执行校验
```bash
# 批量测试脚本执行
test_script_execution() {
    local script="$1"
    local expected_output="$2"

    echo "测试脚本: $script"

    # 执行脚本并捕获输出
    local output=$(timeout 30s bash "$script" 2>&1)
    local exit_code=$?

    # 检查退出码
    if [[ $exit_code -ne 0 ]]; then
        echo "❌ 脚本执行失败 (退出码: $exit_code): $script"
        echo "输出: $output" >> script_errors.log
        return 1
    fi

    # 检查期望输出
    if [[ -n "$expected_output" ]] && ! echo "$output" | grep -q "$expected_output"; then
        echo "❌ 脚本输出不符合预期: $script"
        echo "期望: $expected_output"
        echo "实际: $output" >> script_output_mismatch.log
        return 1
    fi

    echo "✅ 脚本执行成功: $script"
    return 0
}

# 测试关键脚本
test_script_execution ".cursor/core/growth-recorder.sh init" "生长目录已通过管理器初始化"
test_script_execution ".cursor/core/self-learning-engine.sh" "初始化自学习引擎"
test_script_execution ".cursor/features/automation/scripts/growth_init.sh" "初始化完成"
```

#### 目录结构校验
```bash
# 验证目录结构完整性
validate_directory_structure() {
    local expected_dirs=(
        "core-data/perception"
        "core-data/user-data"
        "core-data/project-data"
        "ai-learning/models"
        "ai-learning/training-data"
        "ai-learning/metrics"
        "ai-learning/results"
        "analytics-monitoring/data"
        "analytics-monitoring/cache"
        "analytics-monitoring/system-metrics"
        "storage-cache/rules"
        "storage-cache/templates"
        "storage-cache/backups"
        "records-logs/conversations"
        "records-logs/growth-metrics"
        "records-logs/system-logs"
        "system-services/config"
        "system-services/debug"
        "system-services/compression"
        "system-services/sync"
        "system-services/integrations"
    )

    local missing_dirs=()

    for dir in "${expected_dirs[@]}"; do
        if [[ ! -d ".cursorGrowth/$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done

    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        echo "❌ 缺少目录: ${missing_dirs[*]}"
        return 1
    fi

    echo "✅ 目录结构校验通过"
    return 0
}
```

### 4. 性能基准校验 (Performance Benchmark Check)

#### 执行时间监控
```bash
# 记录脚本执行时间
benchmark_script_execution() {
    local script="$1"
    local max_time="$2"  # 最大允许时间(秒)

    echo "性能基准测试: $script"

    local start_time=$(date +%s.%3N)
    timeout "$max_time"s bash "$script" >/dev/null 2>&1
    local exit_code=$?
    local end_time=$(date +%s.%3N)

    local execution_time=$(echo "$end_time - $start_time" | bc)

    if [[ $exit_code -eq 124 ]]; then
        echo "❌ 脚本执行超时: $script (${execution_time}s > ${max_time}s)"
        return 1
    elif [[ $(echo "$execution_time > $max_time" | bc) -eq 1 ]]; then
        echo "⚠️  脚本执行较慢: $script (${execution_time}s)"
        return 0  # 不算错误，只是警告
    else
        echo "✅ 脚本执行正常: $script (${execution_time}s)"
        return 0
    fi
}

# 设置性能基准
benchmark_script_execution ".cursor/core/growth-recorder.sh init" 5
benchmark_script_execution ".cursor/core/self-learning-engine.sh" 15
benchmark_script_execution ".cursor/features/automation/scripts/growth_init.sh" 5
```

#### 资源使用监控
```bash
# 监控内存和CPU使用
monitor_resource_usage() {
    local script="$1"
    local pid=""

    echo "资源监控: $script"

    # 启动脚本
    bash "$script" &
    pid=$!

    # 监控资源使用
    timeout 10s top -b -n 1 -p "$pid" | grep "$pid" >> resource_usage.log

    # 等待脚本完成
    wait "$pid" 2>/dev/null

    echo "✅ 资源监控完成: $script"
}
```

## 📊 预期效果

### 数量变化
- **目录总数**: 34个 → 24个 (29%减少)
- **顶级目录**: 20个 → 6个 (70%减少)
- **文件数量**: 保持31个不变
- **功能完整性**: 100%保持

### 质量提升
- **结构清晰度**: ⭐⭐⭐⭐⭐ (大幅提升)
- **维护便利性**: ⭐⭐⭐⭐⭐ (显著改善)
- **扩展友好性**: ⭐⭐⭐⭐⭐ (完美支持)
- **理解难度**: ⭐⭐⭐⭐⭐ (大幅降低)

### 校验覆盖
- **文件完整性**: ⭐⭐⭐⭐⭐ (MD5校验和)
- **路径正确性**: ⭐⭐⭐⭐⭐ (自动化扫描)
- **功能完整性**: ⭐⭐⭐⭐⭐ (端到端测试)
- **性能基准**: ⭐⭐⭐⭐⭐ (时间和资源监控)

### 性能影响
- **路径解析**: 保持不变 (缓存机制)
- **脚本执行**: 保持不变 (兼容性保证)
- **查找效率**: 有所提升 (层级更清晰)
- **存储效率**: 保持不变

## ⚠️ 风险评估

### 高风险项目
1. **路径引用错误**: 脚本中硬编码路径可能遗漏更新
2. **配置文件失效**: config.json 中的路径引用需要同步更新
3. **缓存机制失效**: PROJECT_ROOT 缓存可能指向错误路径

### 中风险项目
1. **向后兼容性**: 旧脚本可能仍使用旧路径
2. **功能测试不足**: 某些边缘情况可能未充分测试
3. **文档更新滞后**: 使用说明可能与新结构不符

### 低风险项目
1. **性能影响**: 基本无性能影响
2. **存储空间**: 无额外存储开销
3. **系统稳定性**: 改造不影响核心功能

## 🛡️ 回滚计划

### 紧急回滚步骤
1. **恢复旧的 path-config.sh**
2. **重新创建旧目录结构**
3. **恢复配置文件中的旧路径**
4. **验证所有功能恢复正常**

### 渐进式回滚
1. **保留新旧路径兼容性**
2. **逐步迁移脚本使用新路径**
3. **分阶段删除旧目录结构**
4. **最终完成全面迁移**

## 📅 时间安排

- **总工期**: 8.5个工作日 (脚本为中心，不涉及内容迁移)
- **Phase 1**: Day 1 (规划准备 - 定义目标结构和分析脚本能力)
- **Phase 2**: Day 2-4 (脚本更新 - 让脚本能生成目标结构)
- **Phase 3**: Day 5 (目录重构 - 删除旧.cursorGrowth，生成新结构)
- **Phase 4**: Day 6-7 (测试验证 - 从干净状态验证功能)
- **Phase 4.5**: Day 8 (清理阶段 - 0.5天)
- **Phase 5**: Day 9 (文档更新和最终验证)

### 脚本更新详细时间分配 (按优先级和复杂度 - 安全第一)

- **Day 1 (规划准备 - 定义目标和分析脚本)**:
  - 制定目标目录结构标准 (2小时)
  - 分析所有脚本的目录创建需求 (3小时)
  - 识别需要修改的脚本范围 (2小时)
  - 设计共享函数库架构 (2小时)
  - 创建验证框架和标准 (1小时)

- **Day 2 (高优先级核心脚本 - 函数抽象)**:
  - `shared-functions.sh` - 创建共享函数库，抽象所有共同函数 (4小时)
  - `path-config.sh` - 实现项目识别机制和路径管理系统 (6小时)
  - `growth-recorder.sh` - 重构使用共享函数库 (3小时)
  - `growth-manager.sh` - 重构使用共享函数库 (3小时)
  - **安全检查**: 函数抽象验证和项目识别检查 (2小时)

- **Day 3 (主要功能脚本 - 逐个验证)**:
  - `growth_init.sh` - 基础配置文件路径 (手动检查修改) (3小时)
  - `cursor-master.sh` - 多处路径引用更新 (逐行检查，重点验证) (6小时)
  - `performance-monitor.sh` - 分析监控路径 (手动检查修改) (3小时)
  - **安全检查**: 每个脚本修改后的完整验证 (2小时)

- **Day 4 (钩子脚本群 - 逐个安全修改)**:
  - `session-summary.sh` - 日志路径更新 (手动检查上下文) (2小时)
  - `rule-usage-tracker.sh` - 日志路径更新 (手动检查上下文) (2小时)
  - `command-log.sh` - 日志路径更新 (手动检查上下文) (2小时)
  - `security-audit.sh` - 日志路径更新 (手动检查上下文) (2小时)
  - `prompt-security.sh` - 日志路径更新 (手动检查上下文) (2小时)
  - `code-quality.sh` - 日志路径更新 (手动检查上下文) (2小时)
  - **安全检查**: 每个钩子脚本修改后的验证 (2小时)

- **Day 5 (严格验证 - 每次删除.cursorGrowth)**:
  - 扫描其他可能受影响的脚本 (手动检查) (3小时)
  - 验证所有路径引用正确性 (语法+逻辑验证) (4小时)
  - 运行测试脚本验证功能完整性 (每次删除.cursorGrowth测试) (4小时)

- **Day 8 (清理阶段 - 安全清理)**:
  - 扫描和识别临时文件 (人工确认) (2小时)
  - 备份重要临时数据 (验证备份完整性) (1小时)
  - 安全清理测试脚本 (分批删除，逐个确认) (2小时)
  - 清理临时文档和日志 (人工检查) (2小时)
  - 验证清理完整性 (确保未误删重要文件) (1.5小时)

## ✅ 验收标准

### 功能验收
- [ ] 所有脚本正常启动和运行
- [ ] 文件正确创建在新目录结构中
- [ ] 路径配置正确解析
- [ ] 缓存机制正常工作
- [ ] **文件完整性校验通过** (MD5校验和)
- [ ] **路径引用校验通过** (无过时路径)

### 性能验收
- [ ] 脚本执行时间无明显增加 (≤基准值)
- [ ] 路径解析性能保持稳定
- [ ] 系统资源使用正常
- [ ] **性能基准校验通过** (时间监控)

### 质量验收
- [ ] 代码无语法错误
- [ ] 配置无格式错误
- [ ] 文档内容准确完整
- [ ] **目录结构校验通过** (6层级目录结构完整正确)
- [ ] **配置文件校验通过** (路径引用正确)

### 安全验收
- [ ] **校验和检查全部通过** (文件完整性保证)
- [ ] **功能完整性校验通过** (每次测试前删除 .cursorGrowth，从干净状态验证)
- [ ] 回滚机制有效 (紧急和渐进式回滚)
- [ ] 向后兼容性保持 (旧路径变量可用)
- [ ] **清理验收通过** (只删除了无关文件，重要文件保留)
- [ ] **项目识别验收通过** (脚本能正确识别所属项目)
- [ ] **脚本独立执行验收通过** (每个脚本都是项目独立的)
- [ ] **共享函数库验收通过** (所有共同函数已抽象，维护成本降低)

## 🧹 清理策略

### 清理目标识别
```bash
# 扫描可能需要清理的文件类型
find_cleanup_targets() {
    echo "🔍 扫描临时文件和测试文件..."

    # 测试脚本 (通常包含 test, temp, tmp 等关键词)
    find . -name "*.sh" -type f -exec grep -l "test\|temp\|tmp\|debug\|临时\|测试" {} \;

    # 临时文档
    find . -name "*.md" -o -name "*.txt" -o -name "*.log" | grep -E "(test|temp|tmp|debug|临时|测试|log)"

    # 缓存文件
    find . -name "*cache*" -o -name "*.tmp" -o -name "*.bak"

    # 可能误生成的配置文件
    find . -name "*.json" -exec grep -l "test\|temp\|临时" {} \;
}
```

### 安全清理规则

#### ✅ 可以安全删除的文件类型
- **测试脚本**: 包含 `test_`, `temp_`, `tmp_`, `debug_` 前缀的文件
- **临时文档**: 测试过程中产生的临时 `.md`, `.txt` 文件
- **日志文件**: 测试期间的 `.log` 文件（非系统日志）
- **缓存文件**: 测试过程中产生的缓存文件
- **备份文件**: 自动生成的 `.bak`, `.backup` 文件

#### ❌ 绝对不能删除的文件类型
- **核心脚本**: `cursor-master.sh`, `path-config.sh` 等核心功能脚本
- **配置文件**: `intelligent_evolution.config.json` 等正式配置文件
- **系统日志**: `system-logs/` 目录下的日志文件
- **用户数据**: `user-data/`, `conversations/` 等数据目录
- **AI模型**: `ai/models/` 目录下的模型文件

### 清理执行流程

#### 1. 备份重要临时文件
```bash
# 创建清理备份目录
CLEANUP_BACKUP_DIR="$CURSOR_GROWTH/cleanup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$CLEANUP_BACKUP_DIR"

# 备份可能有用的临时文件
backup_important_temp_files() {
    # 备份测试产生的配置数据
    find . -name "*.json" -exec grep -l "test.*config\|temp.*settings" {} \; | \
        xargs -I {} cp {} "$CLEANUP_BACKUP_DIR/configs/"

    # 备份测试日志 (可能包含调试信息)
    find . -name "*test*.log" -o -name "*debug*.log" | \
        xargs -I {} cp {} "$CLEANUP_BACKUP_DIR/logs/"
}
```

#### 2. 分批次清理
```bash
# 第一批: 最安全的临时文件
safe_cleanup_phase1() {
    echo "🧹 第一批清理: 最安全的临时文件"

    # 删除测试脚本
    find . -name "test_*.sh" -o -name "temp_*.sh" -o -name "*_test.sh" | xargs rm -f

    # 删除临时日志
    find . -name "*.tmp.log" -o -name "temp*.log" | xargs rm -f

    # 删除临时缓存
    find . -name "*.cache.tmp" -o -name "temp*.cache" | xargs rm -f
}

# 第二批: 需要人工确认的文件
safe_cleanup_phase2() {
    echo "🧹 第二批清理: 需要确认的文件"

    # 查找可疑文件供人工确认
    find . -name "*.md" -exec grep -l "测试\|临时\|test\|temp" {} \; | \
        while read file; do
            echo "检查文件: $file"
            head -5 "$file"  # 显示文件开头内容
            read -p "是否删除此文件? (y/N): " answer
            [[ "$answer" == "y" ]] && rm -f "$file"
        done
}
```

#### 3. 清理验证
```bash
# 验证清理结果
verify_cleanup() {
    echo "✅ 清理验证:"

    # 检查是否误删了重要文件
    local missing_critical_files=0

    # 检查核心脚本是否存在
    [[ ! -f ".cursor/core/path-config.sh" ]] && echo "❌ 核心文件缺失: path-config.sh" && ((missing_critical_files++))
    [[ ! -f "cursor-master.sh" ]] && echo "❌ 核心文件缺失: cursor-master.sh" && ((missing_critical_files++))

    # 检查配置文件是否存在
    [[ ! -f ".cursor/config/intelligent_evolution.config.json" ]] && echo "❌ 配置文件缺失" && ((missing_critical_files++))

    if [[ $missing_critical_files -eq 0 ]]; then
        echo "✅ 清理验证通过: 未误删重要文件"
        return 0
    else
        echo "❌ 清理验证失败: 误删了 $missing_critical_files 个重要文件"
        return 1
    fi
}
```

### 清理记录和追溯

#### 记录清理操作
```bash
# 创建清理日志
cleanup_log="$CURSOR_GROWTH/cleanup_log_$(date +%Y%m%d_%H%M%S).txt"

log_cleanup_action() {
    local action="$1"
    local file="$2"
    local reason="$3"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | $action | $file | $reason" >> "$cleanup_log"
}

# 使用示例
log_cleanup_action "DELETE" "/path/to/test_script.sh" "测试脚本，无用"
log_cleanup_action "BACKUP" "/path/to/temp_config.json" "可能有用的测试配置"
```

#### 清理统计报告
```bash
generate_cleanup_report() {
    echo "🧹 清理完成报告" > "$cleanup_log"
    echo "清理时间: $(date)" >> "$cleanup_log"
    echo "清理人: $(whoami)" >> "$cleanup_log"
    echo "" >> "$cleanup_log"

    echo "删除的文件统计:" >> "$cleanup_log"
    grep "DELETE" "$cleanup_log" | wc -l >> "$cleanup_log"

    echo "" >> "$cleanup_log"
    echo "备份的文件统计:" >> "$cleanup_log"
    grep "BACKUP" "$cleanup_log" | wc -l >> "$cleanup_log"

    echo "" >> "$cleanup_log"
    echo "详细操作记录:" >> "$cleanup_log"
    cat "$cleanup_log"
}
```

## 🔒 校验总结

### 校验类型覆盖

| 校验类型           | 覆盖范围       | 执行时机     | 验证内容                |
| ------------------ | -------------- | ------------ | ----------------------- |
| **文件完整性校验** | 所有迁移文件   | 迁移前/中/后 | MD5校验和验证文件未损坏 |
| **路径引用校验**   | 所有脚本和配置 | 脚本更新后   | 检查硬编码路径是否更新  |
| **功能完整性校验** | 所有核心脚本   | 测试阶段     | 验证脚本执行和文件创建  |
| **性能基准校验**   | 关键脚本       | 测试阶段     | 监控执行时间和资源使用  |
| **目录结构校验**   | 新目录架构     | 目录重构后   | 验证6层级结构完整性     |
| **配置文件校验**   | 所有配置文件   | 配置更新后   | 验证路径引用正确性      |
| **项目隔离校验**   | 多项目环境     | 所有阶段     | 验证项目数据完全隔离    |

### 校验自动化程度

- **手动校验**: 17% (人工检查文档和配置)
- **半自动化校验**: 33% (脚本辅助检查)
- **全自动化校验**: 50% (脚本自动验证)

### 校验频率

- **实时校验**: 迁移过程中的即时验证
- **阶段校验**: 每个Phase结束时的全面检查
- **最终校验**: 项目完成后的完整验收

### 校验输出

所有校验结果将保存到以下文件中：
- `migration_baseline.md5` - 迁移前文件校验和
- `migration_final.md5` - 迁移后文件校验和
- `integrity_check.log` - 文件完整性检查日志
- `script_errors.log` - 脚本执行错误日志
- `resource_usage.log` - 资源使用监控日志
- `validation_report.md` - 完整的校验报告

---

**改造负责人**: AI Assistant
**审批状态**: ⏳ 待审批
**开始时间**: 待定
**完成时间**: 待定

*此计划将 .cursorGrowth 重构为6个顶级功能目录的标准化架构，通过修改15+个脚本让它们能生成目标目录结构，配备完整的校验和检查机制，确保重构过程的安全性和正确性*