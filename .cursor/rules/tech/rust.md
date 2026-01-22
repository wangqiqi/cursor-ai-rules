---
command: rust
description: "Rust开发规则 - 内存安全系统编程和高性能应用最佳实践"
alwaysApply: false
---

# 🦀 Rust 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 系统级编程和操作系统开发
- 高性能计算和游戏引擎
- 网络服务和分布式系统
- 嵌入式系统和物联网设备
- 区块链和加密货币应用
- WebAssembly和浏览器应用
- 命令行工具和系统工具

## 🏗️ 项目结构

### Cargo Workspace 项目布局
```
rust_project/
├── Cargo.toml              # 工作区根配置
├── Cargo.lock              # 依赖锁定文件
├── src/                    # 主crate源码
│   ├── main.rs
│   ├── lib.rs
│   └── bin/                # 二进制目标
│       └── cli.rs
├── crates/                 # 子crate
│   ├── core/               # 核心库
│   │   ├── Cargo.toml
│   │   ├── src/
│   │   │   ├── lib.rs
│   │   │   └── models.rs
│   │   └── tests/
│   ├── api/                # API crate
│   │   ├── Cargo.toml
│   │   └── src/
│   └── utils/              # 工具库
│       ├── Cargo.toml
│       └── src/
├── benches/                # 性能基准测试
├── examples/               # 示例程序
├── tests/                  # 集成测试
├── docs/                   # 文档
├── scripts/                # 构建脚本
├── .rustfmt.toml          # 代码格式化配置
├── clippy.toml            # Clippy配置
└── README.md
```

### 单体Crate结构
```
single_crate/
├── Cargo.toml
├── src/
│   ├── main.rs            # 二进制入口
│   ├── lib.rs             # 库入口
│   ├── models.rs          # 数据模型
│   ├── handlers.rs        # 处理逻辑
│   ├── services.rs        # 业务服务
│   ├── repositories.rs    # 数据访问
│   ├── utils.rs           # 工具函数
│   └── config.rs          # 配置管理
├── tests/                 # 集成测试
├── benches/               # 基准测试
└── examples/              # 示例
```

## 📝 编码规范

### 所有权和生命周期管理
```rust
// ✅ 推荐：明确的所有权转移
#[derive(Debug, Clone)]
struct User {
    id: u64,
    username: String,
    email: String,
    created_at: chrono::DateTime<chrono::Utc>,
}

impl User {
    // 构造函数转移所有权
    fn new(username: String, email: String) -> Self {
        Self {
            id: 0, // 将由数据库设置
            username,
            email,
            created_at: chrono::Utc::now(),
        }
    }

    // 借用方法（只读访问）
    fn username(&self) -> &str {
        &self.username
    }

    // 可变借用方法
    fn update_email(&mut self, new_email: String) {
        self.email = new_email;
    }

    // 转移所有权的方法
    fn into_parts(self) -> (u64, String, String) {
        (self.id, self.username, self.email)
    }
}

// ✅ 推荐：使用引用避免不必要的拷贝
fn find_user_by_id<'a>(users: &'a [User], id: u64) -> Option<&'a User> {
    users.iter().find(|user| user.id == id)
}

// ✅ 推荐：生命周期参数明确
struct UserManager<'a> {
    database: &'a mut Database,
}

impl<'a> UserManager<'a> {
    fn new(database: &'a mut Database) -> Self {
        Self { database }
    }

    fn create_user(&mut self, username: String, email: String) -> Result<User, Error> {
        // 验证输入
        self.validate_user_data(&username, &email)?;

        let user = User::new(username, email);

        // 保存到数据库
        self.database.save_user(&user)?;

        Ok(user)
    }

    fn validate_user_data(&self, username: &str, email: &str) -> Result<(), Error> {
        if username.is_empty() {
            return Err(Error::Validation("Username cannot be empty".to_string()));
        }

        if !email.contains('@') {
            return Err(Error::Validation("Invalid email format".to_string()));
        }

        Ok(())
    }
}

// ✅ 推荐：智能指针管理复杂所有权
use std::rc::Rc;
use std::sync::Arc;

#[derive(Clone)]
struct SharedConfig {
    database_url: String,
    max_connections: usize,
}

struct AppState {
    config: Arc<SharedConfig>,
    user_manager: UserManager<'static>, // 假设静态生命周期
}

// 线程安全的共享状态
type SharedAppState = Arc<AppState>;
```

