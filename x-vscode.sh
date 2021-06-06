#!/bin/bash

[ -z "${DISTRO_NAME}" ] && source x-distrodetect.sh

echo -e "\n[VS Code]"
if [ ! -z "${IS_WSL}${IS_WSL2}" ]; then
	echo "VS Code should be installed in the Windows Environment, not in WSL, skipping."
elif which code >/dev/null; then
	echo "VS Code already installed, skipping."
else
	## Set VS Code preferences
	mkdir -p ~/.config/Code/User
	cp vscode.user.settings.json ~/.config/Code/User/settings.json
	## Install Microsoft apt repository key
	eval $(apt-config shell APT_TRUSTED_PARTS Dir::Etc::trustedparts/d)
	CODE_TRUSTED_PART=${APT_TRUSTED_PARTS}microsoft.gpg
	if [ ! -f $CODE_TRUSTED_PART ]; then
		### Sourced from https://packages.microsoft.com/keys/microsoft.asc
		echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.7 (GNU/Linux)

mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwT
LXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV
7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3ag
OeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2j
H632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVr
M+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVs
ZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwEC
AB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH
/32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqe
MNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy
7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXV
KJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJ
XdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+
NdCFTW7wY0Fb1fWJ+/KTsC4=
=J6gs
-----END PGP PUBLIC KEY BLOCK-----
" | gpg --dearmor | sudo tee $CODE_TRUSTED_PART
	fi
	## Install repository source list
	eval $(apt-config shell APT_SOURCE_PARTS Dir::Etc::sourceparts/d)
	CODE_SOURCE_PART=${APT_SOURCE_PARTS}vscode.list
	WRITE_SOURCE=0
	if [ ! -f $CODE_SOURCE_PART ]; then
		### Write source list if it does not exist
		WRITE_SOURCE=1
	elif grep -q "# disabled on upgrade to" $CODE_SOURCE_PART; then
		### Write source list if it was disabled by OS upgrade
		WRITE_SOURCE=1
	fi
	[ "$WRITE_SOURCE" -eq "1" ] && echo -e "### THIS FILE IS AUTOMATICALLY CONFIGURED ###\n# You may comment out this entry, but any other modifications may be lost.\ndeb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | sudo tee $CODE_SOURCE_PART
	sudo apt update && sudo apt install -y --no-install-recommends code
fi