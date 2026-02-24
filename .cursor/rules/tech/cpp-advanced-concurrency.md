---
description: "C++ 并发编程 - mutex、atomic、条件变量、WorkerPool"
globs: ["**/*.cpp", "**/*.hpp"]
alwaysApply: false
priority: 9
---

# C++ 并发编程 (Concurrency)

> 本规则由 `@cpp-advanced` 引用

## std::mutex + RAII 锁

```cpp
class ThreadSafeCounter {
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
```

## 原子操作

```cpp
class LockFreeCounter {
    std::atomic<int> counter_ = 0;
public:
    void increment() {
        counter_.fetch_add(1, std::memory_order_relaxed);
    }
    int get() const {
        return counter_.load(std::memory_order_relaxed);
    }
};
```

## 条件变量 (WorkerPool)

```cpp
class WorkerPool {
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
                        if (stop_ && tasks_.empty()) return;
                        task = std::move(tasks_.front());
                        tasks_.pop();
                    }
                    task();
                }
            });
        }
    }
    template<typename F>
    void enqueue(F&& task) {
        { std::unique_lock<std::mutex> lock(queueMutex_);
          tasks_.emplace(std::forward<F>(task)); }
        condition_.notify_one();
    }
};
```

## 原则

- **MUST** 使用 lock_guard/unique_lock 管理锁
- **PREFER** atomic 替代 mutex（简单计数器）
- **MUST** 在析构中 join 线程

---

*引用: @cpp-advanced*
