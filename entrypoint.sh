#!/bin/bash
set -e

BASE_URI="0.0.0.0"
PORT=${PORT:-4001}
DOWNLOAD_PATH=/Pixiv/downloads
USER_PATH=/Pixiv/usr
CONFIG_FILE=/Pixiv/config.yml

UMASK=${UMASK:-022}
PUID=${PUID:-0}
PGID=${PGID:-0}
# 设置主机地址
if [ -n "$PORT" ]; then
    export SYS_HOST="\"$BASE_URI:$PORT\""
fi

umask ${UMASK}
echo "Starting PixivBiu with PUID:PGID ${PUID}:${PGID} and UMASK ${UMASK}"

# 检查并创建用户（如果需要）
if [ "$PUID" -ne 0 ]; then
    echo "Creating user with PUID:$PUID and PGID:$PGID"
    
    # 创建组（如果不存在）
    if ! getent group "$PGID" >/dev/null 2>&1; then
        groupadd -g "$PGID" pixivbiugroup
        echo "Created group with GID: $PGID"
    fi
    
    # 创建用户（如果不存在）
    if ! getent passwd "$PUID" >/dev/null 2>&1; then
        useradd -u "$PUID" -g "$PGID" -d /Pixiv -s /bin/sh pixivbiuuser
        echo "Created user with UID: $PUID"
    fi
    
    # 确保目录存在
    mkdir -p ${DOWNLOAD_PATH} ${USER_PATH}
    echo "Ensured directories ${DOWNLOAD_PATH} and ${USER_PATH} exist"
    
    # 设置权限
    chown -R ${PUID}:${PGID} /Pixiv
    chmod -R 755 /Pixiv
    echo "Set permissions for /Pixiv to ${PUID}:${PGID}"
else
    echo "Running as root user"
    # 确保目录存在
    mkdir -p ${DOWNLOAD_PATH} ${USER_PATH}
fi

get_env() {
    env | grep "^$1=" | cut -d= -f2-
}

if [ -z "$SYS_DEBUG" ]; then
    if [ -n "$(get_env "sys.debug")" ]; then
        export SYS_DEBUG="$(get_env "sys.debug")"
    fi
fi
if [ -z "$SYS_APIROUTE" ]; then
    if [ -n "$(get_env "sys.apiRoute")" ]; then
        export SYS_APIROUTE="$(get_env "sys.apiRoute")"
    fi
fi
if [ -z "$SYS_PROXY" ]; then
    if [ -n "$(get_env "sys.proxy")" ]; then
        export SYS_PROXY=$(get_env "sys.proxy")
    fi
fi
if [ -z "$SYS_LANGUAGE" ]; then
    if [ -n "$(get_env "sys.language")" ]; then
        export SYS_LANGUAGE=$(get_env "sys.language")
    fi
fi
if [ -z "$SYS_THEME" ]; then
    if [ -n "$(get_env "sys.theme")" ]; then
        export SYS_THEME=$(get_env "sys.theme")
    fi
fi
if [ -z "$BIU_SEARCH_MAXTHREADS" ]; then
    if [ -n "$(get_env "biu.search.maxThreads")" ]; then
        export BIU_SEARCH_MAXTHREADS=$(get_env "biu.search.maxThreads")
    fi
fi
if [ -z "$BIU_SEARCH_LOADCACHEFIRST" ]; then
    if [ -n "$(get_env "biu.search.loadCacheFirst")" ]; then
        export BIU_SEARCH_LOADCACHEFIRST=$(get_env "biu.search.loadCacheFirst")
    fi
fi
if [ -z "$BIU_SEARCH_MAXCACHESIZEMIB" ]; then
    if [ -n "$(get_env "biu.search.maxCacheSizeMiB")" ]; then
        export BIU_SEARCH_MAXCACHESIZEMIB=$(get_env "biu.search.maxCacheSizeMiB")
    fi
