# Cursor AI Rules 插件系统

## 概述

插件系统允许开发者扩展Master命令系统的功能，通过模块化的方式添加新的组件和功能。

## 插件结构

每个插件都应该遵循以下目录结构：

```
plugins/
├── your-plugin-name/
│   ├── manifest.json      # 插件清单文件
│   ├── component-1.js     # 组件实现文件
│   ├── component-2.js     # 更多组件...
│   ├── init.js           # 可选的初始化脚本
│   ├── cleanup.js        # 可选的清理脚本
│   └── README.md         # 可选的插件说明文档
```

## 插件清单 (manifest.json)

插件清单定义了插件的基本信息和组件：

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "插件的简要描述",
  "author": "插件作者",
  "priority": 50,
  "dependencies": ["other-plugin"],
  "components": [
    {
      "name": "componentName",
      "module": "component-file.js",
      "description": "组件描述",
      "dependencies": ["other-component"],
      "singleton": true
    }
  ],
  "hooks": {
    "onLoad": "init.js",
    "onUnload": "cleanup.js"
  },
  "permissions": [
    "file:read",
    "file:write",
    "network:http"
  ]
}
```

### 字段说明

- `name`: 插件唯一标识符
- `version`: 插件版本号
- `description`: 插件功能描述
- `author`: 插件作者信息
- `priority`: 加载优先级 (数字越大优先级越高)
- `dependencies`: 依赖的其他插件
- `components`: 插件提供的组件列表
- `hooks`: 生命周期钩子脚本
- `permissions`: 插件需要的权限

## 组件开发

组件应该是一个ES6类，遵循以下约定：

```javascript
class YourComponent {
    constructor(projectRoot, options = {}) {
        this.projectRoot = projectRoot;
        this.options = options;
    }

    async initialize() {
        // 组件初始化逻辑
        console.log('组件正在初始化...');
    }

    // 组件方法...

    cleanup() {
        // 组件清理逻辑
        console.log('组件正在清理...');
    }
}

module.exports = YourComponent;
```

## 权限系统

插件可以请求以下权限：

- `file:read` - 读取文件权限
- `file:write` - 写入文件权限
- `network:http` - HTTP网络访问权限
- `network:websocket` - WebSocket连接权限
- `console:log` - 控制台输出权限
- `system:exec` - 系统命令执行权限

## 生命周期

1. **发现**: 系统扫描插件目录，发现插件清单
2. **验证**: 验证插件清单格式和依赖
3. **注册**: 将插件组件注册到组件管理器
4. **初始化**: 执行插件的初始化脚本
5. **使用**: 按需加载和使用组件
6. **清理**: 卸载插件时执行清理脚本

## API 使用

### 启用/禁用插件

```javascript
// 在代码中
componentManager.enablePlugin('your-plugin-name');
componentManager.disablePlugin('your-plugin-name');

// 检查插件状态
const isEnabled = componentManager.isPluginEnabled('your-plugin-name');
```

### 获取插件组件

```javascript
// 获取插件提供的组件
const component = await componentManager.getComponent('your-plugin-name.yourComponent');

// 使用组件
const result = await component.doSomething(params);
```

## 内置插件

| 插件 | 说明 |
|------|------|
| `example-plugin/` | 示例插件，演示基本结构 |
| `quality-check/` | 质量检查插件，封装 quality-manager 能力 |

## 开发示例

参考 `example-plugin/` 和 `quality-check/` 目录中的实现。

## 最佳实践

1. **命名规范**: 使用小写字母和连字符命名插件
2. **错误处理**: 在组件中妥善处理错误
3. **资源清理**: 在cleanup方法中释放所有资源
4. **依赖管理**: 明确声明组件依赖关系
5. **权限最小化**: 只请求必要的权限
6. **文档完善**: 为插件和组件编写详细文档

## 调试和测试

- 使用 `componentManager.getStats()` 查看系统状态
- 检查控制台日志了解组件加载情况
- 使用 `componentManager.getHealthReport()` 诊断问题

## 发布和分发

插件可以打包分发给其他开发者使用，只需要包含插件目录的完整内容即可。