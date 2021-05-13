#!/bin/bash
#set -x
python /datastore/user/admin/script/rollup.py "omni-bro-conn" --field="protocol.keyword" --showField="protocol"   --aggField="{'sum_origBytes':'integer','sum_respBytes':'long','sum_origPkts':'integer','sum_respPkts':'integer'}"