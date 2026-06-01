---
description: "C++ 最佳实践 - 测试、安全、内存管理、设计模式"
globs: ["**/*.cpp", "**/*.hpp"]
alwaysApply: false
priority: 9
---

# C++ 最佳实践 (Practices)

> 本规则由 `@cpp-advanced` 引用

## Catch2 单元测试

```cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("MathUtils - Basic", "[math]") {
    SECTION("Addition") { REQUIRE(utils.add(2, 3) == 5); }
    SECTION("Division by zero") { REQUIRE_THROWS_AS(utils.divide(1.0, 0.0), std::domain_error); }
}
```

## 安全实践

```cpp
void safeCopy(const char* src, char* dst, size_t dstSize) {
    size_t srcLen = std::strlen(src);
    if (srcLen >= dstSize) throw std::length_error("Buffer overflow");
    std::memcpy(dst, src, srcLen + 1);
}

class FileLock {
    int fd_;
    bool locked_;
public:
    explicit FileLock(int fd) : fd_(fd), locked_(false) {
        if (lockf(fd_, F_LOCK, 0) == -1) throw std::system_error(...);
        locked_ = true;
    }
    ~FileLock() { if (locked_) lockf(fd_, F_ULOCK, 0); }
};
```

## 对象池

```cpp
template<typename T>
class ObjectPool {
    std::vector<std::unique_ptr<T>> pool_;
    std::vector<T*> available_;
public:
    template<typename... Args>
    T* acquire(Args&&... args) {
        if (!available_.empty()) {
            T* obj = available_.back();
            available_.pop_back();
            return new (obj) T(std::forward<Args>(args)...);
        }
        pool_.push_back(std::make_unique<T>(std::forward<Args>(args)...));
        return pool_.back().get();
    }
    void release(T* obj) { obj->~T(); available_.push_back(obj); }
};
```

## 设计模式 (策略)

```cpp
class SortStrategy {
public:
    virtual void sort(std::vector<int>& data) = 0;
};
class Sorter {
    std::unique_ptr<SortStrategy> strategy_;
public:
    void setStrategy(std::unique_ptr<SortStrategy> s) { strategy_ = std::move(s); }
    void sort(std::vector<int>& data) { if (strategy_) strategy_->sort(data); }
};
```

## 原则

- **MUST** 使用智能指针管理资源
- **MUST** 进行边界检查
- **PREFER** C++11/14，C++17+ 待项目成熟

---

*引用: @cpp-advanced*
