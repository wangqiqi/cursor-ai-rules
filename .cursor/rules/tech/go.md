---
command: go
description: "Go开发规则 - 云原生微服务和系统编程最佳实践"
alwaysApply: false
---

# 🚀 Go 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- 云原生微服务开发
- 网络服务和API服务
- 分布式系统和容器化应用
- 系统工具和命令行程序
- 高并发服务器应用
- DevOps工具和基础设施代码

## 🏗️ 项目结构

### Go Modules 项目布局
```
go_project/
├── go.mod                    # Go模块定义
├── go.sum                    # 依赖校验文件
├── main.go                   # 程序入口
├── cmd/                      # 主程序
│   └── server/
│       └── main.go
├── internal/                 # 私有代码
│   ├── config/              # 配置管理
│   │   ├── config.go
│   │   └── config_test.go
│   ├── models/              # 数据模型
│   │   ├── user.go
│   │   └── product.go
│   ├── handlers/            # HTTP处理器
│   │   ├── user_handler.go
│   │   └── product_handler.go
│   ├── services/            # 业务逻辑
│   │   ├── user_service.go
│   │   └── product_service.go
│   └── repository/          # 数据访问层
│       ├── user_repo.go
│       └── product_repo.go
├── pkg/                      # 可公开使用的包
│   ├── middleware/
│   └── utils/
├── api/                      # API定义 (protobuf, swagger等)
├── web/                      # Web资源
│   ├── static/
│   └── templates/
├── config/                   # 配置文件
├── scripts/                  # 构建和部署脚本
├── docker/                   # Docker相关
├── docs/                     # 文档
├── Makefile                  # 构建脚本
├── Dockerfile               # Docker镜像定义
└── README.md
```

### 包结构设计原则
```
module github.com/yourname/project

// 清晰的分层架构
├── main.go (程序入口)
├── cmd/ (具体应用)
├── internal/ (私有包)
│   ├── app/ (应用层)
│   ├── domain/ (领域层)
│   └── infrastructure/ (基础设施层)
└── pkg/ (公共包)
    ├── api/ (API定义)
    └── shared/ (共享工具)
```

## 📝 编码规范

### Effective Go 实践
```go
package main

import (
    "context"
    "database/sql"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "time"
)

// ✅ 推荐：清晰的包命名和导入分组
import (
    "context"
    "net/http"

    "github.com/gorilla/mux"
    "github.com/yourname/project/internal/models"
)

// ✅ 推荐：使用结构体标签和JSON序列化
type User struct {
    ID        int64     `json:"id" db:"id"`
    Username  string    `json:"username" db:"username" validate:"required,min=3,max=50"`
    Email     string    `json:"email" db:"email" validate:"required,email"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
    UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// ✅ 推荐：构造函数模式
func NewUser(username, email string) (*User, error) {
    if username == "" || email == "" {
        return nil, fmt.Errorf("username and email are required")
    }

    return &User{
        Username:  username,
        Email:     email,
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }, nil
}

// ✅ 推荐：接口定义和依赖注入
type UserRepository interface {
    Create(ctx context.Context, user *User) error
    GetByID(ctx context.Context, id int64) (*User, error)
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id int64) error
}

type UserService struct {
    repo UserRepository
    // 其他依赖...
}

// 构造函数注入依赖
func NewUserService(repo UserRepository) *UserService {
    return &UserService{
        repo: repo,
    }
}

// ✅ 推荐：错误处理模式
func (s *UserService) CreateUser(ctx context.Context, username, email string) (*User, error) {
    user, err := NewUser(username, email)
    if err != nil {
        return nil, fmt.Errorf("failed to create user: %w", err)
    }

    if err := s.repo.Create(ctx, user); err != nil {
        return nil, fmt.Errorf("failed to save user: %w", err)
    }

    return user, nil
}

