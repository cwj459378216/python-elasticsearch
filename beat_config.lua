elasticsearch = {
        address = "localhost:9200"
}

LogType = {
        JSON    = 1,
        CSV             = 2
}

postgreSQL = {
        pgAddress = "localhost",
        pgPort = 5432,
        pgUser = "postgres",
        pgPassword = "postgres",
        pgDB = "omni_bot",
}


CleanLogsStrategy = {
    {
        rootPath = "/datastore/user/admin/logs/zeek/",
        stepDeep = 2,
        bakRegex = "^(.*)(\\d{2,4}\\-\\d{2}\\-\\d{2})(.*)\\.log|extract_files$",
        timeOut = 0,
        cleanDirs = "false",
        module = "zeek"
    },
    {
        rootPath = "/datastore/user/admin/logs/thunder-bot/",
        stepDeep = 2,
        bakRegex = "(.*)",
        timeOut = 300,
        cleanDirs = "false",
        module = "apm"
        
    },
    {
        rootPath = "/datastore/temp/magnet/scanfile/",
        stepDeep = 5,
        bakRegex = "(.*)",
        timeOut = 604800,
        cleanDirs = "true",
        module = "scanfile"
    },
    {
        rootPath = "/datastore/user/admin/coredump/",
        stepDeep = 1,
        bakRegex = "(.*)",
        timeOut = 604800,
        cleanDirs = "false",
        module = "coredump"
    }
}


-- not relate log files index create in this
ElasticSearchIndex = 
{
    {
        index = "maririn-statistics",
        type = "maririn-statistics",
        mapping = "/datastore/user/admin/conf/mapping/pvc-inoutband.json"
    },
    {
        index = "maririn-traffic",
        type = "maririn-traffic",
        mapping = "/datastore/user/admin/conf/mapping/pvc-traffic.json"
    }
}



