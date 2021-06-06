#!/bin/bash

echo -e "\n[Android Studio]"
if [ -x /opt/android-studio/bin/studio.sh ]; then
	# We think we already have Android Studio installed.
	echo "Android Studio already installed, skipping."
elif [ ! -z "${IS_WSL}${IS_WSL2}" ]; then
	# We're in WSL
	echo "Android Studio for Windows should be installed in Windows directly." # MAYBE?
else
	# We need to install

	curl -Lo /tmp/android-studio.html https://developer.android.com/studio

	if [ -z "$IS_CROS" ]; then
		# Not ChromeOS
		AS_SHANAME=$(grep -Eo "\b[a-f0-9]+\s+android-studio-ide-\S+-linux.tar.gz\b" /tmp/android-studio.html | head -n1)
		AS_EXT="tgz"
	else
		# ChromeOS
		AS_SHANAME=$(grep -Eo "\b[a-f0-9]+\s+android-studio-ide-\S+-cros.deb\b" /tmp/android-studio.html | head -n1)
		AS_EXT="deb"
	fi

	AS_SHA=$(cut -d' ' -f1 <<< "$AS_SHANAME")
	AS_NAME=$(cut -d' ' -f2 <<< "$AS_SHANAME")
	AS_URL=$(grep -Eo "https://\S+/$AS_NAME" /tmp/android-studio.html | head -n1)

	if [ -z "$AS_URL" ]; then
		echo "Unable to locate installer URL, failed!"
	else
		rm /tmp/android-studio.$AS_EXT 2>/dev/null
		curl -Lo /tmp/android-studio.$AS_EXT "$AS_URL"
		if [ -f /tmp/android-studio.$AS_EXT ]; then
			if [ -z "$IS_CROS" ]; then
				# Not ChromeOS
				sudo tar -zx --no-same-owner --no-same-permissions -C /opt -f /tmp/android-studio.tgz
				if [ -x /opt/android-studio/bin/studio.sh ]; then
					echo "ok!"
				else
					echo "... well, that didn't seem to work."
				fi
			else
				# ChromeOS
				sudo apt install /tmp/android-studio.deb
			fi
			rm /tmp/android-studio.$AS_EXT
		else
			echo "Android Studio failed to download, failed!"
		fi
	fi
fi