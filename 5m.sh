#!/bin/bash
#set -x

# topN 500
python /datastore/user/admin/script/rollup.py --m=5 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m"

# topN protocol
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-protocol1m" --m=5 --field="protocol.keyword" --showField="protocol"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# topN Application Protocol
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-appname1m" --m=5 --field="appName.keyword" --showField="appName"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# host
python /datastore/user/admin/script/rollup.py --index="omni-bro-conn-host1m" --m=5 --field="host" --showField="host"  --aggField="{'#_host':'ip'}"