RealTimeLogMonitor = {
        {
                path    = "/datastore/user/admin/logs/zeek/*/conn.log",
                format  = LogType.CSV,
                index   = "omni-bro-conn",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-conn.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tproto\tservice\tduration\torigBytes\trespBytes\tconnState\tlocalOrig\tlocalResp\tmissedBytes\thistory\torigPkts\torigIpBytes\trespPkts\trespIpBytes\ttunnelParents\tappName\tappCate\tkpiNRT\tkpiART\tkpiSRT\tkpiCRT\tkpiPTT\tkpiLatency\tkpiRetran\tkpiTTFB\tipVersion\tiface",
                unset   = '-',
                alarm   = "conn"
        },
        {
                path    = "/datastore/user/admin/logs/zeek/*/http.log",
                format  = LogType.CSV,
                index   = "omni-bro-http",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-http.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\ttransDepth\tmethod\tdomain\turi\treferrer\tversion\tuserAgent\torigin\trequestBodyLen\tresponseBodyLen\tstatusCode\tstatusMsg\tinfoCode\tinfoMsg\ttags\tusername\tpassword\tproxied\torigFuids\torigFileName\torigMimeTypes\trespFuids\trespFilename\trespMimeTypes\tiface",
                unset   = '-',
                alarm   = "http"
        },
--        {
--                path    = "/datastore/user/admin/logs/zeek/*/files.log",
--                format  = LogType.CSV,
--                index   = "omni-bro-file",
--                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
--                type    = "bro",
--                fields  = "ts\tfuid\tsrcIP\tdstIP\tconnUids\tsource\tdepth\tanalyzers\tmimeType\tfilename\tduration\tlocalOrig\tisOrig\tseenBytes\ttotalBytes\tmissingBytes\toverflowBytes\ttimedout\tparentFuid\tmd5\tsha1\tsha256\textracted\textracted_cutoff\textracted_size\tiface",
--                unset   = '-',
--                interval = 300
--        },
        {
                path    = "/datastore/user/admin/logs/zeek/*/dns.log",
                format  = LogType.CSV,
                index   = "omni-bro-dns",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tproto\ttransId\trtt\tquery\tqclass\tqclassName\tqtype\tqtypeName\trcode\trcodeName\tAA\tTC\tRD\tRA\tZ\tanswers\trejected\tdnsBytes\tdnsPkts\topCode\tiface",
                unset   = '-',
                alarm   = "dns"
        },
        {
                path    = "/datastore/user/admin/logs/zeek/*/smtp.log",
                format  = LogType.CSV,
                index   = "omni-bro-smtp",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\ttransDepth\thelo\tmailfrom\trcptto\tdate\tfrom\tto\tcc\treplyTo\tmsgId\tinReplyTo\tsubject\txOriginatingIp\tfirstReceived\tsecondReceived\tlastReply\tpath\tuserAgent\ttls\tfuids\tiface",
                unset   = '-'
        },
        {
                path    = "/datastore/user/admin/logs/zeek/*/dhcp.log",
                format  = LogType.CSV,
                index   = "omni-bro-dhcp",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
                type    = "bro",
                fields  = "ts\tuids\tclientAddr\tserverAddr\tmac\thostName\tclientFqdn\tdomain\trequestedAddr\tassignedAddr\tleaseTime\tclientMessage\tserverMessage\tmsgTypes\tduration\tiface",
                unset   = '-'
        },
        {
                path    = "/datastore/user/admin/logs/zeek/*/ftp.log",
                format  = LogType.CSV,
                index   = "omni-bro-ftp",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tuser\tpassword\tcommand\targ\tmimeType\tfileSize\treplyCode\treplyMsg\tdataChannelPassive\tdataChannelOrigH\tdataChannelRespH\tdataChannelRespP\tfuid\tiface",
                unset   = '-'
        },
--        {
--                path    = "/datastore/user/admin/logs/zeek/*/modbus.log",
--              format  = LogType.CSV,
--                index   = "omni-bro-modbus",
--                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
--                type    = "bro",
--                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tfunc\texception\tiface",
--                unset   = '-',
--                interval = 300
--        },
--        {
--                path    = "/datastore/user/admin/logs/zeek/*/rdp.log",
--                format  = LogType.CSV,
--                index   = "omni-bro-rdp",
--                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
--                type    = "bro",
--                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tcookie\tresult\tsecurityProtocol\tclientChannels\tkeyboardLayout\tclientBuild\tclientName\tclientDigProductId\tdesktop_width\tdesktopHeight\trequestedColorDepth\tcertType\tcertCount\tcertPermanent\tencryptionLevel\tencryptionMethod\tiface",
--                unset   = '-'
--        },
        {
                path    = "/datastore/user/admin/logs/zeek/*/smb_cmd.log",
                format  = LogType.CSV,
                index   = "omni-bro-smb-cmd",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tcommand\tsubCommand\targument\tstatus\trtt\tversion\tuserName\ttree\ttreeService\tfileTS\tfileUID\tfileSrcIP\tfileSrcPort\tfileDstIP\tfileDstPort\tfileFuid\tfileAction\tfilePathName\tfileName\tfileSize\tfilePrevName\tfileMTime\tfileATime\tfileCTime\tfileChTime\tiface",
                unset   = '-'
        },
        {
                path    = "/datastore/user/admin/logs/thunder-bot/AppApmSite/ApmSite*",
                format  = LogType.CSV,
                index   = "omni-apm-site",
                mapping = "/datastore/user/admin/conf/mapping/pvc-apm-common.json",
                type    = "thunder",
                fields  = "ts\tsiteId\tpacket\tbyte\tkpiART\tkpiPTT\tkpiNRT\tkpiSRT\tkpiCRT\tkpiTTFB\tkpiLatency\tretry\tgroupType\tchannelID\tiface"
        },
--        {
--                path    = "/datastore/user/admin/logs/thunder-bot/AppApmApplication/ApmApplication*",
--                format  = LogType.CSV,
--                index   = "omni-apm-application",
--                mapping = "/datastore/user/admin/conf/mapping/pvc-apm-common.json",
--                type    = "thunder",
--                fields  = "ts\tapplicationId\tpacket\tbyte\tkpiART\tkpiPTT\tkpiNRT\tkpiSRT\tkpiCRT\tkpiTTFB\tkpiLatency\tretry\tchannelID\tiface",
--                interval = 300
--        },
--        {
--                path    = "/datastore/user/admin/logs/thunder-bot/AppApmApplicationGroup/ApmApplicationGroup*",
--               format  = LogType.CSV,
--                index   = "omni-apm-applicationgroup",
--                mapping = "/datastore/user/admin/conf/mapping/pvc-apm-common.json",
--                type    = "thunder",
--                fields  = "ts\tapplicationgroupId\tpacket\tbyte\tkpiART\tkpiPTT\tkpiNRT\tkpiSRT\tkpiCRT\tkpiTTFB\tkpiLatency\tretry\tchannelID\tiface",
--                interval = 300
--        },
        {
                path    = "/datastore/user/admin/logs/thunder-bot/AppApmServer/ApmServer*",
                format  = LogType.CSV,
                index   = "omni-apm-server",
                mapping = "/datastore/user/admin/conf/mapping/pvc-apm-common.json",
                type    = "thunder",
                fields  = "ts\tserverIp\tpacket\tbyte\tkpiART\tkpiPTT\tkpiNRT\tkpiSRT\tkpiCRT\tkpiTTFB\tkpiLatency\tretry\tchannelID\tiface"
        },
        {
                path    = "/datastore/user/admin/logs/thunder-bot/AppApmServerGroup/ApmServerGroup*",
                format  = LogType.CSV,
                index   = "omni-apm-servergroup",
                mapping = "/datastore/user/admin/conf/mapping/pvc-apm-common.json",
                type    = "thunder",
                fields  = "ts\tservergroupIp\tpacket\tbyte\tkpiART\tkpiPTT\tkpiNRT\tkpiSRT\tkpiCRT\tkpiTTFB\tkpiLatency\tretry\tgroupType\tchannelID\tiface"
        },
        {
                path    = "/datastore/user/admin/logs/thunder-bot/AppAlarm/ApmAlarm*",
                format  = LogType.CSV,
                index   = "omni-alarm-event",
                mapping = "/datastore/user/admin/conf/mapping/pvc-events.json",
                type    = "alarm",
                fields  = "ts\talarmId\tseverity\tsrcIP\tsrcPort\tdstIP\tdstPort\tmessage\tsiteId\tappId\tserverGroupId\tappGrpId\tchannelID\tserverIp\tiface\tsourceClass\tdetail"
        }
}


