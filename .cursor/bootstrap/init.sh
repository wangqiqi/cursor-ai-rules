#!/bin/bash
# 🚀 Cursor AI Rules - 自适应初始化器
# 自动检测项目环境并配置合适的规则和技能

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$SCRIPT_DIR/../config"
RULES_DIR="$SCRIPT_DIR/../rules"
SKILLS_DIR="$SCRIPT_DIR/../skills"

echo "🚀 Cursor AI Rules - 自适应初始化器"
echo "===================================="
echo "🎯 智能检测项目环境，自动配置AI协作规则"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 全局变量
TECH_STACK=""
TEAM_SIZE="personal"
PROJECT_MATURITY="prototype"
HAS_GIT=false
DETECTED_FEATURES=()

# 1. 环境检测函数
detect_environment() {
    echo "🔍 检测项目环境..."

    # 检查Git
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1 2>/dev/null; then
        HAS_GIT=true
        echo "✅ Git仓库检测: ${GREEN}已启用${NC}"
        DETECTED_FEATURES+=("git")
    else
        echo "⚠️  Git仓库检测: ${YELLOW}未启用${NC}"
    fi

    # 技术栈检测
    detect_tech_stack

    # 团队规模检测
    detect_team_size

    # 项目成熟度检测
    detect_project_maturity

    # 特殊文件检测
    detect_special_files

    echo ""
}

