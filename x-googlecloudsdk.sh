#!/bin/bash

echo -e "\n[GOOGLE CLOUD SDK]"
if [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]; then
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
	echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null && \
	sudo apt-get update
fi
dpkg -l google-cloud-sdk 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y google-cloud-sdk
dpkg -l kubectl 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y kubectl
grep -q "kubectl completion bash" ~/.bashrc || echo 'source <(kubectl completion bash)' | tee -a ~/.bashrc