--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/19
-- Description: 
--
local BasePlugin = require "es_gateway.plugins.base_plugin"
local response = require "es_gateway.utils.response"
local meta  = require "es_gateway.meta"

local server_header = string.format("%s/%s", meta._NAME, meta._VERSION)
local RequestTerminationHandler = BasePlugin:extend()

RequestTerminationHandler.PRIORITY = 7
RequestTerminationHandler.VERSION = '0.1.0'

function  RequestTerminationHandler:new()
    RequestTerminationHandler.super.new(self, "request-termination")
end

function  RequestTerminationHandler:access(conf)
    RequestTerminationHandler.super.access(self)

    local status_code = conf.status_code
    local content_type = conf.content_type
    local body = conf.body
    local message  = conf.message

    if body  then
        ngx.status = status_code

        if not content_type then
            content_type  = 'application/json;  charsest=utf-8s'
        end
        ngx.header['Content-Type'] = content_type
        ngx.header['Server'] = server_header

        ngx.say(body)
        return  ngx.exit(status_code)
    else
        return  response.send(status_code, message)
    end

end

return RequestTerminationHandler