---
description: "C语言开发规则 - 系统级编程最佳实践和安全开发"
apply_when:
  - file_pattern: "**/*.c"
  - file_pattern: "**/*.h"
  - keywords: ["c语言", "c编程"]
priority: 10
---

# 🔧 C 语言开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 操作系统内核和驱动程序开发
- 嵌入式系统和物联网设备
- 系统级工具和库开发
- 高性能计算和实时系统
- 网络协议栈和通信软件
- 跨平台底层库开发

## 🏗️ 项目结构

### 标准C项目布局
```
c_project/
├── Makefile                    # 构建脚本
├── configure.ac               # Autotools配置 (可选)
├── CMakeLists.txt             # CMake配置 (现代替代)
├── src/                       # 源代码
│   ├── main.c
│   ├── core/                  # 核心模块
│   │   ├── core.h
│   │   ├── core.c
│   │   └── types.h
│   └── utils/                 # 工具模块
│       ├── string_utils.h
│       ├── string_utils.c
│       └── memory_utils.h
├── include/                   # 公共头文件
│   └── project_name/
│       ├── config.h
│       └── api.h
├── tests/                     # 测试代码
│   ├── test_main.c
│   └── test_core.c
├── examples/                  # 示例程序
├── docs/                      # 文档
├── scripts/                   # 构建和工具脚本
├── .clang-format             # 代码格式化配置
├── .clang-tidy              # 静态分析配置
└── README.md
```

### 多文件项目组织
```c
// include/project_name/config.h - 配置文件
#ifndef PROJECT_NAME_CONFIG_H
#define PROJECT_NAME_CONFIG_H

// 平台检测宏
#if defined(_WIN32) || defined(_WIN64)
#define PLATFORM_WINDOWS
#elif defined(__linux__)
#define PLATFORM_LINUX
#elif defined(__APPLE__)
#define PLATFORM_MACOS
#endif

// 编译器检测
#if defined(__GNUC__)
#define COMPILER_GCC
#elif defined(__clang__)
#define COMPILER_CLANG
#elif defined(_MSC_VER)
#define COMPILER_MSVC
#endif

// 导出宏
#ifdef _WIN32
#ifdef BUILDING_DLL
#define API_EXPORT __declspec(dllexport)
#else
#define API_EXPORT __declspec(dllimport)
#endif
#else
#define API_EXPORT __attribute__((visibility("default")))
#endif

#endif // PROJECT_NAME_CONFIG_H
```

## 📝 编码规范

### C99/C11标准特性使用
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>

// ✅ 推荐：使用固定宽度整数类型
typedef struct {
    uint32_t id;
    uint8_t flags;
    int64_t timestamp;
    size_t data_size;
} Record;

// ✅ 推荐：使用bool类型和复合字面量
bool validate_record(const Record* record) {
    if (!record) return false;

    return record->id != 0 &&
           record->data_size > 0 &&
           record->timestamp >= 0;
}

// ✅ 推荐：使用指定初始化器
Record create_record(uint32_t id, const char* data) {
    return (Record){
        .id = id,
        .flags = 0x01,
        .timestamp = time(NULL),
        .data_size = strlen(data)
    };
}

// ✅ 推荐：使用变长数组 (C99)
void process_data(size_t count, const int data[count]) {
    for (size_t i = 0; i < count; ++i) {
        printf("data[%zu] = %d\n", i, data[i]);
    }
}

// ✅ 推荐：泛型宏 (C11)
#define MAX(a, b) \
    _Generic((a), \
        int: MAX_INT, \
        float: MAX_FLOAT, \
        double: MAX_DOUBLE \
    )((a), (b))

static inline int MAX_INT(int a, int b) { return a > b ? a : b; }
static inline float MAX_FLOAT(float a, float b) { return a > b ? a : b; }
static inline double MAX_DOUBLE(double a, double b) { return a > b ? a : b; }
```

### 命名约定
```c
// 类型和结构体：PascalCase
typedef struct {
    int id;
    char* name;
} UserRecord;

// 联合体：PascalCase
typedef union {
    uint32_t as_uint32;
    float as_float;
} FloatIntUnion;

// 枚举：PascalCase
typedef enum {
    STATUS_SUCCESS,
    STATUS_ERROR,
    STATUS_PENDING
} ProcessStatus;