# 技术栈检测
detect_tech_stack() {
    echo "  🛠️  技术栈检测..."

    local detected_techs=()

    # Node.js/JavaScript
    if [ -f "package.json" ]; then
        detected_techs+=("node")
        if grep -q '"react"' package.json 2>/dev/null; then
            detected_techs+=("react")
        fi
        if grep -q '"vue"' package.json 2>/dev/null; then
            detected_techs+=("vue")
        fi
        if grep -q '"typescript"' package.json 2>/dev/null; then
            detected_techs+=("typescript")
        fi
    fi

    # Python
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "Pipfile" ]; then
        detected_techs+=("python")
        if [ -f "requirements.txt" ] && grep -q "django\|flask\|fastapi" requirements.txt 2>/dev/null; then
            detected_techs+=("python-web")
        fi
    fi

    # Go
    if [ -f "go.mod" ] || [ -f "go.sum" ]; then
        detected_techs+=("go")
    fi

    # Rust
    if [ -f "Cargo.toml" ] || [ -f "Cargo.lock" ]; then
        detected_techs+=("rust")
    fi

    # Java
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        detected_techs+=("java")
        if [ -f "pom.xml" ]; then
            detected_techs+=("maven")
        fi
    fi

    # .NET
    if [ -f "*.csproj" ] 2>/dev/null || [ -f "*.fsproj" ] 2>/dev/null || [ -f "*.vbproj" ] 2>/dev/null; then
        detected_techs+=("dotnet")
    fi

    # PHP
    if [ -f "composer.json" ]; then
        detected_techs+=("php")
    fi

    # Ruby
    if [ -f "Gemfile" ]; then
        detected_techs+=("ruby")
    fi

    # 容器化
    if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        detected_techs+=("docker")
    fi

    # 云平台
    if [ -f "serverless.yml" ] || [ -f "serverless.yaml" ]; then
        detected_techs+=("serverless")
    fi

    TECH_STACK=$(IFS=,; echo "${detected_techs[*]}")

    if [ ${#detected_techs[@]} -gt 0 ]; then
        echo "    ✅ 检测到技术栈: ${GREEN}${TECH_STACK}${NC}"
        DETECTED_FEATURES+=("${detected_techs[@]}")
    else
        echo "    ⚠️  未检测到常见技术栈"
    fi
}

# 团队规模检测
detect_team_size() {
    if [ "$HAS_GIT" = true ]; then
        local contributor_count=$(git shortlog -sn --no-merges 2>/dev/null | wc -l)
        local commit_count=$(git log --oneline 2>/dev/null | wc -l)

        if [ "$contributor_count" -gt 5 ] || [ "$commit_count" -gt 100 ]; then
            TEAM_SIZE="enterprise"
            echo "    👥 团队规模: ${GREEN}企业级${NC} (贡献者: $contributor_count, 提交: $commit_count)"
        elif [ "$contributor_count" -gt 2 ] || [ "$commit_count" -gt 20 ]; then
            TEAM_SIZE="team"
            echo "    👥 团队规模: ${GREEN}团队协作${NC} (贡献者: $contributor_count, 提交: $commit_count)"
        else
            TEAM_SIZE="personal"
            echo "    👥 团队规模: ${BLUE}个人开发${NC}"
        fi
    else
        echo "    👥 团队规模: ${BLUE}个人开发${NC} (无Git信息)"
    fi
}

# 项目成熟度检测
detect_project_maturity() {
    local maturity_score=0

    # 代码质量指标
    if [ -d "tests" ] || [ -d "__tests__" ] || [ -d "spec" ] || find . -name "*test*" -type f | grep -q .; then
        ((maturity_score += 2))
        DETECTED_FEATURES+=("testing")
    fi

    if [ -f "README.md" ] || [ -f "README.rst" ] || [ -f "docs/README.md" ]; then
        ((maturity_score += 1))
        DETECTED_FEATURES+=("documentation")
    fi

    # CI/CD指标
    if [ -f ".github/workflows/*.yml" ] || [ -f ".github/workflows/*.yaml" ] || [ -f ".travis.yml" ] || [ -f "Jenkinsfile" ]; then
        ((maturity_score += 2))
        DETECTED_FEATURES+=("ci-cd")
    fi

    # 部署指标
    if [ -f "Dockerfile" ] && [ -f "docker-compose.yml" ]; then
        ((maturity_score += 2))
        DETECTED_FEATURES+=("containerization")
    fi

    if [ -f "deploy.sh" ] || [ -f "deployment/" ] || [ -f "ansible/" ]; then
        ((maturity_score += 1))
        DETECTED_FEATURES+=("deployment")
    fi

    # 架构指标
    if [ -f "architecture.md" ] || [ -f "ARCHITECTURE.md" ] || [ -d "docs/architecture" ]; then
        ((maturity_score += 1))
        DETECTED_FEATURES+=("architecture-docs")
    fi

    # 根据分数判断成熟度
    if [ $maturity_score -ge 6 ]; then
        PROJECT_MATURITY="enterprise"
        echo "    📊 项目成熟度: ${GREEN}企业级${NC} (分数: $maturity_score/8)"
    elif [ $maturity_score -ge 3 ]; then
        PROJECT_MATURITY="development"
        echo "    📊 项目成熟度: ${YELLOW}开发阶段${NC} (分数: $maturity_score/8)"
    else
        PROJECT_MATURITY="prototype"
        echo "    📊 项目成熟度: ${BLUE}原型阶段${NC} (分数: $maturity_score/8)"
    fi
}

# 特殊文件检测
detect_special_files() {
    # 许可证
    if [ -f "LICENSE" ] || [ -f "LICENSE.md" ] || [ -f "COPYING" ]; then
        DETECTED_FEATURES+=("license")
    fi

    # 贡献指南
    if [ -f "CONTRIBUTING.md" ] || [ -f "CONTRIBUTING.rst" ]; then
        DETECTED_FEATURES+=("contributing")
    fi

    # 代码规范
    if [ -f ".eslintrc*" ] || [ -f ".prettierrc*" ] || [ -f "tsconfig.json" ]; then
        DETECTED_FEATURES+=("code-quality")
    fi

    # 安全
    if [ -f ".secrets" ] || [ -f ".env" ] || [ -d "secrets/" ]; then
        DETECTED_FEATURES+=("secrets-management")
    fi
}

# 2. 配置生成
generate_config() {
    echo "⚙️ 生成项目配置..."

    # 获取Git信息
    local author_name="本地用户"
    local author_email="local@example.com"
    local project_name="本地项目"

    if [ "$HAS_GIT" = true ]; then
        author_name=$(git config --get user.name 2>/dev/null || echo "本地用户")
        author_email=$(git config --get user.email 2>/dev/null || echo "local@example.com")
        project_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
    fi

    # 生成项目配置
    cat > "$CONFIG_DIR/project.json" << EOF
{
  "version": "1.0.0",
  "generated_at": "$(date -Iseconds)",
  "generated_by": "$author_name <$author_email>",
  "project": {
    "name": "$project_name",
    "root": "$(pwd)",
    "tech_stack": "$TECH_STACK",
    "team_size": "$TEAM_SIZE",
    "maturity": "$PROJECT_MATURITY",
    "has_git": $HAS_GIT
  },
  "features": {
    "automation": true,
    "skills": true,
    "rules": true,
    "evolution": true
  },
  "detected_features": $(printf '%s\n' "${DETECTED_FEATURES[@]}" | jq -R . | jq -s . 2>/dev/null || echo "[]")
}
EOF

    echo "✅ 项目配置已生成: ${GREEN}$CONFIG_DIR/project.json${NC}"
}

# 3. 规则激活
activate_rules() {
    echo "📋 激活项目规则..."

    local activated_rules=()

    # 核心规则（所有项目）
    for rule in "$RULES_DIR/core/"*.md; do
        if [ -f "$rule" ]; then
            local rule_name=$(basename "$rule")
            ln -sf "../core/$rule_name" "$RULES_DIR/$rule_name" 2>/dev/null || cp "$rule" "$RULES_DIR/$rule_name"
            activated_rules+=("$rule_name")
        fi
    done

    # 技术栈特定规则
    IFS=',' read -ra TECH_ARRAY <<< "$TECH_STACK"
    for tech in "${TECH_ARRAY[@]}"; do
        case $tech in
            node|typescript|react|vue)
                if [ -f "$RULES_DIR/tech/javascript.md" ]; then
                    ln -sf "../tech/javascript.md" "$RULES_DIR/javascript.md" 2>/dev/null || cp "$RULES_DIR/tech/javascript.md" "$RULES_DIR/javascript.md"
                    activated_rules+=("javascript.md")
                fi
                ;;
            python)
                if [ -f "$RULES_DIR/tech/python.md" ]; then
                    ln -sf "../tech/python.md" "$RULES_DIR/python.md" 2>/dev/null || cp "$RULES_DIR/tech/python.md" "$RULES_DIR/python.md"
                    activated_rules+=("python.md")
                fi
                ;;
            go)
                if [ -f "$RULES_DIR/tech/golang.md" ]; then
                    ln -sf "../tech/golang.md" "$RULES_DIR/golang.md" 2>/dev/null || cp "$RULES_DIR/tech/golang.md" "$RULES_DIR/golang.md"
                    activated_rules+=("golang.md")
                fi
                ;;
        esac
    done

    # 团队规模规则
    case $TEAM_SIZE in
        enterprise)
            if [ -f "$RULES_DIR/team/enterprise.md" ]; then
                ln -sf "../team/enterprise.md" "$RULES_DIR/enterprise.md" 2>/dev/null || cp "$RULES_DIR/team/enterprise.md" "$RULES_DIR/enterprise.md"
                activated_rules+=("enterprise.md")
            fi
            ;;
        team)
            if [ -f "$RULES_DIR/team/collaboration.md" ]; then
                ln -sf "../team/collaboration.md" "$RULES_DIR/collaboration.md" 2>/dev/null || cp "$RULES_DIR/team/collaboration.md" "$RULES_DIR/collaboration.md"
                activated_rules+=("collaboration.md")
            fi
            ;;
    esac

    echo "✅ 已激活 ${GREEN}${#activated_rules[@]}${NC} 个规则"
}

