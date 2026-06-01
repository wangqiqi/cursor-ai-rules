---
description: "Rust高级实践 - 测试、性能优化、安全实践和最佳实践 (rust, 测试, 性能, 安全, 优化)"
globs: ["**/*.rs"]
alwaysApply: false
priority: 9
---

# Rust 高级实践

本文档是从 `rust.md` 分割出来的高级主题部分，涵盖测试策略、性能优化、安全实践和最佳实践。

# Cargo.toml (工作区根)
[workspace]
members = [
    "crates/core",
    "crates/api",
    "crates/cli",
    "crates/utils",
]

[workspace.dependencies]
# 共享依赖版本
serde = "1.0"
tokio = "1.0"
anyhow = "1.0"
```

### 条件编译
```rust
// 使用条件编译处理平台差异
#[cfg(target_os = "linux")]
mod linux_specific {
    pub fn get_os_info() -> String {
        "Linux".to_string()
    }
}

#[cfg(target_os = "macos")]
mod macos_specific {
    pub fn get_os_info() -> String {
        "macOS".to_string()
    }
}

#[cfg(target_os = "windows")]
mod windows_specific {
    pub fn get_os_info() -> String {
        "Windows".to_string()
    }
}

pub fn get_platform_info() -> String {
    #[cfg(target_os = "linux")]
    return linux_specific::get_os_info();

    #[cfg(target_os = "macos")]
    return macos_specific::get_os_info();

    #[cfg(target_os = "windows")]
    return windows_specific::get_os_info();

    #[allow(unreachable_code)]
    "Unknown".to_string()
}
```

## 🧪 测试策略

### 单元测试和集成测试
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;

    // ✅ 推荐：单元测试
    #[test]
    fn test_user_creation() {
        let username = "john_doe".to_string();
        let email = "john@example.com".to_string();

        let user = User::new(username.clone(), email.clone());

        assert_eq!(user.username, username);
        assert_eq!(user.email, email);
        assert_eq!(user.id, 0); // 默认ID
        assert!(user.created_at <= chrono::Utc::now());
    }

    #[test]
    fn test_user_validation() {
        // 有效用户
        let user = User::new("john".to_string(), "john@example.com".to_string());
        assert!(user.validate().is_ok());

        // 无效用户名
        let invalid_user = User::new("".to_string(), "john@example.com".to_string());
        assert!(invalid_user.validate().is_err());

        // 无效邮箱
        let invalid_user2 = User::new("john".to_string(), "invalid-email".to_string());
        assert!(invalid_user2.validate().is_err());
    }

    // ✅ 推荐：异步测试
    #[tokio::test]
    async fn test_async_user_service() {
        let repository = Arc::new(InMemoryRepository::<User>::new());
        let service = AsyncUserService::new(repository);

        let result = service.create_user(
            "john".to_string(),
            "john@example.com".to_string()
        ).await;

        assert!(result.is_ok());
        let user = result.unwrap();
        assert_eq!(user.username, "john");
    }

    // ✅ 推荐：测试fixture
    struct TestFixture {
        repository: InMemoryRepository<User>,
        service: UserService,
    }

    impl TestFixture {
        fn new() -> Self {
            let repository = InMemoryRepository::new();
            let service = UserService::new(Arc::new(repository));

            Self { repository, service }
        }

        fn create_test_user(&mut self, username: &str, email: &str) -> User {
            let user = User::new(username.to_string(), email.to_string());
            self.repository.save(&user).unwrap();
            user
        }
    }

    #[test]
    fn test_user_operations_with_fixture() {
        let mut fixture = TestFixture::new();

        // 创建测试用户
        let user = fixture.create_test_user("test", "test@example.com");

        // 测试查找
        let found = fixture.service.find_user_by_id(user.id).unwrap();
        assert!(found.is_some());
        assert_eq!(found.unwrap().username, "test");
    }

    // ✅ 推荐：属性测试
    #[cfg(feature = "proptest")]
    mod proptest_tests {
        use proptest::prelude::*;

        proptest! {
            #[test]
            fn test_user_creation_with_random_data(
                username in "[a-zA-Z0-9_]{1,50}",
                email in "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
            ) {
                let user = User::new(username.clone(), email.clone());
                prop_assert_eq!(user.username, username);
                prop_assert_eq!(user.email, email);
            }
        }
    }
}
```

