#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

runned=()
ask () {
	echo
	while true; do
		echo -n "$1 [y/n] "
		read answer
		if [[ $answer = 'Y' ]] || [[ $answer = 'y' ]]; then
			run $2
			break
		elif [[ $answer = 'n' ]] || [[ $answer = 'N' ]]; then
			break
		fi
	done
}
run () {
	runned+=" $1"
	if [[ -f $1 ]]; then
		bash $1
	else
		bash <(curl -s "https://tools.deltazero.cz/server/$1")
	fi
}
check() {
	if [[ ! -x /usr/bin/apt ]] || [[ ! -x /usr/bin/apt-get ]]; then
		echo "This script is only to be run Debian-like distributions!"
		echo "Tested on:"
		echo " * Debian 10 [buster]"
		echo " * Ubuntu 18-04 [bionic]"
		exit
	fi

	if [[ $USER = 'root' ]]; then
		echo "Do not run this as root!"
		echo "The script will use sudo"
		exit
	fi
}

check

echo "BASIC SERVER SETUP $ver"
echo "By ΔO [deltazero.cz]"

if ([[ "$USER" = "ubuntu" ]] || [[ "$USER" = "debian" ]] || [[ "$USER" = "user" ]]) && [ -d $HOME ]; then
	echo
  if [[ -f "./user.rename.sh" ]]; then
		bash ./user.rename.sh && exit
	else
		bash <(curl -s "https://tools.deltazero.cz/server/user.rename.sh") && exit
	fi
fi

run "setup.basic.sh"

ask "Install full LAMP?"  "setup.lamp.sh"
if [[ ! " ${runned} " =~ " setup.lamp.sh " ]]; then
	ask "Install apache?"   "setup.apache.sh"
	ask "Install php?"      "setup.php.sh"
	ask "Install mysql?"    "setup.mysql.sh"
fi

ask "Install node?"     "setup.node.sh"
ask "Install mongodb?"  "setup.mongo.sh"
if [[ ! -f /usr/sbin/backup ]]; then
	ask "Set up backup?"  "setup.backup.sh"
fi

echo
echo "* * * * * * * * * * * * * * * *"
echo "*    INSTALLATION COMPLETE    *"
echo "* * * * * * * * * * * * * * * *"
echo
echo "Reconnect now to enjoy fully :)"
