#!/bin/bash

# Futu Stock MCP Server PyPI 发布脚本 (Bash)
# 自动递增 patch 版本号，构建发布到 PyPI，然后推送代码和 tag

set -e  # 遇到错误立即退出

echo "📦 开始发布 Futu Stock MCP Server 到 PyPI..."

# 检查必要的工具
if ! command -v uv &> /dev/null; then
    echo "❌ uv 未安装，请先安装 uv"
    exit 1
fi

if ! command -v python &> /dev/null; then
    echo "❌ Python 未安装"
    exit 1
fi

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
echo "📁 项目目录: $PROJECT_ROOT"

# 切换到项目目录
cd "$PROJECT_ROOT"

# 检查虚拟环境
VENV_PATH="$PROJECT_ROOT/.venv"
if [ ! -d "$VENV_PATH" ]; then
    echo "🔧 创建虚拟环境..."
    uv venv
fi

# 激活虚拟环境
echo "🔄 激活虚拟环境..."
source "$VENV_PATH/bin/activate"

# 验证虚拟环境
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ 虚拟环境激活失败"
    exit 1
fi

echo "✅ 虚拟环境已激活: $VIRTUAL_ENV"

# 安装项目依赖
echo "📥 安装项目依赖..."
uv pip install -e .

# 安装发布工具
echo "🔧 安装发布工具..."
uv pip install build twine

# 清理旧的构建文件
echo "🧹 清理旧的构建文件..."
rm -rf dist/ build/
find . -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true
mkdir -p dist/

# 读取当前版本
CURRENT_VERSION=$(python -c "
import re
with open('pyproject.toml', 'r') as f:
    content = f.read()
match = re.search(r'^version\s*=\s*[\"\'](.*?)[\"\']\s*$', content, re.MULTILINE)
if match:
    print(match.group(1))
else:
    print('unknown')
    exit(1)
")

echo "📋 当前版本: v$CURRENT_VERSION"

# 自动递增 patch 版本号（x.y.z → x.y.z+1）
NEW_VERSION=$(python -c "
parts = '$CURRENT_VERSION'.split('.')
parts[-1] = str(int(parts[-1]) + 1)
print('.'.join(parts))
")

echo "🆙 新版本: v$NEW_VERSION"

# 更新 pyproject.toml 中的版本号
sed -i.bak "s/^version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
rm -f pyproject.toml.bak

# 更新 server.py 中的版本号
sed -i.bak "s/version='futu-stock-mcp-server [^']*'/version='futu-stock-mcp-server $NEW_VERSION'/" src/futu_stock_mcp_server/server.py
rm -f src/futu_stock_mcp_server/server.py.bak

echo "✅ 版本号已更新: $CURRENT_VERSION → $NEW_VERSION"

# 构建包
echo "🔨 构建包..."
python -m build

# 检查包
echo "🔍 检查包..."
python -m twine check dist/*

# 列出构建的文件
echo "📦 构建的文件:"
ls -la dist/

# ===== 先发布到 PyPI =====
echo ""
echo "🚀 发布 v$NEW_VERSION 到 PyPI..."

if [ -z "$TWINE_PASSWORD" ]; then
    echo "⚠️  未设置 TWINE_PASSWORD，将使用 ~/.pypirc 中的认证信息"
fi

python -m twine upload dist/*

echo "✅ 发布成功！"
echo "🔗 查看包: https://pypi.org/project/futu-stock-mcp-server/$NEW_VERSION/"

# ===== 发布成功后，推送代码和 tag =====
echo ""
echo "📤 提交版本变更并推送代码..."

git add pyproject.toml src/futu_stock_mcp_server/server.py
git commit -m "chore: bump version to $NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
git push origin HEAD
git push origin "v$NEW_VERSION"

echo "🏷️  Git tag v$NEW_VERSION 已推送到远程仓库"
echo ""
echo "🎉 完成！"
