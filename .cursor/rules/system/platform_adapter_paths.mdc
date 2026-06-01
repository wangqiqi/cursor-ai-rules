---
description: "跨平台路径处理 - 路径规范化、拼接、解析的跨平台实现 (路径, path, normalize, join, resolve)"
globs: ["**/*"]
alwaysApply: false
priority: 19
---

# 📁 跨平台路径处理 (Path Handling)

> 由 platform_adapter 引用，处理路径相关的跨平台逻辑

## 路径规范化 (Path Normalization)

```typescript
class PathNormalizer {
  private platform: string;

  normalize(path: string): string {
    const normalized = path.replace(/[/\\]+/g, this.getSeparator());
    return this.handleSpecialPaths(normalized);
  }

  private getSeparator(): string {
    return this.platform === 'windows' ? '\\' : '/';
  }

  private handleSpecialPaths(path: string): string {
    const replacements = {
      '~': this.getHomeDirectory(),
      '$HOME': this.getHomeDirectory(),
      '%USERPROFILE%': this.getHomeDirectory(),
      '/c/': 'C:\\',  // WSL路径转换
    };
    for (const [pattern, replacement] of Object.entries(replacements)) {
      if (path.includes(pattern)) path = path.replace(pattern, replacement);
    }
    return path;
  }

  private getHomeDirectory(): string {
    return process.env.HOME || process.env.USERPROFILE || '.';
  }
}
```

## 路径操作 (Path Operations)

| 操作 | Linux | Windows |
|------|-------|---------|
| 拼接 | path1/path2 | path1\\path2 |
| 解析 | realpath | Resolve-Path |
| 相对 | realpath --relative-to | 自定义逻辑 |

实现时使用 `path.join()`、`path.resolve()`、`path.relative()` 或平台特定命令。
