# -*- coding:utf8 -*-

# python -m pip install elasticsearch
# python -m pip install requests
from elasticsearch import Elasticsearch
import requests
import json
import re
from argparse import ArgumentParser

def parse_args():
    parser = ArgumentParser()
    parser.add_argument("--lua", dest="lua",
                        help="Select lua file")
    return parser.parse_args()                    


def readLua():
    # f = open("./beat_config.lua")
    f = open(ret.lua)
    lines = f.readlines()
    bool = False
    sum = 0
    str_pat = re.compile(r'\"(.*)\"')
    for line in lines:
        if "RealTimeLogMonitor" in line:
            bool = True
        if bool:
            if not (re.match('}', line) is None):
                bool = False
            if re.match('--', line) is None:
                if sum == 0:
                    jsonMapping = {}
                if "index   =" in line:
                    sum += 1
                    jsonMapping["index"] = str_pat.findall(line)[0]
                if "mapping =" in line:
                    sum += 1
                    jsonMapping["mapping"] = str_pat.findall(line)[0]
                if "type    =" in line:
                    sum += 1
                    jsonMapping["type"] = str_pat.findall(line)[0]
                if sum == 3:
                    sum = 0
                    arr.append(jsonMapping)
    print arr
    f.close()


def readJson(filePath):
    with open(filePath, 'r') as load_f:
        load_dict = json.load(load_f)
        print(load_dict)
        return load_dict


def createdMapping():
    for i in arr:
        indexNew = i.get('index')
        doc = i.get('type')
        # mapping = i.get('mapping')
        mapping = readJson(i.get('mapping'))
        if not es.indices.exists(index=indexNew):
            body = {
                "mappings": {
                    doc: mapping
                }
            }
            print body
            result = es.indices.create(index=indexNew, body=body, ignore=[
                                       400, 401, 404])
            print(result)
            # body = {
            #     "mappings": {
            #         "doc": {
            #             'properties': {
            #                 "timestamp": {
            #                     "type": "date",
            #                     "format": "strict_date_optional_time||epoch_millis||yy/mm/dd-HH:mm:ss"
            #                 }
            #             }
            #         }
            #     }
            # }
            # result = es.indices.create(index=newIndex, body=body, ignore=[
            #                            400, 401, 404])
            # print(result)


def createKibanaIndex():
    kibanaUrl = "http://" + host + ":" + str(kibanaPort)
    createUrl = kibanaUrl + "/api/saved_objects/index-pattern"
    setDefaultIndex = kibanaUrl + "/api/kibana/settings/defaultIndex"
    headers = {'kbn-xsrf': 'true'}
    for mappings in arr:
        r = requests.post(createUrl, data=json.dumps(
            {"attributes": {"title": mappings.get('index')}}), headers=headers)
        if mappings.get('index') == "omni-bro-conn":
            params = {"value": json.loads(r.text).get("id")}
            requests.post(setDefaultIndex, data=json.dumps(
                params), headers=headers)
    print r.text


if __name__ == '__main__':
    host = 'localhost'
    esProt = 9200
    kibanaPort = 5601
    ret = parse_args()
    es = Elasticsearch(hosts=[{'host': host, 'port': esProt}])
    arr = []
    readLua()
    createdMapping()
    createKibanaIndex()
