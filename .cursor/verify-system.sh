#!/bin/bash

###############################################################################
# .cursor 系统验证入口
#
# 委托给 core/unified-check.sh 执行完整验证。
# 保持与 README 文档引用一致。
#
# 使用方法：
#   ./.cursor/verify-system.sh         # 完整验证
#   ./.cursor/verify-system.sh --quick # 快速验证
###############################################################################

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$CURSOR_DIR/core/unified-check.sh" "$@"
