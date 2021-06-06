#!/bin/bash

# Want to force reinstall the fonts?
# Set the ENV variable "FONT_REINSTALL" to any non-empty value.
# So, like: `FONT_REINSTALL=1 ./x-fonts.sh` which calls this file directly.
# Or: `FONT_REINSTALL=1 ./setup.sh` which probably will eventually call this file.

echo -e "\n[FONTS]"
FONTDIR=/usr/share/fonts/emmalyfonts
FONTS_INSTALLED=

[ ! -z "${FONT_REINSTALL}" ] && echo ">> FONT_REINSTALL has been requested <<"

## Go font
sudo mkdir -p $FONTDIR/gofont
if [ "$(ls "$FONTDIR/gofont" 2>/dev/null | wc -l)" == "0" -o ! -z "${FONT_REINSTALL}" ]; then
	echo -e "\nInstalling Go font...\n"
	git clone --depth=1 https://go.googlesource.com/image /tmp/gofont && \
	sudo cp /tmp/gofont/font/gofont/ttfs/*.ttf $FONTDIR/gofont && \
	FONTS_INSTALLED=1
	rm -Rf /tmp/gofont
else
	echo -e "\nGo font already installed, skipping.\n"
fi

## FiraCode font
sudo mkdir -p $FONTDIR/firacode
if [ "$(ls "$FONTDIR/firacode" 2>/dev/null | wc -l)" == "0" -o ! -z "${FONT_REINSTALL}" ]; then
	echo -e "\nInstalling FiraCode font...\n"
	git clone --depth=1 https://github.com/tonsky/FiraCode.git /tmp/firacode && \
	sudo cp /tmp/firacode/distr/ttf/*.ttf $FONTDIR/firacode && \
	FONTS_INSTALLED=1
	rm -Rf /tmp/firacode
else
	echo -e "\nFiraCode font already installed, skipping.\n"
fi

## Victor Mono font
sudo mkdir -p $FONTDIR/victor-mono
if [ "$(ls "$FONTDIR/victor-mono" 2>/dev/null | wc -l)" == "0" -o ! -z "${FONT_REINSTALL}" ]; then
	echo -e "\nInstalling Victor Mono font...\n"
	mkdir -p /tmp/victor-mono && \
	curl -Lo /tmp/victor-mono.zip https://github.com/rubjo/victor-mono/raw/master/public/VictorMonoAll.zip && \
	unzip -q /tmp/victor-mono.zip -d /tmp/victor-mono && \
	sudo cp /tmp/victor-mono/OTF/*.otf $FONTDIR/victor-mono/ && \
	FONTS_INSTALLED=1
	rm -Rf /tmp/victor-mono /tmp/victor-mono.zip
else
	echo -e "\nVictor Mono font already installed, skipping.\n"
fi

## Google Cloud Fonts
if [ "$(ls "$FONTDIR/google-cloud-fonts" 2>/dev/null | wc -l)" == "0" -o ! -z "${FONT_REINSTALL}" ]; then
	if [ ! -z "${WANT_GOOGLE_FONTS}" ]; then
		sudo mkdir -p $FONTDIR/google-cloud-fonts
		echo -e "\nInstalling Google Cloud Fonts...\n"
		[ ! -f /tmp/googlefonts.zip ] && curl -L https://github.com/google/fonts/archive/main.zip > /tmp/googlefonts.zip
		sudo unzip -q /tmp/googlefonts.zip -d $FONTDIR/google-cloud-fonts && \
		FONTS_INSTALLED=1
		rm /tmp/googlefonts.zip
	else
		echo -e "\nGoogle Cloud Fonts are skipped unless ENV variable WANT_GOOGLE_FONTS!=\"\" (because it's >650MB!)\n"
	fi
else
	echo -e "\nGoogle Cloud Fonts already installed, skipping.\n"
fi

## Flush the Font Cache
if [ ! -z "$FONTS_INSTALLED" ]; then
	echo -e "\nFlushing the Font Cache...\n"
	sudo fc-cache -f
fi

echo ""