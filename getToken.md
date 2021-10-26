第一步：访问https://app-api.pixiv.net/web/v1/login?code_challenge=g0i2R7R7AvhAZBGCgIzoGjex23IOMM_szMvqzOBCpso&code_challenge_method=S256&client=pixiv-android

第二步： 打开浏览器的「Dev Console / 开发者工具 / F12」，切换至「Network / 网络」标签

第三步：开启「Preserve log / 持续记录」

第四步：在「Filter / 筛选」文本框中输入「callback?

第五步：登录您的 Pixiv 账号

第六步：成功登录后，会出现一个类似「https://app-api.pixiv.net/.../callback?state=...&code=****************」的字段

第七步：将复制code后面*******，复制到.token.json的对应位置