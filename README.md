## python 对 elasticsearch 的操作
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python get-pip.py
python -m pip install elasticsearch


## top500 查询
1M 查询
python /datastore/user/admin/script/rollup.py --topNSize=500 --topNField="origIpBytes,respIpBytes"

5M 
python /datastore/user/admin/script/rollup.py --m=5 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m"

10M
python /datastore/user/admin/script/rollup.py --m=10 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m-5m"

15M
python /datastore/user/admin/script/rollup.py --m=15 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m-5m-10m"

30M
python /datastore/user/admin/script/rollup.py --m=30 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m-5m-10m-15m"

1H
python /datastore/user/admin/script/rollup.py --h=1 --topNSize=500 --topNField="origIpBytes,respIpBytes" --index="omni-bro-conn-1m-5m-10m-15m-30m"

topNField
python ./rollup.py --topNSize=5 --topNField="origPkts,respPkts"

## hostip 查询
python .\rollup.py --d=1 --index="omni-bro-conn" --field="srcIP" --showField="host"  --filter="{'bool':{'filter':[],'must_not':[{'match':{'severity':{'query':0,'operator':'OR','prefix_length':0,'max_expansions':50,'fuzzy_transpositions':true,'lenient':false,'zero_terms_query':'NONE','auto_generate_synonyms_phrase_query':true,'boost':1}}}],'should':[{'bool':{'should':[{'range':{'srcIP':{'from':'10.0.0.0','to':'10.255.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'srcIP':{'from':'172.16.0.0','to':'172.31.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'srcIP':{'from':'192.168.0.0','to':'192.168.255.255','include_lower':true,'include_upper':true,'boost':1}}}],'adjust_pure_negative':true,'boost':1}},{'bool':{'should':[{'range':{'dstIP':{'from':'10.0.0.0','to':'10.255.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'dstIP':{'from':'172.16.0.0','to':'172.31.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'dstIP':{'from':'192.168.0.0','to':'192.168.255.255','include_lower':true,'include_upper':true,'boost':1}}}],'adjust_pure_negative':true,'boost':1}}],'adjust_pure_negative':true,'boost':1}}"

python .\rollup.py --d=1 --index="omni-bro-conn" --field="dstIP" --showField="host"  --filter="{'bool':{'filter':[],'must_not':[{'match':{'severity':{'query':0,'operator':'OR','prefix_length':0,'max_expansions':50,'fuzzy_transpositions':true,'lenient':false,'zero_terms_query':'NONE','auto_generate_synonyms_phrase_query':true,'boost':1}}}],'should':[{'bool':{'should':[{'range':{'srcIP':{'from':'10.0.0.0','to':'10.255.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'srcIP':{'from':'172.16.0.0','to':'172.31.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'srcIP':{'from':'192.168.0.0','to':'192.168.255.255','include_lower':true,'include_upper':true,'boost':1}}}],'adjust_pure_negative':true,'boost':1}},{'bool':{'should':[{'range':{'dstIP':{'from':'10.0.0.0','to':'10.255.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'dstIP':{'from':'172.16.0.0','to':'172.31.255.255','include_lower':true,'include_upper':true,'boost':1}}},{'range':{'dstIP':{'from':'192.168.0.0','to':'192.168.255.255','include_lower':true,'include_upper':true,'boost':1}}}],'adjust_pure_negative':true,'boost':1}}],'adjust_pure_negative':true,'boost':1}}"

## protocol 聚合
python .\rollup.py --d=10000 --index="omni-bro-conn" --field="protocol.keyword" --showField="protocol"   --aggField="{'sum_origBytes':'integer','sum_respBytes':'long','sum_origPkts':'integer','sum_respPkts':'integer'}"