#!/bin/bash
#set -x

python /datastore/user/admin/script/topN500.py --h=1 --topNSize=10000 --topNField="origIpBytes,respIpBytes"
