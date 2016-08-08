#!/bin/sh

set -e

/home/weave/weave --local setup-cni
/home/weave/weave --local create-bridge

exec /home/weave/weaver --port=6783 --datapath=datapath \
     --http-addr=127.0.0.1:6784 --docker-api='' --no-dns \
     --ipalloc-range=10.244.0.0/14 \
     --name=$(cat /sys/class/net/weave/address) $(/home/weave/kube-peers)
