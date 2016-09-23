# weave-kube

Weave Net integration with Kubernetes for seamless turn-up

This repo contains a DaemonSet config for Kubernetes to install
Weave Net with one command, and the source code for the image which
makes that happen.

## Prerequisites:

Kubernetes 1.3 or newer.

## To use:

 * Bring up a Kubernetes cluster configured to use CNI. For example,
using the [`kubeadm` command](http://kubernetes.io/docs/kubeadm/).

 * Before you create any pods using Kubernetes, install and run Weave
Net via the yaml file:

```
kubectl create -f https://git.io/weave-kube
```

After a few seconds, one Weave Net pod should be running on each node,
and any further pods you create will be attached to the Weave network.

As of 1.7.0, Weave Net supports the Kubernetes policy API so that you can
securely isolate different pods from each other based on namespaces and labels.

## Known Issues

 * Does not automatically handle nodes being removed from the cluster.
   This won't cause issues in practice.

## Further Information

* [Weave Net Docs](https://www.weave.works/docs/net/latest/introducing-weave/)
* [Weave Net Source](https://github.com/weaveworks/weave)
