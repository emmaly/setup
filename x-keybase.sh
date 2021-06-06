#!/bin/bash

echo -e "\n[KEYBASE]"
if which keybase >/dev/null; then
	echo "Keybase already installed, skipping."
else
	wget -O/tmp/keybase.deb https://prerelease.keybase.io/keybase_amd64.deb && \
	sudo dpkg -i /tmp/keybase.deb
	sudo apt-get install -f -y
	rm /tmp/keybase.deb
fi