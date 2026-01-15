---
command: master
description: "🎯 总命令控制器 - 统一调用.cursor目录下的所有规则和脚本命令 | 包含完整的文档和执行脚本"
alwaysApply: false
---

# 🎯 总命令控制器 (Master Command Controller)

*版本: v2.0.0 | 最后更新: 2026-01-15 | 作者: AI共生系统*

## 📋 功能概述

总命令控制器是 `.cursor` 目录的统一入口，提供以下功能：

- 🔍 **命令查询**: 列出所有可用的规则和脚本命令
- 🚀 **一键执行**: 直接调用任意子命令
- 📖 **帮助系统**: 提供详细的命令使用说明
- 🔄 **状态检查**: 查看各组件的运行状态
- 💻 **内置脚本**: 集成完整的bash执行环境

## 🛠️ 使用方法

### 基本语法

```bash
# 列出所有可用命令
@master

# 列出所有可用命令（详细模式）
@master list

# 执行指定规则命令
@master rule <command_name>

# 执行指定脚本命令
@master script <script_name>

# 查看帮助信息
@master help

# 查看特定命令的详细信息
@master help <command_name>
```

### 命令行脚本使用

如果您更喜欢使用命令行脚本，也可以直接运行：

```bash
# 显示所有可用命令
./cursor-master.sh

# 显示详细命令列表
./cursor-master.sh list

# 查看帮助信息
./cursor-master.sh help

# 执行规则命令
./cursor-master.sh rule constitution

# 执行脚本命令
./cursor-master.sh script env_check
```

## 📚 可用规则命令 (Rules)

以下是 `.cursor/rules/` 目录下的所有规则命令：

| 命令 | 描述 | 状态 |
|------|------|------|
| `constitution` | AI共生宪法 - 定义人机协作的核心原则和最高准则 | ✅ 总是启用 |
| `conversation_intent_analyzer` | 对话意图分析器 - 基于用户对话内容理解需求并提供项目规划建议 | ✅ 总是启用 |
| `eslint` | ESLint代码质量检查集成 - 自动检测和修复JavaScript代码问题 | ✅ 总是启用 |
| `evolution-automation` | 自动化演进系统 - 基于感知数据的智能规则自动优化 | 🔄 按需启用 |
| `evolution-governance` | 演进治理机制 - 规则演进的安全保障和质量控制体系 | 🔄 按需启用 |
| `evolution-manual` | 手动演进流程 - 规则演进的手动触发和管理流程 | 🔄 按需启用 |
| `evolution-philosophy` | 演进哲学 - 项目规则持续演进的核心理念和原则指导 | 🔄 按需启用 |
| `generator` | 项目规则生成器 - 自动化生成个性化项目规则配置 | 🔄 按需启用 |
| `i18n` | 国际化支持系统 - 自动检测用户语言偏好并切换沟通和注释语言 | ✅ 总是启用 |
| `intelligent_evolution` | 智能演进系统入口 - 规则演进的统一入口和协调器 | 🔄 按需启用 |
| `module_manager` | 规则管理系统 - 管理.cursor规则的依赖关系、激活控制和扩展机制 | ✅ 总是启用 |
| `philosophy` | 交流哲学与协作模式 - 定义人机协作的沟通准则和协作模式 | ✅ 总是启用 |
| `platform_adapter` | 跨平台适配器 - 统一管理不同操作系统间的命令、路径和环境适配 | ✅ 总是启用 |
| `system_info` | 系统信息获取器 - 自动获取时间、路径和作者信息的通用机制 | ✅ 总是启用 |
| `templates` | 项目配置模板框架 - 自动化生成项目初始化配置 | 🔄 按需启用 |

## 🔧 可用脚本命令 (Scripts)

以下是 `.cursor/scripts/` 目录下的所有可执行脚本：

