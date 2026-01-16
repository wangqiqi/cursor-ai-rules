# 🎯 Skills API 文档

Cursor AI Rules 的技能系统提供了可扩展的 AI 能力增强机制，支持按需安装和自动激活。

## 📋 技能系统概述

### 技能分类

| 分类       | 描述           | 示例                        |
| ---------- | -------------- | --------------------------- |
| `core`     | 基础必备技能   | 代码质量检查、安全审计      |
| `tech`     | 技术栈特定技能 | Node.js、Python、Go开发技能 |
| `tooling`  | 工具链技能     | Docker、Kubernetes、云服务  |
| `workflow` | 工作流技能     | 测试、CI/CD、文档编写       |

### 技能生命周期

```
注册 → 检测 → 安装 → 激活 → 运行 → 更新/卸载
   ↓      ↓      ↓      ↓      ↓        ↓
 技能注册表 环境检测 依赖检查  软链接   执行    版本管理
```

## 🔧 技能注册表

### 注册表结构

```json
{
  "version": "2.0.0",
  "skills": {
    "tech": {
      "nodejs": {
        "name": "Node.js 开发",
        "description": "Node.js 和 JavaScript 开发技能",
        "category": "tech",
        "auto_install": false,
        "path": "tech/nodejs.md",
        "conditions": {
          "files": ["package.json"],
          "commands": ["node", "npm"]
        },
        "dependencies": ["javascript"]
      }
    }
  },
  "auto_install_rules": {
    "always": ["code-quality", "security-audit"],
    "by_tech_stack": {
      "node": ["nodejs", "testing"]
    }
  }
}
```

### 技能定义字段

| 字段           | 类型    | 必需 | 描述                      |
| -------------- | ------- | ---- | ------------------------- |
| `name`         | string  | 是   | 技能显示名称              |
| `description`  | string  | 是   | 技能功能描述              |
| `category`     | string  | 是   | 技能分类                  |
| `auto_install` | boolean | 否   | 是否自动安装（默认false） |
| `path`         | string  | 是   | 技能文件路径              |
| `conditions`   | object  | 否   | 安装条件                  |
| `dependencies` | array   | 否   | 依赖的其他技能            |

## 🚀 技能安装和激活

### 自动安装

系统会根据检测到的环境自动安装适配的技能：

```bash
# 初始化时自动安装
.cursor/core/init.sh

# 系统会：
# 1. 检测 package.json → 安装 nodejs 技能
# 2. 检测 requirements.txt → 安装 python 技能
# 3. 检测 .github/workflows → 安装 ci-cd 技能
```

### 手动安装

```bash
# 查看可用技能
.cursor/automation/scripts/skill-list.sh

# 安装特定技能
.cursor/automation/scripts/skill-install.sh nodejs

# 批量安装
.cursor/automation/scripts/skill-install.sh react vue testing

# 强制重新安装
.cursor/automation/scripts/skill-install.sh --force nodejs
```

### 技能激活

安装后，技能通过软链接激活：

```bash
# 查看激活的技能
ls -la .cursor/skills/active/

# 激活的技能会链接到对应的技能文件
# nodejs -> ../tech/nodejs.md
# react -> ../tech/react.md
```

## 🛠️ 技能开发

### 技能文件结构

Agent Skills 使用 Markdown 格式：

```markdown
---
name: my-custom-skill
description: 自定义技能描述
---

# 🎯 技能标题

技能的详细描述和使用说明。

## When to Use

- 使用场景1
- 使用场景2

## Instructions

详细的使用指导和最佳实践。

## Dependencies

- 依赖1
- 依赖2

## Examples

实际使用示例。
```

### 传统技能格式

兼容旧的技能格式：

```markdown
---
command: skill:my-skill
description: "技能描述"
alwaysApply: false
---

# 🎯 技能标题

技能内容和说明。
```

### 创建新技能

1. **确定技能范围和目标**
```bash
# 定义技能的目标用户和技术领域
# 例如：React 组件开发技能
```

2. **编写技能内容**
```bash
# 创建技能文件
cat > .cursor/skills/tech/react-components.md << 'EOF'
---
name: react-components
description: React 组件开发技能和最佳实践
---

# ⚛️ React 组件开发

React 组件开发的最佳实践和模式。

## When to Use

- 创建新的 React 组件
- 重构现有组件
- 优化组件性能

## Instructions

### 组件设计原则

1. **单一职责**: 每个组件只负责一个功能
2. **可复用性**: 设计可复用的组件接口
3. **性能优化**: 使用适当的优化技术

### 常用模式

#### 函数组件 + Hooks
```tsx
import React, { useState, useEffect } from 'react';

interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

