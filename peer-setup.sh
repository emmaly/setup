#!/bin/bash

DIR=$HOME/.emmaly-setup

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
		$DIR/update-authorized-keys.sh
	else
		(crontab -l | grep -v "update-authorized-keys.sh") | crontab -
	fi
fi
