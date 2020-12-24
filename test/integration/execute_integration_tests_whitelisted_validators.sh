#!/bin/bash

set -x
set -e

. $(dirname $0)/vagrantenv.sh
. ${BASEDIR}/test/integration/shell_utilities.sh

# Rebuild sifchain, but this time don't use validators

sudo rm -rf $NETWORKDIR && mkdir $NETWORKDIR
ADD_VALIDATOR_TO_WHITELIST= bash ${BASEDIR}/test/integration/setup_sifchain.sh && . $envexportfile

docker exec ${CONTAINER_NAME} bash -c ". /test/integration/vagrantenv.sh; cd /sifnode; SMART_CONTRACTS_DIR=/smart-contracts python3 /test/integration/no_whitelisted_validators.py /network-definition.yml"
