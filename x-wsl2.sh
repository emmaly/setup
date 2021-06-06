#!/bin/bash

[ -z "${DISTRO_NAME}" ] && source x-distrodetect.sh

if [ ! -z "$IS_WSL2" ]; then
	echo -e "\n[WSL2 SETTINGS]"

	if [ -z "${WAYLAND_DISPLAY}" ]; then
		grep -q "export DISPLAY" ~/.bashrc || echo "export DISPLAY=\$(awk '/nameserver / {print \$2; exit}' /etc/resolv.conf 2>/dev/null):0" | tee -a ~/.bashrc >/dev/null
	fi

	[ ! -f "$HOME/wsl.sh" ] && cp wsl.sh "$HOME/wsl.sh" && chmod 755 "$HOME/wsl.sh"

	# if which wslusc >/dev/null && [ -x "$HOME/wsl.sh" ]; then
	# 	SHORTCUT_NAME="$(grep -oP '^\s*#\s*NAME=\K.*' "$HOME/wsl.sh")"
	# 	SHORTCUT_NAME="${SHORTCUT_NAME:-WSL}"
	# 	wslusc -n "$SHORTCUT_NAME" -g "$HOME/wsl.sh"
	# fi

	# WORKAROUND an issue in Ubuntu/WSL causing wslusc path length issue
	[ -f "$HOME/wsl.sh" ] && [ ! -L "/bin/_emwsl.sh" ] && sudo ln -s "$HOME/wsl.sh" "/bin/_emwsl.sh"
	if which wslusc >/dev/null && [ -x "/bin/_emwsl.sh" ]; then
		SHORTCUT_NAME="$(grep -oP '^\s*#\s*NAME=\K.*' "/bin/_emwsl.sh")"
		SHORTCUT_NAME="${SHORTCUT_NAME:-WSL}"
		wslusc -n "$SHORTCUT_NAME" -g "/bin/_emwsl.sh"
	fi

	[ -x "$(which docker)" ] && echo "Want Docker?  You'll need https://hub.docker.com/editions/community/docker-ce-desktop-windows/ in Windows."
fi