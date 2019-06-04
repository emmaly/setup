#!/bin/bash

# General Updates
sudo apt-get update
sudo apt-get dist-upgrade -y

# Prereqs
sudo apt-get install -y --no-install-recommends \
			apt-transport-https \
			ca-certificates \
			curl \
			dirmngr \
			dnsutils \
			fakeroot \
			gnupg \
			gnupg2 \
			konsole \
			lsb-release \
			man-db \
			nano \
			powerline \
			python-pip \
			software-properties-common \
			wget \
			whois \
			unzip

# Install Docker GPG Key, Repository, Package
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
			 docker-ce
sudo addgroup $USER docker

# Install Remmina
if [ "stretch" == "$(lsb_release -cs)" ]; then
	echo "deb http://ftp.debian.org/debian $(lsb_release -cs)-backports main" | sudo tee /etc/apt/sources.list.d/stretch-backports.list
	sudo apt-get update
	sudo apt-get install -y --no-install-recommends -t $(lsb_release -cs)-backports \
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

# Konsole config
mkdir -p ~/.local/share/konsole ~/.config
[ ! -f ~/.local/share/konsole/Emmaly.profile ] && cp Emmaly.profile ~/.local/share/konsole/Emmaly.profile
[ ! -f ~/.config/konsolerc ] && cp konsolerc -o ~/.config/konsolerc

# Google Chrome install
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	&& sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
	&& sudo apt-get update
	&& sudo apt-get install -y google-chrome-stable --no-install-recommends

# Google Cloud SDK install
if [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]; then
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
	echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null && \
	sudo apt-get update
fi
dpkg -l google-cloud-sdk 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y google-cloud-sdk
dpkg -l kubectl 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y kubectl
grep -q "kubectl completion bash" ~/.bashrc || echo 'source <(kubectl completion bash)' | tee -a ~/.bashrc

# cloud_sql_proxy install
sudo curl -Lo /usr/local/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
sudo chmod +x /usr/local/bin/cloud_sql_proxy

# Minikube install
sudo curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x /usr/local/bin/minikube

# dind-cluster install
sudo curl -Lo /usr/local/bin/dind-cluster-v1.13 https://github.com/kubernetes-sigs/kubeadm-dind-cluster/releases/download/v0.1.0/dind-cluster-v1.13.sh
sudo chmod +x /usr/local/bin/dind-cluster-v1.13

# Sensible Bash
[ ! -f ~/.sensible.bash ] && curl https://raw.githubusercontent.com/mrzool/bash-sensible/master/sensible.bash -o ~/.sensible.bash
[ -f ~/.sensible.bash ] && grep -q "~/.sensible.bash" ~/.bashrc || \
echo "source ~/.sensible.bash" | tee -a ~/.bashrc

# Powerline config
#grep -q "powerline-daemon -q" ~/.bashrc || echo "powerline-daemon -q" | tee -a ~/.bashrc
#grep -q "/powerline.sh" ~/.bashrc || echo "source /usr/share/powerline/bindings/bash/powerline.sh" | tee -a ~/.bashrc

# Custom PS1 prompt
[ ! -f ~/.ps1.bash ] && cp ps1.bash ~/.ps1.bash
grep -q "~/.ps1.bash" ~/.bashrc || echo "source ~/.ps1.bash" | tee -a ~/.bashrc

# Go install
GO_VERSION=$(gsutil ls gs://golang/ | grep -Ev '(rc|beta|asc|sha256)' | grep linux-amd64.tar.gz | cut -d/ -f4 | sed 's/^go//' | sed 's/\.linux-amd64\.tar\.gz$//' | sort --version-sort | tail -n1)
[ -z "$GO_VERSION" ] && exit 1
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

# Setup Fonts
FONTDIR=/usr/share/fonts/emmalyfonts
if [ ! -d "$FONTDIR" ]; then
	sudo mkdir -p $FONTDIR
	## Google Cloud Fonts
	[ ! -f /tmp/googlefonts.zip ] && curl -L https://github.com/google/fonts/archive/master.zip > /tmp/googlefonts.zip
	sudo mkdir -p $FONTDIR/google-cloud-fonts
	sudo unzip -q /tmp/googlefonts.zip -d $FONTDIR/google-cloud-fonts
	rm /tmp/googlefonts.zip
	## Go font
	sudo mkdir -p $FONTDIR/gofont
	git clone --depth=1 https://go.googlesource.com/image /tmp/gofont
	sudo cp /tmp/gofont/font/gofont/ttfs/*.ttf $FONTDIR/gofont
	rm -Rf /tmp/gofont
	## FiraCode font
	sudo mkdir -p $FONTDIR/firacode
	git clone --depth=1 https://github.com/tonsky/FiraCode.git /tmp/firacode
	sudo cp /tmp/firacode/distr/ttf/*.ttf $FONTDIR/firacode
	rm -Rf /tmp/firacode
	## Flush the Font Cache
	sudo fc-cache -f
fi

# Install VS Code
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
