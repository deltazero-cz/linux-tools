#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

SERVER="athena.dayvee.cz"
FILE="/root/.ssh/id_rsa"
BUSER="backup_${HOSTNAME%%.*}"
CMD="/usr/sbin/backup"
DIRS="/home /etc /var/log"
PARAMS="-avh --exclude '*/__*'"
## consider -v
## consider --del
## consider --exclude
CRON="/var/spool/cron/crontabs/root"
CRONOPTS="45 5  * * *   "

if sudo test -f $FILE; then
	echo "SSH key pair alreasy exists"
else
	echo "Generating public/private rsa key pair."
	echo "For automatic backups, give empty passphrase."
	echo
	sudo ssh-keygen -qt rsa -C "root@$HOSTNAME" -f $FILE
fi

echo
echo "On backup server [$SERVER], # useradd ${BUSER} -g backup -s /bin/false"
echo "with .ssh/authorized_keys having:"
echo
sudo cat $FILE.pub
echo
echo "then just # sudo backup"
echo "do first backup now to auth known host"

sudo tee $CMD > /dev/null << EOF
#!/bin/sh
sudo rsync $PARAMS -e ssh $DIRS $BUSER@$SERVER:/
EOF
sudo chmod +x $CMD

if sudo grep -q "/usr/sbin/backup" $CRON; then
	echo "Cron backup already set, see # sudo crontab -l"
else
	sudo tee -a $CRON > /dev/null << EOF
$CRONOPTS   /usr/sbin/backup
EOF
fi
