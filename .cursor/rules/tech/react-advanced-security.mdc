---
description: "React 安全实践 - 输入验证、DOMPurify、XSS 防护"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 9
---

# React 安全实践 (Security)

> 本规则由 `@react-advanced` 引用

## 输入验证

```jsx
function useFormValidation(initialValues, validationRules) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState({})

  const validateField = (name, value) => {
    const rules = validationRules[name]
    if (!rules) return null
    for (const rule of rules) {
      const error = rule(value)
      if (error) return error
    }
    return null
  }

  const handleChange = (name, value) => {
    setValues(prev => ({ ...prev, [name]: value }))
    setErrors(prev => ({ ...prev, [name]: validateField(name, value) }))
  }

  return { values, errors, handleChange, isValid: Object.values(errors).every(e => !e) }
}
```

## 安全 HTML 渲染 (DOMPurify)

```jsx
import DOMPurify from 'dompurify'

function SafeHtml({ html, className }) {
  const sanitizedHtml = useMemo(() =>
    DOMPurify.sanitize(html, {
      ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
      ALLOWED_ATTR: ['href', 'target', 'rel']
    }),
    [html]
  )
  return <div className={className} dangerouslySetInnerHTML={{ __html: sanitizedHtml }} />
}
```

## 验证规则示例

```jsx
const validationRules = {
  name: [
    (v) => !v ? '姓名不能为空' : null,
    (v) => v.length < 2 ? '姓名至少2个字符' : null,
    (v) => /[<>&"']/.test(v) ? '姓名包含无效字符' : null
  ],
  email: [
    (v) => !v ? '邮箱不能为空' : null,
    (v) => !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) ? '邮箱格式不正确' : null
  ],
}
```

## 原则

- **MUST** 验证并清理用户输入
- **NEVER** 直接使用 `dangerouslySetInnerHTML` 渲染未清理的 HTML
- **MUST** 在服务端也进行验证

---

*引用: @react-advanced*
