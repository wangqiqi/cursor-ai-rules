---
command: java
description: "Java开发规则 - 企业级Java开发最佳实践"
alwaysApply: false
---

# 📜 Java 开发规则

*版本: v4.3.0 | 最后更新: 2026-01-22 | 作者: Cursor AI Rules*

## 🎯 适用场景

- Spring Boot 微服务开发
- 企业级 Java 应用
- Android 应用开发
- 大数据处理应用

## 🏗️ 架构原则

### 面向对象设计
- **SOLID 原则**: 单一职责、开闭原则、里氏替换、接口隔离、依赖倒置
- **设计模式**: 在适当场景使用 GoF 设计模式
- **组合优于继承**: 优先使用组合而不是继承

### 分层架构
- **表现层**: Controller/REST API
- **业务层**: Service/业务逻辑
- **数据访问层**: Repository/DAO
- **领域层**: Domain Model/业务实体

## 📝 编码规范

### 命名约定
```java
// ✅ 推荐 - 类和接口
public class UserService {
    private UserRepository userRepository;
}

public interface PaymentProcessor {
    void process(PaymentRequest request);
}

// ✅ 推荐 - 方法和变量
public UserProfile getUserProfile(String userId) {
    Optional<User> user = userRepository.findById(userId);
    return user.map(this::convertToProfile).orElse(null);
}

private UserProfile convertToProfile(User user) {
    // 转换逻辑
}

// ❌ 避免
public class userservice {  // 类名应 PascalCase
    private UserRepository userrepository;  // 变量名应 camelCase
}

public UserProfile GetUserProfile(String userid) {  // 方法名应 camelCase
    // ...
}
```

### 包结构组织
```
com.company.project
├── api/           # REST API 接口
├── config/        # 配置类
├── domain/        # 领域模型
│   ├── entity/    # JPA 实体
│   ├── repository/# 数据访问接口
│   └── service/   # 业务服务
├── infrastructure/# 基础设施层
│   ├── persistence/# 数据持久化
│   ├── messaging/ # 消息处理
│   └── external/  # 外部服务集成
├── application/   # 应用服务层
└── common/        # 公共组件
    ├── exception/ # 异常处理
    ├── util/      # 工具类
    └── validation/# 验证器
```

## 🔧 最佳实践

### 异常处理
```java
// ✅ 推荐 - 自定义异常和统一处理
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException ex) {
        return ResponseEntity.badRequest()
                .body(new ErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        log.error("Unexpected error", ex);
        return ResponseEntity.internalServerError()
                .body(new ErrorResponse("Internal server error"));
    }
}

// 自定义业务异常
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
```

### 数据访问层
```java
// ✅ 推荐 - Repository 模式
public interface UserRepository extends JpaRepository<User, Long> {

    // 自定义查询方法
    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.status = :status AND u.createdAt > :since")
    List<User> findActiveUsersSince(@Param("status") UserStatus status,
                                   @Param("since") LocalDateTime since);

    // 复杂查询使用 Criteria API 或 QueryDSL
    @Query("SELECT new com.company.UserSummary(u.id, u.name, u.email) FROM User u")
    List<UserSummary> findUserSummaries();
}
```

### 依赖注入
```java
// ✅ 推荐 - 构造函数注入
@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EventPublisher eventPublisher;

    public UserService(UserRepository userRepository,
                      PasswordEncoder passwordEncoder,
                      EventPublisher eventPublisher) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.eventPublisher = eventPublisher;
    }

    // 业务方法
    public User createUser(CreateUserRequest request) {
        // 验证和创建用户的逻辑
        User user = new User(request.getEmail(), request.getName());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        User savedUser = userRepository.save(user);
        eventPublisher.publish(new UserCreatedEvent(savedUser.getId()));

        return savedUser;
    }
}
```

### 测试实践
```java
// ✅ 推荐 - 单元测试
@SpringBootTest
class UserServiceTest {

    @MockBean
    private UserRepository userRepository;

    @Autowired
    private UserService userService;

    @Test
    void shouldCreateUserSuccessfully() {
        // Given
        CreateUserRequest request = new CreateUserRequest(
            "john@example.com", "John Doe", "password123"
        );

        User savedUser = User.builder()
            .id(1L)
            .email("john@example.com")
            .name("John Doe")
            .build();

        when(userRepository.save(any(User.class))).thenReturn(savedUser);

        // When
        User result = userService.createUser(request);

        // Then
        assertThat(result.getEmail()).isEqualTo("john@example.com");
        assertThat(result.getName()).isEqualTo("John Doe");
        verify(userRepository).save(any(User.class));
    }
}
```

## 🔒 安全编码

### 输入验证
```java
// ✅ 推荐 - Bean Validation
public class CreateUserRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;

    @NotBlank(message = "Password is required")
    @Pattern(regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$",
             message = "Password must contain at least one digit, one lowercase, one uppercase, and be at least 8 characters")
    private String password;
}
```

