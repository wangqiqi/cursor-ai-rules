---
description: "Go高级实践 - 测试、性能优化、安全实践和最佳实践"
apply_when:
  - keywords: ["go", "测试", "性能", "安全", "优化"]
priority: 9
---

# Go 高级实践

本文档是从 `go.md` 分割出来的高级主题部分，涵盖测试策略、性能优化、安全实践和最佳实践。

## ⚠️ 执行原则

**MUST** 遵循以下Go高级开发准则：
- **MUST** 编写全面的单元测试和集成测试
- **NEVER** 忽略错误处理和边界情况
- **ALWAYS** 进行性能基准测试
- **DO NOT** 在生产环境使用调试代码
- **MUST** 遵循Go语言的安全最佳实践
- **ALWAYS** 优化goroutine和channel的使用

### 测试策略
    "github.com/yourname/project/internal/repository"
)

// ✅ 推荐：表格驱动测试
func TestUser_Validate(t *testing.T) {
    tests := []struct {
        name     string
        user     models.User
        wantErr  bool
        errField string
    }{
        {
            name: "valid user",
            user: models.User{
                Username: "john_doe",
                Email:    "john@example.com",
            },
            wantErr: false,
        },
        {
            name: "empty username",
            user: models.User{
                Username: "",
                Email:    "john@example.com",
            },
            wantErr:  true,
            errField: "username",
        },
        {
            name: "invalid email",
            user: models.User{
                Username: "john_doe",
                Email:    "invalid-email",
            },
            wantErr:  true,
            errField: "email",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := tt.user.Validate()
            if tt.wantErr {
                assert.Error(t, err)
                if tt.errField != "" {
                    assert.Contains(t, err.Error(), tt.errField)
                }
            } else {
                assert.NoError(t, err)
            }
        })
    }
}

// ✅ 推荐：使用 testify 增强断言
func TestUserService_CreateUser(t *testing.T) {
    // Setup
    mockRepo := &repository.MockUserRepository{}
    service := NewUserService(mockRepo)

    // Test data
    username := "john_doe"
    email := "john@example.com"

    // Expectations
    expectedUser := &models.User{
        Username: username,
        Email:    email,
    }
    mockRepo.On("Create", mock.Anything, mock.MatchedBy(func(user *models.User) bool {
        return user.Username == username && user.Email == email
    })).Return(nil).Once()

    // Execute
    user, err := service.CreateUser(context.Background(), username, email)

    // Assert
    require.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, username, user.Username)
    assert.Equal(t, email, user.Email)
    mockRepo.AssertExpectations(t)
}

// ✅ 推荐：基准测试
func BenchmarkUserService_CreateUser(b *testing.B) {
    // Setup
    service := setupUserService()

    b.ResetTimer()
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            _, err := service.CreateUser(context.Background(), "user", "user@example.com")
            if err != nil {
                b.Fatal(err)
            }
        }
    })
}

// ✅ 推荐：集成测试
func TestMain(m *testing.M) {
    // Setup database
    db := setupTestDatabase()
    defer db.Close()

    // Run tests
    code := m.Run()

    // Cleanup
    teardownTestDatabase(db)

    os.Exit(code)
}
```

### 测试组织
```
user_service_test.go     # 单元测试
user_service_int_test.go # 集成测试
user_service_bench_test.go # 基准测试
```

### 测试覆盖率
```bash
# 运行测试并生成覆盖率报告
go test -cover ./...

# 生成HTML覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html

# 查看函数级覆盖率
go test -cover -covermode=count ./...

# 设置最低覆盖率要求
go test -cover -covermode=count -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep "total:"
```

## 🚀 性能优化

### 内存管理优化
```go
// ✅ 推荐：对象池模式避免频繁分配
type BufferPool struct {
    pool sync.Pool
}

func NewBufferPool() *BufferPool {
    return &BufferPool{
        pool: sync.Pool{
            New: func() interface{} {
                return &bytes.Buffer{}
            },
        },
    }
}

func (p *BufferPool) Get() *bytes.Buffer {
    return p.pool.Get().(*bytes.Buffer)
}

func (p *BufferPool) Put(buf *bytes.Buffer) {
    buf.Reset()
    p.pool.Put(buf)
}

// ✅ 推荐：字符串拼接优化
func buildQueryEfficient(ids []int64) string {
    if len(ids) == 0 {
        return ""
    }

    var builder strings.Builder
    builder.Grow(len(ids)*8 + 20) // 预分配容量

    builder.WriteString("SELECT * FROM users WHERE id IN (")

    for i, id := range ids {
        if i > 0 {
            builder.WriteString(",")
        }
        builder.WriteString(strconv.FormatInt(id, 10))
    }

    builder.WriteString(")")
    return builder.String()
}

// ✅ 推荐：切片预分配容量
func processUsersEfficient(users []User) []User {
    processed := make([]User, 0, len(users)) // 预分配容量

    for _, user := range users {
        if user.IsActive {
            processed = append(processed, user)
        }
    }

    return processed
}

// ✅ 推荐：使用指针避免大结构体拷贝
type LargeStruct struct {
    Data [1024]byte
    Name string
}

func (ls *LargeStruct) Process() {
    // 直接修改，无需拷贝
    ls.Data[0] = 0xFF
}

// 错误方式：值传递导致拷贝
func processLargeStruct(ls LargeStruct) {
    // 整个结构体被拷贝
}

// 正确方式：指针传递
func processLargeStructPtr(ls *LargeStruct) {
    // 只传递指针
}
```

### 并发优化
```go
// ✅ 推荐：使用 sync.Pool 复用对象
var bufferPool = sync.Pool{
    New: func() interface{} {
        return &bytes.Buffer{}
    },
}

func processRequest(data []byte) []byte {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer bufferPool.Put(buf)
    buf.Reset()

    // 使用缓冲区处理数据
    buf.Write(data)
    // ... 处理逻辑 ...

    result := make([]byte, buf.Len())
    copy(result, buf.Bytes())
    return result
}

// ✅ 推荐：原子操作和互斥锁
type Counter struct {
    mu    sync.RWMutex
    count int64
}

func (c *Counter) Increment() {
    c.mu.Lock()
    c.count++
    c.mu.Unlock()
}

func (c *Counter) Get() int64 {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return c.count
}

// 对于简单计数器，使用原子操作更高效
