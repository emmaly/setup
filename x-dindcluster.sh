#!/bin/bash

echo -e "\n[DIND-CLUSTER]"
echo "Installing/updating dind-cluster."
sudo curl -Lo /usr/local/bin/dind-cluster-v1.13 https://github.com/kubernetes-sigs/kubeadm-dind-cluster/releases/download/v0.1.0/dind-cluster-v1.13.sh
sudo chmod +x /usr/local/bin/dind-cluster-v1.13