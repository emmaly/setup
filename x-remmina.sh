#!/bin/bash

[ -z "${DISTRO_NAME}" ] && source x-distrodetect.sh

echo -e "\n[REMMINA]"
if which remmina >/dev/null; then
	echo "Remmina already installed, skipping."
else
	if [ "stretch" == "$DISTRO_CODENAME" ]; then
		echo "deb http://ftp.debian.org/debian $DISTRO_CODENAME-backports main" | sudo tee /etc/apt/sources.list.d/stretch-backports.list
		sudo apt-get update
		sudo apt-get install -y --no-install-recommends -t $DISTRO_CODENAME-backports \
				remmina \
				remmina-plugin-rdp \
				remmina-plugin-secret \
				remmina-plugin-spice \
				remmina-plugin-vnc \
				remmina-plugin-xdmcp
	else
		sudo apt-get install -y --no-install-recommends \
				remmina \
				remmina-plugin-rdp \
				remmina-plugin-secret \
				remmina-plugin-spice \
				remmina-plugin-vnc \
				remmina-plugin-xdmcp
	fi
fi