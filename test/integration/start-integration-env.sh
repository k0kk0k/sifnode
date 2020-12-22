#!/bin/bash
# must run from the root directory of the sifnode tree

set -e # exit on any failure

BASEDIR=$(pwd)/$(dirname $0)/../..

. ${BASEDIR}/test/integration/shell_utilities.sh

export envexportfile=$BASEDIR/test/integration/vagrantenv.sh
rm -f $envexportfile

set_persistant_env_var envexportfile $envexportfile $envexportfile
set_persistant_env_var BASEDIR $BASEDIR $envexportfile
set_persistant_env_var datadir $BASEDIR/test/integration/vagrant/data $envexportfile
set_persistant_env_var CONTAINER_NAME integration_sifnode1_1 $envexportfile
set_persistant_env_var NETWORKDIR $BASEDIR/deploy/networks $envexportfile
set_persistant_env_var GANACHE_DB_DIR $(mktemp -d --tmpdir ganachedb.XXXX) $envexportfile

# Create the docker network
# (use inspect to see if it exists before creating it again)
docker network inspect sifchain_integration > /dev/null 2>&1 || docker network create sifchain_integration

#
# Remove prior generations Config
#
sudo rm -rf $NETWORKDIR && mkdir $NETWORKDIR
rm -rf ${BASEDIR}/smart-contracts/build ${BASEDIR}/smart-contracts/.openzeppelin
make -C ${BASEDIR} install

# ===== Everything from here on down is executed in the $BASEDIR/smart-contracts directory
cd $BASEDIR/smart-contracts

# Startup ganache-cli (https://github.com/trufflesuite/ganache)

cp $BASEDIR/test/integration/.env.ciExample .env

yarn --cwd $BASEDIR/smart-contracts install
export YARN_CACHE_DIR=$(yarn cache dir)
echo "export YARN_CACHE_DIR=$YARN_CACHE_DIR" >> $envexportfile

docker-compose --project-name genesis -f $BASEDIR/test/integration/docker-compose-ganache.yml up -d --force-recreate

# https://www.trufflesuite.com/docs/truffle/overview
# and note that truffle migrate and truffle deploy are the same command
truffle compile
truffle deploy --network develop --reset
# ETHEREUM_CONTRACT_ADDRESS is used for the BridgeRegistry address in many places, so we
# set it and BRIDGE_REGISTRY_ADDRESS to the same value
BRIDGE_REGISTRY_ADDRESS=$(cat $BASEDIR/smart-contracts/build/contracts/BridgeRegistry.json | jq '.networks["5777"].address')
ETHEREUM_CONTRACT_ADDRESS=$BRIDGE_REGISTRY_ADDRESS
if [ -z "$ETHEREUM_CONTRACT_ADDRESS" ]; then
  echo ETHEREUM_CONTRACT_ADDRESS cannot be empty
  exit 1
fi
echo "export ETHEREUM_CONTRACT_ADDRESS=$ETHEREUM_CONTRACT_ADDRESS" >> $envexportfile
echo "# BRIDGE_REGISTRY_ADDRESS and ETHEREUM_CONTRACT_ADDRESS are synonyms">> $envexportfile
echo "export BRIDGE_REGISTRY_ADDRESS=$BRIDGE_REGISTRY_ADDRESS" >> $envexportfile

export BRIDGE_BANK_ADDRESS=$(cat $BASEDIR/smart-contracts/build/contracts/BridgeBank.json | jq '.networks["5777"].address')
if [ -z "BRIDGE_BANK_ADDRESS" ]; then
  echo BRIDGE_BANK_ADDRESS cannot be empty
  exit 1
fi
echo "export BRIDGE_BANK_ADDRESS=$BRIDGE_BANK_ADDRESS" >> $envexportfile

ADD_VALIDATOR_TO_WHITELIST=1 bash ${BASEDIR}/test/integration/setup_sifchain.sh && . $envexportfile

docker exec ${CONTAINER_NAME} bash -c "cd /smart-contracts && yarn install"

#
# Add keys for a second account to test functions against
#
docker exec ${CONTAINER_NAME} bash -c "/test/integration/add-second-account.sh"

export USER1ADDR=$(cat $NETDEF | yq r - "[1].address")
echo "export USER1ADDR=$USER1ADDR" >> $envexportfile