export const UserProfile: React.FC<UserProfileProps> = ({
  userId,
  onUpdate
}) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchUser = async () => {
      setLoading(true);
      try {
        const userData = await api.getUser(userId);
        setUser(userData);
        onUpdate?.(userData);
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId, onUpdate]);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
};
```

#### 自定义 Hooks
```tsx
import { useState, useEffect } from 'react';

export const useLocalStorage = <T>(
  key: string,
  initialValue: T
): [T, (value: T) => void] => {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.warn('Error reading localStorage:', error);
      return initialValue;
    }
  });

  const setValue = (value: T) => {
    try {
      setStoredValue(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.warn('Error setting localStorage:', error);
    }
  };

  return [storedValue, setValue];
};
```

## Dependencies

- React 16.8+
- TypeScript (推荐)
- ESLint + Prettier

## Examples

### 完整组件示例

```tsx
// components/UserDashboard.tsx
import React from 'react';
import { UserProfile } from './UserProfile';
import { useLocalStorage } from '../hooks/useLocalStorage';

export const UserDashboard: React.FC = () => {
  const [theme, setTheme] = useLocalStorage('theme', 'light');

  const handleUserUpdate = (user: User) => {
    console.log('User updated:', user);
    // 处理用户更新逻辑
  };

  return (
    <div className={`dashboard ${theme}`}>
      <header>
        <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
          切换主题
        </button>
      </header>

      <main>
        <UserProfile
          userId="123"
          onUpdate={handleUserUpdate}
        />
      </main>
    </div>
  );
};
```
EOF
```

3. **注册技能**
```json
// 添加到 .cursor/skills/registry.json
{
  "tech": {
    "react-components": {
      "name": "React 组件开发",
      "description": "React 组件开发技能和最佳实践",
      "category": "tech",
      "auto_install": false,
      "path": "tech/react-components.md",
      "conditions": {
        "dependencies": ["react"],
        "files": ["src/App.js", "src/App.tsx"]
      },
      "dependencies": ["javascript", "nodejs"]
    }
  }
}
```

4. **测试技能**
```bash
# 安装技能
.cursor/automation/scripts/skill-install.sh react-components

# 验证安装
ls -la .cursor/skills/active/react-components*

# 测试技能激活
echo "Test React component development" | cursor-chat
```

## 🔧 技能管理工具

### 技能列表
```bash
.cursor/automation/scripts/skill-list.sh
# 显示所有可用技能

.cursor/automation/scripts/skill-list.sh --installed
# 显示已安装的技能

.cursor/automation/scripts/skill-list.sh --category tech
# 显示技术类技能
```

### 技能状态检查
```bash
.cursor/automation/scripts/skill-status.sh
# 检查技能安装状态和健康情况

.cursor/automation/scripts/skill-status.sh nodejs
# 检查特定技能状态
```

### 技能更新
```bash
.cursor/automation/scripts/skill-update.sh
# 更新所有已安装的技能

.cursor/automation/scripts/skill-update.sh nodejs
# 更新特定技能
```

### 技能卸载
```bash
.cursor/automation/scripts/skill-remove.sh unused-skill
# 卸载不需要的技能

.cursor/automation/scripts/skill-cleanup.sh
# 清理未使用的技能文件
```

## 📊 技能使用统计

系统会自动跟踪技能使用情况：

```bash
# 查看技能使用统计
cat .cursor/logs/skill-usage.json

# 生成使用报告
.cursor/automation/scripts/skill-report.sh
```

统计信息包括：
- 技能激活频率
- 使用成功率
- 平均响应时间
- 用户满意度评分

## 🔒 技能安全

### 安全检查
- **依赖验证**: 确保技能依赖的安全性
- **代码审查**: 定期审查技能代码
- **权限控制**: 限制技能的系统访问权限
- **更新验证**: 验证技能更新的完整性

### 隔离执行
```bash
# 技能在沙箱环境中执行
# 限制文件系统访问
# 控制网络请求
# 监控资源使用
```

## 🎯 最佳实践

### 技能设计原则
1. **专注单一领域**: 每个技能解决特定问题
2. **渐进式增强**: 从简单功能开始，逐步完善
3. **文档完备**: 提供详细的使用说明和示例
4. **向后兼容**: 保持API的稳定性

### 性能优化
- **延迟加载**: 只在需要时加载技能
- **缓存机制**: 缓存技能执行结果
- **资源限制**: 控制技能的资源消耗
- **异步处理**: 使用异步方式处理复杂任务

### 用户体验
- **智能推荐**: 根据上下文推荐相关技能
- **渐进式引导**: 帮助用户发现和学习新技能
- **反馈收集**: 收集用户对技能的反馈和建议
- **个性化定制**: 允许用户自定义技能行为

---

*Skills API v2.0 | Cursor AI Rules 4.2.0*