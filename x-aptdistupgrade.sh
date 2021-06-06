#!/bin/bash

echo -e "\n[Package Distribution Upgrade]"
sudo apt-get dist-upgrade -y || exit 1