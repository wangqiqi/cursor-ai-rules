# 📖 Cursor AI Rules 详细使用指南

*版本: v4.3.0 | 最后更新: 2026-01-16 | 作者: wangqiqi (https://github.com/wangqiqi)*

> 💡 **快速开始？** 请查看 [快速开始指南](quick-start.md)
>
> 🔧 **基础使用？** 请查看 [基础使用指南](user-guide/basic-usage.md)
>
> ⚙️ **高级配置？** 请查看 [高级配置指南](user-guide/advanced-config.md)

## 🎯 高级使用场景

### 企业级项目协作

#### 多团队协作模式
```bash
# 团队协作初始化
@master 初始化企业级项目

# 代码规范同步
@master 同步团队代码规范

# 质量门禁检查
@master 执行质量门禁
```

#### 合规性管理
- **安全审计**: 自动检查安全漏洞
- **许可证合规**: 依赖许可证验证
- **代码规范**: 团队统一标准执行

### 复杂项目架构

#### 微服务架构
```bash
# 微服务项目分析
@master 分析微服务架构

# 服务间依赖检查
@master 检查服务依赖关系

# 部署配置优化
@master 优化部署配置
```

#### 多语言项目
- **技术栈识别**: 自动检测多种编程语言
- **跨语言规范**: 统一的代码质量标准
- **构建流程**: 集成多种构建工具

## 🏆 最佳实践

### 项目初始化策略

#### 新项目启动
1. **环境评估**: 先运行环境感知分析
2. **技术选型**: 基于项目需求选择合适的技术栈
3. **规范制定**: 建立项目特定的代码规范
4. **工具配置**: 配置必要的开发工具和钩子

#### 现有项目迁移
1. **现状分析**: 全面了解现有项目结构
2. **渐进式迁移**: 分阶段引入新规范
3. **团队培训**: 确保团队成员理解新流程
4. **监控效果**: 跟踪改进效果和团队适应情况

### 团队协作优化

#### 分支管理
```bash
# 功能分支开发
@master 创建功能分支 feature/user-auth

# 代码审查准备
@master 准备代码审查

# 分支合并检查
@master 检查分支合并
```

#### 代码审查流程
- **自动化检查**: 提交前自动运行质量检查
- **人工审查**: 重点关注业务逻辑和架构设计
- **持续改进**: 基于审查反馈优化流程

## 🆘 故障排除指南

### 常见问题解决

#### 初始化失败
```bash
# 检查权限和环境
ls -la .cursor/core/init.sh
./.cursor/core/env-perception.sh

# 重新运行初始化
./.cursor/core/init.sh
```

#### 配置冲突
```bash
# 验证配置一致性
./.cursor/core/core/config/config-manager.sh validate

# 查看配置状态
./.cursor/core/core/config/config-manager.sh status

# 重置配置
./.cursor/core/core/config/config-manager.sh init
```

#### 性能问题
```bash
# 检查缓存状态
./.cursor/core/performance-cache.sh stats

# 清理缓存
./.cursor/core/performance-cache.sh clean

# 重新构建缓存
./.cursor/core/performance-cache.sh rebuild
```

### 诊断工具

#### 环境完整性检查
```bash
# 运行全面诊断
./.cursor/core/env-perception.sh

# 查看系统日志
./.cursor/core/logging.sh show recent

# 检查磁盘空间
df -h
```

#### 网络连接问题
```bash
# 测试网络连接
curl -I https://api.github.com

# 检查代理设置
env | grep -i proxy

# 验证DNS解析
nslookup github.com
```

### 高级调试

#### 启用调试模式
```bash
# 开启详细日志
export CURSOR_DEBUG=true
export CURSOR_LOG_LEVEL=debug

# 重新运行命令
./.cursor/core/init.sh
```

#### 隔离测试
```bash
# 创建测试环境
./.cursor/core/isolation-debugger.sh create-test-env

# 运行隔离测试
./.cursor/core/core/debug/isolation-debugger.sh run-tests
```

## 📚 相关资源

- **[快速开始指南](quick-start.md)**: 基础安装和配置
- **[基础使用指南](user-guide/basic-usage.md)**: 日常使用方法
- **[高级配置指南](user-guide/advanced-config.md)**: 深度定制选项
- **[系统信息指南](system-info-guide.md)**: 环境检测和系统信息
- **[智能进化指南](intelligent-evolution-guide.md)**: AI学习和优化

---

*🚀 Cursor AI Rules v4.3.0 - 详细使用指南 - 解决复杂使用场景和故障排除*
*最后更新: 2026-01-16 | 作者: wangqiqi*