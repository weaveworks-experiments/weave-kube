package main

import (
	"fmt"
	"log"
	"os"

	"k8s.io/kubernetes/pkg/api"
	"k8s.io/kubernetes/pkg/client/restclient"
	"k8s.io/kubernetes/pkg/client/unversioned"
	kubectl_util "k8s.io/kubernetes/pkg/kubectl/cmd/util"
)

func getKubePeers() ([]string, error) {
	c, err := unversioned.NewInCluster()
	if err != nil {
		return nil, err
	}
	nodeList, err := c.Nodes().List(api.ListOptions{})
	if err != nil {
		// Fallback for cases (e.g. from kube-up.sh) where kube-proxy is not running on master
		log.Print("error contacting APIServer: ", err, "; trying with blank env vars")
		os.Setenv("KUBERNETES_SERVICE_HOST", "")
		os.Setenv("KUBERNETES_SERVICE_PORT", "")
		factory := kubectl_util.NewFactory(nil)
		var config *restclient.Config
		config, err = factory.ClientConfig()
		if err != nil {
			log.Fatal("error contacting APIServer: ", err)
		}
		c, err = unversioned.New(config)
		if err != nil {
			return nil, err
		}
		nodeList, err = c.Nodes().List(api.ListOptions{})
	}

	if err != nil {
		return nil, err
	}
	addresses := make([]string, 0, len(nodeList.Items))
	for _, peer := range nodeList.Items {
		for _, addr := range peer.Status.Addresses {
			if addr.Type == "InternalIP" {
				addresses = append(addresses, addr.Address)
			}
		}
	}
	return addresses, nil
}

func main() {
	peers, err := getKubePeers()
	if err != nil {
		log.Fatalf("Could not get peers: %v", err)
	}
	for _, addr := range peers {
		fmt.Println(addr)
	}
}
