#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

TEMPLATE="https://tools.deltazero.cz/server/template_apache2.zip";

echo
echo "## Installing apache2..."

sudo apt -yqq install apache2 certbot python3-certbot-apache
sudo service apache2 stop

sudo chown -R $USER:$USER /etc/apache2
[[ -f /etc/apache2/sites-available/default-ssl.conf ]] && rm /etc/apache2/sites-available/default-ssl.conf
cat > /etc/apache2/sites-available/000-default.conf << EOF
ServerName     $HOSTNAME
ServerAdmin    root@$HOSTNAME

<VirtualHost _default_:80>
  DocumentRoot  "/home/www/_default"
</VirtualHost>
EOF

cat > /etc/apache2/conf-available/home.conf << EOF
<Directory /home/www/>
	Options -Indexes +FollowSymLinks
	AllowOverride All
	Require all granted
</Directory>
EOF

sudo a2enmod -q ssl rewrite http2
sudo a2enconf -q home

[[ ! -x /home/www ]] && sudo mkdir /home/www
[[ ! -L ~/www ]] && ln -s /home/www ~/www

[[ ! -L /etc/apache2/log ]] && sudo ln -s /var/log/apache2 /etc/apache2/log
[[ ! -x ~/conf ]] && mkdir ~/conf
[[ ! -L ~/conf/apache2 ]] && ln -s /etc/apache2 ~/conf/apache2
[[ ! -L ~/conf/sites ]] && ln -s /etc/apache2/sites-available ~/conf/sites

wget -q $TEMPLATE -O template.zip
if [[ -f template.zip ]]; then
	[[ -d /home/www/_default ]] && sudo rm -r /home/www/_default
	sudo unzip -q template.zip -d /home/www/
	sudo chown -R $USER:$USER /home/www/_default
	rm template.zip

	IP=`dig @resolver1.opendns.com ANY myip.opendns.com +short`
	sed -i "s/__hostname__/$HOSTNAME/" /home/www/_default/index.html
	sed -i "s/__name__/${HOSTNAME%%.*}/" /home/www/_default/index.html
	sed -i "s/__ip__/$IP/" /home/www/_default/index.html
fi

sudo service apache2 start

echo
while true; do
	echo -n "Install SSL certificate for $HOSTNAME [y/n] "
	read answer
	if [[ $answer = 'Y' ]] || [[ $answer = 'y' ]]; then
		echo "Obtaining certificte from letsencrypt.org..."
		sudo certbot certonly --apache -d $HOSTNAME --register-unsafely-without-email --agree-tos --quiet
		if [[ -f /etc/letsencrypt/renewal/$HOSTNAME.conf ]]; then
			cat > /etc/apache2/sites-available/000-default.conf << EOF
ServerName		$HOSTNAME

<VirtualHost _default_:80>
	RewriteEngine	On
	RewriteRule		^(.*)$				https://$HOSTNAME%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:443>
	ServerName		$HOSTNAME

	DocumentRoot	"/home/www/_default"
  Protocols h2 h2c http/1.1

  SSLCertificateFile /etc/letsencrypt/live/$HOSTNAME/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/$HOSTNAME/privkey.pem
  Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
EOF

			sudo service apache2 reload
			CRONOPTS="20 20 20 * *   "
			CMD=`which certbot`

			if sudo crontab -l | grep -q "$CMD"; then
				echo "Cron certbot renewal already set, see # sudo crontab -l"
			else
				(sudo crontab -l ; echo "$CRONOPTS $CMD") 2>&1 | sed "s/no crontab for root//" | sort | uniq | sudo crontab -
				echo "Installed new cronjob for root"
				sudo crontab -l
			fi

			echo "All set, see https://$HOSTNAME :)"
		else
			echo "Unable to set up SSL"
		fi

		break
	elif [[ $answer = 'n' ]] || [[ $answer = 'N' ]]; then
		break
	fi
done

echo
echo "Installed Apache"
apache2 -v | head -n 1
