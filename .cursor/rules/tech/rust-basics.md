---
description: "Rust开发规则 - 内存安全系统编程和高性能应用最佳实践"
apply_when:
  - file_pattern: "**/*.rs"
  - keywords: ["rust", "cargo"]
priority: 10
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