| 脚本 | 描述 | 执行方式 |
|------|------|----------|
| `check.sh` | 代码质量检查脚本 | `bash .cursor/scripts/check.sh` |
| `enable.sh` | 插件启用脚本 | `bash .cursor/scripts/enable.sh` |
| `env_check.sh` | 环境依赖检查脚本 | `bash .cursor/scripts/env_check.sh` |
| `growth_init.sh` | 项目增长初始化脚本 | `bash .cursor/scripts/growth_init.sh` |
| `perception.sh` | 智能感知分析脚本 | `bash .cursor/scripts/perception.sh` |
| `plugin_manager.sh` | 插件管理系统脚本 | `bash .cursor/scripts/plugin_manager.sh` |

## 🎯 快速操作指南

### 常用组合命令

```bash
# 初始化新项目环境
@master script enable.sh    # 启用基础插件
@master script env_check.sh # 检查环境依赖
@master rule generator      # 生成项目规则

# 代码质量检查
@master script check.sh     # 运行代码检查
@master rule eslint         # 启用ESLint检查

# 智能演进管理
@master script perception.sh    # 运行感知分析
@master rule intelligent_evolution  # 启用智能演进
```

### 项目启动流程

对于新项目，建议按以下顺序执行：

1. **环境准备**
   ```bash
   @master script env_check.sh  # 检查环境依赖
   @master script enable.sh     # 启用必要插件
   ```

2. **规则配置**
   ```bash
   @master rule generator       # 生成个性化规则
   @master rule constitution    # 确认协作原则
   ```

3. **质量保障**
   ```bash
   @master rule eslint         # 启用代码检查
   @master script check.sh     # 执行首次检查
   ```

## 🚀 内置执行脚本

