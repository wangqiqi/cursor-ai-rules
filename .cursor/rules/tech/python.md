---
description: "Python开发规则 - Python最佳实践和项目结构"
apply_when:
  - file_pattern: "**/*.py"
  - keywords: ["python", "pip", "django", "flask", "fastapi"]
priority: 10
---

# 🐍 Python 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-15 | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 适用场景

- Django/Flask/FastAPI Web 应用开发
- 数据科学和机器学习项目
- 自动化脚本和工具开发
- API 服务和微服务架构

## 🏗️ 项目结构

### 推荐的项目布局
```
my_project/
├── src/                    # 源代码目录
│   ├── __init__.py
│   ├── main.py            # 应用入口
│   └── my_module/         # 功能模块
│       ├── __init__.py
│       ├── models.py      # 数据模型
│       ├── views.py       # 视图/控制器
│       ├── services.py    # 业务逻辑
│       └── utils.py       # 工具函数
├── tests/                 # 测试目录
│   ├── __init__.py
│   ├── test_models.py
│   └── test_services.py
├── docs/                  # 文档
├── requirements.txt       # 依赖管理
├── pyproject.toml         # 项目配置 (现代)
├── setup.py              # 包安装配置
├── .env                  # 环境变量
├── .gitignore
└── README.md
```

## 📝 编码规范

### PEP 8 合规
- **行长度**: 最多79个字符（Docstring 72个字符）
- **缩进**: 4个空格，无Tab
- **命名**: snake_case for 函数和变量，CamelCase for 类

```python
# ✅ 推荐的命名和结构
class UserService:
    """用户服务类，处理用户相关的业务逻辑。"""

    def __init__(self, db_connection):
        self.db = db_connection
        self._cache = {}

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """根据用户ID获取用户信息。

        Args:
            user_id: 用户的唯一标识符

        Returns:
            用户对象，如果不存在则返回None

        Raises:
            ValueError: 当user_id无效时
        """
        if not isinstance(user_id, int) or user_id <= 0:
            raise ValueError("用户ID必须是正整数")

        # 检查缓存
        if user_id in self._cache:
            return self._cache[user_id]

        # 查询数据库
        user = self.db.query("SELECT * FROM users WHERE id = ?", user_id)

        # 更新缓存
        if user:
            self._cache[user_id] = user

        return user
```

### 类型注解 (Python 3.5+)
```python
from typing import List, Dict, Optional, Union
from dataclasses import dataclass

@dataclass
class User:
    id: int
    name: str
    email: str
    is_active: bool = True

def process_users(users: List[User]) -> Dict[str, int]:
    """处理用户列表，返回统计信息。"""
    stats = {"total": 0, "active": 0}

    for user in users:
        stats["total"] += 1
        if user.is_active:
            stats["active"] += 1

    return stats
```

## 🛠️ 依赖管理

### requirements.txt
```
# Web框架
fastapi==0.104.1
uvicorn==0.24.0

# 数据处理
pandas==2.1.3
numpy==1.26.1

# 数据库
sqlalchemy==2.0.23
alembic==1.12.1

# 测试
pytest==7.4.3
pytest-cov==4.1.0

# 工具
requests==2.31.0
python-dotenv==1.0.0
```

### pyproject.toml (现代方式)
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-project"
version = "0.1.0"
description = "项目描述"
readme = "README.md"
requires-python = ">=3.8"
dependencies = [
    "fastapi>=0.104.0",
    "uvicorn>=0.24.0",
    "sqlalchemy>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
]
```

## 🧪 测试策略

### 单元测试
```python
import pytest
from unittest.mock import Mock, patch
from my_module.services import UserService

class TestUserService:
    @pytest.fixture
    def service(self):
        db_mock = Mock()
        return UserService(db_mock)

    def test_get_user_by_id_success(self, service):
        """测试成功获取用户信息。"""
        # 准备
        expected_user = {"id": 1, "name": "John"}
        service.db.query.return_value = expected_user

        # 执行
        result = service.get_user_by_id(1)

        # 断言
        assert result == expected_user
        service.db.query.assert_called_once()

    def test_get_user_by_id_not_found(self, service):
        """测试用户不存在的情况。"""
        service.db.query.return_value = None

        result = service.get_user_by_id(999)

        assert result is None

    def test_get_user_by_id_invalid_id(self, service):
        """测试无效用户ID。"""
        with pytest.raises(ValueError, match="用户ID必须是正整数"):
            service.get_user_by_id(0)
