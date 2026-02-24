---
description: "模块监控和配置管理 - 性能监控、配置管理和工具系统 (监控, 配置, 性能, 工具)"
globs: ["**/*"]
alwaysApply: false
priority: 19
---

# 📊 模块监控和配置管理

        await this.triggerOptimization('cpu');
      }
    }, 5000); // 每5秒检查一次
  }
}
```

## 🔧 配置管理器 (Configuration Manager)

### 当前配置机制 (Current Configuration Mechanism)

#### 规则级配置 (Rule-level Configuration)
每个规则通过其`RULE.md`文件顶部的元数据进行配置：

```markdown
---
description: "规则描述"
alwaysApply: true/false  # 是否自动激活
---
```

#### 项目级配置 (Project-level Configuration)
- 通过创建/删除规则目录来控制规则激活
- 通过修改规则文件内容来调整规则行为
- 通过引用语法(`@规则名`)建立规则间依赖

#### 用户级配置 (User-level Configuration)
- 用户可以通过复制和修改规则来自定义行为
- 通过创建个人规则目录扩展功能
- 通过选择性激活规则来适应工作习惯

### 配置合并策略 (Configuration Merge Strategy)
```typescript
class ConfigurationManager {
  async getConfiguration(moduleName: string, key: string): Promise<any> {
    const configs = await this.loadConfigurationHierarchy();

    // 从低到高优先级查找配置
    for (const config of configs.reverse()) {
      if (config.modules?.[moduleName]?.[key] !== undefined) {
        return config.modules[moduleName][key];
      }
    }

    // 返回默认值
    return this.getDefaultValue(moduleName, key);
  }

  async setConfiguration(moduleName: string, key: string, value: any): Promise<void> {
    const userConfig = await this.loadUserConfig();

    if (!userConfig.modules) {
      userConfig.modules = {};
    }

    if (!userConfig.modules[moduleName]) {
      userConfig.modules[moduleName] = {};
    }

    userConfig.modules[moduleName][key] = value;

    await this.saveUserConfig(userConfig);
  }
}
```

## 🧩 模块工具子系统 (Module Tools Subsystem)

### 模块架构 (Module Architecture)

#### 模块架构设计蓝图 (Module Architecture Blueprint)

**注意**: 以下目录结构是概念性设计，展示了模块化系统的理想组织方式。目前这些目录还不存在，是未来扩展时的目标架构。

```
当前规则的功能分类 (Current Rules by Function Category)

├── 基础设施层 (Infrastructure Layer)
│   ├── system_info/        # 系统信息获取 (✅ 已实现)
│   ├── platform_adapter/  # 跨平台适配 (✅ 已实现)
│   └── i18n/              # 国际化支持 (✅ 已实现)
├── 开发工具层 (Development Tools Layer)
│   ├── eslint/            # JavaScript代码质量检查 (✅ 已实现)
│   ├── intelligent_evolution/ # 智能感知系统 (✅ 已实现)
│   └── generator/         # 规则生成器 (✅ 已实现)
├── 演进管理层 (Evolution Management Layer)
│   ├── evolution-philosophy/  # 演进理念 (✅ 已实现)
│   ├── evolution-manual/     # 手动演进 (✅ 已实现)
│   ├── evolution-automation/ # 自动化演进 (✅ 已实现)
│   └── evolution-governance/ # 演进治理 (✅ 已实现)
└── 框架核心层 (Framework Core Layer)
    ├── constitution/      # AI共生宪法 (✅ 已实现)
    ├── philosophy/        # 协作哲学 (✅ 已实现)
    ├── templates/         # 配置模板框架 (✅ 已实现)
    └── module_manager/    # 规则管理系统 (✅ 当前文档)