// ✅ 推荐：Context 传递和超时控制
func (s *UserService) ProcessUserBatch(ctx context.Context, userIDs []int64) error {
    // 创建带超时的上下文
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()

    // 使用goroutine处理批量操作
    semaphore := make(chan struct{}, 10) // 限制并发数
    errChan := make(chan error, len(userIDs))

    for _, userID := range userIDs {
        go func(id int64) {
            semaphore <- struct{}{} // 获取信号量
            defer func() { <-semaphore }() // 释放信号量

            if err := s.processSingleUser(ctx, id); err != nil {
                errChan <- err
                return
            }
            errChan <- nil
        }(userID)
    }

    // 收集结果
    for i := 0; i < len(userIDs); i++ {
        if err := <-errChan; err != nil {
            return err
        }
    }

    return nil
}

func (s *UserService) processSingleUser(ctx context.Context, userID int64) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    default:
        // 处理单个用户
        return nil
    }
}
```

### 命名约定
```go
// 包名：小写，简短，有意义
package user
package httputil
package config

// 文件名：snake_case
user_service.go
http_client.go
database_config.go

// 类型名：PascalCase
type User struct {}
type UserService struct {}
type HTTPClient struct {}

// 方法名：PascalCase
func (u *User) GetName() string
func (s *UserService) CreateUser(user *User) error

// 变量名：camelCase
var userCount int
var httpClient *http.Client
var databaseURL string

// 常量：PascalCase 或 全大写
const MaxRetries = 3
const DefaultTimeout = 30 * time.Second

// 私有字段：小写开头
type user struct {
    id       int64
    name     string
    email    string
    password string // 私有字段
}

// 接口：以 er 结尾
type Repository interface {}
type Service interface {}
type Handler interface {}
```

## 🛠️ 依赖管理

### Go Modules (推荐)
```go
// go.mod
module github.com/yourname/project

go 1.21

require (
    github.com/gorilla/mux v1.8.0
    github.com/lib/pq v1.10.9
    gorm.io/gorm v1.25.5
    github.com/golang-jwt/jwt/v5 v5.2.0
)

require (
    github.com/jinzhu/inflection v1.0.0 // indirect
    github.com/jinzhu/now v1.1.5 // indirect
    gorm.io/driver/postgres v1.5.4 // indirect
)
```

### 依赖版本管理
```bash
# 初始化模块
go mod init github.com/yourname/project

# 添加依赖
go get github.com/gorilla/mux@latest
go get gorm.io/gorm@v1.25.5

# 更新依赖
go get -u ./...

# 清理未使用的依赖
go mod tidy

# 下载依赖
go mod download

# 验证依赖
go mod verify
```

### Vendor 模式 (可选)
```bash
# 创建vendor目录
go mod vendor

# 使用vendor构建
go build -mod=vendor

# 清理vendor
rm -rf vendor/
```

## 🧪 测试策略

### 内置测试框架
```go
package user_test

