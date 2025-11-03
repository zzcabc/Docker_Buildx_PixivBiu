#!/bin/bash
set -e
BASE_URI="0.0.0.0"
PORT=4001
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
SYS_API_ROUTE=$(get_env "sys.apiRoute")
SYS_PROXY=$(get_env "sys.proxy")
SYS_LANGUAGE=$(get_env "sys.language")
SYS_THEME=$(get_env "sys.theme")
BIU_SEARCH_MAX_THREADS=$(get_env "biu.search.maxThreads")
BIU_SEARCH_LOAD_CACHE_FIRST=$(get_env "biu.search.loadCacheFirst")
BIU_SEARCH_MAX_CACHE_SIZE_MIB=$(get_env "biu.search.maxCacheSizeMiB")
BIU_DOWNLOAD_MODE=$(get_env "biu.download.mode")
BIU_DOWNLOAD_ARIA2_HOST=$(get_env "biu.download.aria2Host")
BIU_DOWNLOAD_ARIA2_SECRET=$(get_env "biu.download.aria2Secret")
BIU_DOWNLOAD_DETER_PATHS=$(get_env "biu.download.deterPaths")
BIU_DOWNLOAD_MAX_DOWNLOADING=$(get_env "biu.download.maxDownloading")
BIU_DOWNLOAD_SAVE_URI=$(get_env "biu.download.saveURI")
BIU_DOWNLOAD_SAVE_FILE_NAME=$(get_env "biu.download.saveFileName")
BIU_DOWNLOAD_AUTO_ARCHIVE=$(get_env "biu.download.autoArchive")
BIU_DOWNLOAD_WHATS_UGOIRA=$(get_env "biu.download.whatsUgoira")
BIU_DOWNLOAD_IMAGE_HOST=$(get_env "biu.download.imageHost")
SECRET_KEY_API_SAUCENAO=$(get_env "secret.key.apiSauceNAO")
echo "Ready to start PixivBiu with environment variable configurations."
echo "sys.debug=$SYS_DEBUG"
echo "sys.apiRoute=$SYS_API_ROUTE"
echo "sys.proxy=$SYS_PROXY"
echo "sys.language=$SYS_LANGUAGE"
echo "sys.theme=$SYS_THEME"
echo "biu.search.maxThreads=$BIU_SEARCH_MAX_THREADS"
echo "biu.search.loadCacheFirst=$BIU_SEARCH_LOAD_CACHE_FIRST"
echo "biu.search.maxCacheSizeMiB=$BIU_SEARCH_MAX_CACHE_SIZE_MIB"
echo "biu.download.mode=$BIU_DOWNLOAD_MODE"
echo "biu.download.aria2Host=$BIU_DOWNLOAD_ARIA2_HOST"
echo "biu.download.aria2Secret=$BIU_DOWNLOAD_ARIA2_SECRET"
echo "biu.download.deterPaths=$BIU_DOWNLOAD_DETER_PATHS"
echo "biu.download.maxDownloading=$BIU_DOWNLOAD_MAX_DOWNLOADING"
echo "biu.download.saveURI=$BIU_DOWNLOAD_SAVE_URI"
echo "biu.download.saveFileName=$BIU_DOWNLOAD_SAVE_FILE_NAME"
echo "biu.download.autoArchive=$BIU_DOWNLOAD_AUTO_ARCHIVE"
echo "biu.download.whatsUgoira=$BIU_DOWNLOAD_WHATS_UGOIRA"
echo "biu.download.imageHost=$BIU_DOWNLOAD_IMAGE_HOST"
echo "secret.key.apiSauceNAO=$SECRET_KEY_API_SAUCENAO"


# 如果配置文件不存在，则创建一个新的
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default config file at $CONFIG_FILE"
    echo "sys.host:\"${BASE_URI}:${PORT}\"" >> "$CONFIG_FILE"

    if [ -n "$SYS_DEBUG" ]; then
        echo "sys.debug:${SYS_DEBUG:-false}" >> "$CONFIG_FILE"
    fi
    if [ -n "$SYS_API_ROUTE" ]; then
        echo "sys.apiRoute:\"${SYS_API_ROUTE}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$SYS_PROXY" ]; then
        echo "sys.proxy:\"${SYS_PROXY}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$SYS_LANGUAGE" ]; then
        echo "sys.language:\"${SYS_LANGUAGE}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$SYS_THEME" ]; then
        echo "sys.theme:\"${SYS_THEME}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_SEARCH_MAX_THREADS" ]; then
        echo "biu.search.maxThreads:${BIU_SEARCH_MAX_THREADS:-8}" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_SEARCH_LOAD_CACHE_FIRST" ]; then
        echo "biu.search.loadCacheFirst:${BIU_SEARCH_LOAD_CACHE_FIRST:-true}" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_SEARCH_MAX_CACHE_SIZE_MIB" ]; then
        echo "biu.search.maxCacheSizeMiB:${BIU_SEARCH_MAX_CACHE_SIZE_MiB:-512}" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_MODE" ]; then
        echo "biu.download.mode:\"${BIU_DOWNLOAD_MODE}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_ARIA2_HOST" ]; then
        echo "biu.download.aria2Host:\"${BIU_DOWNLOAD_ARIA2_HOST}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_ARIA2_SECRET" ]; then
        echo "biu.download.aria2Secret:\"${BIU_DOWNLOAD_ARIA2_SECRET}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_DETER_PATHS" ]; then
        echo "biu.download.deterPaths:${BIU_DOWNLOAD_DETER_PATHS:-true}" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_MAX_DOWNLOADING" ]; then
        echo "biu.download.maxDownloading:${BIU_DOWNLOAD_MAX_DOWNLOADING:-8}" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_SAVE_URI" ]; then
        echo "biu.download.saveURI:\"${BIU_DOWNLOAD_SAVE_URI}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_SAVE_FILE_NAME" ]; then
        echo "biu.download.saveFileName:\"${BIU_DOWNLOAD_SAVE_FILE_NAME}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_AUTO_ARCHIVE" ]; then
        echo "biu.download.autoArchive:${BIU_DOWNLOAD_AUTO_ARCHIVE:-true}" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_WHATS_UGOIRA" ]; then
        echo "biu.download.whatsUgoira:\"${BIU_DOWNLOAD_WHATS_UGOIRA}\"" >> "$CONFIG_FILE"
    fi
    if [ -n "$BIU_DOWNLOAD_IMAGE_HOST" ]; then
        echo "biu.download.imageHost:\"${BIU_DOWNLOAD_IMAGE_HOST}\""  >> "$CONFIG_FILE"
    fi
    if [ -n "$SECRET_KEY_API_SAUCENAO" ]; then
        echo "secret.key.apiSauceNAO:\"${SECRET_KEY_API_SAUCENAO}\"" >> "$CONFIG_FILE"
    fi
    chown ${PUID}:${PGID} "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    echo "Default config file created."
    echo "Starting PixivBiu..."
    echo "Final config.yml:"
    cat "$CONFIG_FILE"
    exec sudo -u "#$PUID" -g "#$PGID" /Pixiv/main
