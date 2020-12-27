#!/bin/bash
set -x
BASEDIR=$(pwd)
PASSWORD=$(yq r $NETDEF "(*==$MONIKER).password")
ADDR=$(yq r $NETDEF "(*==$MONIKER).address")

yes $PASSWORD | sifnodecli keys add user1

yes $PASSWORD | sifnodecli keys show user1 >> /network-definition.yml

