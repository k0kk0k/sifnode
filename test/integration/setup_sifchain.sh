#!/bin/bash

set -x
set -e

. $(dirname $0)/vagrantenv.sh
. ${TEST_INTEGRATION_DIR}/shell_utilities.sh

#
# scaffold and boot the dockerized localnet
#
BASEDIR=${BASEDIR} rake genesis:network:scaffold['localnet']
# see deploy/rake/genesis.rake for the description of the args to genesis:network:boot
# :chainnet, :eth_bridge_registry_address, :eth_keys, :eth_websocket
BASEDIR=${BASEDIR} rake genesis:network:boot["localnet,${ETHEREUM_CONTRACT_ADDRESS},c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3,ws://genesis_ganachecli_1:7545/"]

sleep 15

#
# Wait for the Websocket subscriptions to be initialized (like 10 seconds)
#
docker logs -f ${CONTAINER_NAME} | grep -m 1 "Subscribed"

# We need to forward the port used by ganache, since adding new network didn't allow
# using the cli
docker exec ${CONTAINER_NAME} bash -c "bash /test/integration/start-ganache-port-forwarding.sh"

# those rake commands generate yaml that provides useful usernames and passwords
# wait for it to appear

set_persistant_env_var NETDEF $NETWORKDIR/network-definition.yml $envexportfile
while [ ! -f $NETDEF ]
do
  sleep 2
done

set_persistant_env_var MONIKER $(cat ${NETWORKDIR}/network-definition.yml | to_json | jq '.[0].moniker') $envexportfile
set_persistant_env_var OWNER_PASSWORD $(cat $NETDEF | yq r - ".password") $envexportfile
set_persistant_env_var OWNER_ADDR $(cat $NETDEF | yq r - ".address") $envexportfile