### 错误处理模式
```rust
use std::fmt;
use std::error::Error as StdError;

// ✅ 推荐：自定义错误类型
#[derive(Debug)]
pub enum Error {
    Io(std::io::Error),
    Parse(std::num::ParseIntError),
    Validation(String),
    Database(String),
    NotFound(String),
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::Io(err) => write!(f, "IO error: {}", err),
            Error::Parse(err) => write!(f, "Parse error: {}", err),
            Error::Validation(msg) => write!(f, "Validation error: {}", msg),
            Error::Database(msg) => write!(f, "Database error: {}", msg),
            Error::NotFound(msg) => write!(f, "Not found: {}", msg),
        }
    }
}

impl StdError for Error {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            Error::Io(err) => Some(err),
            Error::Parse(err) => Some(err),
            _ => None,
        }
    }
}

// 错误转换
impl From<std::io::Error> for Error {
    fn from(err: std::io::Error) -> Self {
        Error::Io(err)
    }
}

impl From<std::num::ParseIntError> for Error {
    fn from(err: std::num::ParseIntError) -> Self {
        Error::Parse(err)
    }
}

// ✅ 推荐：Result和Option的高级使用
fn process_user_data(user_id: &str) -> Result<User, Error> {
    // 解析用户ID
    let id: u64 = user_id.parse().map_err(Error::from)?;

    // 获取用户（可能不存在）
    let user = find_user_by_id(id).ok_or_else(|| {
        Error::NotFound(format!("User with id {} not found", id))
    })?;

    // 验证用户状态
    if !user.is_active {
        return Err(Error::Validation("User is not active".to_string()));
    }

    Ok(user)
}

// ✅ 推荐：错误处理的组合器
fn process_multiple_users(user_ids: &[String]) -> Result<Vec<User>, Error> {
    user_ids
        .iter()
        .map(|id| process_user_data(id))
        .collect::<Result<Vec<_>, _>>()
}

// ✅ 推荐：自定义Result类型
pub type Result<T> = std::result::Result<T, Error>;
```

### 泛型和特征
```rust
// ✅ 推荐：泛型约束和特征定义
pub trait Repository<T> {
    fn save(&self, item: &T) -> Result<()>;
    fn find_by_id(&self, id: u64) -> Result<Option<T>>;
    fn find_all(&self) -> Result<Vec<T>>;
    fn delete(&self, id: u64) -> Result<bool>;
}

pub trait Validatable {
    fn validate(&self) -> Result<()>;
}

// ✅ 推荐：泛型实现
struct InMemoryRepository<T> {
    items: std::collections::HashMap<u64, T>,
    next_id: u64,
}

impl<T> InMemoryRepository<T> {
    fn new() -> Self {
        Self {
            items: std::collections::HashMap::new(),
            next_id: 1,
        }
    }
}

impl<T: Clone + Validatable> Repository<T> for InMemoryRepository<T> {
    fn save(&self, item: &T) -> Result<()> {
        item.validate()?;

        let id = self.next_id;
        self.items.insert(id, item.clone());
        self.next_id += 1;

        Ok(())
    }

    fn find_by_id(&self, id: u64) -> Result<Option<T>> {
        Ok(self.items.get(&id).cloned())
    }

    fn find_all(&self) -> Result<Vec<T>> {
        Ok(self.items.values().cloned().collect())
    }

    fn delete(&self, id: u64) -> Result<bool> {
        Ok(self.items.remove(&id).is_some())
    }
}

// ✅ 推荐：特征对象和动态分发
pub trait Handler {
    fn handle(&self, request: &Request) -> Result<Response>;
}

pub struct Router {
    routes: std::collections::HashMap<String, Box<dyn Handler + Send + Sync>>,
}

impl Router {
    pub fn add_route<H: Handler + Send + Sync + 'static>(
        &mut self,
        path: String,
        handler: H
    ) {
        self.routes.insert(path, Box::new(handler));
    }

    pub fn route(&self, request: &Request) -> Result<Response> {
        if let Some(handler) = self.routes.get(&request.path) {
            handler.handle(request)
        } else {
            Err(Error::NotFound("Route not found".to_string()))
        }
    }
}
```

