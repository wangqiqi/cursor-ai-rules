# 模块化能力映射系统

## 📁 目录结构

```
.cursor/commands/capability-maps/
├── _index.json                    # 主索引文件
├── README.md                      # 本文档
├── global/
│   ├── config.json               # 全局配置
│   └── metadata.json             # 元数据
├── mappings/                     # 能力映射 (按功能分类)
│   ├── project.json              # 项目相关能力
│   ├── code.json                 # 代码相关能力
│   ├── deployment.json           # 部署相关能力
│   ├── testing.json              # 测试相关能力
│   ├── learning.json             # 学习相关能力
│   ├── system.json               # 系统相关能力
│   └── role-system.json          # 角色系统能力
└── advanced/                     # 高级配置
    ├── intent-patterns.json      # 意图模式配置
    ├── execution-presets.json    # 执行预设 (待创建)
    ├── error-handling.json       # 错误处理 (待创建)
    └── performance.json          # 性能优化 (待创建)
```

## 🎯 设计优势

### 1. **职责分离清晰**
- 每个文件专注单一功能领域
- 修改项目功能时只需编辑 `mappings/project.json`
- 新增功能时按类别添加到相应文件

### 2. **维护效率提升**
- 文件大小从5824行减少到各200-500行
- 错误影响范围从全文件缩小到单功能模块
- Git冲突概率大幅降低

### 3. **扩展性极佳**
- 新增功能类别时只需创建新文件
- 技术栈扩展时可创建子分类
- 向后兼容性通过主索引文件保证

## 🔄 加载机制

### 主索引文件 (_index.json)
```json
{
  "version": "2.0.0",
  "structure": "modular",
  "includes": [
    "global/config.json",
    "mappings/project.json",
    "mappings/code.json"
  ],
  "load_order": ["global", "mappings", "advanced"],
  "fallback": "capability-map.json"
}
```

### 智能加载器
1. **优先使用模块化结构**: 读取主索引，按顺序加载各模块
2. **自动合并配置**: 将各模块配置合并为统一的能力映射表
3. **回退兼容**: 如果模块化加载失败，自动回退到传统单文件

## 🚀 使用方式

### 开发者维护
```bash
# 修改项目创建功能
vim mappings/project.json

# 添加新的部署策略
vim mappings/deployment.json

# 新增学习功能
vim mappings/learning.json
```

### 系统加载
```javascript
const loader = new ModularCapabilityLoader();
const capabilities = await loader.loadFromIndex('_index.json');
// 自动加载并合并所有模块
```

## 📊 统计信息

| 类别 | 文件数量 | 映射数量 | 主要功能 |
|------|----------|----------|----------|
| global | 2 | - | 全局配置和元数据 |
| mappings | 7 | 15+ | 核心功能映射 |
| advanced | 4 | - | 高级配置选项 |
| **总计** | **13** | **15+** | **完整能力覆盖** |

## 🔧 维护指南

### 添加新功能
1. 确定功能类别 (project/code/deployment/testing/learning/system)
2. 编辑相应JSON文件，添加新的能力映射
3. 更新主索引文件的includes列表
4. 测试功能是否正常工作

### 修改现有功能
1. 找到相应的功能文件
2. 编辑JSON配置
3. 验证配置格式正确性
4. 提交变更

### 性能优化
- 按需加载：只加载需要的功能模块
- 缓存机制：模块加载结果可缓存
- 增量更新：支持热重载单个模块

## 🛡️ 兼容性保证

### 向后兼容
- 保留原有 `capability-map.json` 作为回退选项
- 主索引文件控制加载策略
- 支持渐进式迁移

### 版本管理
- 语义化版本控制
- 兼容性检查机制
- 回滚支持

## 🎯 最佳实践

1. **单一职责**: 每个映射文件只负责一个功能领域
2. **命名规范**: 使用小写字母和连字符命名文件
3. **文档同步**: 修改配置时同步更新相关文档
4. **测试验证**: 重要变更后进行功能测试
5. **版本控制**: 所有变更通过Git管理

---

*此模块化结构大幅提升了系统的可维护性、可扩展性和团队协作效率。*