注意：以上是功能分类的逻辑分组，实际文件都位于 .cursor/rules/ 目录下
```

**当前状态**: 上述模块功能已通过规则文件实现，但尚未模块化。每个功能都作为独立的RULE.md文件存在。

**当前架构状态**:
1. **规则文件组织**: 所有功能以RULE.md文档形式存在
   - 每个规则都是独立的文档文件
   - 通过@引用语法实现规则间协作
   - 规则可通过文件名激活/停用

2. **功能完整性**: 核心功能已全部实现
   - 所有标注的功能都已通过现有规则文档实现
   - 无"待实现"的功能，所有都是可用的

3. **架构优势**: 当前设计天然具备模块化特征
   - 规则文件本身就是模块化的单元
   - 可以独立维护、测试和扩展
   - 支持条件激活和按需加载

#### 当前规则依赖关系 (Current Rule Dependencies)
```json
{
  "rule_dependencies": {
    "foundation": {
      "description": "基础框架层",
      "rules": ["constitution"],
      "dependents": ["所有其他规则"]
    },
    "collaboration": {
      "description": "协作层",
      "rules": ["philosophy"],
      "depends_on": ["constitution"],
      "dependents": ["所有协作相关规则"]
    },
    "infrastructure": {
      "description": "基础设施层",
      "rules": ["system_info", "platform_adapter", "i18n"],
      "depends_on": ["constitution"],
      "dependents": ["所有需要系统功能的规则"]
    },
    "tools": {
      "description": "工具层",
      "rules": ["eslint", "intelligent_evolution", "generator"],
      "depends_on": ["infrastructure"],
      "dependents": []
    },
    "evolution": {
      "description": "演进层",
      "rules": ["evolution-philosophy", "evolution-manual", "evolution-automation", "evolution-governance"],
      "depends_on": ["constitution", "intelligent_evolution"],
      "dependents": []
    }
  }
}
```

### 规则系统工作机制 (Rule System Working Mechanism)

#### 规则文件标准 (Rule File Standards)
每个规则都作为独立的`.cursor/rules/*/RULE.md`文档存在：

```markdown
---
description: "规则功能描述"
alwaysApply: true/false
---

# 规则标题

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## 功能描述
<!-- 规则的详细功能说明 -->

## 使用方法
<!-- 如何使用该规则 -->
```

#### 规则激活机制 (Rule Activation Mechanism)
- **文件名激活**: 规则通过其所在目录名激活（如`@eslint`激活eslint规则）
- **条件引用**: 规则可通过`@规则名`语法被其他规则引用
- **alwaysApply**: 设置为true的规则始终激活，false的规则按需激活

### 规则激活控制 (Rule Activation Control)

#### 显式激活 (Explicit Activation)
- **目录存在**: 规则通过创建对应的`.cursor/rules/规则名/`目录激活
- **引用语法**: 在其他规则中通过`@规则名`引用来激活依赖规则
- **alwaysApply**: 在规则元数据中设置为true的规则自动激活

#### 隐式激活 (Implicit Activation)
- **按需加载**: 当其他规则引用某个规则时，该规则自动激活
- **上下文相关**: 根据项目特征和使用场景自动判断是否需要激活特定规则
- **用户控制**: 用户可以通过创建/删除规则目录来控制规则的启用和禁用

### 规则扩展机制 (Rule Extension Mechanism)

#### 新规则创建 (New Rule Creation)
创建新的规则只需在`.cursor/rules/`目录下创建新的规则目录和RULE.md文件：

```bash
# 创建新规则目录
mkdir .cursor/rules/my_custom_rule

# 创建规则文档
cat > .cursor/rules/my_custom_rule/RULE.md << 'EOF'
---
description: "我的自定义规则"
alwaysApply: false
---

# 我的自定义规则

*版本: v4.3.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## 功能描述
<!-- 描述规则的功能 -->

## 配置选项
<!-- 描述规则的配置选项 -->

## 使用方法
<!-- 描述如何使用该规则 -->
EOF
```

#### 规则集成方式 (Rule Integration Methods)
- **直接引用**: 在其他规则中使用`@my_custom_rule`引用
- **条件激活**: 根据项目需要选择性激活
- **协作扩展**: 通过与其他规则结合提供完整解决方案

## 👤 用户界面 (User Interface)

### 配置界面 (Configuration Interface)
```json
{
  "user_interface": {
    "dashboard": {
      "active_modules": ["eslint_integration", "git_integration", "i18n_support"],
      "system_status": "healthy",
      "performance_summary": {
        "total_modules": 15,
        "active_modules": 8,
        "memory_usage": "256MB",
        "cpu_usage": "12%"
      }
    },
    "module_browser": {
      "categories": {
        "code_quality": ["eslint", "prettier", "stylelint"],
        "collaboration": ["git_integration", "slack_integration"],
        "productivity": ["task_manager", "time_tracker"]
      },
      "filters": {
        "platform": ["linux", "macos", "windows"],
        "status": ["active", "inactive", "failed"],
        "rating": ["⭐⭐⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐"]
      }
    },
    "settings": {
      "auto_discovery": true,
      "auto_update": "stable",
      "performance_monitoring": true,
      "telemetry": false
    }
  }
}
```

### 规则管理工具 (Rule Management Tools)
```bash
# 查看环境状态
../core/env-perception.sh

# 检查代码质量（针对JavaScript项目）
../core/quality-manager.sh

# 启用特定规则
../core/init.sh rule_name

# 管理插件（如果有的话）
../features/automation/scripts/plugin_manager.sh
```

#### 手动规则管理 (Manual Rule Management)
```bash
# 激活规则：创建规则目录
mkdir .cursor/rules/my_rule
echo "# My Rule" > .cursor/rules/my_rule/RULE.md

# 停用规则：删除规则目录
rm -rf .cursor/rules/my_rule

# 查看活跃规则：列出规则目录
ls .cursor/rules/
```

---

*统一模块管理器是.cursor规则体系的管理和协调中心，提供规则间的依赖管理、激活控制和扩展机制，确保规则系统的有序运行和协作。*
