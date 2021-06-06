#!/bin/bash

echo -e "\n[YARN]"
if which yarn >/dev/null; then
	echo "yarn already installed, skipping."
else
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
		&& sudo sh -c 'echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list' \
		&& sudo apt-get update \
		&& sudo apt-get install -y yarn --no-install-recommends
	grep -q "~/.yarn/bin" ~/.bashrc || \
		echo 'PATH=$PATH:~/.yarn/bin' >> ~/.bashrc
fi