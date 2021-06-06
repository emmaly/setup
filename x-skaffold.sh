#!/bin/bash

echo -e "\n[SKAFFOLD]"
echo "Installing/updating skaffold."
sudo curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo chmod +x /usr/local/bin/skaffold