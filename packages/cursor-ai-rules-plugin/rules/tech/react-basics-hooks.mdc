---
description: "React Hooks 规范 - 自定义 Hooks、useForm、useLocalStorage 等"
globs: ["**/*.jsx", "**/*.tsx"]
alwaysApply: false
priority: 10
---

# React Hooks 规范

> 本规则由 `@react-basics` 引用

## 自定义 Hooks 设计模式

### useLocalStorage
```javascript
function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch { return initialValue }
  })

  const setValue = (value) => {
    const valueToStore = value instanceof Function ? value(storedValue) : value
    setStoredValue(valueToStore)
    window.localStorage.setItem(key, JSON.stringify(valueToStore))
  }
  return [storedValue, setValue]
}
```

### useDebounce
```javascript
function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value)
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])
  return debouncedValue
}
```

### useAsync
```javascript
function useAsync(asyncFunction, immediate = true) {
  const [status, setStatus] = useState('idle')
  const [value, setValue] = useState(null)
  const [error, setError] = useState(null)
  const execute = useCallback(() => {
    setStatus('pending')
    return asyncFunction()
      .then(res => { setValue(res); setStatus('success'); return res })
      .catch(err => { setError(err); setStatus('error'); throw err })
  }, [asyncFunction])
  useEffect(() => { if (immediate) execute() }, [execute, immediate])
  return { execute, status, value, error }
}
```

### useIntersectionObserver
```javascript
function useIntersectionObserver(options = {}) {
  const [isIntersecting, setIsIntersecting] = useState(false)
  const ref = useRef()
  useEffect(() => {
    const el = ref.current
    if (!el) return
    const observer = new IntersectionObserver(([entry]) => {
      setIsIntersecting(entry.isIntersecting)
    }, options)
    observer.observe(el)
    return () => observer.unobserve(el)
  }, [options])
  return [ref, isIntersecting]
}
```

## useForm 模式

```javascript
function useForm(initialValues, validate) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState({})
  const [touched, setTouched] = useState({})

  const handleChange = useCallback((name, value) => {
    setValues(prev => ({ ...prev, [name]: value }))
    if (errors[name]) setErrors(prev => ({ ...prev, [name]: undefined }))
  }, [errors])

  const handleSubmit = useCallback((onSubmit) => (e) => {
    e.preventDefault()
    const validationErrors = validate(values)
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors)
      return
    }
    onSubmit(values)
  }, [validate, values])

  return { values, errors, touched, handleChange, handleSubmit, isValid: Object.keys(errors).length === 0 }
}
```

## 最佳实践

- **MUST** 使用 useCallback 包装传给子组件的回调
- **MUST** 使用 useMemo 缓存昂贵计算
- **MUST** 在 useEffect 中清理订阅/定时器
- **DO NOT** 在循环/条件中调用 Hooks

---

*引用: @react-basics*
