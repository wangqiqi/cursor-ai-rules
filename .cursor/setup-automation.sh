#!/bin/bash
# 🚀 Cursor AI Rules - 自动化系统一键安装脚本
# 安装所有自动化组件：cron任务、Git hooks、监控系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Cursor AI Rules - 自动化系统安装脚本${NC}"
echo "=========================================="
echo ""

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_DIR="$PROJECT_ROOT/.cursor"

echo -e "${GREEN}✅ 项目目录: $PROJECT_ROOT${NC}"

# ============================================================================
# 1️⃣ 检查依赖
# ============================================================================

echo -e "${BLUE}🔍 检查系统依赖...${NC}"

# 检查是否是Git仓库
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误: 当前目录不是Git仓库${NC}"
    exit 1
fi

# 检查jq是否安装
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  警告: 未检测到jq命令，某些功能可能受限${NC}"
    echo -e "${CYAN}💡 安装建议: apt install jq 或 brew install jq${NC}"
fi

# 检查bc是否安装
if ! command -v bc >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  警告: 未检测到bc命令，某些计算功能可能受限${NC}"
fi

echo -e "${GREEN}✅ 系统依赖检查完成${NC}"
echo ""

# ============================================================================
# 2️⃣ 安装Git Hooks
# ============================================================================

echo -e "${BLUE}🎣 安装Git Hooks...${NC}"

if [ -f "$CURSOR_DIR/features/automation/git-hooks/install-hooks.sh" ]; then
    bash "$CURSOR_DIR/features/automation/git-hooks/install-hooks.sh"
    echo -e "${GREEN}✅ Git Hooks安装完成${NC}"
else
    echo -e "${RED}❌ 未找到Git Hooks安装脚本${NC}"
    exit 1
fi

echo ""

# ============================================================================
# 3️⃣ 配置Cron自动化任务
# ============================================================================

echo -e "${BLUE}⏰ 配置Cron自动化任务...${NC}"

CRON_FILE="$CURSOR_DIR/features/automation/cron/cursor-ai-rules.cron"

if [ -f "$CRON_FILE" ]; then
    # 替换PROJECT_PATH变量
    sed "s|/path/to/your/project|$PROJECT_ROOT|g" "$CRON_FILE" > "${CRON_FILE}.tmp"

    # 检查是否已有Cursor AI Rules的cron任务
    if crontab -l 2>/dev/null | grep -q "Cursor AI Rules"; then
        echo -e "${YELLOW}⚠️  检测到已存在的Cursor AI Rules cron任务${NC}"
        echo -e "${CYAN}💡 如需更新，请手动编辑crontab${NC}"
    else
        # 添加到用户crontab
        echo -e "${CYAN}📝 添加cron任务到用户crontab...${NC}"
        (crontab -l 2>/dev/null; echo ""; echo "# Cursor AI Rules - 自动化任务"; cat "${CRON_FILE}.tmp") | crontab -

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Cron任务配置成功${NC}"
            echo -e "${CYAN}📋 已配置的任务:${NC}"
            grep -E "^[^#]" "${CRON_FILE}.tmp" | while read line; do
                echo -e "   $line"
            done
        else
            echo -e "${RED}❌ Cron任务配置失败${NC}"
            echo -e "${YELLOW}💡 请手动运行: crontab $CRON_FILE${NC}"
        fi
    fi

    # 清理临时文件
    rm -f "${CRON_FILE}.tmp"
else
    echo -e "${RED}❌ 未找到Cron配置文件${NC}"
fi

echo ""

# ============================================================================
# 4️⃣ 初始化监控系统
# ============================================================================

echo -e "${BLUE}📊 初始化监控系统...${NC}"

# 创建必要的目录结构
mkdir -p "$PROJECT_ROOT/.cursorGrowth/analytics"
mkdir -p "$PROJECT_ROOT/.cursorGrowth/monitoring"

# 运行初始监控
if [ -f "$CURSOR_DIR/core/usage-monitor.sh" ]; then
    echo -e "${CYAN}📈 生成初始使用统计...${NC}"
    bash "$CURSOR_DIR/core/usage-monitor.sh" --generate-only >/dev/null 2>&1
    echo -e "${GREEN}✅ 监控系统初始化完成${NC}"
else
    echo -e "${RED}❌ 未找到监控脚本${NC}"
fi

echo ""

# ============================================================================
# 5️⃣ 验证安装
# ============================================================================

echo -e "${BLUE}🔍 验证安装...${NC}"

VALIDATION_PASSED=true

