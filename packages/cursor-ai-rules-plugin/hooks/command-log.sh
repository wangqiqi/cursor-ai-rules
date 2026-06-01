#!/bin/bash
# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_plugin-env.sh" 2>/dev/null || true
# 📊 命令日志 Hook（委托 logging-common.sh，避免重复逻辑与路径错误）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/logging-common.sh" command
