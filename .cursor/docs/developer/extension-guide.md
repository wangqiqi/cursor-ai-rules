# 🔧 扩展开发指南 - Cursor AI Rules

*开发者自定义功能和配置的完整指南*

> **注意：两种「插件」**  
> - **Cursor 市场插件**：`packages/cursor-ai-rules-plugin/` + `.cursor-plugin/plugin.json`（全局 rules/skills/agents/commands）。  
> - **Master 内部 JS 插件**：`.cursor/plugins/*/manifest.json`（`component-manager` 加载的 Node 组件）。  
> 本文档主体描述后者；双轨分发见 [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md)。

## 🚀 扩展架构概览

### 插件化设计原则

Cursor AI Rules 采用完全插件化的架构，支持以下扩展类型：

- **技能扩展**: 添加新的AI能力模块
- **规则扩展**: 自定义代码规范和质量规则
- **命令扩展**: 添加新的CLI命令和交互方式
- **钩子扩展**: 在特定时机执行自定义逻辑
- **主题扩展**: 自定义界面样式和交互体验

### 扩展加载机制

```typescript
interface ExtensionManifest {
  name: string;              // 扩展名称
  version: string;          // 版本号
  type: ExtensionType;      // 扩展类型
  entry: string;            // 入口文件
  dependencies?: string[];  // 依赖项
  permissions?: string[];   // 所需权限
  config?: ExtensionConfig; // 配置选项
}

enum ExtensionType {
  SKILL = 'skill',
  RULE = 'rule',
  COMMAND = 'command',
  HOOK = 'hook',
  THEME = 'theme'
}
```

## 🛠️ 技能扩展开发

### 技能架构

#### 技能定义结构
```typescript
interface Skill {
  id: string;
  name: string;
  description: string;
  category: SkillCategory;
  parameters: SkillParameter[];
  execute: SkillExecutor;
  validate?: SkillValidator;
}

interface SkillParameter {
  name: string;
  type: 'string' | 'number' | 'boolean' | 'array' | 'object';
  required: boolean;
  description: string;
  defaultValue?: any;
}

type SkillExecutor = (context: SkillContext) => Promise<SkillResult>;
```

#### 技能实现示例
```typescript
// skills/custom-analysis.skill.js
class CustomAnalysisSkill {
  static id = 'custom-analysis';
  static name = '自定义分析';
  static description = '执行自定义代码分析';

  static parameters = [
    {
      name: 'target',
      type: 'string',
      required: true,
      description: '分析目标文件或目录'
    },
    {
      name: 'depth',
      type: 'number',
      required: false,
      defaultValue: 1,
      description: '分析深度'
    }
  ];

  static async execute(context) {
    const { target, depth } = context.parameters;

    // 技能执行逻辑
    const analysis = await this.performAnalysis(target, depth);

    return {
      success: true,
      data: analysis,
      summary: `分析完成，发现${analysis.issues.length}个问题`
    };
  }

  static async performAnalysis(target, depth) {
    // 实现具体的分析逻辑
    return {
      target,
      depth,
      issues: [],
      metrics: {},
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = CustomAnalysisSkill;
```

### 技能注册

#### 配置文件注册
```json
// config/skills/custom-skills.json
{
  "custom-analysis": {
    "name": "自定义分析",
    "description": "高级代码分析工具",
    "category": "analysis",
    "path": "skills/custom-analysis.skill.js",
    "enabled": true,
    "config": {
      "maxDepth": 5,
      "timeout": 30000
    }
  }
}
```

#### 动态注册
```typescript
// 运行时注册新技能
const skillManager = new SkillManager();

await skillManager.registerSkill({
  id: 'dynamic-skill',
  name: '动态技能',
  description: '运行时加载的技能',
  execute: async (context) => {
    // 技能实现
    return { success: true };
  }
});
```

## 📏 规则扩展开发

### 规则系统架构

#### 规则定义格式
```typescript
interface Rule {
  id: string;
  name: string;
  description: string;
  category: RuleCategory;
  severity: 'error' | 'warning' | 'info';
  conditions: RuleCondition[];
  actions: RuleAction[];
  config?: RuleConfig;
}

interface RuleCondition {
  type: 'file' | 'content' | 'context';
  pattern: string | RegExp;
  operator: 'match' | 'contain' | 'exist' | 'not_exist';
}

interface RuleAction {
  type: 'report' | 'fix' | 'suggest';
  message: string;
  autoFix?: boolean;
  fixFunction?: Function;
}
```

