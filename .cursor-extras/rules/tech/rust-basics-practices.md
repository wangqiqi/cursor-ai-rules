---
description: "Rust 实践 - 项目结构、Cargo、依赖管理"
globs: ["**/*.rs"]
alwaysApply: false
priority: 10
---

# Rust 实践 (Practices)

> 本规则由 `@rust-basics` 引用

## 项目结构

```
rust_project/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   └── bin/
├── crates/
│   ├── core/
│   ├── api/
│   └── utils/
├── tests/
├── benches/
└── examples/
```

## Cargo.toml

```toml
[package]
name = "my-rust-project"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
anyhow = "1.0"
thiserror = "1.0"

[dev-dependencies]
tokio-test = "0.4"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
```

## 原则

- **MUST** 使用 Cargo 管理依赖
- **MUST** 编写文档注释
- **MUST** 测试边界情况和错误路径
- **NEVER** 泄漏敏感信息到错误消息

---

*引用: @rust-basics*
