#!/bin/bash
# agent-orchestration 系列文件集成测试
# shelltest 风格（assert 模式）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

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

assert_contains() {
    local test_name="$1"
    local haystack="$2"
    local needle="$3"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if echo "$haystack" | grep -qF "$needle"; then
        echo "  ✅ $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ $test_name"
        echo "     期望包含: $needle"
        echo "     实际内容: $haystack"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo ""
echo "🧪 Agent Orchestration 系列文件测试"
echo "=================================="
echo ""

# =============================================================================
# 测试组 1: 语法检查
# =============================================================================
echo "📜 测试组 1: 语法检查 (bash -n)"

ORCHESTRATION_FILES=(
    "agent-orchestration-common.sh"
    "agent-orchestration-core.sh"
    "agent-orchestration-scheduler.sh"
    "agent-orchestration-engine.sh"
)

for f in "${ORCHESTRATION_FILES[@]}"; do
    full_path="$CORE_DIR/$f"
    if bash -n "$full_path" 2>/dev/null; then
        echo "  ✅ 语法正确: $f"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ 语法错误: $f"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

echo ""

# =============================================================================
# 测试组 2: 函数存在性检查
# =============================================================================
echo "🔍 测试组 2: 函数存在性检查"

# agent-orchestration-core.sh 关键函数
echo "  📋 agent-orchestration-core.sh 函数检查"

CORE_FUNCTIONS=("submit_task" "assign_task_to_agent" "add_task_to_queue" "cancel_task" "get_task_status")

for func in "${CORE_FUNCTIONS[@]}"; do
    if grep -qE "^[[:space:]]*${func}\(\)" "$CORE_DIR/agent-orchestration-core.sh"; then
        echo "    ✅ 函数已定义: $func"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ 函数未定义: $func"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# agent-orchestration-core.sh 中额外关键函数
echo "  📋 agent-orchestration-core.sh 额外函数检查"
EXTRA_CORE_FUNCTIONS=("trigger_task_assignment" "get_pending_tasks" "process_task_queue")
for func in "${EXTRA_CORE_FUNCTIONS[@]}"; do
    if grep -qE "^[[:space:]]*${func}\(\)" "$CORE_DIR/agent-orchestration-core.sh"; then
        echo "    ✅ 函数已定义: $func"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ 函数未定义: $func"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# agent-orchestration-engine.sh main 函数
echo "  📋 agent-orchestration-engine.sh 函数检查"
if grep -qE "^[[:space:]]*main\(\)" "$CORE_DIR/agent-orchestration-engine.sh"; then
    echo "    ✅ 函数已定义: main (engine)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ 函数未定义: main (engine)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 检查 engine.sh 中的其他关键函数
ENGINE_FUNCTIONS=("init_agent_orchestration_engine" "show_system_status" "show_system_health" "run_integration_tests" "cleanup_system" "show_version_info")
for func in "${ENGINE_FUNCTIONS[@]}"; do
    if grep -qE "^[[:space:]]*${func}\(\)" "$CORE_DIR/agent-orchestration-engine.sh"; then
        echo "    ✅ 函数已定义: $func"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ 函数未定义: $func"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# agent-orchestration-scheduler.sh 关键函数
echo "  📋 agent-orchestration-scheduler.sh 函数检查"
SCHEDULER_FUNCTIONS=("select_optimal_agent" "get_system_load_status" "apply_scheduling_strategy" "update_scheduling_stats")
for func in "${SCHEDULER_FUNCTIONS[@]}"; do
    if grep -qE "^[[:space:]]*${func}\(\)" "$CORE_DIR/agent-orchestration-scheduler.sh"; then
        echo "    ✅ 函数已定义: $func"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ 函数未定义: $func"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# 检查 export -f 导出语句
echo "  📋 函数导出声明检查"
if grep -q "export -f submit_task" "$CORE_DIR/agent-orchestration-core.sh"; then
    echo "    ✅ core.sh 包含 submit_task 导出"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ core.sh 缺少 submit_task 导出"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

if grep -q "export -f main" "$CORE_DIR/agent-orchestration-engine.sh"; then
    echo "    ✅ engine.sh 包含 main 导出"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ engine.sh 缺少 main 导出"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""

# =============================================================================
# 测试组 3: 关键函数执行测试
# =============================================================================
echo "⚙️  测试组 3: 关键函数执行测试"

# 3.1 agent-orchestration-common.sh 可被 source 加载
echo "  📋 agent-orchestration-common.sh source 加载测试"
if source "$CORE_DIR/agent-orchestration-common.sh" 2>/dev/null; then
    echo "    ✅ 成功 source agent-orchestration-common.sh"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    # 可能是由于内部 source 链问题，换成子 shell 测试
    bash -c "source '$CORE_DIR/agent-orchestration-common.sh' 2>/dev/null" && rc=0 || rc=$?
    if [ $rc -eq 0 ]; then
        echo "    ✅ 成功 source agent-orchestration-common.sh (子 shell)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ 无法 source agent-orchestration-common.sh"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 3.2 验证 path-config.sh 和 agent-orchestration-common.sh 可同时加载
echo "  📋 path-config.sh + agent-orchestration-common.sh 联合加载测试"
# 使用绝对路径在子 shell 中测试
JOINT_TEST=$(bash -c "
PATH_CONFIG='$CORE_DIR/../../.cursor/core/path-config.sh'
COMMON='$CORE_DIR/agent-orchestration-common.sh'
source \"\$PATH_CONFIG\" 2>/dev/null || { echo 'path_config_fail'; exit 1; }
source \"\$COMMON\" 2>/dev/null || { echo 'common_fail'; exit 1; }
if [ -n \"\$PROJECT_ROOT\" ]; then
    echo 'ok'
else
    echo 'project_root_empty'
fi
") && rc=0 || rc=$?

if [ "$rc" -eq 0 ] && [ "$JOINT_TEST" = "ok" ]; then
    echo "    ✅ path-config.sh 和 agent-orchestration-common.sh 联合加载成功"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ 联合加载失败 (输出: $JOINT_TEST)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 3.3 验证 core.sh 中函数定义格式一致性（所有函数使用 function_name() 风格）
echo "  📋 函数定义风格一致性检查"
INCONSISTENT=0
for f in "${ORCHESTRATION_FILES[@]}"; do
    full_path="$CORE_DIR/$f"
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{"; then
            :  # 符合规范
        elif echo "$line" | grep -qE "^function[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)"; then
            INCONSISTENT=$((INCONSISTENT + 1))
        fi
    done < "$full_path"
done

if [ "$INCONSISTENT" -eq 0 ]; then
    echo "    ✅ 所有函数定义风格一致 (function_name() 格式)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ 发现 $INCONSISTENT 个 function 关键字风格定义"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 3.4 验证 source 依赖链完整性
echo "  📋 source 依赖链完整性检查"
# 检查 core.sh 的 source 依赖文件是否存在
CORE_DEPS=("agent-orchestration-common.sh" "agent-orchestration-lifecycle.sh" "agent-orchestration-discovery.sh" "agent-orchestration-communication.sh")
ALL_DEPS_EXIST=true
for dep in "${CORE_DEPS[@]}"; do
    if [ ! -f "$CORE_DIR/$dep" ]; then
        echo "    ❌ core.sh 依赖缺失: $dep"
        ALL_DEPS_EXIST=false
    fi
done
if [ "$ALL_DEPS_EXIST" = true ]; then
    echo "    ✅ core.sh 所有 source 依赖文件存在"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ core.sh 存在缺失的 source 依赖"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 3.5 验证 scheduler.sh 的 source 依赖
SCHEDULER_DEPS=("agent-orchestration-common.sh" "agent-orchestration-core.sh" "agent-orchestration-discovery.sh")
ALL_SCHED_DEPS=true
for dep in "${SCHEDULER_DEPS[@]}"; do
    if [ ! -f "$CORE_DIR/$dep" ]; then
        echo "    ❌ scheduler.sh 依赖缺失: $dep"
        ALL_SCHED_DEPS=false
    fi
done
if [ "$ALL_SCHED_DEPS" = true ]; then
    echo "    ✅ scheduler.sh 所有 source 依赖文件存在"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ scheduler.sh 存在缺失的 source 依赖"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 3.6 验证 engine.sh 的 source 依赖
ENGINE_DEPS=("agent-orchestration-common.sh" "performance-cache.sh" "context-pool-manager.sh" "agent-orchestration-autonomous-planner.sh")
ALL_ENG_DEPS=true
for dep in "${ENGINE_DEPS[@]}"; do
    if [ ! -f "$CORE_DIR/$dep" ]; then
        echo "    ❌ engine.sh 依赖缺失: $dep"
        ALL_ENG_DEPS=false
    fi
done
if [ "$ALL_ENG_DEPS" = true ]; then
    echo "    ✅ engine.sh 所有 source 依赖文件存在"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "    ❌ engine.sh 存在缺失的 source 依赖"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 3.7 验证 agent-orchestration-common.sh 自身 source 依赖
echo "  📋 agent-orchestration-common.sh 依赖检查"
if grep -q "source.*path-config.sh" "$CORE_DIR/agent-orchestration-common.sh"; then
    if [ -f "$CORE_DIR/path-config.sh" ] || [ -f "$CORE_DIR/../../.cursor/core/path-config.sh" ]; then
        echo "    ✅ path-config.sh 存在"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ path-config.sh 缺失"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "    ❌ agent-orchestration-common.sh 未引用 path-config.sh"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

if grep -q "source.*compact-output.sh" "$CORE_DIR/agent-orchestration-common.sh"; then
    if [ -f "$CORE_DIR/compact-output.sh" ]; then
        echo "    ✅ compact-output.sh 存在"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "    ❌ compact-output.sh 缺失"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "    ❌ agent-orchestration-common.sh 未引用 compact-output.sh"
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