### SQL 注入防护
```java
// ✅ 推荐 - 使用参数化查询
@Repository
public class UserRepositoryCustomImpl implements UserRepositoryCustom {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public List<User> findUsersByCriteria(String name, String email, UserStatus status) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<User> query = cb.createQuery(User.class);
        Root<User> user = query.from(User.class);

        List<Predicate> predicates = new ArrayList<>();

        if (name != null && !name.trim().isEmpty()) {
            predicates.add(cb.like(user.get("name"), "%" + name + "%"));
        }

        if (email != null && !email.trim().isEmpty()) {
            predicates.add(cb.equal(user.get("email"), email));
        }

        if (status != null) {
            predicates.add(cb.equal(user.get("status"), status));
        }

        query.where(cb.and(predicates.toArray(new Predicate[0])));

        return entityManager.createQuery(query).getResultList();
    }
}
```

## ⚡ 性能优化

### 数据库查询优化
```java
// ✅ 推荐 - N+1 查询问题解决
@Service
public class OrderService {

    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.items WHERE o.customer.id = :customerId")
    List<Order> findOrdersWithItemsByCustomerId(@Param("customerId") Long customerId);

    // 或者使用 EntityGraph
    @EntityGraph(attributePaths = {"items", "customer"})
    List<Order> findAllWithItemsAndCustomer();
}

// ✅ 推荐 - 分页查询优化
public Page<OrderSummary> findOrderSummaries(Pageable pageable) {
    return orderRepository.findOrderSummaries(pageable);
}

// Repository 方法
@Query("SELECT new com.company.OrderSummary(o.id, o.orderNumber, o.total, o.status) FROM Order o")
Page<OrderSummary> findOrderSummaries(Pageable pageable);
```

### 缓存策略
```java
// ✅ 推荐 - Spring Cache 使用
@Service
public class UserService {

    @Cacheable(value = "users", key = "#userId")
    public User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    @CachePut(value = "users", key = "#user.id")
    public User updateUser(User user) {
        User updatedUser = userRepository.save(user);
        return updatedUser;
    }

    @CacheEvict(value = "users", key = "#userId")
    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }
}
```

## 📊 代码质量

### 代码复杂度控制
```java
// ✅ 推荐 - 方法拆分保持简单
public class OrderProcessor {

    // 主方法保持简洁
    public Order processOrder(OrderRequest request) {
        validateRequest(request);
        Order order = createOrder(request);
        processPayment(order);
        sendConfirmation(order);
        return order;
    }

    // 每个方法职责单一
    private void validateRequest(OrderRequest request) {
        // 验证逻辑
    }

    private Order createOrder(OrderRequest request) {
        // 创建订单逻辑
    }

    private void processPayment(Order order) {
        // 支付处理逻辑
    }

    private void sendConfirmation(Order order) {
        // 发送确认邮件逻辑
    }
}
```

### 常量管理
```java
// ✅ 推荐 - 常量类管理
public final class OrderConstants {

    // 订单状态
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PROCESSING = "PROCESSING";
    public static final String STATUS_COMPLETED = "COMPLETED";
    public static final String STATUS_CANCELLED = "CANCELLED";

    // 订单类型
    public static final String TYPE_STANDARD = "STANDARD";
    public static final String TYPE_EXPRESS = "EXPRESS";
    public static final String TYPE_PREMIUM = "PREMIUM";

    // 业务限制
    public static final int MAX_ORDER_ITEMS = 100;
    public static final BigDecimal MAX_ORDER_TOTAL = new BigDecimal("10000.00");

    private OrderConstants() {
        // 防止实例化
    }
}
```

## 🧪 测试策略

### 测试金字塔
```
单元测试 (Unit Tests)     70%
├── 纯函数测试
├── 工具类测试
└── 业务逻辑测试

集成测试 (Integration)    20%
├── API 集成测试
├── 数据库集成测试
└── 外部服务集成测试

端到端测试 (E2E)           10%
├── 用户界面测试
├── 完整业务流程测试
└── 性能测试
```

### 测试覆盖率目标
- **单元测试**: ≥ 80%
- **分支覆盖**: ≥ 75%
- **集成测试**: 关键路径 100%

## 📚 学习资源

### 官方文档
- [OpenJDK Documentation](https://docs.oracle.com/en/java/)
- [Spring Framework](https://spring.io/projects/spring-framework)
- [Maven Documentation](https://maven.apache.org/guides/)

### 推荐书籍
- **《Effective Java》**: Java 编程最佳实践
- **《Clean Code》**: 代码整洁之道
- **《Spring in Action》**: Spring 框架实战
- **《Java Concurrency in Practice》**: Java 并发编程

### 在线资源
- [Baeldung](https://www.baeldung.com/): 优质 Java 教程
- [Spring Guides](https://spring.io/guides): 官方 Spring 指南
- [Java Code Geeks](https://www.javacodegeeks.com/): Java 技术文章

## 🎯 总结

遵循这些 Java 开发规则，您将能够:

✅ **构建可维护的代码**: 清晰的结构和一致的命名
✅ **确保类型安全**: 充分利用 Java 的强类型特性
✅ **提高性能**: 合理的架构设计和优化策略
✅ **保证安全性**: 安全的编码实践和输入验证
✅ **便于测试**: 良好的设计支持全面测试
✅ **持续改进**: 代码质量的持续监控和改进

---
*Java 开发规则 - Cursor AI Rules*
*构建企业级 Java 应用的黄金标准*