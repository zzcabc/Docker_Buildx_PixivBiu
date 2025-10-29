#!/bin/sh
set -e

DOWNLOAD_PATH=/Pixiv/downlaods

chown -R ${PUID}:${PGID} ${DOWNLOAD_PATH}

umask ${UMASK}

exec sudo -u "#$PUID" -g "#$PGID" /Pixiv/main
