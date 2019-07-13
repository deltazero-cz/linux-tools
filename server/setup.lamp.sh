#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

echo "Installing all of LAMP"

run () {
	if [[ -f $1 ]]; then
		bash $1
	else
		bash <(curl -s "https://tools.deltazero.cz/server/$1")
	fi
}

run "setup.apache.sh"
run "setup.php.sh"
run "setup.mysql.sh"
