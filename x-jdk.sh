#!/bin/bash

echo -e "\n[DEFAULT-JDK]"

if which java >/dev/null; then
    echo "JDK already installed, skipping."
else
    sudo apt-get install -y --no-install-recommends default-jdk
fi