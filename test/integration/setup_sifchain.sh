#!/bin/bash

set -x
set -e

. $(dirname $0)/vagrantenv.sh
. ${TEST_INTEGRATION_DIR}/shell_utilities.sh

pkill sifnodecli || true
pkill sifnoded || true
pkill ebrelayer || true

#
# scaffold and boot the dockerized localnet
#
BASEDIR=${BASEDIR} rake genesis:network:scaffold['localnet']

set_persistant_env_var NETDEF $NETWORKDIR/network-definition.yml $envexportfile
set_persistant_env_var MONIKER $(cat $NETDEF | to_json | jq -r '.[0].moniker') $envexportfile
set_persistant_env_var OWNER_PASSWORD $(cat $NETDEF | yq r - ".password") $envexportfile
set_persistant_env_var OWNER_ADDR $(cat $NETDEF | yq r - ".address") $envexportfile
set_persistant_env_var MNEMONIC "$(cat $NETDEF | yq r - ".mnemonic")" $envexportfile
set_persistant_env_var CHAINDIR $NETWORKDIR/validators/$CHAINNET/$MONIKER $envexportfile
set_persistant_env_var SIFNODED_LOG $datadir/logs/sifnoded.log $envexportfile
set_persistant_env_var EBRELAYER_LOG $datadir/logs/ebrelayer.log $envexportfile

rm -f $EBRELAYER_LOG
mkdir -p $datadir/logs
nohup $TEST_INTEGRATION_DIR/sifchain_start_daemon.sh > $SIFNODED_LOG 2>&1 &
set_persistant_env_var SIFNODED_PID $! $envexportfile
nohup sifnodecli rest-server --laddr tcp://0.0.0.0:1317 > $datadir/logs/restserver.log 2>&1 &
set_persistant_env_var REST_SERVER_PID $! $envexportfile
nohup $TEST_INTEGRATION_DIR/sifchain_start_ebrelayer.sh > $EBRELAYER_LOG 2>&1 &
set_persistant_env_var EBRELAYER_PID $! $envexportfile

# Wait for ebrelayer to subscribe

while [ ! -f $EBRELAYER_LOG ]
do
  sleep 10
done
tail -n +1 $EBRELAYER_LOG
#tail -n +1 -f $EBRELAYER_LOG | grep -m 1 "Subscribed"