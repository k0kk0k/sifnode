#!/bin/bash

set -x
set -e

. $(dirname $0)/vagrantenv.sh
. ${BASEDIR}/test/integration/shell_utilities.sh

docker exec ${CONTAINER_NAME} bash -c ". /test/integration/vagrantenv.sh; cd /sifnode; SMART_CONTRACTS_DIR=/smart-contracts python3 /test/integration/initial_test_balances.py /network-definition.yml"
sleep 15
docker exec ${CONTAINER_NAME} bash -c ". /test/integration/vagrantenv.sh; cd /sifnode; SMART_CONTRACTS_DIR=/smart-contracts python3 /test/integration/peggy-basic-test-docker.py /network-definition.yml"
docker exec ${CONTAINER_NAME} bash -c '. /test/integration/vagrantenv.sh; cd /sifnode; SMART_CONTRACTS_DIR=/smart-contracts python3 /test/integration/peggy-e2e-test.py /network-definition.yml'
