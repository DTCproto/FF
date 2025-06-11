#!/bin/sh
set -e

### install dnsutils 7z

TARGET="${TARGETPLATFORM:-unknown}"
echo "Target platform: ${TARGET}"

### eg: linux/amd64,linux/arm64,linux/arm/v7
case "${TARGET}" in
  "linux/amd64")
    ARCH="linux64"
    ;;
  "linux/arm64")
    ARCH="linuxarm64"
    ;;
  *)
    echo "Unsupported CPU: ${TARGET}" >&2;
    exit 1
    ;;
esac

# 定义版本变量
version_tag=$(nslookup api.github.com 8.8.8.8 | grep '^Address:' | grep -v 8.8.8.8 | sed 's/Address: //g' | head -n1 | xargs -I{} curl -ks --resolve api.github.com:443:{} "https://api.github.com/repos/DTCproto/FF/releases" | grep "tag_name" | head -n 1 | sed 's/\"//g;s/,//g;s/ //g;s/v//g;s/tag_name://g' | xargs -i echo '{}')

# 获取下载链接
download_url=$(nslookup api.github.com 8.8.8.8 | grep '^Address:' | grep -v 8.8.8.8 | sed 's/Address: //g' | head -n1 | xargs -I{} curl -ks --resolve api.github.com:443:{} "https://api.github.com/repos/DTCproto/FF/releases/tags/${version_tag}" | grep "browser_download_url" | grep "${ARCH}" | sed -n 's/.*"browser_download_url": *"\([^"]*\)".*/\1/p' | xargs -i echo '{}')

# 下载文件预览链接
echo "Downloading from: ${download_url}"

### ==================文件操作=================== ###

# 安装路径
install_path="/usr/opt/ffmpeg"

rm -rf ffmpeg-install
mkdir ffmpeg-install
cd ffmpeg-install

# 强制覆盖旧版本
rm -rf "${install_path}"
mkdir -p "${install_path}"

# 下载
curl -k -L -O "${download_url}"

# 解压
7z x -bsp1 "ffmpeg-bin-*.7z"

7z x -bsp1 "ffmpeg-*.tar.xz"

7z x -bsp1 "ffmpeg-*.tar"

# 自动识别解压目录（第一个以 ffmpeg-N- 开头的文件夹）
ffmpeg_dir=$(find . -maxdepth 1 -type d -name "ffmpeg-N-*" | head -n 1)
ffmpeg_dir="${ffmpeg_dir#./}"

# 安装
cp -a "${ffmpeg_dir}/." "${install_path}/"

# 建立软链接
ln -svf "${install_path}/bin/ffmpeg" "/usr/local/bin/ffmpeg"
ln -svf "${install_path}/bin/ffprobe" "/usr/local/bin/ffprobe"
ln -svf "${install_path}/bin/ffplay" "/usr/local/bin/ffplay"

# clean
cd ..
rm -rf ffmpeg-install

# 给目录赋权限 755
[ -d "${install_path}" ] && find ${install_path} -type d -exec chmod 755 {} \;
# 给执行文件赋权限 755
[ -d "${install_path}/bin" ] && find ${install_path}/bin -type f -exec chmod 755 {} \;
# 给doc文件赋权限 644
[ -d "${install_path}/doc" ] && find ${install_path}/doc -type f -exec chmod 644 {} \;
[ -d "${install_path}/man" ] && find ${install_path}/man -type f -exec chmod 644 {} \;

# 显示版本
ffmpeg -version | head -n 1