# 4. 技能安装
install_skills() {
    echo "🎯 安装适配技能..."

    local installed_skills=()

    # 核心技能（所有项目）
    for skill in "$SKILLS_DIR/core/"*.md; do
        if [ -f "$skill" ]; then
            local skill_name=$(basename "$skill")
            ln -sf "../core/$skill_name" "$SKILLS_DIR/active/$skill_name" 2>/dev/null || cp "$skill" "$SKILLS_DIR/active/$skill_name"
            installed_skills+=("$skill_name")
        fi
    done

    # 技术栈特定技能
    IFS=',' read -ra TECH_ARRAY <<< "$TECH_STACK"
    for tech in "${TECH_ARRAY[@]}"; do
        case $tech in
            node|typescript)
                for skill_file in "$SKILLS_DIR/tech/nodejs-"*.md; do
                    if [ -f "$skill_file" ]; then
                        local skill_name=$(basename "$skill_file")
                        ln -sf "../../tech/$skill_name" "$SKILLS_DIR/active/$skill_name" 2>/dev/null || cp "$skill_file" "$SKILLS_DIR/active/$skill_name"
                        installed_skills+=("$skill_name")
                    fi
                done
                ;;
            react)
                for skill_file in "$SKILLS_DIR/tech/react-"*.md; do
                    if [ -f "$skill_file" ]; then
                        local skill_name=$(basename "$skill_file")
                        ln -sf "../../tech/$skill_name" "$SKILLS_DIR/active/$skill_name" 2>/dev/null || cp "$skill_file" "$SKILLS_DIR/active/$skill_name"
                        installed_skills+=("$skill_name")
                    fi
                done
                ;;
            python)
                for skill_file in "$SKILLS_DIR/tech/python-"*.md; do
                    if [ -f "$skill_file" ]; then
                        local skill_name=$(basename "$skill_file")
                        ln -sf "../../tech/$skill_name" "$SKILLS_DIR/active/$skill_name" 2>/dev/null || cp "$skill_file" "$SKILLS_DIR/active/$skill_name"
                        installed_skills+=("$skill_name")
                    fi
                done
                ;;
        esac
    done

    echo "✅ 已安装 ${GREEN}${#installed_skills[@]}${NC} 个技能"
}

