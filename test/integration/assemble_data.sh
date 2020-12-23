#!/bin/bash

basedir=$(dirname $0)
. $basedir/vagrantenv.sh

bash $basedir/sifchain_logs.sh
docker exec integration_sifnode1_1 cat /tmp/testrun.sh > ${datadir}/clicmds.txt
docker logs integration_sifnode1_1 > ${datadir}/integrationlog.txt 2>&1
docker logs genesis_ganachecli_1 > ${datadir}/ganachelog.txt 2>&1
cat /sifnode/smart-contracts/.env > ${datadir}/env
cat /sifnode/test/integration/vagrantenv.sh > ${datadir}/vagrantenv.sh
touch /tmp/bridgebank.txt && cat /tmp/bridgebank.txt > ${datadir}/bridgebank.txt
( cd /sifnode/smart-contracts && truffle networks ) > ${datadir}/trufflenetworks.txt
sudo rsync -a $GANACHE_DB_DIR/ ${datadir}/ganachedb/ && chown -R $(id -u) ${datadir}/ganachedb/
