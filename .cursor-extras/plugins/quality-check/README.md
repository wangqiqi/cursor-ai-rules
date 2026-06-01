# quality-check 插件

封装 `quality-manager.sh` 的质量检查能力，作为可选插件提供。

## 使用

通过 component-manager 获取并调用：

```javascript
const qualityService = await componentManager.getComponent('quality-check.qualityService');
const result = await qualityService.runCheck('lint');
```

## 模式

- `lint` - 代码规范检查
- `format` - 格式检查
- `report` - 生成质量报告
- `pre-push-check` - 推送前检查
