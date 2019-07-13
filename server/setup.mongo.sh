#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

DATADIR="/home/mongo"

echo
echo "## Installing mongodb-org..."

if [[ ! -f /etc/apt/sources.list.d/mongodb-org-4.0.list ]]; then
	if [[ `lsb_release -si` = 'Debian' ]]; then
		echo -n "Adding repository "
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
		echo "deb http://repo.mongodb.org/apt/debian $(lsb_release -sc)/mongodb-org/4.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
		sudo apt -qq update
	elif [[ `lsb_release -si` = 'Ubuntu' ]]; then
		echo -n "Adding repository "
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
		echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
	fi

	sudo apt -qq update
fi

sudo apt install -yqq mongodb-org
sudo service mongod stop

sudo chown -R $USER:$USER /etc/mongod.conf
[[ ! -x ~/conf ]] && mkdir ~/conf
[[ ! -x ~/conf/mongo ]] && mkdir ~/conf/mongo
[[ ! -L ~/conf/mongod.conf ]] && ln -s /etc/mongod.conf ~/conf/mongo
[[ ! -L ~/conf/mongod.log ]] && ln -s /var/log/mongodb/mongod.log ~/conf/mongo

sudo mv /var/lib/mongodb/ $DATADIR
sudo sed -i "s#/var/lib/mongodb#$DATADIR#" /etc/mongod.conf

sudo systemctl enable mongod.service > /dev/null
sudo service mongod start

echo
echo -n "Installed Mongo "
mongod --version | head -n 1