### 基准测试
```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn benchmark_user_creation(c: &mut Criterion) {
    c.bench_function("user_creation", |b| {
        b.iter(|| {
            let user = User::new(
                black_box("benchmark_user".to_string()),
                black_box("bench@example.com".to_string())
            );
            black_box(user);
        });
    });
}

fn benchmark_user_validation(c: &mut Criterion) {
    let user = User::new("valid_user".to_string(), "valid@example.com".to_string());

    c.bench_function("user_validation", |b| {
        b.iter(|| {
            let result = user.validate();
            black_box(result);
        });
    });
}

fn benchmark_string_processing(c: &mut Criterion) {
    let data = "some test data for benchmarking string operations";

    c.bench_function("string_processing", |b| {
        b.iter(|| {
            let processed = process_string(black_box(data));
            black_box(processed);
        });
    });
}

criterion_group!(
    benches,
    benchmark_user_creation,
    benchmark_user_validation,
    benchmark_string_processing
);
criterion_main!(benches);
```

### 文档测试
```rust
/// 用户管理服务
///
/// # Examples
///
/// ```
/// use my_project::services::UserService;
/// use my_project::repositories::InMemoryRepository;
/// use std::sync::Arc;
///
/// let repository = Arc::new(InMemoryRepository::new());
/// let service = UserService::new(repository);
///
/// // 创建用户
/// let user = service.create_user("alice", "alice@example.com").unwrap();
/// assert_eq!(user.username, "alice");
/// ```
pub struct UserService {
    // ...
}
```

## 🚀 性能优化

### 零拷贝和内存优化
```rust
use std::mem;

// ✅ 推荐：使用切片避免拷贝
fn process_data(data: &[u8]) -> Vec<u8> {
    // 处理数据而不拷贝
    data.iter()
        .filter(|&&b| b.is_ascii_alphanumeric())
        .map(|&b| b.to_ascii_uppercase())
        .collect()
}

// ✅ 推荐：原地修改优化
fn process_data_inplace(data: &mut [u8]) {
    for byte in data.iter_mut() {
        if byte.is_ascii_lowercase() {
            *byte = byte.to_ascii_uppercase();
        }
    }
}

// ✅ 推荐：Box用于大结构体
#[derive(Clone)]
struct LargeStruct {
    data: [u8; 1024],
    metadata: String,
}

fn create_large_struct() -> Box<LargeStruct> {
    Box::new(LargeStruct {
        data: [0; 1024],
        metadata: "large data".to_string(),
    })
}

// ✅ 推荐：Cow优化读多写少场景
use std::borrow::Cow;

fn normalize_text(input: &str) -> Cow<str> {
    if input.chars().any(|c| c.is_uppercase()) {
        // 需要修改，创建 owned string
        Cow::Owned(input.to_lowercase())
    } else {
        // 无需修改，返回借用
        Cow::Borrowed(input)
    }
}
```

### 编译时优化
```rust
// ✅ 推荐：const fn 编译时计算
const fn fibonacci(n: usize) -> usize {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

const FIB_10: usize = fibonacci(10);

// ✅ 推荐：泛型特化优化
trait Processor<T> {
    fn process(&self, input: T) -> T;
}

// 通用实现
impl<T: Clone> Processor<T> for GenericProcessor {
    fn process(&self, input: T) -> T {
        // 通用处理逻辑
        input
    }
}

// 针对特定类型的特化优化
impl Processor<Vec<i32>> for OptimizedProcessor {
    fn process(&self, mut input: Vec<i32>) -> Vec<i32> {
        // SIMD优化处理
        input.iter_mut().for_each(|x| *x *= 2);
        input
    }
}

// ✅ 推荐：内联优化
#[inline(always)]
fn hot_function(x: i32) -> i32 {
    x * 2 + 1
}

#[inline(never)]
fn cold_function(data: &[u8]) {
    // 很少调用的函数，防止内联
    println!("Processing {} bytes", data.len());
}
```

### 并发优化
```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::thread;
use rayon::prelude::*;

// ✅ 推荐：原子操作
pub struct AtomicCounter {
    count: AtomicUsize,
}

impl AtomicCounter {
    pub fn new() -> Self {
        Self {
            count: AtomicUsize::new(0),
        }
    }

    pub fn increment(&self) -> usize {
        self.count.fetch_add(1, Ordering::SeqCst) + 1
    }

    pub fn get(&self) -> usize {
        self.count.load(Ordering::SeqCst)
    }
}

// ✅ 推荐：Rayon并行处理
fn parallel_process_data(data: &[i32]) -> i32 {
    data.par_iter()
        .map(|&x| expensive_computation(x))
        .sum()
}

fn expensive_computation(x: i32) -> i32 {
    // 模拟耗时计算
    thread::sleep(std::time::Duration::from_micros(100));
    x * x
}

// ✅ 推荐：跨beam并行
use crossbeam::channel;
use crossbeam::thread;

fn parallel_pipeline(input: Vec<i32>) -> Vec<i32> {
    let (sender, receiver) = channel::bounded(100);

    thread::scope(|s| {
        // 生产者线程
        s.spawn(|_| {
            for item in input {
                sender.send(item).unwrap();
            }
            drop(sender);
        });
