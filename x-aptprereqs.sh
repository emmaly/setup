#!/bin/bash

echo -e "\n[INSTALL BASIC PREREQS]"

sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    default-mysql-client \
    dirmngr \
    dnsutils \
    fakeroot \
    gnome-keyring \
    gnupg \
    gnupg2 \
    iputils-ping \
    libglu1-mesa \
    libsecret-1-dev \
    lsb-release \
    man-db \
    nano \
    powerline \
    software-properties-common \
    wget \
    whois \
    unzip \
    xz-utils \
|| exit 1

sudo apt-get install -y --no-install-recommends python-pip || \
sudo apt-get install -y --no-install-recommends python3-pip || \
exit 1