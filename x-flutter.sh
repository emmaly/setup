#!/bin/bash

echo -e "\n[FLUTTER]"
if which flutter >/dev/null; then
	echo "Flutter already installed, skipping."
else
	FLUTTER_URL_BASE="https://storage.googleapis.com/flutter_infra/releases/"
	FLUTTER_URL="${FLUTTER_URL_BASE}$(curl -Ls ${FLUTTER_URL_BASE}releases_linux.json | grep -E '"archive": *"stable/linux/flutter_linux_[0-9]*.[0-9]*.[0-9]*-stable.tar.xz",' | head -n1 | cut -d\" -f4)"
	sudo mkdir -p /opt/flutter && sudo chown -R $USER: /opt/flutter
	curl -Ls "$FLUTTER_URL" | tar -C /opt -Jx
	cd /opt/flutter/bin
	./flutter precache
	cd - >/dev/null
fi
code --install-extension Dart-Code.flutter
grep -q "/opt/flutter/bin" ~/.profile || echo "PATH=\$PATH:/opt/flutter/bin" | tee -a ~/.profile
grep -q "/opt/flutter/bin" ~/.bashrc || echo "PATH=\$PATH:/opt/flutter/bin" | tee -a ~/.bashrc