```

### 测试组织
- **测试文件**: `test_*.py` 或 `*_test.py`
- **测试类**: `Test*`
- **测试方法**: `test_*`
- **夹具**: 使用 `@pytest.fixture`

## 🚀 性能优化

### 内存管理
```python
# ✅ 高效的数据处理
def process_large_dataset(data: List[Dict]) -> List[Dict]:
    """处理大数据集，使用生成器避免内存溢出。"""
    return (
        {**item, "processed": True}
        for item in data
        if item.get("status") == "active"
    )

# 使用上下文管理器管理资源
class DatabaseConnection:
    def __enter__(self):
        self.connection = create_connection()
        return self.connection

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.connection.close()

with DatabaseConnection() as conn:
    # 使用数据库连接
    pass
```

### 异步编程
```python
import asyncio
import aiohttp

async def fetch_user_data(session: aiohttp.ClientSession, user_id: int) -> Dict:
    """异步获取用户数据。"""
    async with session.get(f"https://api.example.com/users/{user_id}") as response:
        return await response.json()

async def process_users_batch(user_ids: List[int]) -> List[Dict]:
    """批量处理用户数据。"""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_user_data(session, uid) for uid in user_ids]
        return await asyncio.gather(*tasks)
```

## 🔒 安全实践

### 输入验证
```python
from pydantic import BaseModel, validator
from typing import Optional

class UserCreate(BaseModel):
    name: str
    email: str
    age: Optional[int] = None

    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('姓名不能为空')
        return v.strip()

    @validator('email')
    def email_must_be_valid(cls, v):
        if '@' not in v:
            raise ValueError('邮箱格式不正确')
        return v.lower()

    @validator('age')
    def age_must_be_positive(cls, v):
        if v is not None and v <= 0:
            raise ValueError('年龄必须大于0')
        return v
```

### 密码处理
```python
import bcrypt
import secrets
from cryptography.fernet import Fernet

class SecurityService:
    @staticmethod
    def hash_password(password: str) -> str:
        """安全的密码哈希。"""
        salt = bcrypt.gensalt(rounds=12)
        return bcrypt.hashpw(password.encode(), salt).decode()

    @staticmethod
    def verify_password(password: str, hashed: str) -> bool:
        """验证密码。"""
        return bcrypt.checkpw(password.encode(), hashed.encode())

    @staticmethod
    def generate_token() -> str:
        """生成安全的随机令牌。"""
        return secrets.token_urlsafe(32)

    def encrypt_data(self, data: str) -> str:
        """加密敏感数据。"""
        f = Fernet(self.encryption_key)
        return f.encrypt(data.encode()).decode()

    def decrypt_data(self, encrypted_data: str) -> str:
        """解密数据。"""
        f = Fernet(self.encryption_key)
        return f.decrypt(encrypted_data.encode()).decode()
```

## 📊 最佳实践

### 设计模式
- **工厂模式**: 对象创建的封装
- **策略模式**: 算法的动态选择
- **装饰器模式**: 功能的动态扩展

### 错误处理
```python
class ApplicationError(Exception):
    """应用基础异常类。"""
    pass

class ValidationError(ApplicationError):
    """数据验证错误。"""
    pass

class DatabaseError(ApplicationError):
    """数据库操作错误。"""
    pass

def handle_database_operation():
    """数据库操作的错误处理。"""
    try:
        # 数据库操作
        result = db.execute("SELECT * FROM users")
        return result
    except DatabaseError as e:
        logger.error(f"数据库错误: {e}")
        raise
    except Exception as e:
        logger.error(f"未知错误: {e}")
        raise DatabaseError("数据库操作失败") from e
```

### 日志记录
```python
import logging
import sys

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('app.log')
    ]
)

logger = logging.getLogger(__name__)

class UserService:
    def __init__(self):
        self.logger = logging.getLogger(f"{__name__}.{self.__class__.__name__}")

    def create_user(self, user_data: Dict) -> User:
        self.logger.info(f"创建用户: {user_data.get('email', 'unknown')}")
        try:
            # 创建用户逻辑
            user = User(**user_data)
            self.logger.info(f"用户创建成功: {user.id}")
            return user
        except Exception as e:
            self.logger.error(f"用户创建失败: {e}")
            raise
```

## 🔄 现代化升级

### Python 版本升级
- **目标版本**: Python 3.8+ (支持现代语法特性)
- **类型注解**: 使用 `typing` 模块和数据类
- **异步编程**: 采用 `asyncio` 和 `async/await`

### 框架选择
- **Web框架**: FastAPI (现代、快速) > Flask > Django
- **API 开发**: FastAPI with Pydantic
- **数据处理**: pandas + numpy
- **机器学习**: scikit-learn + TensorFlow/PyTorch

---

*此规则适用于现代Python开发项目。遵循PEP 8和Python最佳实践。*