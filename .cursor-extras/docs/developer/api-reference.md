# 📚 API参考文档

*完整的组件接口和使用指南*

## 🎯 Capability Maps 组件映射

### 核心组件总览

| 功能领域 | 核心脚本 | 相关模块 | 钩子支持 |
|---------|---------|---------|---------|
| **代码质量** | `quality-manager.sh` | `logging-module.sh` | `code-quality.sh` |
| **版本控制** | `git-manager.sh` | - | `pre-commit.sh`, `commit-msg.sh` |
| **代码格式** | `format-manager.sh` | `file-module.sh` | `pre-commit-format.sh` |
| **测试执行** | `test-runner.sh` | - | `test-pre-run.sh` |
| **安全审计** | `security-auditor.sh` | - | `security-pre-commit.sh` |
| **文档生成** | `docs-generator.sh` | `json-module.sh` | - |
| **性能优化** | `optimizer.sh` | `logging-module.sh` | - |
| **环境感知** | `env-perception.sh` | `cli-framework.sh` | `env-perception.sh` |
| **配置管理** | `config-manager.sh` | `json-module.sh` | - |
| **代码重构** | `refactor-manager.sh` | `file-module.sh` | - |
| **学习管理** | `learning-manager.sh` | `json-module.sh` | `learning-progress-tracker.sh` |
| **角色系统** | `role-manager.js` | - | - |
| **钩子引擎** | `hooks-engine.sh` | `cli-framework.sh` | 所有钩子 |
| **技能加载** | `skills-loader.sh` | - | - |

## 🏗️ 系统架构详解

### 分层架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                    Cursor AI Rules 系统架构                  │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │                🎯 Rules 层 (规则定义)               │    │
│  │  • 技术规则 (JavaScript, Python, Java...)          │    │
│  │  • 工作流规则 (意图分析, 生成器, 模板...)          │    │
│  │  • 系统规则 (平台适配, 系统信息...)               │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               🛠️ Skills 层 (技能执行)              │    │
│  │  • 代码分析技能 (ESLint, 性能分析...)              │    │
│  │  • 开发工具技能 (Git, 测试, 部署...)               │    │
│  │  • AI增强技能 (意图理解, 代码生成...)              │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              📜 Scripts 层 (脚本执行)               │    │
│  │  • 核心脚本 (质量管理, 格式化, 测试...)            │    │
│  │  • 工具脚本 (Git管理, 文档生成...)                 │    │
│  │  • 系统脚本 (环境感知, 配置管理...)                │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            🔗 Workflows 层 (工作流编排)            │    │
│  │  • 项目初始化工作流                                │    │
│  │  • 代码提交工作流                                  │    │
│  │  • 持续集成工作流                                  │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               🎣 Hooks 层 (生命周期钩子)            │    │
│  │  • 提交前钩子 (质量检查, 格式化...)               │    │
│  │  • 提交后钩子 (通知, 同步...)                      │    │
│  │  • 项目钩子 (初始化, 配置...)                      │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Rules API (规则系统)

### 规则定义接口

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

### 规则使用示例

```javascript
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
    }
  ];

  static actions = [
    {
      type: 'report',
      message: '命名不符合规范: {{name}}',
      severity: 'warning'
    }
  ];

  static validate(context) {
    // 规则验证逻辑
    return issues;
  }
}

module.exports = CustomNamingRule;
```

## 🛠️ Skills API (技能系统)

### 技能定义接口

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

### 技能实现示例

```javascript
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
    }
  ];

  static async execute(context) {
    const { target } = context.parameters;
    // 技能执行逻辑
    return { success: true, data: analysis };
  }
}

module.exports = CustomAnalysisSkill;
```

## 📜 Scripts API (脚本系统)

### 脚本架构

```bash
# 脚本标准化模板
#!/bin/bash

# 脚本元数据
SCRIPT_NAME="example-script"
SCRIPT_VERSION="1.0.0"
SCRIPT_DESCRIPTION="示例脚本"

# 导入共享函数
source "$(dirname "$0")/../core/shared-functions.sh"

# 参数解析
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --help|-h)
        show_help
        exit 0
        ;;
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done
}

# 主函数
main() {
  parse_args "$@"

  # 脚本主体逻辑
  echo "执行脚本逻辑..."

  return 0
}

# 执行主函数
main "$@"
```

### 核心脚本列表

| 脚本名称 | 功能描述 | 相关模块 |
|---------|---------|---------|
| `quality-manager.sh` | 代码质量管理 | `logging-module.sh` |
| `git-manager.sh` | Git版本控制 | - |
| `format-manager.sh` | 代码格式化 | `file-module.sh` |
| `test-runner.sh` | 测试执行 | - |
| `security-auditor.sh` | 安全审计 | - |
| `docs-generator.sh` | 文档生成 | `json-module.sh` |
| `env-perception.sh` | 环境感知 | `cli-framework.sh` |
| `config-manager.sh` | 配置管理 | `json-module.sh` |

## 🔗 Workflows API (工作流系统)

### 工作流定义

```typescript
interface Workflow {
  id: string;
  name: string;
  description: string;
  trigger: WorkflowTrigger;
  steps: WorkflowStep[];
  config?: WorkflowConfig;
}

interface WorkflowStep {
  id: string;
  name: string;
  type: 'script' | 'skill' | 'rule' | 'hook';
  target: string;
  parameters?: Record<string, any>;
  conditions?: WorkflowCondition[];
}

interface WorkflowTrigger {
  type: 'manual' | 'auto' | 'hook';
  events?: string[];
  schedule?: string;
}
```

