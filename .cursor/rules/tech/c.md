---
command: c
description: "C语言开发规则 - 系统级编程最佳实践和安全开发"
alwaysApply: false
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

### 编译优化
```c
// 条件编译优化
#ifdef __GNUC__
#define LIKELY(x) __builtin_expect(!!(x), 1)
#define UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
#define LIKELY(x) (x)
#define UNLIKELY(x) (x)
#endif

// 内联函数优化
static inline int fast_max(int a, int b) {
    return LIKELY(a > b) ? a : b;
}

// 分支预测优化
int process_data_optimized(const int* data, size_t count) {
    int sum = 0;
    for (size_t i = 0; i < count; ++i) {
        if (LIKELY(data[i] > 0)) { // 正数更常见
            sum += data[i];
        } else {
            sum -= data[i]; // 负数处理
        }
    }
    return sum;
}

// SIMD优化 (需要编译器支持)
#ifdef __AVX2__
#include <immintrin.h>

void vector_add_float(float* result, const float* a, const float* b, size_t count) {
    size_t i = 0;

    // SIMD处理
    for (; i + 8 <= count; i += 8) {
        __m256 va = _mm256_load_ps(&a[i]);
        __m256 vb = _mm256_load_ps(&b[i]);
        __m256 vr = _mm256_add_ps(va, vb);
        _mm256_store_ps(&result[i], vr);
    }

    // 处理剩余元素
    for (; i < count; ++i) {
        result[i] = a[i] + b[i];
    }
}

#else

void vector_add_float(float* result, const float* a, const float* b, size_t count) {
    for (size_t i = 0; i < count; ++i) {
        result[i] = a[i] + b[i];
    }
}

#endif
```

## 🔒 安全实践

### 缓冲区溢出防护
```c
#include <string.h>
#include <stdio.h>

// ✅ 推荐：安全的字符串操作
size_t safe_strncpy(char* dest, const char* src, size_t dest_size) {
    if (!dest || !src || dest_size == 0) {
        return 0;
    }

    size_t src_len = strnlen(src, dest_size);
    if (src_len < dest_size) {
        // 源字符串完全适合
        memcpy(dest, src, src_len);
        dest[src_len] = '\0';
        return src_len;
    } else {
        // 需要截断
        memcpy(dest, src, dest_size - 1);
        dest[dest_size - 1] = '\0';
        return dest_size - 1;
    }
}

size_t safe_strncat(char* dest, const char* src, size_t dest_size) {
    if (!dest || !src || dest_size == 0) {
        return 0;
    }

    size_t dest_len = strnlen(dest, dest_size);
    if (dest_len >= dest_size) {
        return 0; // 目标缓冲区已满或无效
    }

    size_t remaining = dest_size - dest_len;
    size_t src_len = strnlen(src, remaining);

    memcpy(dest + dest_len, src, src_len);
    dest[dest_len + src_len] = '\0';

    return src_len;
}

// ✅ 推荐：安全的内存操作
void* safe_memcpy(void* dest, const void* src, size_t count) {
    if (!dest || !src) {
        return NULL;
    }

    // 检查重叠
    if ((char*)dest < (char*)src + count &&
        (char*)src < (char*)dest + count) {
        // 重叠，使用memmove
        return memmove(dest, src, count);
    }

    return memcpy(dest, src, count);
}

void* safe_malloc(size_t size) {
    if (size == 0) {
        size = 1; // 避免分配0字节
    }

    if (size > SIZE_MAX / 2) {
        return NULL; // 防止整数溢出
    }

    return malloc(size);
}
```

### 输入验证
```c
#include <ctype.h>
#include <limits.h>

// ✅ 推荐：整数输入验证
bool safe_strtol(const char* str, long* result) {
    if (!str || !result) {
        return false;
    }

    char* endptr;
    errno = 0;

    long value = strtol(str, &endptr, 10);

    // 检查转换错误
    if (errno == ERANGE) {
        return false; // 溢出
    }

    if (endptr == str) {
        return false; // 没有数字
    }

    // 检查是否有额外字符
    while (*endptr != '\0') {
        if (!isspace(*endptr)) {
            return false; // 有非空白字符
        }
        ++endptr;
    }

    *result = value;
    return true;
}

// ✅ 推荐：字符串清理和验证
bool is_safe_string(const char* str, size_t max_len) {
    if (!str) return false;

    size_t len = 0;
    while (*str && len < max_len) {
        if (!isprint(*str) && !isspace(*str)) {
            return false; // 包含不可打印字符
        }
        ++str;
        ++len;
    }

    return *str == '\0'; // 确保以null结尾
}

char* sanitize_string(char* dest, const char* src, size_t dest_size) {
    if (!dest || !src || dest_size == 0) {
        return NULL;
    }

    size_t i = 0;
    for (; i < dest_size - 1 && *src; ++src) {
        if (isalnum(*src) || ispunct(*src) || isspace(*src)) {
            dest[i++] = *src;
        }
        // 过滤掉潜在危险字符
    }

    dest[i] = '\0';
    return dest;
}
```

