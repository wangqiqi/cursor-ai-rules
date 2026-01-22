#!/bin/bash

# 临时测试脚本 - 直接调用感知功能
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.cursor/core"

# 加载完整的env-perception.sh脚本（除了main函数）
echo "🔍 加载感知脚本..."
# 我们需要避免执行main函数，所以注释掉最后的条件判断
sed 's/if \[\[ "\${BASH_SOURCE\[0\]}" == "\${0}" \]\]; then/# &/' .cursor/core/env-perception.sh > /tmp/env-perception-no-main.sh
source /tmp/env-perception-no-main.sh

echo "🔍 执行项目感知测试..."
analyze_project_comprehensive > perception_test_$(date +%Y%m%d_%H%M%S).json
echo "✅ 感知结果已保存到文件"