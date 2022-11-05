# Docker_Buildx_PixivBiu

前往[Dockerhub](https://hub.docker.com/r/zzcabc/pixivbiu)  前往[Github](https://github.com/zzcabc/Docker_Buildx_PixivBiu)

这是GitHub的版本[![GitHub release (latest by date)](https://img.shields.io/github/v/release/txperl/PixivBiu?label=PixivBiu&style=flat-square)](https://github.com/txperl/PixivBiu/releases/latest) 
 这是Docker Hub的版本[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/zzcabc/pixivbiu?label=DockerHub&style=flat-square)](https://hub.docker.com/r/zzcabc/pixivbiu/tags?page=1&ordering=last_updated)


本项目使用Docker Buildx构建全平台镜像，支持linux/amd64、linux/armv7、linux/armv8框架；不再对linux/386、linux/armv6、linux/ppc64le、linux/s390x架构支持

|构建方式|底包采用|Amd64镜像大小|
|--|--|--|
|pyinstaller|alpine:latest|39.1M|
|源码构建|python:alpine3.14|200M|

使用GitHub Action在中国时间 **0:00** 自动拉取[txperl/PixivBiu](https://github.com/txperl/PixivBiu)的源码进行构建Docker镜像，**但当源码版本和Docker镜像版本一致将不会构建镜像**，构建时间大约需要**30分钟**

# 使用方式

在启动镜像之前，你需要准备[.token.json](https://github.com/zzcabc/Docker_Buildx_PixivBiu/blob/master/.token.json)的用户登录token
**请使用客户端获取.token.json文件**

**注意，某些环境变量不建议修改**

| 环境变量 | 注意事项 |
| ---    |  ---       |
|`-e sys.host="0.0.0.0:4001"` |如果你想在docker外访问，请不要传入改环境变量|
|`-e sys.autoOpen=false`|反正docker内也没提供浏览器窗口，所以这项传了没用|
|`-e sys.ignoreOutdated=true`|你敢改为`false`，容器就敢不启动|
|`-e biu.download.saveURI="{ROOTPATH}/downloads/{KT}/"`| 如果不使用aria2，**`{ROOTPATH}/downloads`是不能修改**|
|`-e biu.download.saveURI="{ROOTPATH}/downloads/{KT}/"`| 使用aria2，请**改为`/downloads`**|

## pyinstaller构建镜像的使用方式（默认拉取）

### 国内镜像地址：将 `zzcabc/pixivbiu:latest` 换成 `registry.cn-hangzhou.aliyuncs.com/zzcabc/pixivbiu:latest`

```sh
docker run -d \
    --name pixivbiu \
    --user $(id -u):$(id -g) \
    -p 本机端口:4001 \
    -v 本机路径:/Pixiv/config.yml \
    -v 本机路径:/Pixiv/downloads \
    -v 本机路径:/Pixiv/usr/.token.json \
    zzcabc/pixivbiu
```

### 环境变量具体参照[源码的配置](https://github.com/txperl/PixivBiu/blob/master/app/config/biu_default.yml)使用了环境变量创建容器，可用不需要传入config.yml

#### 如果你使用环境变量传配置，请自行修改下方 ` -e ` 中的内容
```sh
docker run -d \
    --name pixivbiu \
    --user $(id -u):$(id -g) \
    -p 本机端口:4001 \
    -e sys.debug=false \
    -e sys.apiRoute="direct" \
    -e sys.proxy="" \
    -e sys.language="" \
    -e sys.theme="multiverse" \
    -e biu.search.maxThreads=8 \
    -e biu.search.loadCacheFirst=true \
    -e biu.download.mode="dl-single" \
    -e biu.download.aria2Host="localhost:6800" \
    -e biu.download.aria2Secret="" \
    -e biu.download.deterPaths=true \
    -e biu.download.maxDownloading=8 \
    -e biu.download.saveURI="{ROOTPATH}/downloads/{date_today}/" \
    -e biu.download.saveFileName="{title}_{work_id}" \
    -e biu.download.autoArchive=true \
    -e biu.download.whatsUgoira=webp \
    -e biu.download.imageHost="" \
    -e secret.key.apiSauceNAO="" \
    -v 本机路径:/Pixiv/downloads \
    -v 本机路径:/Pixiv/usr/.token.json \
    zzcabc/pixivbiu
```

### 同样你也可以使用默认的配置形式启动容器

```sh
docker run -d \
    --name pixivbiu \
    --user $(id -u):$(id -g) \
    -p 本机端口:4001 \
    -v 本机路径:/Pixiv/downloads \
    -v 本机路径:/Pixiv/usr/.token.json \
    zzcabc/pixivbiu
```

## 源码编译构建镜像的使用方式

### 国内镜像地址：将 `zzcabc/pixivbiu:latest-src` 换成 `registry.cn-hangzhou.aliyuncs.com/zzcabc/pixivbiu:latest-src`

```sh
docker run -d \
    --name pixivbiu \
    --user $(id -u):$(id -g) \
    -p 本机端口:4001 \
    -v 本机路径:/Pixiv/config.yml \
    -v 本机路径:/Pixiv/downloads \
    -v 本机路径:/Pixiv/usr/.token.json \
    zzcabc/pixivbiu:latest-src
```

### 环境变量具体参照[源码的配置](https://github.com/txperl/PixivBiu/blob/master/app/config/biu_default.yml)使用了环境变量创建容器，可用不需要传入config.yml

#### 如果你使用环境变量传配置，请自行修改下方 ` -e ` 中的内容
```sh
docker run -d \
    --name pixivbiu \
    --user $(id -u):$(id -g) \
    -p 本机端口:4001 \
    -e sys.debug=false \
    -e sys.apiRoute="direct" \
    -e sys.proxy="" \
    -e sys.language="" \
    -e sys.theme="multiverse" \
    -e biu.search.maxThreads=8 \
    -e biu.search.loadCacheFirst=true \
    -e biu.download.mode="dl-single" \
    -e biu.download.aria2Host="localhost:6800" \
    -e biu.download.aria2Secret="" \
    -e biu.download.deterPaths=true \
    -e biu.download.maxDownloading=8 \
    -e biu.download.saveURI="{ROOTPATH}/downloads/{date_today}/" \
    -e biu.download.saveFileName="{title}_{work_id}" \
    -e biu.download.autoArchive=true \
    -e biu.download.whatsUgoira=webp \
    -e biu.download.imageHost="" \
    -e secret.key.apiSauceNAO="" \
    -v 本机路径:/Pixiv/downloads \
    -v 本机路径:/Pixiv/usr/.token.json \
    zzcabc/pixivbiu:latest-src
```

### 同样你也可以使用默认的配置形式启动容器

```sh
docker run -d \
    --name pixivbiu \
    --user $(id -u):$(id -g) \
    -p 本机端口:4001 \
    -v 本机路径:/Pixiv/downloads \
    -v 本机路径:/Pixiv/usr/.token.json \
    zzcabc/pixivbiu:latest-src
```

# 映射路径说明

此说明对应Docker容器内

`/Pixiv/downloads`                  图片下载地址

`/Pixiv/config.yml`                 配置文件(有环境变量即可不用传入)

`/Pixiv/usr/.token.json`            Token 存放位置(必须映射)

# Aria的使用方法

## Aria镜像

### 推荐使用p3terx的Aria2Pro

### SECRET不配置默认为p3terx

```sh
docker run -d \
    --name aria2-pro \
    --restart unless-stopped \
    --log-opt max-size=1m \
    -e PUID=$UID \
    -e PGID=$GID \
    -e UMASK_SET=022 \
    -e RPC_SECRET=<TOKEN> \
    -e RPC_PORT=6800 \
    -e LISTEN_PORT=6888 \
    -p 6800:6800 \
    -p 6888:6888 \
    -p 6888:6888/udp \
    -v 本地路径/aria2-config:/config \
    -v 本地路径/aria2-downloads:/downloads \
    p3terx/aria2-pro
```

## 使用Aria需要更改的地方

`biu.download.mode`         为  `aria2`

`biu.download.aria2Host`    为  `aria的ip:6800`

`biu.download.aria2Secret`  为  `aria的secret`

`biu.download.saveURI`      为  `/downloads`

# ~[测试地址](https://hub.docker.com/r/zzcabc/pixivbiu-test)~

# TODO

- [x] 精简镜像大小

- [ ] 内置Aria2

- [x] 上传阿里镜像仓库
