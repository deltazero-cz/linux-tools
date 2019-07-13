#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

NODE_VERSION=12

echo
echo "## Installing node..."

if [[ ! -f /etc/apt/sources.list.d/nodesource.list ]]; then
	echo -n "Adding repository "
	curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
	echo "deb https://deb.nodesource.com/node_$NODE_VERSION.x $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
	echo "deb-src https://deb.nodesource.com/node_$NODE_VERSION.x $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list > /dev/null
	sudo apt -qq update
fi

sudo apt -yqq install nodejs
sudo npm -g i npm

[[ ! -x /home/node ]] && sudo mkdir /home/node
[[ ! -L ~/node ]] && ln -s /home/node/ ~/node

echo
echo -n "Installed node "
node -v