// 函数：snake_case
void process_user_data(const UserRecord* user);
int calculate_checksum(const uint8_t* data, size_t length);
bool validate_input_string(const char* input);

// 变量：snake_case
int user_count;
char* buffer_ptr;
size_t buffer_size;

// 常量：SCREAMING_SNAKE_CASE
#define MAX_BUFFER_SIZE 1024
#define DEFAULT_TIMEOUT_MS 5000
const int MAX_CONNECTIONS = 100;

// 宏函数：SCREAMING_SNAKE_CASE
#define CALCULATE_OFFSET(ptr, offset) \
    ((char*)(ptr) + (offset))

// 文件静态变量：前缀s_
static int s_connection_count = 0;
static char* s_error_message = NULL;
```

### 错误处理和资源管理
```c
#include <errno.h>
#include <string.h>
#include <assert.h>

// ✅ 推荐：统一的错误处理模式
typedef enum {
    ERROR_SUCCESS = 0,
    ERROR_INVALID_ARGUMENT,
    ERROR_OUT_OF_MEMORY,
    ERROR_FILE_NOT_FOUND,
    ERROR_PERMISSION_DENIED,
    ERROR_IO_ERROR
} ErrorCode;

typedef struct {
    ErrorCode code;
    char message[256];
} Error;

// 错误处理宏
#define RETURN_IF_ERROR(expr) \
    do { \
        ErrorCode err = (expr); \
        if (err != ERROR_SUCCESS) { \
            return err; \
        } \
    } while (0)

#define GOTO_IF_ERROR(expr, label) \
    do { \
        ErrorCode err = (expr); \
        if (err != ERROR_SUCCESS) { \
            goto label; \
        } \
    } while (0)

// ✅ 推荐：RAII风格的资源管理
typedef struct {
    FILE* file;
    bool valid;
} FileHandle;

ErrorCode file_handle_open(FileHandle* handle, const char* filename) {
    assert(handle != NULL);
    assert(filename != NULL);

    handle->file = fopen(filename, "r");
    if (!handle->file) {
        return ERROR_FILE_NOT_FOUND;
    }

    handle->valid = true;
    return ERROR_SUCCESS;
}

void file_handle_close(FileHandle* handle) {
    if (handle && handle->valid) {
        fclose(handle->file);
        handle->valid = false;
    }
}

// 使用示例
ErrorCode process_file(const char* filename) {
    FileHandle handle = {0};

    ErrorCode err = file_handle_open(&handle, filename);
    if (err != ERROR_SUCCESS) {
        return err;
    }

    // 使用文件...
    char buffer[1024];
    if (fgets(buffer, sizeof(buffer), handle.file)) {
        // 处理数据
        printf("Read: %s", buffer);
    }

    file_handle_close(&handle); // 确保资源被释放
    return ERROR_SUCCESS;
}

// ✅ 推荐：goto语句用于错误处理 (Linux内核风格)
ErrorCode complex_operation(const char* input) {
    void* buffer1 = NULL;
    void* buffer2 = NULL;
    FileHandle file = {0};

    buffer1 = malloc(1024);
    if (!buffer1) {
        return ERROR_OUT_OF_MEMORY;
    }

    buffer2 = malloc(2048);
    if (!buffer2) {
        goto cleanup_buffer1;
    }

    ErrorCode err = file_handle_open(&file, input);
    if (err != ERROR_SUCCESS) {
        goto cleanup_buffers;
    }

    // 执行主要操作...
    if (some_operation_fails()) {
        err = ERROR_IO_ERROR;
        goto cleanup_all;
    }

    // 成功完成
    err = ERROR_SUCCESS;

cleanup_all:
    file_handle_close(&file);
cleanup_buffers:
    free(buffer2);
cleanup_buffer1:
    free(buffer1);

    return err;
}
```

## 🛠️ 构建系统

### Makefile (传统方式)
```makefile
CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -Werror
CFLAGS += -O2 -DNDEBUG
CFLAGS += $(shell pkg-config --cflags glib-2.0)
LDFLAGS = $(shell pkg-config --libs glib-2.0)

# 调试版本
DEBUG_CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -Werror
DEBUG_CFLAGS += -g -O0 -DDEBUG
DEBUG_LDFLAGS = $(LDFLAGS)

