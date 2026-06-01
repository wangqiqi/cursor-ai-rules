---
description: "Rust 类型系统 - 错误处理、泛型、特征、异步"
globs: ["**/*.rs"]
alwaysApply: false
priority: 10
---

# Rust 类型系统 (Types)

> 本规则由 `@rust-basics` 引用

## 错误处理

```rust
#[derive(Debug)]
pub enum Error {
    Io(std::io::Error),
    Validation(String),
    NotFound(String),
}

impl std::error::Error for Error {}
impl From<std::io::Error> for Error { fn from(err: std::io::Error) -> Self { Error::Io(err) } }

pub type Result<T> = std::result::Result<T, Error>;

fn process_user_data(user_id: &str) -> Result<User> {
    let id: u64 = user_id.parse()?;
    let user = find_user_by_id(id).ok_or_else(|| Error::NotFound(format!("User {} not found", id)))?;
    Ok(user)
}
```

## 泛型与特征

```rust
pub trait Repository<T> {
    fn save(&self, item: &T) -> Result<()>;
    fn find_by_id(&self, id: u64) -> Result<Option<T>>;
}

impl<T: Clone + Validatable> Repository<T> for InMemoryRepository<T> { ... }
```

## 异步编程

```rust
#[async_trait::async_trait]
pub trait AsyncRepository<T>: Send + Sync {
    async fn save(&self, item: &T) -> Result<()>;
    async fn find_by_id(&self, id: u64) -> Result<Option<T>>;
}

pub struct SharedCounter {
    count: Mutex<i64>,
}
```

## 原则

- **MUST** 使用 Result 和 ? 操作符
- **MUST** 实现 std::error::Error
- **MUST** 用 async_trait 定义异步特征

---

*引用: @rust-basics*
