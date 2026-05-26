#!/bin/bash
# 构建 macOS 安装包

set -e

APP_NAME="wx_video_download"
VERSION=$(git describe --tags --always 2>/dev/null || echo "latest")
BUILD_DIR="release"
OUTPUT_NAME="wx_video_download_${VERSION}_macos.tar.gz"

echo "========================================"
echo "  构建 macOS 安装包"
echo "========================================"

# 创建临时构建目录
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 复制二进制文件
echo "复制二进制文件..."
cp "wx_video_download" "${BUILD_DIR}/"

# 复制安装脚本
echo "复制安装脚本..."
cp "install.sh" "${BUILD_DIR}/"

# 复制配置文件
echo "复制配置文件..."
cp "internal/config/config.template.yaml" "${BUILD_DIR}/config.yaml"

# 复制 LICENSE
echo "复制许可证..."
cp "LICENSE" "${BUILD_DIR}/"

# 复制 README（简要版）
cat > "${BUILD_DIR}/README.txt" << 'EOF'
微信视频号下载器 - macOS 安装包
=================================

安装步骤:
1. 解压: tar -xzf wx_video_download_*.tar.gz
2. 安装: sudo ./install.sh
3. 启动: ./install.sh 会自动引导启动

使用方法:
1. 启动程序后会自动安装证书（需要管理员权限）
2. 配置系统代理:
   - 打开 "系统偏好设置" -> "网络" -> "高级" -> "代理"
   - 勾选 "网页代理(HTTP)" 和 "安全网页代理(HTTPS)"
   - 地址: 127.0.0.1
   - 端口: 2023
3. 打开微信 PC 端，点击要下载的视频
4. 在视频下方会出现下载按钮

卸载:
运行 ~/.wx_channels_download/uninstall.sh

常见问题:
Q: 提示权限不足？
A: 确保以 sudo 或管理员身份运行 install.sh

Q: 下载失败？
A: 检查代理是否正确配置，确保程序正在运行

详细文档: https://github.com/ltaoo/wx_channels_download
EOF

# 创建 tar.gz
echo "打包..."
cd "${BUILD_DIR}"
tar -czvf "../${OUTPUT_NAME}" *
cd ..

# 显示结果
echo ""
echo "========================================"
echo "  构建完成!"
echo "========================================"
echo ""
echo "安装包: ${OUTPUT_NAME}"
ls -lh "${OUTPUT_NAME}"
echo ""
echo "使用方法:"
echo "  1. 分发 ${OUTPUT_NAME} 给用户"
echo "  2. 用户解压: tar -xzf ${OUTPUT_NAME}"
echo "  3. 用户安装: sudo ./install.sh"
