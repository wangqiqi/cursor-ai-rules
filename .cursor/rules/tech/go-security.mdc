---
description: "Go安全实践和最佳实践 - 安全编码和生产环境指南 (go, 安全, 最佳实践, security)"
globs: ["**/*.go"]
alwaysApply: false
priority: 9
---

# 🔒 Go 安全实践和最佳实践

## ⚠️ 执行原则

**MUST** 遵循以下Go安全开发准则：
- **MUST** 验证所有输入数据
- **NEVER** 在代码中硬编码密钥和凭据
- **ALWAYS** 使用HTTPS和安全通信
- **DO NOT** 忽略依赖的安全漏洞
- **MUST** 实施适当的认证和授权
- **ALWAYS** 记录安全相关事件

### JWT 认证实现
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

