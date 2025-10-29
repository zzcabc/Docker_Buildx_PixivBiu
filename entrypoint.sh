#!/bin/sh
set -e

# 设置默认值
sys.host=${sys.host:-"0.0.0.0:4001"}
sys.autoOpen=${sys.autoOpen:-"false"}
sys.ignoreOutdated=${sys.ignoreOutdated:-"true"}

ENV sys.host="0.0.0.0:4001"
ENV sys.autoOpen=false
ENV sys.ignoreOutdated=true


# 如果指定了非root用户ID，切换到相应用户
if [ -n "$PUID" ] && [ "$PUID" != "0" ]; then
    # 确保用户和组存在
    if ! getent group "$PGID" > /dev/null 2>&1; then
        addgroup --system --gid "$PGID" appuser
    fi
    
    if ! getent passwd "$PUID" > /dev/null 2>&1; then
        adduser --system --disabled-password --no-create-home --uid "$PUID" --gid "$PGID" appuser
    fi
    
    # 更改文件所有权
    chown -R "$PUID:$PGID" /Pixiv /data 2>/dev/null || true
    
    # 使用 setpriv 来切换用户（Debian 自带工具）
    if command -v setpriv >/dev/null 2>&1; then
        # 使用 setpriv 切换用户（更安全的方式）
        exec setpriv --reuid "$PUID" --regid "$PGID" --init-groups /Pixiv/main
    else
        # 回退到使用 sudo（如果可用）
        if command -v sudo >/dev/null 2>&1; then
            exec sudo -u "#$PUID" -g "#$PGID" /Pixiv/main
        else
            # 最后回退到使用 su
            exec su -s /bin/sh -c "exec /Pixiv/main appuser
        fi
    fi
else
    # 使用root运行
    exec /app/main
fi