fi
if [ -z "$BIU_DOWNLOAD_MODE" ]; then
    if [ -n "$(get_env "biu.download.mode")" ]; then
        export BIU_DOWNLOAD_MODE=$(get_env "biu.download.mode")
    fi
fi
if [ -z "$BIU_DOWNLOAD_ARIA2HOST" ]; then
    if [ -n "$(get_env "biu.download.aria2Host")" ]; then
        export BIU_DOWNLOAD_ARIA2HOST=$(get_env "biu.download.aria2Host")
    fi
fi
if [ -z "$BIU_DOWNLOAD_ARIA2SECRET" ]; then
    if [ -n "$(get_env "biu.download.aria2Secret")" ]; then
        export BIU_DOWNLOAD_ARIA2SECRET=$(get_env "biu.download.aria2Secret")
    fi
fi
if [ -z "$BIU_DOWNLOAD_DETERPATHS" ]; then
    if [ -n "$(get_env "biu.download.deterPaths")" ]; then
        export BIU_DOWNLOAD_DETERPATHS=$(get_env "biu.download.deterPaths")
    fi
fi
if [ -z "$BIU_DOWNLOAD_MAXDOWNLOADING" ]; then
    if [ -n "$(get_env "biu.download.maxDownloading")" ]; then
        export BIU_DOWNLOAD_MAXDOWNLOADING=$(get_env "biu.download.maxDownloading")
    fi
fi
if [ -z "$BIU_DOWNLOAD_SAVEURI" ]; then
    if [ -n "$(get_env "biu.download.saveURI")" ]; then
        export BIU_DOWNLOAD_SAVEURI=$(get_env "biu.download.saveURI")
    fi
fi
if [ -z "$BIU_DOWNLOAD_SAVEFILENAME" ]; then
    if [ -n "$(get_env "biu.download.saveFileName")" ]; then
        export BIU_DOWNLOAD_SAVEFILENAME=$(get_env "biu.download.saveFileName")
    fi
fi
if [ -z "$BIU_DOWNLOAD_AUTOARCHIVE" ]; then
    if [ -n "$(get_env "biu.download.autoArchive")" ]; then
        export BIU_DOWNLOAD_AUTOARCHIVE=$(get_env "biu.download.autoArchive")
    fi
fi
if [ -z "$BIU_DOWNLOAD_WHATSUGOIRA" ]; then
    if [ -n "$(get_env "biu.download.whatsUgoira")" ]; then
        export BIU_DOWNLOAD_WHATSUGOIRA=$(get_env "biu.download.whatsUgoira")
    fi
fi
if [ -z "$BIU_DOWNLOAD_IMAGEHOST" ]; then
    if [ -n "$(get_env "biu.download.imageHost")" ]; then
        export BIU_DOWNLOAD_IMAGEHOST=$(get_env "biu.download.imageHost")
    fi
fi
if [ -z "$SECRET_KEY_APISAUCENAO" ]; then
    if [ -n "$(get_env "secret.key.apiSauceNAO")" ]; then
        export SECRET_KEY_APISAUCENAO=$(get_env "secret.key.apiSauceNAO")
    fi
fi

if [ -z "$SYS_PROXY" ]; then
    # 处理代理设置
    if [ -n "$HTTPS_PROXY" ]; then
        export SYS_PROXY="\"$HTTPS_PROXY\""
    elif [ -n "$HTTP_PROXY" ]; then
        export SYS_PROXY="\"$HTTP_PROXY\""
    fi
else
    export SYS_PROXY="\"$SYS_PROXY\""
fi



echo "Starting PixivBiu with environment variable configurations."
env

echo "Starting PixivBiu..."

# 根据用户ID选择执行方式
if [ "$PUID" -eq 0 ]; then
    # 以root用户运行
    exec sudo -E /Pixiv/main
else
    # 以指定用户运行
    exec sudo -E -u "#$PUID" -g "#$PGID" /Pixiv/main
fi