# 5. 钩子配置
setup_hooks() {
    echo "🔗 配置自动化钩子..."

    # 根据项目特性配置钩子
    local hooks_config='{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": ".cursor/automation/hooks/code-quality.sh"
      }
    ],
    "beforeShellExecution": [
      {
        "command": ".cursor/automation/hooks/security-audit.sh"
      }
    ]'

    # 根据团队规模添加更多钩子
    if [ "$TEAM_SIZE" != "personal" ]; then
        hooks_config="$hooks_config"',$NL    "afterAgentResponse": [
      {
        "command": ".cursor/automation/hooks/rule-usage-tracker.sh"
      }
    ]'
    fi

    # 根据成熟度添加钩子
    if [ "$PROJECT_MATURITY" = "enterprise" ]; then
        hooks_config="$hooks_config"',$NL    "beforeSubmitPrompt": [
      {
        "command": ".cursor/automation/hooks/prompt-security.sh"
      }
    ]'
    fi

    hooks_config="$hooks_config"',$NL    "stop": [
      {
        "command": ".cursor/automation/hooks/session-summary.sh"
      }
    ]
  }
}'

    # 格式化并保存
    echo "$hooks_config" | sed 's/\$NL/\n      /g' > "$SCRIPT_DIR/../automation/config.json"

    echo "✅ 钩子配置已生成: ${GREEN}.cursor/automation/config.json${NC}"
}

# 6. 创建项目摘要
create_summary() {
    echo ""
    echo "🎉 初始化完成！"
    echo "=================="
    echo ""
    echo "📊 项目概况:"
    echo "  🛠️  技术栈: ${GREEN}${TECH_STACK:-"未检测到"}${NC}"
    echo "  👥 团队规模: ${GREEN}$TEAM_SIZE${NC}"
    echo "  📈 项目成熟度: ${GREEN}$PROJECT_MATURITY${NC}"
    echo "  🔧 检测到特性: ${GREEN}${#DETECTED_FEATURES[@]}${NC} 个"
    echo ""
    echo "📁 激活的规则和技能已自动配置"
    echo "⚙️  配置文件: ${BLUE}.cursor/config/project.json${NC}"
    echo "🔗 钩子配置: ${BLUE}.cursor/automation/config.json${NC}"
    echo ""
    echo "💡 提示: 运行 ${YELLOW}.cursor/automation/scripts/env-check.sh${NC} 查看详细状态"
}

# 主函数
main() {
    cd "$PROJECT_ROOT" 2>/dev/null || true

    detect_environment
    generate_config
    activate_rules
    install_skills
    setup_hooks
    create_summary
}

# 检查是否直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi