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
    parser.add_argument("--index", dest="index",
                        help="Select Index that needs to be aggregated, required", default="omni-bro-conn")
    parser.add_argument("--m", dest="minutes",
                        help="Aggregate per minute", default="1")
    parser.add_argument("--h", dest="hours", help="Aggregate per hour")
    parser.add_argument("--d", dest="days", help="Aggregate per day")

    parser.add_argument("--field", dest="field",
                        help="Select to aggregate a field")
    parser.add_argument("--showField", dest="showField",
                        help="Set the output field")

    parser.add_argument("--filter", dest="filter",
                        help="set filter")
    parser.add_argument("--aggField", dest="aggField",
                        help="set aggField")

    parser.add_argument("--topNSize", dest="topNSize",
                        help="set topNSize")
    parser.add_argument("--topNField", dest="topNField",
                        help="set topNField")
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
    # "%Y-%m-%dT%H:%M:%SZ"
    delaytime = 30
    formatTime = "%Y-%m-%dT"
    if not (ret.hours is None):
        timeAgo = (datetime.datetime.now() -
                   datetime.timedelta(hours=float(ret.hours)))
        timeNew = datetime.datetime.now()           
        formatTime = formatTime + "%H:00:00Z"
    elif not (ret.days is None):
        timeAgo = (datetime.datetime.now() -
                   datetime.timedelta(days=float(ret.days)))
        timeNew = datetime.datetime.now()
        formatTime = formatTime + "00:00:00Z"
    else:
        timeAgo = (datetime.datetime.now() -
                   datetime.timedelta(minutes=6))
        timeNew = (datetime.datetime.now() -
                   datetime.timedelta(minutes=5))        
        formatTime = formatTime + "%H:%M:00Z"
    timeStampOld = int(time.mktime(timeAgo.timetuple()))
    timeStampNew = int(time.mktime(timeNew.timetuple()))
    startTime = datetime.datetime.utcfromtimestamp(
        timeStampOld).strftime(formatTime)
    endTime = datetime.datetime.utcfromtimestamp(
        timeStampNew).strftime(formatTime)
    # time.sleep(delaytime)    
    query(startTime, endTime)


def created():
    if not es.indices.exists(index=newIndex):
        body = {
            "mappings": {
                "doc": {
                    'properties': {
                        "timestamp": {
                            "type": "date",
                            "format": "strict_date_optional_time||epoch_millis||yy/mm/dd-HH:mm:ss"
                        },
                        "srcIP":{"type":"ip"},
                        "dstIP":{"type":"ip"}
                    }
                }
            }
        }
        # body = {
        #     "mappings": {
        #         'properties': {
        #             "timestamp": {
        #                 "type": "date",
        #                 "format": "strict_date_optional_time||epoch_millis||yy/mm/dd-HH:mm:ss"
        #             }
        #         }
        #     }
        # }
        if not (ret.aggField is None):
            for k, v in aggFieldObj.items():
                kArr = k.split('_')
                way = kArr[0]
                kArr.remove(way)
                f = "".join(kArr)
                body.get("mappings").get('doc').get("properties")[f] = {"type": v}
                # body.get("mappings").get("properties")[f] = {"type": v}
        result = es.indices.create(index=newIndex, body=body, ignore=[
                                   400, 401, 404])
        print(result)


def timer(func):
    def wrapper(*args, **kwargs):
        res = func(*args, **kwargs)
        return res
    return wrapper


@timer
def batch_data(action):
    helpers.bulk(es, action)


def createAction(bucket, startTime):
    action = {
        "_index": newIndex,
        # '_type': "doc",
        '_type': "doc",
        "_source": {
            # "timestamp": startTime
        }
    }

    if not (ret.field is None):
        action.get('_source')[ret.showField] = bucket.get('key')
        action.get('_source')['docCount'] = bucket.get('doc_count')

    if not (ret.aggField is None):
        for k, v in aggFieldObj.items():
            kArr = k.split('_')
            way = kArr[0]
            kArr.remove(way)
            if (way != '#'):
                f = "".join(kArr)
                action.get('_source')[f] = bucket.get(k).get('value')

    if not (ret.topNField is None):
        for k, v in bucket.items():
            action.get('_source')[k] = v

    return action


