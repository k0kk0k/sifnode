#!/bin/bash

basedir=$(dirname $0)
. $basedir/vagrantenv.sh

bash $basedir/sifchain_logs.sh
docker logs genesis_ganachecli_1 > ${datadir}/ganachelog.txt 2>&1
cp /sifnode/smart-contracts/.env > ${datadir}/env
cp /sifnode/test/integration/vagrantenv.sh > ${datadir}/vagrantenv.sh
#touch /tmp/bridgebank.txt && cat /tmp/bridgebank.txt > ${datadir}/bridgebank.txt
( cd $SMART_CONTRACTS_DIR && truffle networks ) > ${datadir}/trufflenetworks.txt
sudo rsync -a $GANACHE_DB_DIR/ ${datadir}/ganachedb/ && chown -R $(id -u) ${datadir}/ganachedb/
