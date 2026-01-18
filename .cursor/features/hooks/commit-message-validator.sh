#!/bin/bash
# ✅ 提交消息验证器钩子
# 验证提交消息是否符合Conventional Commits规范
# 集成到增强版Git提交流程中

set -e

# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../core" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
source "$SCRIPT_DIR/path-config.sh"

# 项目上下文验证
validate_project_context || exit 1

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 记录钩子执行
log() {
    echo "[HOOK:commit-message-validator] $(date '+%H:%M:%S') $*" >&2
}

# 验证Conventional Commits格式
validate_conventional_commits() {
    local commit_message="$1"

    log "验证Conventional Commits格式: $commit_message"

    # Conventional Commits正则表达式
    # type(scope): description
    local pattern='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([a-zA-Z0-9_-]+\))?: .{1,100}$'

    if echo "$commit_message" | grep -qP "$pattern"; then
        echo -e "${GREEN}✅ 提交消息格式正确${NC}" >&2
        return 0
    else
        echo -e "${RED}❌ 提交消息格式不符合Conventional Commits规范${NC}" >&2
        echo -e "${YELLOW}📋 正确格式: type(scope): description${NC}" >&2
        echo -e "${CYAN}🔧 支持的type: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert${NC}" >&2
        echo -e "${CYAN}📝 示例: feat(user): add login functionality${NC}" >&2
        return 1
    fi
}

# 检查提交消息长度
check_message_length() {
    local commit_message="$1"
    local max_length=72

    if [ ${#commit_message} -gt $max_length ]; then
        echo -e "${YELLOW}⚠️  提交消息过长 (${#commit_message} 字符，建议不超过 $max_length)${NC}" >&2
        return 1
    fi

    echo -e "${GREEN}✅ 提交消息长度合适${NC}" >&2
    return 0
}

# 检查提交消息质量
check_message_quality() {
    local commit_message="$1"

    # 检查是否包含有意义的描述
    if echo "$commit_message" | grep -q "update\|fix\|add\|remove\|change"; then
        echo -e "${GREEN}✅ 提交消息描述清晰${NC}" >&2
        return 0
    else
        echo -e "${YELLOW}⚠️  提交消息描述较为简单，建议提供更多详细信息${NC}" >&2
        return 1
    fi
}

# 分析提交类型与变更的匹配度
analyze_type_consistency() {
    local commit_message="$1"

    # 提取提交类型
    local commit_type=$(echo "$commit_message" | sed -n 's/^\([a-zA-Z]*\).*/\1/p')

    # 分析变更内容
    local has_code_changes=false
    local has_doc_changes=false
    local has_config_changes=false

    if git diff --cached --name-only | grep -q '\.js\|\.ts\|\.py\|\.java\|\.cpp\|\.c\|\.go\|\.rs\|\.php\|\.rb\|\.swift\|\.kt\|\.scala\|\.clj\|\.hs\|\.ml\|\.fs\|\.vb\|\.cs'; then
        has_code_changes=true
    fi

    if git diff --cached --name-only | grep -q '\.md\|\.txt\|\.rst\|\.adoc\|\.pdf\|\.doc\|\.docx'; then
        has_doc_changes=true
    fi

    if git diff --cached --name-only | grep -q '\.json\|\.yaml\|\.yml\|\.toml\|\.ini\|\.cfg\|\.conf\|\.properties\|\.env'; then
        has_config_changes=true
    fi

    # 检查类型一致性
    case "$commit_type" in
        "feat")
            if [ "$has_code_changes" = false ]; then
                echo -e "${YELLOW}⚠️  feat类型但未检测到代码变更${NC}" >&2
            fi
            ;;
        "fix")
            if [ "$has_code_changes" = false ]; then
                echo -e "${YELLOW}⚠️  fix类型但未检测到代码变更${NC}" >&2
            fi
            ;;
        "docs")
            if [ "$has_doc_changes" = false ]; then
                echo -e "${YELLOW}⚠️  docs类型但未检测到文档变更${NC}" >&2
            fi
            ;;
        "test")
            if ! git diff --cached --name-only | grep -q "test\|spec"; then
                echo -e "${YELLOW}⚠️  test类型但未检测到测试文件变更${NC}" >&2
            fi
            ;;
        "config"|"build"|"ci"|"chore")
            # 这些类型通常不需要特殊验证
            ;;
        *)
            echo -e "${YELLOW}⚠️  未知的提交类型: $commit_type${NC}" >&2
            ;;
    esac

    echo -e "${GREEN}✅ 类型一致性检查完成${NC}" >&2
}

