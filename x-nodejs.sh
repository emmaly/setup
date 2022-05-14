#!/bin/bash

# Node.js
NODE_UPGRADE=${NODE_UPGRADE:=no}
NODE_REPO_VER=16.x # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
echo -e "\n[NODE.JS ${NODE_REPO_VER}]"
if [ "$NODE_UPGRADE" == "no" ] && which node; then
	echo "node.js already installed, skipping."
else
	if [ -z "$NODE_REPO_VER" ]; then
		echo "*************** NODE_REPO_VER IS EMPTY WHICH IS BAD.  Fix this at emmaly/setup/setup.sh"
		exit 1
	fi
	wget -q -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - \
		&& sudo sh -c "echo 'deb https://deb.nodesource.com/node_${NODE_REPO_VER} $(lsb_release -c -s) main' > /etc/apt/sources.list.d/nodesource.list" \
		&& sudo sh -c "echo 'deb-src https://deb.nodesource.com/node_${NODE_REPO_VER} $(lsb_release -c -s) main' >> /etc/apt/sources.list.d/nodesource.list" \
		&& sudo apt-get update \
		&& sudo apt-get install -y nodejs --no-install-recommends
fi