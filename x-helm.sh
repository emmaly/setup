#!/bin/bash

echo -e "\n[HELM v3]"
echo "Installing/updating helm v3."
mkdir /tmp/helm-install-$$
HELM_TAG=$(curl -Ls https://github.com/helm/helm/releases | grep 'href="/helm/helm/releases/tag/v3.[0-9]*.[0-9]*\"' | grep -v no-underline | head -n 1 | cut -d '"' -f 2 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}')
curl -Ls https://get.helm.sh/helm-$HELM_TAG-linux-amd64.tar.gz | tar -C /tmp/helm-install-$$ -zx
sudo cp /tmp/helm-install-$$/linux-amd64/helm /usr/local/bin/helm
sudo chmod +x /usr/local/bin/helm
rm -Rf /tmp/helm-install-$$
grep -q "helm completion bash" ~/.profile || echo "source <(helm completion bash)" | tee -a ~/.profile
grep -q "helm completion bash" ~/.bashrc || echo "source <(helm completion bash)" | tee -a ~/.bashrc