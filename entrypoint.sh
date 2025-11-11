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

umask ${UMASK}
echo "Starting PixivBiu with PUID:PGID ${PUID}:${PGID} and UMASK ${UMASK}"

# 检查并创建用户（如果需要）
if [ -n "$PUID" ] && [ "$PUID" -ne 0 ]; then
    echo "Creating user with PUID:$PUID and PGID:$PGID"
    if ! getent group "$PGID" >/dev/null 2>&1; then
        groupadd -g "$PGID" pixivbiugroup
    fi
    if ! getent passwd "$PUID" >/dev/null 2>&1; then
        useradd -u "$PUID" -g "$PGID" -d /Pixiv -s /bin/sh pixivbiuuser
    fi
fi

#确保目录存在
mkdir -p ${DOWNLOAD_PATH} ${USER_PATH}
echo "Ensured directories ${DOWNLOAD_PATH} and ${USER_PATH} exist"

#设置权限
chown -R ${PUID}:${PGID} ${DOWNLOAD_PATH}
chown -R ${PUID}:${PGID} ${USER_PATH}
chmod -R 755 ${DOWNLOAD_PATH}
chmod -R 755 ${USER_PATH}
echo "Set permissions for ${DOWNLOAD_PATH} and ${USER_PATH}"

get_env() {
    env | grep "^$1=" | cut -d= -f2-
}
env
SYS_DEBUG=$(get_env "sys.debug")
# SYS_HOST=$(get_env "sys.host")
SYS_APIROUTE=$(get_env "sys.apiRoute")
SYS_PROXY=$(get_env "sys.proxy")
SYS_LANGUAGE=$(get_env "sys.language")
SYS_THEME=$(get_env "sys.theme")
BIU_SEARCH_MAXTHREADS=$(get_env "biu.search.maxThreads")
BIU_SEARCH_LOADCACHEFIRST=$(get_env "biu.search.loadCacheFirst")
BIU_SEARCH_MAXCACHESIZEMIB=$(get_env "biu.search.maxCacheSizeMiB")
BIU_DOWNLOAD_MODE=$(get_env "biu.download.mode")
BIU_DOWNLOAD_ARIA2HOST=$(get_env "biu.download.aria2Host")
BIU_DOWNLOAD_ARIA2SECRET=$(get_env "biu.download.aria2Secret")
BIU_DOWNLOAD_DETERPATHS=$(get_env "biu.download.deterPaths")
BIU_DOWNLOAD_MAXDOWNLOADING=$(get_env "biu.download.maxDownloading")
BIU_DOWNLOAD_SAVEURI=$(get_env "biu.download.saveURI")
BIU_DOWNLOAD_SAVEFILENAME=$(get_env "biu.download.saveFileName")
BIU_DOWNLOAD_AUTOARCHIVE=$(get_env "biu.download.autoArchive")
BIU_DOWNLOAD_WHATSUGOIRA=$(get_env "biu.download.whatsUgoira")
BIU_DOWNLOAD_IMAGEHOST=$(get_env "biu.download.imageHost")
SECRET_KEY_APISAUCENAO=$(get_env "secret.key.apiSauceNAO")

# 对于每个参数，只有当对应的环境变量有值时才添加
if [ -n "$PORT" ]; then
    SYS_HOST="$BASE_URI:$PORT"
fi
if [ -n "$SYS_APIROUTE" ]; then
    SYS_APIROUTE="$SYS_APIROUTE"
fi
if [ -n "$HTTPS_PROXY" ]; then
    SYS_PROXY="$HTTPS_PROXY"
fi
if [ -n "$HTTP_PROXY" ]; then
    SYS_PROXY="$HTTP_PROXY"
fi
if [ -n "$SYS_PROXY" ]; then
    SYS_PROXY="$SYS_PROXY"
fi
if [ -n "$SYS_LANGUAGE" ]; then
    SYS_LANGUAGE="$SYS_LANGUAGE"
fi
if [ -n "$SYS_THEME" ]; then
    SYS_THEME="$SYS_THEME"
fi
if [ -n "$BIU_SEARCH_MAXTHREADS" ]; then
    BIU_SEARCH_MAXTHREADS="$BIU_SEARCH_MAXTHREADS"
fi
if [ -n "$BIU_SEARCH_LOADCACHEFIRST" ]; then
    BIU_SEARCH_LOADCACHEFIRST="$BIU_SEARCH_LOADCACHEFIRST"
