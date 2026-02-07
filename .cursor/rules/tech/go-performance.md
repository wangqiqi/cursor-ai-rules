---
description: "Go性能优化 - 并发、内存和CPU优化技巧"
apply_when:
  - keywords: ["go", "性能", "优化", "performance", "并发"]
priority: 9
---

# 🚀 Go 性能优化

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
