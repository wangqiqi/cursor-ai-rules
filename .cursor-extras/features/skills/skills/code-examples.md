# 代码示例技能

## 🎯 功能概述

提供丰富的代码示例库和智能示例推荐系统，帮助开发者快速学习和应用最佳实践，通过实际可运行的代码片段加速开发过程，提高代码质量和一致性。

## 🚀 核心能力

### 示例库管理
- **多语言支持**: JavaScript、Python、Java、Go、Rust等主流语言
- **框架示例**: React、Vue、Angular、Django、Spring等框架
- **模式示例**: 设计模式、架构模式、最佳实践
- **场景示例**: 常见开发场景和解决方案

### 智能推荐
- **上下文感知**: 基于当前代码上下文推荐相关示例
- **难度匹配**: 根据开发者水平推荐适当难度的示例
- **项目适配**: 基于项目技术栈推荐相关示例
- **学习路径**: 从基础到高级的渐进式学习示例

### 交互式学习
- **代码运行**: 浏览器内代码执行和结果展示
- **逐步引导**: 分步骤的代码解释和学习指导
- **实时修改**: 示例代码的实时编辑和测试
- **版本对比**: 不同实现方式的对比展示

## 🛠️ 技术实现

### 核心算法
```javascript
// 代码示例推荐引擎
class CodeExampleRecommender {
  async recommendExamples(context) {
    const userProfile = await this.analyzeUserProfile();
    const codeContext = await this.analyzeCodeContext(context);
    const projectContext = await this.analyzeProjectContext();

    // 计算相关性分数
    const examples = await this.searchRelevantExamples(codeContext);
    const scoredExamples = await this.scoreExamples(examples, {
      userProfile,
      codeContext,
      projectContext
    });

    // 按分数排序并返回前N个
    return this.rankAndFilterExamples(scoredExamples);
  }

  async analyzeCodeContext(context) {
    return {
      language: this.detectLanguage(context),
      framework: this.detectFramework(context),
      patterns: this.extractPatterns(context),
      complexity: this.assessComplexity(context),
      domain: this.identifyDomain(context)
    };
  }

  async searchRelevantExamples(query) {
    // 在示例库中搜索相关示例
    const semanticMatches = await this.semanticSearch(query);
    const patternMatches = await this.patternSearch(query);
    const tagMatches = await this.tagSearch(query);

    return this.mergeAndDeduplicate([
      semanticMatches,
      patternMatches,
      tagMatches
    ]);
  }
}
```

### 示例索引和搜索
```javascript
// 示例元数据结构
const exampleMetadata = {
  id: "react_component_best_practices",
  title: "React组件最佳实践",
  description: "展示React组件开发的最佳实践和模式",
  language: "javascript",
  framework: "react",
  tags: ["react", "component", "best-practices", "hooks"],
  difficulty: "intermediate",
  topics: ["组件设计", "状态管理", "性能优化"],
  prerequisites: ["JavaScript基础", "React基础"],
  estimatedTime: "30分钟",
  code: {
    before: "// 不推荐的写法\n// ...",
    after: "// 推荐的写法\n// ...",
    explanation: "为什么这种写法更好..."
  },
  relatedExamples: [
    "react_hooks_patterns",
    "react_performance_tips"
  ]
};

// 智能搜索算法
async function smartSearch(query, context) {
  const queryTerms = tokenize(query);
  const contextTerms = extractContextTerms(context);

  // 语义相似度计算
  const semanticScore = calculateSemanticSimilarity(queryTerms, exampleTags);

  // 上下文相关性计算
  const contextScore = calculateContextRelevance(contextTerms, exampleMetadata);

  // 使用历史计算
  const usageScore = calculateUsageScore(exampleId, userHistory);

  // 综合评分
  const finalScore = semanticScore * 0.4 + contextScore * 0.4 + usageScore * 0.2;

  return finalScore;
}
```

## 📊 性能指标

- **搜索速度**: <500ms的示例推荐响应
- **相关性准确率**: >85%的推荐准确率
- **示例覆盖率**: 1000+ 常用开发场景示例
- **学习路径完备率**: >90%的技术栈学习路径覆盖

## 🔗 集成接口

### Scripts集成
- `example-manager.sh`: 核心示例管理和推荐
- `code-generator.sh`: 基于示例的代码生成
- `learning-path.sh`: 个性化学习路径生成

### Hooks集成
- `example-suggestions.sh`: 代码编写时的示例建议
- `best-practice-check.sh`: 最佳实践检查和建议

### Workflows集成
- **代码生成工作流**: 基于示例的快速代码生成
- **学习引导工作流**: 个性化学习路径和指导
- **代码审查工作流**: 基于最佳实践的代码审查

## 📚 示例分类

### 基础语法示例
```javascript
// 变量声明最佳实践
// ❌ 不推荐
var name = "John";
function getUser() { /* ... */ }

// ✅ 推荐
const name = "John";
const getUser = () => { /* ... */ };
```

