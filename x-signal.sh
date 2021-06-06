#!/bin/bash

echo -e "\n[SIGNAL]"
if which signal-desktop >/dev/null; then
	echo "Signal already installed, skipping."
else
	curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
	echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal.list
	sudo apt update && sudo apt install -y --no-install-recommends signal-desktop
fi