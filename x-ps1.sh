#!/bin/bash

echo -e "\n[PS1 INSTALL]"
[ ! -f ~/.ps1.bash ] && cp ps1.bash ~/.ps1.bash
grep -q "~/.ps1.bash" ~/.bashrc || echo "source ~/.ps1.bash" | tee -a ~/.bashrc >/dev/null
echo ""