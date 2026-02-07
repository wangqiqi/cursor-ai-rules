# .cursor 目录结构说明

## 📁 根目录结构

```
.cursor/
├── cursor-master.sh          # 🎯 主入口 - Master命令司令部
├── check                     # 🔍 系统检查便捷入口
├── stop-web                  # 🛑 停止Web服务便捷入口
│
├── agents/                   # 🤖 AI代理
│   └── command-center.md
│
├── commands/                 # ⚡ 命令系统
│   ├── master.md
│   ├── master-handler.js
│   └── [其他命令文件]
│
├── core/                     # 🔧 核心脚本库（所有脚本统一存放）
│   ├── unified-check.sh      # 统一验证脚本
│   ├── verify-system.sh      # 系统验证脚本
│   ├── system-health-check.sh
│   ├── check.sh              # 检查脚本实现
│   ├── stop-web.sh           # 停止Web服务实现
│   └── [87+ 个核心脚本]
│
├── config/                   # ⚙️ 配置文件
│   ├── personality-system.json
│   └── [其他配置]
│
├── rules/                    # 📜 规则系统
│   ├── core/                 # 核心规则
│   ├── system/               # 系统规则
│   ├── tech/                 # 技术规则
│   ├── workflow/             # 工作流规则
│   ├── evolution/            # 演进规则
│   └── team/                 # 团队规则
│
├── features/                 # ✨ 特性系统
│   ├── skills/               # 技能库
│   ├── hooks/                # Git钩子
│   └── [其他特性]
│
├── skills/                   # 🎓 项目技能
│   └── skill-dispatcher/
│
└── docs/                     # 📚 文档
    ├── developer/            # 开发者文档
    ├── guides/               # 指南文档
    └── reference/            # 参考文档
```

## 🎯 快速入口

### 主入口
```bash
.cursor/cursor-master.sh      # Master命令司令部（主入口）
```

### 便捷入口（无.sh后缀，更简洁）
```bash
.cursor/check                # 系统检查
.cursor/stop-web             # 停止Web服务
```

## 🔧 核心脚本

所有实现脚本都存放在 `.cursor/core/` 目录中：

- `unified-check.sh` - 统一验证（整合系统检查+规则检查+健康检查）
- `verify-system.sh` - 系统完整性验证
- `system-health-check.sh` - 系统健康检查
- `check.sh` - 检查脚本实现
- `stop-web.sh` - 停止Web服务实现
- 以及其他87+个核心脚本...

## 📊 统计信息

- **Agents**: 1个
- **Commands**: 3个
- **Rules**: 56个
- **Skills**: 35个（技能库）+ 1个（项目技能）
- **Core Scripts**: 90+个
- **Features**: 74+个
- **Docs**: 24个

## 🎯 设计原则

1. **根目录简洁** - 只保留主入口和便捷入口
2. **脚本统一** - 所有脚本存放在 `core/` 目录
3. **功能分离** - rules/、features/、skills/ 各司其职
4. **便于维护** - 清晰的目录结构和职责划分
