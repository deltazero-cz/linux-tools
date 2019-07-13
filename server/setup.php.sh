#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

TEMPLATE="https://tools.deltazero.cz/server/template_php.zip";
PHP=php7.3
ETC=/etc/php/7.3

echo
echo "## Installing $PHP..."

if [[ `lsb_release -si` = 'Debian' ]]; then
	if [[ ! -f /etc/apt/sources.list.d/php.list ]]; then
		sudo wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
		sudo apt -qq update
	fi
elif [[ `lsb_release -si` = 'Ubuntu' ]]; then
	if [[ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-$(lsb_release -sc).list ]]; then
		sudo add-apt-repository ppa:ondrej/php
	fi
fi

sudo apt install -yqq $PHP-fpm $PHP-cli $PHP-bcmath $PHP-curl $PHP-imap $PHP-intl $PHP-json \
	$PHP-mbstring $PHP-soap	$PHP-readline $PHP-xml $PHP-xmlrpc $PHP-xsl $PHP-zip \
  $PHP-mysql $PHP-sqlite3 $PHP-mongodb \
	> /dev/null
sudo apt -yqq dist-upgrade
sudo apt -yqq autoremove

sudo chown -R $USER:$USER /etc/php

cat > $ETC/fpm/conf.d/99-custom.ini << EOF
upload_max_filesize = 128M
post_max_size = 256M
memory_limit = 1G
max_execution_time = 3600
max_input_vars = 10000
max_input_time = 3600
EOF

sudo service $PHP-fpm restart

if [[ -d /etc/apache2 ]]; then
	sudo a2enmod -q proxy_fcgi setenvif
	sudo a2enconf -q $PHP-fpm
	sudo service apache2 restart
fi

[[ ! -x ~/conf ]] && mkdir ~/conf
[[ ! -L ~/conf/php ]] && ln -s $ETC ~/conf/php

wget -q $TEMPLATE -O template.zip
if [[ -f template.zip ]]; then
	[[ -d /home/www/_default ]] && sudo rm -r /home/www/_default
	sudo unzip -q template.zip -d /home/www/
	sudo chown -R $USER:$USER /home/www/_default
	rm template.zip
fi

echo
echo -n "Installed "
php -v | head -n 1