ScanFileLogMonitor = {
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/conn*",
                format  = LogType.CSV,
                index   = "omni-bro-conn",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tproto\tservice\tduration\torigBytes\trespBytes\tconnState\tlocalOrig\tlocalResp\tmissedBytes\thistory\torigPkts\torigIpBytes\trespPkts\trespIpBytes\ttunnelParents\tappName\tappCate\tkpiNRT\tkpiART\tkpiSRT\tkpiCRT\tkpiPTT\tkpiLatency\tkpiRetran\tkpiTTFB\tipVersion\tfilePath",
                unset   = '-',
                alarm   = "conn"
        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/http*",
                format  = LogType.CSV,
                index   = "omni-bro-http",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\ttransDepth\tmethod\tdomain\turi\treferrer\tversion\tuserAgent\torigin\trequestBodyLen\tresponseBodyLen\tstatusCode\tstatusMsg\tinfoCode\tinfoMsg\ttags\tusername\tpassword\tproxied\torigFuids\torigFileName\torigMimeTypes\trespFuids\trespFilename\trespMimeTypes\tfilePath",
                unset   = '-',
                alarm   = "http"
        },
--        {
--                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/files*",
--                format  = LogType.CSV,
--                index   = "omni-bro-file",
--                type    = "bro",
--                fields  = "ts\tfuid\tsrcIP\tdstIP\tconnUids\tsource\tdepth\tanalyzers\tmimeType\tfilename\tduration\tlocalOrig\tisOrig\tseenBytes\ttotalBytes\tmissingBytes\toverflowBytes\ttimedout\tparentFuid\tmd5\tsha1\tsha256\textracted\textracted_cutoff\textracted_size\tfilePath",
--                unset   = '-'
--        },
       {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/dhcp*",
                format  = LogType.CSV,
                index   = "omni-bro-dhcp",
                type    = "bro",
                fields  = "ts\tuids\tclientAddr\tserverAddr\tmac\thostName\tclientFqdn\tdomain\trequestedAddr\tassignedAddr\tleaseTime\tclientMessage\tserverMessage\tmsgTypes\tduration\tfilePath",
                unset   = "-"
        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/dns*",
                format  = LogType.CSV,
                index   = "omni-bro-dns",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tproto\ttransId\trtt\tquery\tqclass\tqclassName\tqtype\tqtypeName\trcode\trcodeName\tAA\tTC\tRD\tRA\tZ\tanswers\trejected\tdnsBytes\tdnsPkts\topCode\tfilePath",
                unset   = '-',
                alarm   = "dns"
        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/smtp*",
                format  = LogType.CSV,
                index   = "omni-bro-smtp",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\ttransDepth\thelo\tmailfrom\trcptto\tdate\tfrom\tto\tcc\treplyTo\tmsgId\tinReplyTo\tsubject\txOriginatingIp\tfirstReceived\tsecondReceived\tlastReply\tpath\tuserAgent\ttls\tfuids\tfilePath",
                unset   = '-'
        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/ftp*",
                format  = LogType.CSV,
                index   = "omni-bro-ftp",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tuser\tpassword\tcommand\targ\tmimeType\tfileSize\treplyCode\treplyMsg\tdataChannelPassive\tdataChannelOrigH\tdataChannelRespH\tdataChannelRespP\tfuid\tfilePath",
                unset   = '-'
        },
