---
description: "C++开发规则 - 现代C++最佳实践和高性能开发 (c++, cpp)"
globs: ["**/*.cpp", "**/*.cc", "**/*.cxx", "**/*.hpp", "**/*.h"]
alwaysApply: false
priority: 10
---

# 🚀 C++ 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 高性能系统编程和底层开发
- 游戏引擎和实时图形应用
- 嵌入式系统和物联网设备
- 高频交易和金融系统
- 科学计算和数值模拟
- 跨平台桌面应用开发

## 🏗️ 项目结构

### 现代CMake项目布局
```
modern_cpp_project/
├── CMakeLists.txt              # 主CMake配置
├── cmake/                      # CMake模块
│   ├── CompilerWarnings.cmake
│   └── Conan.cmake
├── src/                        # 源代码
│   ├── main.cpp
│   ├── core/                   # 核心模块
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   ├── core.h
│   │   │   └── types.h
│   │   └── src/
│   │       ├── core.cpp
│   │       └── types.cpp
│   └── utils/                  # 工具模块
├── tests/                      # 测试
│   ├── CMakeLists.txt
│   ├── main.cpp
│   └── core/
│       └── test_core.cpp
├── benchmarks/                 # 性能测试
├── examples/                   # 示例代码
├── docs/                       # 文档
├── conanfile.txt              # Conan依赖
├── .clang-format              # 代码格式化配置
├── .clang-tidy               # 静态分析配置
└── README.md
```

### 头文件组织
```
include/project_name/
├── core/                       # 核心功能头文件
│   ├── config.h               # 配置宏
│   ├── types.h                # 类型定义
│   └── interfaces/            # 接口定义
├── algorithms/                # 算法相关
├── containers/                # 容器实现
└── utilities/                 # 工具函数
```

## 📝 编码规范

### 现代C++特性使用 (C++11/14)
```cpp
#include <iostream>
#include <memory>
#include <vector>
#include <string>
#include <functional>

// ✅ 推荐：使用智能指针和RAII
class FileHandler {
private:
    std::unique_ptr<std::FILE, std::function<void(std::FILE*)>> file_;

public:
    explicit FileHandler(const std::string& path)
        : file_(std::fopen(path.c_str(), "r"),
                [](std::FILE* f) { if (f) std::fclose(f); }) {
        if (!file_) {
            throw std::runtime_error("Failed to open file");
        }
    }

    // 使用const std::string&避免字符串拷贝
    void processLine(const std::string& line) {
        std::cout << "Processing: " << line << std::endl;
    }
};

// ✅ 推荐：使用auto和范围for
boost::optional<std::string> findUser(const std::vector<User>& users,
                                    const std::string& name) {
    for (const auto& user : users) {
        if (user.name == name) {
            return user.email;
        }
    }
    return boost::none;
}

// ✅ 推荐：使用constexpr进行编译时计算
constexpr int fibonacci(int n) {
    return (n <= 1) ? n : fibonacci(n - 1) + fibonacci(n - 2);
}
```

### 命名约定
```cpp
// 类和结构体：PascalCase
class UserManager {
public:
    // 方法：camelCase
    void processUserData();

    // 常量：SCREAMING_SNAKE_CASE
    static constexpr int MAX_CONNECTIONS = 100;

private:
    // 成员变量：m_camelCase 或 camelCase_ (选择一种)
    std::string m_userName;
    int userId_;

    // 私有方法：camelCase
    bool validateUserData() const;
};

// 函数：camelCase
void processData(const std::vector<int>& data);

// 变量：camelCase
std::string userInput;
int itemCount;

// 类型别名：PascalCase
using UserList = std::vector<User>;
using StringView = std::string_view;

// 命名空间：lowercase
namespace utils {
namespace math {

// 模板参数：PascalCase with T prefix
template<typename TContainer, typename TValue>
class ContainerWrapper;

} // namespace math
} // namespace utils
```

### 异常安全和错误处理
```cpp
#include <stdexcept>
#include <system_error>

// ✅ 推荐：使用自定义异常类
class DatabaseError : public std::runtime_error {
public:
    explicit DatabaseError(const std::string& message)
        : std::runtime_error(message) {}
};

class NetworkError : public std::system_error {
public:
    NetworkError(int errorCode, const std::string& message)
        : std::system_error(errorCode, std::generic_category(), message) {}
};

// ✅ 推荐：异常安全的资源管理
class DatabaseConnection {
private:
    std::unique_ptr<sqlite3, decltype(&sqlite3_close)> db_;

public:
    DatabaseConnection(const std::string& dbPath) {
        sqlite3* db = nullptr;
        if (sqlite3_open(dbPath.c_str(), &db) != SQLITE_OK) {
            throw DatabaseError("Failed to open database");
        }
        db_ = std::unique_ptr<sqlite3, decltype(&sqlite3_close)>(
            db, &sqlite3_close);
    }

    // 强异常保证：要么完全成功，要么完全回滚
    void executeTransaction(const std::string& sql) {
        if (sqlite3_exec(db_.get(), "BEGIN", nullptr, nullptr, nullptr) != SQLITE_OK) {
            throw DatabaseError("Failed to begin transaction");
        }

        try {
            if (sqlite3_exec(db_.get(), sql.c_str(), nullptr, nullptr, nullptr) != SQLITE_OK) {
                throw DatabaseError("Failed to execute SQL");
            }

            if (sqlite3_exec(db_.get(), "COMMIT", nullptr, nullptr, nullptr) != SQLITE_OK) {
                throw DatabaseError("Failed to commit transaction");
            }
        } catch (...) {
            sqlite3_exec(db_.get(), "ROLLBACK", nullptr, nullptr, nullptr);
            throw;
        }
    }
};
```

## 🛠️ 依赖管理

### Conan (推荐)
```python
# conanfile.txt
[requires]
boost/1.83.0
catch2/3.4.0

[generators]
CMakeDeps
CMakeToolchain

[options]
spdlog:shared=False
```

### vcpkg (替代方案)
```json
{
  "name": "my-cpp-project",
  "version": "1.0.0",
  "dependencies": [
    "fmt",
    "spdlog",
    "boost",
    "catch2"
  ]
}
```

### CMake配置
```cmake
cmake_minimum_required(VERSION 3.20)
project(MyProject VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 查找依赖
find_package(Boost REQUIRED)

# 包含目录
include_directories(include)
include_directories(${Boost_INCLUDE_DIRS})

# 源文件
file(GLOB_RECURSE SOURCES "src/*.cpp")

# 可执行文件
add_executable(${PROJECT_NAME} ${SOURCES})

# 链接库
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        ${Boost_LIBRARIES}
)

# 编译选项
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
)
```

## 🧪 测试策略
