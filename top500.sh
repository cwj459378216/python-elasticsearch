#!/bin/bash
#set -x

python /datastore/user/admin/web/script/topN500.py --h=1 --topNSize=500 --topNField="origIpBytes,respIpBytes"


python /datastore/user/admin/web/script/topN500.py --createdIndex="omni-bro-conn-art-1h" --h=1  --topNSize=500 --topNField="kpiART"
