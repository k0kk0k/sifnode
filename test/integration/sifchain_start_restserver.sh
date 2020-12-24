#!/bin/bash

#
# Sifnode entrypoint.
#

. /sifnode/test/integration/vagrantenv.sh

sifnodecli rest-server --laddr tcp://0.0.0.0:1317 &
