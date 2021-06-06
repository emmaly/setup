#!/bin/bash

if [ -z $(which lsb_release) ]; then
    echo -e "\n[INSTALLING LSB-RELEASE]"
    sudo apt-get install -y --no-install-recommends lsb-release || exit 1
fi

DISTRO_NAME_TITLECASE="$(lsb_release -is)"
DISTRO_NAME="$(lsb_release -is | tr -s 'A-Z' 'a-z')"
DISTRO_VER="$(lsb_release -rs)"
DISTRO_CODENAME="$(lsb_release -cs)"
IS_WSL="$(uname -r | grep -qi '\bmicrosoft\b' && echo 1)" # either 1 or empty
IS_WSL2="$(uname -r | grep -qi '\b-microsoft-.*-WSL2\b' && echo 1)" # either 1 or empty
IS_CROS="$(test -d /opt/google/cros-containers && which sommelier >/dev/null && echo 1)" # either 1 or empty

echo -e "\n[DISTRO]"
echo "${DISTRO_NAME_TITLECASE} ${DISTRO_VER} (${DISTRO_CODENAME})"
[ "$IS_WSL" -a ! "$IS_WSL2" ] && echo " • Running in a Windows WSL Environment"
[ "$IS_WSL2" ] && echo " • Running in a Windows WSL2 Environment"
[ "$IS_CROS" ] && echo " • Running in a ChromeOS Hosted Linux Container"
echo ""