#### 自定义规则示例
```typescript
// rules/custom-naming.rule.js
class CustomNamingRule {
  static id = 'custom-naming';
  static name = '自定义命名规范';
  static description = '检查变量和函数命名是否符合团队规范';

  static conditions = [
    {
      type: 'file',
      pattern: '\\.(js|ts)$',
      operator: 'match'
    },
    {
      type: 'content',
      pattern: /(var|let|const|function)\s+[a-zA-Z_$][a-zA-Z0-9_$]*/,
      operator: 'match'
    }
  ];

  static actions = [
    {
      type: 'report',
      message: '变量/函数命名不符合规范: {{name}}',
      severity: 'warning'
    },
    {
      type: 'suggest',
      message: '建议使用驼峰命名法',
      autoFix: true,
      fixFunction: (content, match) => {
        // 自动修复逻辑
        return content.replace(match, this.toCamelCase(match));
      }
    }
  ];

  static toCamelCase(name) {
    // 驼峰命名转换逻辑
    return name.replace(/[-_](.)/g, (_, letter) => letter.toUpperCase());
  }

  static validate(context) {
    const { content, filePath } = context;

    // 验证逻辑
    const issues = [];

    // 检查命名规范
    const namingPattern = /(var|let|const|function)\s+([a-zA-Z_$][a-zA-Z0-9_$]*)/g;
    let match;

    while ((match = namingPattern.exec(content)) !== null) {
      const [, type, name] = match;

      if (!this.isValidName(name)) {
        issues.push({
          type: 'naming',
          message: `${type} ${name} 命名不符合规范`,
          line: this.getLineNumber(content, match.index),
          fix: this.suggestFix(name)
        });
      }
    }

    return issues;
  }

  static isValidName(name) {
    // 检查是否为有效的驼峰命名
    return /^[a-z][a-zA-Z0-9]*$/.test(name);
  }

  static suggestFix(name) {
    // 生成修复建议
    return name.replace(/[-_](.)/g, (_, letter) => letter.toUpperCase());
  }

  static getLineNumber(content, index) {
    return content.substring(0, index).split('\n').length;
  }
}

module.exports = CustomNamingRule;
```

### 规则配置

#### 规则配置文件
```json
// config/rules/custom-rules.json
{
  "custom-naming": {
    "enabled": true,
    "severity": "warning",
    "config": {
      "allowUnderscore": false,
      "allowHyphen": false,
      "enforceCamelCase": true
    }
  },
  "custom-security": {
    "enabled": true,
    "severity": "error",
    "config": {
      "checkSecrets": true,
      "checkInjection": true
    }
  }
}
```

## ⚡ 命令扩展开发

### 命令系统架构

#### 命令定义接口
```typescript
interface Command {
  name: string;
  description: string;
  usage: string;
  options: CommandOption[];
  handler: CommandHandler;
  middleware?: CommandMiddleware[];
}

interface CommandOption {
  name: string;
  alias?: string;
  type: 'string' | 'number' | 'boolean' | 'array';
  description: string;
  required?: boolean;
  default?: any;
}

type CommandHandler = (args: CommandArgs, context: CommandContext) => Promise<CommandResult>;
```

