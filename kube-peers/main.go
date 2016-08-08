package main

import (
	"fmt"
	"log"

	"k8s.io/kubernetes/pkg/api"
	"k8s.io/kubernetes/pkg/client/restclient"
	"k8s.io/kubernetes/pkg/client/unversioned"
)

func getKubePeers() ([]string, error) {
	config, err := restclient.InClusterConfig()
	if err != nil {
		return nil, err
	}
	c, err := unversioned.New(config)
	if err != nil {
		return nil, err
	}
	nodeList, err := c.Nodes().List(api.ListOptions{})
	if err != nil {
		return nil, err
	}
	addresses := make([]string, 0, len(nodeList.Items))
	for _, peer := range nodeList.Items {
		if peer.Name != "kubernetes-master" {
			for _, addr := range peer.Status.Addresses {
				if addr.Type == "InternalIP" {
					addresses = append(addresses, addr.Address)
				}
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
