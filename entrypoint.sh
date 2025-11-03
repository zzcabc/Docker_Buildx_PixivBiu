#!/bin/sh

DOWNLOAD_PATH=/Pixiv/downloads
USER_PATH=/Pixiv/usr
CONFIG_FILE=/Pixiv/config.yml

umask ${UMASK}
echo "Starting PixivBiu with PUID:PGID ${PUID}:${PGID} and UMASK ${UMASK}"

# 检查并创建用户（如果需要）
if [ -n "$PUID" ] && [ "$PUID" != "0" ]; then
    if ! getent passwd "$PUID" >/dev/null 2>&1; then
        echo "Creating user with PUID: $PUID and PGID: $PGID"
        if ! getent group "$PGID" >/dev/null 2>&1; then
            groupadd -g "$PGID" pixivbiugroup
        fi
        useradd -u "$PUID" -g "$PGID" -d /Pixiv -s /bin/sh pixivbiuuser
    fi
fi


set -e



# 确保目录存在
mkdir -p ${DOWNLOAD_PATH} ${USER_PATH}

# 设置权限
chown -R ${PUID}:${PGID} ${DOWNLOAD_PATH}
chown -R ${PUID}:${PGID} ${USER_PATH}

# 检查并创建/修改配置文件
# if [ ! -f "$CONFIG_FILE" ]; then
#     echo "Creating config file at $CONFIG_FILE"
#     cat > "$CONFIG_FILE" << EOF
# sys.host: "0.0.0.0:4001"
# sys.autoOpen: false
# sys.ignoreOutdated: true
# EOF
# fi

exec sudo -u "#$PUID" -g "#$PGID" /Pixiv/main