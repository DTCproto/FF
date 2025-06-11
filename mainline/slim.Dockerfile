FROM debian:bookworm-slim AS builder

# BuildKit 的自动变量
ARG TARGETPLATFORM

# 安装工具
RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		tzdata \
		dnsutils \
		xz-utils \
		binutils \
		curl \
		wget \
		bash \
		; \
	rm -rf /var/lib/apt/lists/*; \
	mkdir -p /usr/src;

COPY install_7z.sh /usr/src/install_7z.sh
COPY install_ffmpeg.sh /usr/src/install_ffmpeg.sh

RUN set -eux; \
	cd /usr/src/; \
	chmod +x /usr/src/install_7z.sh; \
	chmod +x /usr/src/install_ffmpeg.sh; \
	ls -al /usr/src/; \
	TARGETPLATFORM=${TARGETPLATFORM} ./install_7z.sh; \
	TARGETPLATFORM=${TARGETPLATFORM} ./install_ffmpeg.sh;

# 精简运行文件
RUN set -eux; \
	strip /usr/opt/ffmpeg/bin/*;

# 方便作为基础构建镜像
FROM debian:bookworm-slim

# build args
ARG INSTALL_PATH="/usr/opt/ffmpeg"

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		tzdata \
		; \
	apt-get clean; \
	rm -rf /tmp/* /var/lib/apt/lists/*;

COPY --from=builder ${INSTALL_PATH}/bin/ffmpeg ${INSTALL_PATH}/bin/
COPY --from=builder ${INSTALL_PATH}/bin/ffprobe ${INSTALL_PATH}/bin/

RUN set -eux; \
	ln -svf "${INSTALL_PATH}/bin/ffmpeg" "/usr/local/bin/ffmpeg"; \
	ln -svf "${INSTALL_PATH}/bin/ffprobe" "/usr/local/bin/ffprobe";

LABEL \
	description="FFMPEG" \
	maintainer="Custom Auto Build"

CMD ["sh"]
