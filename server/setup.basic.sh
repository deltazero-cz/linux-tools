#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT

echo
echo -n "Update hostname? [$HOSTNAME]: "
read newhost
if [[ ! -z ${newhost} ]]; then
  sudo sh -c "echo ${newhost} > /etc/hostname"
  sudo hostname ${newhost}
  HOSTNAME=${newhost}
else
  echo "Skipping hostname setup"
fi

echo
echo "## Updating system..."

echo
if grep -q "Europe/UTC" /etc/timezone; then
  sudo dpkg-reconfigure tzdata
fi
# sudo locale-gen en_US en_US.UTF-8 # cs_CZ cs_CZ.UTF-8

sudo apt -qq update
sudo apt -yqq dist-upgrade
sudo apt -yqq install screen vim netcat ntp rsync fail2ban bash-completion git zip \
  lsb-release software-properties-common
sudo apt -yqq autoremove
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100

cat > ~/.bashrc << EOF
PS1='[\[\e[0;32m\]\u@\h \[\e[0;34m\]\W\[\e[0;00m\]]\$ ';

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -lhF'
alias la='ls -AF'
alias l='ls -CF'
alias s='sudo'
alias sus='sudo -s'
alias a2reload='sudo service apache2 reload'

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
EOF
sudo sh -c "echo complete -F _root_command s > /etc/bash_completion.d/s"

LINE='screen -R && exit'
FILE=~/.profile
grep -q "$LINE" "$FILE" || echo $LINE > $FILE

