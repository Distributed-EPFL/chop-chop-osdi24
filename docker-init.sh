#!/bin/bash
#
#   docker-init.sh - initialize a Chop Chop network from the control node
#
#   Tell each node in the system, as described by the setup file expected to
#   be in './mnt/setup.txt', what role they have in the network, create a Silk
#   environment file in 'env.sh' and, if present', sends the assets found in
#   'mnt/assets' to all nodes.
#
#   Syntax: docket-init.sh
#

set -e


./script/control-silk-env './mnt/setup.txt' > 'env.sh'
source 'env.sh'

./script/control-silk-kv './mnt/setup.txt'

if [ -e './mnt/assets' ] ; then
    silk send -t '/home/ubuntu' "${all}" './mnt/assets'
fi


exec /bin/bash