### 异步编程
```rust
use tokio::sync::Mutex;
use std::sync::Arc;

// ✅ 推荐：异步函数和Future
#[derive(Clone)]
pub struct AsyncUserService {
    repository: Arc<dyn Repository<User> + Send + Sync>,
}

impl AsyncUserService {
    pub fn new(repository: Arc<dyn Repository<User> + Send + Sync>) -> Self {
        Self { repository }
    }

    pub async fn create_user(&self, username: String, email: String) -> Result<User> {
        // 异步验证
        self.validate_user_data(&username, &email).await?;

        let user = User::new(username, email);

        // 异步保存
        self.repository.save(&user).await?;

        Ok(user)
    }

    async fn validate_user_data(&self, username: &str, email: &str) -> Result<()> {
        // 模拟异步验证（比如检查数据库中的唯一性）
        tokio::time::sleep(std::time::Duration::from_millis(10)).await;

        if username.is_empty() {
            return Err(Error::Validation("Username cannot be empty".to_string()));
        }

        if !email.contains('@') {
            return Err(Error::Validation("Invalid email format".to_string()));
        }

        Ok(())
    }
}

// ✅ 推荐：并发安全的共享状态
pub struct SharedCounter {
    count: Mutex<i64>,
}

impl SharedCounter {
    pub fn new() -> Self {
        Self {
            count: Mutex::new(0),
        }
    }

    pub async fn increment(&self) -> Result<i64> {
        let mut count = self.count.lock().await;
        *count += 1;
        Ok(*count)
    }

    pub async fn get(&self) -> Result<i64> {
        let count = self.count.lock().await;
        Ok(*count)
    }
}

// ✅ 推荐：Stream处理
use futures::stream::{self, StreamExt};

pub async fn process_users_batch(user_ids: Vec<u64>) -> Result<Vec<User>> {
    // 创建并发流
    let results = stream::iter(user_ids)
        .map(|id| async move {
            // 模拟异步获取用户
            tokio::time::sleep(std::time::Duration::from_millis(50)).await;
            find_user_by_id(id).await
        })
        .buffer_unordered(10) // 限制并发数量
        .collect::<Vec<_>>()
        .await;

    // 过滤掉None值并收集结果
    let users = results
        .into_iter()
        .filter_map(|result| result.transpose())
        .collect::<Result<Vec<_>>>()?;

    Ok(users)
}

// ✅ 推荐：异步trait
#[async_trait::async_trait]
pub trait AsyncRepository<T>: Send + Sync {
    async fn save(&self, item: &T) -> Result<()>;
    async fn find_by_id(&self, id: u64) -> Result<Option<T>>;
    async fn find_all(&self) -> Result<Vec<T>>;
}
```

## 🛠️ 依赖管理

### Cargo.toml 配置
```toml
[package]
name = "my-rust-project"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A Rust project"
license = "MIT OR Apache-2.0"
keywords = ["rust", "async", "web"]
categories = ["web-programming", "database"]
repository = "https://github.com/yourname/project"

[dependencies]
# Web框架
axum = { version = "0.6", features = ["json", "multipart"] }
tokio = { version = "1.0", features = ["full"] }

# 序列化
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# 数据库
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres", "chrono"] }
redis = "0.23"

# 错误处理
anyhow = "1.0"
thiserror = "1.0"

# 日志
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# 工具库
chrono = { version = "0.4", features = ["serde"] }
uuid = { version = "1.0", features = ["v4", "serde"] }
regex = "1.9"

[dev-dependencies]
# 测试工具
tokio-test = "0.4"
criterion = { version = "0.5", features = ["html_reports"] }

[build-dependencies]
# 构建时依赖
cc = "1.0"

[features]
default = []
postgres = ["sqlx/postgres"]
mysql = ["sqlx/mysql"]
sqlite = ["sqlx/sqlite"]

[[bench]]
name = "my_benchmarks"
harness = false

[profile.release]
opt-level = 3
debug = false
strip = true
lto = true
codegen-units = 1
panic = "abort"
```