#### 自定义命令示例
```typescript
// commands/custom-deploy.command.js
class CustomDeployCommand {
  static name = 'custom-deploy';
  static description = '自定义部署命令';
  static usage = 'custom-deploy [options] <environment>';

  static options = [
    {
      name: 'target',
      alias: 't',
      type: 'string',
      description: '部署目标',
      required: true
    },
    {
      name: 'version',
      alias: 'v',
      type: 'string',
      description: '部署版本',
      default: 'latest'
    },
    {
      name: 'dry-run',
      alias: 'd',
      type: 'boolean',
      description: '仅预览部署计划',
      default: false
    }
  ];

  static async handler(args, context) {
    const { target, version, dryRun } = args;
    const { logger, config } = context;

    logger.info(`开始部署到 ${target} 环境，版本: ${version}`);

    try {
      // 部署前检查
      await this.preDeployCheck(target, version);

      if (dryRun) {
        // 预览模式
        const plan = await this.generateDeployPlan(target, version);
        logger.info('部署计划预览:');
        logger.info(JSON.stringify(plan, null, 2));
        return { success: true, plan };
      }

      // 执行部署
      const result = await this.executeDeploy(target, version);

      logger.info('部署完成');
      return {
        success: true,
        deployment: result,
        url: result.url,
        version: result.version
      };

    } catch (error) {
      logger.error(`部署失败: ${error.message}`);
      throw error;
    }
  }

  static async preDeployCheck(target, version) {
    // 部署前检查逻辑
    // - 检查环境可用性
    // - 验证版本存在性
    // - 检查权限
  }

  static async generateDeployPlan(target, version) {
    // 生成部署计划
    return {
      target,
      version,
      steps: [
        '备份当前版本',
        '下载新版本',
        '停止服务',
        '更新文件',
        '启动服务',
        '健康检查'
      ],
      estimatedTime: '5 minutes'
    };
  }

  static async executeDeploy(target, version) {
    // 执行实际部署逻辑
    // 这里是简化的示例
    return {
      target,
      version,
      status: 'success',
      url: `https://${target}.example.com`,
      deployedAt: new Date().toISOString()
    };
  }
}

module.exports = CustomDeployCommand;
```

### 命令注册

#### 命令配置文件
```json
// config/commands/custom-commands.json
{
  "custom-deploy": {
    "path": "commands/custom-deploy.command.js",
    "enabled": true,
    "permissions": ["deploy"],
    "environments": ["staging", "production"]
  }
}
```

## 🎣 钩子扩展开发

### 钩子系统架构

#### 钩子定义接口
```typescript
interface Hook {
  id: string;
  name: string;
  description: string;
  event: HookEvent;
  priority: number;
  condition?: HookCondition;
  handler: HookHandler;
}

enum HookEvent {
  PRE_COMMIT = 'pre-commit',
  POST_COMMIT = 'post-commit',
  PRE_PUSH = 'pre-push',
  POST_MERGE = 'post-merge',
  FILE_CHANGE = 'file-change',
  PROJECT_INIT = 'project-init',
  COMMAND_EXECUTE = 'command-execute'
}

type HookHandler = (context: HookContext) => Promise<HookResult>;
```

#### 自定义钩子示例
```typescript
// hooks/custom-quality-hook.hook.js
class CustomQualityHook {
  static id = 'custom-quality-check';
  static name = '自定义质量检查钩子';
  static description = '在提交前执行自定义质量检查';

  static event = 'pre-commit';
  static priority = 10; // 执行优先级

  static condition = {
    // 只在JavaScript/TypeScript项目中执行
    projectType: ['nodejs', 'react'],
    // 只在src目录的文件变更时执行
    filePattern: 'src/**/*.{js,ts,jsx,tsx}'
  };

  static async handler(context) {
    const { changedFiles, logger, config } = context;

    logger.info('开始执行自定义质量检查...');

    const results = {
      passed: true,
      issues: [],
      metrics: {}
    };

    try {
      // 1. 代码复杂度检查
      const complexity = await this.checkComplexity(changedFiles);
      results.metrics.complexity = complexity;

      if (complexity.average > config.quality.maxComplexity) {
        results.issues.push({
          type: 'complexity',
          severity: 'warning',
          message: `平均复杂度(${complexity.average})超过阈值(${config.quality.maxComplexity})`,
          suggestion: '考虑拆分复杂函数'
        });
      }

      // 2. 代码覆盖率检查
      if (config.quality.requireTests) {
        const coverage = await this.checkTestCoverage(changedFiles);
        results.metrics.coverage = coverage;

        if (coverage.percentage < config.quality.minCoverage) {
          results.issues.push({
            type: 'coverage',
            severity: 'error',
            message: `测试覆盖率(${coverage.percentage}%)低于要求(${config.quality.minCoverage}%)`,
            suggestion: '请为新代码添加测试'
          });
          results.passed = false;
        }
      }

      // 3. 性能检查
      const performance = await this.checkPerformance(changedFiles);
      results.metrics.performance = performance;

      // 生成报告
      if (results.issues.length > 0) {
        logger.warn(`发现 ${results.issues.length} 个质量问题:`);
        results.issues.forEach(issue => {
          logger.warn(`- ${issue.type}: ${issue.message}`);
        });
      } else {
        logger.info('✅ 所有质量检查通过');
      }

      return results;

    } catch (error) {
      logger.error(`质量检查失败: ${error.message}`);
      throw error;
    }
  }

