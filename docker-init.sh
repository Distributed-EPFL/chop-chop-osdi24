#!/bin/bash
#
#
#

set -e


./script/control-silk-env './mnt/setup.txt' > 'env.sh'
source 'env.sh'

./script/control-silk-kv './mnt/setup.txt'

if [ -e './mnt/assets' ] ; then
    silk send -t '/home/ubuntu' "${all}" './mnt/assets'
fi


exec /bin/bash
