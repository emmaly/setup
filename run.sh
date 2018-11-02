#!/bin/bash

STAGINGDIR=/tmp/emmaly.setup-$$

sudo apt-get update && \
sudo apt-get install -y --no-install-recommends git && \
mkdir -p $STAGINGDIR && \
cd $STAGINGDIR && \
git clone https://github.com/emmaly/setup.git . && \
bash setup.sh