### 工作流示例

```json
{
  "id": "commit-workflow",
  "name": "代码提交工作流",
  "description": "自动化代码提交前的质量检查",
  "trigger": {
    "type": "hook",
    "events": ["pre-commit"]
  },
  "steps": [
    {
      "id": "format-check",
      "name": "代码格式检查",
      "type": "script",
      "target": "format-manager.sh",
      "parameters": { "check-only": true }
    },
    {
      "id": "quality-check",
      "name": "代码质量检查",
      "type": "script",
      "target": "quality-manager.sh"
    },
    {
      "id": "test-run",
      "name": "单元测试执行",
      "type": "script",
      "target": "test-runner.sh"
    }
  ]
}
```

## 🎣 Hooks API (钩子系统)

### 钩子定义接口

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
  PROJECT_INIT = 'project-init'
}

type HookHandler = (context: HookContext) => Promise<HookResult>;
```

### 钩子实现示例

```javascript
// hooks/pre-commit-quality.hook.js
class PreCommitQualityHook {
  static id = 'pre-commit-quality';
  static name = '提交前质量检查';
  static description = '在代码提交前执行质量检查';

  static event = 'pre-commit';
  static priority = 10;

  static condition = {
    filePattern: 'src/**/*.{js,ts,jsx,tsx}',
    excludePattern: 'node_modules/**'
  };

  static async handler(context) {
    const { changedFiles, logger } = context;

    logger.info('开始执行提交前质量检查...');

    // 执行质量检查
    const qualityResult = await runQualityChecks(changedFiles);

    if (!qualityResult.passed) {
      logger.error('质量检查失败:');
      qualityResult.issues.forEach(issue => {
        logger.error(`- ${issue.file}:${issue.line}: ${issue.message}`);
      });
      throw new Error('质量检查未通过，无法提交');
    }

    logger.info('✅ 质量检查通过');
    return { success: true };
  }
}

module.exports = PreCommitQualityHook;
```

## 🔧 实用工具 API

### 文件操作模块

```typescript
interface FileOperations {
  // 读取文件
  readFile(path: string): Promise<string>;

  // 写入文件
  writeFile(path: string, content: string): Promise<void>;

  // 查找文件
  findFiles(pattern: string, cwd?: string): Promise<string[]>;

  // 目录操作
  ensureDir(path: string): Promise<void>;
  removeDir(path: string): Promise<void>;
}
```

### JSON处理模块

```typescript
interface JsonOperations {
  // 读取JSON文件
  readJson<T = any>(path: string): Promise<T>;

  // 写入JSON文件
  writeJson(path: string, data: any): Promise<void>;

  // JSON路径查询
  query(path: string, jsonPath: string): Promise<any>;

  // JSON合并
  merge(target: any, source: any): any;
}
```

### 日志模块

```typescript
interface LoggingOperations {
  // 日志级别
  debug(message: string, meta?: any): void;
  info(message: string, meta?: any): void;
  warn(message: string, meta?: any): void;
  error(message: string, meta?: any): void;

  // 结构化日志
  log(level: LogLevel, message: string, meta?: any): void;

  // 性能日志
  time(label: string): void;
  timeEnd(label: string): void;
}
```

### CLI框架模块

```typescript
interface CliFramework {
  // 参数解析
  parseArgs(args: string[]): ParsedArgs;

  // 命令注册
  registerCommand(command: Command): void;

  // 帮助生成
  generateHelp(command?: string): string;

  // 输出格式化
  formatOutput(data: any, format: 'json' | 'table' | 'text'): string;
}
```

## 📊 组件使用统计

### 按类别统计

| 类别 | 数量 | 主要组件 |
|------|------|----------|
| Rules | 23+ | 技术规则、工作流规则、系统规则 |
| Skills | 24+ | 代码分析、开发工具、AI增强 |
| Scripts | 17+ | 核心脚本、工具脚本、系统脚本 |
| Workflows | 10+ | 项目初始化、代码提交、持续集成 |
| Hooks | 17+ | 提交钩子、文件变更钩子、项目钩子 |

### 功能覆盖统计

- **代码质量**: ESLint、Prettier、复杂度分析
- **版本控制**: Git操作、分支管理、提交规范
- **测试执行**: 单元测试、集成测试、端到端测试
- **安全审计**: 漏洞扫描、依赖检查、代码审查
- **文档生成**: API文档、README、变更日志
- **环境感知**: 技术栈识别、依赖分析、配置检测
- **学习管理**: 进度跟踪、个性化推荐、效果评估

## 🔍 故障排除

### 常见API问题

#### 技能无法加载
```bash
# 检查技能文件语法
node -c skills/your-skill.skill.js

# 验证技能配置
./.cursor/core/init.sh --validate-skills
```

#### 规则不生效
```bash
# 检查规则配置
cat .cursor/config/rules/your-rule.json

# 测试规则执行
./.cursor/core/test-rule.sh your-rule
```

#### 钩子不触发
```bash
# 检查钩子配置
cat .cursor/features/hooks/hooks.json

# 验证钩子权限
ls -la .cursor/features/hooks/
```

## 📚 扩展阅读

- [架构详解](architecture.md) - 系统架构设计
- [扩展开发指南](extension-guide.md) - 自定义组件开发
- [配置管理](../admin/configuration.md) - 配置系统使用

---

*最后更新: 2026-01-22 | 版本: v9.0.0 | 状态: 📚 API参考文档完成*