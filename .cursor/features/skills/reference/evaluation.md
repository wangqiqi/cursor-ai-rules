# ✅ MCP 评估指南 (本地化)

*基于 Model Context Protocol 评估规范 | 下载时间: 2026-01-16*

## 评估概述

MCP评估是验证MCP服务器实现质量的重要机制。通过创建结构化的评估问题，可以：

- 验证工具功能的正确性
- 测试错误处理能力
- 确保响应格式符合规范
- 评估整体用户体验

## 问题创建指南

### 评估问题类型

#### 功能性问题
测试工具的核心功能是否正常工作。

**示例**:
```xml
<question>
  <text>What is the weather like in Tokyo?</text>
  <expected_answer>The response should include current weather information for Tokyo with temperature and conditions.</expected_answer>
  <tools>get_weather</tools>
</question>
```

#### 错误处理问题
测试工具对无效输入的处理能力。

**示例**:
```xml
<question>
  <text>What is the weather like in an empty string location?</text>
  <expected_answer>The tool should return an appropriate error message for invalid location input.</expected_answer>
  <tools>get_weather</tools>
</question>
```

#### 边界条件问题
测试极端输入和边界情况。

**示例**:
```xml
<question>
  <text>What is the weather at coordinates 999.999, 999.999?</text>
  <expected_answer>The tool should handle invalid coordinates gracefully with appropriate error message.</expected_answer>
  <tools>get_weather</tools>
</question>
```

#### 格式验证问题
确保响应格式符合MCP规范。

**示例**:
```xml
<question>
  <text>Calculate 15 + 27</text>
  <expected_answer>The response should be properly formatted with the calculation result and use appropriate content type.</expected_answer>
  <tools>calculate</tools>
</question>
```

## 答案验证策略

### 精确匹配验证
对于确定性结果，使用精确字符串匹配。

```xml
<verification>
  <type>exact_match</type>
  <expected>42</expected>
</verification>
```

### 模式匹配验证
对于变化性结果，使用正则表达式匹配。

```xml
<verification>
  <type>regex</type>
  <pattern>Temperature: \d+°[CF]</pattern>
</verification>
```

### 语义验证
对于复杂响应，使用语义分析。

```xml
<verification>
  <type>semantic</type>
  <criteria>
    <contains>temperature</contains>
    <contains>weather condition</contains>
    <format>readable text</format>
  </criteria>
</verification>
```

### 错误验证
验证错误情况的正确处理。

```xml
<verification>
  <type>error_check</type>
  <expected_error>Invalid location</expected_error>
</verification>
```

## XML格式规范

### 完整评估文件结构

```xml
<mcp_evaluation version="1.0">
  <metadata>
    <title>Weather API Server Evaluation</title>
    <description>Comprehensive evaluation of weather API MCP server</description>
    <server_name>weather-api-server</server_name>
    <version>1.0.0</version>
    <author>Evaluation Team</author>
    <date>2026-01-16</date>
  </metadata>

  <test_suite name="functional_tests">
    <question id="weather_basic">
      <text>What is the weather like in New York?</text>
      <expected_answer>The response should include current temperature and weather conditions for New York.</expected_answer>
      <tools>get_weather</tools>
      <verification>
        <type>semantic</type>
        <criteria>
          <contains>New York</contains>
          <contains>temperature</contains>
          <contains>weather</contains>
          <format>text</format>
        </criteria>
      </verification>
    </question>

    <question id="weather_units">
      <text>What is the temperature in London in Fahrenheit?</text>
      <expected_answer>The response should show temperature in Fahrenheit for London.</expected_answer>
      <tools>get_weather</tools>
      <verification>
        <type>regex</type>
        <pattern>London.*\d+°F</pattern>
      </verification>
    </question>
  </test_suite>

  <test_suite name="error_handling">
    <question id="invalid_location">
      <text>What is the weather in [invalid location]?</text>
      <expected_answer>The tool should return an appropriate error message.</expected_answer>
      <tools>get_weather</tools>
      <verification>
        <type>error_check</type>
        <expected_error>location</expected_error>
      </verification>
    </question>
  </test_suite>
</mcp_evaluation>
```

### 问题元素详解

