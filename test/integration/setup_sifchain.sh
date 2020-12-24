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
set_persistant_env_var MONIKER $(cat cat $NETDEF | to_json | jq -r '.[0].moniker') $envexportfile
set_persistant_env_var OWNER_PASSWORD $(cat $NETDEF | yq r - ".password") $envexportfile
set_persistant_env_var OWNER_ADDR $(cat $NETDEF | yq r - ".address") $envexportfile
set_persistant_env_var MNEMONIC "$(cat $NETDEF | yq r - ".mnemonic")" $envexportfile
set_persistant_env_var CHAINDIR $NETWORKDIR/validators/$CHAINNET/$MONIKER $envexportfile

mkdir -p $datadir/logs
nohup $TEST_INTEGRATION_DIR/sifchain_start_daemon.sh > $datadir/logs/daemon.log 2>&1 &
nohup $TEST_INTEGRATION_DIR/sifchain_start_restserver.sh > $datadir/logs/restserver.log 2>&1 &
nohup $TEST_INTEGRATION_DIR/sifchain_start_relayer.sh > $datadir/logs/relayer.log 2>&1 &

# BASEDIR=${BASEDIR} rake genesis:network:boot["localnet,${ETHEREUM_CONTRACT_ADDRESS},c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3,ws://genesis_ganachecli_1:7545/"]


#
# Wait for the Websocket subscriptions to be initialized (like 10 seconds)
#
tail -f $datadir/logs/relayer.log | grep -m 1 "Subscribed"