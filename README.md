# [Docker_Buildx_PixivBiu](https://https://hub.docker.com/r/zzcabc/pixivbiu) <-点击跳转DockerHub


[![GitHub release (latest by date)](https://img.shields.io/github/v/release/txperl/PixivBiu?label=danmuji&style=flat-square)](https://github.com/txperl/PixivBiu/releases/latest) [![Docker Image Version (latest by date)](https://img.shields.io/docker/v/zzcabc/danmuji?label=DockerHub&style=flat-square)](https://hub.docker.com/r/zzcabc/danmuji/tags?page=1&ordering=last_updated)
### 如果你发现上面图标版本不一致，请点击一下star，这样会触发自动构建镜像，即使你之后取消star


本项目使用Docker Buildx构建全平台镜像，支持linux/386、linux/amd64、linux/armv5、linux/armv7、linux/armv8、linux/ppc64le、linux/s390x框架，并使用python:3.7.12作为底包


使用GitHub Action中国时间 **0:00** 自动拉取[txperl/PixivBiu](https://github.com/txperl/PixivBiu)的源码进行构建Docker镜像，**但当源码版本和Docker镜像版本一致将不会构建镜像**，由源码构建时间大概4分钟

**使用方式**

```sh
docker run -d \
    --name pixivbiu \
    -p 本机端口:4001 \
    -v 本机路径:/PixivBiu/config.yml \
    -v 本机路径:/PixivBiu/downloads \
    -v 本级路径:/PivixBiu/usr/.token.json \
    zzcabc/pixivbiu:latest
```

**映射路径说明** 

此说明对应Docker容器内

/PixivBiu/config.yml                 配置文件

/PixivBiu/downloads                  图片下载地址

/PivixBiu/usr/.token.json            Token 存放位置
