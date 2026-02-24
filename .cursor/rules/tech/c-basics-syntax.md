---
description: "C 语言语法规范 - C99/C11 标准、命名约定、项目结构"
globs: ["**/*.c", "**/*.h"]
alwaysApply: false
priority: 10
---

# C 语言语法规范 (Syntax)

> 本规则由 `@c-basics` 引用

## 项目结构

```
c_project/
├── Makefile / CMakeLists.txt
├── src/           # 源代码 (main.c, core/, utils/)
├── include/       # 公共头文件
├── tests/         # 测试
├── examples/
└── .clang-format
```

## C99/C11 标准特性

```c
#include <stdbool.h>
#include <stdint.h>

// 固定宽度整数
typedef struct {
    uint32_t id;
    uint8_t flags;
    int64_t timestamp;
    size_t data_size;
} Record;

// bool 与复合字面量
bool validate_record(const Record* record) {
    return record && record->id != 0 && record->data_size > 0;
}

Record create_record(uint32_t id, const char* data) {
    return (Record){
        .id = id,
        .flags = 0x01,
        .timestamp = time(NULL),
        .data_size = strlen(data)
    };
}

// 变长数组 (C99)
void process_data(size_t count, const int data[count]) {
    for (size_t i = 0; i < count; ++i) printf("data[%zu] = %d\n", i, data[i]);
}
```

## 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 结构体/枚举 | PascalCase | UserRecord, ProcessStatus |
| 函数/变量 | snake_case | process_user_data, buffer_size |
| 常量/宏 | SCREAMING_SNAKE_CASE | MAX_BUFFER_SIZE |
| 文件静态 | 前缀 s_ | s_connection_count |

## 头文件保护

```c
#ifndef PROJECT_NAME_CONFIG_H
#define PROJECT_NAME_CONFIG_H
// ...
#endif
```

---

*引用: @c-basics*
