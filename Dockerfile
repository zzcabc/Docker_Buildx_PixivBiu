FROM python:3.7.12-alpine3.14
RUN apk add -U --no-cache tzdata git gcc libc-dev linux-headers jpeg-dev zlib-dev && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    git clone --depth=1 https://github.com/txperl/PixivBiu.git && \
    cd /PixivBiu && \
    rm config.yml && \
    pip install -r requirements.txt && \
    apk del tzdata git libc-dev linux-headers && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    rm -rf /tmp/*
WORKDIR /PixivBiu
EXPOSE 4001
VOLUME /PixivBiu/downloads /PixivBiu/config.yml /PixivBiu/usr/.token.json
ENTRYPOINT ["python","main.py"]