#!/bin/bash

# Versions
NODE_REPO_VER=12.x # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
#FIRACODE_COMMIT=3557a00

# Distro
DISTRO_NAME="$(lsb_release -is | tr -s 'A-Z' 'a-z')"
DISTRO_VER="$(lsb_release -rs)"
DISTRO_CODENAME="$(lsb_release -cs)"
IS_WSL="$(uname -r | grep -qi '\-microsoft-' && echo 1)" # either 1 or empty

# Executable Paths
SSHKEYGEN="$(which ssh-keygen 2>/dev/null || which ssh-keygen.exe 2>/dev/null)"

# Setup git
git config --global user.name "Emmaly"
git config --global user.email "emmaly@emma.ly"

# Create keys, if needed
echo -e "\n[SSH KEYS]"
if [ -f ~/.ssh/id_ed25519 ]; then
	echo -e "Key already exists, skipping."
else
	echo -e "Generating new key pair..."
	$SSHKEYGEN -t ed25519 -C "${USER}@${HOSTNAME}:$(date +"%Y%m%d")" -f ~/.ssh/id_ed25519
fi

# General Directories
echo -e "\n[GENERAL DIRECTORIES]"
mkdir -vp ~/code ~/.local/share ~/.config ~/.yarn/bin

# Packages
echo -e "\n[PACKAGES]"

## General Updates
echo -e "\nUpdating package cache..."
sudo apt-get update
echo -e "\nUpgrading packages..."
sudo apt-get dist-upgrade -y

## Prereqs
echo -e "\nInstalling some packages..."
sudo apt-get install -y --no-install-recommends \
			apt-transport-https \
			ca-certificates \
			curl \
			dirmngr \
			dnsutils \
			fakeroot \
			gnome-keyring \
			gnupg \
			gnupg2 \
			iputils-ping \
			keychain \
			konsole \
			libsecret-1-dev \
			lsb-release \
			man-db \
			mysql-client \
			mysql-workbench \
			nano \
			powerline \
			python-pip \
			software-properties-common \
			wget \
			whois \
			unzip

# Configure Keychain
echo -e "\n[KEYCHAIN]"
grep keychain ~/.bashrc | grep eval >/dev/null || echo 'eval $(keychain --eval id_ed25519)' >> ~/.bashrc

# Install Docker GPG Key, Repository, Package
echo -e "\n[DOCKER]"
if which docker >/dev/null; then
	echo "Docker already installed, skipping."
else
	curl -fsSL https://download.docker.com/linux/$DISTRO_NAME/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$DISTRO_NAME $DISTRO_CODENAME stable"
	sudo apt-get update
	sudo apt-get install -y --no-install-recommends \
				 docker-ce
	sudo addgroup $USER docker
fi

# Install Remmina
echo -e "\n[REMMINA]"
if which remmina >/dev/null; then
	echo "Remmina already installed, skipping."
else
	if [ "stretch" == "$DISTRO_CODENAME" ]; then
		echo "deb http://ftp.debian.org/debian $DISTRO_CODENAME-backports main" | sudo tee /etc/apt/sources.list.d/stretch-backports.list
		sudo apt-get update
		sudo apt-get install -y --no-install-recommends -t $DISTRO_CODENAME-backports \
				remmina \
				remmina-plugin-rdp \
				remmina-plugin-secret \
				remmina-plugin-spice \
				remmina-plugin-vnc \
				remmina-plugin-xdmcp
	else
		sudo apt-get install -y --no-install-recommends \
				remmina \
				remmina-plugin-rdp \
				remmina-plugin-secret \
				remmina-plugin-spice \
				remmina-plugin-vnc \
				remmina-plugin-xdmcp
	fi
fi

# Konsole config
echo -e "\n[KONSOLE]"
if [ -f ~/.local/share/konsole/Emmaly.profile ]; then
	echo "Emmaly's Konsole config already installed, skipping."
else
	mkdir -p ~/.local/share/konsole ~/.config
	cp Emmaly.profile ~/.local/share/konsole/Emmaly.profile
	[ ! -f ~/.config/konsolerc ] && cp konsolerc ~/.config/konsolerc
