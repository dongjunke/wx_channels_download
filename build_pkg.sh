#!/bin/bash
# 构建 macOS 一键安装包

set -e

APP_NAME="wx_video_download"
VERSION=$(git describe --tags --always 2>/dev/null || echo "latest")
BUILD_DIR="release_pkg"
OUTPUT_NAME="wx_video_download_${VERSION}_macos.pkg"

echo "========================================"
echo "  构建 macOS 一键安装包"
echo "========================================"

# 清理旧文件
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 复制二进制文件
echo "复制二进制文件..."
cp "wx_video_download" "${BUILD_DIR}/"

# ====== 创建 .app 应用包 ======
echo "创建应用包..."
APP_DIR="${BUILD_DIR}/启动下载器.app/Contents/MacOS"
mkdir -p "${APP_DIR}"

# 创建启动脚本（可执行文件）
cat > "${APP_DIR}/启动下载器" << 'APPSCRIPT'
#!/bin/bash
osascript -e 'tell application "Terminal" to do script "sudo wx_video_download"'
APPSCRIPT
chmod +x "${APP_DIR}/启动下载器"

# 创建 Info.plist
cat > "${BUILD_DIR}/启动下载器.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>启动下载器</string>
    <key>CFBundleIdentifier</key>
    <string>com.wxchannels.download</string>
    <key>CFBundleName</key>
    <string>启动下载器</string>
    <key>CFBundleDisplayName</key>
    <string>微信视频号下载器</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024</string>
</dict>
</plist>
PLIST

# 创建 PkgInfo
echo -n "APPL????" > "${BUILD_DIR}/启动下载器.app/Contents/PkgInfo"

# ====== 创建 postinstall 脚本 ======
cat > "${BUILD_DIR}/postinstall" << 'POSTEOF'
#!/bin/bash

# 安装主程序
chmod +x "/usr/local/bin/wx_video_download"

# 安装 .app 启动器
cp -R "/Applications/安装包内容/启动下载器.app" "/Applications/"

# 修复权限
chmod +x "/Applications/启动下载器.app/Contents/MacOS/启动下载器"

# 显示安装完成
sleep 1
osascript -e 'display dialog "安装完成！\n\n使用方法：\n1. 打开 系统偏好设置 -> 网络\n2. 点击 Wi-Fi 右边的详情... -> 代理\n3. 勾选 HTTP 和 HTTPS 代理\n4. 地址填 127.0.0.1，端口填 2023\n5. 点击 好 和 应用\n6. 从启动台找到 微信视频号下载器 双击启动\n\n提示：首次运行会要求输入密码" buttons {"好的"} default button 1 with title "安装完成"'
POSTEOF
chmod +x "${BUILD_DIR}/postinstall"

# 创建 preinstall 脚本
cat > "${BUILD_DIR}/preinstall" << 'PREEOF'
#!/bin/bash
PREEOF
chmod +x "${BUILD_DIR}/preinstall"

# ====== 构建 pkg ======
echo "构建安装包..."

pkgbuild \
    --identifier "com.wxchannels.download" \
    --version "${VERSION}" \
    --root "${BUILD_DIR}" \
    --scripts "${BUILD_DIR}" \
    --install-location "/Applications/安装包内容" \
    --quiet \
    "${OUTPUT_NAME}"

echo ""
echo "========================================"
echo "  构建完成！"
echo "========================================"
echo ""
echo "安装包: ${OUTPUT_NAME}"
ls -lh "${OUTPUT_NAME}"
