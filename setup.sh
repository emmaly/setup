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
			fakeroot \
			gnupg \
			konsole \
			lsb-release \
			man-db \
			nano \
			powerline \
			python-pip \
			wget \
			unzip

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

# Google Cloud SDK install
[ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ] && \
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null && \
sudo apt-get update
dpkg -l google-cloud-sdk 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y google-cloud-sdk
dpkg -l kubectl 2>/dev/null | grep ^ii >/dev/null || sudo apt-get install --no-install-recommends -y kubectl

# Sensible Bash
curl https://raw.githubusercontent.com/mrzool/bash-sensible/master/sensible.bash -o ~/.sensible.bash
[ -f ~/.sensible.bash ] && grep -q "~/.sensible.bash" ~/.bashrc || \
echo "source ~/.sensible.bash" | tee -a ~/.bashrc && \

# Powerline config
#grep -q "powerline-daemon -q" ~/.bashrc || echo "powerline-daemon -q" | tee -a ~/.bashrc
#grep -q "/powerline.sh" ~/.bashrc || echo "source /usr/share/powerline/bindings/bash/powerline.sh" | tee -a ~/.bashrc

# Custom PS1 prompt
[ ! -f ~/.ps1.bash ] && ps1.bash -o ~/.ps1.bash
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

# Setup Fonts
FONTDIR=/usr/share/fonts/emmalyfonts
sudo rm -Rf $FONTDIR
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

# Install VS Code (see https://code.visualstudio.com/Download for new version/sha values)
VSCODE_VERSION=1.28
VSCODE_SHA256=fa5f9a4349edc2b9931631c67fdfaa920270ab1b27c34e3841d987406a588dd4
if [ ! -z "${VSCODE_VERSION}" ]; then
	if dpkg -l code 2>/dev/null | grep ^ii >/dev/null; then
		echo "Skipping VS Code..."
	else
		[ ! -f /tmp/vscode.deb ] && curl -L https://vscode-update.azurewebsites.net/${VSCODE_VERSION}/linux-deb-x64/stable > /tmp/vscode.deb
		[ -f /tmp/vscode.deb ] && sha256sum /tmp/vscode.deb | grep -q "${VSCODE_SHA256}" && \
		sudo dpkg -i /tmp/vscode.deb && \
		rm -f /tmp/vscode.deb
	fi
fi
