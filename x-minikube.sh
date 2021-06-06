#!/bin/bash

echo -e "\n[MINIKUBE]"
echo "Installing/updating minikube."
sudo curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x /usr/local/bin/minikube