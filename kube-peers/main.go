package main

import (
	"fmt"
	"log"

	v1core "k8s.io/client-go/1.4/kubernetes/typed/core/v1"
	"k8s.io/client-go/1.4/pkg/api"
	"k8s.io/client-go/1.4/rest"
)

func getKubePeers() ([]string, error) {
	config, err := rest.InClusterConfig()
	if err != nil {
		return nil, err
	}
	c, err := v1core.NewForConfig(config)
	if err != nil {
		return nil, err
	}
	nodeList, err := c.Nodes().List(api.ListOptions{})
	if err != nil {
		// Fallback for cases (e.g. from kube-up.sh) where kube-proxy is not running on master
		config.Host = "http://localhost:8080"
		log.Print("error contacting APIServer: ", err, "; trying with fallback: ", config.Host)
		c, err = v1core.NewForConfig(config)
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