```bash
#!/bin/bash

# 🎯 Cursor AI 总命令控制器
# 统一调用 .cursor 目录下的所有规则和脚本命令
#
# 使用方法:
#   ./cursor-master.sh              # 显示所有可用命令
#   ./cursor-master.sh list         # 显示所有可用命令（详细）
#   ./cursor-master.sh rule <name>  # 执行指定规则命令
#   ./cursor-master.sh script <name> # 执行指定脚本
#   ./cursor-master.sh help         # 显示帮助信息

set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$SCRIPT_DIR/.cursor"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示Logo
show_logo() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                🎯 Cursor AI 总命令控制器                     ║"
    echo "║                                                              ║"
    echo "║              统一管理 .cursor 规则和脚本                     ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查 .cursor 目录是否存在
check_cursor_dir() {
    if [ ! -d "$CURSOR_DIR" ]; then
        echo -e "${RED}❌ 错误: 未找到 .cursor 目录 ($CURSOR_DIR)${NC}"
        echo -e "${YELLOW}💡 请确保在正确的项目根目录下运行此脚本${NC}"
        exit 1
    fi
}

# 获取所有可用的规则命令
get_available_rules() {
    local rules_dir="$CURSOR_DIR/rules"
    local rules_list=""

    if [ -d "$rules_dir" ]; then
        for rule_file in "$rules_dir"/*.md; do
            if [ -f "$rule_file" ]; then
                local filename=$(basename "$rule_file" .md)
                # 提取YAML front matter中的字段
                local content=$(head -10 "$rule_file")
                local command=$(echo "$content" | grep "^command:" | head -1 | sed 's/command: //' | tr -d '"' | xargs)
                local description=$(echo "$content" | grep "^description:" | head -1 | sed 's/description: //' | tr -d '"' | xargs)
                local always_apply=$(echo "$content" | grep "^alwaysApply:" | head -1 | sed 's/alwaysApply: //' | xargs)

                if [ -n "$command" ] && [ -n "$description" ] && [ -n "$always_apply" ]; then
                    rules_list="$rules_list$command|$description|$always_apply\n"
                fi
            fi
        done
    fi

    echo -e "$rules_list"
}

# 获取所有可用的脚本命令
get_available_scripts() {
    local scripts_dir="$CURSOR_DIR/scripts"
    local scripts_list=""

    if [ -d "$scripts_dir" ]; then
        for script_file in "$scripts_dir"/*.sh; do
            if [ -f "$script_file" ] && [ -x "$script_file" ]; then
                local filename=$(basename "$script_file" .sh)
                scripts_list="$scripts_list|$filename"
            fi
        done
    fi

    echo "$scripts_list"
}

# 显示所有可用命令
show_commands() {
    local detailed=${1:-false}

    echo -e "${BLUE}📚 可用规则命令 (Rules):${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local rules=$(get_available_rules)
    if [ -n "$rules" ]; then
        echo -e "$rules" | while IFS='|' read -r command description always_apply; do
            if [ -n "$command" ] && [ -n "$description" ]; then
                if [ "$always_apply" = "true" ]; then
                    echo -e "  ✅ ${GREEN}$command${NC} - $description"
                else
                    echo -e "  🔄 ${YELLOW}$command${NC} - $description"
                fi
            fi
        done
    else
        echo -e "  ${RED}❌ 未找到规则文件${NC}"
    fi

    echo
    echo -e "${PURPLE}🔧 可用脚本命令 (Scripts):${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local scripts=$(get_available_scripts)
    if [ -n "$scripts" ]; then
        echo "$scripts" | tr '|' '\n' | while read -r script_name; do
            if [ -n "$script_name" ]; then
                echo -e "  🚀 ${CYAN}$script_name${NC} - 执行 $script_name 脚本"
            fi
        done
    else
        echo -e "  ${RED}❌ 未找到脚本文件${NC}"
    fi

    if [ "$detailed" = "true" ]; then
        echo
        echo -e "${YELLOW}💡 使用提示:${NC}"
        echo "  • 规则命令: ./cursor-master.sh rule <command_name>"
        echo "  • 脚本命令: ./cursor-master.sh script <script_name>"
        echo "  • 查看帮助: ./cursor-master.sh help"
    fi
}

# 执行规则命令
execute_rule() {
    local rule_name="$1"

    if [ -z "$rule_name" ]; then
        echo -e "${RED}❌ 错误: 请指定要执行的规则命令名${NC}"
        echo -e "${YELLOW}💡 示例: ./cursor-master.sh rule constitution${NC}"
        exit 1
    fi

    local rule_file="$CURSOR_DIR/rules/${rule_name}.md"

    if [ ! -f "$rule_file" ]; then
        echo -e "${RED}❌ 错误: 未找到规则文件 '$rule_file'${NC}"
        echo -e "${YELLOW}💡 运行 './cursor-master.sh list' 查看所有可用规则${NC}"
        exit 1
    fi

    echo -e "${GREEN}🚀 执行规则命令: ${CYAN}$rule_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 这里可以根据规则文件的格式来执行相应的逻辑
    # 目前只是显示规则文件内容作为示例
    echo -e "${YELLOW}📖 规则文件内容预览:${NC}"
    head -20 "$rule_file"

    echo
    echo -e "${GREEN}✅ 规则 '$rule_name' 已加载${NC}"
}

# 执行脚本命令
execute_script() {
    local script_name="$1"

    if [ -z "$script_name" ]; then
        echo -e "${RED}❌ 错误: 请指定要执行的脚本名${NC}"
        echo -e "${YELLOW}💡 示例: ./cursor-master.sh script enable.sh${NC}"
        exit 1
    fi

    local script_file="$CURSOR_DIR/scripts/${script_name}"

    if [ ! -f "$script_file" ]; then
        script_file="$CURSOR_DIR/scripts/${script_name}.sh"
    fi

    if [ ! -f "$script_file" ]; then
        echo -e "${RED}❌ 错误: 未找到脚本文件 '$script_file'${NC}"
        echo -e "${YELLOW}💡 运行 './cursor-master.sh list' 查看所有可用脚本${NC}"
        exit 1
    fi

    if [ ! -x "$script_file" ]; then
        echo -e "${YELLOW}⚠️  脚本文件没有执行权限，正在设置...${NC}"
        chmod +x "$script_file"
    fi

    echo -e "${GREEN}🚀 执行脚本命令: ${CYAN}$script_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 执行脚本
    if bash "$script_file"; then
        echo
        echo -e "${GREEN}✅ 脚本 '$script_name' 执行成功${NC}"
    else
        echo
        echo -e "${RED}❌ 脚本 '$script_name' 执行失败${NC}"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}🎯 Cursor AI 总命令控制器 - 使用帮助${NC}"
    echo
    echo -e "${YELLOW}基本用法:${NC}"
    echo "  ./cursor-master.sh              # 显示所有可用命令"
    echo "  ./cursor-master.sh list         # 显示所有可用命令（详细）"
    echo "  ./cursor-master.sh rule <name>  # 执行指定规则命令"
    echo "  ./cursor-master.sh script <name> # 执行指定脚本"
    echo "  ./cursor-master.sh help         # 显示此帮助信息"
    echo
    echo -e "${YELLOW}示例:${NC}"
    echo "  ./cursor-master.sh rule constitution     # 执行宪法规则"
    echo "  ./cursor-master.sh script enable.sh      # 运行启用脚本"
    echo "  ./cursor-master.sh script check.sh       # 运行代码检查"
    echo
    echo -e "${YELLOW}快速操作:${NC}"
    echo "  # 初始化新项目"
    echo "  ./cursor-master.sh script enable.sh"
    echo "  ./cursor-master.sh script env_check.sh"
    echo "  ./cursor-master.sh rule generator"
    echo
    echo "  # 代码质量检查"
    echo "  ./cursor-master.sh script check.sh"
    echo "  ./cursor-master.sh rule eslint"
}

# 主函数
main() {
    check_cursor_dir

    case "${1:-}" in
        "")
            show_logo
            show_commands
            ;;
        "list")
            show_logo
            show_commands true
            ;;
        "rule")
            execute_rule "$2"
            ;;
        "script")
            execute_script "$2"
            ;;
        "help"|"-h"|"--help")
            show_logo
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $1${NC}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
```