fi

# Google Chrome install
echo -e "\n[GOOGLE CHROME]"
if which google-chrome >/dev/null; then
	echo "Google Chrome already installed, skipping."
else
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \
		&& sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' \
		&& sudo apt-get update \
		&& sudo apt-get install -y google-chrome-stable --no-install-recommends
fi

# Google Cloud SDK install
echo -e "\n[GOOGLE CLOUD SDK]"
if [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]; then
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
	echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null && \
	sudo apt-get update
fi
dpkg -l google-cloud-sdk 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y google-cloud-sdk
dpkg -l kubectl 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y kubectl
grep -q "kubectl completion bash" ~/.bashrc || echo 'source <(kubectl completion bash)' | tee -a ~/.bashrc

# cloud_sql_proxy install
echo -e "\n[CLOUD_SQL_PROXY]"
echo "Installing/updating cloud_sql_proxy."
sudo curl -Lo /usr/local/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
sudo chmod +x /usr/local/bin/cloud_sql_proxy

# Minikube install
echo -e "\n[MINIKUBE]"
echo "Installing/updating minikube."
sudo curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x /usr/local/bin/minikube

# dind-cluster install
echo -e "\n[DIND-CLUSTER]"
echo "Installing/updating dind-cluster."
sudo curl -Lo /usr/local/bin/dind-cluster-v1.13 https://github.com/kubernetes-sigs/kubeadm-dind-cluster/releases/download/v0.1.0/dind-cluster-v1.13.sh
sudo chmod +x /usr/local/bin/dind-cluster-v1.13

# Sensible Bash
echo -e "\n[SENSIBLE BASH]"
[ ! -f ~/.sensible.bash ] && curl https://raw.githubusercontent.com/mrzool/bash-sensible/master/sensible.bash -o ~/.sensible.bash
[ -f ~/.sensible.bash ] && grep -q "~/.sensible.bash" ~/.bashrc || \
echo "source ~/.sensible.bash" | tee -a ~/.bashrc

# Powerline config
#echo -e "\n[POWERLINE]"
#grep -q "powerline-daemon -q" ~/.bashrc || echo "powerline-daemon -q" | tee -a ~/.bashrc
#grep -q "/powerline.sh" ~/.bashrc || echo "source /usr/share/powerline/bindings/bash/powerline.sh" | tee -a ~/.bashrc

# Custom PS1 prompt
echo -e "\n[PS1 PROMPT]"
[ ! -f ~/.ps1.bash ] && cp ps1.bash ~/.ps1.bash
grep -q "~/.ps1.bash" ~/.bashrc || echo "source ~/.ps1.bash" | tee -a ~/.bashrc

