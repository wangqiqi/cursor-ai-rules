---
description: "C++开发规则 - 现代C++最佳实践和高性能开发"
apply_when:
  - file_pattern: "**/*.cpp"
  - file_pattern: "**/*.cc"
  - file_pattern: "**/*.cxx"
  - file_pattern: "**/*.hpp"
  - file_pattern: "**/*.h"
  - keywords: ["c++", "cpp"]
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

### 使用Catch2进行单元测试
```cpp
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <catch2/benchmark/catch_benchmark.hpp>

#include "math_utils.h"

// 测试套件
TEST_CASE("MathUtils - Basic arithmetic", "[math][arithmetic]") {
    MathUtils utils;

    SECTION("Addition") {
        REQUIRE(utils.add(2, 3) == 5);
        REQUIRE(utils.add(-1, 1) == 0);
    }

    SECTION("Subtraction") {
        REQUIRE(utils.subtract(5, 3) == 2);
        REQUIRE(utils.subtract(1, 1) == 0);
    }
}

TEST_CASE("MathUtils - Floating point operations", "[math][floating]") {
    MathUtils utils;

    SECTION("Division with approximation") {
        REQUIRE(utils.divide(10.0, 3.0) == Catch::Approx(3.333).epsilon(0.001));
    }
}

TEST_CASE("MathUtils - Edge cases", "[math][edge]") {
    MathUtils utils;

    SECTION("Division by zero") {
        REQUIRE_THROWS_AS(utils.divide(1.0, 0.0), std::domain_error);
    }

    SECTION("Large numbers") {
        double result = utils.add(1e308, 1e308);
        REQUIRE(std::isinf(result)); // 应该溢出为无穷大
    }
}

// 基准测试
TEST_CASE("MathUtils - Performance benchmarks", "[benchmark]") {
    MathUtils utils;

    BENCHMARK("Factorial of 10") {
        return utils.factorial(10);
    };

    BENCHMARK("Factorial of 20") {
        return utils.factorial(20);
    };
}
```

### 测试组织
```cpp
// tests/main.cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>

// tests/math_test.cpp
#include <catch2/catch_test_macros.hpp>
#include "math_utils.h"

TEST_CASE("MathUtils tests", "[math]") {
    // 测试实现
}

// tests/CMakeLists.txt
find_package(Catch2 REQUIRED)

file(GLOB TEST_SOURCES "*.cpp")
add_executable(tests ${TEST_SOURCES})
target_link_libraries(tests PRIVATE Catch2::Catch2 math_utils)

include(Catch)
catch_discover_tests(tests)
```

## 🚀 性能优化

### 内存管理优化
```cpp
#include <memory>
#include <vector>
#include <array>

// ✅ 推荐：对象池模式避免频繁分配
template<typename T>
class ObjectPool {
private:
    std::vector<std::unique_ptr<T>> pool_;
    std::vector<T*> available_;

public:
    template<typename... Args>
    T* acquire(Args&&... args) {
        if (!available_.empty()) {
            T* obj = available_.back();
            available_.pop_back();
            return new (obj) T(std::forward<Args>(args)...); // 就地构造
        }

        pool_.push_back(std::make_unique<T>(std::forward<Args>(args)...));
        return pool_.back().get();
    }

    void release(T* obj) {
        obj->~T(); // 手动析构
        available_.push_back(obj);
    }
};

// ✅ 推荐：使用 placement new 和手动内存管理
class MemoryPool {
private:
    std::unique_ptr<char[]> buffer_;
    char* next_;
    size_t remaining_;

public:
    MemoryPool(size_t size) : buffer_(new char[size]), next_(buffer_.get()), remaining_(size) {}

    template<typename T, typename... Args>
    T* allocate(Args&&... args) {
        void* mem = allocateRaw(sizeof(T));
        return new (mem) T(std::forward<Args>(args)...);
    }

    void* allocateRaw(size_t size) {
        if (size > remaining_) {
            throw std::bad_alloc();
        }

        void* result = next_;
        next_ += size;
        remaining_ -= size;
        return result;
    }
};

// ✅ 推荐：使用 std::array 替代动态数组（当大小固定时）
void processFixedSizeData() {
    std::array<double, 1024> data; // 栈上分配，性能更好

    // 避免 std::vector<double> data(1024); 的堆分配开销
    for (size_t i = 0; i < data.size(); ++i) {
        data[i] = computeValue(i);
    }
}
```

