#!/usr/bin/env bash
#
# Copyright (c) 2019 David Obdržálek, ΔO [deltazero.cz]
# License: MIT
#
# Setup minimal environment for sh, bash & rsync inside a chrooted dir

echo -n "Is this the correct chroot dir: $PWD [Y/n] "
read answer
if [[ ! -z $answer ]] && [[ $answer != 'Y' ]] && [[ $answer != 'y' ]]; then
  echo "Abort."
  exit 1
fi

echo
echo "Doing magic..."

copies=$((ldd `which sh`; ldd `which bash`; ldd `which rsync`) | awk '/\// { print ($3 ? $3 : $1) }' | sort | uniq)
copies+=" $(which sh) $(which bash) $(which rsync)"
# echo $copies; exit

for f in $copies; do
  d=$(dirname ${f})
  [[ ! -d ".$d" ]] && sudo mkdir -p ".$d"
  [[ ! -f ".$f" ]] && sudo cp -v "$f" ".$f"
done

echo
echo "All set, rsync will now work in $PWD"