def query(startTime, endTime):
    body = {
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
                    "gte": startTime,
                    "lt": endTime,
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
                            "gte": startTime,
                            "lt": endTime,
                        }
                    }
                }
            ]
        }}

    if not (ret.field is None):
        body.get('aggregations').get('distribute_by_key')[
            'terms'] = {"field": field, "size": aggSize}
        if not (ret.aggField is None):
            body.get('aggregations').get(
                'distribute_by_key')['aggregations'] = {}
            for k, v in aggFieldObj.items():
                kArr = k.split('_')
                way = kArr[0]
                if (way != '#'):
                    kArr.remove(way)
                    f = "".join(kArr)
                    body.get('aggregations').get('distribute_by_key')[
                        'aggregations'][k] = {way: {"field": f}}
        buckets = es.search(index=index, body=body).get(
            'aggregations').get('distribute_by_key').get('buckets')
        arr = []
        for bucket in buckets:
            arr.append(createAction(bucket, startTime))
        batch_data(arr)
    elif not (ret.aggField is None):
        body['aggregations'] = {}
        for k, v in aggFieldObj.items():
            kArr = k.split('_')
            way = kArr[0]
            if (way != '#'):
                kArr.remove(way)
                f = "".join(kArr)
                body.get('aggregations').get('distribute_by_key')[
                    'aggregations'][k] = {way: {"field": f}}
        buckets = es.search(index=index, body=body).get('aggregations')
        batch_data([createAction(buckets, startTime)])
    # print("query:" + json.dumps(body))
    if not (ret.topNField is None):
        queryBody = {}
        queryBody["query"] = {"bool": {
            "filter": [
                {
                    "range": {
                        "timestamp": {
                            "gte": startTime,
                            "lt": endTime,
                        }
                    }
                }
            ],
            "must_not": [{"prefix": {"filePath.keyword": {"value": "/datastore"}}}]
        }}
        queryBody["size"] = ret.topNSize
        topFields = ret.topNField.split(',')
        sourceStr = ''
        for topField in topFields:
            # print(topField)
            sourceStr += "doc['" + topField + "'].value" + " + "
        sourceArr = sourceStr.split(' + ')
        sourceArr.pop()
        source = '+'.join(sourceArr)
        queryBody["sort"] = {
            "_script": {
                "type": "number",
                "script": {
                    "lang": "painless",
                    "source": source,
                    "params": {
                        "factor": 1.1
                    }
                },
                "order": "desc"
            }
        }
        print(json.dumps(queryBody))
        buckets = es.search(index=index, body=queryBody)
        # print(json.dumps(buckets))
        # createAction(buckets.get('hits').get('hits'), endTime)
        print(len(buckets.get('hits').get('hits')))
        if not (ret.topNField is None):
            arr = []
            for bucket in buckets.get('hits').get('hits'):
                arr.append(createAction(bucket.get('_source'), startTime))
        batch_data(arr)
        # print("queryBody:" + json.dumps(queryBody))


def xstr(s):
    return '' if s is None else str(s).lower()


if __name__ == '__main__':
    ret = parse_args()
    host = 'localhost'
    index = ret.index
    aggSize = 10000
    es = Elasticsearch(hosts=[{'host': host, 'port': 9200}])
    if not (ret.field is None):
        field = ret.field
        if not (ret.showField is None):
            showField = ret.showField
        else:
            showField = field
    else:
        showField = ''
    if not (ret.aggField is None):
        aggFieldObj = json.loads(ret.aggField.replace("'", "\""))
    if not (ret.hours is None):
        newIndex = index + '-' + xstr(showField) + xstr(ret.hours) + 'h'
    elif not (ret.days is None):
        newIndex = index + '-' + xstr(showField) + xstr(ret.days) + 'd'
    else:
        newIndex = index + '-' + xstr(showField) + xstr(ret.minutes) + 'm'
    created()
    timeRange()
    print("index:" + newIndex)
    print("Data aggregation success")
