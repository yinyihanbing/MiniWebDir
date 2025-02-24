#!/bin/bash

cd "$(dirname "$0")"

cd ../dok

docker-compose stop ggweb

docker-compose rm ggweb

cd ../ggweb

git pull

docker builder prune

docker build --no-cache -t ggweb .

docker tag ggweb:latest yinyihanbing/ggweb:0.0.1

docker rmi ggweb

docker push yinyihanbing/ggweb:0.0.1

cd ../dok

docker-compose up -d ggweb