## 🔍 命令状态监控

### 规则状态说明

- ✅ **总是启用 (alwaysApply: true)**: 这些规则会自动应用于所有相关文件
- 🔄 **按需启用 (alwaysApply: false)**: 需要手动调用或满足特定条件才会激活

### 脚本执行状态

脚本命令会返回执行结果，成功时显示 ✅，失败时显示 ❌ 并提供错误信息。

## 🚀 高级用法

### 批处理执行

```bash
# 连续执行多个命令（需要在支持的环境中使用）
@master rule eslint && @master script check.sh
```

### 条件执行

```bash
# 仅在特定文件类型存在时执行
if [ -f "package.json" ]; then
    @master rule eslint
fi
```

## 📖 规则文件说明

总命令控制器基于 `.cursor/rules/` 目录下的规则文件工作：

- 每个 `.md` 文件都是一个规则
- 文件顶部包含 YAML front matter 定义命令信息
- 支持 `command`, `description`, `alwaysApply` 等字段

## 🔍 故障排除

### 脚本无法执行

```bash
# 确保脚本有执行权限
chmod +x cursor-master.sh

# 检查文件是否存在
ls -la cursor-master.sh
```

### 规则文件不存在

```bash
# 检查 .cursor 目录结构
ls -la .cursor/

# 确认规则文件存在
ls -la .cursor/rules/
```

### 脚本执行失败

```bash
# 查看详细错误信息
./cursor-master.sh script <script_name>

# 检查脚本权限
ls -la .cursor/scripts/
```

## ❓ 帮助与支持

### 获取帮助

```bash
@master help          # 显示总帮助信息
@master help <命令名>  # 显示特定命令的详细帮助
```

### 故障排除

如果遇到问题：

1. 运行 `@master list` 检查所有命令是否可用
2. 运行 `@master script env_check.sh` 检查环境依赖
3. 查看具体的错误信息并参考对应命令的文档

## 🤝 贡献

如果您想添加新的规则或脚本：

1. 在 `.cursor/rules/` 下添加新的 `.md` 规则文件
2. 在 `.cursor/scripts/` 下添加新的 `.sh` 脚本文件
3. 确保脚本有执行权限：`chmod +x script.sh`
4. 总命令控制器会自动识别并显示新命令

---

*💡 提示：总命令控制器让您可以从项目根目录统一管理所有.cursor功能，无需记忆复杂的路径和命令语法。通过 @master 命令或 ./cursor-master.sh 脚本，您可以轻松访问所有功能！*