  static async checkComplexity(files) {
    // 计算代码复杂度
    let totalComplexity = 0;
    let fileCount = 0;

    for (const file of files) {
      if (file.endsWith('.js') || file.endsWith('.ts')) {
        const complexity = await this.calculateFileComplexity(file);
        totalComplexity += complexity;
        fileCount++;
      }
    }

    return {
      average: fileCount > 0 ? totalComplexity / fileCount : 0,
      total: totalComplexity,
      files: fileCount
    };
  }

  static async calculateFileComplexity(filePath) {
    // 简化的复杂度计算
    // 实际实现应该使用专门的复杂度分析工具
    const content = await fs.readFile(filePath, 'utf-8');

    // 简单的圈复杂度估算
    const conditions = (content.match(/\b(if|while|for|switch)\b/g) || []).length;
    const operators = (content.match(/(\|\||&&|\?|:)/g) || []).length;

    return Math.max(1, conditions + operators * 0.5);
  }

  static async checkTestCoverage(files) {
    // 检查测试覆盖率
    // 这里应该调用实际的测试覆盖率工具
    return {
      percentage: 85, // 示例值
      lines: 1250,
      covered: 1063,
      missed: 187
    };
  }

  static async checkPerformance(files) {
    // 性能检查
    const metrics = {
      loadTime: 0,
      memoryUsage: 0,
      bundleSize: 0
    };

    // 这里应该集成实际的性能测试工具
    // 如 Lighthouse、WebPageTest 等

    return metrics;
  }
}

module.exports = CustomQualityHook;
```

### 钩子配置

#### 钩子配置文件
```json
// config/hooks/custom-hooks.json
{
  "custom-quality-check": {
    "enabled": true,
    "priority": 10,
    "config": {
      "maxComplexity": 10,
      "minCoverage": 80,
      "performanceThreshold": 3000
    }
  },
  "custom-security-scan": {
    "enabled": true,
    "priority": 5,
    "config": {
      "scanSecrets": true,
      "scanVulnerabilities": true
    }
  }
}
```

## 🎨 主题扩展开发

### 主题系统架构

#### 主题定义接口
```typescript
interface Theme {
  id: string;
  name: string;
  description: string;
  author: string;
  version: string;
  baseTheme: 'light' | 'dark' | 'auto';

  colors: ThemeColors;
  typography: ThemeTypography;
  spacing: ThemeSpacing;
  components: ThemeComponents;
}

interface ThemeColors {
  primary: string;
  secondary: string;
  accent: string;
  background: string;
  surface: string;
  text: {
    primary: string;
    secondary: string;
    disabled: string;
  };
  border: string;
  error: string;
  warning: string;
  success: string;
  info: string;
}
```

#### 自定义主题示例
```typescript
// themes/custom-dark.theme.js
class CustomDarkTheme {
  static id = 'custom-dark';
  static name = '自定义暗色主题';
  static description = '专为开发者设计的舒适暗色主题';
  static author = 'Developer';
  static version = '1.0.0';
  static baseTheme = 'dark';

  static colors = {
    primary: '#6366f1',      // 靛蓝
    secondary: '#8b5cf6',    // 紫色
    accent: '#06b6d4',       // 青色
    background: '#0f172a',   // 深蓝灰
    surface: '#1e293b',      // 中蓝灰
    text: {
      primary: '#f1f5f9',    // 浅灰
      secondary: '#94a3b8',  // 中灰
      disabled: '#64748b'    // 深灰
    },
    border: '#334155',       // 边框色
    error: '#ef4444',        // 红色
    warning: '#f59e0b',      // 橙色
    success: '#10b981',      // 绿色
    info: '#3b82f6'          // 蓝色
  };

  static typography = {
    fontFamily: '"JetBrains Mono", "Fira Code", monospace',
    fontSize: {
      xs: '0.75rem',    // 12px
      sm: '0.875rem',   // 14px
      base: '1rem',     // 16px
      lg: '1.125rem',   // 18px
      xl: '1.25rem',    // 20px
      '2xl': '1.5rem',  // 24px
      '3xl': '1.875rem', // 30px
      '4xl': '2.25rem'  // 36px
    },
    fontWeight: {
      light: 300,
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700
    },
    lineHeight: {
      tight: 1.25,
      normal: 1.5,
      relaxed: 1.75
    }
  };

