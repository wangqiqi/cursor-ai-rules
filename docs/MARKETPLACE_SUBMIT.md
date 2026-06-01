# Cursor 插件市场提交清单

**单仓库模式**：插件清单在 `.cursor-plugin/plugin.json`，组件路径指向 **`.cursor/`**（无 `packages/` 副本）。

## 提交前自检

```bash
bash scripts/verify-plugin-manifest.sh
bash .cursor/tests/test-common.sh
```

- [ ] `plugin.json` 的 `version` 与 `CHANGELOG.md` 最新条目一致（`bash scripts/bump-plugin-version.sh`）
- [ ] `.cursor/` 为唯一权威源；复制安装与插件安装共用同一棵树
- [ ] `README.md` / `README.en.md` 含双轨说明
- [ ] 许可：MIT（`LICENSE`）
- [ ] 仓库：`https://github.com/wangqiqi/cursor-ai-rules`

## 本地验证（插件 = 整个仓库）

```bash
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)" ~/.cursor/plugins/local/cursor-ai-rules
```

重启 Cursor，在 Settings → Rules / Skills 中确认加载。

## 官方流程

1. 阅读 [Cursor Plugins Building](https://cursor.com/docs/plugins/building)
2. 提交本仓库（根目录含 `.cursor-plugin/plugin.json`）
3. 若市场要求独立目录，使用 Release 附件 `cursor-ai-rules-*.tar.gz`（含 `.cursor-plugin` + `.cursor` + `AGENTS.md`）

## 发版

```bash
# 更新 CHANGELOG 后
bash scripts/bump-plugin-version.sh
git tag v4.7.x
git push origin v4.7.x
```

`release.yml` 会打包单仓库发行物并创建 GitHub Release。
