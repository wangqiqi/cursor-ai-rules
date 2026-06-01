# 安装指南 (INSTALL)

将 **Cursor AI Rules** 接入你的业务项目。本仓库是配置模板，不是托管服务。

> 详细能力说明见 [README.md](README.md)（中文）/ [README.en.md](README.en.md)（英文）。

---

## 一、复制到项目（推荐）

### 必复制（3 项）

| 文件 / 目录 | 作用 |
|-------------|------|
| **`.cursor/`** | 规则、技能、命令、hooks、`core/` 脚本等运行时 |
| **`AGENTS.md`** | Agent 子代理入口说明 |
| **`.cursorignore`** | 缩小 `@codebase` 索引范围，**降低无关文件进入上下文的概率** |

```bash
git clone https://github.com/wangqiqi/cursor-ai-rules.git
DEST=/path/to/your-project

cp -r cursor-ai-rules/.cursor "$DEST/"
cp    cursor-ai-rules/AGENTS.md "$DEST/"
cp    cursor-ai-rules/.cursorignore "$DEST/"
```

可选初始化：

```bash
cd "$DEST" && bash .cursor/core/init.sh --quickstart
```

### 勿复制（本仓库维护 / 本地生成）

| 路径 | 说明 |
|------|------|
| `.cursorGrowth/` | 各项目本地学习数据（运行后生成，已在 `.gitignore`） |
| `.cursor-plugin/` | 插件市场清单，仅本仓库发版用 |
| `.github/`、`.githooks/`、`scripts/` | CI 与维护脚本 |
| `docs/`、`CHANGELOG.md`、`ROADMAP.md`、`plan.md` | 仓库文档与路线图 |
| `archive/` | 本地归档 |

---

## 二、`.cursorignore` 与上下文

### 它解决什么

- **会生效**：代码索引、`@codebase`、自动检索时尽量跳过列表内路径。
- **不解决**：`alwaysApply: true` 的规则仍会注入对话（宪法、哲学、路由等）；要再省 token 需调整规则 frontmatter，见 `.cursor/docs/admin/configuration.md`。

### 默认排除项（摘要）

- `.cursorGrowth/` — 本地隐私数据  
- `archive/` — 归档  
- `.cursor/skills/**/references/` — 技能内上游文档副本（需要时用 `@路径` 手动引用）  
- `.cursor/monitoring/`、日志、`node_modules/`、`.cursor/tests/` 等  

业务项目若已有 `.cursorignore`，请**合并**上述条目，勿直接覆盖。

---

## 三、插件安装（全局）

```bash
git clone https://github.com/wangqiqi/cursor-ai-rules.git
cd cursor-ai-rules
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)" ~/.cursor/plugins/local/cursor-ai-rules
# 重启 Cursor
```

`.cursor-plugin/plugin.json` 指向本仓库 `.cursor/`。业务项目仍建议自带 **`.cursorignore`**（复制或合并），以控制该项目索引体积。

市场上架自检：[docs/MARKETPLACE_SUBMIT.md](docs/MARKETPLACE_SUBMIT.md)。

---

## 四、安装后自检

1. 项目根存在 `.cursor/rules/`、`.cursor/skills/`。  
2. 在 Cursor 聊天输入 `/master` 或 `/vibe` 有响应。  
3. `@codebase` 检索时不再大量命中 `references/`、日志等（已配置 `.cursorignore` 时）。

---

## English (brief)

**Copy to your app repo:** `.cursor/`, `AGENTS.md`, `.cursorignore`.

**`.cursorignore`** reduces index noise for `@codebase`; it does **not** remove `alwaysApply` rules from the chat context.

**Do not copy:** `.cursorGrowth/`, `.cursor-plugin/`, `scripts/`, repo docs under `docs/`, etc.
