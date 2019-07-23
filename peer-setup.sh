#!/bin/bash

DIR=$HOME/.emmaly-setup

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if which git >/dev/null; then
	if [ ! -d "$DIR" ]; then
		git clone https://github.com/emmaly/setup.git "$DIR"
	else
		git -C "$DIR" pull
	fi
fi

if which crontab >/dev/null; then
	if [ -d "$DIR" -a -f "$DIR/update-authorized-keys.sh" ]; then
		(crontab -l | grep -v "update-authorized-keys.sh"; echo "0 * * * * $DIR/update-authorized-keys.sh") | crontab -
		[ -x "$DIR/update-authorized-keys.sh" ] && "$DIR/update-authorized-keys.sh"
	else
		(crontab -l | grep -v "update-authorized-keys.sh") | crontab -
	fi
fi

[ -d ~/.ssh ] && chmod 700 ~/.ssh
[ -f ~/.ssh/authorized_keys ] && chmod 600 ~/.ssh/authorized_keys
