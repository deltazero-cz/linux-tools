#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT
#
# WARNING: Hot renaming is dangerous, especially via remote access
# -> you might lose access
# PROCEED AT YOUR OWN RISK

echo -n "Rename user? [$USER]: "
read newuser
if [[ ! -z ${newuser} ]]; then
  echo "First, set your password"
  sudo passwd $USER
  sudo su -c "\
    sed -i s/$USER/$newuser/g /etc/group \
    && sed -i s/$USER/$newuser/g /etc/shadow \
    && sed -i s/$USER/$newuser/g /etc/passwd \
    && mv /home/$USER/ /home/$newuser \
    && echo \"$newuser ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$newuser"
  # export USER=$newuser
  # export HOME=/home/$newuser
  echo
  echo "Your new username: $newuser"
  echo
  echo "Log out and reconnect as $newuser now! Then re-run this script"
  exit
else
  echo "Username unchanged"
  exit 1
fi