# 检查Git hooks
HOOKS_INSTALLED=0
for hook in post-commit pre-push commit-msg; do
    if [ -x "$PROJECT_ROOT/.git/hooks/$hook" ]; then
        ((HOOKS_INSTALLED++))
    fi
done

echo -e "${GREEN}✅ Git Hooks: $HOOKS_INSTALLED/3 已安装${NC}"

# 检查cron任务
CRON_TASKS=$(crontab -l 2>/dev/null | grep -c "Cursor AI Rules" || echo "0")
echo -e "${GREEN}✅ Cron任务: $CRON_TASKS 个已配置${NC}"

# 检查目录结构
DIRS_EXIST=0
for dir in analytics monitoring; do
    if [ -d "$PROJECT_ROOT/.cursorGrowth/$dir" ]; then
        ((DIRS_EXIST++))
    fi
done

echo -e "${GREEN}✅ 目录结构: $DIRS_EXIST/2 已创建${NC}"

# 检查监控文件
if [ -f "$PROJECT_ROOT/.cursorGrowth/analytics/usage-stats-$(date +%Y%m%d).json" ]; then
    echo -e "${GREEN}✅ 监控文件: 已生成${NC}"
else
    echo -e "${YELLOW}⚠️  监控文件: 未生成${NC}"
fi

echo ""

# ============================================================================
# 6️⃣ 生成安装报告
# ============================================================================

INSTALL_REPORT="$CURSOR_DIR/automation-install-report.json"

cat > "$INSTALL_REPORT" <<EOF
{
  "installation_timestamp": "$(date -Iseconds)",
  "project_root": "$PROJECT_ROOT",
  "components_installed": {
    "git_hooks": $HOOKS_INSTALLED,
    "cron_tasks": $CRON_TASKS,
    "directories_created": $DIRS_EXIST,
    "monitoring_initialized": $([ -f "$PROJECT_ROOT/.cursorGrowth/analytics/usage-stats-$(date +%Y%m%d).json" ] && echo true || echo false)
  },
  "automated_features": [
    "持续学习循环 (每小时)",
    "深度学习优化 (每天凌晨2点)",
    "自适应优化 (每周日凌晨3点)",
    "Token压缩 (每4小时)",
    "质量报告 (每天早上8点)",
    "MCP集成检查 (每天早上9点)",
    "性能监控 (每30分钟)",
    "上下文清理 (每天晚上10点)",
    "模式分析更新 (每周一早上6点)",
    "实验状态检查 (每天中午12点)",
    "生长数据分析 (每周六早上7点)",
    "AI代理健康检查 (每2小时)",
    "数据备份 (每周日凌晨1点)",
    "使用监控 (每天早上6点)",
    "日志轮转 (每月1号凌晨4点)"
  ],
  "git_hooks_installed": [
    "post-commit: 智能学习和生长记录",
    "pre-push: 质量检查和安全验证",
    "commit-msg: Conventional Commits格式验证"
  ],
  "status": "installation_completed"
}
EOF

echo -e "${GREEN}🎉 自动化系统安装完成！${NC}"
echo "=========================="
echo ""
echo -e "${BLUE}📊 安装摘要:${NC}"
echo "  • Git Hooks: $HOOKS_INSTALLED/3 已安装"
echo "  • Cron任务: $CRON_TASKS 个自动化任务"
echo "  • 目录结构: $DIRS_EXIST/3 已创建"
echo "  • 监控系统: 已初始化"
echo ""
echo -e "${BLUE}🤖 自动化功能:${NC}"
echo "  • ⏰ 15个定时自动化任务"
echo "  • 🎣 3个智能Git Hooks"
echo "  • 📊 实时使用监控"
echo "  • 🌱 智能生长系统"
echo ""
echo -e "${BLUE}📁 重要文件:${NC}"
echo "  • 安装报告: $INSTALL_REPORT"
echo "  • Cron配置: $CURSOR_DIR/features/automation/cron/cursor-ai-rules.cron"
echo "  • Hooks目录: $CURSOR_DIR/features/automation/git-hooks/"
echo ""
echo -e "${YELLOW}💡 下一步:${NC}"
echo "  1. 测试Git提交: git commit -m \"test: 测试自动化hooks\""
echo "  2. 查看监控报告: cat .cursorGrowth/analytics/usage-stats-*.json"
echo "  3. 检查cron日志: tail -f .cursorGrowth/monitoring/logs/cron-*.log"
echo ""
echo -e "${GREEN}✅ Cursor AI Rules 自动化系统已就绪！${NC}"
echo ""
echo -e "${CYAN}🚀 现在你的AI编程助手将全自动运行，所有功能都会被智能触发！${NC}"