### 工作区管理
```toml
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

        // 消费者线程
        let handles: Vec<_> = (0..4).map(|_| {
            s.spawn(|_| {
                let mut results = Vec::new();
                while let Ok(item) = receiver.recv() {
                    results.push(process_item(item));
                }
                results
            })
        }).collect();

        // 收集结果
        let mut final_results = Vec::new();
        for handle in handles {
            final_results.extend(handle.join().unwrap());
        }

        final_results
    }).unwrap()
}

fn process_item(item: i32) -> i32 {
    item * 2
}
```

## 🔒 安全实践

### 内存安全保证
```rust
// ✅ 推荐：使用类型系统防止常见错误
#[derive(Debug, Clone)]
pub struct NonEmptyString(String);

impl NonEmptyString {
    pub fn new(s: String) -> Option<Self> {
        if s.is_empty() {
            None
        } else {
            Some(Self(s))
        }
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl std::fmt::Display for NonEmptyString {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// ✅ 推荐：范围类型防止越界
#[derive(Debug, Clone, Copy)]
pub struct RangeInclusive<T> {
    start: T,
    end: T,
}

impl<T: PartialOrd + Copy> RangeInclusive<T> {
    pub fn new(start: T, end: T) -> Option<Self> {
        if start <= end {
            Some(Self { start, end })
        } else {
            None
        }
    }

    pub fn contains(&self, value: T) -> bool {
        self.start <= value && value <= self.end
    }
}

// ✅ 推荐：PhantomData处理泛型生命周期
use std::marker::PhantomData;

struct DatabaseConnection<'a> {
    _marker: PhantomData<&'a ()>,
    // 实际连接数据...
}

impl<'a> DatabaseConnection<'a> {
    fn new() -> Self {
        Self {
            _marker: PhantomData,
        }
    }
}
```

### FFI安全
```rust
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};

// ✅ 推荐：安全的FFI包装
#[link(name = "mylib")]
extern "C" {
    fn c_function(input: *const c_char) -> c_int;
    fn c_function_safe(input: *const c_char, output: *mut c_char, output_len: c_int) -> c_int;
}

pub fn safe_c_function(input: &str) -> Result<String, Box<dyn std::error::Error>> {
    let c_input = CString::new(input)?;

    // 安全的调用
    let result_code = unsafe { c_function(c_input.as_ptr()) };

    if result_code != 0 {
        return Err(format!("C function failed with code {}", result_code).into());
    }

    Ok("success".to_string())
}

// ✅ 推荐：FFI类型安全包装
pub struct SafeFFIWrapper {
    // 封装不安全的FFI调用
}

impl SafeFFIWrapper {
    pub fn call_external_function(&self, data: &[u8]) -> Result<Vec<u8>, Error> {
        // 验证输入
        if data.is_empty() {
            return Err(Error::Validation("Input data cannot be empty".to_string()));
        }

        // 安全的FFI调用
        let mut output = vec![0u8; 1024]; // 预分配输出缓冲区

        let result = unsafe {
            c_function_safe(
                data.as_ptr() as *const c_char,
                output.as_mut_ptr() as *mut c_char,
                output.len() as c_int
            )
        };

        if result < 0 {
            return Err(Error::Io(std::io::Error::last_os_error()));
        }

        // 截取实际输出长度
        output.truncate(result as usize);
        Ok(output)
    }
}
```

## 📊 最佳实践

### 宏和代码生成
```rust
// ✅ 推荐：声明宏简化重复代码
macro_rules! impl_display_for_enum {
    ($enum_name:ident { $($variant:ident),* $(,)? }) => {
        impl std::fmt::Display for $enum_name {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                match self {
                    $(Self::$variant => write!(f, stringify!($variant)),)*
                }
            }
        }
    };
}

#[derive(Debug, Clone)]
pub enum Status {
    Active,
    Inactive,
    Pending,
}

impl_display_for_enum!(Status { Active, Inactive, Pending });

// ✅ 推荐：过程宏（attribute宏）
#[derive(Builder, Debug)]
#[builder(name = "UserBuilder")]
pub struct User {
    #[builder(setter(into))]
    username: String,

    #[builder(setter(into))]
    email: String,

    #[builder(default = "false")]
    is_active: bool,
}

// 生成的代码可以这样使用：
// let user = UserBuilder::default()
//     .username("john")
//     .email("john@example.com")
//     .is_active(true)
//     .build()
//     .unwrap();
```

