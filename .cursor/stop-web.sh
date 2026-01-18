#!/bin/bash

# Cursor AI Rules - 停止Web界面脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$SCRIPT_DIR/web"

echo "🛑 停止 Cursor AI Master Web界面..."

# 检查PID文件是否存在
if [ ! -f "$WEB_DIR/server.pid" ]; then
    echo "❌ 未找到服务器PID文件，服务器可能未启动"
    echo "检查路径: $WEB_DIR/server.pid"
    exit 1
fi

# 读取PID并停止进程
PID=$(cat "$WEB_DIR/server.pid")
if kill -0 $PID 2>/dev/null; then
    echo "🔄 正在停止服务器进程 (PID: $PID)..."
    kill $PID

    # 等待进程停止
    for i in {1..10}; do
        if ! kill -0 $PID 2>/dev/null; then
            echo "✅ 服务器已停止"
            rm -f "$WEB_DIR/server.pid"
            exit 0
        fi
        sleep 0.5
    done

    # 强制终止
    echo "⚠️  正常停止失败，尝试强制终止..."
    kill -9 $PID 2>/dev/null
    rm -f "$WEB_DIR/server.pid"
    echo "✅ 服务器已强制停止"
else
    echo "⚠️  服务器进程已不存在"
    rm -f "$WEB_DIR/server.pid"
fi