### 编译时优化
```cpp
// ✅ 推荐：模板元编程进行编译时计算
template<size_t N>
struct Factorial {
    static constexpr size_t value = N * Factorial<N - 1>::value;
};

template<>
struct Factorial<0> {
    static constexpr size_t value = 1;
};

// 使用编译时常量
constexpr size_t factorial_10 = Factorial<10>::value;

// ✅ 推荐：使用 constexpr 函数
constexpr int fibonacci(int n) {
    return (n <= 1) ? n : fibonacci(n - 1) + fibonacci(n - 2);
}

// ✅ 推荐：条件编译优化
#ifdef __AVX2__
#include <immintrin.h>

void vectorizedAdd(float* a, float* b, float* result, size_t size) {
    for (size_t i = 0; i < size; i += 8) {
        __m256 va = _mm256_load_ps(&a[i]);
        __m256 vb = _mm256_load_ps(&b[i]);
        __m256 vr = _mm256_add_ps(va, vb);
        _mm256_store_ps(&result[i], vr);
    }
}

#else

void vectorizedAdd(float* a, float* b, float* result, size_t size) {
    for (size_t i = 0; i < size; ++i) {
        result[i] = a[i] + b[i];
    }
}

#endif
```

## 🔒 安全实践

### 边界检查和输入验证
```cpp
#include <string_view>
#include <stdexcept>
#include <algorithm>

// ✅ 推荐：安全的字符串处理
class SecureStringProcessor {
public:
    static std::string sanitizeInput(std::string_view input,
                                   size_t maxLength = 1000) {
        if (input.length() > maxLength) {
            throw std::invalid_argument("Input too long");
        }

        std::string result;
        result.reserve(input.length());

        for (char c : input) {
            if (std::isalnum(c) || std::ispunct(c) || std::isspace(c)) {
                result += c;
            }
            // 过滤掉潜在的危险字符
        }

        return result;
    }

    static bool validateEmail(std::string_view email) {
        if (email.empty() || email.length() > 254) {
            return false;
        }

        // 简单的邮箱格式验证
        auto atPos = email.find('@');
        if (atPos == std::string_view::npos || atPos == 0) {
            return false;
        }

        auto dotPos = email.find('.', atPos);
        return dotPos != std::string_view::npos &&
               dotPos > atPos + 1 &&
               dotPos < email.length() - 1;
    }
};

// ✅ 推荐：安全的数组访问
template<typename T, size_t N>
class SafeArray {
private:
    std::array<T, N> data_;

public:
    T& at(size_t index) {
        if (index >= N) {
            throw std::out_of_range("Array index out of bounds");
        }
        return data_[index];
    }

    const T& at(size_t index) const {
        if (index >= N) {
            throw std::out_of_range("Array index out of bounds");
        }
        return data_[index];
    }

    T& operator[](size_t index) noexcept {
        return data_[index]; // 不进行边界检查，提供性能
    }

    constexpr size_t size() const noexcept {
        return N;
    }
};
```

### 内存安全
```cpp
#include <memory>
#include <vector>
#include <cstring>

// ✅ 推荐：避免缓冲区溢出
void safeCopy(const char* src, char* dst, size_t dstSize) {
    if (!src || !dst) {
        throw std::invalid_argument("Null pointer argument");
    }

    size_t srcLen = std::strlen(src);
    if (srcLen >= dstSize) {
        throw std::length_error("Source string too long for destination buffer");
    }

    std::memcpy(dst, src, srcLen + 1); // +1 for null terminator
}

// ✅ 推荐：智能指针的使用
class ResourceManager {
private:
    std::vector<std::unique_ptr<Resource>> resources_;

public:
    void addResource(std::unique_ptr<Resource> resource) {
        resources_.push_back(std::move(resource));
    }

    // 资源自动管理，无需手动delete
};

// ✅ 推荐：RAII 资源管理
class FileLock {
private:
    int fd_;
    bool locked_;

public:
    explicit FileLock(int fd) : fd_(fd), locked_(false) {
        if (lockf(fd_, F_LOCK, 0) == -1) {
            throw std::system_error(errno, std::generic_category(),
                                  "Failed to acquire file lock");
        }
        locked_ = true;
    }

    ~FileLock() {
        if (locked_) {
            lockf(fd_, F_ULOCK, 0); // 自动解锁
        }
    }

    // 禁止拷贝
    FileLock(const FileLock&) = delete;
    FileLock& operator=(const FileLock&) = delete;
};
```

## 📊 最佳实践

