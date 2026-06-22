# Docker_Buildx_PixivBiu

[DockerHub](https://hub.docker.com/r/zzcabc/pixivbiu) | [GitHub](https://github.com/zzcabc/Docker_Buildx_PixivBiu)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/txperl/PixivBiu?label=PixivBiu&style=flat-square)](https://github.com/txperl/PixivBiu/releases/latest)[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/zzcabc/pixivbiu?label=Docker&style=flat-square)](https://hub.docker.com/r/zzcabc/pixivbiu/tags?page=1&ordering=last_updated) [![Docker Pulls](https://img.shields.io/docker/pulls/zzcabc/pixivbiu?style=flat-square)](https://hub.docker.com/r/zzcabc/pixivbiu)


本项目使用 Docker Buildx 构建全平台镜像，支持 `linux/amd64`、`linux/armv8` 框架，不再对 `linux/386`、`linux/armv6`、`linux/armv7`、`linux/ppc64le`、`linux/s390x` 架构提供支持。

**ARM64暂时构建出现问题**



使用 GitHub Action 在 **UTC+8 00:00** 自动拉取 [txperl/PixivBiu](https://github.com/txperl/PixivBiu) 的源码进行构建 Docker 镜像，**但当源码版本和 Docker 镜像版本一致将不会构建镜像**，总的构建时间大约需要 **3 分钟**。

## 因txperl瞎jb重构项目，仅提供基础的docker命令，具体环境变量请查询项目说明


### ~~国内镜像地址~~ (我推送不上去)

- 将 `zzcabc/pixivbiu:latest` 换成 `ghcr.io/zzcabc/pixivbiu:latest`

```sh
docker run -itd \
    --name pixivbiu \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    -p 本机端口:4001 \
    -v 本机路径:/Pixiv/downloads \
    zzcabc/pixivbiu
```