```python
# Python列表操作
# 创建列表
fruits = ['apple', 'banana', 'orange']

# 列表推导式
squares = [x**2 for x in range(10)]

# 字典推导式
names = ['Alice', 'Bob', 'Charlie']
name_lengths = {name: len(name) for name in names}
```

### 设计模式示例
```javascript
// 单例模式
class DatabaseConnection {
  constructor() {
    if (DatabaseConnection.instance) {
      return DatabaseConnection.instance;
    }
    // 初始化数据库连接
    this.connection = createConnection();
    DatabaseConnection.instance = this;
  }

  query(sql) {
    return this.connection.query(sql);
  }
}

// 使用单例
const db1 = new DatabaseConnection();
const db2 = new DatabaseConnection();
console.log(db1 === db2); // true
```

```python
# 工厂模式
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def speak(self):
        pass

class Dog(Animal):
    def speak(self):
        return "Woof!"

class Cat(Animal):
    def speak(self):
        return "Meow!"

class AnimalFactory:
    @staticmethod
    def create_animal(animal_type):
        if animal_type == "dog":
            return Dog()
        elif animal_type == "cat":
            return Cat()
        else:
            raise ValueError(f"Unknown animal type: {animal_type}")

# 使用工厂
dog = AnimalFactory.create_animal("dog")
cat = AnimalFactory.create_animal("cat")
```

### 框架特定示例
```javascript
// React Hooks最佳实践
import React, { useState, useEffect, useCallback } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);

  // 使用useCallback避免不必要的重渲染
  const fetchUser = useCallback(async () => {
    setLoading(true);
    try {
      const userData = await fetchUserById(userId);
      setUser(userData);
    } catch (error) {
      console.error('Failed to fetch user:', error);
    } finally {
      setLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

```python
# Django模型和视图
# models.py
from django.db import models

class Article(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    author = models.ForeignKey('Author', on_delete=models.CASCADE)
    published_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

# views.py
from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from .models import Article

def article_list(request):
    articles = Article.objects.all().order_by('-published_date')
    return render(request, 'articles/article_list.html', {
        'articles': articles
    })

def article_detail(request, pk):
    article = get_object_or_404(Article, pk=pk)
    return render(request, 'articles/article_detail.html', {
        'article': article
    })

def article_api(request):
    articles = Article.objects.all().values('title', 'author__name', 'published_date')
    return JsonResponse({'articles': list(articles)})
```

## 📈 学习与适应

### 自适应学习
- **技能水平评估**: 根据代码质量和复杂度评估开发者水平
- **偏好学习**: 学习开发者常用的编程模式和风格
- **进度跟踪**: 记录学习进度和掌握的技能

### 智能推荐
- **难度适配**: 根据当前水平推荐适当难度的示例
- **上下文相关**: 基于当前代码上下文推荐相关示例
- **学习路径**: 提供从基础到高级的系统学习路径

## 🎯 使用场景

### 新手学习
- **语言基础**: 编程语言的基本语法和概念
- **框架入门**: 常用框架的快速上手指南
- **最佳实践**: 行业认可的编码规范和模式

### 开发者日常
- **代码参考**: 常见问题的标准解决方案
- **模式应用**: 设计模式在实际项目中的应用
- **性能优化**: 代码性能优化技巧和示例

### 团队协作
- **代码规范**: 团队统一的编码风格和规范
- **技术分享**: 优秀代码示例的团队分享
- **知识传承**: 核心技术和模式的文档化传承

## 🔧 配置选项

### 基本配置
```json
{
  "code_examples": {
    "enabled": true,
    "default_language": "javascript",
    "show_explanations": true,
    "interactive_mode": true
  }
}
```

### 高级配置
```json
{
  "advanced": {
    "custom_examples": [],
    "learning_paths": {
      "javascript": ["basics", "dom", "async", "frameworks"],
      "python": ["syntax", "oop", "web", "data-science"],
      "java": ["oop", "spring", "microservices"]
    },
    "recommendation_engine": {
      "semantic_search": true,
      "collaborative_filtering": true,
      "context_awareness": true
    },
    "quality_filters": {
      "min_rating": 4.0,
      "verified_only": true,
      "up_to_date": true
    }
  }
}
```

### 集成配置
```json
{
  "integrations": {
    "ide_plugins": ["vscode", "intellij", "sublime"],
    "documentation_sites": ["mdn", "devdocs", "stackoverflow"],
    "code_sharing": ["github_gist", "codepen", "jsfiddle"],
    "learning_platforms": ["codecademy", "freecodecamp", "coursera"]
  }
}
```

## 📚 相关资源

- **学习平台**: freeCodeCamp、Codecademy、MDN
- **代码示例**: GitHub、CodePen、JSFiddle
- **最佳实践**: Airbnb JavaScript指南、Google Python指南

---

**技能版本**: 1.0.0
**示例数量**: 1000+ 代码示例
**支持语言**: 10+ 编程语言
**学习路径**: 50+ 专项学习路径
**依赖**: example-manager.sh