#!/bin/bash

echo -e "\n[SENSIBLE BASH]"
[ ! -f ~/.sensible.bash ] && curl https://raw.githubusercontent.com/mrzool/bash-sensible/master/sensible.bash -o ~/.sensible.bash
[ -f ~/.sensible.bash ] && grep -q "~/.sensible.bash" ~/.bashrc || \
echo "source ~/.sensible.bash" | tee -a ~/.bashrc