### 设计模式在Rust中的应用
```rust
// ✅ 推荐：Newtype模式增强类型安全
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(pub u64);

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct OrderId(pub u64);

impl UserId {
    pub fn new(id: u64) -> Self {
        Self(id)
    }

    pub fn value(&self) -> u64 {
        self.0
    }
}

impl OrderId {
    pub fn new(id: u64) -> Self {
        Self(id)
    }

    pub fn value(&self) -> u64 {
        self.0
    }
}

// 防止ID混用
fn process_user(user_id: UserId, order_id: OrderId) {
    // 编译器会阻止传递错误类型的ID
}

// ✅ 推荐：策略模式
pub trait SortingStrategy {
    fn sort(&self, data: &mut [i32]);
}

pub struct BubbleSort;
pub struct QuickSort;

impl SortingStrategy for BubbleSort {
    fn sort(&self, data: &mut [i32]) {
        // 冒泡排序实现
        for i in 0..data.len() {
            for j in 0..data.len() - i - 1 {
                if data[j] > data[j + 1] {
                    data.swap(j, j + 1);
                }
            }
        }
    }
}

impl SortingStrategy for QuickSort {
    fn sort(&self, data: &mut [i32]) {
        quicksort_helper(data, 0, data.len() as isize - 1);
    }
}

fn quicksort_helper(data: &mut [i32], low: isize, high: isize) {
    if low < high {
        let pivot_index = partition(data, low, high);
        quicksort_helper(data, low, pivot_index - 1);
        quicksort_helper(data, pivot_index + 1, high);
    }
}

fn partition(data: &mut [i32], low: isize, high: isize) -> isize {
    let pivot = data[high as usize];
    let mut i = low - 1;

    for j in low..high {
        if data[j as usize] < pivot {
            i += 1;
            data.swap(i as usize, j as usize);
        }
    }

    data.swap((i + 1) as usize, high as usize);
    i + 1
}

pub struct Sorter<T: SortingStrategy> {
    strategy: T,
}

impl<T: SortingStrategy> Sorter<T> {
    pub fn new(strategy: T) -> Self {
        Self { strategy }
    }

    pub fn sort(&self, data: &mut [i32]) {
        self.strategy.sort(data);
    }
}
```

### 项目组织最佳实践
```rust
// ✅ 推荐：清晰的模块结构
pub mod models {
    pub mod user;
    pub mod order;
}

pub mod services {
    pub mod user_service;
    pub mod order_service;
}

pub mod repositories {
    pub mod user_repository;
    pub mod order_repository;
}

pub mod handlers {
    pub mod user_handler;
    pub mod order_handler;
}

pub mod utils {
    pub mod validation;
    pub mod crypto;
}

// lib.rs
pub use models::*;
pub use services::*;
pub use repositories::*;
pub use handlers::*;
pub use utils::*;

// 或者使用更细粒度的导出
pub mod models {
    pub use self::user::*;
    pub use self::order::*;
}
```

## 🔄 现代化升级

### Rust版本演进
- **Rust 2021**: 新的预导入和语法改进
- **Rust 2024**: 预计的下一个edition
- **Nightly功能**: 异步函数、泛型关联类型等

### 生态系统选择
- **Web**: axum, warp, rocket
- **异步**: tokio, async-std, smol
- **数据库**: diesel, sqlx, rbatis
- **序列化**: serde
- **CLI**: clap, structopt
- **GUI**: iced, druid, tauri

### 性能和安全
- **编译优化**: LTO, 代码生成单元优化
- **安全检查**: 边界检查、所有权检查
- **并发安全**: Send/Sync trait保证

---

*此规则适用于现代Rust开发项目。充分利用所有权系统和类型安全，构建高性能、安全的系统。*