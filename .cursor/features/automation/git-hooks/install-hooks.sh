#!/bin/bash
# 🚀 Cursor AI Rules - Git Hooks 安装脚本
# 自动安装智能Git hooks到项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取项目根目录
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CURSOR_DIR="$PROJECT_ROOT/.cursor"
HOOKS_DIR="$CURSOR_DIR/features/automation/git-hooks"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo -e "${BLUE}🚀 Cursor AI Rules - Git Hooks 安装脚本${NC}"
echo "=========================================="
echo ""

# 检查是否是Git仓库
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误: 当前目录不是Git仓库${NC}"
    echo -e "${YELLOW}💡 请在Git项目根目录下运行此脚本${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 检测到Git仓库: $PROJECT_ROOT${NC}"

# 检查hooks目录是否存在
if [ ! -d "$HOOKS_DIR" ]; then
    echo -e "${RED}❌ 错误: 未找到hooks目录: $HOOKS_DIR${NC}"
    exit 1
fi

# 创建.git/hooks目录（如果不存在）
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo -e "${YELLOW}📁 创建Git hooks目录...${NC}"
    mkdir -p "$GIT_HOOKS_DIR"
fi

# 备份现有hooks
BACKUP_DIR="$GIT_HOOKS_DIR/backup-$(date +%Y%m%d_%H%M%S)"
if [ -f "$GIT_HOOKS_DIR/pre-commit" ] || [ -f "$GIT_HOOKS_DIR/commit-msg" ] || [ -f "$GIT_HOOKS_DIR/post-commit" ] || [ -f "$GIT_HOOKS_DIR/pre-push" ]; then
    echo -e "${YELLOW}📦 备份现有hooks到: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    cp "$GIT_HOOKS_DIR"/* "$BACKUP_DIR"/ 2>/dev/null || true
fi

# 安装智能hooks
HOOKS_INSTALLED=0

# 1. 安装post-commit hook
if [ -f "$HOOKS_DIR/post-commit" ]; then
    echo -e "${BLUE}📝 安装post-commit hook...${NC}"
    cp "$HOOKS_DIR/post-commit" "$GIT_HOOKS_DIR/post-commit"
    chmod +x "$GIT_HOOKS_DIR/post-commit"
    echo -e "${GREEN}✅ post-commit hook 已安装${NC}"
    ((HOOKS_INSTALLED++))
fi

# 2. 安装pre-push hook
if [ -f "$HOOKS_DIR/pre-push" ]; then
    echo -e "${BLUE}🛡️ 安装pre-push hook...${NC}"
    cp "$HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo -e "${GREEN}✅ pre-push hook 已安装${NC}"
    ((HOOKS_INSTALLED++))
fi

# 3. 检查是否需要创建commit-msg hook (用于Conventional Commits)
if [ ! -f "$GIT_HOOKS_DIR/commit-msg" ]; then
    echo -e "${BLUE}📝 创建commit-msg hook (Conventional Commits)...${NC}"
    cat > "$GIT_HOOKS_DIR/commit-msg" << 'EOF'
#!/bin/bash
# Conventional Commits 格式检查

# 允许通过--no-verify跳过检查
if [[ "$2" == "commit" ]] && [[ "$*" == *"--no-verify"* ]]; then
    exit 0
fi

# 简单的格式检查
commit_msg=$(cat "$1")
if ! echo "$commit_msg" | grep -qP '^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([a-zA-Z0-9_-]+\))?: .{1,}'; then
    echo "❌ 提交消息不符合Conventional Commits格式"
    echo "正确格式: type(scope): description"
    echo "示例: feat(user): add login functionality"
    echo ""
    echo "使用 --no-verify 跳过此检查"
    exit 1
fi

exit 0
EOF
    chmod +x "$GIT_HOOKS_DIR/commit-msg"
    echo -e "${GREEN}✅ commit-msg hook 已创建${NC}"
    ((HOOKS_INSTALLED++))
fi

# 验证安装
echo ""
echo -e "${BLUE}🔍 验证安装...${NC}"

INSTALLED_HOOKS=0
for hook in post-commit pre-push commit-msg; do
    if [ -x "$GIT_HOOKS_DIR/$hook" ]; then
        echo -e "${GREEN}✅ $hook hook: 已安装${NC}"
        ((INSTALLED_HOOKS++))
    else
        echo -e "${RED}❌ $hook hook: 安装失败${NC}"
    fi
done

# 创建hooks状态文件
HOOKS_STATUS_FILE="$CURSOR_DIR/git-hooks/status.json"
mkdir -p "$(dirname "$HOOKS_STATUS_FILE")"

cat > "$HOOKS_STATUS_FILE" <<EOF
{
  "installed_at": "$(date -Iseconds)",
  "project_root": "$PROJECT_ROOT",
  "hooks_installed": $INSTALLED_HOOKS,
  "backup_location": "$BACKUP_DIR",
  "hooks_list": [
    "post-commit",
    "pre-push",
    "commit-msg"
  ],
  "features": [
    "智能学习记录",
    "质量检查",
    "Conventional Commits验证",
    "AI代理健康检查",
    "性能监控"
  ]
}
EOF

echo ""
echo -e "${GREEN}🎉 Git Hooks 安装完成！${NC}"
echo "=========================="
echo ""
echo -e "${BLUE}📊 安装统计:${NC}"
echo "  • 已安装hooks: $INSTALLED_HOOKS 个"
echo "  • 备份位置: $BACKUP_DIR"
echo "  • 状态文件: $HOOKS_STATUS_FILE"
echo ""
echo -e "${BLUE}🚀 智能功能:${NC}"
echo "  • 📈 Post-commit: 自动学习和生长记录"
echo "  • 🛡️ Pre-push: 质量检查和安全验证"
echo "  • 📝 Commit-msg: Conventional Commits格式验证"
echo ""
echo -e "${YELLOW}💡 使用提示:${NC}"
echo "  • 跳过检查: git commit --no-verify"
echo "  • 查看日志: $PROJECT_ROOT/.cursorGrowth/monitoring/logs/"
echo "  • 卸载hooks: rm $GIT_HOOKS_DIR/post-commit $GIT_HOOKS_DIR/pre-push"
echo ""
echo -e "${GREEN}✅ Cursor AI Rules Git Hooks 已就绪！${NC}"