package main

import (
	"fmt"
	"log"
	"os"

	"k8s.io/kubernetes/pkg/api"
	"k8s.io/kubernetes/pkg/client/unversioned"
	kubectl_util "k8s.io/kubernetes/pkg/kubectl/cmd/util"
)

func getKubePeers() ([]string, error) {
	factory := kubectl_util.NewFactory(nil)
	config, err := factory.ClientConfig()
	if err != nil {
		os.Setenv("KUBERNETES_SERVICE_HOST", "")
		os.Setenv("KUBERNETES_SERVICE_PORT", "")
		config, err = factory.ClientConfig()
		if err != nil {
			log.Fatal("error contacting APIServer: ", err)
		}
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