# Go install
echo -e "\n[GO]"
echo "Installing/updating Go, if needed."
GO_VERSION=$(gsutil ls gs://golang/ | grep -Ev '(rc|beta|asc|sha256)' | grep linux-amd64.tar.gz | cut -d/ -f4 | sed 's/^go//' | sed 's/\.linux-amd64\.tar\.gz$//' | sort --version-sort | tail -n1)
if [ -z "$GO_VERSION" ]; then
	echo "********************* GO_VERSION IS EMPTY, WHICH IS BAD.  Perhaps there's an error in Google Storage, or on the Internet connection?  Review it in emmaly/setup/setup.sh"
else
	## Check if currently installed version matches
	KEEP_GO=
	[ -f "/usr/local/go/bin/go" ] && /usr/local/go/bin/go version | grep -q " go$GO_VERSION " && KEEP_GO=1
	## If we're not keeping current version (or it is absent), replace and/or fetch and install
	if [ -z "$KEEP_GO" ]; then
		### Remove old Go if exists
		sudo rm -Rf /usr/local/go
		### Fetch new Go, install, and cleanup
		gsutil cp gs://golang/go${GO_VERSION}.linux-amd64.tar.gz /tmp/go.tgz && \
		sudo tar -C /usr/local -zxf /tmp/go.tgz && \
		rm /tmp/go.tgz
	fi
	## Setup Go
	mkdir -p ~/go/{src,bin}
	grep -q "/usr/local/go/bin" ~/.profile || echo "PATH=\$PATH:/usr/local/go/bin" | tee -a ~/.profile
	grep -q "/usr/local/go/bin" ~/.bashrc || echo "PATH=\$PATH:/usr/local/go/bin" | tee -a ~/.bashrc
	grep -q "~/go/bin" ~/.profile || echo "PATH=\$PATH:~/go/bin" | tee -a ~/.profile
	grep -q "~/go/bin" ~/.bashrc || echo "PATH=\$PATH:~/go/bin" | tee -a ~/.bashrc
	#grep -q "GO111MODULE" ~/.profile || echo "export GO111MODULE=on" | tee -a ~/.profile
	#grep -q "GO111MODULE" ~/.bashrc || echo "export GO111MODULE=on" | tee -a ~/.bashrc
fi

# node.js
echo -e "\n[NODE.JS ${NODE_REPO_VER}]"
if which node; then
	echo "node.js already installed, skipping."
else
	if [ -z "$NODE_REPO_VER" ]; then
		echo "*************** NODE_REPO_VER IS EMPTY WHICH IS BAD.  Fix this at emmaly/setup/setup.sh"
		exit 1
	fi
	wget -q -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - \
		&& sudo sh -c "echo 'deb https://deb.nodesource.com/node_${NODE_REPO_VER} $(lsb_release -c -s) main' > /etc/apt/sources.list.d/nodesource.list" \
		&& sudo sh -c "echo 'deb-src https://deb.nodesource.com/node_${NODE_REPO_VER} $(lsb_release -c -s) main' >> /etc/apt/sources.list.d/nodesource.list" \
		&& sudo apt-get update \
		&& sudo apt-get install -y nodejs --no-install-recommends
fi

# Install packages via yarn
echo -e "\n[YARN]"
if which yarn; then
	echo "yarn already installed, skipping."
else
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
		&& sudo sh -c 'echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list' \
		&& sudo apt-get update \
		&& sudo apt-get install -y yarn --no-install-recommends
	grep -q "~/.yarn/bin" ~/.bashrc || \
		echo 'PATH=$PATH:~/.yarn/bin' >> ~/.bashrc
	yarn global add bower
	yarn global add localtunnel
	yarn global add polymer-cli
	yarn global add firebase-tools
	yarn global add webpack webpack-cli
	yarn global add twilio-cli
	yarn global add @angular/cli
	yarn global add @vue/cli
fi

# Setup Fonts
echo -e "\n[FONTS]"
FONTDIR=/usr/share/fonts/emmalyfonts
## Google Cloud Fonts
if [ -d "$FONTDIR/google-cloud-fonts" ]; then
	echo "Google Cloud Fonts already installed, skipping."
else
	[ ! -f /tmp/googlefonts.zip ] && curl -L https://github.com/google/fonts/archive/master.zip > /tmp/googlefonts.zip
	sudo mkdir -p $FONTDIR/google-cloud-fonts
	sudo unzip -q /tmp/googlefonts.zip -d $FONTDIR/google-cloud-fonts
	rm /tmp/googlefonts.zip
	FONTS_INSTALLED=1
fi
## Go font
if [ -d "$FONTDIR/gofont" ]; then
	echo "Go Font already installed, skipping."
else
	sudo mkdir -p $FONTDIR/gofont
	git clone --depth=1 https://go.googlesource.com/image /tmp/gofont
	sudo cp /tmp/gofont/font/gofont/ttfs/*.ttf $FONTDIR/gofont
	rm -Rf /tmp/gofont
	FONTS_INSTALLED=1
fi
## FiraCode font
if [ -d "$FONTDIR/firacode" ]; then
	echo "FiraCode Font already installed, skipping."
else
	sudo mkdir -p $FONTDIR/firacode
	if [ -z $FIRACODE_COMMIT ]; then
		git clone --depth=1 https://github.com/tonsky/FiraCode.git /tmp/firacode
	else
		git clone https://github.com/tonsky/FiraCode.git /tmp/firacode
		git -C /tmp/firacode checkout $FIRACODE_COMMIT
	fi
	sudo cp /tmp/firacode/distr/ttf/*.ttf $FONTDIR/firacode
	rm -Rf /tmp/firacode
	FONTS_INSTALLED=1
fi
## Operator Mono
if [ -d "$FONTDIR/operator-mono" ]; then
	echo "Operator Mono already installed, skipping."
else
	sudo mkdir -p $FONTDIR/operator-mono
	curl -Lo /tmp/operator-mono.zip https://www.cufonfonts.com/download/font/operator-mono
	sudo unzip -q /tmp/operator-mono.zip -d $FONTDIR/operator-mono
	rm /tmp/operator-mono.zip
	FONTS_INSTALLED=1
fi
## Victor Mono
if [ -d "$FONTDIR/victor-mono" ]; then
	echo "Victor Mono already installed, skipping."
else
	sudo mkdir -p $FONTDIR/victor-mono
	curl -Lo /tmp/victor-mono.zip https://github.com/rubjo/victor-mono/raw/master/public/VictorMonoAll.zip
	mkdir /tmp/victor-mono
	unzip -q /tmp/victor-mono.zip -d /tmp/victor-mono
	sudo cp /tmp/victor-mono/OTF/*.otf $FONTDIR/victor-mono/
	rm -R /tmp/victor-mono /tmp/victor-mono.zip
	FONTS_INSTALLED=1
fi
## Flush the Font Cache
if [ ! -z "$FONTS_INSTALLED" ]; then
	sudo fc-cache -f
fi

# Install VS Code
echo -e "\n[VS Code]"
if [ ! -z "$IS_WSL" ]; then
	echo "VS Code should not be installed in WSL, skipping."
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

# Android Studio for Chrome OS
echo -e "\n[Android Studio for Chrome OS]"
if [ ! -z "$IS_WSL" ]; then
	echo "Android Studio for Chrome OS should not be installed in WSL, skipping."
elif [ -x /opt/android-studio/bin/studio.sh ]; then
	echo "Android Studio already installed, skipping."
else
	curl -Lo /tmp/android-studio.html https://developer.android.com/studio
	AS_SHANAME=$(grep -Eo "\b[a-f0-9]+\s+android-studio-ide-\S+-cros.deb\b" /tmp/android-studio.html | head -n1)
	AS_SHA=$(cut -d' ' -f1 <<< "$AS_SHANAME")
	AS_NAME=$(cut -d' ' -f2 <<< "$AS_SHANAME")
	AS_URL=$(grep -Eo "https://\S+/$AS_NAME" /tmp/android-studio.html | head -n1)
	if [ -z "$AS_URL" ]; then
		echo "Unable to locate installer URL, failed!"
	else
		rm /tmp/android-studio.deb 2>/dev/null
		curl -Lo /tmp/android-studio.deb "$AS_URL"
		if [ -f /tmp/android-studio.deb ]; then
			sudo apt install /tmp/android-studio.deb
			rm /tmp/android-studio.deb
		else
			echo "Android Studio failed to download, failed!"
		fi
	fi
fi

# Install Signal
#echo -e "\n[SIGNAL]"
#if which signal-desktop >/dev/null; then
#	echo "Signal already installed, skipping."
#else
#	curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
#	echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal.list
#	sudo apt update && sudo apt install -y --no-install-recommends signal-desktop
#fi

# Install Keybase
#echo -e "\n[KEYBASE]"
#if which keybase >/dev/null; then
#	echo "Keybase already installed, skipping."
#else
#	wget -O/tmp/keybase.deb https://prerelease.keybase.io/keybase_amd64.deb && \
#	sudo dpkg -i /tmp/keybase.deb
#	sudo apt-get install -f -y
#	rm /tmp/keybase.deb
#fi

# Run peer-setup
if [ -x ./peer-setup.sh ]; then
	echo -e "\n[PEER-SETUP]"
	./peer-setup.sh
fi

# WSL2 Settings
if [ ! -z "$IS_WSL" ]; then
	grep -q "export DISPLAY" ~/.bashrc || echo "export DISPLAY=\$(awk '/nameserver / {print \$2; exit}' /etc/resolv.conf 2>/dev/null):0" | tee -a ~/.bashrc >/dev/null
fi
