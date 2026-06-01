# Node Mcp Server — Full Guide

# ⚡ TypeScript MCP Server 实现指南 (本地化)

*基于 Model Context Protocol TypeScript SDK | 下载时间: 2026-01-16*

## 项目结构

### 推荐的项目结构

```
mcp-typescript-server/
├── src/
│   ├── index.ts          # 服务器入口
│   ├── tools/            # 工具定义
│   │   ├── weather.ts    # 天气工具
│   │   ├── calculator.ts # 计算器工具
│   │   └── filesystem.ts # 文件系统工具
│   ├── types/            # 类型定义
│   │   └── index.ts
│   └── utils/            # 工具函数
│       └── validation.ts
├── package.json
├── tsconfig.json
└── README.md
```

## 服务器初始化模式

### 基本服务器设置

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server(
  {
    name: 'example-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {}, // 启用工具支持
    },
  }
);

// 使用stdio传输（本地工具）
const transport = new StdioServerTransport();
await server.connect(transport);
```

### HTTP服务器设置

```typescript
import { SSEServerTransport } from '@modelcontextprotocol/sdk/server/sse.js';
import express from 'express';

const app = express();

// MCP SSE传输
app.get('/sse', async (req, res) => {
  const transport = new SSEServerTransport(res, req);
  await server.connect(transport);
});

app.listen(3000, () => {
  console.log('MCP server listening on port 3000');
});
```

## Zod模式

### 基础模式定义

```typescript
import { z } from 'zod';

// 参数验证模式
const WeatherParams = z.object({
  location: z.string().min(1).describe('城市或地点名称'),
  unit: z.enum(['celsius', 'fahrenheit']).default('celsius').describe('温度单位'),
});

const CalculatorParams = z.object({
  expression: z.string().min(1).describe('数学表达式'),
});

// 响应模式
const WeatherResponse = z.object({
  temperature: z.number(),
  unit: z.string(),
  description: z.string(),
  location: z.string(),
});
```

### 工具注册模式

```typescript
// 天气工具
server.registerTool(
  'get_weather',
  '获取指定地点的天气信息',
  WeatherParams.shape,
  async (args) => {
    const { location, unit } = args;

    // 调用天气API
    const weatherData = await fetchWeatherData(location, unit);

    return {
      content: [{
        type: 'text',
        text: `📍 ${location}: ${weatherData.temperature}°${unit === 'celsius' ? 'C' : 'F'}, ${weatherData.description}`
      }]
    };
  }
);

// 计算器工具
server.registerTool(
  'calculate',
  '计算数学表达式',
  CalculatorParams.shape,
  async (args) => {
    const { expression } = args;

    try {
      // 注意：生产环境中应该使用安全的数学库
      const result = eval(expression);

      return {
        content: [{
          type: 'text',
          text: `${expression} = ${result}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `计算错误: ${error.message}`
        }],
        isError: true
      };
    }
  }
);
```

## 工具注册示例

### 文件系统工具

```typescript
import { z } from 'zod';
import { promises as fs } from 'fs';
import { join } from 'path';

const ListFilesParams = z.object({
  path: z.string().default('.').describe('目录路径'),
  recursive: z.boolean().default(false).describe('是否递归列出'),
});

const ReadFileParams = z.object({
  path: z.string().describe('文件路径'),
  encoding: z.enum(['utf8', 'base64']).default('utf8').describe('文件编码'),
});

server.registerTool(
  'list_files',
  '列出目录中的文件',
  ListFilesParams.shape,
  async (args) => {
    const { path, recursive } = args;

    try {
      const entries = await fs.readdir(path, { withFileTypes: true });
      const files = entries.map(entry => ({
        name: entry.name,
        type: entry.isDirectory() ? 'directory' : 'file',
        path: join(path, entry.name)
      }));

      return {
        content: [{
          type: 'text',
          text: `📁 ${path} 中的文件:\n${files.map(f => `${f.type === 'directory' ? '📁' : '📄'} ${f.name}`).join('\n')}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `读取目录失败: ${error.message}`
        }],
        isError: true
      };
    }
  }
);

server.registerTool(
  'read_file',
  '读取文件内容',
  ReadFileParams.shape,
  async (args) => {
    const { path, encoding } = args;

    try {
      const content = await fs.readFile(path, encoding);

      return {
        content: [{
          type: 'text',
          text: `📄 ${path} 内容:\n\`\`\`\n${content}\n\`\`\``
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `读取文件失败: ${error.message}`
        }],
        isError: true
      };
    }
  }
);
```

## 完整的示例

### package.json

```json
{
  "name": "mcp-typescript-server",
  "version": "1.0.0",
  "description": "MCP TypeScript Server Example",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsx src/index.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.4.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### 完整服务器示例

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

// 参数模式
const EchoParams = z.object({
  message: z.string().describe('要回显的消息'),
});

const TimeParams = z.object({
  timezone: z.string().default('UTC').describe('时区'),
});

// 创建服务器
const server = new Server(
  {
    name: 'example-typescript-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 注册工具
server.registerTool(
  'echo',
  '回显输入的消息',
  EchoParams.shape,
  async (args) => {
    const { message } = args;

    return {
      content: [{
        type: 'text',
        text: `🔊 Echo: ${message}`
      }]
    };
  }
);

server.registerTool(
  'get_time',
  '获取当前时间',
  TimeParams.shape,
  async (args) => {
    const { timezone } = args;

    const now = new Date();
    const timeString = now.toLocaleString('en-US', {
      timeZone: timezone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });

    return {
      content: [{
        type: 'text',
        text: `🕐 Current time in ${timezone}: ${timeString}`
      }]
    };
  }
);

// 启动服务器
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('TypeScript MCP server started');
}

main().catch(console.error);
```

## 质量检查清单

### 代码质量
- [ ] 使用TypeScript严格模式
- [ ] 所有参数都有Zod验证
- [ ] 错误处理完善
- [ ] 代码有适当注释

### 工具设计
- [ ] 每个工具职责单一
- [ ] 参数描述清晰
- [ ] 错误信息友好
- [ ] 响应格式一致

### 测试验证
- [ ] npm run build 通过
- [ ] 使用MCP Inspector测试
- [ ] 所有工具功能正常
- [ ] 错误情况处理正确

---

*此指南基于 Model Context Protocol TypeScript SDK 官方文档，提供完整的TypeScript MCP服务器实现参考。*
