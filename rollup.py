# -*- coding:utf8 -*-

# python -m pip install elasticsearch
from elasticsearch import Elasticsearch
from elasticsearch import helpers
from argparse import ArgumentParser
import json
import functools
import time
import datetime


def parse_args():
    parser = ArgumentParser()
    parser.add_argument("index")
    parser.add_argument('aggField')
    parser.add_argument("--m", dest="minutes", help="set minutes", default="1")
    parser.add_argument("--h", dest="hours", help="set hours")
    parser.add_argument("--d", dest="days", help="set days")
    parser.add_argument("--field", dest="field",
                        help="set field")
    parser.add_argument("--filter", dest="filter",
                        help="set filter")
    return parser.parse_args()


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


def timeRange():
    time_now = int(time.time())
    if not (ret.hours is None):
        timeAgo = (datetime.datetime.now() -
                   datetime.timedelta(hours=float(ret.hours)))
    elif not (ret.days is None):
        timeAgo = (datetime.datetime.now() -
                   datetime.timedelta(days=float(ret.days)))
    else:
        timeAgo = (datetime.datetime.now() -
                   datetime.timedelta(minutes=float(ret.minutes)))
    timeStampOld = int(time.mktime(timeAgo.timetuple()))
    timeStampNew = int(time.mktime(datetime.datetime.now().timetuple()))
    startTime = datetime.datetime.utcfromtimestamp(
        timeStampOld).strftime("%Y-%m-%dT%H:%M:%SZ")
    endTime = datetime.datetime.utcfromtimestamp(
        timeStampNew).strftime("%Y-%m-%dT%H:%M:%SZ")
    query(startTime, endTime)


def created():
    if not es.indices.exists(index=newIndex):
        body = {
            "mappings": {
                'properties': {
                    "timestamp": {
                        "type": "date",
                        "format": "strict_date_optional_time||epoch_millis||yy/mm/dd-HH:mm:ss"
                    }
                }
            }
        }
        if not (ret.aggField is None):
            for k, v in aggFieldObj.items():
                kArr = k.split('_')
                way = kArr[0]
                kArr.remove(way)
                f = "".join(kArr)
                body.get("mappings").get("properties")[f] = {"type": v}
        result = es.indices.create(index=newIndex, body=body, ignore=[
                                   400, 401, 404])


def timer(func):
    def wrapper(*args, **kwargs):
        res = func(*args, **kwargs)
        return res
    return wrapper


@timer
def batch_data(action):
    helpers.bulk(es, action)


def createAction(bucket, nowDate):
    action = {
        "_index": newIndex,
        "_source": {
            "timestamp": nowDate
        }
    }

    if not (ret.field is None):
        action.get('_source')[ret.field] = bucket.get('key')
        action.get('_source')['docCount'] = bucket.get('doc_count')

    for k, v in aggFieldObj.items():
        kArr = k.split('_')
        way = kArr[0]
        kArr.remove(way)
        f = "".join(kArr)
        action.get('_source')[f] = bucket.get(k).get('value')
    return action


def query(startTime, endTime):
    body = {
        "size": 0,
        "aggregations": {
            "distribute_by_key": {
                # "terms": {
                #     "field": aggField,
                #     "size": aggSize,
                # },
                # "aggregations": {
                #     "sum_orig_bytes": {
                #         "sum": {
                #             "field": "origIpBytes"
                #         }
                #     },
                #     "sum_resp_bytes": {
                #         "sum": {
                #             "field": "respIpBytes"
                #         }
                #     },
                #     "sum_orig_packets": {
                #         "sum": {
                #             "field": "origPkts"
                #         }
                #     },
                #     "sum_resp_packets": {
                #         "sum": {
                #             "field": "respPkts"
                #         }
                #     }
                # }
            }
        }
    }
    if not (ret.filter is None):
        queryFilter = json.loads(ret.filter.replace("'", "\""))
        queryFilter.get("bool").get("filter").append({
            "range": {
                "timestamp": {
                    "from": startTime,
                    "to": endTime,
                }
            }
        })
        body["query"] = queryFilter
    else:
        body["query"] = {"bool": {
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
        }}

    if not (ret.field is None):
        body.get('aggregations').get('distribute_by_key')[
            'terms'] = {"field": aggField, "size": aggSize}
        if not (ret.aggField is None):
            body.get('aggregations').get(
                'distribute_by_key')['aggregations'] = {}
            for k, v in aggFieldObj.items():
                kArr = k.split('_')
                way = kArr[0]
                kArr.remove(way)
                f = "".join(kArr)
                body.get('aggregations').get('distribute_by_key')[
                    'aggregations'][k] = {way: {"field": f}}
        buckets = es.search(index=index, body=body).get(
            'aggregations').get('distribute_by_key').get('buckets')
        arr = []
        for bucket in buckets:
            arr.append(createAction(bucket, endTime))
        batch_data(arr)
    elif not (ret.aggField is None):
        body['aggregations'] = {}
        for k, v in aggFieldObj.items():
            kArr = k.split('_')
            way = kArr[0]
            kArr.remove(way)
            f = "".join(kArr)
            body['aggregations'][k] = {way: {"field": f}}
        buckets = es.search(index=index, body=body).get('aggregations')
        batch_data([createAction(buckets, endTime)])
    print("query:" + json.dumps(body))    


def xstr(s):
    return '' if s is None else str(s)


if __name__ == '__main__':
    ret = parse_args()
    host = '192.168.1.75'
    index = ret.index
    aggSize = 10000
    aggField = xstr(ret.field) + '.keyword'
    es = Elasticsearch(hosts=[{'host': host, 'port': 9200}])
    aggFieldObj = json.loads(ret.aggField.replace("'", "\""))
    if not (ret.hours is None):
        newIndex = index + '-' + xstr(ret.field) + xstr(ret.hours) + 'h'
    elif not (ret.days is None):
        newIndex = index + '-' + xstr(ret.field) + xstr(ret.days) + 'd'
    else:
        newIndex = index + '-' + xstr(ret.field) + xstr(ret.minutes) + 'm'
    created()
    timeRange()
    print("index:" + newIndex)
    print("Data aggregation success")