# 源文件
SRCS = src/main.c src/core.c src/utils.c
OBJS = $(SRCS:.c=.o)
DEPS = $(SRCS:.c=.d)

# 目标
TARGET = myapp
TEST_TARGET = tests

.PHONY: all clean test debug install uninstall

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# 依赖文件生成
%.d: %.c
	$(CC) $(CFLAGS) -MM -MT $(@:.d=.o) $< > $@

-include $(DEPS)

debug: CFLAGS = $(DEBUG_CFLAGS)
debug: LDFLAGS = $(DEBUG_LDFLAGS)
debug: $(TARGET)

test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TEST_TARGET): tests/test_main.c src/core.c src/utils.c
	$(CC) $(DEBUG_CFLAGS) $^ -o $@ $(DEBUG_LDFLAGS)

clean:
	rm -f $(OBJS) $(DEPS) $(TARGET) $(TEST_TARGET)

install: $(TARGET)
	install -d $(DESTDIR)/usr/local/bin
	install $(TARGET) $(DESTDIR)/usr/local/bin/

uninstall:
	rm -f $(DESTDIR)/usr/local/bin/$(TARGET)

# 代码质量检查
lint:
	clang-tidy $(SRCS) -- $(CFLAGS)
	cppcheck --enable=all --std=c11 $(SRCS)
```

### CMake (现代方式)
```cmake
cmake_minimum_required(VERSION 3.10)
project(MyProject VERSION 1.0.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# 编译选项
add_compile_options(
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    $<$<CONFIG:Debug>:-g -O0 -DDEBUG>
    $<$<CONFIG:Release>:-O2 -DNDEBUG>
)

# 查找依赖
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED glib-2.0)

# 包含目录
include_directories(include)
include_directories(${GLIB_INCLUDE_DIRS})

# 源文件
file(GLOB SOURCES "src/*.c")

# 可执行文件
add_executable(${PROJECT_NAME} ${SOURCES})

# 链接库
target_link_libraries(${PROJECT_NAME} ${GLIB_LIBRARIES})

# 测试
enable_testing()
file(GLOB TEST_SOURCES "tests/*.c")
add_executable(tests ${TEST_SOURCES} src/core.c src/utils.c)
add_test(NAME unit_tests COMMAND tests)

# 安装
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)
```

## 🧪 测试策略

### 简单的单元测试框架
```c
// tests/test_framework.h
#ifndef TEST_FRAMEWORK_H
#define TEST_FRAMEWORK_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    const char* name;
    void (*test_func)(void);
} TestCase;

#define TEST_CASE(name) \
    static void test_##name(void)