import (
    "context"
    "database/sql"
    "testing"
    "time"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"

    "github.com/yourname/project/internal/models"
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
type AtomicCounter struct {
    count int64
}

func (c *AtomicCounter) Increment() {
    atomic.AddInt64(&c.count, 1)
}

func (c *AtomicCounter) Get() int64 {
    return atomic.LoadInt64(&c.count)
}

// ✅ 推荐：Worker Pool 模式
type WorkerPool struct {
    workers   int
    taskChan  chan func()
    quitChan  chan struct{}
    wg        sync.WaitGroup
}

func NewWorkerPool(workers int) *WorkerPool {
    wp := &WorkerPool{
        workers:  workers,
        taskChan: make(chan func(), workers*2),
        quitChan: make(chan struct{}),
    }

    wp.start()
    return wp
}

func (wp *WorkerPool) start() {
    for i := 0; i < wp.workers; i++ {
        wp.wg.Add(1)
        go func() {
            defer wp.wg.Done()
            for {
                select {
                case task := <-wp.taskChan:
                    task()
                case <-wp.quitChan:
                    return
                }
            }
        }()
    }
}

func (wp *WorkerPool) Submit(task func()) {
    select {
    case wp.taskChan <- task:
    case <-wp.quitChan:
        return
    }
}

func (wp *WorkerPool) Stop() {
    close(wp.quitChan)
    wp.wg.Wait()
}
```

## 🔒 安全实践

### 输入验证和清理
```go
import (
    "html"
    "net/url"
    "regexp"
    "strings"
    "unicode/utf8"
)

// ✅ 推荐：输入验证和清理
type UserInputValidator struct {
    usernameRegex *regexp.Regexp
    emailRegex    *regexp.Regexp
}

func NewUserInputValidator() *UserInputValidator {
    return &UserInputValidator{
        usernameRegex: regexp.MustCompile(`^[a-zA-Z0-9_]{3,50}$`),
        emailRegex:    regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`),
    }
}

func (v *UserInputValidator) ValidateUsername(username string) error {
    if username == "" {
        return errors.New("username is required")
    }

    if utf8.RuneCountInString(username) > 50 {
        return errors.New("username too long")
    }

    if !v.usernameRegex.MatchString(username) {
        return errors.New("username contains invalid characters")
    }

    return nil
}

func (v *UserInputValidator) ValidateEmail(email string) error {
    if email == "" {
        return errors.New("email is required")
    }

    if len(email) > 254 {
        return errors.New("email too long")
    }

    email = strings.TrimSpace(strings.ToLower(email))

    if !v.emailRegex.MatchString(email) {
        return errors.New("invalid email format")
    }

    return nil
}

func (v *UserInputValidator) SanitizeInput(input string) string {
    // HTML转义
    input = html.EscapeString(input)

    // URL编码处理
    if strings.Contains(input, "%") {
        if decoded, err := url.QueryUnescape(input); err == nil {
            input = decoded
        }
    }

    // 移除控制字符
    input = strings.Map(func(r rune) rune {
        if r < 32 || r == 127 {
            return -1
        }
        return r
    }, input)

    return strings.TrimSpace(input)
}

// ✅ 推荐：SQL注入防护
func (r *UserRepository) GetUserByIDSafe(ctx context.Context, id int64) (*User, error) {
    // 使用参数化查询自动防止SQL注入
    query := `SELECT id, username, email, created_at FROM users WHERE id = $1`

    var user User
    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &user.ID, &user.Username, &user.Email, &user.CreatedAt,
    )

    if err == sql.ErrNoRows {
        return nil, ErrUserNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("failed to get user: %w", err)
    }

    return &user, nil
}
```

### 密码安全处理
```go
import (
    "crypto/rand"
    "crypto/subtle"
    "golang.org/x/crypto/argon2"
    "golang.org/x/crypto/bcrypt"
)

// ✅ 推荐：安全的密码哈希
type PasswordHasher struct {
    time    uint32
    memory  uint32
    threads uint8
    keyLen  uint32
}

func NewPasswordHasher() *PasswordHasher {
    return &PasswordHasher{
        time:    1,
        memory:  64 * 1024, // 64MB
        threads: 4,
        keyLen:  32,
    }
}

func (h *PasswordHasher) HashPassword(password string) ([]byte, error) {
    // 生成盐值
    salt := make([]byte, 32)
    if _, err := rand.Read(salt); err != nil {
        return nil, err
    }

    // 使用Argon2id哈希
    hash := argon2.IDKey([]byte(password), salt, h.time, h.memory, h.threads, h.keyLen)

    // 组合盐值和哈希
    result := make([]byte, len(salt)+len(hash))
    copy(result, salt)
    copy(result[len(salt):], hash)

    return result, nil
}

func (h *PasswordHasher) VerifyPassword(password string, hash []byte) bool {
    if len(hash) < 32 {
        return false
    }

    salt := hash[:32]
    storedHash := hash[32:]

    // 重新计算哈希
    computedHash := argon2.IDKey([]byte(password), salt, h.time, h.memory, h.threads, h.keyLen)

    // 恒定时间比较防止时序攻击
    return subtle.ConstantTimeCompare(storedHash, computedHash) == 1
}

// ✅ 推荐：JWT token 处理
import (
    "github.com/golang-jwt/jwt/v5"
)

type JWTManager struct {
    secretKey []byte
}

func NewJWTManager(secret string) *JWTManager {
    return &JWTManager{
        secretKey: []byte(secret),
    }
}

type Claims struct {
    UserID   int64  `json:"user_id"`
    Username string `json:"username"`
    jwt.RegisteredClaims
}

func (j *JWTManager) GenerateToken(userID int64, username string) (string, error) {
    claims := Claims{
        UserID:   userID,
        Username: username,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
            NotBefore: jwt.NewNumericDate(time.Now()),
            Issuer:    "your-app",
        },
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(j.secretKey)
}

func (j *JWTManager) ValidateToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
        }
        return j.secretKey, nil
    })

    if err != nil {
        return nil, err
    }

    if claims, ok := token.Claims.(*Claims); ok && token.Valid {
        return claims, nil
    }

    return nil, errors.New("invalid token")
}
```

## 📊 最佳实践

### 错误处理模式
```go
// ✅ 推荐：自定义错误类型
type Error struct {
    Code    string `json:"code"`
    Message string `json:"message"`
    Details string `json:"details,omitempty"`
}

func (e *Error) Error() string {
    return fmt.Sprintf("[%s] %s", e.Code, e.Message)
}

func NewError(code, message string) *Error {
    return &Error{
        Code:    code,
        Message: message,
    }
}

// 预定义错误
var (
    ErrNotFound     = NewError("NOT_FOUND", "resource not found")
    ErrUnauthorized = NewError("UNAUTHORIZED", "unauthorized access")
    ErrValidation   = NewError("VALIDATION_ERROR", "validation failed")
)

// ✅ 推荐：错误包装和链式调用
func (r *UserRepository) GetUserByID(ctx context.Context, id int64) (*User, error) {
    if id <= 0 {
        return nil, fmt.Errorf("%w: invalid user ID %d", ErrValidation, id)
    }

    var user User
    query := `SELECT id, username, email FROM users WHERE id = $1`

    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &user.ID, &user.Username, &user.Email,
    )

    if err == sql.ErrNoRows {
        return nil, fmt.Errorf("%w: user %d not found", ErrNotFound, id)
    }

    if err != nil {
        return nil, fmt.Errorf("database error: %w", err)
    }

    return &user, nil
}

// ✅ 推荐：错误恢复和日志记录
func handleRequest(w http.ResponseWriter, r *http.Request) {
    defer func() {
        if err := recover(); err != nil {
            log.Printf("Panic recovered: %v", err)
            http.Error(w, "Internal Server Error", http.StatusInternalServerError)
        }
    }()

    user, err := processUserRequest(r)
    if err != nil {
        handleError(w, err)
        return
    }

    respondJSON(w, user)
}

func handleError(w http.ResponseWriter, err error) {
    var appErr *Error

    switch {
    case errors.Is(err, ErrNotFound):
        http.Error(w, "Not Found", http.StatusNotFound)
    case errors.Is(err, ErrUnauthorized):
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
    case errors.As(err, &appErr):
        w.WriteHeader(http.StatusBadRequest)
        json.NewEncoder(w).Encode(appErr)
    default:
        log.Printf("Unexpected error: %v", err)
        http.Error(w, "Internal Server Error", http.StatusInternalServerError)
    }
}
```

### 日志记录
```go
import (
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

// ✅ 推荐：结构化日志记录
type Logger struct {
    *zap.Logger
}

func NewLogger(level string) *Logger {
    config := zap.NewProductionConfig()

    // 设置日志级别
    switch level {
    case "debug":
        config.Level = zap.NewAtomicLevelAt(zapcore.DebugLevel)
    case "info":
        config.Level = zap.NewAtomicLevelAt(zapcore.InfoLevel)
    case "warn":
        config.Level = zap.NewAtomicLevelAt(zapcore.WarnLevel)
    case "error":
        config.Level = zap.NewAtomicLevelAt(zapcore.ErrorLevel)
    default:
        config.Level = zap.NewAtomicLevelAt(zapcore.InfoLevel)
    }

    logger, err := config.Build()
    if err != nil {
        panic(err)
    }

    return &Logger{logger}
}

func (l *Logger) LogUserAction(userID int64, action string, metadata map[string]interface{}) {
    l.Info("user action",
        zap.Int64("user_id", userID),
        zap.String("action", action),
        zap.Any("metadata", metadata),
        zap.Time("timestamp", time.Now()),
    )
}

func (l *Logger) LogError(err error, context map[string]interface{}) {
    l.Error("operation failed",
        zap.Error(err),
        zap.Any("context", context),
        zap.Stack("stacktrace"),
    )
}

// ✅ 推荐：Context 感知日志记录
type ContextLogger struct {
    *Logger
}

func (cl *ContextLogger) WithContext(ctx context.Context) *zap.Logger {
    logger := cl.Logger

    // 从context中提取请求ID等信息
    if requestID, ok := ctx.Value("request_id").(string); ok {
        logger = logger.With(zap.String("request_id", requestID))
    }

    if userID, ok := ctx.Value("user_id").(int64); ok {
        logger = logger.With(zap.Int64("user_id", userID))
    }

    return logger
}
```

### API设计
```go
// ✅ 推荐：RESTful API 设计
type UserHandler struct {
    service *UserService
    logger  *Logger
}

func NewUserHandler(service *UserService, logger *Logger) *UserHandler {
    return &UserHandler{
        service: service,
        logger:  logger,
    }
}

// GET /users
func (h *UserHandler) ListUsers(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()

    // 解析查询参数
    page := getIntParam(r, "page", 1)
    limit := getIntParam(r, "limit", 10)

    users, total, err := h.service.ListUsers(ctx, page, limit)
    if err != nil {
        h.logger.WithContext(ctx).Error("failed to list users", zap.Error(err))
        respondError(w, http.StatusInternalServerError, "failed to list users")
        return
    }

    response := map[string]interface{}{
        "users": users,
        "pagination": map[string]interface{}{
            "page":  page,
            "limit": limit,
            "total": total,
        },
    }

    respondJSON(w, http.StatusOK, response)
}

// POST /users
func (h *UserHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()

    var req CreateUserRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        h.logger.WithContext(ctx).Warn("invalid request body", zap.Error(err))
        respondError(w, http.StatusBadRequest, "invalid request body")
        return
    }

    if err := validateCreateUserRequest(&req); err != nil {
        h.logger.WithContext(ctx).Warn("validation failed", zap.Error(err))
        respondError(w, http.StatusBadRequest, err.Error())
        return
    }

    user, err := h.service.CreateUser(ctx, req.Username, req.Email)
    if err != nil {
        h.logger.WithContext(ctx).Error("failed to create user", zap.Error(err))
        respondError(w, http.StatusInternalServerError, "failed to create user")
        return
    }

    h.logger.WithContext(ctx).Info("user created",
        zap.Int64("user_id", user.ID),
        zap.String("username", user.Username),
    )

    respondJSON(w, http.StatusCreated, user)
}

// 辅助函数
func respondJSON(w http.ResponseWriter, status int, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}

func respondError(w http.ResponseWriter, status int, message string) {
    respondJSON(w, status, map[string]string{"error": message})
}

func getIntParam(r *http.Request, key string, defaultValue int) int {
    if values := r.URL.Query()[key]; len(values) > 0 {
        if v, err := strconv.Atoi(values[0]); err == nil {
            return v
        }
    }
    return defaultValue
}
```

## 🔄 现代化升级

### Go版本演进
- **Go 1.18+**: 泛型支持
- **Go 1.19+**: 更好的错误处理和性能优化
- **Go 1.20+**: 更好的内存管理
- **Go 1.21+**: 最新的稳定版本

### 框架选择
- **Web框架**: Gin, Echo, Fiber (高性能)
- **ORM**: GORM, sqlx, database/sql
- **配置**: Viper, envconfig
- **日志**: zap, logrus
- **测试**: testify, ginkgo

### 部署和容器化
- **Docker**: 官方Go镜像
- **Kubernetes**: Go应用容器化部署
- **CI/CD**: GitHub Actions, GitLab CI

---

*此规则适用于现代Go开发项目。遵循Effective Go最佳实践，注重并发安全和高性能。*