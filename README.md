# weave-kube
Weave Net integration with Kubernetes for seamless turn-up

This repo contains a sample DaemonSet config for Kubernetes to install
Weave Net with one command, and the source code for the image which
makes that happen.

## Prerequisites:

A version of Kubernetes that includes PR #28178, to reload the CNI
configuration after launch.

Download a copy of `weave-daemonset.yaml` from this repo.

## To use:

 * Bring up a Kubernetes cluster configured to use CNI. For example,
using the 'cluster' scripts supplied as part of Kubernetes:

```
NETWORK_PROVIDER=cni cluster/kube-up.sh
```

 * Before you create any pods using Kubernetes, install and run Weave
Net via the yaml file:

```
kubectl create -f weave-daemonset.yaml
```

After a few seconds, one Weave Net pod should be running on each node,
and any further pods you create will be attached to the Weave network.

### Further Information

* [Weave Net Docs](https://www.weave.works/docs/net/latest/introducing-weave/)
* [Weave Net Source](https://github.com/weaveworks/weave)
