--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/18
-- Description: base plugin
--
local Object = require "es_gateway.vendor.classic"
local BasePlugin = Object:extend()

local ngx_log = ngx.log
local DEBUG = ngx.DEBUG

function BasePlugin:new(name)
    self._name = name
end

function BasePlugin:init_worker()
    ngx_log(DEBUG, "executing plugin \"", self._name, "\": init_worker")
end

function BasePlugin:certificate()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  certificate")
end

function BasePlugin:rewrite()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  rewrite")
end

function BasePlugin:access()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  access")
end

function BasePlugin:header_filter()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  header_filter")
end

function BasePlugin:body_filter()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  body_filter")
end

function BasePlugin:log()
    ngx_log(DEBUG, "execcuting  plugin \"", self._name, "\":  log")
end

return  BasePlugin