fi
if [ -n "$BIU_SEARCH_MAXCACHESIZEMIB" ]; then
    BIU_SEARCH_MAXCACHESIZEMIB="$BIU_SEARCH_MAXCACHESIZEMIB"
fi
if [ -n "$BIU_DOWNLOAD_MODE" ]; then
    BIU_DOWNLOAD_MODE="$BIU_DOWNLOAD_MODE"
fi
if [ -n "$BIU_DOWNLOAD_ARIA2HOST" ]; then
    BIU_DOWNLOAD_ARIA2HOST="$BIU_DOWNLOAD_ARIA2HOST"
fi
if [ -n "$BIU_DOWNLOAD_ARIA2SECRET" ]; then
    BIU_DOWNLOAD_ARIA2SECRET="$BIU_DOWNLOAD_ARIA2SECRET"
fi
if [ -n "$BIU_DOWNLOAD_DETERPATHS" ]; then
    BIU_DOWNLOAD_DETERPATHS="$BIU_DOWNLOAD_DETERPATHS"
fi
if [ -n "$BIU_DOWNLOAD_MAXDOWNLOADING" ]; then
    BIU_DOWNLOAD_MAXDOWNLOADING="$BIU_DOWNLOAD_MAXDOWNLOADING"
fi
if [ -n "$BIU_DOWNLOAD_SAVEURI" ]; then
    BIU_DOWNLOAD_SAVEURI="$BIU_DOWNLOAD_SAVEURI"
fi
if [ -n "$BIU_DOWNLOAD_SAVEFILENAME" ]; then
    BIU_DOWNLOAD_SAVEFILENAME="$BIU_DOWNLOAD_SAVEFILENAME"
fi
if [ -n "$BIU_DOWNLOAD_AUTOARCHIVE" ]; then
    BIU_DOWNLOAD_AUTOARCHIVE="$BIU_DOWNLOAD_AUTOARCHIVE"
fi
if [ -n "$BIU_DOWNLOAD_WHATSUGOIRA" ]; then
    BIU_DOWNLOAD_WHATSUGOIRA="$BIU_DOWNLOAD_WHATSUGOIRA"
fi
if [ -n "$BIU_DOWNLOAD_IMAGEHOST" ]; then
    BIU_DOWNLOAD_IMAGEHOST="$BIU_DOWNLOAD_IMAGEHOST"
fi
if [ -n "$SECRET_KEY_APISAUCENAO" ]; then
    SECRET_KEY_APISAUCENAO="$SECRET_KEY_APISAUCENAO"
fi

echo "Ready to start PixivBiu with environment variable configurations."
echo "sys.debug=$SYS_DEBUG"
echo "sys.host=$SYS_HOST"
echo "sys.apiRoute=$SYS_APIROUTE"
echo "sys.proxy=$SYS_PROXY"
echo "sys.language=$SYS_LANGUAGE"
echo "sys.theme=$SYS_THEME"
echo "biu.search.maxThreads=$BIU_SEARCH_MAXTHREADS"
echo "biu.search.loadCacheFirst=$BIU_SEARCH_LOADCACHEFIRST"
echo "biu.search.maxCacheSizeMiB=$BIU_SEARCH_MAXCACHESIZEMIB"
echo "biu.download.mode=$BIU_DOWNLOAD_MODE"
echo "biu.download.aria2Host=$BIU_DOWNLOAD_ARIA2HOST"
echo "biu.download.aria2Secret=$BIU_DOWNLOAD_ARIA2SECRET"
echo "biu.download.deterPaths=$BIU_DOWNLOAD_DETERPATHS"
echo "biu.download.maxDownloading=$BIU_DOWNLOAD_MAXDOWNLOADING"
echo "biu.download.saveURI=$BIU_DOWNLOAD_SAVEURI"
echo "biu.download.saveFileName=$BIU_DOWNLOAD_SAVEFILENAME"
echo "biu.download.autoArchive=$BIU_DOWNLOAD_AUTOARCHIVE"
echo "biu.download.whatsUgoira=$BIU_DOWNLOAD_WHATSUGOIRA"
echo "biu.download.imageHost=$BIU_DOWNLOAD_IMAGEHOST"
echo "secret.key.apiSauceNAO=$SECRET_KEY_APISAUCENAO"


echo "Starting PixivBiu..."
exec sudo -u "#$PUID" -g "#$PGID" /Pixiv/main