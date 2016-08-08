#!/bin/sh

set -e

# Create CNI config, if not already there
if [ ! -f /etc/cni/net.d/10-weave.conf ] ; then
    mkdir -p /etc/cni/net.d
    cat > /etc/cni/net.d/10-weave.conf <<EOF
{
    "name": "weave",
    "type": "weave-net"
}
EOF
fi

# Copy CNI plugin binary
if [ ! -f /opt/cni/bin/weave-net ] ; then
    mkdir -p /opt/cni/bin
    cp /home/weave/plugin /opt/cni/bin/weave-net
fi
if [ ! -f /opt/cni/bin/weave-ipam ] ; then
    cp /home/weave/plugin /opt/cni/bin/weave-ipam
fi

/home/weave/weave --local create-bridge --force

exec /home/weave/weaver --port=6783 --datapath=datapath \
     --http-addr=127.0.0.1:6784 --docker-api='' --no-dns \
     --ipalloc-range=10.244.0.0/14 \
     --name=$(cat /sys/class/net/weave/address) $(/home/weave/kube-peers)