### 设计模式在C++中的应用
```cpp
// 策略模式 - 运行时算法选择
class SortStrategy {
public:
    virtual ~SortStrategy() = default;
    virtual void sort(std::vector<int>& data) = 0;
};

class QuickSort : public SortStrategy {
public:
    void sort(std::vector<int>& data) override {
        std::sort(data.begin(), data.end());
    }
};

class BubbleSort : public SortStrategy {
public:
    void sort(std::vector<int>& data) override {
        // 冒泡排序实现
        for (size_t i = 0; i < data.size(); ++i) {
            for (size_t j = 0; j < data.size() - i - 1; ++j) {
                if (data[j] > data[j + 1]) {
                    std::swap(data[j], data[j + 1]);
                }
            }
        }
    }
};

class Sorter {
private:
    std::unique_ptr<SortStrategy> strategy_;

public:
    void setStrategy(std::unique_ptr<SortStrategy> strategy) {
        strategy_ = std::move(strategy);
    }

    void sort(std::vector<int>& data) {
        if (strategy_) {
            strategy_->sort(data);
        }
    }
};

// 使用示例
Sorter sorter;
if (data.size() > 1000) {
    sorter.setStrategy(std::make_unique<QuickSort>());
} else {
    sorter.setStrategy(std::make_unique<BubbleSort>());
}
```

### 模板元编程
```cpp
// 类型特征 - 编译时类型检查
template<typename T>
struct is_pointer : std::false_type {};

template<typename T>
struct is_pointer<T*> : std::true_type {};

template<typename T>
struct is_pointer<std::shared_ptr<T>> : std::true_type {};

template<typename T>
struct is_pointer<std::unique_ptr<T>> : std::true_type {};

// 静态断言
template<typename T>
void processData(T value) {
    static_assert(!is_pointer<T>::value, "Pointers not allowed");
    // 处理非指针数据
}

// 类型安全的容器
template<typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
class NumericVector {
private:
    std::vector<T> data_;

public:
    void add(T value) {
        data_.push_back(value);
    }

    T sum() const {
        return std::accumulate(data_.begin(), data_.end(), T{0});
    }
};
```

### 并发编程
```cpp
#include <thread>
#include <mutex>
#include <atomic>
#include <future>
#include <condition_variable>

// ✅ 推荐：使用 std::mutex 和 RAII 锁
class ThreadSafeCounter {
private:
    std::mutex mutex_;
    int counter_ = 0;

public:
    void increment() {
        std::lock_guard<std::mutex> lock(mutex_);
        ++counter_;
    }

    int get() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return counter_;
    }
};

// ✅ 推荐：使用原子操作
class LockFreeCounter {
private:
    std::atomic<int> counter_ = 0;

public:
    void increment() {
        counter_.fetch_add(1, std::memory_order_relaxed);
    }

    int get() const {
        return counter_.load(std::memory_order_relaxed);
    }
};

// ✅ 推荐：使用条件变量
class WorkerPool {
private:
    std::vector<std::thread> workers_;
    std::queue<std::function<void()>> tasks_;
    std::mutex queueMutex_;
    std::condition_variable condition_;
    bool stop_ = false;

public:
    WorkerPool(size_t numThreads) {
        for (size_t i = 0; i < numThreads; ++i) {
            workers_.emplace_back([this] {
                while (true) {
                    std::function<void()> task;
                    {
                        std::unique_lock<std::mutex> lock(queueMutex_);
                        condition_.wait(lock, [this] {
                            return stop_ || !tasks_.empty();
                        });

                        if (stop_ && tasks_.empty()) {
                            return;
                        }

                        task = std::move(tasks_.front());
                        tasks_.pop();
                    }
                    task();
                }
            });
        }
    }

    ~WorkerPool() {
        {
            std::unique_lock<std::mutex> lock(queueMutex_);
            stop_ = true;
        }
        condition_.notify_all();

        for (auto& worker : workers_) {
            if (worker.joinable()) {
                worker.join();
            }
        }
    }

    template<typename F>
    void enqueue(F&& task) {
        {
            std::unique_lock<std::mutex> lock(queueMutex_);
            tasks_.emplace(std::forward<F>(task));
        }
        condition_.notify_one();
    }
};
```

## 🔄 现代化升级

### C++版本演进
- **C++11/14**: 基础现代化，智能指针、lambda、auto、constexpr
- **C++17+**: 暂不使用，等待项目成熟后再考虑升级

### 编译器选择
- **GCC**: 开源，Linux平台首选
- **Clang**: 更好的错误信息，跨平台支持
- **MSVC**: Windows平台最佳选择
- **Intel C++**: 数值计算性能优化

### 构建系统
- **CMake**: 现代跨平台构建系统（推荐）
- **Bazel**: 大型项目构建
- **Meson**: 快速简单构建
- **XMake**: Lua脚本构建系统

---

*此规则适用于现代C++开发项目。优先使用C++11/14特性，注重性能、内存安全和代码可维护性。C++17以上特性暂时不用。*