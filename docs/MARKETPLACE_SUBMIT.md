# Cursor 插件市场提交清单 (Task 6.5)

本仓插件包路径：`packages/cursor-ai-rules-plugin/`（由 `scripts/sync-plugin-package.sh` 生成）。

## 提交前自检

```bash
bash scripts/sync-plugin-package.sh
bash scripts/verify-plugin-package.sh
bash scripts/check-plugin-package-drift.sh
bash .cursor/tests/test-common.sh
```

- [ ] `plugin.json` 的 `version` 与 `CHANGELOG.md` 最新条目一致
- [ ] `packages/` 已提交且无未 sync 漂移（CI `check-plugin-package-drift` 通过）
- [ ] `README.md` / `README.en.md` 含双轨安装说明
- [ ] 许可：MIT（`LICENSE`）
- [ ] 仓库：`https://github.com/wangqiqi/cursor-ai-rules`

## 本地验证安装

```bash
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)/packages/cursor-ai-rules-plugin" ~/.cursor/plugins/local/cursor-ai-rules
```

重启 Cursor，在 Settings → Rules / Skills 中确认加载。

## 官方流程

1. 阅读 [Cursor Plugins Building](https://cursor.com/docs/plugins/building)
2. 按官方要求提交 PR 或表单（可能指向 `github.com/cursor/plugins` 等 monorepo）
3. 若仅接受「仓库根即插件」，可从 tag 附件 `cursor-ai-rules-plugin-*.tar.gz`（见 `.github/workflows/release.yml`）解压提交，或使用 `git subtree split`

## 发版

```bash
# 更新 CHANGELOG 后
git tag v4.7.x
git push origin v4.7.x
```

`release.yml` 会自动打包 `packages/cursor-ai-rules-plugin` 并创建 GitHub Release。
