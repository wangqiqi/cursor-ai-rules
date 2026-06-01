#!/bin/bash
# common.sh 核心函数 + 核心-扩展层集成测试

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CURSOR_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

assert() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if [ "$expected" = "$actual" ]; then
        echo "  ✅ $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ $test_name"
        echo "     期望: $expected"
        echo "     实际: $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_exit_code() {
    local test_name="$1"
    local expected_code="$2"
    local actual_code="$3"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if [ "$expected_code" -eq "$actual_code" ]; then
        echo "  ✅ $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ $test_name"
        echo "     期望退出码: $expected_code"
        echo "     实际退出码: $actual_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo ""
echo "🧪 Cursor AI Rules 核心-扩展集成测试"
echo "=================================="
echo ""

# =============================================================================
# 测试组 1: 核心文件完整性
# =============================================================================
echo "📦 测试组 1: 核心文件完整性"

CORE_FILES=(
    "core/init.sh"
    "core/path-config.sh"
    "core/common.sh"
    "cursor-master.sh"
    "rules/core/constitution.mdc"
    "rules/core/constitution_architecture.mdc"
    "config/project.json"
    "README.md"
)

for f in "${CORE_FILES[@]}"; do
    if [ -f "$CURSOR_DIR/$f" ]; then
        echo "  ✅ 核心文件存在: $f"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ 核心文件缺失: $f"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# 仅引导脚本要求零 jq/node 依赖；其余 core/*.sh 可使用 jq（见 README）
echo "  📋 引导脚本零外部依赖检查"
BOOTSTRAP_SCRIPTS=(
    "core/init.sh"
    "core/path-config.sh"
    "core/common.sh"
    "core/colors.sh"
    "cursor-master.sh"
)
bootstrap_dep_issues=0
for rel in "${BOOTSTRAP_SCRIPTS[@]}"; do
    f="$CURSOR_DIR/$rel"
    [ -f "$f" ] || continue
    if grep -qE '(\||;|\{|`)\s*jq\b|command -v jq' "$f" 2>/dev/null; then
        echo "    ❌ $rel 不应包含 jq 命令依赖"
        bootstrap_dep_issues=$((bootstrap_dep_issues + 1))
    fi
    if grep -qE '(\||;|\{|`)\s*node\b|command -v node' "$f" 2>/dev/null; then
        echo "    ❌ $rel 不应包含 node 命令依赖"
        bootstrap_dep_issues=$((bootstrap_dep_issues + 1))
    fi
done
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ "$bootstrap_dep_issues" -eq 0 ]; then
    echo "    ✅ 引导脚本无 jq/node 依赖"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ 引导脚本含 $bootstrap_dep_issues 处外部依赖"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo "  📋 可选工具 jq（Hooks/Master 推荐）"
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if command -v jq >/dev/null 2>&1; then
    echo "    ✅ jq 已安装"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ⚠️ jq 未安装（部分 Hooks 受限，复制即用核心仍可用）"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

echo ""

# =============================================================================
# 测试组 2: 核心脚本语法检查
# =============================================================================
echo "📜 测试组 2: 核心脚本语法检查"

