# setup

Maintainer: Emmaly Wilson <emmaly@emma.ly>

Run the usual setup via one of these:

*	`curl -L https://setup.emma.ly | bash -s`
*	`wget -qO- https://setup.emma.ly | bash -s`

Key could be created and read via something like this:

* `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "${USER}@$(hostname) $(date +"$(date -u --rfc-3339=date)")" && cat ~/.ssh/id_ed25519.pub`

Key distribution via something like this:

*	`curl -L https://peersetup.emma.ly | bash -s`
*	`wget -qO- https://peersetup.emma.ly | bash -s`
