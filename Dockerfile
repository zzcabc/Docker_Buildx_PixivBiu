FROM python:3.7.12
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    apt update && \
    apt install git && \
    git clone https://github.com/txperl/PixivBiu.git && \
    /usr/local/bin/python -m pip install --upgrade pip && \
    cd /PixivBiu && \
    pip install -r requirements.txt 
WORKDIR PixivBiu
EXPOSE 4001
VOLUME /PixivBiu/config.yml /PixivBiu/downloads /PixivBiu/usr/.token.json
ENTRYPOINT ["python","main.py"]