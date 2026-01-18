#!/bin/bash
set -e

echo "脚本开始执行" >&2

# 加载共享函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
# 保存SCRIPT_DIR，避免被path-config.sh覆盖
ORIGINAL_SCRIPT_DIR="$SCRIPT_DIR"
source "$SCRIPT_DIR/path-config.sh"
SCRIPT_DIR="$ORIGINAL_SCRIPT_DIR"

echo "库加载完成" >&2

# 验证项目上下文
echo "跳过项目上下文验证" >&2

# 主函数
main() {
    echo "main函数执行" >&2
    echo "测试完成"
}

# 如果直接运行此脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "条件满足，调用main函数" >&2
    main "$@"
else
    echo "条件不满足" >&2
fi
