# Skill Dispatcher

智能技能调度器，用于发现、匹配和调用 `.cursor/skills/` 官方技能包。

## 快速开始

### 列出所有可用技能

```bash
./scripts/list-skills.sh
```

### 在对话中使用

```
你: 有什么可用的技能？
AI: [使用 skill-dispatcher 列出所有技能]

你: 我需要设计一个 REST API
AI: [使用 skill-dispatcher 匹配并调用 api-design 技能]

你: 帮我优化代码性能
AI: [使用 skill-dispatcher 匹配并调用 optimization-tools 技能]
```

## 目录结构

```
skill-dispatcher/
├── SKILL.md              # 主技能文件
├── README.md             # 本文件
├── reference.md          # 详细参考文档
└── scripts/
    └── list-skills.sh    # 技能列表工具
```

## 核心功能

### 1. 技能发现

自动扫描 `.cursor/skills/` 目录，读取 `registry.json`，发现所有可用技能。

### 2. 智能匹配

基于关键词、语义和依赖关系，智能匹配最适合当前任务的技能。

### 3. 技能调用

加载并执行匹配的技能，将技能的指导和最佳实践应用到当前任务。

## 技能分类

- **Development (开发)** - API设计、后端开发、全栈开发
- **Testing (测试)** - API测试、自动化测试
- **Security (安全)** - 安全分析、漏洞扫描
- **Analysis (分析)** - 代码分析、性能分析、系统分析
- **Optimization (优化)** - 优化工具、重构工具、SSR优化
- **Documentation (文档)** - 文档工具、Word/Excel/PDF/PPT处理
- **Collaboration (协作)** - Git管理
- **Learning (学习)** - 代码示例、学习助手
- **AI Integration (AI集成)** - MCP构建器
- **Design (设计)** - 前端设计、画布设计、主题工厂
- **Creative (创意)** - 算法艺术、GIF创建
- **Enterprise (企业)** - 品牌指南、内部通讯

## 使用示例

### 示例 1: 发现技能

```
用户: 列出所有测试相关的技能

Dispatcher:
## 🧪 Testing (测试)

✓ api-testing - API测试和验证工具
  依赖: javascript, testing

✓ test-automation - 自动化测试框架和工具
  依赖: 无

○ webapp-testing - 使用Playwright进行Web应用测试
  依赖: javascript, node
```

### 示例 2: 匹配技能

```
用户: 我需要为我的Express应用设计RESTful API

Dispatcher:
✓ 检测到任务: Express RESTful API 设计
✓ 匹配技能: api-design
✓ 检查依赖: javascript ✓, nodejs ✓
✓ 加载技能: .cursor/skills/api-design/references/full-guide.md

[应用 api-design 技能的指导...]
```

### 示例 3: 组合技能

```
用户: 构建一个完整的Web应用

Dispatcher:
任务分析: 复杂全栈开发任务
需要技能组合:

1. **fullstack-development** (主技能)
   → 全栈开发框架和最佳实践

2. **frontend-design** (辅助)
   → 前端界面设计

3. **backend-development** (辅助)
   → 后端API开发

4. **api-testing** (验证)
   → API接口测试

5. **security-analysis** (安全)
   → 安全检查

正在依次加载和应用这些技能...
```

## 工具脚本

### list-skills.sh

列出所有可用技能，按分类显示，包括技能元数据和依赖信息。

```bash
./scripts/list-skills.sh
```

输出示例：
```
═══════════════════════════════════════════════════════
  🎯 Cursor Skills - 技能列表
═══════════════════════════════════════════════════════

📍 技能目录: /path/to/.cursor/skills/
📄 注册表版本: 2.0.0
📅 最后更新: 2026-01-15

🚀 Development (开发)
───────────────────────────────────────────────────────
  ✓ api-design - API设计
     专业的API设计能力，包括RESTful、GraphQL等
     依赖: javascript, nodejs

  ✓ backend-development - 后端开发
     后端系统设计和开发指导
     依赖: nodejs, python, java

...
```

## 配置

Skill Dispatcher 读取 `.cursor/features/skills/skills/registry.json` 来获取技能元数据。

### 注册表格式

```json
{
  "version": "2.0.0",
  "skills": {
    "legacy": {
      "skill-id": {
        "name": "技能名称",
        "description": "技能描述",
        "category": "分类",
        "auto_install": true,
        "path": "skill-file.md",
        "dependencies": ["dependency1"],
        "source": "source-name"
      }
    }
  }
}
```

## 依赖检查

在调用技能前，Dispatcher 会检查：

1. **项目依赖** - 项目是否满足技能所需的依赖
2. **工具可用性** - 所需工具是否已安装
3. **文件存在性** - 技能文件是否存在

如果依赖不满足，会提示用户：

```
⚠️ 技能 "api-design" 需要以下依赖:
缺少: nodejs

建议:
1. 安装 Node.js
2. 或选择其他不依赖 nodejs 的技能
```

## 技能生命周期

```
用户请求
  ↓
发现技能 (扫描目录和注册表)
  ↓
匹配技能 (关键词、语义、分类)
  ↓
检查依赖 (验证依赖是否满足)
  ↓
加载技能 (读取技能文件)
  ↓
应用技能 (应用技能指导)
  ↓
完成任务
```

## 最佳实践

### 1. 技能选择

- 优先使用 `auto_install: true` 的技能
- 确保项目满足技能的依赖要求
- 根据任务类型选择合适的分类

### 2. 技能组合

- 主技能提供核心功能
- 辅助技能提供支持功能
- 验证技能确保质量

### 3. 调用顺序

对于多技能任务：
1. 先调用主技能
2. 再调用辅助技能
3. 最后调用验证技能

## 故障排除

### 技能未找到

```
❌ 技能 "xxx" 未找到
✓ 检查拼写是否正确
✓ 运行 list-skills.sh 查看可用技能
```

### 依赖缺失

```
⚠️ 缺少依赖: python
✓ 安装所需依赖
✓ 或选择其他技能
```

### 加载失败

```
❌ 加载技能失败
✓ 检查技能文件是否存在
✓ 验证文件格式是否正确
```

## 相关文件

- `.cursor/features/skills/skills/registry.json` - 技能注册表
- `.cursor/skills/*/SKILL.md` + `references/full-guide.md` - 技能文件
- `reference.md` - 详细参考文档

## 版本信息

- **版本**: 1.0.0
- **注册表版本**: 2.0.0
- **支持的技能数量**: 30+
- **最后更新**: 2026-02-07

## 贡献

要添加新技能：

1. 在 `.cursor/skills/<name>/` 创建官方技能包（`SKILL.md` + `references/full-guide.md`）
2. 更新 `registry.json` 注册技能
3. 运行 `list-skills.sh` 验证

---

**作者**: Cursor AI Rules Team  
**许可**: MIT License  
**项目**: LocFileShare
