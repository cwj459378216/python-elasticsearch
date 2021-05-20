#!/bin/bash
#set -x

# topN 500
python /datastore/user/admin/script/rollup.py --m=15 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m-5m-10"

# topN protocol
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-protocol1m-protocol5m-protocol10m" --m=15 --field="protocol.keyword" --showField="protocol"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# topN Application Protocol
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-appname1m-appname5m-appname10m" --m=15 --field="appName.keyword" --showField="appName"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# host
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-host1m-host5m-host10m" --m=15 --field="host" --showField="host"  --aggField="{'#_host':'ip'}"