--        {
--                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/modbus*",
--                format  = LogType.CSV,
--                index   = "omni-bro-modbus",
--                type    = "bro",
--                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tfunc\texception\tfilePath",
--                unset   = '-'
--        },
--        {
--                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/rdp*",
--                format  = LogType.CSV,
--                index   = "omni-bro-rdp",
--                type    = "bro",
--                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tcookie\tresult\tsecurityProtocol\tclientChannels\tkeyboardLayout\tclientBuild\tclientName\tclientDigProductId\tdesktop_width\tdesktopHeight\trequestedColorDepth\tcertType\tcertCount\tcertPermanent\tencryptionLevel\tencryptionMethod\tfilePath",
--                unset   = '-'
--        },
       {
                path    = "/datastore/temp/magnet/scanfile/*/logs/zeek/smb_cmd*",
                format  = LogType.CSV,
                index   = "omni-bro-smb-cmd",
                mapping = "/datastore/user/admin/conf/mapping/pvc-zeek-common.json",
                type    = "bro",
                fields  = "ts\tuid\tsrcIP\tsrcPort\tdstIP\tdstPort\tcommand\tsubCommand\targument\tstatus\trtt\tversion\tuserName\ttree\ttreeService\tfileTS\tfileUID\tfileSrcIP\tfileSrcPort\tfileDstIP\tfileDstPort\tfileFuid\tfileAction\tfilePathName\tfileName\tfileSize\tfilePrevName\tfileMTime\tfileATime\tfileCTime\tfileChTime\tfilePath",
                unset   = '-'
        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/thunder-bot/AppApmSite/ApmSite*",
                format  = LogType.CSV,
                index   = "omni-apm-site",
                type    = "thunder",
                fields  = "ts\tsiteId\tpacket\tbyte\tART\tPTT\tNRT\tSRT\tCRT\tTTFB\tkpiLatency\tretry\tgroupType\tchannelID\tfilePath",
                unset   = '-'
        },
--        {
--                path    = "/datastore/temp/magnet/scanfile/*/logs/thunder-bot/AppApmApplication/ApmApplication*",
--                format  = LogType.CSV,
--                index   = "omni-apm-application",
--                type    = "thunder",
--                fields  = "ts\tapplicationId\tpacket\tbyte\tART\tPTT\tNRT\tSRT\tCRT\tTTFB\tkpiLatency\tretry\tchannelID\tfilePath",
--                interval = "300"
--        },
--        {
--                path    = "/datastore/temp/magnet/scanfile/*/logs/thunder-bot/AppApmApplicationGroup/ApmApplicationGroup*",
--                format  = LogType.CSV,
--                index   = "omni-apm-applicationgroup",
--                type    = "thunder",
--                fields  = "ts\tapplicationgroupId\tpacket\tbyte\tART\tPTT\tNRT\tSRT\tCRT\tTTFB\tkpiLatency\tretry\tchannelID\tfilePath",
--                interval = "300"
--        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/thunder-bot/AppApmServer/ApmServer*",
                format  = LogType.CSV,
                index   = "omni-apm-server",
                type    = "thunder",
                fields  = "ts\tserverIp\tpacket\tbyte\tART\tPTT\tNRT\tSRT\tCRT\tTTFB\tkpiLatency\tretry\tchannelID\tfilePath",
                unset   = "-"
        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/thunder-bot/AppApmServerGroup/ApmServerGroup*",
                format  = LogType.CSV,
                index   = "omni-apm-servergroup",
                type    = "thunder",
                fields  = "ts\tservergroupIp\tpacket\tbyte\tART\tPTT\tNRT\tSRT\tCRT\tTTFB\tkpiLatency\tretry\tgroupType\tchannelID\tfilePath",
                unset   = '-'

        },
        {
                path    = "/datastore/temp/magnet/scanfile/*/logs/thunder-bot/AppAlarm/ApmAlarm*",
                format  = LogType.CSV,
                index   = "omni-alarm-event",
                type    = "alarm",
                fields  = "ts\talarmId\tseverity\tsrcIP\tsrcPort\tdstIP\tdstPort\tmessage\tsiteId\tappId\tserverGroupId\tappGrpId\tchannelID\tserverIp\tfilePath\tsourceClass\tdetail",
                unset   = "-"
        }
}


--Other file that need Monitor to delete file or folder,interval is user set millisecond  wait for file last update;
