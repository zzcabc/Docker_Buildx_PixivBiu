#!/bin/sh
set -e

UID=`id -u`
GID=`id -g`


echo
echo "UID: $UID"
echo "GID: $GID"
echo

echo "Setting conf"

touch /config/aria2.session

if [[ ! -e /config/aria2.conf ]]
then
  cp /aria2.conf.default /config/aria2.conf
fi

echo "[DONE]"

echo "Setting owner and permissions"

chown -R $UID:$GID /config
find /config -type d -exec chmod 755 {} +
find /config -type f -exec chmod 644 {} +

echo "[DONE]"

echo "Starting aria2c"

exec aria2c \
    --conf-path=/config/aria2.conf \
  > /dev/stdout \
  2 > /dev/stderr

echo 'Exiting aria2'

nohup /Pixiv/main &



