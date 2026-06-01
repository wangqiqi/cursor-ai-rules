# Token 压缩实测说明

复现：`pip install tiktoken && bash scripts/benchmark-token-compression.sh`

## 结论（2026-06-02 改进后）

| 项 | 说明 |
|----|------|
| **默认 `minimal`** | 对 Markdown 做空白/徽章行/emoji/重复 `---` 精简（`compress-markdown-text.py`） |
| **README 前 6KB** | tiktoken 约 **2250 → 1877（~16.6%）** |
| **CHANGELOG / constitution** | 约 **2–8%**（中文技术文档 emoji/徽章较少） |
| **JSON 键名替换** | 默认 **关闭**（`TOKEN_COMPRESS_JSON_KEYS=false`） |
| **`maximum`** | 已 **禁用 base64**，行为同 aggressive |
| **Cursor 账单** | 钩子不改写 Agent 响应；真省对话 token 靠 **`.cursorignore` + 规则 globs** |

## 改进项（v4.8.0）

1. 新增 `.cursor/core/compress-markdown-text.py`
2. `compress_to_binary` 弃用
3. `estimate_compression_tokens` / `estimate_tokens(generic)` 按字符粗算
4. README 去掉未验证的 25–35% / 70% 承诺

## 配置（`.cursor/config/token-optimization.env`）

```bash
COMPRESSION_LEVEL=minimal
TOKEN_COMPRESS_MARKDOWN=true
TOKEN_COMPRESS_JSON_KEYS=false
TOKEN_COMPRESS_SEMANTIC=false
```

## 相关文件

- `.cursor/core/token-compression.sh`
- `.cursor/hooks/token-compression.sh`
- `scripts/benchmark-token-compression.sh`
