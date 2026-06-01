# Python Mcp Server — Full Guide

# 🐍 Python MCP Server 实现指南 (本地化)

*基于 Model Context Protocol Python SDK | 下载时间: 2026-01-16*

## 项目结构

### 推荐的项目结构

```
mcp-python-server/
├── src/
│   ├── __init__.py       # 包初始化
│   ├── server.py         # 主服务器文件
│   ├── tools/            # 工具模块
│   │   ├── __init__.py
│   │   ├── weather.py    # 天气工具
│   │   ├── calculator.py # 计算器工具
│   │   └── filesystem.py # 文件系统工具
│   ├── models/           # 数据模型
│   │   ├── __init__.py
│   │   └── weather.py
│   └── utils/            # 工具函数
│       ├── __init__.py
│       └── validation.py
├── tests/                # 测试文件
│   ├── __init__.py
│   └── test_server.py
├── pyproject.toml        # 项目配置
└── README.md
```

## 服务器初始化模式

### 使用FastMCP (推荐)

```python
from mcp import Tool
from mcp.server.fastmcp import FastMCP

# 创建FastMCP服务器
app = FastMCP("example-server")

# 或者使用低级API
from mcp import Server
from mcp.server.stdio import stdio_server

server = Server("example-server")
```

### 低级API实现

```python
import asyncio
from mcp import Server, NotificationOptions, types
from mcp.server.stdio import stdio_server

# 创建服务器实例
server = Server("example-server")

# 定义工具
@server.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="get_weather",
            description="获取指定地点的天气信息",
            inputSchema={
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "城市或地点名称"
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "default": "celsius",
                        "description": "温度单位"
                    }
                },
                "required": ["location"]
            }
        )
    ]

# 实现工具调用
@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "get_weather":
        location = arguments.get("location", "New York")
        unit = arguments.get("unit", "celsius")

        # 模拟天气API调用
        temperature = 22 if unit == "celsius" else 72
        unit_symbol = "°C" if unit == "celsius" else "°F"

        return [
            types.TextContent(
                type="text",
                text=f"📍 {location}: {temperature}{unit_symbol}, 晴天"
            )
        ]

    raise ValueError(f"Unknown tool: {name}")

# 启动服务器
async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
```

## Pydantic模型示例

### 数据模型定义

```python
from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum

class TemperatureUnit(str, Enum):
    CELSIUS = "celsius"
    FAHRENHEIT = "fahrenheit"

class WeatherRequest(BaseModel):
    location: str = Field(..., description="城市或地点名称")
    unit: TemperatureUnit = Field(default=TemperatureUnit.CELSIUS, description="温度单位")

class WeatherResponse(BaseModel):
    temperature: float = Field(..., description="温度数值")
    unit: TemperatureUnit
    description: str = Field(..., description="天气描述")
    location: str

class Coordinates(BaseModel):
    latitude: float
    longitude: float
```

### 工具注册模式

```python
from mcp import Tool
from mcp.server.fastmcp import FastMCP

app = FastMCP("weather-server")

@app.tool()
async def get_weather(location: str, unit: str = "celsius") -> str:
    """
    获取指定地点的天气信息

    Args:
        location: 城市或地点名称
        unit: 温度单位 ('celsius' 或 'fahrenheit')

    Returns:
        天气信息字符串
    """
    # 验证输入
    if not location.strip():
        raise ValueError("Location cannot be empty")

    if unit not in ["celsius", "fahrenheit"]:
        raise ValueError("Unit must be 'celsius' or 'fahrenheit'")

    # 模拟API调用
    temperature = 22 if unit == "celsius" else 72
    unit_symbol = "°C" if unit == "celsius" else "°F"

    return f"📍 {location}: {temperature}{unit_symbol}, 晴天"

@app.tool()
async def calculate(expression: str) -> str:
    """
    计算数学表达式

    注意：这是一个简化示例，生产环境中应该使用更安全的数学库

    Args:
        expression: 数学表达式字符串

    Returns:
        计算结果
    """
    try:
        # 安全检查（简化版）
        if any(char in expression for char in ['__', 'import', 'exec', 'eval']):
            raise ValueError("Unsafe expression")

        result = eval(expression, {"__builtins__": {}}, {})
        return f"{expression} = {result}"
    except Exception as e:
        return f"计算错误: {str(e)}"
```

## 文件系统工具示例

### 完整的文件系统工具