# 提供修复建议
provide_fix_suggestions() {
    local commit_message="$1"

    echo -e "${BLUE}💡 修复建议:${NC}" >&2

    # 分析当前消息的问题
    if ! echo "$commit_message" | grep -q ':'; then
        echo -e "${CYAN}  • 添加冒号分隔类型和描述${NC}" >&2
    fi

    if ! echo "$commit_message" | grep -qP '^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)'; then
        echo -e "${CYAN}  • 使用标准提交类型${NC}" >&2
        echo -e "${CYAN}    feat: 新功能${NC}" >&2
        echo -e "${CYAN}    fix: 修复bug${NC}" >&2
        echo -e "${CYAN}    docs: 文档更新${NC}" >&2
        echo -e "${CYAN}    refactor: 代码重构${NC}" >&2
        echo -e "${CYAN}    test: 测试相关${NC}" >&2
        echo -e "${CYAN}    chore: 构建工具${NC}" >&2
    fi

    if [ ${#commit_message} -gt 72 ]; then
        echo -e "${CYAN}  • 缩短描述长度 (当前: ${#commit_message}, 建议: ≤72)${NC}" >&2
    fi
}

# 生成自动修复的提交消息
generate_fixed_message() {
    local original_message="$1"

    log "尝试自动修复提交消息"

    # 简单的自动修复逻辑
    local fixed_message="$original_message"

    # 添加缺失的类型
    if ! echo "$fixed_message" | grep -qP '^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)'; then
        # 基于变更内容推断类型
        if git diff --cached --name-only | grep -q '\.md\|\.txt\|\.rst\|\.adoc'; then
            fixed_message="docs: $fixed_message"
        elif git diff --cached --name-only | grep -q "test\|spec"; then
            fixed_message="test: $fixed_message"
        elif git diff --cached --name-only | grep -q '\.json\|\.yaml\|\.yml\|\.toml'; then
            fixed_message="config: $fixed_message"
        else
            fixed_message="feat: $fixed_message"
        fi
    fi

    # 添加缺失的冒号
    if ! echo "$fixed_message" | grep -q ':'; then
        fixed_message=$(echo "$fixed_message" | sed 's/ /: /')
    fi

    echo -e "${BLUE}🔧 建议的修复版本: ${NC}$fixed_message" >&2
    echo "$fixed_message"
}

# 主处理函数
main() {
    local hook_event="$1"
    local commit_message="$2"

    log "执行提交消息验证钩子: $hook_event"

    case "$hook_event" in
        "commit-msg")
            # Git commit-msg钩子标准处理
            if [ -z "$commit_message" ]; then
                # 从标准输入读取提交消息
                commit_message=$(cat)
            fi

            log "验证提交消息: $commit_message"

            local validation_passed=true

            # 1. 验证Conventional Commits格式
            if ! validate_conventional_commits "$commit_message"; then
                validation_passed=false
            fi

            # 2. 检查消息长度
            if ! check_message_length "$commit_message"; then
                validation_passed=false
            fi

            # 3. 检查消息质量
            if ! check_message_quality "$commit_message"; then
                validation_passed=false
            fi

            # 4. 分析类型一致性
            analyze_type_consistency "$commit_message"

            if [ "$validation_passed" = false ]; then
                echo "" >&2
                provide_fix_suggestions "$commit_message"
                echo "" >&2

                # 尝试提供自动修复建议
                local fixed_message=$(generate_fixed_message "$commit_message")
                if [ "$fixed_message" != "$commit_message" ]; then
                    echo -e "${YELLOW}❓ 是否使用建议的修复版本？(y/N): ${NC}" >&2
                    read -r -t 10 use_fix </dev/tty || use_fix="n"
                    if [[ $use_fix =~ ^[Yy]$ ]]; then
                        echo "$fixed_message" > "$1"  # 覆盖提交消息文件
                        echo -e "${GREEN}✅ 已应用修复版本${NC}" >&2
                        validation_passed=true
                    fi
                fi

                if [ "$validation_passed" = false ]; then
                    echo -e "${RED}❌ 提交消息验证失败，请修复后重试${NC}" >&2
                    exit 1
                fi
            fi

            log "提交消息验证通过"
            ;;

        "validate-message")
            # 独立的验证接口
            if validate_conventional_commits "$commit_message" && \
               check_message_length "$commit_message" && \
               check_message_quality "$commit_message"; then
                echo "✅ 提交消息验证通过"
                exit 0
            else
                echo "❌ 提交消息验证失败"
                exit 1
            fi
            ;;

        *)
            log "未知钩子事件: $hook_event"
            exit 1
            ;;
    esac
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi