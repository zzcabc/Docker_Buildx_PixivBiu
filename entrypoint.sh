#!/bin/sh
set -e

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

# 确保目录存在
mkdir -p ${DOWNLOAD_PATH} ${USER_PATH}

# 设置权限
chown -R ${PUID}:${PGID} ${DOWNLOAD_PATH}
chown -R ${PUID}:${PGID} ${USER_PATH}

SYS_DEBUG=$(printenv "sys.debug")
SYS_HOST=$(printenv "sys.host")
SYS_API_ROUTE=$(printenv "sys.apiRoute")
SYS_PROXY=$(printenv "sys.proxy")
SYS_LANGUAGE=$(printenv "sys.language")
SYS_THEME=$(printenv "sys.theme")
BIU_SEARCH_MAX_THREADS=$(printenv "biu.search.maxThreads")
BIU_SEARCH_LOAD_CACHE_FIRST=$(printenv "biu.search.loadCacheFirst")
BIU_SEARCH_MAX_CACHE_SIZE_MIB=$(printenv "biu.search.maxCacheSizeMiB")
BIU_DOWNLOAD_MODE=$(printenv "biu.download.mode")
BIU_DOWNLOAD_ARIA2_HOST=$(printenv "biu.download.aria2Host")
BIU_DOWNLOAD_ARIA2_SECRET=$(printenv "biu.download.aria2Secret")
BIU_DOWNLOAD_DETER_PATHS=$(printenv "biu.download.deterPaths")
BIU_DOWNLOAD_MAX_DOWNLOADING=$(printenv "biu.download.maxDownloading")
BIU_DOWNLOAD_SAVE_URI=$(printenv "biu.download.saveURI")
BIU_DOWNLOAD_SAVE_FILE_NAME=$(printenv "biu.download.saveFileName")
BIU_DOWNLOAD_AUTO_ARCHIVE=$(printenv "biu.download.autoArchive")
BIU_DOWNLOAD_WHATS_UGOIRA=$(printenv "biu.download.whatsUgoira")
BIU_DOWNLOAD_IMAGE_HOST=$(printenv "biu.download.imageHost")
SECRET_KEY_API_SAUCENAO=$(printenv "secret.key.apiSauceNAO")


if [ -n "$HTTP_PROXY" ]; then
    echo "设置HTTP代理为 $HTTP_PROXY"
    export http_proxy=$HTTP_PROXY
    export https_proxy=$HTTP_PROXY
    if [ -n "$SYS_PROXY" ]; then
        
    else
        SYS_PROXY=$HTTP_PROXY
    fi
else
    if [ -n "$HTTPS_PROXY" ]; then
        echo "设置HTTPS代理为 $HTTPS_PROXY"
        export http_proxy=$HTTPS_PROXY
        export https_proxy=$HTTPS_PROXY
        if [ -n "$SYS_PROXY" ]; then
            
        else
            SYS_PROXY=$HTTPS_PROXY
        fi
    fi
fi

args=()

# 处理 sys.host
if [ -n "$PROT" ]; then
    args+=("sys.host=0.0.0.0:$PROT")
fi

# 处理 sys.apiRoute
if [ -n "$SYS_API_ROUTE" ]; then
    args+=("sys.apiRoute=$SYS_API_ROUTE")
fi

# 处理 sys.proxy
if [ -n "$SYS_PROXY" ]; then
    args+=("sys.proxy=$SYS_PROXY")
fi

# 处理 sys.language
if [ -n "$SYS_LANGUAGE" ]; then
    args+=("sys.language=$SYS_LANGUAGE")
fi

# 处理 sys.theme
if [ -n "$SYS_THEME" ]; then
    args+=("sys.theme=$SYS_THEME")
fi

# 处理 biu.search.maxThreads
if [ -n "$BIU_SEARCH_MAX_THREADS" ]; then
    args+=("biu.search.maxThreads=$BIU_SEARCH_MAX_THREADS")
fi

# 处理 biu.search.loadCacheFirst
if [ -n "$BIU_SEARCH_LOAD_CACHE_FIRST" ]; then
    args+=("biu.search.loadCacheFirst=$BIU_SEARCH_LOAD_CACHE_FIRST")
fi

# 处理 biu.search.maxCacheSizeMiB
if [ -n "$BIU_SEARCH_MAX_CACHE_SIZE_MIB" ]; then
    args+=("biu.search.maxCacheSizeMiB=$BIU_SEARCH_MAX_CACHE_SIZE_MIB")
fi

# 处理 biu.download.mode
if [ -n "$BIU_DOWNLOAD_MODE" ]; then
    args+=("biu.download.mode=$BIU_DOWNLOAD_MODE")
fi

# 处理 biu.download.aria2Host
if [ -n "$BIU_DOWNLOAD_ARIA2_HOST" ]; then
    args+=("biu.download.aria2Host=$BIU_DOWNLOAD_ARIA2_HOST")
fi

# 处理 biu.download.aria2Secret
if [ -n "$BIU_DOWNLOAD_ARIA2_SECRET" ]; then
    args+=("biu.download.aria2Secret=$BIU_DOWNLOAD_ARIA2_SECRET")
fi

# 处理 biu.download.deterPaths
if [ -n "$BIU_DOWNLOAD_DETER_PATHS" ]; then
    args+=("biu.download.deterPaths=$BIU_DOWNLOAD_DETER_PATHS")
fi

# 处理 biu.download.maxDownloading
if [ -n "$BIU_DOWNLOAD_MAX_DOWNLOADING" ]; then
    args+=("biu.download.maxDownloading=$BIU_DOWNLOAD_MAX_DOWNLOADING")
fi

# 处理 biu.download.saveURI
if [ -n "$BIU_DOWNLOAD_SAVE_URI" ]; then
    args+=("biu.download.saveURI=$BIU_DOWNLOAD_SAVE_URI")
fi

# 处理 biu.download.saveFileName
if [ -n "$BIU_DOWNLOAD_SAVE_FILE_NAME" ]; then
    args+=("biu.download.saveFileName=$BIU_DOWNLOAD_SAVE_FILE_NAME")
fi

# 处理 biu.download.autoArchive
if [ -n "$BIU_DOWNLOAD_AUTO_ARCHIVE" ]; then
    args+=("biu.download.autoArchive=$BIU_DOWNLOAD_AUTO_ARCHIVE")
fi

# 处理 biu.download.whatsUgoira
if [ -n "$BIU_DOWNLOAD_WHATS_UGOIRA" ]; then
    args+=("biu.download.whatsUgoira=$BIU_DOWNLOAD_WHATS_UGOIRA")
fi

# 处理 biu.download.imageHost
if [ -n "$BIU_DOWNLOAD_IMAGE_HOST" ]; then
    args+=("biu.download.imageHost=$BIU_DOWNLOAD_IMAGE_HOST")
fi

# 处理 secret.key.apiSauceNAO
if [ -n "$SECRET_KEY_API_SAUCENAO" ]; then
    args+=("secret.key.apiSauceNAO=$SECRET_KEY_API_SAUCENAO")
fi

# 然后执行命令
exec sudo -u "#$PUID" -g "#$PGID" \
    "${args[@]}" \
    /Pixiv/main