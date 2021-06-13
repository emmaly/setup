#!/bin/bash

# git
source x-git.sh

# apt-update (or exit)
source x-aptupdate.sh

# distro-detect (could exit)
source x-distrodetect.sh

# dirs
source x-dirs.sh

# apt-update (or exit)
source x-aptupdate.sh

# apt-distupgrade (or exit)
source x-aptdistupgrade.sh

# Install Prereq Packages (or exit)
source x-aptprereqs.sh

# ~/.ssh keys
source x-sshkeys.sh

# Docker
source x-docker.sh

# Remmina
source x-remmina.sh

# Konsole
source x-konsole.sh

# Google Chrome
# source x-googlechrome.sh

# Google Cloud SDK
source x-googlecloudsdk.sh

# cloud_sql_proxy
# source x-cloudsqlproxy.sh

# Minikube
# source x-minikube.sh

# Helm
# source x-helm.sh

# Skaffold
# source x-skaffold.sh

# dind-cluster
# source x-dindcluster.sh

# Sensible Bash
# source x-sensiblebash.sh

# PS1
source x-ps1.sh

# Go
source x-go.sh

# JDK
source x-jdk.sh

# Node.js
source x-nodejs.sh

# yarn
source x-yarn.sh

# Firebase
source x-firebase.sh

# Fonts
source x-fonts.sh

# VS Code
source x-vscode.sh

# Android Studio
# source x-androidstudio.sh

# Signal
# source x-signal.sh

# Keybase
# source x-keybase.sh

# Flutter
# source x-flutter.sh

# peer-setup
source x-peersetup.sh

# WSL2
source x-wsl2.sh