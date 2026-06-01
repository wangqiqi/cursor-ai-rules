---
description: "Rust 所有权与生命周期 - 借用、智能指针、Rc/Arc"
globs: ["**/*.rs"]
alwaysApply: false
priority: 10
---

# Rust 所有权与生命周期 (Ownership)

> 本规则由 `@rust-basics` 引用

## 所有权转移

```rust
struct User {
    id: u64,
    username: String,
    email: String,
}

impl User {
    fn new(username: String, email: String) -> Self {
        Self { id: 0, username, email }
    }
    fn username(&self) -> &str { &self.username }
    fn update_email(&mut self, new_email: String) { self.email = new_email; }
}
```

## 引用与生命周期

```rust
fn find_user_by_id<'a>(users: &'a [User], id: u64) -> Option<&'a User> {
    users.iter().find(|user| user.id == id)
}

struct UserManager<'a> {
    database: &'a mut Database,
}
```

## 智能指针

```rust
use std::rc::Rc;
use std::sync::Arc;

struct AppState {
    config: Arc<SharedConfig>,
}
type SharedAppState = Arc<AppState>;
```

## 原则

- **MUST** 优先使用引用避免拷贝
- **MUST** 用 Arc 跨线程共享
- **MUST** 明确生命周期参数

---

*引用: @rust-basics*
