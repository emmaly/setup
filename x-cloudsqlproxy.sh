#!/bin/bash

echo -e "\n[CLOUD_SQL_PROXY]"
echo "Installing/updating cloud_sql_proxy."
sudo curl -Lo /usr/local/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
sudo chmod +x /usr/local/bin/cloud_sql_proxy