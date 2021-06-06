#!/bin/bash

echo -e "\n[KONSOLE]"

which konsole >/dev/null || sudo apt-get install -y --no-install-recommends konsole

if [ -f ~/.local/share/konsole/Emmaly.profile ]; then
	echo "Emmaly's Konsole config already installed, skipping."
else
	mkdir -p ~/.local/share/konsole ~/.config
	cp Emmaly.profile ~/.local/share/konsole/Emmaly.profile
	[ ! -f ~/.config/konsolerc ] && cp konsolerc ~/.config/konsolerc
fi