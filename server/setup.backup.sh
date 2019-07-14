#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

FILE="/root/.ssh/id_rsa"
BUSER="backup_${HOSTNAME%%.*}"
CMD="/usr/local/bin/backup"
DIRS="/home /etc /var/log"
PARAMS="-avh --exclude '*/__*'"
## consider -v
## consider --del
## consider --exclude
CRON="/var/spool/cron/crontabs/root"
CRONOPTS="45 05 * * *    "

echo -n "Your backup server [hostname]: "
read SERVER

if [[ -z $SERVER ]]; then
	echo "No backup server; skipping"
	exit
fi

if sudo test -f $FILE; then
	echo "SSH key pair alreasy exists"
else
	echo "Generating public/private rsa key pair."
	echo "For automatic backups, give empty passphrase."
	echo
	sudo ssh-keygen -qt rsa -C "root@$HOSTNAME" -f $FILE
fi

echo
echo "On backup server [$SERVER], # sudo useradd ${BUSER} -g backup -s /bin/sh"
echo "with .ssh/authorized_keys having:"
echo
sudo cat $FILE.pub
echo

sudo tee $CMD > /dev/null << EOF
#!/bin/sh
sudo rsync $PARAMS -e ssh $DIRS $BUSER@$SERVER:/
EOF
sudo chmod +x $CMD

if sudo crontab -l | grep -q "$CMD"; then
	echo "Cron backup already set, see # sudo crontab -l"
else
	(sudo crontab -l ; echo "$CRONOPTS $CMD") 2>&1 | sed "s/no crontab for root//" | sort | uniq | sudo crontab -
	echo "Installed new cronjob for root"
	sudo crontab -l
fi

echo
echo "do first backup now to auth known host"
echo "# backup"
