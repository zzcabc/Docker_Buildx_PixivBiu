#!/bin/sh
set -e

# 环境变量默认值
PIXIVBIU_SERVER_HOST="${PIXIVBIU_SERVER_HOST:-0.0.0.0}"
PIXIVBIU_SERVER_PORT="${PIXIVBIU_SERVER_PORT:-4001}"
DOWNLOAD_PATH="/Pixiv/downloads"
USER_PATH="/Pixiv/usr"
CONFIG_FILE="/Pixiv/config.yml"

UMASK="${UMASK:-022}"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

# 设置 umask
umask "${UMASK}"

echo "Starting PixivBiu with PUID:PGID = ${PUID}:${PGID}, UMASK = ${UMASK}"

# 创建用户和组（仅当 PUID 或 PGID 非 0 时）
if [ "${PUID}" -ne 0 ] || [ "${PGID}" -ne 0 ]; then
    # 检查组是否存在，若不存在则创建
    if ! getent group "${PGID}" >/dev/null 2>&1; then
        addgroup -g "${PGID}" -S appgroup
    fi
    # 检查用户是否存在，若不存在则创建
    if ! getent passwd "${PUID}" >/dev/null 2>&1; then
        adduser -u "${PUID}" -G appgroup -S -D -h /Pixiv appuser
    fi
fi

# 确保目录存在
mkdir -p "${DOWNLOAD_PATH}" "${USER_PATH}"
echo "Ensured directories: ${DOWNLOAD_PATH}, ${USER_PATH}"

# 设置目录所有权（如果需要）
if [ "${PUID}" -ne 0 ] || [ "${PGID}" -ne 0 ]; then
    chown -R "${PUID}:${PGID}" "${DOWNLOAD_PATH}" "${USER_PATH}"
    echo "Set ownership to ${PUID}:${PGID} for data directories"
fi

# 如果存在配置文件，也一并修改权限（可选）
[ -f "${CONFIG_FILE}" ] && chown "${PUID}:${PGID}" "${CONFIG_FILE}"

# 切换用户并执行程序
if [ "${PUID}" -eq 0 ] && [ "${PGID}" -eq 0 ]; then
    # 以 root 直接运行
    exec /Pixiv/pixivbiu
else
    # 使用 su-exec 切换用户执行
    exec su-exec "${PUID}:${PGID}" /Pixiv/pixivbiu
fi