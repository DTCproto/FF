#!/bin/sh
set -e

### apt install dnsutils

TARGET="${TARGETPLATFORM:-unknown}"
echo "Target platform: ${TARGET}"

### eg: linux/amd64,linux/arm64,linux/arm/v7
case "${TARGET}" in
  "linux/amd64")
    ARCH="x64"
    ;;
  "linux/386")
    ARCH="x86"
    ;;
  "linux/arm64")
    ARCH="arm64"
    ;;
  "linux/arm/v7")
    ARCH="arm"
    ;;
  "linux/arm/v6")
    ARCH="arm"
    ;;
  *)
    echo "Unsupported CPU: ${TARGET}" >&2;
    exit 1
    ;;
esac

# 定义版本变量
version_tag=$(nslookup api.github.com 8.8.8.8 | grep '^Address:' | grep -v 8.8.8.8 | sed 's/Address: //g' | head -n1 | xargs -I{} curl -ks --resolve api.github.com:443:{} "https://api.github.com/repos/ip7z/7zip/releases" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g;s/v//g' | xargs -i echo '{}')

version_short=$(echo ${version_tag} | sed 's/\.//g' | xargs -i echo '{}')

download_url="https://github.com/ip7z/7zip/releases/download/${version_tag}/7z${version_short}-linux-${ARCH}.tar.xz"

# 下载文件预览链接
echo "Downloading from: ${download_url}"

### ==================文件操作=================== ###

# 安装路径
install_path="/usr/opt/7z"

rm -rf 7z-install
mkdir 7z-install
cd 7z-install

rm -rf ${install_path}
mkdir -p "${install_path}/bin"

# 下载
curl -k -L -O "${download_url}"

# 安装
tar -xf *.tar.xz
install 7zz* "${install_path}/bin/"
ln -svf "${install_path}/bin/7zz" "/usr/local/bin/7zz"
ln -svf "${install_path}/bin/7zz" "/usr/local/bin/7z"

# clean
cd ..
rm -rf 7z-install

# 给目录赋权限 755
[ -d "${install_path}" ] && find ${install_path} -type d -exec chmod 755 {} \;
# 给执行文件赋权限 755
[ -d "${install_path}/bin" ] && find ${install_path}/bin -type f -exec chmod 755 {} \;
# 给doc文件赋权限 644
[ -d "${install_path}/doc" ] && find ${install_path}/doc -type f -exec chmod 644 {} \;
[ -d "${install_path}/man" ] && find ${install_path}/man -type f -exec chmod 644 {} \;

# 显示版本
7z -version | head -n 2
