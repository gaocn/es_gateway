--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/15
-- Description: 
--

--local dispatcher = require("request_dispatcher")
local logger     = require "es_gateway.utils.logger"
local dispatcher = require "es_gateway.core.request_dispatcher"
local str_utils = require "es_gateway.utils.string"
local split = str_utils.split

logger.set_priority(1)

--*********************  function definition  **************************--

--@func http_body
--  EG:
--    curl localhost:80/kafka_log_qpay-2017.04.09/search -d'{"title":"Consuming for buy"}'
--    After Process we get a string of request_body: {"title":"Consuming for buy"}
--@return
--  @params body: nil if there is no JOSN BODY
--
function http_body()
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    return body
end

--[[
 found = false this request has should be forbidden
 found = true this request is allowed to forward to upstream servers to process
]]--

function process_request(uri,requestMethod,indices)
    local isValid = is_request_valid(uri, requestMethod, indices)

    if not isValid then
        logger.debug('Request is not valid ' .. uri .. requestMethod)
        ngx.exit(ngx.HTTP_FORBIDDEN)
    else
        dispatcher.dispatch_request()
    end
end

--[[
    return a indices table in uri, if there is no indices return nil
    eg:
      for uri = /index1,index2/type return a table {'index1','index2'}
]]--
function get_indices(uri)
    if string.len(uri) <= 1 then
        return nil
    end
    local item
    sIdx, eIdx = string.find(uri, '(/.-)/', 0)
    if eIdx ~= nil then
        item = string.sub(uri, sIdx + 1, eIdx - 1)
    else
        item = string.sub(uri, 2)
    end
    if string.match(item, ',') then
        return split(item, ',')
    else
        local itemTable = {}
        itemTable[#itemTable+1] = item
        return itemTable
    end
end

--
--	@func: by default GET request is allowed only if this request has permission to access relevant indices
--  @return
--     true if this request pass ACL validation
--     false if the request is invalid
--
function is_request_valid(uri, requestMethod, AuthIndices)
    local requestIndices = get_indices(uri)
    if requestIndices == nil then
        return false
    end

    for _, index in ipairs(requestIndices) do
        local found = false
        for _, authIndex in ipairs(AuthIndices) do
            if string.find(index, authIndex) ~= nil then
                --ngx.say(index, '--', authIndex)
                if requestMethod == 'GET' then
                    return true
                end
                -- if acl_table[authIndex] is defined and is valid then found = true else found = false
                -- load from  share memory, and store it into ACL_TABLE
                local ACL_TABLE = ngx.shared.acl_table
                if ACL_TABLE[authIndex] then
                    value = ACL_TABLE[authIndex]
                    if string.find(value.method, requestMethod) and value.on_off == 'ON' then
                        return true
                    else
                        found = false
                    end
                else
                    -- in this if-case, it means requestIndices contains one of authenticated indices, so return true
                    return true
                end
            end
        end
        if not found then
            return false
        end
    end
    return false
end

-- ******************* kibana relevant functions *********************--
--[[
    indicse = "kafka_log.obs*, kafka_log_mbank-2017*"
    table authIndices = "obs,mbank, fz_mbank"
]]--
function is_msearch_valid(indices, authIndices)
    indices = split(indices,',')
    for idx, index in ipairs(indices) do
        local found = false
        for idy, pattern in ipairs(authIndices) do
            if string.find(index, pattern) ~= nil then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end
    return true
end

--[[
   function: if rerquest is _mget  request and _index == 'kbn_name', then return true, otherwise return false
   httpUrl:  http://10.230.135.126:5601/es_admin/_mget
   httpBody: {"docs":[{"_index":"ee7aacc3kibana","_type":"visualization","_id":"634d8960-2edf-11e7-a8d3-1d9cd2997bf0"}]}
]]--
function is_mget_valid(kbnName, httpBody)
    pattern = '"_index":".-"'
    local startPos = 0
    startIdx,endIdx = string.find(httpBody, pattern, startPos)
    while  startIdx and endIdx do
        kName = string.sub(httpBody, startIdx + 10, endIdx - 1)
        if kName ~= kbnName then
            return false
        end
        startPos = endIdx
        startIdx,endIdx = string.find(httpBody, pattern, startPos)
    end
    return true
end

--[[
   function: from http request body, we get all indices info
   str = "{\"index\":[\"kafka_log_obs_log-2017.04.30\",\"kafka_log_obs_log-2017.05.01\"],\"ignore_unavailable\":true,\"preference\":1493689684385}"
   return: "kafka_log_obs_log-2017.04.30","kafka_log_obs_log-2017.05.01"
]]--
function get_msearch_indices(httpBody)
    local indices = ""
    local pattern="\"index\":%[.-%]"
    local startPos = 0
    startIdx,endIdx = string.find(httpBody, pattern, startPos)
    while  startIdx and endIdx do
        if indices == "" then
            indices = string.sub(httpBody, startIdx + 9, endIdx - 1)
        else
            indices = indices .. "," .. string.sub(httpBody, startIdx + 9, endIdx - 1)
        end
        startPos = endIdx
        startIdx,endIdx = string.find(httpBody, pattern, startPos)
    end
    return indices
end

--[[
    uri = /api/kibana/settings/defaultIndex
]]--
function is_default_index_request(uri)
    if string.find(uri, 'kibana/settings/defaultIndex') ~= nil then
        return true
    end
    return false
end

--[[
    uri = /es_admin/kibanaIndexName/_refresh
]]--

function is_refresh_request(uri)
    if string.find(uri, '_refresh') ~= nil then
        return true
    end
    return false
end

--[[
     funciton used to process AccessControl for kibana request

     Refactor: dispatcher.dispatchKibanaRequest()
]]--

function process_kibana_request(uri, kbnName, authIndices)
    --[[
         particular process for pruduct environment
         for if
              request_uri="/0d77fdf2_kibana/index-pattern/_search?stored_fields="
         after processed by F5 it will be:
              request_uri="/0d77fdf2_kibana/index-pattern/_search?stored_fields=&ClientIP=10.230.135.128&X_"
          which will be treated as an illegal HTTP request.

        So here if we mathch the request_uri, we rewrite it as it original format
    ]]--
    --particularProcessForKibanaInProductEnv(ngx.var.uri, ngx.var.request_uri)

    if uri == '/' and ngx.var.request_method == 'HEAD' then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end

    if string.find(uri, '/_nodes') ~= nil then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
    pattern = '/_cluster/health/' .. kbnName
    if string.find(uri, pattern) then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
    -- allow kibana's export and import funciton
    if string.find(uri, '/_search/scroll') ~= nil then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
    -- allow kibana Timelion board
    if string.find(uri, '/app/timelion') ~= nil then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
    if string.find(uri, '/api/timelion/run') ~= nil then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end


    -- allow _refresh API
    if is_refresh_request(uri) then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
    -- allow /defaultIndex API
    if is_default_index_request(uri) then
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
    -- get request body, reutrn nil if there is no body
    httpbody = http_body()

    --ngx.say(uri,'----', kbnName, '====', indices, '****', authIndices)
    --if string.find(uri, '/es_admin/_mget') ~= nil then
    if string.find(uri, '/_mget') ~= nil and httpbody ~= nil then
        if is_mget_valid(kbnName, httpbody) then
            --ngx.say('passed')
            --ngx.exec("@upstreams")
            dispatcher.dispatch_kibana_request()
        else
            ngx.exit(ngx.HTTP_FORBIDDEN)
        end
    end

    if string.find(uri, '/_msearch') ~= nil and httpbody ~= nil then
        indices = get_msearch_indices(httpbody)
        if is_msearch_valid(indices, authIndices) then
            --ngx.exec("@upstreams")
            dispatcher.dispatch_kibana_request()
        else
            ngx.exit(ngx.HTTP_FORBIDDEN)
        end
    end

    --bug fix 20170906--  if uri has prefix /*obs  /*_kafka_log and so on, this request should be forbbiden
    if string.find(uri,'^/%*') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    -- if uri contains indices that match any of authIndices, then we rewrite request, otherwise return 403
    post_process_kibana_request(uri,  authIndices)
end

--[[
 found = false this request has should be forbidden
 found = true this request is allowed to forward to upstream servers to process
]]--
function post_process_kibana_request(uri, indices)
    found = false
    --indices = {'qpay', 'mbank', 'ka'}
    for idx, val in ipairs(indices) do
        pattern = string.lower(val)
        if string.find(uri, pattern) ~= nil then
            found=true
            --ngx.say(src,'----', pattern, '^^^^^', indices[idx], '@@@', val, '   ', idx)
            break
        end
    end

    if not found then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    else
        --ngx.exec("@upstreams")
        dispatcher.dispatch_kibana_request()
    end
end

--********************  ACL Strategy *********************************--
--[[
    for given request, check it according to @ACL_TABLE
    1. first tranform URI = simpleURI
        URI=/index/type/_refresh  simpleURI = /_refresh
    2. check if method is ON, then return true
             if method is OFF, then reutrn false
    isAllowed('/index/type/_refresh', 'PUT')
    isAllowed('/index', 'POST')
    isAllowed('/', 'POST')
    @return
	true   allow this request
	false  deny this request
	nil    no related rules, should be passed to another phase
]]--
function is_allowed(simpleUri, method)
    if simpleUri == nil then
        return nil
    end
    -- load from  share memory, and store it into ACL_TABLE
    local ACL_TABLE = ngx.shared.acl_table
    if ACL_TABLE[simpleUri] then
        value = ACL_TABLE[simpleUri]
        if string.find(value.method, 'ALL') and value.on_off == 'OFF' then
            return false
        end
        if string.find(value.method, 'ALL') and value.on_off == 'ON' then
            return true
        end
        if string.find(value.method, method) and value.on_off == 'ON' then
            return true
        else
            return false
        end
    end
    return nil
end
--[[
  	logger.debug(getSimpleUri('/index/type/_refresh'))  ==> /_refresh
	logger.debug(getSimpleUri('/twitter/_cache/clear')) ==> /_cache
 	logger.debug(getSimpleUri('/twitter/cache/clear'))  ==> nil
  	logger.debug(getSimpleUri('/my_source_index/_shrink/my_target_index'))==> /_shrink
 	logger.debug(getSimpleUri('/_cluster/state/_all/foo,bar')) ==> /_cluster
]]--
function get_simple_uri(fullUri)
    startPos = 0
    sIdx, eIdx = string.find(fullUri, '(/.-)/', startPos)
    while eIdx ~= nil do
        item = string.sub(fullUri, sIdx, eIdx - 1)
        if string.find(item, '^/_') then
            return item
        end
        startPos = eIdx
        sIdx, eIdx = string.find(fullUri, '(/.-)/', startPos)
    end
    item = string.sub(fullUri, startPos, -1)
    if string.find(item, '^/_') then
        return item
    end
    return nil
end

--[[ test method ]]--
function toString()
    for key,value in pairs(ACL_TABLE) do
        ngx.say(key,'--',value['method'], '--',value['on_off'])
    end

end

--[[
   for exception case like /_search/scroll, we permit this request
]]--
function permit_exception_uri(uri)
    if uri == '/_search/scroll' then
        --ngx.exec("@upstreams")
        dispatcher.dispatchr_request()
    end
end

function preprocess_acl(uri, method)
    permit_exception_uri(uri)
    --toString()
    simpleUri = get_simple_uri(uri)
    status = is_allowed(simpleUri, method)
    --logger.debug(uri, '===', simpleUri, '---', status)
    if status == false then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    if simpleUri == '/_sql' then
        dispatcher.dispatch_sql_request(http_body())
    end
end


local _M = {}

return setmetatable(_M, {
    __tostring = function(tb)
        return "Main Handler to process different http request."
    end,
    __index = {
        process_request = process_request,
        preprocess_acl = preprocess_acl,
        permit_exception_uri = permit_exception_uri,
        process_kibana_request = process_kibana_request,
        post_process_kibana_request = post_process_kibana_request,

        is_allowed = is_allowed,
        is_mget_valid = is_mget_valid,
        is_msearch_valid = is_msearch_valid,
        is_request_valid = is_refresh_request,
        is_refresh_request = is_refresh_request,
        is_default_index_request = is_default_index_request,

        http_body = http_body,
        get_indices = get_indices,
        get_simple_uri = get_simple_uri,
        get_msearch_indices = get_msearch_indices
    }
})