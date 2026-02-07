---
description: "Rust性能优化和最佳实践 - 零成本抽象和unsafe指南"
apply_when:
  - keywords: ["rust", "性能", "优化", "unsafe", "最佳实践"]
priority: 9
---

# ⚡ Rust 性能优化和最佳实践


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

