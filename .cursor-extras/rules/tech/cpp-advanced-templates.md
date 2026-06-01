---
description: "C++ 模板与编译时优化 - 模板元编程、constexpr、类型特征"
globs: ["**/*.cpp", "**/*.hpp"]
alwaysApply: false
priority: 9
---

# C++ 模板与编译时优化 (Templates)

> 本规则由 `@cpp-advanced` 引用

## 模板元编程

```cpp
template<size_t N>
struct Factorial {
    static constexpr size_t value = N * Factorial<N - 1>::value;
};
template<> struct Factorial<0> { static constexpr size_t value = 1; };

constexpr size_t factorial_10 = Factorial<10>::value;
```

## 类型特征

```cpp
template<typename T>
struct is_pointer : std::false_type {};
template<typename T>
struct is_pointer<T*> : std::true_type {};

template<typename T>
void processData(T value) {
    static_assert(!is_pointer<T>::value, "Pointers not allowed");
}
```

## constexpr 函数

```cpp
constexpr int fibonacci(int n) {
    return (n <= 1) ? n : fibonacci(n - 1) + fibonacci(n - 2);
}
```

## 条件编译 (SIMD)

```cpp
#ifdef __AVX2__
#include <immintrin.h>
void vectorizedAdd(float* a, float* b, float* result, size_t size) {
    for (size_t i = 0; i < size; i += 8) {
        __m256 va = _mm256_load_ps(&a[i]);
        __m256 vb = _mm256_load_ps(&b[i]);
        _mm256_store_ps(&result[i], _mm256_add_ps(va, vb));
    }
}
#else
void vectorizedAdd(float* a, float* b, float* result, size_t size) {
    for (size_t i = 0; i < size; ++i) result[i] = a[i] + b[i];
}
#endif
```

## 原则

- **MUST** 使用 constexpr 进行编译时计算
- **MUST** 用 static_assert 约束模板参数

---

*引用: @cpp-advanced*
