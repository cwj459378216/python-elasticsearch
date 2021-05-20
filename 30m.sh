#!/bin/bash
#set -x

# topN 500
python /datastore/user/admin/script/rollup.py --m=30 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m-5m-10m-15m"

# topN protocol
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-protocol1m-protocol5m-protocol10m-protocol15m" --m=30 --field="protocol.keyword" --showField="protocol"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# topN Application Protocol
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-appname1m-appname5m-appname10m-appname15m" --m=30 --field="appName.keyword" --showField="appName"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# host
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-host1m-host5m-host10m-host15m" --m=30 --field="host" --showField="host"  --aggField="{'#_host':'ip'}"