  static spacing = {
    px: '1px',
    0: '0',
    1: '0.25rem',   // 4px
    2: '0.5rem',    // 8px
    3: '0.75rem',   // 12px
    4: '1rem',      // 16px
    5: '1.25rem',   // 20px
    6: '1.5rem',    // 24px
    8: '2rem',      // 32px
    10: '2.5rem',   // 40px
    12: '3rem',     // 48px
    16: '4rem',     // 64px
    20: '5rem',     // 80px
    24: '6rem'      // 96px
  };

  static components = {
    button: {
      borderRadius: '0.375rem',  // 6px
      padding: {
        sm: '0.5rem 1rem',      // 8px 16px
        md: '0.625rem 1.25rem', // 10px 20px
        lg: '0.75rem 1.5rem'    // 12px 24px
      },
      shadow: '0 1px 3px rgba(0, 0, 0, 0.3)'
    },
    input: {
      borderRadius: '0.375rem',
      border: '1px solid',
      padding: '0.5rem 0.75rem',
      focus: {
        borderColor: '#6366f1',
        shadow: '0 0 0 3px rgba(99, 102, 241, 0.1)'
      }
    },
    card: {
      borderRadius: '0.5rem',
      shadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
      background: '#1e293b'
    }
  };

  // 主题应用方法
  static apply() {
    const root = document.documentElement;

    // 应用颜色变量
    Object.entries(this.colors).forEach(([key, value]) => {
      if (typeof value === 'string') {
        root.style.setProperty(`--color-${key}`, value);
      } else if (typeof value === 'object') {
        Object.entries(value).forEach(([subKey, subValue]) => {
          root.style.setProperty(`--color-${key}-${subKey}`, subValue);
        });
      }
    });

    // 应用字体变量
    Object.entries(this.typography.fontSize).forEach(([key, value]) => {
      root.style.setProperty(`--font-size-${key}`, value);
    });

    // 应用间距变量
    Object.entries(this.spacing).forEach(([key, value]) => {
      root.style.setProperty(`--spacing-${key}`, value);
    });
  }
}

module.exports = CustomDarkTheme;
```

### 主题注册

#### 主题配置文件
```json
// config/themes/custom-themes.json
{
  "custom-dark": {
    "name": "自定义暗色主题",
    "description": "专为开发者设计的舒适暗色主题",
    "author": "Developer",
    "version": "1.0.0",
    "baseTheme": "dark",
    "path": "themes/custom-dark.theme.js",
    "enabled": true,
    "config": {
      "autoApply": true,
      "highContrast": false
    }
  }
}
```

## 📦 扩展打包与分发

### 扩展包结构
```
custom-extension/
├── manifest.json        # 扩展清单
├── main.js             # 主入口文件
├── config/             # 配置目录
│   ├── default.json
│   └── schema.json
├── assets/             # 资源文件
│   ├── icons/
│   └── styles/
├── docs/               # 扩展文档
│   ├── README.md
│   └── CHANGELOG.md
└── tests/              # 测试文件
    ├── unit/
    └── integration/
```

### 扩展清单文件
```json
// manifest.json
{
  "name": "custom-extension",
  "version": "1.0.0",
  "description": "自定义扩展包",
  "author": "Developer Name",
  "license": "MIT",

  "extensions": [
    {
      "type": "skill",
      "id": "custom-skill",
      "name": "自定义技能",
      "entry": "skills/custom-skill.js"
    },
    {
      "type": "rule",
      "id": "custom-rule",
      "name": "自定义规则",
      "entry": "rules/custom-rule.js"
    }
  ],

  "dependencies": {
    "cursor-ai-rules": ">=9.0.0"
  },

  "keywords": ["analysis", "automation"],
  "repository": "https://github.com/user/custom-extension",
  "homepage": "https://custom-extension.dev"
}
```

### 分发方式
1. **GitHub发布**: 在GitHub上发布扩展包
2. **NPM包**: 通过NPM发布可安装包
3. **官方市场**: 提交到Cursor AI Rules官方扩展市场

---

## 📚 相关文档

- [系统架构](architecture.md) - 了解扩展架构基础
- [API参考](api-reference.md) - 扩展开发API
- [配置管理](../admin/configuration.md) - 扩展配置管理

---

*最后更新: 2026-01-22 | 版本: v9.0.0 | 状态: 🔧 扩展开发指南完成*