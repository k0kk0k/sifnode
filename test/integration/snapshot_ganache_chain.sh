#!/bin/bash

. $(dirname $0)/vagrantenv.sh
GANACHE_DB_DIR=${1:=$GANACHE_DB_DIR}
shift

newganachedir=$(mktemp -d --tmpdir ganachedbSnapshot.XXXX)
sudo rsync -a $GANACHE_DB_DIR/ $newganachedir/
echo $newganachedir