#!/bin/bash

set -e

basedir=$(dirname $0)
. $basedir/vagrantenv.sh

output=$datadir/sifchaintxs.txt
rm -f $output

hashes=$(cat SIFNODED_LOG | grep "^txhash: " | sed -e "s/txhash: //")
for i in $hashes
do
  sifnodecli q tx $i >> $output
done
