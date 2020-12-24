#!/bin/bash

# Takes a snapshot of the ganache data directory and prints
# the snapshot directory

set -ex

. $(dirname $0)/vagrantenv.sh
. $TEST_INTEGRATION_DIR/shell_utilities.sh

echo ${datadir}/ganachelog.txt.$(filenamedate)
