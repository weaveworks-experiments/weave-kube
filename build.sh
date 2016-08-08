#! /bin/sh

set -e

IMAGE_VERSION=latest
IMAGE_VERSION=${WEAVE_VERSION:-$IMAGE_VERSION}

# Build helper program
go build -i -o image/kube-peers -ldflags "-extldflags -static" ./kube-peers

# Extract other files we need
NAME=weave-kube-$$
docker create --name=$NAME weaveworks/weave:$WEAVE_VERSION
docker cp $NAME:/home/weave/weaver image
docker cp $NAME:/weavedb/weavedata.db image
docker cp $NAME:/etc/ssl/certs/ca-certificates.crt image
docker rm $NAME

# Build the end product
docker build -t weaveworks/weave-kube:$IMAGE_VERSION image