#define RUN_TEST(name) \
    do { \
        printf("Running test: %s... ", #name); \
        fflush(stdout); \
        test_##name(); \
        printf("PASSED\n"); \
    } while (0)

#define ASSERT_TRUE(condition) \
    do { \
        if (!(condition)) { \
            fprintf(stderr, "ASSERTION FAILED: %s:%d: %s\n", \
                    __FILE__, __LINE__, #condition); \
            exit(1); \
        } \
    } while (0)

#define ASSERT_FALSE(condition) ASSERT_TRUE(!(condition))

#define ASSERT_EQUAL(a, b) \
    do { \
        if ((a) != (b)) { \
            fprintf(stderr, "ASSERTION FAILED: %s:%d: %s != %s (%d != %d)\n", \
                    __FILE__, __LINE__, #a, #b, (int)(a), (int)(b)); \
            exit(1); \
        } \
    } while (0)

#define ASSERT_STR_EQUAL(a, b) \
    do { \
        if (strcmp((a), (b)) != 0) { \
            fprintf(stderr, "ASSERTION FAILED: %s:%d: %s != %s\n", \
                    __FILE__, __LINE__, #a, #b); \
            exit(1); \
        } \
    } while (0)

#endif // TEST_FRAMEWORK_H
```

### 测试实现示例
```c
// tests/test_core.c
#include "test_framework.h"
#include "../src/core.h"

TEST_CASE(test_validate_input) {
    // 测试有效输入
    ASSERT_TRUE(validate_input_string("hello"));
    ASSERT_TRUE(validate_input_string("hello123"));

    // 测试无效输入
    ASSERT_FALSE(validate_input_string(NULL));
    ASSERT_FALSE(validate_input_string(""));
    ASSERT_FALSE(validate_input_string("hello\x01world")); // 包含控制字符
}

TEST_CASE(test_calculate_checksum) {
    uint8_t data1[] = {1, 2, 3, 4, 5};
    ASSERT_EQUAL(calculate_checksum(data1, 5), 15);

    uint8_t data2[] = {0};
    ASSERT_EQUAL(calculate_checksum(data2, 1), 0);

    uint8_t data3[] = {255, 255};
    ASSERT_EQUAL(calculate_checksum(data3, 2), 254); // 溢出处理
}

TEST_CASE(test_process_data) {
    int data[] = {1, 2, 3, 4, 5};
    int result[5];

    process_data(5, data, result);

    for (int i = 0; i < 5; ++i) {
        ASSERT_EQUAL(result[i], data[i] * 2); // 假设process_data做翻倍操作
    }
}
```

### 测试运行器
```c
// tests/test_main.c
#include "test_framework.h"

int main(void) {
    printf("Running unit tests...\n\n");

    // 运行所有测试
    RUN_TEST(test_validate_input);
    RUN_TEST(test_calculate_checksum);
    RUN_TEST(test_process_data);

    printf("\nAll tests passed!\n");
    return 0;
}
```

## 🚀 性能优化

### 内存管理优化
```c
#include <stdlib.h>
#include <string.h>

// ✅ 推荐：内存池避免频繁分配
typedef struct {
    void* buffer;
    size_t buffer_size;
    size_t used;
    void** free_list;
    size_t free_count;
} MemoryPool;

MemoryPool* memory_pool_create(size_t block_size, size_t block_count) {
    MemoryPool* pool = malloc(sizeof(MemoryPool));
    if (!pool) return NULL;

    pool->buffer_size = block_size * block_count;
    pool->buffer = malloc(pool->buffer_size);
    if (!pool->buffer) {
        free(pool);
        return NULL;
    }

    pool->used = 0;
    pool->free_list = malloc(block_count * sizeof(void*));
    if (!pool->free_list) {
        free(pool->buffer);
        free(pool);
        return NULL;
    }

    pool->free_count = block_count;
    for (size_t i = 0; i < block_count; ++i) {
        pool->free_list[i] = (char*)pool->buffer + i * block_size;
    }

    return pool;
}

void* memory_pool_alloc(MemoryPool* pool) {
    if (pool->free_count == 0) return NULL;

    return pool->free_list[--pool->free_count];
}

void memory_pool_free(MemoryPool* pool, void* ptr) {
    if (pool->free_count >= pool->buffer_size / (pool->buffer_size / (pool->used + 1))) {
        return; // 池已满，简单忽略
    }

    pool->free_list[pool->free_count++] = ptr;
}

void memory_pool_destroy(MemoryPool* pool) {
    if (pool) {
        free(pool->free_list);
        free(pool->buffer);
        free(pool);
    }
}

// ✅ 推荐：缓存友好的数据结构
typedef struct {
    int id;
    char padding[60]; // 填充到64字节缓存行大小
} CacheAlignedItem;

#define CACHE_LINE_SIZE 64

typedef struct {
    CacheAlignedItem items[1000];
} CacheFriendlyArray;

// ✅ 推荐：预分配策略
typedef struct {
    char* buffer;
    size_t capacity;
    size_t size;
} StringBuffer;

StringBuffer* string_buffer_create(size_t initial_capacity) {
    StringBuffer* sb = malloc(sizeof(StringBuffer));
    if (!sb) return NULL;

    sb->buffer = malloc(initial_capacity);
    if (!sb->buffer) {
        free(sb);
        return NULL;
    }

    sb->capacity = initial_capacity;
    sb->size = 0;
    return sb;
}

bool string_buffer_append(StringBuffer* sb, const char* str) {
    size_t len = strlen(str);
    size_t needed = sb->size + len + 1; // +1 for null terminator

    if (needed > sb->capacity) {
        size_t new_capacity = sb->capacity * 2;
        while (new_capacity < needed) {
            new_capacity *= 2;
        }

        char* new_buffer = realloc(sb->buffer, new_capacity);
        if (!new_buffer) return false;

        sb->buffer = new_buffer;
        sb->capacity = new_capacity;
    }

    strcpy(sb->buffer + sb->size, str);
    sb->size += len;
    return true;
}
```
