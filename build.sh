#! /bin/sh

set -e

WEAVE_VERSION=${WEAVE_VERSION:-latest}
IMAGE_VERSION=${IMAGE_VERSION:-$WEAVE_VERSION}

if ! grep -q "FROM.*$WEAVE_VERSION" image/Dockerfile ; then
    echo "WEAVE_VERSION does not match image/Dockerfile"
    exit 1
fi

# Build helper program
go build -i -o image/kube-peers -ldflags "-linkmode external -extldflags -static" ./kube-peers

# Extract other files we need
NAME=weave-kube-$$
$SUDO docker create --name=$NAME weaveworks/weave:$WEAVE_VERSION
$SUDO docker cp $NAME:/home/weave/weaver image
$SUDO docker cp $NAME:/weavedb/weavedata.db image
$SUDO docker cp $NAME:/etc/ssl/certs/ca-certificates.crt image
$SUDO docker rm $NAME

# Build the end product
$SUDO docker build -t weaveworks/weave-kube:$IMAGE_VERSION image