#### 基本问题结构
```xml
<question id="unique_identifier">
  <text>The question text that will be asked</text>
  <expected_answer>Description of what the correct answer should contain</expected_answer>
  <tools>tool_name_1,tool_name_2</tools>
  <verification>
    <!-- 验证规则 -->
  </verification>
</question>
```

#### 元数据字段
- `id`: 唯一标识符，用于跟踪和报告
- `text`: 实际向MCP服务器提出的问题
- `expected_answer`: 人类可读的正确答案描述
- `tools`: 该问题预期使用的工具名称

## 示例问题和答案

### 天气工具评估

#### 问题1: 基本天气查询
```xml
<question id="weather_paris">
  <text>What's the weather like in Paris?</text>
  <expected_answer>Temperature and weather conditions for Paris</expected_answer>
  <tools>get_weather</tools>
  <verification>
    <type>semantic</type>
    <criteria>
      <contains>Paris</contains>
      <contains>temperature</contains>
      <contains>°C</contains>
    </criteria>
  </verification>
</question>
```

**预期响应**:
```
📍 Paris: 18°C, Partly cloudy
```

#### 问题2: 温度单位转换
```xml
<question id="weather_fahrenheit">
  <text>Give me the temperature in Sydney in Fahrenheit</text>
  <expected_answer>Temperature in Sydney displayed in Fahrenheit</expected_answer>
  <tools>get_weather</tools>
  <verification>
    <type>regex</type>
    <pattern>Sydney.*\d+°F</pattern>
  </verification>
</question>
```

**预期响应**:
```
📍 Sydney: 75°F, Sunny
```

### 计算器工具评估

#### 问题3: 基本数学运算
```xml
<question id="calc_addition">
  <text>What is 25 plus 17?</text>
  <expected_answer>The sum of 25 and 17</expected_answer>
  <tools>calculate</tools>
  <verification>
    <type>exact_match</type>
    <expected>42</expected>
  </verification>
</question>
```

**预期响应**:
```
🧮 25 + 17 = 42
```

#### 问题4: 复杂表达式
```xml
<question id="calc_complex">
  <text>Calculate (10 + 5) * 3 - 2</text>
  <expected_answer>The result of the mathematical expression</expected_answer>
  <tools>calculate</tools>
  <verification>
    <type>exact_match</type>
    <expected>43</expected>
  </verification>
</question>
```

**预期响应**:
```
🧮 (10 + 5) * 3 - 2 = 43
```

### 文件系统工具评估

#### 问题5: 目录列出
```xml
<question id="list_current_dir">
  <text>What files are in the current directory?</text>
  <expected_answer>List of files in the current directory</expected_answer>
  <tools>list_files</tools>
  <verification>
    <type>semantic</type>
    <criteria>
      <contains>file</contains>
      <format>list</format>
    </criteria>
  </verification>
</question>
```

**预期响应**:
```
📁 当前目录中的文件:
📄 README.md
📄 package.json
📁 src/
📁 tests/
```

## 评估执行流程

### 1. 准备阶段
- 启动MCP服务器
- 加载评估XML文件
- 初始化结果收集器

### 2. 执行阶段
- 逐个发送问题到MCP服务器
- 收集工具调用和响应
- 应用验证规则

### 3. 报告阶段
- 生成详细的评估报告
- 标识失败的测试用例
- 提供改进建议

## 评估报告格式

```json
{
  "evaluation_report": {
    "server_name": "weather-api-server",
    "version": "1.0.0",
    "timestamp": "2026-01-16T10:30:00Z",
    "summary": {
      "total_questions": 15,
      "passed": 13,
      "failed": 2,
      "pass_rate": 86.67
    },
    "results": [
      {
        "question_id": "weather_paris",
        "status": "passed",
        "response": "📍 Paris: 18°C, Partly cloudy",
        "verification": "semantic_match"
      },
      {
        "question_id": "calc_division_by_zero",
        "status": "failed",
        "response": "Division by zero result: infinity",
        "expected": "Error message for division by zero",
        "verification": "error_check_failed"
      }
    ],
    "recommendations": [
      "Improve error handling for edge cases",
      "Add input validation for numeric operations",
      "Consider adding more detailed weather descriptions"
    ]
  }
}
```

---

*此评估指南基于 Model Context Protocol 官方评估规范，提供创建和执行MCP服务器评估的完整参考。*