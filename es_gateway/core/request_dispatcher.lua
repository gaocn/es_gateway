--[[
    @Date 2017-08-31
    @Description: functions related to dispatcher request to different es cluster according to system id of request uri.

    NOTE: all retrieve infomation should be lower case ~_~

    @refactor: 2017/12/12  by gww
]]--

-- to reuse this module, define this file as a module which cause this module will be loaded only once. 
-- module('request_dispatcher', package.seeall)

local logger = require "es_gateway.utils.logger"
local gateway_conf = require "es_gateway.gateway_conf"
local str_utils = require "es_gateway.utils.string"
local escape_wildcard = str_utils.escape_wildcard
local truncate = str_utils.truncate
local find_last = str_utils.find_last
local SYSTEM_CLISTER_MAP = gateway_conf.system_cluster_map


--[[
    retrieve system id from request data
    logger:debug(get_system_id('/kafka_log_mbank_log-*/_refresh'))  ==> mbank
    logger:debug(get_system_id('/kafka_log_fqz-qpay_log-*/_cache/clear')) ==> fqz-qpay
    logger:debug(get_system_id('/twitter/cache/clear'))  ==> nil
    logger:debug(get_system_id('/kafka_log_fqz-qpay_log-*,kafka_log_mbank_log-*/_search'))==> [fqz-qpay,mbank]
    logger:debug(get_system_id('/kafka_perbank_log-2017.08.30')) ==> perbank
    logger:debug(get_system_id('/apm_kibana_es_ulog')) ==> es_ulog
    logger:debug(get_system_id('select * from kafka_log_pqay_log-2017.11.30')) ==> pqay
    logger:debug(get_system_id('select * from kafka_sjsh_bbfree_log-2017.11.30 limit 10')) ==> sjsh_bbfree
    logger:debug(get_system_id('select * from asmp_kibana_ulog where age > 20 limit 5')) ==> ulog
]]--
local function get_system_id(data)
    data = escape_wildcard(data)
    data = string.lower(data)

    log_pattern = 'kafka_log_(.-)_log'
    monitor_pattern = 'kafka_(.-)_log'
    kibana_pattern = '_kibana_(.-)[/ ]'
    
    systemID = {}
    idx = 1

    if string.match(data, 'kafka_log') then
        for id in string.gmatch(data, log_pattern) do
            systemID[idx] = id
            idx = idx + 1
        end
    elseif string.match(data, 'kafka_') then 
       for id in string.gmatch(data, monitor_pattern) do
            systemID[idx] = id
            idx = idx + 1
        end
    else
        for id in string.gmatch(data, kibana_pattern) do
            systemID[idx] = id
            idx = idx + 1
        end
    end

    --for key, id in pairs(systemID) do
    --    logger.debug('%s #### %s', key ,id)
    --end
    return systemID
end

--[[
  @Return:
    true ,system_id 
       return true and the system id if all system id from this request are from same es cluster
    false 
      return false if there exists a system id which is different from others
]]--
local function is_same_cluster(systemID)
    cluster = nil
    for key, id in pairs(systemID) do
        if cluster == nil then
            cluster = SYSTEM_CLISTER_MAP[id]
        else
            if SYSTEM_CLISTER_MAP[id] == nil or cluster ~= SYSTEM_CLISTER_MAP[id] then
                logger.warn("indices should not access different clusters")
                return false
            end
        end
    end

    return true, cluster
end

local function construct_upstream_url(cluster_id)
    local url = 'http://' .. cluster_id .. ngx.var.uri

    pattern = '&?ClientIP'
    args = ngx.var.args
    args = truncate(args, pattern)
    
    if args ~= nil then
        url = url .. '?' .. args
    end
    return url
end

--[[
    1. get system id from data
    2. determine upstream to which this requests is dispatched using ngx.shared.system_cluster_map
    3. call ngx.exec to dispatch request
]]--
local function do_dispatch(data)
    local system_id = get_system_id(data)
    status, cluster_id = is_same_cluster(system_id)
    local urlKey = "worker_" .. ngx.worker.id()

    if status == false then
        --forbidden for different cluster indices in same request
        logger.warn('forbidden for different cluster indices in same request')
        ngx.exit(ngx.HTTP_FORBIDDEN)
    elseif cluster_id then
        --dispatcher to cluster
       url = construct_upstream_url(cluster_id)
       logger.debug("proxy_pass: %s", url)
       ngx.shared.system_cluster_map[urlKey] = url
       ngx.exec('@dispatcher')
    else
       logger.warn("cluster id is nil")
       ngx.exit(ngx.HTTP_FORBIDDEN)
    end
end

--[[
    dispatch request according to requset_uri
]]--
local function dispatch_request()
    do_dispatch(ngx.var.uri)
end

--[[
    dispatcher SQL Request to specific ES_Cluster.
    NOTE: 
        Only SELECT SQL Statement is allowed!
    eg:
        curl -XPOST http://gateway/_sql -d'SELECT * from indexName limit 10'
    @body: SQL Statement in lower case
]]--
local function dispatch_sql_request(body)
    -- NOT SELECT statement, should forbbiden!
    if string.match(string.lower(body), 'select') then
        do_dispatch(body)
    else
        logger.warn("only SELECT statements is allowed!")
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end
end

--[[
   kbn_name format: systemid_kibana_ulog
   dispatcher kibana request to differrnt cluster according to kbn_name
]]--
local function dispatch_kibana_request()
   local kbnName = string.lower(ngx.var.http_kbn_name)
   local urlKey = "worker_" .. ngx.worker.id()
 
   if kbnName ~= nil then
       idx = find_last(kbnName, 'kibana_')
       if idx ~= nil then
           clusterID = string.lower(string.sub(kbnName, idx + 1))
       else
           --false check
           logger.warn("can not find es cluster name from kbn_name[%s]!", kbnName)
           ngx.exit(ngx.HTTP_FORBIDDEN)
       end
       url = construct_upstream_url(clusterID)
       ngx.shared.system_cluster_map[urlKey] = url
       logger.debug("proxy_pass: %s", url)
       ngx.exec('@dispatcher')
   else
       logger.warn("kbn_name is nil")
       ngx.exit(ngx.HTTP_FORBIDDEN)
   end
end


local _M = {}

return setmetatable(_M, {
    __tostring = function(tb) 
        return "[Request Dispatcher do allocation requests to corresponding upstream!]"
    end
    ,
    __index = {
        dispatch_kibana_request = dispatch_kibana_request,
        dispatch_sql_request = dispatch_sql_request,
        dispatch_request = dispatch_request,

        -- for test
--        construct_upstream_url = construct_upstream_url,
--        do_dispatch = do_dispatch,
--        is_same_cluster = is_same_cluster,
--        get_system_id = get_system_id,
    }
})