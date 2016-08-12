#!/bin/sh

set -e

# Default if not supplied - same as gce kube-up script uses
IPALLOC_RANGE=${IPALLOC_RANGE:-10.244.0.0/14}

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

install_cni_plugin() {
    mkdir -p $1 || return 1
    cp /home/weave/plugin $1/weave-net
    cp /home/weave/plugin $1/weave-ipam
}

# Install CNI plugin binary to typical CNI bin location
# with fall-back to CNI directory used by kube-up on GCI OS
if [ ! -f /opt/cni/bin/weave-net ] ; then
    if ! install_cni_plugin /opt/cni/bin ; then
        install_cni_plugin /host_home/kubernetes/bin
    fi
fi

/home/weave/weave --local create-bridge --force

# Kubernetes sets HOSTNAME to the host's hostname
# when running a pod in host namespace.
NICKNAME_ARG=""
if [ -n "$HOSTNAME" ] ; then
    NICKNAME_ARG="--nickname=$HOSTNAME"
fi

BRIDGE_OPTIONS="--datapath=datapath"
if [ "$(/home/weave/weave --local bridge-type)" = "bridge" ] ; then
    # TODO: Call into weave script to do this
    if ! ip link show vethwe-pcap >/dev/null 2>&1 ; then
        ip link add name vethwe-bridge type veth peer name vethwe-pcap
        ip link set vethwe-bridge up
        ip link set vethwe-pcap up
        ip link set vethwe-bridge master weave
    fi
    BRIDGE_OPTIONS="--iface=vethwe-pcap"
fi

/home/weave/weaver --port=6783 $BRIDGE_OPTIONS \
     --http-addr=127.0.0.1:6784 --docker-api='' --no-dns \
     --ipalloc-range=$IPALLOC_RANGE $NICKNAME_ARG \
     --name=$(cat /sys/class/net/weave/address) "$@" \
     $(/home/weave/kube-peers) &
WEAVE_PID=$!

# Wait for weave process to become responsive
while true ; do
    curl 127.0.0.1:6784/status >/dev/null 2>&1 && break
    if ! kill -0 $WEAVE_PID >/dev/null 2>&1 ; then
        echo Weave process has died >&2
        exit 1
    fi
    sleep 1
done

# Allocate an IP address to the bridge so host processes can communicate with pods
BRIDGE_CIDR=$(curl -s -S -X POST 127.0.0.1:6784/ip/weave:expose)
if ! ip addr show dev weave | grep -qF $BRIDGE_CIDR ; then
    ip addr add dev weave $BRIDGE_CIDR
fi

wait $WEAVE_PID