for f in "$CURSOR_DIR/core"/*.sh "$CURSOR_DIR/cursor-master.sh"; do
    basename=$(basename "$f")
    if bash -n "$f" 2>/dev/null; then
        echo "  ✅ 语法正确: $basename"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ 语法错误: $basename"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

echo ""

# =============================================================================
# 测试组 3: 核心功能测试 - path-config.sh
# =============================================================================
echo "📍 测试组 3: path-config.sh 路径解析"

source "$CURSOR_DIR/core/path-config.sh" 2>/dev/null

assert "PROJECT_ROOT 非空" "非空" "${PROJECT_ROOT:+非空}"
assert_exit_code "CURSOR_DIR 存在" 0 $([ -d "$CURSOR_DIR" ] && echo 0 || echo 1)
assert "CURSOR_DIR 以 .cursor 结尾" ".cursor" "$(basename "$CURSOR_DIR")"

echo ""

# =============================================================================
# 测试组 4: 核心功能测试 - init.sh
# =============================================================================
echo "🚀 测试组 4: init.sh 初始化"

source "$CURSOR_DIR/core/init.sh" 2>/dev/null

# 测试项目类型检测
echo "  📋 detect_project_type"
if type detect_project_type >/dev/null 2>&1; then
    PROJECT_TYPE=$(detect_project_type)
    case "$PROJECT_TYPE" in
        node|python|rust|go|java|cpp|unknown)
            echo "    ✅ 返回了有效项目类型: $PROJECT_TYPE"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            ;;
        *)
            echo "    ❌ 无效的项目类型: $PROJECT_TYPE"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            ;;
    esac
else
    echo "    ❌ detect_project_type 函数未定义"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 测试 --quickstart
echo "  📋 init.sh --quickstart"
OUTPUT=$(bash "$CURSOR_DIR/core/init.sh" --quickstart 2>&1) && rc=0 || rc=$?
assert_exit_code "init.sh --quickstart 退出码为 0" 0 $rc
if echo "$OUTPUT" | grep -q "准备就绪"; then
    echo "    ✅ 输出包含'准备就绪'"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ 输出缺少'准备就绪'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""

# =============================================================================
# 测试组 5: 扩展层检测（如果有）
# =============================================================================
echo "🧩 测试组 5: 扩展层集成"

CURSOR_PKG="$PROJECT_ROOT/.cursor"
if [ -d "$CURSOR_PKG" ]; then
    echo "  ✅ .cursor/ 存在"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    if [ -f "$CURSOR_PKG/hooks.json" ]; then
        echo "  ✅ hooks.json 在项目 .cursor/"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ hooks.json 不在 .cursor/"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 2))

    MDC_RULES=$(find "$CURSOR_PKG/rules" -name '*.mdc' 2>/dev/null | wc -l)
    if [ "$MDC_RULES" -ge 10 ] 2>/dev/null; then
        echo "  ✅ 规则库就绪 ($MDC_RULES 个 .mdc)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ⚠️ 规则较少 ($MDC_RULES 个 .mdc)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
else
    echo "  ⏭️ 跳过 (无 .cursor/)"
fi

echo ""

# =============================================================================
# 测试组 6: Hook 日志脚本
# =============================================================================
echo "🪝 测试组 6: Hook 日志脚本"

LOGGING_COMMON="$CURSOR_DIR/hooks/logging-common.sh"
if bash -n "$LOGGING_COMMON" 2>/dev/null; then
    echo "  ✅ logging-common.sh 语法正确"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ❌ logging-common.sh 语法错误"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

if ! grep -qE 'log_to_file \\"|case \\"\$' "$LOGGING_COMMON" 2>/dev/null; then
    echo "  ✅ logging-common.sh 无错误转义引号"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ❌ logging-common.sh 仍含 \\\" 路径转义"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

TEST_INPUT='{"command":"echo hook-test","output":"","duration":50,"cwd":"/tmp","conversation_id":"t1"}'
HOOK_OUT=$(echo "$TEST_INPUT" | bash "$LOGGING_COMMON" command 2>/dev/null) || true
LOG_FILE="$CURSOR_DIR/monitoring/logs/hooks/command-execution.log"
if [ -f "$LOG_FILE" ] && tail -1 "$LOG_FILE" | grep -q 'hook-test'; then
    echo "  ✅ logging-common 写入正确日志路径"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ❌ logging-common 未写入 $LOG_FILE"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

if [ "$HOOK_OUT" = "$TEST_INPUT" ]; then
    echo "  ✅ logging-common 透传 JSON 输入"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ❌ logging-common 未透传 JSON 输入"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""

# =============================================================================
# 汇总
# =============================================================================
echo "=================================="
echo "📊 测试结果汇总"
echo "  总计: $TESTS_TOTAL"
echo "  ✅ 通过: $TESTS_PASSED"
echo "  ❌ 失败: $TESTS_FAILED"
echo "=================================="

if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
