#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

DATADIR="/home/mysql"

echo
echo "## Installing mysql-community..."

if [[ ! -f /etc/apt/sources.list.d/mysql.list ]]; then
	FILE="mysql-apt-config_0.8.13-1_all.deb";
	wget -qc "https://dev.mysql.com/get/$FILE"
	if [[ ! -f $FILE ]]; then
		echo "ERROR: Unable to download $FILE"
		exit
	fi

	sudo dpkg -i $FILE
	rm $FILE
	sudo apt -qq update
fi
sudo apt -yqq install mysql-server mysql-client mysql-utilities

sudo chown -R $USER:$USER /etc/mysql
[[ ! -L ~/conf/mysql ]] && ln -s /etc/mysql ~/conf/mysql
[[ ! -L ~/conf/mysql/log ]] && ln -s /var/log/mysql ~/conf/mysql/log

sudo service mysql stop
echo "Moving datadir to $DATADIR"
sudo mv /var/lib/mysql/ $DATADIR
# sudo chown -R mysql:mysql $DATADIR
# sudo chmod 755 $DATADIR

rm /etc/mysql/my.cnf
cat > /etc/mysql/my.cnf << EOF
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/

[mysqld]
datadir=$DATADIR

EOF

if [[ -d /etc/apparmor.d ]]; then
  sudo sh -c "echo \"alias /var/lib/mysql/ -> /home/mysql/,\" > /etc/apparmor.d/tunables/alias"
  sudo systemctl restart apparmor
fi

sudo service mysql start

echo
echo -n "Installed "
mysql --version
