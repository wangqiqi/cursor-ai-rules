---
description: "Go开发规则 - 云原生微服务和系统编程最佳实践"
apply_when:
  - file_pattern: "**/*.go"
  - keywords: ["golang", "go"]
priority: 10
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