else
    echo "Config file $CONFIG_FILE already exists. Skipping creation."
    # 清空位置参数
    set --
    # 对于每个参数，只有当对应的环境变量有值时才添加
    if [ -n "$PORT" ]; then
        set -- "$@" "sys.host=$BASE_URI:$PORT"
    fi

    if [ -n "$SYS_API_ROUTE" ]; then
        set -- "$@" "sys.apiRoute=$SYS_API_ROUTE"
    fi

    if [ -n "$SYS_PROXY" ]; then
        set -- "$@" "sys.proxy=$SYS_PROXY"
    fi

    if [ -n "$SYS_LANGUAGE" ]; then
        set -- "$@" "sys.language=$SYS_LANGUAGE"
    fi

    if [ -n "$SYS_THEME" ]; then
        set -- "$@" "sys.theme=$SYS_THEME"
    fi

    if [ -n "$BIU_SEARCH_MAX_THREADS" ]; then
        set -- "$@" "biu.search.maxThreads=$BIU_SEARCH_MAX_THREADS"
    fi

    if [ -n "$BIU_SEARCH_LOAD_CACHE_FIRST" ]; then
        set -- "$@" "biu.search.loadCacheFirst=$BIU_SEARCH_LOAD_CACHE_FIRST"
    fi

    if [ -n "$BIU_SEARCH_MAX_CACHE_SIZE_MIB" ]; then
        set -- "$@" "biu.search.maxCacheSizeMiB=$BIU_SEARCH_MAX_CACHE_SIZE_MIB"
    fi

    if [ -n "$BIU_DOWNLOAD_MODE" ]; then
        set -- "$@" "biu.download.mode=$BIU_DOWNLOAD_MODE"
    fi

    if [ -n "$BIU_DOWNLOAD_ARIA2_HOST" ]; then
        set -- "$@" "biu.download.aria2Host=$BIU_DOWNLOAD_ARIA2_HOST"
    fi

    if [ -n "$BIU_DOWNLOAD_ARIA2_SECRET" ]; then
        set -- "$@" "biu.download.aria2Secret=$BIU_DOWNLOAD_ARIA2_SECRET"
    fi

    if [ -n "$BIU_DOWNLOAD_DETER_PATHS" ]; then
        set -- "$@" "biu.download.deterPaths=$BIU_DOWNLOAD_DETER_PATHS"
    fi

    if [ -n "$BIU_DOWNLOAD_MAX_DOWNLOADING" ]; then
        set -- "$@" "biu.download.maxDownloading=$BIU_DOWNLOAD_MAX_DOWNLOADING"
    fi

    if [ -n "$BIU_DOWNLOAD_SAVE_URI" ]; then
        set -- "$@" "biu.download.saveURI=$BIU_DOWNLOAD_SAVE_URI"
    fi

    if [ -n "$BIU_DOWNLOAD_SAVE_FILE_NAME" ]; then
        set -- "$@" "biu.download.saveFileName=$BIU_DOWNLOAD_SAVE_FILE_NAME"
    fi

    if [ -n "$BIU_DOWNLOAD_AUTO_ARCHIVE" ]; then
        set -- "$@" "biu.download.autoArchive=$BIU_DOWNLOAD_AUTO_ARCHIVE"
    fi

    if [ -n "$BIU_DOWNLOAD_WHATS_UGOIRA" ]; then
        set -- "$@" "biu.download.whatsUgoira=$BIU_DOWNLOAD_WHATS_UGOIRA"
    fi

    if [ -n "$BIU_DOWNLOAD_IMAGE_HOST" ]; then
        set -- "$@" "biu.download.imageHost=$BIU_DOWNLOAD_IMAGE_HOST"
    fi

    if [ -n "$SECRET_KEY_API_SAUCENAO" ]; then
        set -- "$@" "secret.key.apiSauceNAO=$SECRET_KEY_API_SAUCENAO"
    fi

    echo "Starting PixivBiu..."
    echo "Final command arguments:$@"
    exec sudo -u "#$PUID" -g "#$PGID" "$@" /Pixiv/main
fi