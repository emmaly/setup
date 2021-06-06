#!/bin/bash

SSHKEYFILE=~/.ssh/id_ed25519

echo -e "\n[SSH KEYS]"
if [ -f "${SSHKEYFILE}" ]; then
	echo -e "Key already exists, skipping."
else
    SSHKEYGEN="$(which ssh-keygen 2>/dev/null || which ssh-keygen.exe 2>/dev/null)"
    if [ -z "${SSHKEYGEN}" ]; then
        echo -e "Error: ssh-keygen missing; can't create keys, skipping."
    else
    	echo -e "Generating new key pair..."
	    $SSHKEYGEN -t ed25519 -C "${USER}@${HOSTNAME}:$(date +"%Y%m%d")" -f "${SSHKEYFILE}"
    fi
fi

echo -e "\n[KEYCHAIN]"
if [ ! -f "${SSHKEYFILE}" ]; then
    echo -e "Error: ${SSHKEYFILE} doesn't exist, skipping."
else
    which keychain >/dev/null || sudo apt-get install -y --no-install-recommends keychain
    grep keychain ~/.bashrc | grep eval >/dev/null || echo 'eval $(keychain --eval id_ed25519 2>/dev/null)' >> ~/.bashrc
fi