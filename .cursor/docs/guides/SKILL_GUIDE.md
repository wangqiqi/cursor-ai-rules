# .cursor 技能系统使用指南

## 📚 目录

1. [技能系统概述](#技能系统概述)
2. [两个Skills目录的区别](#两个skills目录的区别)
3. [技能注册表](#技能注册表)
4. [技能分类详解](#技能分类详解)
5. [技能使用方法](#技能使用方法)
6. [技能开发指南](#技能开发指南)
7. [常见问题](#常见问题)

---

## 技能系统概述

### 什么是技能?

技能(Skill)是可重用的专业知识包,包含特定领域的最佳实践、工作流程和解决方案。

### 技能系统架构

```
.cursor/
├── skills/                    # 项目特定技能
│   └── skill-dispatcher/      # 技能调度器
└── features/                  # 跨项目共享功能
    └── skills/                # 技能库 (37个技能)
        ├── registry.json      # 技能注册表
        ├── api-design.md      # API设计技能
        ├── backend-development.md
        └── ... (35+ 技能文件)
```

---

## 两个Skills目录的区别

### `.cursor/skills/` - 项目技能

**定位**: 项目特定的技能定义

**作用域**: 当前项目（可复制到任意项目后独立演化）

**格式**: 符合 [Cursor Agent Skills](https://cursor.com/cn/docs/context/skills) 标准（每技能一个文件夹，含 SKILL.md）

**特点**:
- 为本项目定制
- 可能不适合其他项目
- 管理项目特定的专业知识

**当前内容**:

```
.cursor/skills/
└── skill-dispatcher/          # 技能调度器
    ├── SKILL.md              # 技能定义
    ├── README.md             # 使用说明
    ├── reference.md          # 参考文档
    ├── examples.md           # 使用示例
    └── scripts/
        └── list-skills.sh    # 列出技能脚本
```

**skill-dispatcher 功能**:
- 发现 `.cursor/features/skills/` 中的技能
- 智能匹配最适合的技能
- 管理技能调用和执行
- 检查技能依赖

---

### `.cursor/features/skills/` - 技能库

**定位**: 可跨项目共享的通用技能库

**格式**: 自定义扩展（flat .md 文件 + registry.json），由 skill-dispatcher 统一调度。非 Cursor 官方「每技能一文件夹」格式。

**作用域**: 可以在任何项目中使用

**特点**:
- 高度可重用
- 通用的最佳实践
- 跨项目一致性
- 可独立维护和更新

**当前内容**: 37个专业技能

---

## 为什么有两个目录?

### 设计理念

```
.cursor/skills/              ← 项目层
    (管理这个项目的技能)
        ↓ 调度
        ↓
.cursor/features/skills/    ← 库层
    (提供通用的技能)
```

### 职责分离

| 方面 | 项目技能 (`.cursor/skills/`) | 技能库 (`.cursor/features/skills/`) |
|------|------------------------------|-------------------------------------|
| **作用域** | 当前项目 | 跨项目 |
| **可重用性** | 项目特定 | 高度可重用 |
| **维护** | 项目维护 | 独立维护 |
| **数量** | 1个 (skill-dispatcher) | 37个 |
| **用途** | 管理技能系统 | 提供专业知识 |
| **示例** | skill-dispatcher | api-design, backend-development |

### 调用关系

```
用户请求技能
    ↓
command-center (Agent)
    ↓
skill-dispatcher (项目技能)
    ↓
读取 registry.json
    ↓
匹配并加载
    ↓
.cursor/features/skills/* (库技能)
    ↓
应用专业知识
```

---

## 技能注册表

### registry.json

**位置**: `.cursor/features/skills/registry.json`

**版本**: 2.0.0

**结构**:

```json
{
  "version": "2.0.0",
  "last_updated": "2026-01-15",
  "description": "Cursor AI Rules 技能注册表 - 合并了agent和legacy技能",
  "skills": {
    "legacy": {
      "[skill-id]": {
        "name": "技能名称",
        "description": "技能描述",
        "category": "分类",
        "auto_install": true/false,
        "path": "skill-file.md",
        "dependencies": [],
        "source": "cursor-ai-rules|anthropic-skills|reference"
      }
    }
  },
  "categories": {
    "[category]": ["skill-id-1", "skill-id-2"]
  },
  "auto_install_rules": {
    "always": ["skill-creator"],
    "by_tech_stack": {},
    "by_tools": {},
    "by_workflow": {}
  },
  "compatibility_matrix": {
    "skill_dependencies": {},
    "conflicts": {}
  }
}
```

### 关键字段说明

- **name**: 技能显示名称
- **description**: 技能功能描述
- **category**: 技能分类
- **auto_install**: 是否自动安装
- **dependencies**: 依赖的技术栈或工具
- **source**: 技能来源

---

## 技能分类详解

### Development (开发) - 5个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| api-design | API设计 | RESTful、GraphQL API设计 | ✅ |
| backend-development | 后端开发 | 后端系统设计和开发 | ✅ |
| fullstack-development | 全栈开发 | 前后端全栈开发指导 | ✅ |
| web-artifacts-builder | Web工件构建 | React+Tailwind组件构建 | ❌ |
| debug-assistant | 智能调试助手 | 使用隔离和模式分析的调试 | ❌ |

**使用场景**:
- 架构设计
- API开发
- 代码实现
- 调试问题

---

### Testing (测试) - 4个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| api-testing | API测试 | API测试和验证 | ✅ |
| test-automation | 测试自动化 | 自动化测试框架 | ✅ |
| webapp-testing | Web应用测试 | Playwright测试 | ❌ |
| evaluation | 技能评估框架 | MCP技能质量评估 | ❌ |

**使用场景**:
- 编写测试用例
- 自动化测试
- 端到端测试

---

### Security (安全) - 2个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| security-analysis | 安全分析 | 代码安全漏洞检测 | ✅ |
| vulnerability-scanning | 漏洞扫描 | 安全漏洞扫描 | ✅ |

**使用场景**:
- 代码安全审计
- 漏洞检测
- 安全最佳实践

---

### Analysis (分析) - 3个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| code-analysis | 代码分析 | 智能代码分析 | ✅ |
| performance-analysis | 性能分析 | 应用性能分析 | ✅ |
| system-analysis | 系统分析 | 系统架构分析 | ✅ |

**使用场景**:
- 代码质量分析
- 性能优化
- 架构审查

---

### Optimization (优化) - 3个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| optimization-tools | 优化工具 | 代码和性能优化 | ✅ |
| refactoring-tools | 重构工具 | 代码重构 | ✅ |
| ssr-optimization | SSR优化 | 服务器端渲染优化 | ❌ |

**使用场景**:
- 代码优化
- 性能调优
- 重构项目

---

### Documentation (文档) - 8个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| documentation-tools | 文档工具 | 文档生成和维护 | ✅ |
| docx | Word文档 | Microsoft Word处理 | ❌ |
| pdf | PDF文档 | PDF处理 | ❌ |
| pptx | PowerPoint | 演示文稿 | ❌ |
| xlsx | Excel | 电子表格 | ❌ |
| mcp-specification | MCP规范 | MCP协议文档 | ❌ |
| python-sdk-README | Python SDK | Python SDK指南 | ❌ |
| typescript-sdk-README | TypeScript SDK | TypeScript SDK指南 | ❌ |

**使用场景**:
- 生成文档
- 处理Office文档
- 学习SDK使用

---

### Design (设计) - 4个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| canvas-design | 画布设计 | 基于画布的设计 | ❌ |
| frontend-design | 前端设计 | 前端界面设计 | ❌ |
| theme-factory | 主题工厂 | 主题创建和管理 | ❌ |
| brand-guidelines | 品牌指南 | 品牌规范 | ❌ |

**使用场景**:
- UI/UX设计
- 主题定制
- 品牌应用

---

### Learning (学习) - 2个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| learning-assistant | 学习助手 | 编程学习助手 | ✅ |
| code-examples | 代码示例 | 代码示例库 | ✅ |

**使用场景**:
- 学习新技术
- 查找代码示例
- 技能提升

---

### Collaboration (协作) - 3个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| git-management | Git管理 | Git版本控制 | ✅ |
| doc-coauthoring | 文档协作 | 文档协作 | ❌ |
| internal-comms | 内部通讯 | 团队通讯 | ❌ |

**使用场景**:
- Git工作流
- 团队协作
- 文档协作

---

### AI Integration (AI集成) - 3个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| mcp-builder | MCP构建器 | MCP服务器开发 | ❌ |
| skill-creator | 技能创建器 | AI技能开发 | ✅ |
| node_mcp_server | Node.js MCP | Node.js MCP框架 | ❌ |
| python_mcp_server | Python MCP | Python MCP框架 | ❌ |

**使用场景**:
- 开发MCP服务器
- 创建新技能
- AI集成

---

### Creative (创意) - 2个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| algorithmic-art | 算法艺术 | p5.js算法艺术 | ❌ |
| slack-gif-creator | Slack GIF | GIF创建 | ❌ |

**使用场景**:
- 创意编程
- 视觉创作

---

### Reference (参考) - 4个技能

| 技能ID | 名称 | 描述 | 自动安装 |
|--------|------|------|----------|
| mcp_best_practices | MCP最佳实践 | MCP开发指南 | ❌ |
| evaluation | 评估框架 | 技能评估 | ❌ |

**使用场景**:
- 查阅参考文档
- 学习最佳实践

---

## 技能使用方法

### 方法1: 通过Master命令

```bash
# 明确指定技能
/master 使用 api-design 技能设计用户认证API

# 多个技能组合
/master 使用 api-design 和 security-analysis 设计支付系统

# 让系统自动选择
/master 我需要设计一个微服务架构
# → 系统会自动匹配 backend-development, api-design 等技能
```

### 方法2: 直接调用

```bash
# 直接描述需求,触发技能
设计一个RESTful API for user management
# → skill-dispatcher 自动匹配 api-design

# 使用测试技能
帮我为这个API编写测试用例
# → skill-dispatcher 自动匹配 api-testing
```

### 方法3: 查询技能

```bash
# 查看所有技能
有什么可用的技能?

# 按分类查看
列出所有开发类技能

# 查看特定技能信息
告诉我 api-design 技能的详细信息
```

---

## 技能开发指南

### 创建新技能

#### 步骤1: 创建技能文件

在 `.cursor/features/skills/` 创建 `[skill-name].md`:

```markdown
---
name: my-skill
description: 我的技能描述
category: development
auto_install: true
dependencies: []
---

# 我的技能

技能详细说明...

## 能力

- 能力1
- 能力2

## 使用方法

...

## 示例

...
```

#### 步骤2: 注册技能

在 `registry.json` 中添加:

```json
{
  "skills": {
    "legacy": {
      "my-skill": {
        "name": "我的技能",
        "description": "技能描述",
        "category": "development",
        "auto_install": true,
        "path": "my-skill.md",
        "dependencies": [],
        "source": "cursor-ai-rules"
      }
    }
  },
  "categories": {
    "development": [..., "my-skill"]
  }
}
```

#### 步骤3: 测试技能

```bash
# 查询技能是否可用
/master 列出所有技能

# 使用技能
/master 使用 my-skill 技能...
```

---

### 技能最佳实践

#### 1. 清晰的职责定义

每个技能应该有明确的职责范围:

```markdown
## 技能职责

- ✅ 包含: API设计相关的知识
- ❌ 不包含: 具体代码实现
```

#### 2. 完整的元数据

```markdown
---
name: api-design
description: 专业的API设计能力
category: development
auto_install: true
dependencies: ["javascript", "nodejs"]
source: cursor-ai-rules
---
```

#### 3. 结构化的内容

```markdown
# 技能名称

## 核心能力
## 使用场景
## 工作流程
## 最佳实践
## 示例
## 参考资料
```

#### 4. 依赖声明

明确技能的依赖关系:

```json
{
  "dependencies": ["javascript", "nodejs"],
  "conditions": {
    "dependencies": ["javascript", "nodejs"]
  }
}
```

---

## 常见问题

### Q1: 为什么要分两个目录?

**A**: 职责分离和可重用性:
- `.cursor/skills/` - 管理这个项目的技能系统
- `.cursor/features/skills/` - 可在多个项目中使用的技能库

### Q2: 如何选择使用哪个技能?

**A**: 三种方式:
1. 明确指定: `/master 使用 api-design 技能`
2. 自动匹配: 描述需求,让系统自动匹配
3. 查询选择: 先查看可用技能,再选择

### Q3: 技能依赖不满足怎么办?

**A**: 
- 系统会提示缺少的依赖
- 可以安装依赖或选择其他技能
- 某些技能不依赖特定环境,可优先使用

### Q4: 如何添加自定义技能?

**A**: 
1. 在 `.cursor/features/skills/` 创建技能文件
2. 在 `registry.json` 中注册
3. 测试技能是否可用

### Q5: 技能可以组合使用吗?

**A**: 可以! 系统支持多技能组合:
```bash
/master 使用 api-design、security-analysis 和 backend-development 技能
```

### Q6: 如何查看所有技能?

**A**: 
```bash
# 通过命令
有什么可用的技能?

# 或查看注册表
cat .cursor/features/skills/registry.json

# 或使用脚本
./.cursor/skills/skill-dispatcher/scripts/list-skills.sh
```

---

## 技能统计

| 分类 | 技能数量 | 自动安装 |
|------|----------|----------|
| Development | 5 | 3 |
| Testing | 4 | 2 |
| Security | 2 | 2 |
| Analysis | 3 | 3 |
| Optimization | 3 | 2 |
| Documentation | 8 | 1 |
| Design | 4 | 0 |
| Learning | 2 | 2 |
| Collaboration | 3 | 1 |
| AI Integration | 4 | 1 |
| Creative | 2 | 0 |
| Reference | 4 | 0 |
| **总计** | **37** | **17** |

---

**文档版本**: 1.0.0  
**最后更新**: 2026-02-07  
**维护者**: cursor-ai-rules 项目
