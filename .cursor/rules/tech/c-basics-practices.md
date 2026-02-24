---
description: "C 语言实践 - 构建系统、Makefile、CMake、测试策略"
globs: ["**/*.c", "**/*.h"]
alwaysApply: false
priority: 10
---

# C 语言实践 (Practices)

> 本规则由 `@c-basics` 引用

## Makefile

```makefile
CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -Werror -O2 -DNDEBUG
SRCS = src/main.c src/core.c src/utils.c
OBJS = $(SRCS:.c=.o)

TARGET = myapp
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

.PHONY: all clean test
all: $(TARGET)
clean: rm -f $(OBJS) $(TARGET)
test: ./$(TEST_TARGET)
```

## CMake

```cmake
cmake_minimum_required(VERSION 3.10)
project(MyProject LANGUAGES C)
set(CMAKE_C_STANDARD 11)

add_compile_options(-Wall -Wextra -Wpedantic -Werror)
add_executable(${PROJECT_NAME} src/main.c src/core.c src/utils.c)
enable_testing()
add_test(NAME unit_tests COMMAND tests)
```

## 单元测试框架

```c
#define TEST_CASE(name) static void test_##name(void)
#define RUN_TEST(name) do { printf("Running %s... ", #name); test_##name(); printf("PASSED\n"); } while (0)
#define ASSERT_TRUE(c) do { if (!(c)) { fprintf(stderr, "FAIL: %s:%d\n", __FILE__, __LINE__); exit(1); } } while (0)
#define ASSERT_EQUAL(a, b) ASSERT_TRUE((a) == (b))
```

## 原则

- **MUST** 使用 -Wall -Wextra -Wpedantic
- **MUST** 为 Release 使用 -O2 -DNDEBUG
- **MUST** 编写单元测试

---

*引用: @c-basics*
