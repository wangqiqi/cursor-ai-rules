#!/bin/bash
# .cursor 系统检查统一入口
cd "$(dirname "$0")" && ./core/unified-check.sh "$@"