### 格式化字符串安全
```c
#include <stdarg.h>

// ✅ 推荐：安全的格式化函数
int safe_snprintf(char* buffer, size_t buffer_size, const char* format, ...) {
    if (!buffer || !format || buffer_size == 0) {
        return -1;
    }

    va_list args;
    va_start(args, format);

    int result = vsnprintf(buffer, buffer_size, format, args);

    va_end(args);

    if (result < 0) {
        buffer[0] = '\0'; // 确保缓冲区以null结尾
        return -1;
    }

    if ((size_t)result >= buffer_size) {
        buffer[buffer_size - 1] = '\0'; // 确保缓冲区以null结尾
        return buffer_size - 1;
    }

    return result;
}

// ✅ 推荐：避免格式化字符串漏洞
void safe_log(const char* level, const char* format, ...) {
    char buffer[1024];

    va_list args;
    va_start(args, format);

    // 使用vsnprintf而不是直接传递format到printf
    int len = vsnprintf(buffer, sizeof(buffer), format, args);
    if (len < 0 || (size_t)len >= sizeof(buffer)) {
        // 截断或错误处理
        buffer[sizeof(buffer) - 1] = '\0';
    }

    va_end(args);

    // 安全的输出
    fprintf(stderr, "[%s] %s\n", level, buffer);
}
```

## 📊 最佳实践

### 模块化和接口设计
```c
// core.h - 模块接口定义
#ifndef CORE_H
#define CORE_H

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// 前向声明不完整类型
typedef struct CoreContext CoreContext;

// 函数指针类型定义
typedef bool (*DataProcessor)(void* data, size_t size);
typedef void (*ErrorHandler)(const char* message);

// 配置结构体
typedef struct {
    size_t buffer_size;
    int timeout_ms;
    DataProcessor processor;
    ErrorHandler error_handler;
} CoreConfig;

// API函数
CoreContext* core_create(const CoreConfig* config);
void core_destroy(CoreContext* context);
bool core_process_data(CoreContext* context, const void* data, size_t size);
const char* core_get_last_error(const CoreContext* context);

#ifdef __cplusplus
}
#endif

#endif // CORE_H
```

### 错误处理模式
```c
// error.h - 统一的错误处理
#ifndef ERROR_H
#define ERROR_H

typedef enum {
    E_SUCCESS = 0,
    E_INVALID_ARGUMENT,
    E_OUT_OF_MEMORY,
    E_IO_ERROR,
    E_TIMEOUT,
    E_PERMISSION_DENIED,
    E_UNKNOWN
} ErrorCode;

typedef struct {
    ErrorCode code;
    char message[256];
    const char* file;
    int line;
} Error;

#define ERROR_CREATE(code, msg) \
    ((Error){(code), (msg), __FILE__, __LINE__})

#define RETURN_ERROR_IF(condition, code, msg) \
    do { \
        if (condition) { \
            return ERROR_CREATE(code, msg); \
        } \
    } while (0)

static inline bool error_is_success(const Error* error) {
    return error && error->code == E_SUCCESS;
}

static inline void error_print(const Error* error) {
    if (error) {
        fprintf(stderr, "Error %d at %s:%d: %s\n",
                error->code, error->file, error->line, error->message);
    }
}

#endif // ERROR_H
```

### 跨平台兼容性
```c
// platform.h - 平台抽象层
#ifndef PLATFORM_H
#define PLATFORM_H

#include <stdint.h>
#include <stdbool.h>

#ifdef _WIN32
#include <windows.h>
#define PATH_SEPARATOR '\\'
#define PATH_SEPARATOR_STR "\\"
typedef HANDLE FileHandle;
#define INVALID_FILE_HANDLE INVALID_HANDLE_VALUE
#else
#include <unistd.h>
#include <fcntl.h>
#define PATH_SEPARATOR '/'
#define PATH_SEPARATOR_STR "/"
typedef int FileHandle;
#define INVALID_FILE_HANDLE (-1)
#endif

// 统一的文件操作API
typedef struct {
    FileHandle handle;
    bool valid;
} PlatformFile;

PlatformFile platform_file_open(const char* path, bool read_only);
void platform_file_close(PlatformFile* file);
bool platform_file_read(PlatformFile* file, void* buffer, size_t size, size_t* read);
bool platform_file_write(PlatformFile* file, const void* buffer, size_t size);

// 目录操作
bool platform_directory_create(const char* path);
bool platform_directory_exists(const char* path);

// 路径操作
char* platform_path_join(const char* dir, const char* filename);
char* platform_path_get_directory(const char* path);
char* platform_path_get_filename(const char* path);

// 线程API (简化版本)
typedef struct PlatformThread PlatformThread;
typedef void (*ThreadFunction)(void* arg);

PlatformThread* platform_thread_create(ThreadFunction func, void* arg);
void platform_thread_join(PlatformThread* thread);
void platform_thread_destroy(PlatformThread* thread);

#endif // PLATFORM_H
```

## 🔄 现代化升级

### C标准演进
- **C89/C90**: 经典C标准，仍然广泛支持
- **C99**: 变长数组、复合字面量、指定初始化器
- **C11**: 原子操作、线程支持、多线程内存模型
- **C23**: 预计的新特性，包括更好的类型推断

### 编译器支持
- **GCC**: 最全面的C标准支持
- **Clang**: 优秀的错误诊断和静态分析
- **MSVC**: Windows平台最佳选择
- **TinyCC**: 轻量级编译器，适合嵌入式

### 开发工具
- **静态分析**: Clang Static Analyzer, Cppcheck, Coverity
- **内存检查**: Valgrind, AddressSanitizer
- **代码覆盖**: Gcov, LCOV
- **文档生成**: Doxygen

---

*此规则适用于系统级C语言开发项目。强调内存安全、性能优化和跨平台兼容性。优先使用C11标准特性。*