```python
import os
import asyncio
from pathlib import Path
from typing import List, Dict, Any
from mcp.server.fastmcp import FastMCP

app = FastMCP("filesystem-server")

@app.tool()
async def list_directory(path: str = ".", show_hidden: bool = False) -> str:
    """
    列出目录内容

    Args:
        path: 目录路径（默认为当前目录）
        show_hidden: 是否显示隐藏文件

    Returns:
        目录内容列表
    """
    try:
        path_obj = Path(path).resolve()

        if not path_obj.exists():
            return f"❌ 路径不存在: {path}"

        if not path_obj.is_dir():
            return f"❌ 不是目录: {path}"

        entries = []
        for item in path_obj.iterdir():
            if not show_hidden and item.name.startswith('.'):
                continue

            item_type = "📁" if item.is_dir() else "📄"
            entries.append(f"{item_type} {item.name}")

        result = f"📂 {path} 目录内容:\n"
        result += "\n".join(entries) if entries else "目录为空"

        return result

    except Exception as e:
        return f"❌ 读取目录失败: {str(e)}"

@app.tool()
async def read_file(file_path: str, max_lines: int = 50) -> str:
    """
    读取文件内容

    Args:
        file_path: 文件路径
        max_lines: 最大读取行数（防止大文件）

    Returns:
        文件内容
    """
    try:
        path_obj = Path(file_path).resolve()

        if not path_obj.exists():
            return f"❌ 文件不存在: {file_path}"

        if not path_obj.is_file():
            return f"❌ 不是文件: {file_path}"

        # 检查文件大小（限制为1MB）
        if path_obj.stat().st_size > 1024 * 1024:
            return f"❌ 文件过大: {path_obj.stat().st_size} bytes (限制: 1MB)"

        content = path_obj.read_text(encoding='utf-8')

        lines = content.split('\n')
        if len(lines) > max_lines:
            content = '\n'.join(lines[:max_lines])
            content += f"\n\n... (文件过长，只显示前 {max_lines} 行)"

        return f"📄 {file_path} 内容:\n```\n{content}\n```"

    except UnicodeDecodeError:
        return f"❌ 文件编码错误，无法读取: {file_path}"
    except Exception as e:
        return f"❌ 读取文件失败: {str(e)}"

@app.tool()
async def get_file_info(file_path: str) -> str:
    """
    获取文件信息

    Args:
        file_path: 文件路径

    Returns:
        文件详细信息
    """
    try:
        path_obj = Path(file_path).resolve()

        if not path_obj.exists():
            return f"❌ 文件不存在: {file_path}"

        stat = path_obj.stat()

        info = f"📊 {file_path} 文件信息:\n"
        info += f"类型: {'目录' if path_obj.is_dir() else '文件'}\n"
        info += f"大小: {stat.st_size} bytes\n"
        info += f"修改时间: {stat.st_mtime}\n"
        info += f"权限: {oct(stat.st_mode)[-3:]}"

        return info

    except Exception as e:
        return f"❌ 获取文件信息失败: {str(e)}"
```

## 完整的FastMCP示例

### pyproject.toml

```toml
[project]
name = "mcp-python-server"
version = "1.0.0"
description = "MCP Python Server Example"
requires-python = ">=3.10"
dependencies = [
    "mcp>=0.1.0",
    "fastmcp>=0.9.0",
    "pydantic>=2.0.0",
    "httpx>=0.25.0",  # 用于API调用
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src"]

[project.scripts]
mcp-server = "src.server:main"
```

### 完整服务器示例

```python
#!/usr/bin/env python3
"""
MCP Python Server 示例
使用FastMCP框架实现简单的工具服务器
"""

import asyncio
from mcp.server.fastmcp import FastMCP

# 创建FastMCP应用
app = FastMCP("example-python-server")

@app.tool()
async def echo(message: str) -> str:
    """
    回显输入的消息

    Args:
        message: 要回显的消息

    Returns:
        回显的消息
    """
    return f"🔊 Echo: {message}"

@app.tool()
async def get_current_time(timezone: str = "UTC") -> str:
    """
    获取当前时间

    Args:
        timezone: 时区名称（默认为UTC）

    Returns:
        格式化的时间字符串
    """
    from datetime import datetime
    import zoneinfo

    try:
        # 使用zoneinfo处理时区（Python 3.9+）
        tz = zoneinfo.ZoneInfo(timezone)
        current_time = datetime.now(tz)

        formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S %Z")
        return f"🕐 Current time in {timezone}: {formatted_time}"

    except zoneinfo.ZoneInfoNotFoundError:
        return f"❌ Unknown timezone: {timezone}"
    except Exception as e:
        return f"❌ Error getting time: {str(e)}"

@app.tool()
async def simple_calculator(a: float, b: float, operation: str) -> str:
    """
    简单的计算器

    Args:
        a: 第一个数字
        b: 第二个数字
        operation: 操作符 (+, -, *, /)

    Returns:
        计算结果
    """
    try:
        if operation == "+":
            result = a + b
        elif operation == "-":
            result = a - b
        elif operation == "*":
            result = a * b
        elif operation == "/":
            if b == 0:
                return "❌ Division by zero"
            result = a / b
        else:
            return f"❌ Unsupported operation: {operation}"

        return f"🧮 {a} {operation} {b} = {result}"

    except Exception as e:
        return f"❌ Calculation error: {str(e)}"

if __name__ == "__main__":
    # 启动服务器
    import mcp.server.stdio
    mcp.server.stdio.stdio_server()(app.to_server())
```

## 质量检查清单

### 代码质量
- [ ] 使用类型注解
- [ ] 所有函数都有文档字符串
- [ ] 错误处理完善
- [ ] 输入验证严格

### 工具设计
- [ ] 每个工具职责单一
- [ ] 参数类型明确
- [ ] 错误信息友好
- [ ] 响应格式一致

### 测试验证
- [ ] python -m py_compile 通过
- [ ] 使用MCP Inspector测试
- [ ] 所有工具功能正常
- [ ] 边界情况处理正确

### 依赖管理
- [ ] pyproject.toml 配置正确
- [ ] 依赖版本合理
- [ ] 安全漏洞检查

---

*此指南基于 Model Context Protocol Python SDK 官方文档，提供完整的Python MCP服务器实现参考。*
