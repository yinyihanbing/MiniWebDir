# ggweb

## 下载源码
git clone -b ggweb https://github.com/yinyihanbing/MiniWebDir.git ggweb

## 這個命令會移除所有未使用的建置快取資料
docker builder prune
## 打包镜像
docker build --no-cache -t ggweb .
## 查看所有镜像
docker images
## 运行镜像
docker run ggweb
## 5