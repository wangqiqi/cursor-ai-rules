# 🚀 Cursor AI Rules - Extensions 扩展系统

## 🏗️ 扁平化架构设计

**核心理念：降低认知负担，简化目录结构**

### 📊 结构对比

**旧结构（混乱）:**
```
.cursor/extensions/
├── skills/
│   ├── bridge/           # 技能桥接 (3层)
│   │   ├── docx.md
│   │   ├── converter.sh
│   │   └── algorithmic-art.md
│   ├── runtime/          # 运行时 (3层)
│   │   └── skill-discovery.sh
│   └── registry/         # 注册表 (3层)
│       └── skills-registry.json
```

**新结构（扁平化）:**
```
.cursor/extensions/
├── skills/               # 统一技能目录 (2层)
│   ├── registry.json    # 技能注册表
│   ├── discovery.sh     # 技能发现器
│   ├── converter.sh     # 技能转换器
│   ├── docx.md         # Word处理技能
│   └── algorithmic-art.md # 算法艺术技能
└── README.md            # 扩展说明
```

### 🎯 设计原则

1. **层级最小化** - 从最多5层降低到2层
2. **命名简化** - 去掉冗余前缀（如skill-）
3. **结构统一** - 同类文件集中管理
4. **路径直观** - 降低记忆和查找成本

## 🛠️ 核心组件

### Skills技能系统
- **`registry.json`** - 技能注册表，记录所有可用技能
- **`discovery.sh`** - 技能发现器，检查和加载技能
- **`converter.sh`** - 技能转换器，将外部格式转换为Cursor规则
- **`16个专业技能`** - 全套专业技能库（文档处理、设计创作、AI集成等）

### 使用方式

```bash
# 发现可用技能
./.cursor/extensions/skills/discovery.sh

# 转换外部技能
./.cursor/extensions/skills/converter.sh <skill_name>

# 通过智能Master调用
@master skill docx     # 调用Word处理技能
@master skill pdf      # 调用PDF处理技能
@master skill mcp-builder  # 调用MCP构建器
@master skill webapp-testing  # 调用Web测试工具

## 🎯 完整Skills生态 (16个专业技能)

### 📄 文档处理技能
- **docx** - Word文档处理和操作
- **pdf** - PDF文档处理和转换
- **pptx** - PowerPoint演示文稿处理
- **xlsx** - Excel电子表格处理

### 🎨 创意设计技能
- **algorithmic-art** - 算法艺术生成和可视化
- **canvas-design** - Canvas设计和图形创作
- **frontend-design** - 前端设计和UI开发
- **theme-factory** - 主题工厂和样式生成

### 🤖 AI集成技能
- **mcp-builder** - MCP服务器构建和管理
- **slack-gif-creator** - Slack GIF动图创建器
- **skill-creator** - 技能创建和开发工具

### 🏢 企业协作技能
- **brand-guidelines** - 品牌指南和规范管理
- **internal-comms** - 内部沟通和协作工具
- **doc-coauthoring** - 文档协作和版本控制

### 🧪 测试开发技能
- **webapp-testing** - Web应用测试和质量保障
- **web-artifacts-builder** - Web构建产物生成器
```

## 📈 性能提升

| 指标 | 旧结构 | 新结构 | 提升 |
|------|--------|--------|------|
| 最大层级 | 5层 | 2层 | **60%减少** |
| 路径复杂度 | 高 | 低 | **显著降低** |
| 文件查找 | 复杂 | 简单 | **大幅改善** |
| 维护成本 | 高 | 低 | **显著降低** |

## 🔄 迁移说明

### 从旧结构迁移
1. ✅ 已自动迁移所有文件到新结构
2. ✅ 已更新所有路径引用
3. ✅ 已测试功能完整性

### 兼容性保证
- 所有现有功能保持不变
- 智能Master调用方式不变
- 外部接口保持兼容

## 🎯 扩展开发指南

### 添加新技能
1. 将技能文件放入 `skills/` 目录
2. 在 `registry.json` 中注册技能信息
3. 通过 `@master skill <name>` 调用

### 开发原则
- 保持扁平化设计理念
- 优先使用描述性命名
- 确保功能模块化
- 维护向后兼容性

---

*🚀 扁平化架构，让扩展开发更简单、更高效！*