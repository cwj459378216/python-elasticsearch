#!/bin/bash
#set -x

# topN 500
python /datastore/user/admin/script/rollup.py --topNSize=500 --topNField="origIpBytes,respIpBytes"

# topN ip protocol
# python /datastore/user/admin/script/rollup.py --index="omni-bro-conn" --field="protocol.keyword" --showField="protocol"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# topN Application Protocol
# python /datastore/user/admin/script/rollup.py --index="omni-bro-conn" --field="appName.keyword" --showField="appName"   --aggField="{'sum_origIpBytes':'integer','sum_respIpBytes':'integer','sum_origPkts':'long','sum_respPkts':'integer'}"

# host
# python /datastore/user/admin/script/rollup.py --index="omni-bro-conn" --field="srcIP" --showField="host"  --filter="{'bool':{'filter':[{'bool':{'should':[{'range':{'srcIP':{'from':'10.0.0.0','to':'10.255.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'srcIP':{'from':'172.16.0.0','to':'172.31.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'srcIP':{'from':'192.168.0.0','to':'192.168.255.255','include_lower':true,'include_upper':true,'boost':1}}}],'adjust_pure_negative':true,'boost':1}}]}}" --aggField="{'#_host':'ip'}"
# python /datastore/user/admin/script/rollup.py --index="omni-bro-conn" --field="dstIP" --showField="host"  --filter="{'bool':{'filter':[{'bool':{'should':[{'range':{'dstIP':{'from':'10.0.0.0','to':'10.255.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'dstIP':{'from':'172.16.0.0','to':'172.31.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'dstIP':{'from':'192.168.0.0','to':'192.168.255.255','include_lower':true,'include_upper':true,'boost':1}}}],'adjust_pure_negative':true,'boost':1}}]}}" --aggField="{'#_host':'ip'}"