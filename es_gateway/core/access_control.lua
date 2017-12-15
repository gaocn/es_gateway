--[[
    @Author gww
    @Date   2017-04-10
    @Description 
]]--

local logger  = require "es_gateway.utils.logger"
local handler = require "es_gateway.core.handler"
local redis_helper   = require "es_gateway.redis.redis_helper"
logger.set_priority(1)

local function escape_line(id)
    res, cnt = string.gsub(id,'%-','_')
    return res
end

--[[
    retrieve header
    curl -H"X_TOKEN:indices" localhost:80/kafka_ebflog_qpay_log-2017.04.08?pretty
]]--
local token = ngx.var.http_x_token
if token == nil then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

local indices = redis_helper.get_token_value(token)
if indices == nil then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

--[[
    retrieve header kbn_name
    curl -H"KBN_NAME:kibana" localhos:80
    test case: indices = {"qpay", "mbank", "perbank"}
]]--
local kbnName = ngx.var.http_kbn_name
local uri = escape_line(string.lower(ngx.var.uri))
local requestMethod = ngx.var.request_method

if kbnName == nil then
    handler.preprocess_acl(uri, requestMethod)
    handler.process_request(uri, requestMethod, indices)
else
    indices[#indices + 1] = kbnName
    handler.process_kibana_request(uri, kbnName, indices)
end
