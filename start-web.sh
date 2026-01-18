#!/bin/bash

# Cursor AI Rules - Web界面启动脚本
# 快速启动图形化Web界面

set -e

echo "🧠 Cursor AI Master - Web界面启动器"
echo "======================================"

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 错误: Node.js 未安装"
    echo "请访问 https://nodejs.org 安装 Node.js"
    exit 1
fi

# 检查npm是否可用
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: npm 未找到"
    echo "请确保 Node.js 正确安装"
    exit 1
fi

# 检查并安装express依赖
if ! [ -d "web/node_modules/express" ]; then
    echo "📦 安装 Web界面依赖..."
    cd web
    if ! [ -f "package.json" ]; then
        npm init -y >/dev/null 2>&1
    fi
    npm install express >/dev/null 2>&1
    cd ..
    echo "✅ 依赖安装完成"
else
    echo "✅ 依赖已存在，跳过安装"
fi

# 检查web目录是否存在
if [ ! -d "web" ]; then
    echo "❌ 错误: web目录不存在"
    echo "请确保项目结构完整"
    exit 1
fi

# 启动Web服务器
echo "🚀 启动 Cursor AI Master Web界面..."
echo "🌐 访问地址: http://localhost:3000"
echo "💡 提示: 在浏览器中打开上述地址开始使用"
echo ""
echo "按 Ctrl+C 停止服务器"
echo ""

# 启动服务器并在后台运行
cd web
nohup node server.js > server.log 2>&1 &
echo $! > server.pid
cd ..

echo "✅ Web服务器已在后台启动 (PID: $(cat web/server.pid))"
echo "📝 日志文件: web/server.log"
echo "🛑 要停止服务器，请运行: ./stop-web.sh"