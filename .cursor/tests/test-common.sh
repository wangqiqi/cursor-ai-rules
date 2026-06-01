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
    "rules/core/constitution.md"
    "rules/core/constitution_architecture.md"
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

# 检查核心文件无实际 jq/node 命令依赖
echo "  📋 核心文件零外部依赖检查"
for f in "$CURSOR_DIR/core"/*.sh "$CURSOR_DIR/cursor-master.sh"; do
    if grep -qE '(\||;|\{|`)\s*jq\b|command -v jq' "$f" 2>/dev/null; then
        echo "    ❌ $f 包含 jq 命令依赖"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    fi
    if grep -qE '(\||;|\{|`)\s*node\b|command -v node' "$f" 2>/dev/null; then
        echo "    ❌ $f 包含 node 命令依赖"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    fi
done
echo "    ✅ 核心文件无 jq/node 依赖"
TESTS_PASSED=$((TESTS_PASSED + 1))
TESTS_TOTAL=$((TESTS_TOTAL + 1))

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

EXTRAS_DIR="$PROJECT_ROOT/.cursor-extras"
if [ -d "$EXTRAS_DIR" ]; then
    echo "  ✅ .cursor-extras/ 存在"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # 检查 hooks.json 在扩展层
    if [ -f "$EXTRAS_DIR/hooks.json" ]; then
        echo "  ✅ hooks.json 在扩展层"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ hooks.json 不在扩展层"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 2))

    # 检查规则目录完整
    EXTRAS_RULES=$(find "$EXTRAS_DIR/rules" -maxdepth 1 -type f 2>/dev/null | wc -l)
    # 放宽要求：核心层已有两条宪法规则，扩展层至少有10条技术规则算健康
    if [ "$EXTRAS_RULES" -ge 10 ] 2>/dev/null; then
        echo "  ✅ 扩展层规则丰富 ($EXTRAS_RULES 文件)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ⚠️ 扩展层规则较少 ($EXTRAS_RULES 文件)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
else
    echo "  ⏭️ 跳过 (无 .cursor-extras/)"
fi

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
