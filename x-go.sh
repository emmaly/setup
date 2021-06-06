#!/bin/bash

echo -e "\n[GO]"

if which gsutil >/dev/null; then
    echo "Installing/updating Go, if needed."
    GO_VERSION=$(gsutil ls gs://golang/ | grep -Ev '(rc|beta|asc|sha256)' | grep linux-amd64.tar.gz | cut -d/ -f4 | sed 's/^go//' | sed 's/\.linux-amd64\.tar\.gz$//' | sort --version-sort | tail -n1)
    if [ -z "$GO_VERSION" ]; then
        echo "********************* GO_VERSION IS EMPTY, WHICH IS BAD.  Perhaps there's an error in Google Storage, or on the Internet connection?  Review it in emmaly/setup/x-go.sh"
    else
        ## Check if currently installed version matches
        KEEP_GO=
        [ -f "/usr/local/go/bin/go" ] && /usr/local/go/bin/go version | grep -q " go$GO_VERSION " && KEEP_GO=1
        ## If we're not keeping current version (or it is absent), replace and/or fetch and install
        if [ -z "$KEEP_GO" ]; then
            ### Remove old Go if exists
            sudo rm -Rf /usr/local/go
            ### Fetch new Go, install, and cleanup
            gsutil cp gs://golang/go${GO_VERSION}.linux-amd64.tar.gz /tmp/go.tgz && \
            sudo tar -C /usr/local -zxf /tmp/go.tgz && \
            rm /tmp/go.tgz
        fi
        ## Setup Go
        mkdir -p ~/go/{src,bin}
        grep -q "/usr/local/go/bin" ~/.profile || echo "PATH=\$PATH:/usr/local/go/bin" | tee -a ~/.profile
        grep -q "/usr/local/go/bin" ~/.bashrc || echo "PATH=\$PATH:/usr/local/go/bin" | tee -a ~/.bashrc
        grep -q "~/go/bin" ~/.profile || echo "PATH=\$PATH:~/go/bin" | tee -a ~/.profile
        grep -q "~/go/bin" ~/.bashrc || echo "PATH=\$PATH:~/go/bin" | tee -a ~/.bashrc
        grep -q "CGO_ENABLED" ~/.profile || echo "export CGO_ENABLED=0" | tee -a ~/.profile
        grep -q "CGO_ENABLED" ~/.bashrc || echo "export CGO_ENABLED=0" | tee -a ~/.bashrc
    fi
else
    echo "Requires gsutil, which isn't found in \$PATH." # comes from https://cloud.google.com/sdk, which gets installed by x-googlecloudsdk.sh
fi