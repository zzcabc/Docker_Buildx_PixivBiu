FROM python:3.7.12
WORKDIR /PixivBiu
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    apt update && \
    apt install git && \
    cd PixivBiu && \
    git clone https://github.com/txperl/PixivBiu.git && \
    pip install -r requirements.txt 
EXPOSE 4001
VOLUME /PixivBiu/config.yml /PixivBiu/download
ENTRYPOINT ["python","main.py"]