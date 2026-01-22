---
command: skill:frontend-design
description: "🎯 Skills扩展: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics."
alwaysApply: false
---

# 🎯 Skills扩展: frontend-design

Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.

## 🔧 使用方法

```bash
@master skill:frontend-design [参数]
```

## 📚 原始文档

description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt

## 📖 详细技术指南

### 何时使用
- 当用户要求构建Web组件、页面或应用程序时
- 用于创建网站、落地页、仪表板或React组件
- 当需要样式化或美化Web UI元素时
- 对于需要独特、高质量设计的HTML/CSS布局
- 当避免通用或重复的AI生成美学时

### 设计原则
1. **独特美学**: 创建独特、令人难忘的设计，避免通用模板
2. **生产质量**: 确保所有代码都是生产就绪的，具有正确的结构和性能
3. **创意方法**: 将功能与艺术设计元素相结合
4. **现代标准**: 使用当前的Web开发最佳实践和技术

### 实现指南

#### 组件创建
- 使用带有适当可访问性属性的语义HTML
- 实现响应式设计，支持移动端和桌面端
- 应用现代CSS技术（Grid、Flexbox、CSS变量）
- 确保跨浏览器兼容性

#### 样式和主题
- 创建独特的设计系统和配色方案
- 使用现代排版层次结构
- 实现流畅的动画和过渡效果
- 应用微妙的阴影和深度效果

#### 用户体验优化
- 实现直观的导航和交互模式
- 添加适当的加载状态和反馈
- 确保可访问性和可用性标准
- 优化性能和响应时间

### 代码示例

#### React组件设计
```jsx
import React from 'react';
import styled from 'styled-components';

const Card = styled.div`
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
  transition: transform 0.3s ease;

  &:hover {
    transform: translateY(-5px);
  }
`;

const Title = styled.h2`
  color: white;
  font-family: 'Inter', sans-serif;
  font-weight: 600;
  margin-bottom: 1rem;
`;

const Button = styled.button`
  background: rgba(255,255,255,0.2);
  border: 2px solid white;
  color: white;
  padding: 0.75rem 2rem;
  border-radius: 50px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: white;
    color: #667eea;
  }
`;

const FeatureCard = ({ title, description, icon }) => (
  <Card>
    <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>{icon}</div>
    <Title>{title}</Title>
    <p style={{ color: 'rgba(255,255,255,0.9)', marginBottom: '1.5rem' }}>
      {description}
    </p>
    <Button>了解更多</Button>
  </Card>
);

export default FeatureCard;
```

#### CSS设计系统
```css
:root {
  /* 颜色系统 */
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --secondary-color: #764ba2;
  --accent-color: #f093fb;

  /* 排版 */
  --font-primary: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-heading: 'Poppins', sans-serif;

  /* 间距 */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;
  --spacing-xl: 4rem;

  /* 圆角 */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 16px;
  --radius-xl: 32px;

  /* 阴影 */
  --shadow-sm: 0 2px 8px rgba(0,0,0,0.1);
  --shadow-md: 0 8px 32px rgba(0,0,0,0.15);
  --shadow-lg: 0 20px 40px rgba(0,0,0,0.2);
}

.design-system-demo {
  background: var(--primary-gradient);
  border-radius: var(--radius-lg);
  padding: var(--spacing-xl);
  box-shadow: var(--shadow-lg);
  font-family: var(--font-primary);
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing-lg);
  margin: var(--spacing-xl) 0;
}

.interactive-element {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
}

.interactive-element:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}
```

### 最佳实践

#### 设计一致性
- 建立统一的设计语言和组件库
- 维护一致的颜色、字体和间距系统
- 创建可重用的设计模式和模板

#### 性能优化
- 使用CSS优化和最小化重排重绘
- 实现懒加载和代码分割
- 优化图片和资源加载

#### 可访问性
- 使用语义HTML和ARIA属性
- 确保足够的颜色对比度
- 支持键盘导航和屏幕阅读器

### 常见用例

#### 落地页设计
- 英雄区域（Hero Section）
- 功能展示区域
- 客户评价部分
- 行动召唤（CTA）按钮

#### 仪表板界面
- 数据可视化组件
- 导航菜单和侧边栏
- 响应式卡片布局
- 交互式图表和图表

#### 电子商务界面
- 产品展示网格
- 购物车和结账流程
- 用户账户管理
- 搜索和过滤功能

---
*来源: Anthropic Skills库 | 集成时间: 2026-01-15*
