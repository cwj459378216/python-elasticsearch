# -*- coding:utf8 -*-

# python -m pip install elasticsearch
from elasticsearch import Elasticsearch
from elasticsearch import helpers
from argparse import ArgumentParser
import json
import functools
import time
import datetime

host = '192.168.1.75'
conn = 'omni-bro-conn'
newIndex = 'omni-bro-conn-9'

es = Elasticsearch(hosts=[{'host': host, 'port': 9200}])

# get param


def parse_args():
    parser = ArgumentParser()
    parser.add_argument("--m", dest="minute", help="set minute")
    parser.add_argument("--h", dest="hour", help="set hour")
    parser.add_argument("--d", dest="day", help="set day")

    return parser.parse_args()

# obj2json


def esjson(func):
    @functools.wraps(func)
    def wrapper(*args, **kw):
        res = func(*args, **kw)
        data = json.dumps(res, sort_keys=True, indent=4, separators=(
            ',', ':'), encoding='gbk', ensure_ascii=True)
        return data
    return wrapper


@esjson
def printjson(func):
    return func

# time conversion


def timeRange():
    time_now = int(time.time())
    # 先获得时间数组格式的日期
    timeAgo = (datetime.datetime.now() - datetime.timedelta(days=10000))
    # 转换为时间戳
    timeStampOld = int(time.mktime(timeAgo.timetuple()))
    timeStampNew = int(time.mktime(datetime.datetime.now().timetuple()))
    # 转换为其他字符串格式
    # otherStyleTime = threeDayAgo.strftime("%Y-%m-%d %H:%M:%S")
    # print(otherStyleTime)
    startTime = datetime.datetime.utcfromtimestamp(
        timeStampOld).strftime("%Y-%m-%dT%H:%M:%SZ")
    endTime = datetime.datetime.utcfromtimestamp(
        timeStampNew).strftime("%Y-%m-%dT%H:%M:%SZ")
    print(startTime)
    print(endTime)
    query(startTime, endTime)

# if created


def created():
    print (es.indices.exists(index=newIndex))
    if not es.indices.exists(index=newIndex):
        # es.indices.create(index=newIndex)
        # created mapping
        body = {
            "mappings": {
                'properties': {
                        "origBytes": {
                            "type": "integer"
                        },
                        "origPkts": {
                            "type": "long"
                        },
                        "respBytes": {
                            "type": "long"
                        },
                        "respPkts": {
                            "type": "integer"
                        },
                        "sumBytes": {
                            "type": "long"
                        },
                        "timestamp": {
                            "type": "date",
                            "format": "strict_date_optional_time||epoch_millis||yy/mm/dd-HH:mm:ss.SSSSSS"
                        }
                    }
            }
        }
        # create(self, index, body=None, params=None, headers=None)
        result = es.indices.create(index=newIndex, body=body, ignore=[
                                   400, 401, 404])  # 忽略index存在了不能新建的错误
        print(result)

# insert


def insert():
    b = {"name": 'lu', 'sex': 'female', 'age': 10}
    es.index(index='bank_test_1', body=b, id=None)


def timer(func):
    def wrapper(*args, **kwargs):
        # start = time.time()
        res = func(*args, **kwargs)
        # print('共耗时约 {:.2f} 秒'.format(time.time() - start))
        return res

    return wrapper

# @timer
# def create_data():
#     """ 写入数据 """
#     for line in range(100):
#         es.index(index='s2', doc_type='doc', body={'title': line})


@timer
def batch_data(action):
    # """ 批量写入数据 """
    # action = [{
    #     "_index": newIndex,
    #     "_source": {
    #         "origBytes": 11,
    #         "origPkts": 22,
    #         "respBytes": 33,
    #         "respPkts": 44,
    #         "timestamp": "2021-04-15T09:21:47.631601"
    #     }
    # } for i in range(2)]
    # print(action)
    helpers.bulk(es, action)


# create action
def createAction(bucket, nowDate):
    sumBytes = bucket.get('sum_bytes').get('value')
    sumRespBytes = bucket.get('sum_resp_bytes').get('value')
    sumOrigBytes = bucket.get('sum_orig_bytes').get('value')
    sumRespPackets = bucket.get('sum_resp_packets').get('value')
    sumOrigPackets = bucket.get('sum_orig_packets').get('value')
    protocol = bucket.get('key')
    docCount = bucket.get('doc_count')
    return {
        "_index": newIndex,
        "_source": {
            "origBytes": sumOrigBytes,
            "origPkts": sumOrigPackets,
            "respBytes": sumRespBytes,
            "respPkts": sumRespPackets,
            "sumBytes": sumBytes,
            "protocol": protocol,
            "docCount": docCount,
            "timestamp": nowDate
        }
    }

# query


def query(startTime, endTime):
    body = {
        "size": 0,
        "query": {
            "bool": {
                "filter": [
                    {
                        "range": {
                            "timestamp": {
                                "from": startTime,
                                "to": endTime,
                            }
                        }
                    }
                ]
            }
        },
        "aggregations": {
            "distribute_by_key": {
                "terms": {
                    "field": "protocol.keyword",
                    "size": 10000,
                },
                "aggregations": {
                    "sum_orig_bytes": {
                        "sum": {
                            "field": "origIpBytes"
                        }
                    },
                    "sum_resp_bytes": {
                        "sum": {
                            "field": "respIpBytes"
                        }
                    },
                    "sum_orig_packets": {
                        "sum": {
                            "field": "origPkts"
                        }
                    },
                    "sum_resp_packets": {
                        "sum": {
                            "field": "respPkts"
                        }
                    },
                    "sum_bytes": {
                        "sum": {
                            "script": {
                                "source": "doc['origIpBytes'].value + doc['respIpBytes'].value",
                                "lang": "painless"
                            }
                        }
                    }
                }
            }
        }
    }
    # print printjson(es.count(index="bank",body=body))
    print (es.search(index=conn, body=body).get(
        'aggregations').get('distribute_by_key').get('buckets'))
    buckets = es.search(index=conn, body=body).get(
        'aggregations').get('distribute_by_key').get('buckets')
    arr = []
    for bucket in buckets:
        arr.append(createAction(bucket, endTime))
        print(arr)
    # print (printjson(es.search(index=conn, body=body)))
    batch_data(arr)

if __name__ == '__main__':
    # ret = parse_args()
    # print(ret.minute, ret.hour, ret.day)
    created()
    timeRange()
    # batch_data()
