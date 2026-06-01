# Cursor 命令扩展说明

## handler 扩展用法

### 当前实现

`master.md`、`vibe.md` 等命令的 frontmatter 中包含：

```yaml
handler: "./master-handler.js"
context: ["currentFile", "selectedText", "cursorPosition", ...]
```

### 待确认项

- **Cursor 官方**：根据 [Cursor 命令文档](https://docs.cursor.com/context/commands)，slash commands 主要为 Markdown 描述，插入为 prompt 上下文。
- **handler 字段**：是否为 Cursor 原生支持，需以官方文档为准。
- **当前行为**：若 Cursor 不原生执行 handler，则 AI 会根据 master.md 的规则和前置步骤，通过 `run_terminal_cmd` 等方式间接调用 master-handler.js。

### 建议

保留 `handler` 作为**文档约定**和**实现说明**，便于 AI 和开发者理解命令的实际执行入口。若 Cursor 未来支持原生 handler 执行，可无缝对接。
