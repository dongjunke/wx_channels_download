#!/bin/bash
# wx_channels_download macOS 安装脚本

set -e

APP_NAME="wx_video_download"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="${HOME}/.wx_channels_download"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  微信视频号下载器 安装程序${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查是否是 root 用户运行
if [[ $EUID -eq 0 ]]; then
   echo -e "${YELLOW}警告: 建议不要以 root 用户运行安装程序${NC}"
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查二进制文件是否存在
if [[ ! -f "${SCRIPT_DIR}/${APP_NAME}" ]]; then
    echo -e "${RED}错误: 找不到 ${APP_NAME} 二进制文件${NC}"
    echo "请确保安装包完整"
    exit 1
fi

# 创建配置目录
echo -e "\n${GREEN}[1/4]${NC} 创建配置目录..."
mkdir -p "${CONFIG_DIR}"

# 复制配置文件
if [[ ! -f "${CONFIG_DIR}/config.yaml" ]]; then
    if [[ -f "${SCRIPT_DIR}/config.yaml" ]]; then
        cp "${SCRIPT_DIR}/config.yaml" "${CONFIG_DIR}/"
        echo "  配置文件已复制到: ${CONFIG_DIR}/config.yaml"
    else
        cat > "${CONFIG_DIR}/config.yaml" << 'EOF'
debug:
  error: false

pagespy:
  enabled: false

download:
  defaultHighest: false
  filenameTemplate: "{{filename}}_{{spec}}"
  dir: "%UserDownloads%"
  pauseWhenDownload: false
  playDoneAudio: true
  frontend: false
  forceCheckAllFeeds: false
  remoteServer:
    enabled: false
    protocol: "http"
    hostname: "192.168.1.2"
    port: 2022

api:
  protocol: "http"
  hostname: "127.0.0.1"
  port: 2022

proxy:
  system: true
  hostname: "127.0.0.1"
  port: 2023
  skipInstallRootCert: false

channels:
  disableLocationToHome: false

mp:
  disabled: true
  remoteServer:
    protocol: "http"
    hostname: ""
    port: 80
  refreshToken: "wx_channels_download"
  tokenFilepath: ""
  refreshSkipMinutes: 20
  maxWebsocketClients: 5

cloudflare:
  accountId: ""
  apiToken: ""
  refreshToken: "wx_channels_download"
  adminToken: ""
  workerName: "mp-rss-api"
  d1Name: "mp-rss-db"
EOF
        echo "  配置文件已创建: ${CONFIG_DIR}/config.yaml"
    fi
else
    echo "  配置文件已存在，跳过"
fi

# 安装二进制文件
echo -e "\n${GREEN}[2/4]${NC} 安装二进制文件..."
if sudo cp "${SCRIPT_DIR}/${APP_NAME}" "${INSTALL_DIR}/${APP_NAME}"; then
    sudo chmod +x "${INSTALL_DIR}/${APP_NAME}"
    echo "  已安装到: ${INSTALL_DIR}/${APP_NAME}"
else
    # 如果 /usr/local/bin 不可写，尝试用户目录
    USER_BIN="${HOME}/bin"
    mkdir -p "${USER_BIN}"
    cp "${SCRIPT_DIR}/${APP_NAME}" "${USER_BIN}/${APP_NAME}"
    chmod +x "${USER_BIN}/${APP_NAME}"
    echo "  已安装到: ${USER_BIN}/${APP_NAME}"
    echo -e "${YELLOW}提示: 请将 ${USER_BIN} 添加到 PATH 环境变量${NC}"
fi

# 创建卸载脚本
echo -e "\n${GREEN}[3/4]${NC} 创建卸载脚本..."
cat > "${CONFIG_DIR}/uninstall.sh" << EOF
#!/bin/bash
# wx_channels_download 卸载脚本

echo "正在卸载 wx_channels_download..."

# 删除二进制文件
sudo rm -f /usr/local/bin/wx_video_download 2>/dev/null || true
rm -f ~/bin/wx_video_download 2>/dev/null || true

# 删除配置文件（可选）
read -p "是否删除配置文件？[y/N] " -n 1 -r
echo
if [[ \$REPLY =~ ^[Yy]$ ]]; then
    rm -rf "${CONFIG_DIR}"
    echo "配置文件已删除"
fi

echo "卸载完成"
EOF
chmod +x "${CONFIG_DIR}/uninstall.sh"
echo "  卸载脚本已创建: ${CONFIG_DIR}/uninstall.sh"

# 创建启动脚本
echo -e "\n${GREEN}[4/4]${NC} 创建便捷启动脚本..."
cat > "${CONFIG_DIR}/start.sh" << EOF
#!/bin/bash
# wx_channels_download 启动脚本

echo "正在启动微信视频号下载器..."
echo "首次运行需要管理员权限来安装证书"
echo ""

if [[ -f /usr/local/bin/wx_video_download ]]; then
    sudo /usr/local/bin/wx_video_download
elif [[ -f ~/bin/wx_video_download ]]; then
    sudo ~/bin/wx_video_download
else
    echo "错误: 找不到 wx_video_download"
    exit 1
fi
EOF
chmod +x "${CONFIG_DIR}/start.sh"
echo "  启动脚本已创建: ${CONFIG_DIR}/start.sh"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "使用方法:"
echo "  1. 启动程序: ${CONFIG_DIR}/start.sh"
echo "     或者直接运行: sudo ${APP_NAME}"
echo ""
echo "  2. 配置代理:"
echo "     - macOS 系统偏好设置 -> 网络 -> 高级 -> 代理"
echo "     -勾选 '网页代理(HTTP)' 和 '安全网页代理(HTTPS)'"
echo "     - 地址: 127.0.0.1"
echo "     - 端口: 2023"
echo ""
echo "  3. 卸载: ${CONFIG_DIR}/uninstall.sh"
echo ""
