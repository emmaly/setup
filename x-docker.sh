#!/bin/bash

[ -z "${DISTRO_NAME}" ] && source x-distrodetect.sh

echo -e "\n[DOCKER]"
if which docker >/dev/null; then
	echo "Docker already installed, skipping."
else
	curl -fsSL https://download.docker.com/linux/$DISTRO_NAME/gpg | sudo apt-key add - && \
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$DISTRO_NAME $DISTRO_CODENAME stable" && \
	sudo apt-get update && \
	sudo apt-get install -y --no-install-recommends docker-ce && \
	sudo addgroup $USER docker
fi