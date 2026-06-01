#!/bin/bash
# 加载统一路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../.cursor/core/path-config.sh"  # 统一路径配置

# 🎯 Cursor AI Rules - 提交信息验证Hook
# 验证Git提交信息的格式和质量

COMMIT_MSG_FILE="$1"

source "$SCRIPT_DIR/../../../.cursor/core/colors.sh"

# 统计
WARNINGS=0
ERRORS=0

# 日志函数
log_info() {
    echo -e "${BLUE}[COMMIT-MSG-HOOK]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[COMMIT-MSG-HOOK]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[COMMIT-MSG-HOOK]${NC} ⚠️  $1"
}

log_error() {
    echo -e "${RED}[COMMIT-MSG-HOOK]${NC} ❌ $1"
}

# 检查提交信息文件是否存在
if [ ! -f "$COMMIT_MSG_FILE" ]; then
    log_error "提交信息文件不存在: $COMMIT_MSG_FILE"
    exit 1
fi

# 读取提交信息
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")
log_info "验证提交信息: $COMMIT_MSG"

# 规则1: 检查提交信息是否为空
if [ -z "$COMMIT_MSG" ]; then
    log_error "提交信息不能为空"
    ((ERRORS++))
fi

# 规则2: 检查提交信息长度
MSG_LENGTH=${#COMMIT_MSG}
if [ $MSG_LENGTH -lt 10 ]; then
    log_warning "提交信息过短 (当前: $MSG_LENGTH 字符，建议至少10字符)"
    ((WARNINGS++))
elif [ $MSG_LENGTH -gt 100 ]; then
    log_warning "提交信息过长 (当前: $MSG_LENGTH 字符，建议不超过100字符)"
    ((WARNINGS++))
fi

# 规则3: 检查是否包含有意义的动词
MEANINGFUL_VERBS=("add" "update" "fix" "remove" "refactor" "optimize" "improve" "create" "delete" "merge" "feat" "fix" "docs" "style" "refactor" "test" "chore")
LOWER_MSG=$(echo "$COMMIT_MSG" | tr '[:upper:]' '[:lower:]')

has_meaningful_verb=false
for verb in "${MEANINGFUL_VERBS[@]}"; do
    if echo "$LOWER_MSG" | grep -q "\b$verb"; then
        has_meaningful_verb=true
        break
    fi
done

if ! $has_meaningful_verb; then
    log_warning "提交信息建议包含有意义的动词 (add/update/fix/remove等)"
    ((WARNINGS++))
fi

# 规则4: 检查是否包含特殊字符开头 (Conventional Commits)
if [[ $COMMIT_MSG =~ ^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: ]]; then
    log_success "检测到Conventional Commits格式"
elif [[ $COMMIT_MSG =~ ^(Merge|Revert|Revert) ]]; then
    log_success "检测到Git自动生成的提交信息"
else
    log_debug "使用传统提交信息格式"
fi

# 规则5: 检查是否包含问题编号 (如 #123, ISSUE-123)
if echo "$COMMIT_MSG" | grep -qE "(#[0-9]+|ISSUE-[0-9]+|BUG-[0-9]+)"; then
    log_success "检测到问题编号引用"
fi

# 规则6: 检查是否包含不当内容
INAPPROPRIATE_WORDS=("fuck" "shit" "damn" "crap" "stupid" "idiot" "moron" "asshole")
for word in "${INAPPROPRIATE_WORDS[@]}"; do
    if echo "$LOWER_MSG" | grep -qi "\b$word\b"; then
        log_error "提交信息包含不当语言: $word"
        ((ERRORS++))
    fi
done

# 规则7: 检查是否以句号结尾
if [[ $COMMIT_MSG =~ \.$ ]]; then
    log_warning "提交信息不应以句号结尾"
    ((WARNINGS++))
fi

# 规则8: 检查是否存在多行提交信息
LINE_COUNT=$(echo "$COMMIT_MSG" | wc -l)
if [ $LINE_COUNT -gt 1 ]; then
    log_info "检测到多行提交信息 ($LINE_COUNT 行)"

    # 检查第二行是否为空
    SECOND_LINE=$(echo "$COMMIT_MSG" | sed -n '2p')
    if [ -n "$SECOND_LINE" ]; then
        log_warning "多行提交信息的第二行应该为空"
        ((WARNINGS++))
    fi

    # 检查正文长度
    BODY_LENGTH=$(echo "$COMMIT_MSG" | sed -n '3,$p' | wc -c)
    if [ $BODY_LENGTH -gt 500 ]; then
        log_warning "提交信息正文过长 (建议不超过500字符)"
        ((WARNINGS++))
    fi
fi

# 生成验证报告
log_info "提交信息验证完成"
echo ""
echo "📊 验证结果:"
echo "   ⚠️  警告: $WARNINGS"
echo "   ❌ 错误: $ERRORS"
echo ""

# 根据严重程度决定是否阻止提交
if [ $ERRORS -gt 0 ]; then
    log_error "发现 $ERRORS 个错误，必须修复后才能提交"
    echo ""
    echo "💡 修复建议:"
    echo "   - 使用描述性的提交信息"
    echo "   - 避免使用不当语言"
    echo "   - 确保信息长度适中"
    echo "   - 考虑使用Conventional Commits格式"
    echo ""
    echo "🔄 重新提交: git commit --amend"
    exit 1
elif [ $WARNINGS -gt 3 ]; then
    log_warning "发现较多警告，建议优化提交信息"
    echo ""
    echo "💡 优化建议:"
    echo "   - 添加更详细的描述"
    echo "   - 使用有意义的动词"
    echo "   - 参考Conventional Commits规范"
    echo ""
    echo "⚡ 强制提交: git commit --no-verify"
elif [ $WARNINGS -gt 0 ]; then
    log_warning "发现 $WARNINGS 个警告，提交将继续进行"
else
    log_success "提交信息验证通过！"
fi

exit 0