#!/bin/bash

# 动态README生成器
# 基于项目状态和规则信息自动生成README.md

set -e

# 配置变量
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
RULES_DIR="${PROJECT_ROOT}/.cursor/rules"
DATA_DIR="${PROJECT_ROOT}/.cursor/data"
OUTPUT_FILE="${PROJECT_ROOT}/README.md"

# 获取动态信息
CURRENT_TIME="$(date '+%Y-%m-%d %H:%M:%S %Z')"
GIT_USER_NAME="$(git config --get user.name 2>/dev/null || echo 'AI协作社区')"
GIT_USER_EMAIL="$(git config --get user.email 2>/dev/null || echo 'community@ai-rules.dev')"
RULE_COUNT="$(find "$RULES_DIR" -name "RULE.md" | wc -l)"
SCRIPT_COUNT="$(find "$RULES_DIR" -name "*.sh" | wc -l)"
TEMPLATE_COUNT="$(find "$RULES_DIR" -name "*.json" | wc -l)"

# 获取最新感知数据
LATEST_PERCEPTION=""
if [ -d "$DATA_DIR" ]; then
    LATEST_PERCEPTION_FILE="$(find "$DATA_DIR" -name "perception_*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)"
    if [ -f "$LATEST_PERCEPTION_FILE" ]; then
        # 提取关键信息
        TECH_STACK="$(grep -o '"tech_stack": "[^"]*"' "$LATEST_PERCEPTION_FILE" 2>/dev/null | head -1 | sed 's/.*"tech_stack": "\(.*\)".*/\1/' || echo '未检测')"
        TEAM_SIZE="$(grep -o '"team_dynamics": "[^"]*"' "$LATEST_PERCEPTION_FILE" 2>/dev/null | head -1 | sed 's/.*"team_dynamics": "\(.*\)".*/\1/' || echo '未检测')"
        PROJECT_SCALE="$(grep -o '"project_scale": "[^"]*"' "$LATEST_PERCEPTION_FILE" 2>/dev/null | head -1 | sed 's/.*"project_scale": "\(.*\)".*/\1/' || echo '未检测')"
    fi
fi

# 扫描规则目录生成规则表格
generate_rules_table() {
    echo "| 规则模块 | 功能描述 | 应用场景 | 状态 |"
    echo "| -------- | -------- | -------- | ---- |"

    # constitution
    if [ -f "$RULES_DIR/constitution/RULE.md" ]; then
        echo "| **constitution** | 🤝 AI共生宪法 | 定义协作核心原则 | ✅ 活跃 |"
    fi

    # philosophy
    if [ -f "$RULES_DIR/philosophy/RULE.md" ]; then
        echo "| **philosophy** | 💬 协作哲学 | 优化沟通和交互模式 | ✅ 活跃 |"
    fi

    # generator
    if [ -f "$RULES_DIR/generator/RULE.md" ]; then
        echo "| **generator** | ⚙️ 系统信息获取器 | 自动化获取环境信息 | ✅ 活跃 |"
    fi

    # intelligent_evolution
    if [ -f "$RULES_DIR/intelligent_evolution/RULE.md" ]; then
        echo "| **intelligent_evolution** | 🧠 智能演进系统 | 自动感知和规则进化 | ✅ 活跃 |"
    fi

    # system_info
    if [ -f "$RULES_DIR/system_info/RULE.md" ]; then
        echo "| **system_info** | 🔧 系统信息测试器 | 路径检测和测试工具 | ✅ 活跃 |"
    fi

    # templates
    if [ -f "$RULES_DIR/templates/RULE.md" ]; then
        echo "| **templates** | 🎨 配置模板 | 规范化项目结构 | ✅ 活跃 |"
    fi
}

# 生成项目状态信息
generate_project_status() {
    if [ -n "$TECH_STACK" ] && [ "$TECH_STACK" != "未检测" ]; then
        echo "### 📊 当前项目状态"
        echo ""
        echo "| 指标 | 状态 |"
        echo "| ---- | ---- |"
        echo "| 🛠️ 技术栈 | $TECH_STACK |"
        echo "| 👥 团队规模 | $TEAM_SIZE |"
        echo "| 📏 项目规模 | $PROJECT_SCALE |"
        echo "| 📈 规则数量 | $RULE_COUNT 个规则 |"
        echo "| 🔧 工具数量 | $SCRIPT_COUNT 个脚本 |"
        echo "| 📋 模板数量 | $TEMPLATE_COUNT 个配置 |"
        echo ""
    fi
}

# 生成智能特性描述
generate_smart_features() {
    echo "### 🧠 智能特性"
    echo ""
    echo "- ✅ **自动感知** - 实时监控项目变化和技术栈演进"
    echo "- ✅ **用户学习** - 分析沟通模式，学习协作偏好"
    echo "- ✅ **自适应调整** - 基于感知数据自动优化规则"
    echo "- ✅ **渐进进化** - 小步快跑，确保平滑过渡"
    if [ -f "$RULES_DIR/intelligent_evolution/perception.sh" ]; then
        echo "- ✅ **感知分析** - 运行 \`./.cursor/rules/intelligent_evolution/perception.sh\` 获取项目洞察"
    fi
    echo ""
}

# 生成新的README.md
cat > "$OUTPUT_FILE" << EOF
# 🤖 Cursor AI Rules

[![Cursor](https://img.shields.io/badge/Cursor-AI-blue)](https://cursor.com)
[![Version](https://img.shields.io/badge/version-2.0.0-green)]()
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)
[![Rules](https://img.shields.io/badge/rules-$RULE_COUNT-blue)]()
[![Scripts](https://img.shields.io/badge/scripts-$SCRIPT_COUNT-orange)]()

> 为Cursor编辑器提供智能、自适应的AI协作规则系统，让AI成为更好的编程伙伴

## ✨ 核心特性

### 🚀 即插即用
\`\`\`bash
# 一键部署到任何项目
./.cursor/cursor-adaptation-setup.sh

# 运行智能感知分析
./.cursor/rules/intelligent_evolution/perception.sh
\`\`\`

### 🧠 智能协作框架
- **🤝 AI共生宪法** - 人机协作的核心原则和最高准则
- **💬 协作哲学** - 智能对话模式和沟通优化
- **📈 智能演进系统** - 自动感知项目变化和用户偏好
- **⚙️ 系统信息获取器** - 自动化获取环境信息和路径检测
- **🎨 配置模板** - 规范化项目结构和初始化配置

$(generate_smart_features)

### 🔧 自适应环境
- 🔍 **自动环境检测** - 获取本地时间、Git信息和项目状态
- 🎯 **智能规则匹配** - 根据项目类型和技术栈自动调整
- 📝 **模板变量替换** - 动态变量系统，开箱即用
- 🛡️ **安全协作保障** - 风险控制和隐私保护
- 📊 **使用统计监控** - 实时感知和性能分析

$(generate_project_status)

## 🎯 快速开始

### 1. 克隆规则包
\`\`\`bash
git clone https://github.com/wangqiqi/cursor-ai-rules.git
cd cursor-ai-rules
\`\`\`

### 2. 部署到你的项目
\`\`\`bash
# 复制到你的项目根目录
cp -r .cursor ~/your-project/

# 进入项目目录
cd ~/your-project

# 运行自动适配脚本
./.cursor/cursor-adaptation-setup.sh
\`\`\`

### 3. 激活智能感知（可选）
\`\`\`bash
# 运行感知分析，了解项目状态
./.cursor/rules/intelligent_evolution/perception.sh

# 查看感知数据
cat .cursor/data/perception_$(date +%Y%m%d).json
\`\`\`

### 4. 开始使用
规则系统自动生效！在Cursor中享受智能的AI协作体验。

## 📋 规则体系

$(generate_rules_table)

## 🚀 主要优势

### 智能环境适配
- **🌍 本地化支持** - 自动适配时区、语言和Git配置
- **👤 用户感知** - 获取Git配置，实现个性化体验
- **🔄 动态调整** - 根据使用习惯和项目变化优化规则

### 团队协作优化
- **👥 多角色支持** - 适应不同团队成员和项目阶段需求
- **📊 协作监控** - 提供效率分析和改进建议
- **🔒 安全保障** - 内置风险评估和隐私保护

### 易用性设计
- **📦 开箱即用** - 无需复杂配置，一键部署
- **🔄 可逆操作** - 支持规则回滚和重置
- **📚 完整文档** - 详细的使用指南和最佳实践
- **🧠 智能进化** - 自动感知和持续改进

## 🎨 使用示例

### 基本协作
\`\`\`
用户: "帮我写一个登录API"
AI: 🤖 基于constitution规则，我需要确认安全要求...
     💡 建议添加JWT认证和输入验证
\`\`\`

### 智能协作
\`\`\`
用户: "这个项目需要重构"
AI: 🧠 根据intelligent_evolution感知，项目规模较大...
     📊 建议分阶段实施，优先处理高风险模块
     ⚡ 基于团队规模调整协作模式
\`\`\`

### 感知驱动协作
\`\`\`
AI: 🔍 检测到项目技术栈变化，自动调整规则...
     📈 启用新的质量检查标准
     🎯 优化代码审查流程
\`\`\`

## 🤝 贡献指南

我们欢迎各种形式的贡献！

### 开发贡献
1. Fork 本仓库
2. 创建特性分支 (\`git checkout -b feature/AmazingFeature\`)
3. 提交更改 (\`git commit -m 'Add some AmazingFeature'\`)
4. 推送到分支 (\`git push origin feature/AmazingFeature\`)
5. 创建 Pull Request

### 规则贡献
- 提出新的协作模式建议
- 分享使用经验和最佳实践
- 参与规则演进讨论
- 贡献感知算法改进

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- [Cursor](https://cursor.com) - 优秀的AI编程环境
- 所有为AI协作规范贡献智慧的开发者们
- 智能演进系统的贡献者们

---

**让AI成为更好的编程伙伴！** 🚀✨

---

*最后更新: $CURRENT_TIME | 作者: $GIT_USER_NAME <$GIT_USER_EMAIL> | 规则版本: 2.0.0*
EOF

echo "✅ README.md 已成功更新！"
echo "📊 包含 $RULE_COUNT 个规则，$SCRIPT_COUNT 个脚本，$TEMPLATE_COUNT 个配置模板"
if [ -n "$TECH_STACK" ] && [ "$TECH_STACK" != "未检测" ]; then
    echo "🧠 已集成感知数据：$TECH_STACK"
fi
