---
description: "C 语言内存与资源管理 - 错误处理、RAII、内存池、goto 清理"
globs: ["**/*.c", "**/*.h"]
alwaysApply: false
priority: 10
---

# C 语言内存与资源管理 (Memory)

> 本规则由 `@c-basics` 引用

## 错误处理

```c
typedef enum {
    ERROR_SUCCESS = 0,
    ERROR_INVALID_ARGUMENT,
    ERROR_OUT_OF_MEMORY,
    ERROR_FILE_NOT_FOUND
} ErrorCode;

#define RETURN_IF_ERROR(expr) \
    do { ErrorCode err = (expr); if (err != ERROR_SUCCESS) return err; } while (0)

#define GOTO_IF_ERROR(expr, label) \
    do { ErrorCode err = (expr); if (err != ERROR_SUCCESS) goto label; } while (0)
```

## RAII 风格资源管理

```c
typedef struct {
    FILE* file;
    bool valid;
} FileHandle;

ErrorCode file_handle_open(FileHandle* handle, const char* filename);
void file_handle_close(FileHandle* handle);

// 使用
ErrorCode process_file(const char* filename) {
    FileHandle handle = {0};
    ErrorCode err = file_handle_open(&handle, filename);
    if (err != ERROR_SUCCESS) return err;
    // 使用文件...
    file_handle_close(&handle);
    return ERROR_SUCCESS;
}
```

## goto 清理 (Linux 内核风格)

```c
ErrorCode complex_operation(const char* input) {
    void* buffer1 = NULL;
    void* buffer2 = NULL;
    FileHandle file = {0};

    buffer1 = malloc(1024);
    if (!buffer1) return ERROR_OUT_OF_MEMORY;
    buffer2 = malloc(2048);
    if (!buffer2) goto cleanup_buffer1;

    if (file_handle_open(&file, input) != ERROR_SUCCESS)
        goto cleanup_buffers;

    // 主逻辑...
    if (fails()) goto cleanup_all;

cleanup_all:   file_handle_close(&file);
cleanup_buffers: free(buffer2);
cleanup_buffer1: free(buffer1);
    return err;
}
```

## 内存池

```c
typedef struct {
    void* buffer;
    size_t buffer_size;
    size_t used;
    void** free_list;
    size_t free_count;
} MemoryPool;

MemoryPool* memory_pool_create(size_t block_size, size_t block_count);
void* memory_pool_alloc(MemoryPool* pool);
void memory_pool_free(MemoryPool* pool, void* ptr);
void memory_pool_destroy(MemoryPool* pool);
```

## 缓存友好结构

```c
#define CACHE_LINE_SIZE 64
typedef struct {
    int id;
    char padding[60];  // 填充到缓存行
} CacheAlignedItem;
```

## 原则

- **MUST** 配对 malloc/free、fopen/fclose
- **MUST** 检查分配返回值
- **MUST** 使用 goto 统一清理多资源

---

*引用: @c-basics*
